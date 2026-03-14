<?php
declare(strict_types=1);

function reddaxe_env(string $path): array
{
    if (!is_file($path)) {
        return [];
    }

    $result = [];
    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    if (!is_array($lines)) {
        return [];
    }

    foreach ($lines as $line) {
        $line = trim($line);
        if ($line === '' || str_starts_with($line, '#')) {
            continue;
        }

        $eqPos = strpos($line, '=');
        if ($eqPos === false) {
            continue;
        }

        $key = trim(substr($line, 0, $eqPos));
        $value = trim(substr($line, $eqPos + 1));
        if ($key === '') {
            continue;
        }

        if (
            (str_starts_with($value, '"') && str_ends_with($value, '"')) ||
            (str_starts_with($value, "'") && str_ends_with($value, "'"))
        ) {
            $value = substr($value, 1, -1);
        }

        $result[$key] = $value;
    }

    return $result;
}

function reddaxe_build_config(): array
{
    $apiEnv = reddaxe_env(__DIR__ . '/../apik/v1/.env');

    $links = [
        'www' => (string)($apiEnv['REDDAXE_LINK_WWW'] ?? '/latestnews'),
        'forum' => (string)($apiEnv['REDDAXE_LINK_FORUM'] ?? '/latestnews'),
        'wiki' => (string)($apiEnv['REDDAXE_LINK_WIKI'] ?? '/latestnews'),
        'external-discord' => (string)($apiEnv['REDDAXE_LINK_EXTERNAL_DISCORD'] ?? 'https://discord.com'),
    ];

    $allowedHosts = [
        'discord.com',
        'www.discord.com',
        'discord.gg',
    ];

    $allowedHostsFromEnv = (string)($apiEnv['REDDAXE_ALLOWED_HOSTS'] ?? '');
    if ($allowedHostsFromEnv !== '') {
        $parts = array_filter(array_map('trim', explode(',', $allowedHostsFromEnv)));
        if ($parts !== []) {
            $allowedHosts = array_values(array_unique($parts));
        }
    }

    return [
        'brand' => (string)($apiEnv['REDDAXE_BRAND'] ?? 'RedDAXE.pl'),
        'accountLoginUrl' => (string)($apiEnv['REDDAXE_LOGIN_URL'] ?? '/reddaxe/account-login.php'),
        'accountCreateUrl' => (string)($apiEnv['REDDAXE_CREATE_URL'] ?? '/reddaxe/account-create.php'),
        'downloadPageUrl' => (string)($apiEnv['REDDAXE_DOWNLOAD_PAGE_URL'] ?? '/downloads'),
        'installerCatalogApiUrl' => (string)($apiEnv['REDDAXE_INSTALLER_CATALOG_API'] ?? '/apik/v1/installer-catalog.php'),
        'registerApiPath' => (string)($apiEnv['REDDAXE_REGISTER_API_PATH'] ?? '/apik/v1/register-account.php'),
        'redirectLinks' => $links,
        'allowedExternalHosts' => $allowedHosts,
    ];
}

function reddaxe_e(string $value): string
{
    return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
}

function reddaxe_is_allowed_target(string $target, array $allowedHosts): bool
{
    if ($target === '') {
        return false;
    }

    if (str_starts_with($target, '/')) {
        return !str_starts_with($target, '//');
    }

    if (!preg_match('#^https?://#i', $target)) {
        return false;
    }

    $parts = parse_url($target);
    if (!is_array($parts)) {
        return false;
    }

    $host = strtolower((string)($parts['host'] ?? ''));
    if ($host === '') {
        return false;
    }

    foreach ($allowedHosts as $allowedHost) {
        $allowedHost = strtolower(trim((string)$allowedHost));
        if ($allowedHost === '') {
            continue;
        }
        if ($host === $allowedHost) {
            return true;
        }
        if (str_ends_with($host, '.' . $allowedHost)) {
            return true;
        }
    }

    return false;
}

function reddaxe_log_redirect(string $key, string $target): void
{
    $line = json_encode([
        'ts' => gmdate('c'),
        'event' => 'reddaxe.redirect',
        'targetKey' => $key,
        'target' => $target,
        'ipHash' => reddaxe_ip_hash(),
        'ua' => substr((string)($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 180),
    ], JSON_UNESCAPED_SLASHES);

    if (!is_string($line)) {
        return;
    }

    @file_put_contents(__DIR__ . '/redirect.log', $line . PHP_EOL, FILE_APPEND | LOCK_EX);
}

function reddaxe_ip_hash(): string
{
    $ip = trim((string)($_SERVER['REMOTE_ADDR'] ?? ''));
    if ($ip === '') {
        return 'unknown';
    }

    static $salt = null;
    if ($salt === null) {
        $env = reddaxe_env(__DIR__ . '/../apik/v1/.env');
        $salt = (string)($env['REDDAXE_LOG_SALT'] ?? $env['APP_KEY'] ?? 'reddaxe-redirect-v1');
        if ($salt === '') {
            $salt = 'reddaxe-redirect-v1';
        }
    }

    return substr(hash('sha256', $salt . '|' . $ip), 0, 16);
}

function reddaxe_public_base_url(): string
{
    $scheme = 'http';
    if (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') {
        $scheme = 'https';
    } elseif (!empty($_SERVER['HTTP_X_FORWARDED_PROTO'])) {
        $forwardedProto = strtolower((string)$_SERVER['HTTP_X_FORWARDED_PROTO']);
        if ($forwardedProto === 'https') {
            $scheme = 'https';
        }
    }

    $host = (string)($_SERVER['HTTP_HOST'] ?? '127.0.0.1');
    return $scheme . '://' . $host;
}

function reddaxe_skip_tls_verify_for_url(string $url): bool
{
    $parts = parse_url($url);
    if (!is_array($parts)) {
        return false;
    }
    $scheme = strtolower((string)($parts['scheme'] ?? ''));
    if ($scheme !== 'https') {
        return false;
    }
    $host = strtolower((string)($parts['host'] ?? ''));

    if (in_array($host, ['127.0.0.1', 'localhost', '::1'], true)) {
        return true;
    }

    // Host rozwiązujący się na loopback (np. tibia.reddaxe.pl → 127.0.0.1 w /etc/hosts)
    $resolved = gethostbyname($host);
    if ($resolved !== $host && str_starts_with($resolved, '127.')) {
        return true;
    }

    return false;
}

function reddaxe_internal_api_base_url(): string
{
    static $cached = null;
    if ($cached !== null) {
        return $cached;
    }
    $env = reddaxe_env(__DIR__ . '/../apik/v1/.env');
    $override = trim((string)($env['INTERNAL_API_BASE_URL'] ?? ''));
    $cached = ($override !== '') ? $override : reddaxe_public_base_url();
    return $cached;
}

function reddaxe_post_json(string $path, array $payload, int &$httpCode = 0): array
{
    $url = rtrim(reddaxe_internal_api_base_url(), '/') . '/' . ltrim($path, '/');
    $skipTlsVerify = reddaxe_skip_tls_verify_for_url($url);
    $body = json_encode($payload, JSON_UNESCAPED_SLASHES);
    if (!is_string($body)) {
        $httpCode = 0;
        return [
            'ok' => false,
            'error' => 'json_encode_failed',
            'message' => 'Cannot encode request payload.',
            'raw' => '',
        ];
    }

    if (function_exists('curl_init')) {
        $ch = curl_init($url);
        if ($ch === false) {
            $httpCode = 0;
            return [
                'ok' => false,
                'error' => 'curl_init_failed',
                'message' => 'Cannot initialize HTTP client.',
                'raw' => '',
            ];
        }

        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Accept: application/json',
            ],
            CURLOPT_POSTFIELDS => $body,
            CURLOPT_TIMEOUT => 15,
            CURLOPT_SSL_VERIFYPEER => !$skipTlsVerify,
            CURLOPT_SSL_VERIFYHOST => $skipTlsVerify ? 0 : 2,
        ]);

        $raw = curl_exec($ch);
        if ($raw === false) {
            $message = (string)curl_error($ch);
            curl_close($ch);
            $httpCode = 0;
            return [
                'ok' => false,
                'error' => 'curl_exec_failed',
                'message' => $message !== '' ? $message : 'Cannot contact API endpoint.',
                'raw' => '',
            ];
        }
        $httpCode = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
        curl_close($ch);
    } else {
        $context = stream_context_create([
            'http' => [
                'method' => 'POST',
                'header' => "Content-Type: application/json\r\nAccept: application/json\r\n",
                'content' => $body,
                'timeout' => 15,
                'ignore_errors' => true,
            ],
            'ssl' => [
                'verify_peer' => !$skipTlsVerify,
                'verify_peer_name' => !$skipTlsVerify,
            ],
        ]);
        $raw = @file_get_contents($url, false, $context);
        if ($raw === false) {
            $httpCode = 0;
            return [
                'ok' => false,
                'error' => 'http_request_failed',
                'message' => 'Cannot contact API endpoint.',
                'raw' => '',
            ];
        }
        $httpCode = 0;
        if (isset($http_response_header) && is_array($http_response_header)) {
            foreach ($http_response_header as $line) {
                if (preg_match('#^HTTP/\d+\.\d+\s+(\d{3})#', $line, $m)) {
                    $httpCode = (int)$m[1];
                    break;
                }
            }
        }
    }

    $decoded = json_decode((string)$raw, true);
    if (!is_array($decoded)) {
        return [
            'ok' => false,
            'error' => 'invalid_json_response',
            'message' => 'API returned non-JSON response.',
            'raw' => (string)$raw,
        ];
    }

    return [
        'ok' => true,
        'data' => $decoded,
        'raw' => (string)$raw,
    ];
}

if (!defined('REDDAXE_I18N_SUPPORTED')) {
    define('REDDAXE_I18N_SUPPORTED', ['pl', 'en']);
}
if (!defined('REDDAXE_I18N_DEFAULT')) {
    define('REDDAXE_I18N_DEFAULT', 'pl');
}
if (!defined('REDDAXE_I18N_FALLBACK')) {
    define('REDDAXE_I18N_FALLBACK', 'en');
}

function reddaxe_normalize_lang(string $raw): ?string
{
    $lang = strtolower(trim($raw));
    if ($lang === '') {
        return null;
    }
    if (str_contains($lang, '-')) {
        $lang = explode('-', $lang, 2)[0];
    }
    if (str_contains($lang, '_')) {
        $lang = explode('_', $lang, 2)[0];
    }

    return in_array($lang, REDDAXE_I18N_SUPPORTED, true) ? $lang : null;
}

function reddaxe_resolve_lang(): string
{
    $fromGet = isset($_GET['lang']) ? reddaxe_normalize_lang((string)$_GET['lang']) : null;
    $fromCookie = isset($_COOKIE['reddaxe_lang']) ? reddaxe_normalize_lang((string)$_COOKIE['reddaxe_lang']) : null;
    $fromHeader = null;

    $accept = (string)($_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? '');
    if ($accept !== '') {
        foreach (explode(',', $accept) as $part) {
            $candidate = reddaxe_normalize_lang($part);
            if ($candidate !== null) {
                $fromHeader = $candidate;
                break;
            }
        }
    }

    $selected = $fromGet ?? $fromCookie ?? $fromHeader ?? REDDAXE_I18N_DEFAULT;

    if ($fromGet !== null) {
        setcookie('reddaxe_lang', $selected, [
            'expires' => time() + 86400 * 365,
            'path' => '/',
            'secure' => (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off'),
            'httponly' => false,
            'samesite' => 'Lax',
        ]);
        $_COOKIE['reddaxe_lang'] = $selected;
    }

    return $selected;
}

function reddaxe_current_lang(): string
{
    return (string)($GLOBALS['REDDAXE_LANG'] ?? REDDAXE_I18N_DEFAULT);
}

function reddaxe_supported_langs(): array
{
    return REDDAXE_I18N_SUPPORTED;
}

function reddaxe_lang_switch_url(string $lang): string
{
    $normalized = reddaxe_normalize_lang($lang);
    if ($normalized === null) {
        $normalized = REDDAXE_I18N_DEFAULT;
    }

    $path = (string)($_SERVER['PHP_SELF'] ?? '/reddaxe/index.php');
    $query = $_GET;
    $query['lang'] = $normalized;
    $qs = http_build_query($query);

    return $path . ($qs === '' ? '' : ('?' . $qs));
}

function reddaxe_load_translations(string $lang): array
{
    $file = __DIR__ . '/i18n/' . $lang . '.php';
    if (!is_file($file)) {
        return [];
    }

    $data = require $file;
    return is_array($data) ? $data : [];
}

function reddaxe_i18n_value(array $dict, string $key): ?string
{
    return array_key_exists($key, $dict) && is_string($dict[$key]) ? (string)$dict[$key] : null;
}

function reddaxe_t(string $key, array $vars = []): string
{
    static $cache = [];
    $lang = reddaxe_current_lang();

    if (!isset($cache[$lang])) {
        $cache[$lang] = reddaxe_load_translations($lang);
    }
    if (!isset($cache[REDDAXE_I18N_FALLBACK])) {
        $cache[REDDAXE_I18N_FALLBACK] = reddaxe_load_translations(REDDAXE_I18N_FALLBACK);
    }

    $value = reddaxe_i18n_value($cache[$lang], $key);
    if ($value === null && $lang !== REDDAXE_I18N_FALLBACK) {
        $value = reddaxe_i18n_value($cache[REDDAXE_I18N_FALLBACK], $key);
    }
    if ($value === null) {
        $value = $key;
    }

    foreach ($vars as $name => $raw) {
        $value = str_replace('{' . $name . '}', (string)$raw, $value);
    }

    return $value;
}

/**
 * Start a shared session compatible with MyAAC.
 * Uses default PHPSESSID cookie and MyAAC's session save path
 * so that session data is shared between RedDAXE and MyAAC.
 */
function reddaxe_start_shared_session(): void
{
    if (session_status() === PHP_SESSION_ACTIVE) {
        return;
    }
    $sessDir = __DIR__ . '/../system/php_sessions';
    if (is_dir($sessDir)) {
        session_save_path($sessDir);
    }
    session_start();
}

/**
 * Fetch the raw password hash from the MyAAC accounts table.
 * This is needed so that the session value matches what MyAAC's login.php expects.
 */
function reddaxe_fetch_myaac_password_hash(int $accountId): ?string
{
    $configFile = __DIR__ . '/../config.local.php';
    if (!is_file($configFile)) {
        return null;
    }

    $config = [];
    require $configFile;

    $host = (string)($config['database_host'] ?? '127.0.0.1');
    $port = (int)($config['database_port'] ?? 3306);
    $user = (string)($config['database_user'] ?? '');
    $pass = (string)($config['database_password'] ?? '');
    $dbName = (string)($config['database_name'] ?? '');

    if ($user === '' || $dbName === '') {
        return null;
    }

    try {
        $pdo = new PDO(
            "mysql:host={$host};port={$port};dbname={$dbName};charset=utf8mb4",
            $user,
            $pass,
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_TIMEOUT => 5]
        );
        $stmt = $pdo->prepare('SELECT `password` FROM `accounts` WHERE `id` = :id LIMIT 1');
        $stmt->execute([':id' => $accountId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return is_array($row) ? (string)$row['password'] : null;
    } catch (\Throwable $e) {
        return null;
    }
}

$GLOBALS['REDDAXE_LANG'] = reddaxe_resolve_lang();
