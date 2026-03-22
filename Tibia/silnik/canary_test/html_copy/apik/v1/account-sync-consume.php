<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * account-sync-consume.php — K12
 * Consume one-time sync token and issue target-channel session.
 *
 * Request JSON:
 * {
 *   "type": "account_sync_consume",
 *   "syncToken": "<one_time_token>",
 *   "target": "www|launcher"
 * }
 */

require_once __DIR__ . '/common.php';
$requestStartedAt = microtime(true);

function syncConsumeError(string $code, string $message, int $httpCode = 400): void
{
    sendLauncherError($code, $message, $httpCode);
}

function worldsContext(array $ENV): array
{
    $worldIp = $ENV['WORLD_IP'] ?? '127.0.0.1';
    $worldPort = isset($ENV['WORLD_PORT']) ? (int)$ENV['WORLD_PORT'] : 7172;
    $classic74Ip = $ENV['WORLD_CLASSIC74_IP'] ?? $worldIp;
    $classic74Port = isset($ENV['WORLD_CLASSIC74_PORT']) ? (int)$ENV['WORLD_CLASSIC74_PORT'] : $worldPort;
    $modernIp = $ENV['WORLD_MODERN_IP'] ?? $worldIp;
    $modernPort = isset($ENV['WORLD_MODERN_PORT']) ? (int)$ENV['WORLD_MODERN_PORT'] : 7174;

    return [
        ['id' => 0, 'gameMode' => 'classic74', 'name' => 'Classic 7.4', 'host' => $classic74Ip, 'port' => $classic74Port],
        ['id' => 1, 'gameMode' => 'modern', 'name' => 'Modern', 'host' => $modernIp, 'port' => $modernPort],
    ];
}

function gameModeFromWorldId(int $worldId): string
{
    return $worldId === 1 ? 'modern' : 'classic74';
}

function fetchCharactersByWorld(array $ENV, int $accountId): array
{
    $charactersByWorld = ['classic74' => [], 'modern' => [], 'unknown' => []];
    $engines = getBothEnginePdos($ENV);

    foreach ($engines as $gameMode => $pdo) {
        $stmt = $pdo->prepare(
            "SELECT id, name, level, vocation, lastlogin
             FROM players
             WHERE account_id = ? AND deletion = 0
             ORDER BY name"
        );
        $stmt->execute([$accountId]);
        while ($row = $stmt->fetch()) {
            $character = [
                'id' => (int)$row['id'],
                'name' => (string)$row['name'],
                'level' => (int)$row['level'],
                'vocation' => (int)$row['vocation'],
                'lastlogin' => (int)$row['lastlogin'],
                'worldId' => $gameMode === 'modern' ? 1 : 0,
            ];
            $charactersByWorld[$gameMode][] = $character;
        }
    }

    return $charactersByWorld;
}

function fetchIdentityLinks(PDO $globalDb, int $accountId): array
{
    try {
        $stmt = $globalDb->prepare(
            "SELECT provider, provider_user_id, provider_email, provider_display_name, is_primary, linked_at, last_login_at
             FROM account_identity_links
             WHERE account_id = ?
             ORDER BY linked_at ASC"
        );
        $stmt->execute([$accountId]);
    } catch (PDOException $e) {
        // Table may not exist before migration 004 rollout.
        return [];
    }
    $links = [];
    while ($row = $stmt->fetch()) {
        $links[] = [
            'provider' => (string)$row['provider'],
            'providerUserId' => (string)$row['provider_user_id'],
            'providerEmail' => (string)($row['provider_email'] ?? ''),
            'providerDisplayName' => (string)($row['provider_display_name'] ?? ''),
            'isPrimary' => ((int)$row['is_primary'] === 1),
            'linkedAt' => (string)$row['linked_at'],
            'lastLoginAt' => isset($row['last_login_at']) ? (string)$row['last_login_at'] : null,
        ];
    }
    return $links;
}

$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    syncConsumeError('invalid_json', 'Invalid JSON request.');
}

$action = isset($req['type']) ? trim((string)$req['type']) : 'account_sync_consume';
if (!in_array($action, ['account_sync_consume', 'sync_token_consume'], true)) {
    syncConsumeError('invalid_action', 'Expected type=account_sync_consume.');
}

$syncToken = trim((string)($req['syncToken'] ?? ''));
$verifier = trim((string)($req['verifier'] ?? ''));
$requestedTarget = strtolower(trim((string)($req['target'] ?? '')));
$requestedSource = strtolower(trim((string)($req['source'] ?? '')));
if ($syncToken === '') {
    syncConsumeError('missing_sync_token', 'Missing syncToken.');
}
if ($requestedTarget !== '' && !in_array($requestedTarget, ['launcher', 'www'], true)) {
    syncConsumeError('invalid_target', 'Invalid target channel.');
}
if ($requestedSource !== '' && !in_array($requestedSource, ['launcher', 'www'], true)) {
    syncConsumeError('invalid_source', 'Invalid source channel.');
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);
$apiDb = getApiDb($ENV);
$globalDb = getGlobalDb($ENV);
$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);

$sessionTtl = isset($ENV['SESSION_TTL']) ? (int)$ENV['SESSION_TTL'] : 1800;
if ($sessionTtl < 60) {
    $sessionTtl = 60;
}

$sessionGameMode = 'all';

$now = time();
$syncRow = null;
$newSessionKey = '';
$newSessionExpiresAt = 0;

$apiDb->beginTransaction();
try {
    $stmt = $apiDb->prepare(
        "SELECT token, account_id, source, target, expires_at, used_at, verifier_hash
         FROM account_sync_tokens
         WHERE token = ?
         LIMIT 1
         FOR UPDATE"
    );
    $stmt->execute([$syncToken]);
    $syncRow = $stmt->fetch();

    if (!$syncRow) {
        throw new RuntimeException('invalid_sync_token');
    }

    if (!empty($syncRow['used_at'])) {
        throw new RuntimeException('sync_token_already_used');
    }
    if ((int)$syncRow['expires_at'] < $now) {
        $del = $apiDb->prepare("DELETE FROM account_sync_tokens WHERE token = ?");
        $del->execute([$syncToken]);
        throw new RuntimeException('sync_token_expired');
    }

    $target = (string)$syncRow['target'];
    if ($requestedTarget !== '' && $requestedTarget !== $target) {
        throw new RuntimeException('target_mismatch');
    }

    $source = (string)$syncRow['source'];
    if ($requestedSource !== '' && $requestedSource !== $source) {
        throw new RuntimeException('source_mismatch');
    }

    // SEC-P2-001: Validate PKCE-like verifier (fail-closed: if hash stored, verifier required)
    $storedHash = (string)($syncRow['verifier_hash'] ?? '');
    if ($storedHash !== '') {
        if ($verifier === '' || !hash_equals($storedHash, hash('sha256', $verifier))) {
            throw new RuntimeException('verifier_mismatch');
        }
    }

    $mark = $apiDb->prepare("UPDATE account_sync_tokens SET used_at = NOW() WHERE token = ?");
    $mark->execute([$syncToken]);

    $newSessionKey = bin2hex(random_bytes(32));
    $newSessionExpiresAt = $now + $sessionTtl;
    $accountId = (int)$syncRow['account_id'];
    $insertSession = $apiDb->prepare(
        "INSERT INTO ticket_sessions (session_key, account_id, game_mode, expires_at)
         VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE account_id = VALUES(account_id), game_mode = VALUES(game_mode), expires_at = VALUES(expires_at)"
    );
    $insertSession->execute([$newSessionKey, $accountId, $sessionGameMode, $newSessionExpiresAt]);

    $apiDb->commit();
} catch (Throwable $e) {
    $apiDb->rollBack();
    $code = $e->getMessage();
    if ($code === 'invalid_sync_token') {
        syncConsumeError('invalid_sync_token', 'Invalid sync token.', 401);
    }
    if ($code === 'sync_token_already_used') {
        syncConsumeError('sync_token_already_used', 'Sync token already used.', 409);
    }
    if ($code === 'sync_token_expired') {
        syncConsumeError('sync_token_expired', 'Sync token expired.', 401);
    }
    if ($code === 'target_mismatch') {
        syncConsumeError('target_mismatch', 'Sync token target mismatch.', 409);
    }
    if ($code === 'source_mismatch') {
        syncConsumeError('source_mismatch', 'Sync token source mismatch.', 409);
    }
    if ($code === 'verifier_mismatch') {
        syncConsumeError('verifier_mismatch', 'Sync token verifier mismatch.', 403);
    }
    syncConsumeError('sync_consume_failed', 'Cannot consume sync token.', 500);
}

if (!is_array($syncRow)) {
    syncConsumeError('sync_consume_failed', 'Cannot consume sync token.', 500);
}

$accountId = (int)$syncRow['account_id'];
$stmt = $globalDb->prepare("SELECT id, name, email FROM accounts WHERE id = ? LIMIT 1");
$stmt->execute([$accountId]);
$account = $stmt->fetch();
if (!$account) {
    syncConsumeError('account_not_found', 'Account not found.', 404);
}

$charactersByWorld = fetchCharactersByWorld($ENV, $accountId);
$identities = fetchIdentityLinks($globalDb, $accountId);
$counts = [
    'all' => count($charactersByWorld['classic74']) + count($charactersByWorld['modern']) + count($charactersByWorld['unknown']),
    'classic74' => count($charactersByWorld['classic74']),
    'modern' => count($charactersByWorld['modern']),
    'unknown' => count($charactersByWorld['unknown']),
];

logTicketEvent('account.sync_token.consumed', [
    'endpoint' => 'account-sync-consume.php',
    'ipHash' => $ipHash,
    'accountId' => $accountId,
    'source' => (string)$syncRow['source'],
    'target' => (string)$syncRow['target'],
    'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
], $ENV);

json_out([
    'ok' => true,
    'sync' => [
        'source' => (string)$syncRow['source'],
        'target' => (string)$syncRow['target'],
        'consumed' => true,
    ],
    'session' => [
        'sessionKey' => $newSessionKey,
        'accountId' => $accountId,
        'gameMode' => $sessionGameMode,
        'expiresAt' => $newSessionExpiresAt,
    ],
    'account' => [
        'id' => (int)$account['id'],
        'name' => (string)$account['name'],
        'email' => (string)$account['email'],
    ],
    'worlds' => worldsContext($ENV),
    'charactersByWorld' => $charactersByWorld,
    'counts' => $counts,
    'identities' => $identities,
    'activeProfile' => [
        'gameMode' => $sessionGameMode,
        'allowedModes' => ['all', 'classic74', 'modern'],
    ],
    'links' => [
        'profileSwitchEndpoint' => '/apik/v1/account-profile-switch.php',
    ],
]);
