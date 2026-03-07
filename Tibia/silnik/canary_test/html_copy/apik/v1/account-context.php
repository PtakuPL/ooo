<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * account-context.php — K6
 * Zwraca kontekst konta dla strony/launchera:
 * - światy,
 * - postacie pogrupowane per serwer,
 * - dane sesji.
 */

require_once __DIR__ . '/common.php';

function getWorldsContext(array $ENV): array
{
    $worldIp = $ENV['WORLD_IP'] ?? '127.0.0.1';
    $worldPort = isset($ENV['WORLD_PORT']) ? (int)$ENV['WORLD_PORT'] : 7172;
    $classic74Ip = $ENV['WORLD_CLASSIC74_IP'] ?? $worldIp;
    $classic74Port = isset($ENV['WORLD_CLASSIC74_PORT']) ? (int)$ENV['WORLD_CLASSIC74_PORT'] : $worldPort;
    $modernIp = $ENV['WORLD_MODERN_IP'] ?? $worldIp;
    $modernPort = isset($ENV['WORLD_MODERN_PORT']) ? (int)$ENV['WORLD_MODERN_PORT'] : 7174;

    return [
        [
            'id' => 0,
            'gameMode' => 'classic74',
            'name' => 'Classic 7.4',
            'host' => $classic74Ip,
            'port' => $classic74Port,
        ],
        [
            'id' => 1,
            'gameMode' => 'modern',
            'name' => 'Modern',
            'host' => $modernIp,
            'port' => $modernPort,
        ],
    ];
}

function worldIdToGameMode(int $worldId): string
{
    return $worldId === 1 ? 'modern' : 'classic74';
}

function normalizeSessionGameMode(string $mode): string
{
    $mode = strtolower(trim($mode));
    if (!in_array($mode, ['all', 'classic74', 'modern'], true)) {
        return 'all';
    }
    return $mode;
}

$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    sendLauncherError('invalid_json', 'Invalid JSON request.');
}

$action = isset($req['type']) ? trim((string)$req['type']) : 'account_context';
if ($action !== 'account_context') {
    sendLauncherError('invalid_action', 'Expected type=account_context.');
}

$sessionKey = trim((string)($req['sessionKey'] ?? ''));
if ($sessionKey === '') {
    sendLauncherError('missing_session_key', 'Missing sessionKey.');
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

// F1: multi-DB connections
$apiDb    = getApiDb($ENV);     // ticket_sessions
$globalDb = getGlobalDb($ENV);  // accounts

// Session validation (API_DB)
$now = time();
$stmt = $apiDb->prepare(
    "SELECT session_key, account_id, game_mode, expires_at
     FROM ticket_sessions
     WHERE session_key = ? LIMIT 1"
);
$stmt->execute([$sessionKey]);
$session = $stmt->fetch();
if (!$session) {
    sendLauncherError('invalid_session', 'Invalid or expired session.', 401);
}
if ((int)$session['expires_at'] < $now) {
    sendLauncherError('expired_session', 'Session expired.', 401);
}

// Account lookup (GLOBAL_DB)
$accountId = (int)$session['account_id'];
$stmt = $globalDb->prepare("SELECT id, name, email FROM accounts WHERE id = ? LIMIT 1");
$stmt->execute([$accountId]);
$account = $stmt->fetch();
if (!$account) {
    sendLauncherError('account_not_found', 'Account not found.', 404);
}

// Characters from both engine DBs
$charactersByWorld = [
    'classic74' => [],
    'modern' => [],
    'unknown' => [],
];

$engines = getBothEnginePdos($ENV);
foreach ($engines as $gm => $engineDb) {
    $worldIdVal = ($gm === 'modern') ? 1 : 0;
    try {
        $stmt = $engineDb->prepare(
            "SELECT id, name, level, vocation, lastlogin FROM players WHERE account_id = ? AND deletion = 0 ORDER BY name"
        );
        $stmt->execute([$accountId]);
        while ($row = $stmt->fetch()) {
            $charactersByWorld[$gm][] = [
                'id' => (int)$row['id'],
                'name' => (string)$row['name'],
                'level' => (int)$row['level'],
                'vocation' => (int)$row['vocation'],
                'lastlogin' => (int)$row['lastlogin'],
                'worldId' => $worldIdVal,
            ];
        }
    } catch (\PDOException $e) {
        // Engine DB unavailable — skip silently
    }
}

$counts = [
    'all' => count($charactersByWorld['classic74']) + count($charactersByWorld['modern']) + count($charactersByWorld['unknown']),
    'classic74' => count($charactersByWorld['classic74']),
    'modern' => count($charactersByWorld['modern']),
    'unknown' => count($charactersByWorld['unknown']),
];

$sessionGameMode = normalizeSessionGameMode((string)$session['game_mode']);

json_out([
    'session' => [
        'sessionKey' => $session['session_key'],
        'accountId' => $accountId,
        'gameMode' => $sessionGameMode,
        'expiresAt' => (int)$session['expires_at'],
    ],
    'account' => [
        'id' => (int)$account['id'],
        'name' => (string)$account['name'],
        'email' => (string)$account['email'],
    ],
    'worlds' => getWorldsContext($ENV),
    'charactersByWorld' => $charactersByWorld,
    'counts' => $counts,
    'activeProfile' => [
        'gameMode' => $sessionGameMode,
        'allowedModes' => ['all', 'classic74', 'modern'],
    ],
    'links' => [
        'profileSwitchEndpoint' => '/apik/v1/account-profile-switch.php',
    ],
]);
