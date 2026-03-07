<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * oauth-callback.php — K15/K16/K17
 *
 * Handles OAuth callback for launcher social login/link flow.
 *
 * Request (GET/POST/JSON):
 *   provider=google|facebook|steam
 *   state=<oauth_state>
 *   code=<authorization_code>
 *
 * Result:
 *   - resolves/creates local account
 *   - links social identity in account_identity_links
 *   - issues launcher session (ticket_sessions)
 */

require_once __DIR__ . '/common.php';
$requestStartedAt = microtime(true);

function oauthCallbackError(string $code, string $message, int $httpCode = 400): void
{
    sendLauncherError($code, $message, $httpCode);
}

function getOAuthCallbackInput(): array
{
    $input = $_GET;
    if (strtoupper((string)($_SERVER['REQUEST_METHOD'] ?? 'GET')) === 'POST') {
        $input = array_merge($input, $_POST);
        $raw = file_get_contents('php://input') ?: '';
        $json = json_decode($raw, true);
        if (is_array($json)) {
            $input = array_merge($input, $json);
        }
    }
    return is_array($input) ? $input : [];
}

function wantsJsonResponse(): bool
{
    if (isset($_GET['format']) && strtolower((string)$_GET['format']) === 'json') {
        return true;
    }
    $accept = strtolower((string)($_SERVER['HTTP_ACCEPT'] ?? ''));
    return str_contains($accept, 'application/json');
}

function parseBoolEnv(array $env, string $key, bool $default): bool
{
    if (!array_key_exists($key, $env)) {
        return $default;
    }
    $raw = strtolower(trim((string)$env[$key]));
    if ($raw === '') {
        return $default;
    }
    return in_array($raw, ['1', 'true', 'yes', 'on'], true);
}

function isValidPkceCodeVerifier(string $value): bool
{
    $len = strlen($value);
    if ($len < 43 || $len > 128) {
        return false;
    }
    return preg_match('/^[A-Za-z0-9\\-._~]+$/', $value) === 1;
}

function readBoundedIntEnv(array $env, string $key, int $default, int $min, int $max): int
{
    $raw = isset($env[$key]) ? (int)$env[$key] : $default;
    if ($raw < $min) {
        return $min;
    }
    if ($raw > $max) {
        return $max;
    }
    return $raw;
}

/**
 * @return array{allowed:bool,retryAfter:int,error:string}
 */
function applyOAuthRateLimitBucket(
    PDO $apiDb,
    string $bucket,
    string $keyHash,
    int $maxHits,
    int $windowSeconds,
    array $metadata = []
): array {
    if ($maxHits <= 0 || $windowSeconds <= 0) {
        return ['allowed' => true, 'retryAfter' => 0, 'error' => ''];
    }

    $now = time();
    try {
        $countStmt = $apiDb->prepare(
            "SELECT COUNT(*) AS cnt, MIN(expires_at) AS min_expires_at
             FROM oauth_rate_limits
             WHERE bucket = ? AND key_hash = ? AND expires_at >= ?"
        );
        $countStmt->execute([$bucket, $keyHash, $now]);
        $countRow = $countStmt->fetch();
    } catch (PDOException $e) {
        if (str_contains($e->getMessage(), '1146')) {
            return ['allowed' => false, 'retryAfter' => 0, 'error' => 'schema_not_ready'];
        }
        return ['allowed' => false, 'retryAfter' => 0, 'error' => 'db_error'];
    }

    $count = $countRow ? (int)($countRow['cnt'] ?? 0) : 0;
    $minExpiresAt = $countRow ? (int)($countRow['min_expires_at'] ?? 0) : 0;

    if ($count >= $maxHits) {
        $retryAfter = $minExpiresAt > $now ? ($minExpiresAt - $now) : $windowSeconds;
        if ($retryAfter < 1) {
            $retryAfter = 1;
        }
        return ['allowed' => false, 'retryAfter' => $retryAfter, 'error' => 'rate_limited'];
    }

    $expiresAt = $now + $windowSeconds;
    $metaJson = json_encode($metadata, JSON_UNESCAPED_SLASHES);
    if (!is_string($metaJson)) {
        $metaJson = '{}';
    }
    try {
        $insertStmt = $apiDb->prepare(
            "INSERT INTO oauth_rate_limits (bucket, key_hash, expires_at, metadata_json)
             VALUES (?, ?, ?, ?)"
        );
        $insertStmt->execute([$bucket, $keyHash, $expiresAt, $metaJson]);
    } catch (PDOException $e) {
        if (str_contains($e->getMessage(), '1146')) {
            return ['allowed' => false, 'retryAfter' => 0, 'error' => 'schema_not_ready'];
        }
        return ['allowed' => false, 'retryAfter' => 0, 'error' => 'db_error'];
    }

    if (mt_rand(1, 10) === 1) {
        $cleanupStmt = $apiDb->prepare("DELETE FROM oauth_rate_limits WHERE expires_at < ?");
        $cleanupStmt->execute([$now]);
    }

    return ['allowed' => true, 'retryAfter' => 0, 'error' => ''];
}

function getOAuthProviderConfig(string $provider, array $env): array
{
    if ($provider === 'google') {
        $clientId = trim((string)($env['GOOGLE_OAUTH_CLIENT_ID'] ?? ''));
        $clientSecret = trim((string)($env['GOOGLE_OAUTH_CLIENT_SECRET'] ?? ''));
        $redirectUri = trim((string)($env['GOOGLE_OAUTH_REDIRECT_URI'] ?? ''));
        if ($clientId === '' || $clientSecret === '' || $redirectUri === '') {
            return [];
        }
        $scope = trim((string)($env['GOOGLE_OAUTH_SCOPE'] ?? 'openid email profile'));
        if ($scope === '') {
            $scope = 'openid email profile';
        }
        return [
            'provider' => 'google',
            'flow' => 'oauth2',
            'clientId' => $clientId,
            'clientSecret' => $clientSecret,
            'redirectUri' => $redirectUri,
            'scope' => $scope,
            'tokenMethod' => 'post_form',
            'tokenUrl' => 'https://oauth2.googleapis.com/token',
            'userinfoUrl' => 'https://openidconnect.googleapis.com/v1/userinfo',
        ];
    }

    if ($provider === 'facebook') {
        $clientId = trim((string)($env['FACEBOOK_OAUTH_CLIENT_ID'] ?? ''));
        $clientSecret = trim((string)($env['FACEBOOK_OAUTH_CLIENT_SECRET'] ?? ''));
        $redirectUri = trim((string)($env['FACEBOOK_OAUTH_REDIRECT_URI'] ?? ''));
        if ($clientId === '' || $clientSecret === '' || $redirectUri === '') {
            return [];
        }
        $scope = trim((string)($env['FACEBOOK_OAUTH_SCOPE'] ?? 'email public_profile'));
        if ($scope === '') {
            $scope = 'email public_profile';
        }
        $graphVersion = trim((string)($env['FACEBOOK_OAUTH_GRAPH_VERSION'] ?? 'v19.0'));
        if (!preg_match('/^v[0-9]+\\.[0-9]+$/', $graphVersion)) {
            $graphVersion = 'v19.0';
        }
        return [
            'provider' => 'facebook',
            'flow' => 'oauth2',
            'clientId' => $clientId,
            'clientSecret' => $clientSecret,
            'redirectUri' => $redirectUri,
            'scope' => $scope,
            'graphVersion' => $graphVersion,
            'tokenMethod' => 'get_query',
            'tokenUrl' => 'https://graph.facebook.com/' . $graphVersion . '/oauth/access_token',
            'userinfoUrl' => 'https://graph.facebook.com/' . $graphVersion . '/me',
        ];
    }

    if ($provider === 'steam') {
        $redirectUri = trim((string)($env['STEAM_OAUTH_REDIRECT_URI'] ?? ''));
        if ($redirectUri === '') {
            return [];
        }
        $realm = trim((string)($env['STEAM_OAUTH_REALM'] ?? ''));
        if ($realm === '') {
            $parsed = parse_url($redirectUri);
            if (is_array($parsed)) {
                $scheme = strtolower((string)($parsed['scheme'] ?? ''));
                $host = (string)($parsed['host'] ?? '');
                if ($scheme !== '' && $host !== '') {
                    $port = isset($parsed['port']) ? (int)$parsed['port'] : 0;
                    $defaultPort = ($scheme === 'https') ? 443 : (($scheme === 'http') ? 80 : 0);
                    $portPart = ($port > 0 && $port !== $defaultPort) ? ':' . $port : '';
                    $realm = $scheme . '://' . $host . $portPart;
                }
            }
        }
        if ($realm === '') {
            return [];
        }
        return [
            'provider' => 'steam',
            'flow' => 'steam_openid',
            'redirectUri' => $redirectUri,
            'realm' => $realm,
            'verifyUrl' => 'https://steamcommunity.com/openid/login',
            'steamApiKey' => trim((string)($env['STEAM_WEB_API_KEY'] ?? '')),
        ];
    }

    return [];
}

function getOpenIdRequestValue(array $req, string $dottedKey): string
{
    if (array_key_exists($dottedKey, $req)) {
        return trim((string)$req[$dottedKey]);
    }
    $underscored = str_replace('.', '_', $dottedKey);
    if (array_key_exists($underscored, $req)) {
        return trim((string)$req[$underscored]);
    }
    return '';
}

function parseHttpStatus(array $headers): int
{
    foreach ($headers as $line) {
        if (preg_match('#^HTTP/\d+(?:\.\d+)?\s+(\d{3})#', (string)$line, $m) === 1) {
            return (int)$m[1];
        }
    }
    return 0;
}

function httpPostFormJson(string $url, array $form, int $timeoutSec = 10): array
{
    $content = http_build_query($form);
    $ctx = stream_context_create([
        'http' => [
            'method' => 'POST',
            'header' => "Content-Type: application/x-www-form-urlencoded\r\nAccept: application/json\r\n",
            'content' => $content,
            'timeout' => $timeoutSec,
            'ignore_errors' => true,
        ],
    ]);

    $body = @file_get_contents($url, false, $ctx);
    $headers = isset($http_response_header) && is_array($http_response_header) ? $http_response_header : [];
    $status = parseHttpStatus($headers);

    $json = [];
    if (is_string($body) && $body !== '') {
        $decoded = json_decode($body, true);
        if (is_array($decoded)) {
            $json = $decoded;
        }
    }

    return [
        'status' => $status,
        'body' => is_string($body) ? $body : '',
        'json' => $json,
    ];
}

function httpGetJson(string $url, array $headers = [], int $timeoutSec = 10): array
{
    $headerLines = '';
    foreach ($headers as $line) {
        $headerLines .= $line . "\r\n";
    }
    $ctx = stream_context_create([
        'http' => [
            'method' => 'GET',
            'header' => $headerLines . "Accept: application/json\r\n",
            'timeout' => $timeoutSec,
            'ignore_errors' => true,
        ],
    ]);

    $body = @file_get_contents($url, false, $ctx);
    $responseHeaders = isset($http_response_header) && is_array($http_response_header) ? $http_response_header : [];
    $status = parseHttpStatus($responseHeaders);

    $json = [];
    if (is_string($body) && $body !== '') {
        $decoded = json_decode($body, true);
        if (is_array($decoded)) {
            $json = $decoded;
        }
    }

    return [
        'status' => $status,
        'body' => is_string($body) ? $body : '',
        'json' => $json,
    ];
}

function httpPostFormRaw(string $url, array $form, int $timeoutSec = 10): array
{
    $content = http_build_query($form);
    $ctx = stream_context_create([
        'http' => [
            'method' => 'POST',
            'header' => "Content-Type: application/x-www-form-urlencoded\r\n",
            'content' => $content,
            'timeout' => $timeoutSec,
            'ignore_errors' => true,
        ],
    ]);

    $body = @file_get_contents($url, false, $ctx);
    $headers = isset($http_response_header) && is_array($http_response_header) ? $http_response_header : [];
    $status = parseHttpStatus($headers);

    return [
        'status' => $status,
        'body' => is_string($body) ? $body : '',
    ];
}

function verifySteamOpenId(array $req, array $providerConfig, int $timeoutSec): array
{
    $required = [
        'openid.ns',
        'openid.mode',
        'openid.op_endpoint',
        'openid.claimed_id',
        'openid.identity',
        'openid.return_to',
        'openid.response_nonce',
        'openid.assoc_handle',
        'openid.signed',
        'openid.sig',
    ];
    foreach ($required as $key) {
        if (getOpenIdRequestValue($req, $key) === '') {
            return ['ok' => false, 'error' => 'steam_openid_missing_' . str_replace('.', '_', $key)];
        }
    }

    if (strtolower(getOpenIdRequestValue($req, 'openid.mode')) !== 'id_res') {
        return ['ok' => false, 'error' => 'steam_openid_invalid_mode'];
    }

    $claimedId = getOpenIdRequestValue($req, 'openid.claimed_id');
    if (!preg_match('#^https?://steamcommunity\\.com/openid/id/(\\d+)$#', $claimedId, $m)) {
        return ['ok' => false, 'error' => 'steam_openid_invalid_claimed_id'];
    }
    $steamId = (string)$m[1];

    $verifyParams = [
        'openid.ns' => getOpenIdRequestValue($req, 'openid.ns'),
        'openid.mode' => 'check_authentication',
        'openid.op_endpoint' => getOpenIdRequestValue($req, 'openid.op_endpoint'),
        'openid.claimed_id' => $claimedId,
        'openid.identity' => getOpenIdRequestValue($req, 'openid.identity'),
        'openid.return_to' => getOpenIdRequestValue($req, 'openid.return_to'),
        'openid.response_nonce' => getOpenIdRequestValue($req, 'openid.response_nonce'),
        'openid.assoc_handle' => getOpenIdRequestValue($req, 'openid.assoc_handle'),
        'openid.signed' => getOpenIdRequestValue($req, 'openid.signed'),
        'openid.sig' => getOpenIdRequestValue($req, 'openid.sig'),
    ];
    $verifyResp = httpPostFormRaw((string)$providerConfig['verifyUrl'], $verifyParams, $timeoutSec);
    if ((int)$verifyResp['status'] < 200 || (int)$verifyResp['status'] >= 300) {
        return ['ok' => false, 'error' => 'steam_openid_verify_http_failed'];
    }
    if (!str_contains((string)$verifyResp['body'], 'is_valid:true')) {
        return ['ok' => false, 'error' => 'steam_openid_invalid_assertion'];
    }

    return [
        'ok' => true,
        'steamId' => $steamId,
        'claimedId' => $claimedId,
        'identity' => getOpenIdRequestValue($req, 'openid.identity'),
    ];
}

function fetchSteamPlayerSummary(string $steamId, array $providerConfig, int $timeoutSec): array
{
    $apiKey = (string)($providerConfig['steamApiKey'] ?? '');
    if ($apiKey === '') {
        return [];
    }
    $url = 'https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?' . http_build_query([
        'key' => $apiKey,
        'steamids' => $steamId,
    ]);
    $resp = httpGetJson($url, [], $timeoutSec);
    if ((int)$resp['status'] < 200 || (int)$resp['status'] >= 300 || !is_array($resp['json'])) {
        return [];
    }
    $players = $resp['json']['response']['players'] ?? null;
    if (!is_array($players) || !isset($players[0]) || !is_array($players[0])) {
        return [];
    }
    return $players[0];
}

function trimToLen(?string $value, int $maxLen): ?string
{
    if ($value === null) {
        return null;
    }
    $trimmed = trim($value);
    if ($trimmed === '') {
        return null;
    }
    if (function_exists('mb_strlen') && function_exists('mb_substr')) {
        if (mb_strlen($trimmed, 'UTF-8') > $maxLen) {
            $trimmed = mb_substr($trimmed, 0, $maxLen, 'UTF-8');
        }
        return $trimmed;
    }

    if (strlen($trimmed) > $maxLen) {
        $trimmed = substr($trimmed, 0, $maxLen);
    }
    return $trimmed;
}

function sanitizeAccountNameBase(string $candidate): string
{
    $normalized = preg_replace('/[^A-Za-z0-9_]+/', '_', $candidate);
    if (!is_string($normalized)) {
        $normalized = '';
    }
    $normalized = trim($normalized, '_');
    if ($normalized === '') {
        $normalized = 'player';
    }
    if (strlen($normalized) < 3) {
        $normalized .= 'usr';
    }
    if (strlen($normalized) > 24) {
        $normalized = substr($normalized, 0, 24);
    }
    return $normalized;
}

function generateUniqueAccountName(PDO $globalDb, string $base, string $seed): string
{
    $base = sanitizeAccountNameBase($base);

    for ($i = 0; $i < 25; $i++) {
        $suffix = '';
        if ($i > 0) {
            $suffix = '_' . substr(hash('sha1', $seed . ':' . $i), 0, 6);
        }
        $maxBaseLen = 32 - strlen($suffix);
        if ($maxBaseLen < 3) {
            $maxBaseLen = 3;
        }
        $name = substr($base, 0, $maxBaseLen) . $suffix;

        if (!preg_match('/^[A-Za-z0-9_]{3,32}$/', $name)) {
            continue;
        }

        $stmt = $globalDb->prepare("SELECT id FROM accounts WHERE name = ? LIMIT 1");
        $stmt->execute([$name]);
        if (!$stmt->fetch()) {
            return $name;
        }
    }

    oauthCallbackError('account_name_generation_failed', 'Cannot generate unique account name.', 500);
}

function fetchAccountById(PDO $globalDb, int $accountId): array
{
    $stmt = $globalDb->prepare("SELECT id, name, email FROM accounts WHERE id = ? LIMIT 1");
    $stmt->execute([$accountId]);
    $row = $stmt->fetch();
    if (!$row) {
        oauthCallbackError('account_not_found', 'Account not found.', 404);
    }
    return is_array($row) ? $row : [];
}

function worldsContext(array $env): array
{
    $worldIp = $env['WORLD_IP'] ?? '127.0.0.1';
    $worldPort = isset($env['WORLD_PORT']) ? (int)$env['WORLD_PORT'] : 7172;
    $classic74Ip = $env['WORLD_CLASSIC74_IP'] ?? $worldIp;
    $classic74Port = isset($env['WORLD_CLASSIC74_PORT']) ? (int)$env['WORLD_CLASSIC74_PORT'] : $worldPort;
    $modernIp = $env['WORLD_MODERN_IP'] ?? $worldIp;
    $modernPort = isset($env['WORLD_MODERN_PORT']) ? (int)$env['WORLD_MODERN_PORT'] : 7174;

    return [
        ['id' => 0, 'gameMode' => 'classic74', 'name' => 'Classic 7.4', 'host' => $classic74Ip, 'port' => $classic74Port],
        ['id' => 1, 'gameMode' => 'modern', 'name' => 'Modern', 'host' => $modernIp, 'port' => $modernPort],
    ];
}

function gameModeFromWorldId(int $worldId): string
{
    return $worldId === 1 ? 'modern' : 'classic74';
}

function fetchCharactersByWorld(array $env, int $accountId): array
{
    $charactersByWorld = ['classic74' => [], 'modern' => [], 'unknown' => []];
    $engines = getBothEnginePdos($env);

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

function issueSyncTokenForLauncher(
    PDO $apiDb,
    int $accountId,
    int $expiresAt,
    array $metadata,
    array $env
): ?string {
    $metaJson = json_encode($metadata, JSON_UNESCAPED_SLASHES);
    if (!is_string($metaJson)) {
        $metaJson = '{}';
    }

    for ($attempt = 0; $attempt < 3; $attempt++) {
        $syncToken = bin2hex(random_bytes(32));
        try {
            $stmt = $apiDb->prepare(
                "INSERT INTO account_sync_tokens (token, account_id, source, target, expires_at, metadata_json)
                 VALUES (?, ?, 'oauth', 'launcher', ?, ?)"
            );
            $stmt->execute([$syncToken, $accountId, $expiresAt, $metaJson]);
            return $syncToken;
        } catch (PDOException $e) {
            if (str_contains($e->getMessage(), '1062') || str_contains($e->getMessage(), 'Duplicate')) {
                continue;
            }
            if (str_contains($e->getMessage(), '1146')) {
                return null;
            }
            oauthCallbackError('db_insert_failed', 'Cannot issue launcher sync token.', 500);
        }
    }

    return null;
}

function buildLauncherReturnUrl(string $baseUri, array $params): string
{
    $baseUri = trim($baseUri);
    if ($baseUri === '') {
        return '';
    }

    $sep = str_contains($baseUri, '?') ? '&' : '?';
    return $baseUri . $sep . http_build_query($params);
}

$req = getOAuthCallbackInput();
$provider = strtolower(trim((string)($req['provider'] ?? '')));
$state = trim((string)($req['state'] ?? ''));
$code = trim((string)($req['code'] ?? ''));
$codeVerifier = trim((string)($req['codeVerifier'] ?? ''));

if ($provider === '') {
    oauthCallbackError('missing_provider', 'Missing provider.');
}
$supportedProviders = ['google', 'facebook', 'steam'];
if (!in_array($provider, $supportedProviders, true)) {
    oauthCallbackError('provider_not_supported', 'Provider is not supported.', 501);
}
if ($state === '') {
    oauthCallbackError('missing_state', 'Missing OAuth state.');
}

$env = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);
$apiDb = getApiDb($env);
$globalDb = getGlobalDb($env);
$clientIp = getClientIp($env);
$ipHash = hashClientIp($clientIp, $env);
$providerLabel = ucfirst($provider);

$providerConfig = getOAuthProviderConfig($provider, $env);
if ($providerConfig === []) {
    oauthCallbackError('provider_not_configured', $providerLabel . ' OAuth is not configured on this environment.', 503);
}
$providerFlow = (string)($providerConfig['flow'] ?? '');
if (!in_array($providerFlow, ['oauth2', 'steam_openid'], true)) {
    oauthCallbackError('provider_flow_not_supported', 'Provider flow is not supported.', 501);
}
if ($providerFlow === 'oauth2' && $code === '') {
    oauthCallbackError('missing_code', 'Missing OAuth code.');
}

$sessionTtl = isset($env['SESSION_TTL']) ? (int)$env['SESSION_TTL'] : 1800;
if ($sessionTtl < 60) {
    $sessionTtl = 60;
}

$syncTtl = isset($env['ACCOUNT_SYNC_TOKEN_TTL']) ? (int)$env['ACCOUNT_SYNC_TOKEN_TTL'] : 120;
if ($syncTtl < 30) {
    $syncTtl = 30;
}
if ($syncTtl > 600) {
    $syncTtl = 600;
}

$tokenTimeout = isset($env['OAUTH_HTTP_TIMEOUT']) ? (int)$env['OAUTH_HTTP_TIMEOUT'] : (isset($env['GOOGLE_OAUTH_HTTP_TIMEOUT']) ? (int)$env['GOOGLE_OAUTH_HTTP_TIMEOUT'] : 10);
if ($tokenTimeout < 3) {
    $tokenTimeout = 3;
}
if ($tokenTimeout > 20) {
    $tokenTimeout = 20;
}

$providerEnvPrefix = strtoupper($provider) . '_OAUTH_';
$allowEmailLink = parseBoolEnv(
    $env,
    $providerEnvPrefix . 'LINK_BY_EMAIL',
    parseBoolEnv($env, 'OAUTH_LINK_BY_EMAIL', true)
);
$requireVerifiedEmail = parseBoolEnv(
    $env,
    $providerEnvPrefix . 'REQUIRE_VERIFIED_EMAIL',
    parseBoolEnv($env, 'OAUTH_REQUIRE_VERIFIED_EMAIL', true)
);
$fallbackEmailDomain = trim((string)($env['OAUTH_FALLBACK_EMAIL_DOMAIN'] ?? 'social.local'));
if ($fallbackEmailDomain === '') {
    $fallbackEmailDomain = 'social.local';
}
$launcherReturnBaseUri = trim((string)($env['LAUNCHER_OAUTH_RETURN_URI'] ?? ''));
$oauthRateLimitEnabled = parseBoolEnv($env, 'OAUTH_RATE_LIMIT_ENABLED', false);
$oauthCallbackWindow = readBoundedIntEnv($env, 'OAUTH_RATE_LIMIT_CALLBACK_WINDOW', 300, 10, 7200);
$oauthCallbackMax = readBoundedIntEnv($env, 'OAUTH_RATE_LIMIT_CALLBACK_MAX', 30, 1, 1000);

if ($oauthRateLimitEnabled) {
    $limitResult = applyOAuthRateLimitBucket(
        $apiDb,
        'oauth_callback:' . $provider,
        $ipHash,
        $oauthCallbackMax,
        $oauthCallbackWindow,
        ['provider' => $provider]
    );
    if (!$limitResult['allowed']) {
        if ($limitResult['error'] === 'schema_not_ready') {
            oauthCallbackError('oauth_rate_limit_schema_not_ready', 'OAuth rate-limit schema is not deployed yet.', 503);
        }
        if ($limitResult['error'] === 'db_error') {
            oauthCallbackError('db_query_error', 'Database query error.', 500);
        }
        oauthCallbackError(
            'rate_limited',
            'Too many OAuth callback requests. Retry in ' . (int)$limitResult['retryAfter'] . ' seconds.',
            429
        );
    }
}

$now = time();
$requestedAccountId = null;
$oauthMode = 'login';
$expectedCodeVerifierHash = null;

$apiDb->beginTransaction();
try {
    $stateStmt = $apiDb->prepare(
        "SELECT state, provider, code_verifier_hash, requested_account_id, expires_at, consumed_at
         FROM oauth_states
         WHERE state = ?
         LIMIT 1
         FOR UPDATE"
    );
    $stateStmt->execute([$state]);
    $stateRow = $stateStmt->fetch();

    if (!$stateRow) {
        throw new RuntimeException('invalid_state');
    }
    if ((string)$stateRow['provider'] !== $provider) {
        throw new RuntimeException('provider_state_mismatch');
    }
    if (!empty($stateRow['consumed_at'])) {
        throw new RuntimeException('oauth_state_already_used');
    }
    if ((int)$stateRow['expires_at'] < $now) {
        $delStmt = $apiDb->prepare("DELETE FROM oauth_states WHERE state = ?");
        $delStmt->execute([$state]);
        throw new RuntimeException('oauth_state_expired');
    }

    $statePkceHash = isset($stateRow['code_verifier_hash']) ? trim((string)$stateRow['code_verifier_hash']) : '';
    if ($statePkceHash !== '') {
        if ($codeVerifier === '') {
            throw new RuntimeException('missing_code_verifier');
        }
        if (!isValidPkceCodeVerifier($codeVerifier)) {
            throw new RuntimeException('invalid_code_verifier');
        }
        if (!hash_equals($statePkceHash, hash('sha256', $codeVerifier))) {
            throw new RuntimeException('code_verifier_mismatch');
        }
        $expectedCodeVerifierHash = $statePkceHash;
    }

    $requested = isset($stateRow['requested_account_id']) ? (int)$stateRow['requested_account_id'] : 0;
    if ($requested > 0) {
        $requestedAccountId = $requested;
        $oauthMode = 'link';
    }

    $consumeStmt = $apiDb->prepare("UPDATE oauth_states SET consumed_at = NOW() WHERE state = ?");
    $consumeStmt->execute([$state]);

    $apiDb->commit();
} catch (Throwable $e) {
    $apiDb->rollBack();
    $codeErr = $e->getMessage();
    if ($codeErr === 'oauth_schema_not_ready') {
        oauthCallbackError('oauth_schema_not_ready', 'OAuth schema is not deployed yet.', 503);
    }
    if ($codeErr === 'invalid_state') {
        oauthCallbackError('invalid_state', 'Invalid OAuth state.', 401);
    }
    if ($codeErr === 'provider_state_mismatch') {
        oauthCallbackError('provider_state_mismatch', 'OAuth provider mismatch.', 409);
    }
    if ($codeErr === 'oauth_state_already_used') {
        oauthCallbackError('oauth_state_already_used', 'OAuth state already used.', 409);
    }
    if ($codeErr === 'oauth_state_expired') {
        oauthCallbackError('oauth_state_expired', 'OAuth state expired.', 401);
    }
    if ($codeErr === 'missing_code_verifier') {
        oauthCallbackError('missing_code_verifier', 'Missing PKCE codeVerifier.', 400);
    }
    if ($codeErr === 'invalid_code_verifier') {
        oauthCallbackError('invalid_code_verifier', 'Invalid PKCE codeVerifier format.', 400);
    }
    if ($codeErr === 'code_verifier_mismatch') {
        oauthCallbackError('code_verifier_mismatch', 'PKCE codeVerifier mismatch.', 401);
    }
    oauthCallbackError('oauth_state_consume_failed', 'Cannot consume OAuth state.', 500);
}

$providerUserId = '';
$providerEmail = '';
$emailVerified = false;
$providerDisplayName = '';
$providerAvatarUrl = '';
$metadata = ['provider' => $provider];

if ($providerFlow === 'oauth2') {
    $tokenRequest = [
        'client_id' => $providerConfig['clientId'],
        'client_secret' => $providerConfig['clientSecret'],
        'code' => $code,
        'grant_type' => 'authorization_code',
        'redirect_uri' => $providerConfig['redirectUri'],
    ];
    if ($expectedCodeVerifierHash !== null) {
        $tokenRequest['code_verifier'] = $codeVerifier;
    }

    $tokenResp = null;
    if (($providerConfig['tokenMethod'] ?? 'post_form') === 'get_query') {
        $tokenUrl = (string)$providerConfig['tokenUrl'] . '?' . http_build_query($tokenRequest);
        $tokenResp = httpGetJson($tokenUrl, [], $tokenTimeout);
    } else {
        $tokenResp = httpPostFormJson((string)$providerConfig['tokenUrl'], $tokenRequest, $tokenTimeout);
    }

    $tokenJson = is_array($tokenResp['json']) ? $tokenResp['json'] : [];
    if ((int)$tokenResp['status'] < 200 || (int)$tokenResp['status'] >= 300 || $tokenJson === []) {
        oauthCallbackError($provider . '_token_exchange_failed', $providerLabel . ' token exchange failed.', 401);
    }

    $accessToken = trim((string)($tokenJson['access_token'] ?? ''));
    if ($accessToken === '') {
        oauthCallbackError($provider . '_token_missing_access_token', $providerLabel . ' response does not contain access token.', 401);
    }

    if ($provider === 'google') {
        $userinfoResp = httpGetJson((string)$providerConfig['userinfoUrl'], [
            'Authorization: Bearer ' . $accessToken,
        ], $tokenTimeout);
        $userinfo = is_array($userinfoResp['json']) ? $userinfoResp['json'] : [];
        if ((int)$userinfoResp['status'] < 200 || (int)$userinfoResp['status'] >= 300 || $userinfo === []) {
            oauthCallbackError('google_userinfo_failed', 'Cannot fetch Google user profile.', 401);
        }

        $providerUserId = trim((string)($userinfo['sub'] ?? ''));
        if ($providerUserId === '') {
            oauthCallbackError('google_userinfo_missing_sub', 'Google profile has no subject identifier.', 401);
        }
        $providerEmailRaw = trim((string)($userinfo['email'] ?? ''));
        if ($providerEmailRaw !== '' && filter_var($providerEmailRaw, FILTER_VALIDATE_EMAIL)) {
            $providerEmail = strtolower($providerEmailRaw);
        }
        $emailVerified = !empty($userinfo['email_verified']);
        if ($requireVerifiedEmail && $providerEmail !== '' && !$emailVerified) {
            $providerEmail = '';
        }
        $providerDisplayName = (string)($userinfo['name'] ?? '');
        $providerAvatarUrl = (string)($userinfo['picture'] ?? '');
        $metadata['scope'] = (string)($tokenJson['scope'] ?? '');
        $metadata['tokenType'] = (string)($tokenJson['token_type'] ?? '');
    } elseif ($provider === 'facebook') {
        $fields = 'id,name,email,picture.type(large)';
        $userinfoUrl = (string)$providerConfig['userinfoUrl'] . '?' . http_build_query([
            'fields' => $fields,
            'access_token' => $accessToken,
        ]);
        $userinfoResp = httpGetJson($userinfoUrl, [], $tokenTimeout);
        $userinfo = is_array($userinfoResp['json']) ? $userinfoResp['json'] : [];
        if ((int)$userinfoResp['status'] < 200 || (int)$userinfoResp['status'] >= 300 || $userinfo === []) {
            oauthCallbackError('facebook_userinfo_failed', 'Cannot fetch Facebook user profile.', 401);
        }

        $providerUserId = trim((string)($userinfo['id'] ?? ''));
        if ($providerUserId === '') {
            oauthCallbackError('facebook_userinfo_missing_id', 'Facebook profile has no identifier.', 401);
        }
        $providerEmailRaw = trim((string)($userinfo['email'] ?? ''));
        if ($providerEmailRaw !== '' && filter_var($providerEmailRaw, FILTER_VALIDATE_EMAIL)) {
            $providerEmail = strtolower($providerEmailRaw);
        }
        $emailVerified = ($providerEmail !== '');
        $providerDisplayName = (string)($userinfo['name'] ?? '');
        $pictureUrl = $userinfo['picture']['data']['url'] ?? '';
        $providerAvatarUrl = is_string($pictureUrl) ? $pictureUrl : '';
        $metadata['scope'] = (string)($tokenJson['scope'] ?? '');
        $metadata['tokenType'] = (string)($tokenJson['token_type'] ?? '');
    } else {
        oauthCallbackError('provider_flow_not_supported', 'Provider flow is not supported.', 501);
    }
} elseif ($providerFlow === 'steam_openid') {
    $steamVerify = verifySteamOpenId($req, $providerConfig, $tokenTimeout);
    if (empty($steamVerify['ok'])) {
        $errorCode = (string)($steamVerify['error'] ?? 'steam_openid_failed');
        oauthCallbackError($errorCode, 'Steam OpenID verification failed.', 401);
    }

    $providerUserId = (string)($steamVerify['steamId'] ?? '');
    if ($providerUserId === '') {
        oauthCallbackError('steam_openid_missing_steamid', 'Steam OpenID did not return steamid.', 401);
    }
    $providerEmail = '';
    $emailVerified = false;
    $providerDisplayName = 'Steam ' . $providerUserId;
    $providerAvatarUrl = '';

    $steamProfile = fetchSteamPlayerSummary($providerUserId, $providerConfig, $tokenTimeout);
    if ($steamProfile !== []) {
        if (isset($steamProfile['personaname']) && is_string($steamProfile['personaname']) && trim($steamProfile['personaname']) !== '') {
            $providerDisplayName = trim((string)$steamProfile['personaname']);
        }
        if (isset($steamProfile['avatarfull']) && is_string($steamProfile['avatarfull'])) {
            $providerAvatarUrl = trim((string)$steamProfile['avatarfull']);
        }
    }

    $metadata['claimedId'] = (string)($steamVerify['claimedId'] ?? '');
    $metadata['identity'] = (string)($steamVerify['identity'] ?? '');
    $metadata['steamProfileEnriched'] = ($steamProfile !== []);
} else {
    oauthCallbackError('provider_flow_not_supported', 'Provider flow is not supported.', 501);
}

$providerUserId = trimToLen($providerUserId, 191) ?? '';
if ($providerUserId === '') {
    oauthCallbackError($provider . '_userinfo_invalid_id', $providerLabel . ' profile identifier is invalid.', 401);
}
$providerEmailDb = trimToLen($providerEmail, 255);
$providerDisplayNameDb = trimToLen($providerDisplayName, 191);
$providerAvatarUrlDb = trimToLen($providerAvatarUrl, 512);

$metadata['emailVerified'] = (bool)$emailVerified;
$metadataJson = json_encode($metadata, JSON_UNESCAPED_SLASHES);
if (!is_string($metadataJson)) {
    $metadataJson = '{}';
}

$accountId = 0;
$action = 'login_existing_link';
$linkCreatedNow = false;

$globalDb->beginTransaction();
try {
    $existingLinkStmt = $globalDb->prepare(
        "SELECT id, account_id
         FROM account_identity_links
         WHERE provider = ? AND provider_user_id = ?
         LIMIT 1
         FOR UPDATE"
    );
    $existingLinkStmt->execute([$provider, $providerUserId]);
    $existingLink = $existingLinkStmt->fetch();

    if ($existingLink) {
        $accountId = (int)$existingLink['account_id'];
        if ($requestedAccountId !== null && $requestedAccountId !== $accountId) {
            throw new RuntimeException('provider_already_linked_other_account');
        }

        $updateLinkStmt = $globalDb->prepare(
            "UPDATE account_identity_links
             SET provider_email = ?, provider_display_name = ?, provider_avatar_url = ?, metadata_json = ?, last_login_at = NOW()
             WHERE id = ?"
        );
        $linkId = (int)$existingLink['id'];
        $updateLinkStmt->execute([
            $providerEmailDb,
            $providerDisplayNameDb,
            $providerAvatarUrlDb,
            $metadataJson,
            $linkId
        ]);

        if ($requestedAccountId !== null) {
            $action = 'already_linked';
        }
    } else {
        if ($requestedAccountId !== null) {
            $accountId = $requestedAccountId;
            $existsStmt = $globalDb->prepare("SELECT id FROM accounts WHERE id = ? LIMIT 1 FOR UPDATE");
            $existsStmt->execute([$accountId]);
            if (!$existsStmt->fetch()) {
                throw new RuntimeException('link_account_not_found');
            }
            $action = 'linked_to_existing_account';
        } else {
            $resolvedByEmail = false;
            if ($allowEmailLink && $providerEmailDb !== null && $providerEmailDb !== '') {
                $emailStmt = $globalDb->prepare(
                    "SELECT id, name
                     FROM accounts
                     WHERE email = ?
                     ORDER BY id ASC
                     LIMIT 3
                     FOR UPDATE"
                );
                $emailStmt->execute([$providerEmailDb]);

                $emailMatches = [];
                while ($row = $emailStmt->fetch()) {
                    $emailMatches[] = $row;
                }

                if (count($emailMatches) > 1) {
                    throw new RuntimeException('email_conflict_multiple_accounts');
                }
                if (count($emailMatches) === 1 && is_array($emailMatches[0])) {
                    $accountId = (int)$emailMatches[0]['id'];
                    $resolvedByEmail = true;
                    $action = 'linked_by_email';
                }
            }

            if (!$resolvedByEmail) {
                $nameSeed = $providerDisplayNameDb ?? ($providerEmailDb ?? ($provider . '_' . $providerUserId));
                $accountName = generateUniqueAccountName($globalDb, (string)$nameSeed, $providerUserId);
                $emailForAccount = $providerEmailDb;
                if ($emailForAccount === null || $emailForAccount === '') {
                    $emailForAccount = $provider . '_' . substr(hash('sha256', $providerUserId), 0, 20) . '@' . $fallbackEmailDomain;
                }

                $passwordRaw = bin2hex(random_bytes(24));
                $passwordHash = password_hash(
                    $passwordRaw,
                    defined('PASSWORD_ARGON2ID') ? PASSWORD_ARGON2ID : PASSWORD_BCRYPT
                );
                if ($passwordHash === false) {
                    throw new RuntimeException('password_hash_failed');
                }

                $engineSha1 = sha1($passwordRaw);
                $accountKey = bin2hex(random_bytes(32));
                $created = time();
                $emailHash = md5($emailForAccount);
                $emailVerifiedFlag = ($providerEmailDb !== null && $providerEmailDb !== '' && $emailVerified) ? 1 : 0;

                $insertAccount = $globalDb->prepare(
                    "INSERT INTO accounts (name, password, engine_password_sha1, email, `key`, created, email_hash, email_verified)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
                );
                try {
                    $insertAccount->execute([
                        $accountName,
                        $passwordHash,
                        $engineSha1,
                        $emailForAccount,
                        $accountKey,
                        $created,
                        $emailHash,
                        $emailVerifiedFlag
                    ]);
                } catch (PDOException $e) {
                    if (str_contains($e->getMessage(), '1062') || str_contains($e->getMessage(), 'Duplicate')) {
                        throw new RuntimeException('account_insert_duplicate');
                    }
                    throw new RuntimeException('db_insert_failed');
                }
                $accountId = (int)$globalDb->lastInsertId();
                $action = 'created_new_account';
            }
        }

        $isPrimary = 0;
        $primaryCheckStmt = $globalDb->prepare(
            "SELECT id FROM account_identity_links WHERE account_id = ? LIMIT 1 FOR UPDATE"
        );
        $primaryCheckStmt->execute([$accountId]);
        if (!$primaryCheckStmt->fetch()) {
            $isPrimary = 1;
        }

        $insertLinkStmt = $globalDb->prepare(
            "INSERT INTO account_identity_links
                (account_id, provider, provider_user_id, provider_email, provider_display_name, provider_avatar_url, is_primary, metadata_json, linked_at, last_login_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())"
        );
        try {
            $insertLinkStmt->execute([
                $accountId,
                $provider,
                $providerUserId,
                $providerEmailDb,
                $providerDisplayNameDb,
                $providerAvatarUrlDb,
                $isPrimary,
                $metadataJson
            ]);
        } catch (PDOException $e) {
            if (str_contains($e->getMessage(), '1062') || str_contains($e->getMessage(), 'Duplicate')) {
                throw new RuntimeException('provider_already_linked_race');
            }
            throw new RuntimeException('db_insert_failed');
        }
        $linkCreatedNow = true;
    }

    if ($accountId <= 0) {
        throw new RuntimeException('account_resolution_failed');
    }

    $globalDb->commit();
} catch (Throwable $e) {
    $globalDb->rollBack();
    $codeErr = $e->getMessage();

    if ($codeErr === 'oauth_schema_not_ready') {
        oauthCallbackError('oauth_schema_not_ready', 'OAuth schema is not deployed yet.', 503);
    }
    if ($codeErr === 'provider_already_linked_other_account') {
        oauthCallbackError('provider_already_linked_other_account', $providerLabel . ' identity is already linked to another account.', 409);
    }
    if ($codeErr === 'provider_already_linked_race') {
        oauthCallbackError('provider_already_linked', $providerLabel . ' identity is already linked. Retry login.', 409);
    }
    if ($codeErr === 'link_account_not_found') {
        oauthCallbackError('link_account_not_found', 'Requested account for linking does not exist.', 404);
    }
    if ($codeErr === 'email_conflict_multiple_accounts') {
        oauthCallbackError('email_conflict_multiple_accounts', 'Multiple local accounts share this email. Manual merge required before social linking.', 409);
    }
    if ($codeErr === 'password_hash_failed') {
        oauthCallbackError('password_hash_failed', 'Password hashing failed.', 500);
    }
    if ($codeErr === 'account_insert_duplicate') {
        oauthCallbackError('account_insert_duplicate', 'Account conflict during social registration. Retry.', 409);
    }
    oauthCallbackError('oauth_account_link_failed', 'Cannot map ' . $providerLabel . ' identity to local account.', 500);
}

// Issue session and sync token on API_DB (separate from identity transaction)
$newSessionKey = bin2hex(random_bytes(32));
$sessionExpiresAt = $now + $sessionTtl;
$sessionMode = 'all';

$sessionStmt = $apiDb->prepare(
    "INSERT INTO ticket_sessions (session_key, account_id, game_mode, expires_at)
     VALUES (?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE account_id = VALUES(account_id), game_mode = VALUES(game_mode), expires_at = VALUES(expires_at)"
);
$sessionStmt->execute([$newSessionKey, $accountId, $sessionMode, $sessionExpiresAt]);

$launcherSyncExpiresAt = $now + $syncTtl;
$launcherSyncToken = issueSyncTokenForLauncher($apiDb, $accountId, $launcherSyncExpiresAt, [
    'ipHash' => $ipHash,
    'provider' => $provider,
    'providerUserId' => $providerUserId,
    'issuedAt' => $now,
], $env);

$account = fetchAccountById($globalDb, $accountId);
$charactersByWorld = fetchCharactersByWorld($env, $accountId);

$counts = [
    'all' => count($charactersByWorld['classic74']) + count($charactersByWorld['modern']) + count($charactersByWorld['unknown']),
    'classic74' => count($charactersByWorld['classic74']),
    'modern' => count($charactersByWorld['modern']),
    'unknown' => count($charactersByWorld['unknown']),
];

if (mt_rand(1, 10) === 1) {
    $cleanup = $apiDb->prepare("DELETE FROM oauth_states WHERE expires_at < ? OR consumed_at IS NOT NULL");
    $cleanup->execute([$now]);
}

if (!isset($account) || !is_array($account)) {
    oauthCallbackError('account_resolution_failed', 'Cannot resolve local account.', 500);
}
if (!isset($newSessionKey) || !is_string($newSessionKey) || $newSessionKey === '') {
    oauthCallbackError('session_issue_failed', 'Cannot issue launcher session.', 500);
}
if (!isset($sessionExpiresAt) || !is_int($sessionExpiresAt)) {
    oauthCallbackError('session_issue_failed', 'Cannot issue launcher session.', 500);
}

logTicketEvent('oauth.callback', [
    'endpoint' => 'oauth-callback.php',
    'ipHash' => $ipHash,
    'provider' => $provider,
    'mode' => $oauthMode,
    'action' => $action,
    'rateLimitEnabled' => $oauthRateLimitEnabled ? 1 : 0,
    'rateLimitWindow' => $oauthRateLimitEnabled ? $oauthCallbackWindow : 0,
    'rateLimitMax' => $oauthRateLimitEnabled ? $oauthCallbackMax : 0,
    'accountId' => (int)$account['id'],
    'linkCreatedNow' => $linkCreatedNow ? 1 : 0,
    'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
], $env);

$launcherDeepLink = null;
if ($launcherSyncToken !== null && $launcherReturnBaseUri !== '') {
    $launcherDeepLink = buildLauncherReturnUrl($launcherReturnBaseUri, [
        'status' => 'ok',
        'provider' => $provider,
        'syncToken' => $launcherSyncToken,
    ]);
}

$response = [
    'ok' => true,
    'provider' => $provider,
    'mode' => $oauthMode,
    'action' => $action,
    'pkce' => [
        'used' => $expectedCodeVerifierHash !== null,
    ],
    'account' => [
        'id' => (int)$account['id'],
        'name' => (string)$account['name'],
        'email' => (string)$account['email'],
    ],
    'session' => [
        'sessionKey' => $newSessionKey,
        'accountId' => (int)$account['id'],
        'gameMode' => 'all',
        'expiresAt' => $sessionExpiresAt,
    ],
    'identity' => [
        'provider' => $provider,
        'providerUserId' => $providerUserId,
        'providerEmail' => (string)($providerEmailDb ?? ''),
        'providerDisplayName' => (string)($providerDisplayNameDb ?? ''),
        'providerAvatarUrl' => (string)($providerAvatarUrlDb ?? ''),
        'emailVerified' => (bool)$emailVerified,
        'linkedNow' => $linkCreatedNow,
    ],
    'worlds' => worldsContext($env),
    'charactersByWorld' => $charactersByWorld,
    'counts' => $counts,
    'launcherSyncToken' => $launcherSyncToken,
    'launcherSyncExpiresAt' => isset($launcherSyncExpiresAt) ? $launcherSyncExpiresAt : null,
    'launcherDeepLink' => $launcherDeepLink,
];

if (!wantsJsonResponse() && $launcherDeepLink !== null) {
    header('Location: ' . $launcherDeepLink, true, 302);
    exit;
}

json_out($response);
