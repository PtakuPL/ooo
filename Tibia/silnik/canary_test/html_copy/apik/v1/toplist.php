<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * toplist.php — K7
 * Topka wspólna lub per-serwer.
 * GET /apik/v1/toplist.php?gameMode=all|classic74|modern&limit=50
 */

require_once __DIR__ . '/common.php';

function parseMode(string $mode): string
{
    return in_array($mode, ['all', 'classic74', 'modern'], true) ? $mode : 'all';
}

$mode = parseMode((string)($_GET['gameMode'] ?? $_GET['mode'] ?? 'all'));
$limit = (int)($_GET['limit'] ?? 50);
if ($limit < 1) {
    $limit = 1;
}
if ($limit > 200) {
    $limit = 200;
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

// F1: multi-DB — players+accounts are in engine DBs
$players = [];
$rank = 1;

$sqlTopPlayers = "
    SELECT p.id, p.name, p.level, p.experience, p.vocation, p.lastlogin, a.name AS account_name
    FROM players p
    INNER JOIN accounts a ON a.id = p.account_id
    WHERE p.deletion = 0
    ORDER BY p.level DESC, p.experience DESC, p.name ASC
    LIMIT ?
";

if ($mode === 'all') {
    // Query both engine DBs and merge
    $engines = getBothEnginePdos($ENV);
    $allRows = [];
    foreach ($engines as $gm => $engineDb) {
        $worldIdVal = ($gm === 'modern') ? 1 : 0;
        try {
            $stmt = $engineDb->prepare($sqlTopPlayers);
            $stmt->execute([$limit]);
            while ($row = $stmt->fetch()) {
                $row['_worldId'] = $worldIdVal;
                $row['_gameMode'] = $gm;
                $allRows[] = $row;
            }
        } catch (\PDOException $e) {
            // Engine DB unavailable — skip
        }
    }
    // Sort merged results
    usort($allRows, function($a, $b) {
        if ($a['level'] !== $b['level']) return $b['level'] <=> $a['level'];
        if ($a['experience'] !== $b['experience']) return $b['experience'] <=> $a['experience'];
        return strcmp($a['name'], $b['name']);
    });
    $allRows = array_slice($allRows, 0, $limit);
    foreach ($allRows as $row) {
        $players[] = [
            'rank' => $rank++,
            'id' => (int)$row['id'],
            'name' => (string)$row['name'],
            'accountName' => (string)$row['account_name'],
            'level' => (int)$row['level'],
            'experience' => (int)$row['experience'],
            'vocation' => (int)$row['vocation'],
            'worldId' => $row['_worldId'],
            'gameMode' => $row['_gameMode'],
            'lastlogin' => (int)$row['lastlogin'],
        ];
    }
} else {
    // Query specific engine DB
    $engineDb = getEnginePdo($ENV, $mode);
    $worldIdVal = ($mode === 'modern') ? 1 : 0;
    $stmt = $engineDb->prepare($sqlTopPlayers);
    $stmt->execute([$limit]);
    while ($row = $stmt->fetch()) {
        $players[] = [
            'rank' => $rank++,
            'id' => (int)$row['id'],
            'name' => (string)$row['name'],
            'accountName' => (string)$row['account_name'],
            'level' => (int)$row['level'],
            'experience' => (int)$row['experience'],
            'vocation' => (int)$row['vocation'],
            'worldId' => $worldIdVal,
            'gameMode' => $mode,
            'lastlogin' => (int)$row['lastlogin'],
        ];
    }
}

json_out([
    'mode' => $mode,
    'limit' => $limit,
    'count' => count($players),
    'players' => $players,
]);
