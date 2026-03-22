<?php
declare(strict_types=1);

/**
 * account-sync-www-login.php — K13
 * Consumes launcher->WWW sync token and opens website session.
 *
 * Browser flow:
 *   GET /apik/v1/account-sync-www-login.php?syncToken=...&redirect=/account/createcharacter
 *
 * API flow:
 *   GET/POST with format=json (or Accept: application/json)
 */

require_once __DIR__ . '/common.php';
$requestStartedAt = microtime(true);

function wantsJsonResponse(): bool
{
    if (isset($_GET['format']) && strtolower((string)$_GET['format']) === 'json') {
        return true;
    }
    $accept = strtolower((string)($_SERVER['HTTP_ACCEPT'] ?? ''));
    return str_contains($accept, 'application/json');
}

function syncWwwLoginError(string $code, string $message, int $httpCode = 400): void
{
    sendLauncherError($code, $message, $httpCode);
}

function extractLauncherHints(string $redirectPath): array
{
    $query = parse_url($redirectPath, PHP_URL_QUERY);
    if (!is_string($query) || $query === '') {
        return ['source' => '', 'mode' => ''];
    }

    parse_str($query, $params);
    $source = isset($params['source']) && strtolower((string)$params['source']) === 'launcher' ? 'launcher' : '';
    $modeRaw = strtolower((string)($params['mode'] ?? ''));
    $mode = in_array($modeRaw, ['classic74', 'modern'], true) ? $modeRaw : '';
    return ['source' => $source, 'mode' => $mode];
}

function buildLoginFallbackUrl(string $redirectPath, string $syncError): string
{
    $hints = extractLauncherHints($redirectPath);
    $params = [
        'redirect' => $redirectPath,
        'sync_error' => $syncError,
    ];
    if ($hints['source'] !== '') {
        $params['source'] = $hints['source'];
    }
    if ($hints['mode'] !== '') {
        $params['mode'] = $hints['mode'];
    }
    return '/account/login?' . http_build_query($params);
}

function syncWwwLoginFail(
    string $code,
    string $message,
    int $httpCode,
    bool $jsonResponse,
    string $redirectPath
): void {
    if ($jsonResponse) {
        syncWwwLoginError($code, $message, $httpCode);
    }
    header('Location: ' . buildLoginFallbackUrl($redirectPath, $code), true, 302);
    exit;
}

function normalizeRedirectPath(string $redirect): string
{
    $redirect = trim($redirect);
    if ($redirect === '') {
        return '/account/createcharacter';
    }
    if (!str_starts_with($redirect, '/')) {
        return '/account/createcharacter';
    }
    if (str_starts_with($redirect, '//')) {
        return '/account/createcharacter';
    }
    return $redirect;
}

function startWebsiteSession(string $siteName): void
{
    if (session_status() === PHP_SESSION_ACTIVE) {
        return;
    }
    // MyAAC uses default session name (PHPSESSID) + custom save path
    session_save_path(dirname(__DIR__, 2) . '/system/php_sessions');
    session_start();
}

$redirectPath = normalizeRedirectPath((string)($_GET['redirect'] ?? $_POST['redirect'] ?? '/account/createcharacter?source=launcher'));
$jsonResponse = wantsJsonResponse();

$syncToken = trim((string)($_GET['syncToken'] ?? $_POST['syncToken'] ?? ''));
$verifier = trim((string)($_POST['verifier'] ?? ''));
if ($syncToken === '' || $verifier === '') {
    $raw = file_get_contents('php://input') ?: '';
    $req = json_decode($raw, true);
    if (is_array($req)) {
        if ($syncToken === '') {
            $syncToken = trim((string)($req['syncToken'] ?? ''));
        }
        if ($verifier === '') {
            $verifier = trim((string)($req['verifier'] ?? ''));
        }
    }
}
if ($syncToken === '') {
    syncWwwLoginFail('missing_sync_token', 'Missing syncToken.', 400, $jsonResponse, $redirectPath);
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);
$apiDb = getApiDb($ENV);
$globalDb = getGlobalDb($ENV);
$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);

$now = time();
$tokenRow = null;
$account = null;

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
    $tokenRow = $stmt->fetch();

    if (!$tokenRow) {
        throw new RuntimeException('invalid_sync_token');
    }

    if (!empty($tokenRow['used_at'])) {
        throw new RuntimeException('sync_token_already_used');
    }
    if ((int)$tokenRow['expires_at'] < $now) {
        $del = $apiDb->prepare("DELETE FROM account_sync_tokens WHERE token = ?");
        $del->execute([$syncToken]);
        throw new RuntimeException('sync_token_expired');
    }
    if ((string)$tokenRow['target'] !== 'www') {
        throw new RuntimeException('target_mismatch');
    }
    if ((string)$tokenRow['source'] !== 'launcher') {
        throw new RuntimeException('source_mismatch');
    }

    // SEC-P2-001: Validate PKCE-like verifier (fail-closed: if hash stored, verifier required)
    $storedHash = (string)($tokenRow['verifier_hash'] ?? '');
    if ($storedHash !== '') {
        if ($verifier === '' || !hash_equals($storedHash, hash('sha256', $verifier))) {
            throw new RuntimeException('verifier_mismatch');
        }
    }

    $mark = $apiDb->prepare("UPDATE account_sync_tokens SET used_at = NOW() WHERE token = ?");
    $mark->execute([$syncToken]);

    $apiDb->commit();
} catch (Throwable $e) {
    $apiDb->rollBack();
    $code = $e->getMessage();
    if ($code === 'invalid_sync_token') {
        syncWwwLoginFail('invalid_sync_token', 'Invalid sync token.', 401, $jsonResponse, $redirectPath);
    }
    if ($code === 'sync_token_already_used') {
        syncWwwLoginFail('sync_token_already_used', 'Sync token already used.', 409, $jsonResponse, $redirectPath);
    }
    if ($code === 'sync_token_expired') {
        syncWwwLoginFail('sync_token_expired', 'Sync token expired.', 401, $jsonResponse, $redirectPath);
    }
    if ($code === 'target_mismatch') {
        syncWwwLoginFail('target_mismatch', 'Sync token target mismatch.', 409, $jsonResponse, $redirectPath);
    }
    if ($code === 'source_mismatch') {
        syncWwwLoginFail('source_mismatch', 'Only launcher->www token is accepted here.', 409, $jsonResponse, $redirectPath);
    }
    if ($code === 'verifier_mismatch') {
        syncWwwLoginFail('verifier_mismatch', 'Sync token verifier mismatch.', 403, $jsonResponse, $redirectPath);
    }
    syncWwwLoginFail('sync_consume_failed', 'Cannot consume sync token.', 500, $jsonResponse, $redirectPath);
}

$accountId = (int)$tokenRow['account_id'];
$accStmt = $globalDb->prepare("SELECT id, name, email, password FROM accounts WHERE id = ? LIMIT 1");
$accStmt->execute([$accountId]);
$account = $accStmt->fetch();
if (!$account) {
    syncWwwLoginFail('account_not_found', 'Account not found.', 404, $jsonResponse, $redirectPath);
}

if (!is_array($account)) {
    syncWwwLoginFail('sync_consume_failed', 'Cannot consume sync token.', 500, $jsonResponse, $redirectPath);
}

$siteName = trim((string)($ENV['SITE_NAME'] ?? 'CanaryAAC'));
startWebsiteSession($siteName);
session_regenerate_id(true);

// MyAAC session format: prefixed keys (default prefix: 'myaac_')
// login.php verifies: $account->getPassword() == getSession('password')
$sessionPrefix = 'myaac_';
$_SESSION[$sessionPrefix . 'account'] = (int)$account['id'];
$_SESSION[$sessionPrefix . 'password'] = (string)$account['password'];
$_SESSION[$sessionPrefix . 'remember_me'] = true;
$_SESSION[$sessionPrefix . 'last_visit'] = time();
session_write_close();

logTicketEvent('account.sync_www.login', [
    'endpoint' => 'account-sync-www-login.php',
    'ipHash' => $ipHash,
    'accountId' => (int)$account['id'],
    'source' => is_array($tokenRow) ? (string)$tokenRow['source'] : 'launcher',
    'target' => 'www',
    'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
], $ENV);

if ($jsonResponse) {
    json_out([
        'ok' => true,
        'loggedIn' => true,
        'account' => [
            'id' => (int)$account['id'],
            'name' => (string)$account['name'],
            'email' => (string)$account['email'],
        ],
        'redirectTo' => $redirectPath,
    ]);
}

header('Location: ' . $redirectPath, true, 302);
exit;
