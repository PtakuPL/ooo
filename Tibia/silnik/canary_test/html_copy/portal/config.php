<?php
/**
 * Portal RedDAXE.pl — konfiguracja.
 * Wspolny backend z API launchera (ta sama tabela accounts, ten sam .env).
 */
declare(strict_types=1);

// Zaladuj .env z katalogu API (wspolna konfiguracja)
$envPath = __DIR__ . '/../apik/v1/.env';
$ENV = [];
if (is_file($envPath)) {
    $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $eq = strpos($line, '=');
        if ($eq === false) continue;
        $k = trim(substr($line, 0, $eq));
        $v = trim(substr($line, $eq + 1));
        if ((str_starts_with($v, '"') && str_ends_with($v, '"')) ||
            (str_starts_with($v, "'") && str_ends_with($v, "'"))) {
            $v = substr($v, 1, -1);
        }
        $ENV[$k] = $v;
    }
}

// DB connection (PDO, ta sama baza co API)
function portalDb(): PDO {
    global $ENV;
    static $pdo = null;
    if ($pdo !== null) return $pdo;
    $host = $ENV['DB_HOST'] ?? '127.0.0.1';
    $port = $ENV['DB_PORT'] ?? '3306';
    $name = $ENV['DB_NAME'] ?? 'canaryaac';
    $user = $ENV['DB_USER'] ?? 'root';
    $pass = $ENV['DB_PASS'] ?? '';
    $dsn = "mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4";
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
    return $pdo;
}

// Branding
define('PORTAL_SITE_NAME', 'RedDAXE');
define('PORTAL_SITE_TITLE', 'RedDAXE — Gaming Portal');
define('PORTAL_VERSION', '0.1.0-pre');
define('PORTAL_I18N_SUPPORTED', ['pl', 'en']);
define('PORTAL_I18N_DEFAULT', 'pl');
define('PORTAL_I18N_FALLBACK', 'en');

// Allow-list redirectow (klucz => URL)
define('REDIRECT_ALLOW_LIST', [
    'www'   => $ENV['PORTAL_REDIRECT_WWW']   ?? 'https://127.0.0.1/',
    'forum' => $ENV['PORTAL_REDIRECT_FORUM'] ?? 'https://127.0.0.1/forum/',
    'wiki'  => $ENV['PORTAL_REDIRECT_WIKI']  ?? 'https://127.0.0.1/wiki/',
]);

// Zewnetrzne linki (allow-list slugow)
define('EXTERNAL_LINKS', [
    'tibia-fandom' => ['url' => 'https://tibia.fandom.com/', 'label' => 'Tibia Wiki (Fandom)'],
    'otland'       => ['url' => 'https://otland.net/',        'label' => 'OTLand Forum'],
]);

function portalNormalizeLang(string $raw): ?string {
    $lang = strtolower(trim($raw));
    if (str_contains($lang, '-')) {
        $lang = explode('-', $lang, 2)[0];
    }
    if (str_contains($lang, '_')) {
        $lang = explode('_', $lang, 2)[0];
    }
    return in_array($lang, PORTAL_I18N_SUPPORTED, true) ? $lang : null;
}

function portalResolveLang(): string {
    $fromGet = isset($_GET['lang']) ? portalNormalizeLang((string)$_GET['lang']) : null;
    $fromCookie = isset($_COOKIE['portal_lang']) ? portalNormalizeLang((string)$_COOKIE['portal_lang']) : null;
    $fromHeader = null;

    $accept = (string)($_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? '');
    if ($accept !== '') {
        foreach (explode(',', $accept) as $part) {
            $candidate = portalNormalizeLang($part);
            if ($candidate !== null) {
                $fromHeader = $candidate;
                break;
            }
        }
    }

    $selected = $fromGet ?? $fromCookie ?? $fromHeader ?? PORTAL_I18N_DEFAULT;

    if ($fromGet !== null) {
        setcookie('portal_lang', $selected, [
            'expires' => time() + 86400 * 365,
            'path' => '/',
            'secure' => (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off'),
            'httponly' => false,
            'samesite' => 'Lax',
        ]);
        $_COOKIE['portal_lang'] = $selected;
    }

    return $selected;
}

function portalCurrentLang(): string {
    return (string)($GLOBALS['PORTAL_LANG'] ?? PORTAL_I18N_DEFAULT);
}

function portalSupportedLangs(): array {
    return PORTAL_I18N_SUPPORTED;
}

function portalLangSwitchUrl(string $lang): string {
    $normalized = portalNormalizeLang($lang);
    if ($normalized === null) {
        $normalized = PORTAL_I18N_DEFAULT;
    }

    $path = (string)($_SERVER['PHP_SELF'] ?? '/portal/');
    $query = $_GET;
    $query['lang'] = $normalized;
    $qs = http_build_query($query);
    return $path . ($qs === '' ? '' : ('?' . $qs));
}

function portalLoadTranslations(string $lang): array {
    $file = __DIR__ . '/i18n/' . $lang . '.php';
    if (!is_file($file)) {
        return [];
    }
    $data = require $file;
    return is_array($data) ? $data : [];
}

function portalI18nValue(array $dict, string $key): ?string {
    return array_key_exists($key, $dict) && is_string($dict[$key]) ? (string)$dict[$key] : null;
}

function portalT(string $key, array $vars = []): string {
    static $cache = [];
    $lang = portalCurrentLang();

    if (!isset($cache[$lang])) {
        $cache[$lang] = portalLoadTranslations($lang);
    }
    if (!isset($cache[PORTAL_I18N_FALLBACK])) {
        $cache[PORTAL_I18N_FALLBACK] = portalLoadTranslations(PORTAL_I18N_FALLBACK);
    }

    $value = portalI18nValue($cache[$lang], $key);
    if ($value === null && $lang !== PORTAL_I18N_FALLBACK) {
        $value = portalI18nValue($cache[PORTAL_I18N_FALLBACK], $key);
    }
    if ($value === null) {
        $value = $key;
    }

    foreach ($vars as $name => $raw) {
        $value = str_replace('{' . $name . '}', (string)$raw, $value);
    }
    return $value;
}

$GLOBALS['PORTAL_LANG'] = portalResolveLang();

// CSRF
function portalCsrfToken(): string {
    if (session_status() !== PHP_SESSION_ACTIVE) {
        session_start();
    }
    if (empty($_SESSION['portal_csrf'])) {
        $_SESSION['portal_csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['portal_csrf'];
}

function portalCsrfCheck(): bool {
    if (session_status() !== PHP_SESSION_ACTIVE) {
        session_start();
    }
    $token = $_POST['csrf_token'] ?? '';
    return !empty($token) && hash_equals($_SESSION['portal_csrf'] ?? '', $token);
}
