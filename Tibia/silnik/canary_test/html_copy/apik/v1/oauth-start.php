<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * oauth-start.php — K15/K16/K17
 *
 * Starts OAuth/OpenID flow and returns provider authorization URL.
 *
 * Request (GET/POST/JSON):
 *   provider=google|facebook|steam
 *   mode=login|link      (default: login)
 *   sessionKey=<ticket session key>   (required for mode=link)
 *   codeVerifier=<pkce verifier>       (oauth2 providers only)
 */

require_once __DIR__ . '/common.php';
$requestStartedAt = microtime(true);

function oauthStartError(string $code, string $message, int $httpCode = 400): void
{
    sendLauncherError($code, $message, $httpCode);
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
    return preg_match('/^[A-Za-z0-9\-._~]+$/', $value) === 1;
}

function pkceCodeChallenge(string $codeVerifier): string
{
    $hash = hash('sha256', $codeVerifier, true);
    return rtrim(strtr(base64_encode($hash), '+/', '-_'), '=');
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

function getOAuthStartInput(): array
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

function appendQueryParams(string $url, array $params): string
{
    if ($url === '') {
        return '';
    }
    $sep = str_contains($url, '?') ? '&' : '?';
    return $url . $sep . http_build_query($params);
}

function extractUrlOrigin(string $url): string
{
    $parts = parse_url($url);
    if (!is_array($parts)) {
        return '';
    }
    $scheme = strtolower((string)($parts['scheme'] ?? ''));
    $host = (string)($parts['host'] ?? '');
    if ($scheme === '' || $host === '') {
        return '';
    }
    $port = isset($parts['port']) ? (int)$parts['port'] : 0;
    $defaultPort = ($scheme === 'https') ? 443 : (($scheme === 'http') ? 80 : 0);
    $portPart = ($port > 0 && $port !== $defaultPort) ? ':' . $port : '';
    return $scheme . '://' . $host . $portPart;
}

function getOAuthStartProviderConfig(string $provider, array $env): array
{
    if ($provider === 'google') {
        $clientId = trim((string)($env['GOOGLE_OAUTH_CLIENT_ID'] ?? ''));
        $redirectUri = trim((string)($env['GOOGLE_OAUTH_REDIRECT_URI'] ?? ''));
        if ($clientId === '' || $redirectUri === '') {
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
            'redirectUri' => $redirectUri,
            'scope' => $scope,
            'authUrl' => 'https://accounts.google.com/o/oauth2/v2/auth',
            'pkceRequired' => parseBoolEnv($env, 'GOOGLE_OAUTH_REQUIRE_PKCE', false),
            'supportsPkce' => true,
        ];
    }

    if ($provider === 'facebook') {
        $clientId = trim((string)($env['FACEBOOK_OAUTH_CLIENT_ID'] ?? ''));
        $redirectUri = trim((string)($env['FACEBOOK_OAUTH_REDIRECT_URI'] ?? ''));
        if ($clientId === '' || $redirectUri === '') {
            return [];
        }
        $scope = trim((string)($env['FACEBOOK_OAUTH_SCOPE'] ?? 'email public_profile'));
        if ($scope === '') {
            $scope = 'email public_profile';
        }
        $graphVersion = trim((string)($env['FACEBOOK_OAUTH_GRAPH_VERSION'] ?? 'v19.0'));
        if (!preg_match('/^v[0-9]+\.[0-9]+$/', $graphVersion)) {
            $graphVersion = 'v19.0';
        }
        return [
            'provider' => 'facebook',
            'flow' => 'oauth2',
            'clientId' => $clientId,
            'redirectUri' => $redirectUri,
            'scope' => $scope,
            'graphVersion' => $graphVersion,
            'authUrl' => 'https://www.facebook.com/' . $graphVersion . '/dialog/oauth',
            'pkceRequired' => parseBoolEnv($env, 'FACEBOOK_OAUTH_REQUIRE_PKCE', false),
            'supportsPkce' => true,
        ];
    }

    if ($provider === 'steam') {
        $redirectUri = trim((string)($env['STEAM_OAUTH_REDIRECT_URI'] ?? ''));
        if ($redirectUri === '') {
            return [];
        }
        $realm = trim((string)($env['STEAM_OAUTH_REALM'] ?? ''));
        if ($realm === '') {
            $realm = extractUrlOrigin($redirectUri);
        }
        if ($realm === '') {
            return [];
        }
        return [
            'provider' => 'steam',
            'flow' => 'steam_openid',
            'redirectUri' => $redirectUri,
            'realm' => $realm,
            'authUrl' => 'https://steamcommunity.com/openid/login',
            'pkceRequired' => false,
            'supportsPkce' => false,
        ];
    }

    return [];
}

$req = getOAuthStartInput();
$provider = strtolower(trim((string)($req['provider'] ?? '')));
$mode = strtolower(trim((string)($req['mode'] ?? 'login')));
$sessionKey = trim((string)($req['sessionKey'] ?? ''));
$codeVerifier = trim((string)($req['codeVerifier'] ?? ''));

if ($provider === '') {
    oauthStartError('missing_provider', 'Missing provider.');
}
if (!in_array($mode, ['login', 'link'], true)) {
    oauthStartError('invalid_mode', 'Invalid mode. Expected login or link.');
}
$supportedProviders = ['google', 'facebook', 'steam'];
if (!in_array($provider, $supportedProviders, true)) {
    oauthStartError('provider_not_supported', 'Provider is not supported.', 501);
}
if ($mode === 'link' && $sessionKey === '') {
    oauthStartError('missing_session_key', 'Missing sessionKey for mode=link.');
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);
$apiDb = getApiDb($ENV);
$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);

$providerConfig = getOAuthStartProviderConfig($provider, $ENV);
if ($providerConfig === []) {
    oauthStartError('provider_not_configured', 'OAuth provider is not configured on this environment.', 503);
}

$pkceRequired = (bool)$providerConfig['pkceRequired'];
$supportsPkce = (bool)$providerConfig['supportsPkce'];
$codeVerifierHash = null;
$codeChallenge = null;
if ($codeVerifier !== '') {
    if (!$supportsPkce) {
        oauthStartError('provider_pkce_not_supported', 'PKCE is not supported for this provider.');
    }
    if (!isValidPkceCodeVerifier($codeVerifier)) {
        oauthStartError('invalid_code_verifier', 'Invalid PKCE codeVerifier format.');
    }
    $codeVerifierHash = hash('sha256', $codeVerifier);
    $codeChallenge = pkceCodeChallenge($codeVerifier);
} elseif ($pkceRequired) {
    oauthStartError('missing_code_verifier', 'Missing PKCE codeVerifier.');
}

$oauthStateTtl = isset($ENV['OAUTH_STATE_TTL']) ? (int)$ENV['OAUTH_STATE_TTL'] : 300;
if ($oauthStateTtl < 60) {
    $oauthStateTtl = 60;
}
if ($oauthStateTtl > 900) {
    $oauthStateTtl = 900;
}
$oauthRateLimitEnabled = parseBoolEnv($ENV, 'OAUTH_RATE_LIMIT_ENABLED', false);
$oauthStartWindow = readBoundedIntEnv($ENV, 'OAUTH_RATE_LIMIT_START_WINDOW', 60, 5, 3600);
$oauthStartMax = readBoundedIntEnv($ENV, 'OAUTH_RATE_LIMIT_START_MAX', 20, 1, 1000);

if ($oauthRateLimitEnabled) {
    $limitResult = applyOAuthRateLimitBucket(
        $apiDb,
        'oauth_start:' . $provider,
        $ipHash,
        $oauthStartMax,
        $oauthStartWindow,
        ['provider' => $provider, 'mode' => $mode]
    );
    if (!$limitResult['allowed']) {
        if ($limitResult['error'] === 'schema_not_ready') {
            oauthStartError('oauth_rate_limit_schema_not_ready', 'OAuth rate-limit schema is not deployed yet.', 503);
        }
        if ($limitResult['error'] === 'db_error') {
            oauthStartError('db_query_error', 'Database query error.', 500);
        }
        oauthStartError(
            'rate_limited',
            'Too many OAuth start requests. Retry in ' . (int)$limitResult['retryAfter'] . ' seconds.',
            429
        );
    }
}

$requestedAccountId = null;
$now = time();
if ($mode === 'link') {
    $stmt = $apiDb->prepare(
        "SELECT account_id, expires_at FROM ticket_sessions WHERE session_key = ? LIMIT 1"
    );
    $stmt->execute([$sessionKey]);
    $session = $stmt->fetch();
    if (!$session) {
        oauthStartError('invalid_session', 'Invalid or expired session for linking.', 401);
    }
    if ((int)$session['expires_at'] < $now) {
        oauthStartError('expired_session', 'Session expired for linking.', 401);
    }
    $requestedAccountId = (int)$session['account_id'];
}

$state = bin2hex(random_bytes(32));
$expiresAt = $now + $oauthStateTtl;
try {
    $stmt = $apiDb->prepare(
        "INSERT INTO oauth_states (state, provider, code_verifier_hash, redirect_uri, requested_account_id, expires_at)
         VALUES (?, ?, ?, ?, ?, ?)"
    );
    $stmt->execute([$state, $provider, $codeVerifierHash, $providerConfig['redirectUri'], $requestedAccountId, $expiresAt]);
} catch (PDOException $e) {
    if (str_contains($e->getMessage(), '1146')) {
        oauthStartError('oauth_schema_not_ready', 'OAuth schema is not deployed yet.', 503);
    }
    oauthStartError('db_insert_failed', 'Cannot create OAuth state.', 500);
}

$authUrl = '';
if ($providerConfig['flow'] === 'oauth2') {
    $authParams = [
        'client_id' => $providerConfig['clientId'],
        'redirect_uri' => $providerConfig['redirectUri'],
        'response_type' => 'code',
        'scope' => $providerConfig['scope'],
        'state' => $state,
    ];
    if ($provider === 'google') {
        $authParams['access_type'] = 'online';
        $authParams['include_granted_scopes'] = 'true';
        $authParams['prompt'] = 'select_account';
    }
    if ($provider === 'facebook') {
        $authParams['display'] = 'popup';
    }
    if ($supportsPkce && $codeChallenge !== null) {
        $authParams['code_challenge'] = $codeChallenge;
        $authParams['code_challenge_method'] = 'S256';
    }
    $authUrl = $providerConfig['authUrl'] . '?' . http_build_query($authParams);
} elseif ($providerConfig['flow'] === 'steam_openid') {
    $returnTo = appendQueryParams($providerConfig['redirectUri'], [
        'provider' => $provider,
        'state' => $state,
    ]);
    $authParams = [
        'openid.ns' => 'http://specs.openid.net/auth/2.0',
        'openid.mode' => 'checkid_setup',
        'openid.return_to' => $returnTo,
        'openid.realm' => $providerConfig['realm'],
        'openid.identity' => 'http://specs.openid.net/auth/2.0/identifier_select',
        'openid.claimed_id' => 'http://specs.openid.net/auth/2.0/identifier_select',
    ];
    $authUrl = $providerConfig['authUrl'] . '?' . http_build_query($authParams);
}
if ($authUrl === '') {
    oauthStartError('provider_flow_not_supported', 'Provider flow is not supported.', 501);
}

if (mt_rand(1, 10) === 1) {
    $cleanup = $apiDb->prepare("DELETE FROM oauth_states WHERE expires_at < ? OR consumed_at IS NOT NULL");
    $cleanup->execute([$now]);
}

logTicketEvent('oauth.start', [
    'endpoint' => 'oauth-start.php',
    'ipHash' => $ipHash,
    'provider' => $provider,
    'mode' => $mode,
    'flow' => (string)$providerConfig['flow'],
    'requestedAccountId' => $requestedAccountId,
    'pkce' => $codeVerifierHash !== null ? 'enabled' : 'disabled',
    'rateLimitEnabled' => $oauthRateLimitEnabled ? 1 : 0,
    'rateLimitWindow' => $oauthRateLimitEnabled ? $oauthStartWindow : 0,
    'rateLimitMax' => $oauthRateLimitEnabled ? $oauthStartMax : 0,
    'stateTtl' => $oauthStateTtl,
    'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
], $ENV);

json_out([
    'ok' => true,
    'provider' => $provider,
    'mode' => $mode,
    'flow' => (string)$providerConfig['flow'],
    'pkceRequired' => $pkceRequired,
    'pkceProvided' => $codeVerifierHash !== null,
    'state' => $state,
    'expiresAt' => $expiresAt,
    'authUrl' => $authUrl,
]);
