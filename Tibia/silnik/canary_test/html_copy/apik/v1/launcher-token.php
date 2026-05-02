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

// FIX42+FIX43: Shared utilities (loadEnvFiles, sendError, sendLauncherError, json_out)
// launcher-token.php uses sendLauncherError() — Rust launcher contract format:
//   {"error": "error_code", "message": "human readable"}
require_once __DIR__ . '/common.php';
$requestStartedAt = microtime(true);

// FIX-AUD12: getClientIp() przeniesione do common.php z obsługą trusted proxy.
// Użycie: getClientIp($ENV) — wymaga TRUSTED_PROXIES w .env

/**
 * Porównaj wersje semantyczne (major.minor.patch).
 * Zwraca: -1 (a<b), 0 (a==b), 1 (a>b)
 */
function versionCompare(string $a, string $b): int {
    return version_compare($a, $b);
}

function playerManifestDenyPatterns(): array {
    return [
        '#(^|/)start_dev\.(sh|bat|cmd|ps1)$#i',
        '#(^|/)start_player\.(sh|bat|cmd|ps1)$#i',
        '#(^|/)serverlist\.(json|lua)$#i',
        '#(^|/)init_serverlist\.lua$#i',
        '#(^|/)otclientrc\.lua$#i',
        '#(^|/)otclientrc\.lua\.default$#i',
        '#(^|/)src/#',
        '#(^|/)tools/#',
        '#(^|/)docs/#',
        '#(^|/)tests/#',
        '#(^|/)serverSIDE(/|$)#i',
        '#(^|/)\.github/#',
        '#\.sh$#i',
        '#\.bat$#i',
        '#\.cmd$#i',
        '#\.ps1$#i',
        '#\.cpp$#i',
        '#\.c$#i',
        '#\.h$#i',
        '#\.hpp$#i',
        '#\.rs$#i',
        '#(^|/)Cargo\.(toml|lock)$#i',
        '#(^|/)CMakeLists\.txt$#i',
        '#(^|/)CMakeCache\.txt$#i',
        '#\.pdb$#i',
        '#\.ilk$#i',
        '#\.obj$#i',
        '#\.o$#i',
        '#\.lib$#i',
        '#\.a$#i',
        '#\.md$#i',
        '#\.patch$#i',
        '#\.orig$#i',
        '#\.bak$#i',
        '#\.bak\.[^/]+$#i',
        '#\.txt$#i',
        '#(^|/)README[^/]*$#i',
        '#(^|/)\.env(\.|$)#i',
        '#\.key$#i',
        '#\.secret$#i',
    ];
}

function blockedPlayerManifestPathsForVersion(string $channel, string $version): array {
    $manifestFile = __DIR__ . '/manifests/' . $channel . '/' . $version . '.json';
    if (!is_file($manifestFile)) {
        return ['__manifest_json_missing__:' . $channel . '/' . $version];
    }

    $manifest = json_decode((string)file_get_contents($manifestFile), true);
    if (!is_array($manifest)) {
        return ['__manifest_json_invalid__:' . $channel . '/' . $version];
    }

    $blocked = [];
    $patterns = playerManifestDenyPatterns();
    foreach (($manifest['files'] ?? []) as $file) {
        $path = is_array($file) ? (string)($file['path'] ?? '') : '';
        if ($path === '') {
            continue;
        }
        foreach ($patterns as $pattern) {
            if (preg_match($pattern, $path)) {
                $blocked[] = $path;
                break;
            }
        }
    }
    sort($blocked);
    return $blocked;
}

function rejectIfPlayerManifestBlocked(string $channel, string $version, array $ENV, string $ipHash, float $requestStartedAt): void {
    if (($ENV['ALLOW_DEV_CLIENT_MANIFEST'] ?? '') === '1') {
        return;
    }

    $blockedPaths = blockedPlayerManifestPathsForVersion($channel, $version);
    if ($blockedPaths === []) {
        return;
    }

    error_log('[launcher-token.php] blocked dirty player manifest channel=' . $channel . ' version=' . $version . ' paths=' . implode(',', array_slice($blockedPaths, 0, 20)));
    logTicketEvent('launcher_token.rejected.manifest_blocked', [
        'endpoint' => 'launcher-token.php',
        'ipHash' => $ipHash,
        'manifestVersion' => $version,
        'channel' => $channel,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendLauncherError('manifest_blocked', 'Client manifest is blocked because it contains non-player files. Update will be available after clean client package deploy.', 503);
}

// ------- read request -------
$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    logTicketEvent('launcher_token.rejected.invalid_json', [
        'endpoint' => 'launcher-token.php',
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ]);
    sendLauncherError('missing_fields', 'Invalid JSON request.', 400);
}

$launcherVersion = isset($req['launcherVersion']) ? trim((string)$req['launcherVersion']) : '';
$filesHash       = isset($req['filesHash'])       ? trim((string)$req['filesHash']) : '';
$manifestVersion = isset($req['manifestVersion'])  ? trim((string)$req['manifestVersion']) : '';
$nonce           = isset($req['nonce']) ? trim((string)$req['nonce']) : '';
$challengeResponse = isset($req['challengeResponse']) ? trim((string)$req['challengeResponse']) : '';

if ($launcherVersion === '' || $filesHash === '') {
    logTicketEvent('launcher_token.rejected.missing_fields', [
        'endpoint' => 'launcher-token.php',
        'hasLauncherVersion' => $launcherVersion !== '',
        'hasFilesHash' => $filesHash !== '',
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ]);
    sendLauncherError('missing_fields', 'Missing required fields: launcherVersion, filesHash.', 400);
}

// ------- config -------
$ENV = loadEnvFiles([__DIR__ . '/.env']);

$minVersion    = $ENV['LAUNCHER_MIN_VERSION'] ?? '1.0.0';
$tokenTtl      = isset($ENV['LAUNCH_TOKEN_TTL']) ? (int)$ENV['LAUNCH_TOKEN_TTL'] : 300;
$rateLimit     = isset($ENV['LAUNCH_TOKEN_RATE_LIMIT']) ? (int)$ENV['LAUNCH_TOKEN_RATE_LIMIT'] : 5;
$requireChallenge = filter_var($ENV['CHALLENGE_REQUIRED'] ?? false, FILTER_VALIDATE_BOOLEAN);

// ------- version check -------
if (versionCompare($launcherVersion, $minVersion) < 0) {
    logTicketEvent('launcher_token.rejected.version_too_old', [
        'endpoint' => 'launcher-token.php',
        'launcherVersion' => $launcherVersion,
        'minVersion' => $minVersion,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendLauncherError('launcher_version_rejected', "Launcher version {$launcherVersion} is too old. Minimum: {$minVersion}. Please update your launcher.", 403);
}

// ------- DB (F1: multi-DB — all tables here are API_DB) -------
try {
    $apiDb = getApiDb($ENV);
} catch (\Exception $e) {
    logTicketEvent('launcher_token.rejected.db_connect_failed', [
        'endpoint' => 'launcher-token.php',
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendLauncherError('internal_error', 'Database connection failed.', 500);
}

$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);
$now = time();

// ------- rate-limit: max N tokenów/min per IP -------
$stmt = $apiDb->prepare(
    "SELECT COUNT(*) AS cnt FROM launch_tokens WHERE client_ip = ? AND created_at > DATE_SUB(NOW(), INTERVAL 1 MINUTE)"
);
$stmt->execute([$clientIp]);
$res = $stmt->fetch();

if ((int)$res['cnt'] >= $rateLimit) {
    logTicketEvent('launcher_token.rejected.rate_limited', [
        'endpoint' => 'launcher-token.php',
        'ipHash' => $ipHash,
        'rateLimit' => $rateLimit,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendLauncherError('rate_limited', "Rate limit exceeded. Max {$rateLimit} tokens per minute.", 429);
}

// ------- filesHash verification -------
// FIX12: fail-closed — gdy manifestVersion jest pusty, sprawdź filesHash
//        przeciwko NAJNOWSZEMU aktywnemu manifestowi. Nie pozwalaj na bypass.
// FIX-AUD5: fail-closed gdy manifestVersion podany ale nie istnieje w DB
// FIX-AUD13: query uwzględnia channel (unique key = version+channel)
$requestChannel = isset($req['channel']) ? trim((string)$req['channel']) : 'stable';

// Q-02: Whitelist kanałów — tylko znane wartości
$allowedChannels = ['stable', 'beta', 'dev'];
if (!in_array($requestChannel, $allowedChannels, true)) {
    logTicketEvent('launcher_token.rejected.invalid_channel', [
        'endpoint' => 'launcher-token.php',
        'channel' => $requestChannel,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendLauncherError('invalid_channel', 'Invalid channel. Allowed: ' . implode(', ', $allowedChannels), 400);
}

if ($manifestVersion !== '') {
    // Sprawdź czy filesHash zgadza się z oczekiwanym hashem z manifest_versions
    // FIX-AUD13: dodano channel do WHERE — schema ma UNIQUE(version, channel)
    $stmt = $apiDb->prepare(
        "SELECT version, files_hash FROM manifest_versions WHERE version = ? AND channel = ? AND is_active = 1 LIMIT 1"
    );
    $stmt->execute([$manifestVersion, $requestChannel]);
    $mv = $stmt->fetch();

    if ($mv) {
        if ($mv['files_hash'] !== $filesHash) {
            // Sprawdź previous version (grace period) — w tym samym kanale
            // FIX-AUD13: grace period query też filtruje po channel
            $stmt2 = $apiDb->prepare(
                "SELECT version, files_hash FROM manifest_versions WHERE channel = ? AND is_active = 1 ORDER BY id DESC LIMIT 2"
            );
            $stmt2->execute([$requestChannel]);
            $accepted = false;
            $acceptedVersion = '';
            while ($row = $stmt2->fetch()) {
                if ($row['files_hash'] === $filesHash) {
                    $accepted = true;
                    $acceptedVersion = (string)$row['version'];
                    break;
                }
            }

            if (!$accepted) {
                logTicketEvent('launcher_token.rejected.files_hash_mismatch', [
                    'endpoint' => 'launcher-token.php',
                    'ipHash' => $ipHash,
                    'manifestVersion' => $manifestVersion,
                    'channel' => $requestChannel,
                    'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
                ], $ENV);
                sendLauncherError('files_hash_mismatch', 'Client files hash mismatch. Pliki klienta nie pasują do oczekiwanych. Zrestartuj launcher.', 403);
            }
            rejectIfPlayerManifestBlocked($requestChannel, $acceptedVersion, $ENV, $ipHash, $requestStartedAt);
        } else {
            rejectIfPlayerManifestBlocked($requestChannel, (string)$mv['version'], $ENV, $ipHash, $requestStartedAt);
        }
    } else {
        // FIX-AUD5: manifestVersion podany ale nie istnieje w DB → FAIL-CLOSED
        // Nie przepuszczamy — klient twierdzi że ma wersję której nie znamy
        error_log("[launcher-token.php] FIX-AUD5 BLOCKED: manifestVersion '{$manifestVersion}' channel '{$requestChannel}' not found in manifest_versions.");
        logTicketEvent('launcher_token.rejected.manifest_version_unknown', [
            'endpoint' => 'launcher-token.php',
            'ipHash' => $ipHash,
            'manifestVersion' => $manifestVersion,
            'channel' => $requestChannel,
            'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
        ], $ENV);
        sendLauncherError('manifest_version_expired', 'Unknown manifest version. Please update your client.', 403);
    }
} else {
    // FIX12: manifestVersion jest pusty — sprawdź filesHash przeciwko najnowszemu aktywnemu manifestowi
    // FIX-AUD13: filtruj po kanale klienta
    $stmt = $apiDb->prepare(
        "SELECT version, files_hash FROM manifest_versions WHERE channel = ? AND is_active = 1 ORDER BY id DESC LIMIT 2"
    );
    $stmt->execute([$requestChannel]);
    $rows = $stmt->fetchAll();

    if (count($rows) > 0) {
        // Mamy aktywne manifesty — filesHash MUSI pasować do jednego z nich
        $accepted = false;
        $acceptedVersion = '';
        foreach ($rows as $row) {
            if ($row['files_hash'] === $filesHash) {
                $accepted = true;
                $acceptedVersion = (string)$row['version'];
                break;
            }
        }

        if (!$accepted) {
            logTicketEvent('launcher_token.rejected.files_hash_mismatch', [
                'endpoint' => 'launcher-token.php',
                'ipHash' => $ipHash,
                'manifestVersion' => $manifestVersion !== '' ? $manifestVersion : 'none',
                'channel' => $requestChannel,
                'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
            ], $ENV);
            sendLauncherError('files_hash_mismatch', 'Client files hash mismatch (no manifest version provided). Update your launcher.', 403);
        }
        rejectIfPlayerManifestBlocked($requestChannel, $acceptedVersion, $ENV, $ipHash, $requestStartedAt);
    } else {
        // FIX21: Brak aktywnych manifestów w DB → FAIL-CLOSED.
        // Nie przepuszczamy bez weryfikacji — admin musi dodać manifest do DB.
        // Użyj: php generate_manifest.php aby wygenerować manifest.
        error_log('[launcher-token.php] FIX21 BLOCKED: No active manifest_versions in DB. Cannot verify filesHash. Add manifest first.');
        logTicketEvent('launcher_token.rejected.no_active_manifest', [
            'endpoint' => 'launcher-token.php',
            'ipHash' => $ipHash,
            'channel' => $requestChannel,
            'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
        ], $ENV);
        sendLauncherError('internal_error', 'Server configuration error: no manifest available. Contact administrator.', 500);
    }
}

// ------- optional/required challenge-response verification -------
if ($requireChallenge || $nonce !== '' || $challengeResponse !== '') {
    if ($nonce === '' || $challengeResponse === '') {
        logTicketEvent('launcher_token.rejected.challenge_missing_fields', [
            'endpoint' => 'launcher-token.php',
            'ipHash' => $ipHash,
            'challengeRequired' => $requireChallenge,
            'hasNonce' => $nonce !== '',
            'hasChallengeResponse' => $challengeResponse !== '',
            'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
        ], $ENV);
        sendLauncherError('challenge_required', 'Challenge nonce/response required.', 403);
    }

    $normalizedNonce = strtolower($nonce);
    $normalizedResponse = strtolower($challengeResponse);

    if (strlen($normalizedNonce) < 32 || !ctype_xdigit($normalizedNonce)) {
        logTicketEvent('launcher_token.rejected.challenge_nonce_invalid', [
            'endpoint' => 'launcher-token.php',
            'ipHash' => $ipHash,
            'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
        ], $ENV);
        sendLauncherError('challenge_invalid', 'Invalid challenge nonce format.', 403);
    }

    if (strlen($normalizedResponse) !== 64 || !ctype_xdigit($normalizedResponse)) {
        logTicketEvent('launcher_token.rejected.challenge_response_invalid_format', [
            'endpoint' => 'launcher-token.php',
            'ipHash' => $ipHash,
            'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
        ], $ENV);
        sendLauncherError('challenge_invalid', 'Invalid challenge response format.', 403);
    }

    $stmt = $apiDb->prepare(
        "SELECT expires_at FROM ticket_nonces WHERE nonce = ? AND account_id = 0 LIMIT 1"
    );
    $stmt->execute([$normalizedNonce]);
    $nonceRow = $stmt->fetch();

    if (!$nonceRow) {
        logTicketEvent('launcher_token.rejected.challenge_nonce_unknown', [
            'endpoint' => 'launcher-token.php',
            'ipHash' => $ipHash,
            'nonceHash' => substr(hash('sha256', $normalizedNonce), 0, 12),
            'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
        ], $ENV);
        sendLauncherError('challenge_invalid', 'Challenge nonce invalid or already used.', 403);
    }

    if ((int)$nonceRow['expires_at'] < $now) {
        $delExpired = $apiDb->prepare(
            "DELETE FROM ticket_nonces WHERE nonce = ? AND account_id = 0"
        );
        $delExpired->execute([$normalizedNonce]);

        logTicketEvent('launcher_token.rejected.challenge_expired', [
            'endpoint' => 'launcher-token.php',
            'ipHash' => $ipHash,
            'nonceHash' => substr(hash('sha256', $normalizedNonce), 0, 12),
            'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
        ], $ENV);
        sendLauncherError('challenge_expired', 'Challenge has expired. Request a new challenge.', 403);
    }

    $expectedResponse = hash('sha256', $normalizedNonce . ':' . $filesHash);
    if (!hash_equals($expectedResponse, $normalizedResponse)) {
        logTicketEvent('launcher_token.rejected.challenge_response_mismatch', [
            'endpoint' => 'launcher-token.php',
            'ipHash' => $ipHash,
            'nonceHash' => substr(hash('sha256', $normalizedNonce), 0, 12),
            'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
        ], $ENV);
        sendLauncherError('challenge_invalid', 'Challenge response mismatch.', 403);
    }

    $del = $apiDb->prepare(
        "DELETE FROM ticket_nonces WHERE nonce = ? AND account_id = 0"
    );
    $del->execute([$normalizedNonce]);

    logTicketEvent('launcher_token.challenge_validated', [
        'endpoint' => 'launcher-token.php',
        'ipHash' => $ipHash,
        'nonceHash' => substr(hash('sha256', $normalizedNonce), 0, 12),
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
}

// ------- generate token -------
$token = bin2hex(random_bytes(32)); // 64-char hex UUID
$expiresAt = date('Y-m-d H:i:s', $now + $tokenTtl);

$stmt = $apiDb->prepare(
    "INSERT INTO launch_tokens (token, launcher_version, files_hash, manifest_version, client_ip, expires_at)
     VALUES (?, ?, ?, ?, ?, ?)"
);
$mvStr = $manifestVersion !== '' ? $manifestVersion : '0.0.0';
$stmt->execute([$token, $launcherVersion, $filesHash, $mvStr, $clientIp, $expiresAt]);

// ------- cleanup expired tokens (okazyjnie ~10% requestów) -------
if (mt_rand(1, 10) === 1) {
    $apiDb->exec("DELETE FROM launch_tokens WHERE expires_at < NOW()");
}

logTicketEvent('launcher_token.issued', [
    'endpoint' => 'launcher-token.php',
    'ipHash' => $ipHash,
    'channel' => $requestChannel,
    'manifestVersion' => $mvStr,
    'launcherVersion' => $launcherVersion,
    'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
], $ENV);

echo json_encode([
    'token'            => $token,
    'expiresInSeconds'  => $tokenTtl,
], JSON_UNESCAPED_SLASHES);
