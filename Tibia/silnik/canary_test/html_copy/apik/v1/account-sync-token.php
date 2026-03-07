<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * account-sync-token.php — K12
 * Issue one-time sync token for cross-channel account sync (WWW <-> launcher).
 *
 * Request JSON:
 * {
 *   "type": "account_sync_token",
 *   "sessionKey": "<ticket_session_key>",
 *   "source": "launcher|www",
 *   "target": "www|launcher"
 * }
 */

require_once __DIR__ . '/common.php';
$requestStartedAt = microtime(true);

function syncTokenError(string $code, string $message, int $httpCode = 400): void
{
    sendLauncherError($code, $message, $httpCode);
}

function buildPublicBaseUrl(array $ENV): string
{
    $raw = trim((string)($ENV['URL'] ?? ''));
    if ($raw !== '') {
        return rtrim($raw, '/');
    }

    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? '127.0.0.1';
    return $scheme . '://' . $host;
}

$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    syncTokenError('invalid_json', 'Invalid JSON request.');
}

$action = isset($req['type']) ? trim((string)$req['type']) : 'account_sync_token';
if (!in_array($action, ['account_sync_token', 'sync_token_issue'], true)) {
    syncTokenError('invalid_action', 'Expected type=account_sync_token.');
}

$sessionKey = trim((string)($req['sessionKey'] ?? ''));
$source = strtolower(trim((string)($req['source'] ?? 'launcher')));
$target = strtolower(trim((string)($req['target'] ?? 'www')));
if ($sessionKey === '') {
    syncTokenError('missing_session_key', 'Missing sessionKey.');
}

$allowedChannels = ['launcher', 'www'];
if (!in_array($source, $allowedChannels, true)) {
    syncTokenError('invalid_source', 'Invalid source channel.');
}
if (!in_array($target, $allowedChannels, true)) {
    syncTokenError('invalid_target', 'Invalid target channel.');
}
if ($source === $target) {
    syncTokenError('invalid_target', 'Source and target must differ.');
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);
$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);

$syncTtl = isset($ENV['ACCOUNT_SYNC_TOKEN_TTL']) ? (int)$ENV['ACCOUNT_SYNC_TOKEN_TTL'] : 120;
if ($syncTtl < 30) {
    $syncTtl = 30;
}
if ($syncTtl > 600) {
    $syncTtl = 600;
}

// F1: multi-DB — ticket_sessions + account_sync_tokens are in API_DB
$apiDb = getApiDb($ENV);

$now = time();
$stmt = $apiDb->prepare(
    "SELECT account_id, game_mode, expires_at FROM ticket_sessions WHERE session_key = ? LIMIT 1"
);
$stmt->execute([$sessionKey]);
$session = $stmt->fetch();
if (!$session) {
    syncTokenError('invalid_session', 'Invalid or expired session.', 401);
}
if ((int)$session['expires_at'] < $now) {
    syncTokenError('expired_session', 'Session expired.', 401);
}

$accountId = (int)$session['account_id'];
$expiresAt = $now + $syncTtl;
$metaJson = json_encode([
    'ipHash' => $ipHash,
    'sessionGameMode' => (string)$session['game_mode'],
    'issuedAt' => $now,
], JSON_UNESCAPED_SLASHES);

$inserted = false;
$syncToken = '';
for ($attempt = 0; $attempt < 3; $attempt++) {
    $syncToken = bin2hex(random_bytes(32));
    try {
        $stmt = $apiDb->prepare(
            "INSERT INTO account_sync_tokens (token, account_id, source, target, expires_at, metadata_json)
             VALUES (?, ?, ?, ?, ?, ?)"
        );
        $ok = $stmt->execute([$syncToken, $accountId, $source, $target, $expiresAt, $metaJson]);
        if ($ok) {
            $inserted = true;
            break;
        }
    } catch (\PDOException $e) {
        if ($e->getCode() === '23000') {
            continue; // duplicate key — retry
        }
        if (str_contains($e->getMessage(), '1146')) {
            syncTokenError('sync_schema_not_ready', 'Sync schema is not deployed yet.', 503);
        }
        syncTokenError('db_insert_failed', 'Cannot issue sync token.', 500);
    }
}

if (!$inserted) {
    syncTokenError('token_generation_failed', 'Cannot issue unique sync token.', 500);
}

// Deterministyczne best-effort cleanup
$cleanup = $apiDb->prepare(
    "DELETE FROM account_sync_tokens WHERE expires_at < ? OR used_at IS NOT NULL LIMIT 500"
);
$cleanup->execute([$now]);

logTicketEvent('account.sync_token.issued', [
    'endpoint' => 'account-sync-token.php',
    'ipHash' => $ipHash,
    'accountId' => $accountId,
    'source' => $source,
    'target' => $target,
    'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
], $ENV);

$consumeUrl = null;
if ($target === 'www') {
    $consumeUrl = buildPublicBaseUrl($ENV) . '/account/sync-login?syncToken=' . urlencode($syncToken);
}

json_out([
    'ok' => true,
    'syncToken' => $syncToken,
    'source' => $source,
    'target' => $target,
    'expiresAt' => $expiresAt,
    'consumeUrl' => $consumeUrl,
]);
