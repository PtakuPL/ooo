<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * PLAN-S3: /apik/v1/games-list.php — lista gier dostępnych dla zalogowanego gracza.
 *
 * Input:  POST JSON { "sessionKey": "..." }
 * Output: { "games": [ { slug, name, engineType, gameHost, gamePort, platforms, status } ] }
 *
 * Wymaga aktywnej sesji (ticket_sessions) — launcher wywołuje po login.php.
 */

require_once __DIR__ . '/common.php';

// ------- read request -------
$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);

$sessionKey = is_array($req) && isset($req['sessionKey']) ? trim((string)$req['sessionKey']) : '';
if ($sessionKey === '') {
    sendError('Missing sessionKey.');
}

// ------- DB config (F1: multi-DB) -------
$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

$apiDb    = getApiDb($ENV);     // ticket_sessions
$globalDb = getGlobalDb($ENV);  // account_games + games

// ------- validate session (API_DB) -------
$now = time();
$stmt = $apiDb->prepare(
    "SELECT account_id FROM ticket_sessions WHERE session_key = ? AND expires_at > ? LIMIT 1"
);
$stmt->execute([$sessionKey, $now]);
$session = $stmt->fetch();
if (!$session) {
    sendError('Session expired or invalid. Please login again.');
}
$accountId = (int)$session['account_id'];

// ------- fetch games for this account (GLOBAL_DB) -------
$stmt = $globalDb->prepare(
    "SELECT g.slug, g.name, g.engine_type, g.game_host, g.game_port,
            g.platform_windows, g.platform_linux, g.platform_android, g.status
     FROM account_games ag
     JOIN games g ON g.id = ag.game_id
     WHERE ag.account_id = ? AND g.status IN ('active', 'maintenance')
     ORDER BY g.sort_order"
);
$stmt->execute([$accountId]);

$games = [];
while ($row = $stmt->fetch()) {
    $platforms = [];
    if ((int)$row['platform_windows']) $platforms[] = 'windows';
    if ((int)$row['platform_linux'])   $platforms[] = 'linux';
    if ((int)$row['platform_android']) $platforms[] = 'android';

    $games[] = [
        'slug'       => $row['slug'],
        'name'       => $row['name'],
        'engineType' => $row['engine_type'],
        'gameHost'   => $row['game_host'],
        'gamePort'   => (int)$row['game_port'],
        'platforms'  => $platforms,
        'status'     => $row['status'],
    ];
}

json_out(['games' => $games]);
