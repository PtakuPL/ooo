<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * players-list.php — K8
 * Lista graczy wspólna lub per-serwer.
 * GET /apik/v1/players-list.php?mode=all|classic74|modern&onlineOnly=0|1&limit=200
 * Backward compatibility: gameMode query param is still accepted.
 */

require_once __DIR__ . '/common.php';

function parseModePlayers(string $mode): string
{
    return in_array($mode, ['all', 'classic74', 'modern'], true) ? $mode : 'all';
}

$modeRaw = (string)($_GET['mode'] ?? ($_GET['gameMode'] ?? 'all'));
$mode = parseModePlayers($modeRaw);
$onlineOnly = (int)($_GET['onlineOnly'] ?? 0) === 1;
$limit = (int)($_GET['limit'] ?? 200);
if ($limit < 1) {
    $limit = 1;
}
if ($limit > 1000) {
    $limit = 1000;
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

// F1: multi-DB — players are in ENGINE DBs
$playerSql = "
    SELECT p.id, p.name, p.level, p.vocation, p.lastlogin
    FROM players p
    " . ($onlineOnly ? "INNER JOIN players_online po ON po.player_id = p.id" : "") . "
    WHERE p.deletion = 0
    ORDER BY p.name ASC
    LIMIT ?
";

$players = [];

if ($mode === 'all') {
    // Query both engine DBs and merge
    $engines = getBothEnginePdos($ENV);
    foreach ($engines as $gm => $engineDb) {
        $worldIdVal = ($gm === 'modern') ? 1 : 0;
        try {
            $stmt = $engineDb->prepare($playerSql);
            $stmt->execute([$limit]);
            while ($row = $stmt->fetch()) {
                $players[] = [
                    'id' => (int)$row['id'],
                    'name' => (string)$row['name'],
                    'level' => (int)$row['level'],
                    'vocation' => (int)$row['vocation'],
                    'lastlogin' => (int)$row['lastlogin'],
                    'worldId' => $worldIdVal,
                    'gameMode' => $gm,
                    'online' => $onlineOnly,
                ];
            }
        } catch (\PDOException $e) {
            // Engine DB unavailable — skip
        }
    }
    // Sort merged and limit
    usort($players, fn($a, $b) => strcmp($a['name'], $b['name']));
    $players = array_slice($players, 0, $limit);
} else {
    // Query specific engine DB
    $engineDb = getEnginePdo($ENV, $mode);
    $worldIdVal = ($mode === 'modern') ? 1 : 0;
    $stmt = $engineDb->prepare($playerSql);
    $stmt->execute([$limit]);
    while ($row = $stmt->fetch()) {
        $players[] = [
            'id' => (int)$row['id'],
            'name' => (string)$row['name'],
            'level' => (int)$row['level'],
            'vocation' => (int)$row['vocation'],
            'lastlogin' => (int)$row['lastlogin'],
            'worldId' => $worldIdVal,
            'gameMode' => $mode,
            'online' => $onlineOnly,
        ];
    }
}

json_out([
    'mode' => $mode,
    'onlineOnly' => $onlineOnly,
    'limit' => $limit,
    'count' => count($players),
    'players' => $players,
]);
