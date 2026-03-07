<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * server-status.php — status wszystkich serwerów gry.
 *
 * GET /apik/v1/server-status.php
 *
 * INS-63: Reads servers dynamically from `games` DB table.
 * Zwraca listę serwerów z ich statusem (online/offline/maintenance),
 * liczbą graczy i pingiem. Launcher wyświetla to na ekranie Status.
 *
 * Serwer sprawdza TCP connect do game port (7172 itp.) aby potwierdzić online.
 */

require_once __DIR__ . '/common.php';

$ENV = loadEnvFiles([__DIR__ . '/.env', __DIR__ . '/../.env', '/var/www/html/.env']);

// INS-63: Load servers from DB (games table) instead of hardcoded array
$servers = [];
try {
    $db = getGlobalDb($ENV);
    $games = getActiveGamesFromDb($db, 'active,maintenance');

    foreach ($games as $game) {
        $worldId = (int)$game['sort_order'] - 1;
        $gamePort = (int)$game['game_port'];
        $loginPort = (int)($game['login_port'] ?? 0);
        if ($loginPort <= 0) {
            $loginPort = $gamePort;
        }

        $servers[] = [
            'id'        => $game['game_mode'] ?: $game['slug'],
            'worldId'   => $worldId,
            'gameMode'  => $game['game_mode'] ?: $game['slug'],
            'name'      => $game['name'],
            'host'      => $game['game_host'],
            'port'      => $gamePort,
            'loginPort' => $loginPort,
            'gamePort'  => $gamePort,
            'type'      => $game['engine_type'] ?? 'tibia',
            'dbStatus'  => $game['status'],
        ];
    }
} catch (\Throwable $e) {
    // DB unavailable — fallback to .env based config
    error_log('[server-status] DB unavailable, using .env fallback: ' . $e->getMessage());
    $servers = [
        [
            'id' => 'modern', 'worldId' => 1, 'gameMode' => 'modern', 'name' => 'Modern',
            'host' => $ENV['WORLD_MODERN_IP'] ?? $ENV['WORLD_IP'] ?? '127.0.0.1',
            'port' => (int)($ENV['WORLD_MODERN_PORT'] ?? $ENV['WORLD_PORT'] ?? 7174),
            'loginPort' => (int)($ENV['WORLD_LOGIN_PORT'] ?? 7173),
            'gamePort'  => (int)($ENV['WORLD_MODERN_PORT'] ?? $ENV['WORLD_PORT'] ?? 7174),
            'type' => 'tibia', 'dbStatus' => 'active',
        ],
        [
            'id' => 'classic74', 'worldId' => 0, 'gameMode' => 'classic74', 'name' => 'Classic 7.4',
            'host' => $ENV['WORLD_CLASSIC74_IP'] ?? $ENV['WORLD_IP'] ?? '127.0.0.1',
            'port' => (int)($ENV['WORLD_CLASSIC74_PORT'] ?? $ENV['WORLD_PORT'] ?? 7172),
            'loginPort' => (int)($ENV['WORLD_LOGIN_PORT'] ?? 7171),
            'gamePort'  => (int)($ENV['WORLD_CLASSIC74_PORT'] ?? $ENV['WORLD_PORT'] ?? 7172),
            'type' => 'tibia', 'dbStatus' => 'active',
        ],
    ];
}

$result = [];

foreach ($servers as $srv) {
    $online = false;
    $players = null;
    $pingMs = null;

    // If DB says maintenance, report that directly
    $dbStatus = $srv['dbStatus'] ?? 'active';

    // TCP connect check z pomiarem czasu
    $timeoutMs = (int)($ENV['SERVER_STATUS_TIMEOUT_MS'] ?? 800);
    $timeoutSec = max(1, (int)ceil($timeoutMs / 1000));

    $t0 = microtime(true);
    $sock = @fsockopen($srv['host'], $srv['port'], $errno, $errstr, $timeoutSec);
    $t1 = microtime(true);

    if ($sock) {
        $online = true;
        $pingMs = (int)(($t1 - $t0) * 1000);
        fclose($sock);

        // Próba odczytu graczy z bazy (opcjonalnie)
        $players = getOnlinePlayers($ENV, (int)$srv['worldId']);
    }

    // Determine displayed status: DB maintenance > TCP result
    $displayStatus = 'offline';
    if ($dbStatus === 'maintenance') {
        $displayStatus = 'maintenance';
    } elseif ($online) {
        $displayStatus = 'online';
    }

    $result[] = [
        'id' => $srv['id'],
        'worldId' => (int)$srv['worldId'],
        'gameMode' => $srv['gameMode'],
        'name' => $srv['name'],
        'type' => $srv['type'],
        'status' => $displayStatus,
        'players' => $players,
        'ping' => $pingMs,
        'host' => $srv['host'],
        'port' => $srv['port'],
        'loginPort' => $srv['loginPort'] ?? $srv['port'],
        'gamePort'  => $srv['gamePort'] ?? $srv['port'],
    ];
}

header('Cache-Control: public, max-age=15');

json_out([
    'ts' => time(),
    'servers' => $result,
]);

// ─────────────────────────────────────────────

function getOnlinePlayers(array $env, int $worldId): ?int
{
    try {
        $dsn = sprintf(
            'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
            $env['DB_HOST'] ?? '127.0.0.1',
            $env['DB_PORT'] ?? '3306',
            $env['DB_NAME'] ?? 'canaryaac'
        );
        $pdo = new PDO($dsn, (string)($env['DB_USER'] ?? 'root'), (string)($env['DB_PASS'] ?? ''), [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_TIMEOUT => 2,
        ]);

        // Preferuj count per-world: players_online JOIN players(world).
        try {
            $stmt = $pdo->prepare(
                'SELECT COUNT(*) AS cnt
                 FROM players_online po
                 INNER JOIN players p ON p.id = po.player_id
                 WHERE p.world = :world_id'
            );
            $stmt->execute(['world_id' => $worldId]);
            $row = $stmt->fetch();
            if ($row) {
                return (int)$row['cnt'];
            }
        } catch (\Throwable $inner) {
            // Fallback kompatybilności dla starszego schematu z world_id.
            try {
                $stmt = $pdo->prepare(
                    'SELECT COUNT(*) AS cnt
                     FROM players_online po
                     INNER JOIN players p ON p.id = po.player_id
                     WHERE p.world_id = :world_id'
                );
                $stmt->execute(['world_id' => $worldId]);
                $row = $stmt->fetch();
                if ($row) {
                    return (int)$row['cnt'];
                }
            } catch (\Throwable $inner2) {
                // Final fallback: global online count.
            }
        }

        $stmt = $pdo->query('SELECT COUNT(*) AS cnt FROM players_online');
        $row = $stmt->fetch();
        return $row ? (int)$row['cnt'] : 0;
    } catch (\Throwable $e) {
        return null;
    }
}
