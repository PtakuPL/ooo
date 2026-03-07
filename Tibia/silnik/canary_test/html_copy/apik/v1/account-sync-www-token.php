<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * account-sync-www-token.php — K14
 * Issues WWW->launcher sync token from active website session.
 *
 * Request JSON:
 * {
 *   "type": "account_sync_www_token",
 *   "target": "launcher"
 * }
 */

require_once __DIR__ . '/common.php';
$requestStartedAt = microtime(true);

function syncWwwTokenError(string $code, string $message, int $httpCode = 400): void
{
    sendLauncherError($code, $message, $httpCode);
}

function startWebsiteSessionForSync(string $siteName): void
{
    if (session_status() !== PHP_SESSION_ACTIVE) {
        // MyAAC uses default session name (PHPSESSID) + custom save path
        session_save_path(dirname(__DIR__, 2) . '/system/php_sessions');
        session_start();
    }
}

function buildBaseUrl(array $ENV): string
{
    $raw = trim((string)($ENV['URL'] ?? ''));
    if ($raw !== '') {
        return rtrim($raw, '/');
    }
    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? '127.0.0.1';
    return $scheme . '://' . $host;
}

if (strtoupper((string)($_SERVER['REQUEST_METHOD'] ?? 'GET')) !== 'POST') {
    syncWwwTokenError('method_not_allowed', 'Use POST request.', 405);
}

$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    $req = [];
}

$action = isset($req['type']) ? trim((string)$req['type']) : 'account_sync_www_token';
if (!in_array($action, ['account_sync_www_token', 'sync_token_issue_www'], true)) {
    syncWwwTokenError('invalid_action', 'Expected type=account_sync_www_token.');
}

$target = strtolower(trim((string)($req['target'] ?? 'launcher')));
if ($target !== 'launcher') {
    syncWwwTokenError('invalid_target', 'Only target=launcher is supported for WWW session sync.');
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);
$siteName = trim((string)($ENV['SITE_NAME'] ?? 'CanaryAAC'));
startWebsiteSessionForSync($siteName);

// MyAAC session format: prefixed keys (default prefix: 'myaac_')
$sessionPrefix = 'myaac_';
$accountId = isset($_SESSION[$sessionPrefix . 'account']) ? (int)$_SESSION[$sessionPrefix . 'account'] : 0;
$lastVisit = isset($_SESSION[$sessionPrefix . 'last_visit']) ? (int)$_SESSION[$sessionPrefix . 'last_visit'] : 0;
if ($accountId <= 0) {
    syncWwwTokenError('www_session_not_authenticated', 'WWW session is not authenticated.', 401);
}
if ($lastVisit > 0 && (time() - $lastVisit) > 1800) {
    unset($_SESSION[$sessionPrefix . 'account'], $_SESSION[$sessionPrefix . 'password']);
    syncWwwTokenError('www_session_expired', 'WWW session expired.', 401);
}

// Keep session fresh
$_SESSION[$sessionPrefix . 'last_visit'] = time();
session_write_close();

$globalDb = getGlobalDb($ENV);
$apiDb = getApiDb($ENV);
$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);
$syncTtl = isset($ENV['ACCOUNT_SYNC_TOKEN_TTL']) ? (int)$ENV['ACCOUNT_SYNC_TOKEN_TTL'] : 120;
if ($syncTtl < 30) {
    $syncTtl = 30;
}
if ($syncTtl > 600) {
    $syncTtl = 600;
}

$rateLimitMaxOpen = isset($ENV['ACCOUNT_SYNC_WWW_OPEN_TOKENS_MAX']) ? (int)$ENV['ACCOUNT_SYNC_WWW_OPEN_TOKENS_MAX'] : 3;
if ($rateLimitMaxOpen < 1) {
    $rateLimitMaxOpen = 1;
}
if ($rateLimitMaxOpen > 20) {
    $rateLimitMaxOpen = 20;
}

$existsStmt = $globalDb->prepare("SELECT id FROM accounts WHERE id = ? LIMIT 1");
$existsStmt->execute([$accountId]);
if (!$existsStmt->fetch()) {
    syncWwwTokenError('account_not_found', 'Account not found.', 404);
}

$now = time();
$openStmt = $apiDb->prepare(
    "SELECT COUNT(*) AS cnt
     FROM account_sync_tokens
     WHERE account_id = ?
       AND source = 'www'
       AND target = 'launcher'
       AND used_at IS NULL
       AND expires_at >= ?"
);
$openStmt->execute([$accountId, $now]);
$openRow = $openStmt->fetch();
$openCount = $openRow ? (int)$openRow['cnt'] : 0;
if ($openCount >= $rateLimitMaxOpen) {
    syncWwwTokenError('rate_limited', 'Too many open sync tokens. Try again in a moment.', 429);
}

$expiresAt = $now + $syncTtl;
$metaJson = json_encode([
    'ipHash' => $ipHash,
    'issuedAt' => $now,
    'issuedFrom' => 'www_session',
], JSON_UNESCAPED_SLASHES);

$inserted = false;
$syncToken = '';
for ($attempt = 0; $attempt < 3; $attempt++) {
    $syncToken = bin2hex(random_bytes(32));
    try {
        $insert = $apiDb->prepare(
            "INSERT INTO account_sync_tokens (token, account_id, source, target, expires_at, metadata_json)
             VALUES (?, ?, 'www', 'launcher', ?, ?)"
        );
        $insert->execute([$syncToken, $accountId, $expiresAt, $metaJson]);
        $inserted = true;
        break;
    } catch (PDOException $e) {
        if (str_contains($e->getMessage(), '1062') || str_contains($e->getMessage(), 'Duplicate')) {
            continue;
        }
        syncWwwTokenError('db_insert_failed', 'Cannot issue sync token.', 500);
    }
}

if (!$inserted) {
    syncWwwTokenError('token_generation_failed', 'Cannot issue unique sync token.', 500);
}

if (mt_rand(1, 10) === 1) {
    $cleanup = $apiDb->prepare(
        "DELETE FROM account_sync_tokens WHERE expires_at < ? OR used_at IS NOT NULL"
    );
    $cleanup->execute([$now]);
}

$baseUrl = buildBaseUrl($ENV);
$launcherScheme = trim((string)($ENV['LAUNCHER_SYNC_URI_SCHEME'] ?? 'launcher'));
if ($launcherScheme === '') {
    $launcherScheme = 'launcher';
}

logTicketEvent('account.sync_www_token.issued', [
    'endpoint' => 'account-sync-www-token.php',
    'ipHash' => $ipHash,
    'accountId' => $accountId,
    'source' => 'www',
    'target' => 'launcher',
    'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
], $ENV);

json_out([
    'ok' => true,
    'syncToken' => $syncToken,
    'source' => 'www',
    'target' => 'launcher',
    'expiresAt' => $expiresAt,
    'consumeEndpoint' => $baseUrl . '/apik/v1/account-sync-consume.php',
    'launcherDeepLink' => $launcherScheme . '://account-sync?token=' . urlencode($syncToken),
]);
