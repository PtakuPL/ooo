<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * E3: POST /api/launcher-token.php — Wydaje jednorazowy launch-token.
 *
 * Request JSON:
 *   {
 *     "launcherVersion": "1.0.0",
 *     "filesHash": "sha256_hex",
 *     "clientVersion": "1.0.0",
 *     "manifestVersion": "1.0.0"
 *   }
 *
 * Weryfikacja:
 *   1. launcherVersion >= LAUNCHER_MIN_VERSION
 *   2. filesHash === oczekiwany hash z manifest_versions (dla danej wersji)
 *   3. Rate-limit: max N tokenów/min per IP
 *
 * Odpowiedź:
 *   {"launchToken": "uuid-64-hex", "expiresIn": 300}
 *
 * Token jest wiązany z IP klienta (IP-binding).
 * Konsumowany atomowo przez login.php (SELECT FOR UPDATE + DELETE).
 */

// ------- utils -------
function sendError(string $msg, int $code = 200): void {
    http_response_code($code);
    echo json_encode(['error' => $msg], JSON_UNESCAPED_SLASHES);
    exit;
}

function loadEnvFiles(array $paths): array {
    $env = [];
    foreach ($paths as $path) {
        if (!is_file($path)) continue;
        $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
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
            $env[$k] = $v;
        }
    }
    return $env;
}

/**
 * Pobierz prawdziwe IP klienta (obsługa reverse proxy).
 * Dla dev/local: po prostu REMOTE_ADDR.
 */
function getClientIp(): string {
    // W produkcji z Cloudflare/nginx: użyj CF-Connecting-IP lub X-Forwarded-For
    // z whitelistą trusted proxies (patrz plan sekcja 16.3)
    return $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
}

/**
 * Porównaj wersje semantyczne (major.minor.patch).
 * Zwraca: -1 (a<b), 0 (a==b), 1 (a>b)
 */
function versionCompare(string $a, string $b): int {
    return version_compare($a, $b);
}

// ------- read request -------
$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    sendError('Invalid JSON request.');
}

$launcherVersion = isset($req['launcherVersion']) ? trim((string)$req['launcherVersion']) : '';
$filesHash       = isset($req['filesHash'])       ? trim((string)$req['filesHash']) : '';
$manifestVersion = isset($req['manifestVersion'])  ? trim((string)$req['manifestVersion']) : '';

if ($launcherVersion === '' || $filesHash === '') {
    sendError('Missing required fields: launcherVersion, filesHash.');
}

// ------- config -------
$ENV = loadEnvFiles([__DIR__ . '/.env']);

$minVersion    = $ENV['LAUNCHER_MIN_VERSION'] ?? '1.0.0';
$tokenTtl      = isset($ENV['LAUNCH_TOKEN_TTL']) ? (int)$ENV['LAUNCH_TOKEN_TTL'] : 300;
$rateLimit     = isset($ENV['LAUNCH_TOKEN_RATE_LIMIT']) ? (int)$ENV['LAUNCH_TOKEN_RATE_LIMIT'] : 5;

// ------- version check -------
if (versionCompare($launcherVersion, $minVersion) < 0) {
    sendError("Launcher version {$launcherVersion} is too old. Minimum: {$minVersion}. Please update your launcher.");
}

// ------- DB -------
$dbhost = $ENV['DB_HOST'] ?? '127.0.0.1';
$dbuser = $ENV['DB_USER'] ?? 'ptaku';
$dbpass = $ENV['DB_PASS'] ?? '12345678';
$dbname = $ENV['DB_NAME'] ?? 'canaryaac';
$dbport = isset($ENV['DB_PORT']) ? (int)$ENV['DB_PORT'] : 3306;

$mysqli = @new mysqli($dbhost, $dbuser, $dbpass, $dbname, $dbport);
if ($mysqli->connect_errno) {
    sendError('Database connection failed.');
}
$mysqli->set_charset('utf8mb4');

$clientIp = getClientIp();
$now = time();

// ------- rate-limit: max N tokenów/min per IP -------
$stmt = $mysqli->prepare(
    "SELECT COUNT(*) AS cnt FROM launch_tokens WHERE client_ip = ? AND created_at > DATE_SUB(NOW(), INTERVAL 1 MINUTE)"
);
$stmt->bind_param('s', $clientIp);
$stmt->execute();
$res = $stmt->get_result()->fetch_assoc();
$stmt->close();

if ((int)$res['cnt'] >= $rateLimit) {
    sendError("Rate limit exceeded. Max {$rateLimit} tokens per minute.");
}

// ------- filesHash verification -------
// FIX12: fail-closed — gdy manifestVersion jest pusty, sprawdź filesHash
//        przeciwko NAJNOWSZEMU aktywnemu manifestowi. Nie pozwalaj na bypass.
if ($manifestVersion !== '') {
    // Sprawdź czy filesHash zgadza się z oczekiwanym hashem z manifest_versions
    $stmt = $mysqli->prepare(
        "SELECT files_hash FROM manifest_versions WHERE version = ? AND is_active = 1 LIMIT 1"
    );
    $stmt->bind_param('s', $manifestVersion);
    $stmt->execute();
    $mvRes = $stmt->get_result();

    if ($mvRes->num_rows > 0) {
        $mv = $mvRes->fetch_assoc();
        if ($mv['files_hash'] !== $filesHash) {
            $stmt->close();
            // Sprawdź previous version (grace period)
            $stmt2 = $mysqli->prepare(
                "SELECT files_hash FROM manifest_versions WHERE channel = 'stable' AND is_active = 1 ORDER BY id DESC LIMIT 2"
            );
            $stmt2->execute();
            $acceptedRes = $stmt2->get_result();
            $accepted = false;
            while ($row = $acceptedRes->fetch_assoc()) {
                if ($row['files_hash'] === $filesHash) {
                    $accepted = true;
                    break;
                }
            }
            $stmt2->close();

            if (!$accepted) {
                sendError('Client files hash mismatch. Pliki klienta nie pasują do oczekiwanych. Zrestartuj launcher.');
            }
        }
    }
    $stmt->close();
} else {
    // FIX12: manifestVersion jest pusty — sprawdź filesHash przeciwko najnowszemu aktywnemu manifestowi
    $stmt = $mysqli->prepare(
        "SELECT files_hash FROM manifest_versions WHERE channel = 'stable' AND is_active = 1 ORDER BY id DESC LIMIT 2"
    );
    $stmt->execute();
    $mvRes = $stmt->get_result();

    if ($mvRes->num_rows > 0) {
        // Mamy aktywne manifesty — filesHash MUSI pasować do jednego z nich
        $accepted = false;
        while ($row = $mvRes->fetch_assoc()) {
            if ($row['files_hash'] === $filesHash) {
                $accepted = true;
                break;
            }
        }
        $stmt->close();

        if (!$accepted) {
            sendError('Client files hash mismatch (no manifest version provided). Update your launcher.');
        }
    } else {
        // FIX21: Brak aktywnych manifestów w DB → FAIL-CLOSED.
        // Nie przepuszczamy bez weryfikacji — admin musi dodać manifest do DB.
        // Użyj: php generate_manifest.php aby wygenerować manifest.
        $stmt->close();
        error_log('[launcher-token.php] FIX21 BLOCKED: No active manifest_versions in DB. Cannot verify filesHash. Add manifest first.');
        sendError('Server configuration error: no manifest available. Contact administrator.');
    }
}

// ------- generate token -------
$token = bin2hex(random_bytes(32)); // 64-char hex UUID
$expiresAt = date('Y-m-d H:i:s', $now + $tokenTtl);

$stmt = $mysqli->prepare(
    "INSERT INTO launch_tokens (token, launcher_version, files_hash, manifest_version, client_ip, expires_at)
     VALUES (?, ?, ?, ?, ?, ?)"
);
$mvStr = $manifestVersion !== '' ? $manifestVersion : '0.0.0';
$stmt->bind_param('ssssss', $token, $launcherVersion, $filesHash, $mvStr, $clientIp, $expiresAt);
$stmt->execute();
$stmt->close();

// ------- cleanup expired tokens (okazyjnie ~10% requestów) -------
if (mt_rand(1, 10) === 1) {
    $mysqli->query("DELETE FROM launch_tokens WHERE expires_at < NOW()");
}

$mysqli->close();

echo json_encode([
    'launchToken' => $token,
    'expiresIn'   => $tokenTtl,
], JSON_UNESCAPED_SLASHES);
