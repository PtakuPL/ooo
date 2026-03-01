<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * /api/v1/login.php — standalone login endpoint for OTClient/Canary
 * (bez zależności od MyAAC).
 *
 * B1: Obsługuje opcjonalny parametr `gameMode` z requestu klienta.
 * B2: Filtruje listę worldów wg gameMode (classic74 → tylko world classic74, modern → modern).
 *     Zapisuje sesję z gameMode do tabeli `ticket_sessions` (do użycia przez ticket.php).
 *
 * - Czyta konfigurację DB z .env (najpierw /var/www/html/api/v1/.env, potem /var/www/html/.env).
 * - Weryfikuje hasło:
 *      • jeśli w DB jest 40-znakowy hex (SHA1) → porównanie case-insensitive (lower/UPPER)
 *      • w innym wypadku dopuszcza tryb plain (==)
 * - Tworzy sesję z losowym kluczem (UUID) zamiast account\npassword
 * - Buduje listę postaci i dane świata (filtrowane wg gameMode).
 */

// ------- utils -------
function sendError(string $msg, int $code = 200): void {
    http_response_code($code); // OTClient oczekuje 200 nawet dla błędów
    echo json_encode(['errorCode' => 3, 'errorMessage' => $msg], JSON_UNESCAPED_SLASHES);
    exit;
}

function json_out($data, int $code = 200): void {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_SLASHES);
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
 * B2: Konfiguracja worldów per gameMode.
 * Każdy gameMode może mieć inny zestaw worldów (inne IP, port, nazwa).
 * Domyślnie: jeden world "Local" z .env WORLD_IP/WORLD_PORT.
 */
function getWorldsForGameMode(string $gameMode, array $ENV): array {
    // World wspólne pola template
    $defaultWorld = function(int $id, string $name, string $ip, int $port): array {
        return [
            'id'                         => $id,
            'name'                       => $name,
            'externaladdress'            => $ip,
            'externaladdressprotected'   => $ip,
            'externaladdressunprotected' => $ip,
            'externalport'               => $port,
            'externalportprotected'      => $port,
            'externalportunprotected'    => $port,
            'previewstate'               => 0,
            'location'                   => 'EUR',
            'anticheatprotection'        => false,
            'pvptype'                    => 0,
            'anticheatprotectiontournament' => false,
            'pvp_type'                   => 0,
            'battleye_protected'         => false,
            'worldstatus'                => 'online',
        ];
    };

    // Konfiguracja per gameMode — rozszerzalna.
    // Docelowo z bazy/pliku config, na razie z .env.
    $worldIp   = $ENV['WORLD_IP']   ?? '127.0.0.1';
    $worldPort = isset($ENV['WORLD_PORT']) ? (int)$ENV['WORLD_PORT'] : 7172;

    // B2: Classic74 i Modern mogą mieć osobne porty/IP
    $classic74Ip   = $ENV['WORLD_CLASSIC74_IP']   ?? $worldIp;
    $classic74Port = isset($ENV['WORLD_CLASSIC74_PORT']) ? (int)$ENV['WORLD_CLASSIC74_PORT'] : $worldPort;
    $modernIp      = $ENV['WORLD_MODERN_IP']      ?? $worldIp;
    $modernPort    = isset($ENV['WORLD_MODERN_PORT']) ? (int)$ENV['WORLD_MODERN_PORT'] : $worldPort;

    switch ($gameMode) {
        case 'classic74':
            return [$defaultWorld(0, 'Classic 7.4', $classic74Ip, $classic74Port)];
        case 'modern':
            return [$defaultWorld(1, 'Modern', $modernIp, $modernPort)];
        default:
            // Brak gameMode (stary klient) → oba worldy
            return [
                $defaultWorld(0, 'Classic 7.4', $classic74Ip, $classic74Port),
                $defaultWorld(1, 'Modern', $modernIp, $modernPort),
            ];
    }
}

// ------- read request -------
$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
$action = is_array($req) && isset($req['type']) ? (string)$req['type'] : 'login';

if ($action !== 'login') {
    sendError("Unrecognized event {$action}.");
}

$email = isset($req['email']) ? trim((string)$req['email']) : '';
$plain = isset($req['password']) ? (string)$req['password'] : '';
if ($email === '' || $plain === '') {
    sendError('Email or password is empty.');
}

// B1: Opcjonalny gameMode z klienta (classic74 / modern / brak)
$gameMode = isset($req['gameMode']) ? trim((string)$req['gameMode']) : '';
$validModes = ['classic74', 'modern', ''];
if (!in_array($gameMode, $validModes, true)) {
    sendError('Invalid gameMode: ' . $gameMode);
}

// ------- DB config -------
$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env', // /var/www/html/.env
]);

$dbhost = $ENV['DB_HOST'] ?? '127.0.0.1';
$dbuser = $ENV['DB_USER'] ?? 'ptaku';
$dbpass = $ENV['DB_PASS'] ?? '12345678';
$dbname = $ENV['DB_NAME'] ?? 'canaryaac';
$dbport = isset($ENV['DB_PORT']) ? (int)$ENV['DB_PORT'] : 3306;

$sessionTtl = isset($ENV['SESSION_TTL']) ? (int)$ENV['SESSION_TTL'] : 1800; // 30 min

// ------- connect -------
$mysqli = @new mysqli($dbhost, $dbuser, $dbpass, $dbname, $dbport);
if ($mysqli->connect_errno) {
    sendError('Database connection failed.');
}
$mysqli->set_charset('utf8mb4');

// ------- fetch account by email -------
$stmt = $mysqli->prepare("SELECT id, name, password FROM accounts WHERE email = ? LIMIT 1");
$stmt->bind_param('s', $email);
$stmt->execute();
$res = $stmt->get_result();
if ($res->num_rows === 0) {
    sendError('Email or password is not correct.');
}
$acc = $res->fetch_assoc();
$stmt->close();

// ------- password check (case-insensitive for SHA1 hex) -------
$stored = (string)$acc['password'];
$ok = false;
if (strlen($stored) === 40 && ctype_xdigit($stored)) {
    $ok = hash_equals(strtolower($stored), strtolower(sha1($plain)));
} else {
    $ok = hash_equals($stored, $plain);
}
if (!$ok) {
    sendError('Email or password is not correct.');
}

// ============================================================
// E11: LaunchToken validation — klient musi przejść przez launcher
// Launcher pobiera token z launcher-token.php i przekazuje go przez env OTC_LAUNCH_TOKEN.
// Klient dołącza token do JSON body logowania (E10).
// Jeden token = jedno logowanie (one-time use, atomowa konsumpcja).
// ============================================================
$launchToken = isset($req['launchToken']) ? trim((string)$req['launchToken']) : '';
$clientLocked = ($ENV['CLIENT_LOCKED'] ?? 'false') === 'true';

if ($clientLocked) {
    if ($launchToken === '') {
        sendError('Launch token required. Please use the official launcher.');
    }

    $clientIp = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
    $now = time();

    // Atomowa walidacja + konsumpcja tokenu (SELECT FOR UPDATE + DELETE w transakcji)
    $mysqli->begin_transaction();
    try {
        $stmt = $mysqli->prepare(
            "SELECT token, client_ip, expires_at, files_hash FROM launch_tokens WHERE token = ? FOR UPDATE"
        );
        $stmt->bind_param('s', $launchToken);
        $stmt->execute();
        $tokenRes = $stmt->get_result();

        if ($tokenRes->num_rows === 0) {
            $stmt->close();
            $mysqli->rollback();
            sendError('Invalid launch token. Please restart the launcher.');
        }

        $tokenRow = $tokenRes->fetch_assoc();
        $stmt->close();

        // Sprawdź wygaśnięcie (expires_at jest TIMESTAMP/datetime w MySQL)
        if (strtotime($tokenRow['expires_at']) < $now) {
            $delStmt = $mysqli->prepare("DELETE FROM launch_tokens WHERE token = ?");
            $delStmt->bind_param('s', $launchToken);
            $delStmt->execute();
            $delStmt->close();
            $mysqli->commit();
            sendError('Launch token expired. Please restart the launcher.');
        }

        // Sprawdź IP (token przypisany do IP, z którego launcher go pobrał)
        if ($tokenRow['client_ip'] !== $clientIp) {
            $mysqli->rollback();
            sendError('Launch token IP mismatch. Do not share tokens.');
        }

        // Opcjonalnie: sprawdź files_hash (integralność plików klienta)
        $expectedHash = $ENV['EXPECTED_FILES_HASH'] ?? '';
        if ($expectedHash !== '' && $tokenRow['files_hash'] !== $expectedHash) {
            $delStmt = $mysqli->prepare("DELETE FROM launch_tokens WHERE token = ?");
            $delStmt->bind_param('s', $launchToken);
            $delStmt->execute();
            $delStmt->close();
            $mysqli->commit();
            sendError('Client files integrity check failed. Please update your client.');
        }

        // Konsumuj: one-time use — usuń token
        $delStmt = $mysqli->prepare("DELETE FROM launch_tokens WHERE token = ?");
        $delStmt->bind_param('s', $launchToken);
        $delStmt->execute();
        $delStmt->close();
        $mysqli->commit();
    } catch (\Exception $e) {
        $mysqli->rollback();
        sendError('Token validation error.');
    }
}

// ------- characters -------
$chars = [];
$stmt = $mysqli->prepare("SELECT name, level, sex, vocation, looktype, lookhead, lookbody, looklegs, lookfeet, lookaddons, lastlogin
                          FROM players WHERE account_id = ? AND deletion = 0 ORDER BY name");
$stmt->bind_param('i', $acc['id']);
$stmt->execute();
$r = $stmt->get_result();

// B2: Przypisz worldid na podstawie gameMode
$worldId = ($gameMode === 'classic74') ? 0 : (($gameMode === 'modern') ? 1 : 0);
while ($p = $r->fetch_assoc()) {
    $chars[] = [
        'worldid'     => $worldId,
        'name'        => $p['name'],
        'ismale'      => ((int)$p['sex'] === 1),
        'vocation'    => (int)$p['vocation'],
        'level'       => (int)$p['level'],
        'outfitid'    => (int)$p['looktype'],
        'headcolor'   => (int)$p['lookhead'],
        'torsocolor'  => (int)$p['lookbody'],
        'legscolor'   => (int)$p['looklegs'],
        'detailcolor' => (int)$p['lookfeet'],
        'addonsflags' => (int)$p['lookaddons'],
        'istutorial'  => false,
        'lastlogin'   => (int)$p['lastlogin'],
    ];
}
$stmt->close();

// ------- B2: worlds (filtered by gameMode) -------
$worlds = getWorldsForGameMode($gameMode, $ENV);

$playdata = ['worlds' => $worlds, 'characters' => $chars];

// ------- B1: session z kluczem UUID + zapis do ticket_sessions -------
// Generujemy losowy session key (NIE account\npassword — bezpieczniejsze).
// Stary format (account\npassword) nadal potrzebny jako fallback dla sessionkey
// w OTClient protocolgame — ale to ticket.php generuje ticket z HMAC.
$sessionUuid = bin2hex(random_bytes(32)); // 64-znakowy hex

// Zapisz sesję do bazy (ticket.php będzie weryfikować)
$expiresAt = time() + $sessionTtl;
$stmt = $mysqli->prepare(
    "INSERT INTO ticket_sessions (session_key, account_id, game_mode, expires_at)
     VALUES (?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE account_id = VALUES(account_id), game_mode = VALUES(game_mode), expires_at = VALUES(expires_at)"
);
$accountId = (int)$acc['id'];
$gameModeDb = $gameMode !== '' ? $gameMode : 'modern'; // domyślnie modern
$stmt->bind_param('sisi', $sessionUuid, $accountId, $gameModeDb, $expiresAt);
$stmt->execute();
$stmt->close();

// Cleanup: usuń wygasłe sesje (okazyjnie, co ~10% requestów)
if (mt_rand(1, 10) === 1) {
    $now = time();
    $mysqli->query("DELETE FROM ticket_sessions WHERE expires_at < {$now}");
}

// Session key — UUID (do ticket.php) + legacy format (do protocolgame fallback)
$legacySessionKey = $acc['name'] . "\n" . $plain;

$session = [
    'sessionkey'    => $sessionUuid,                // B1: nowy UUID session — ticket.php używa tego
    'key'           => $legacySessionKey,            // Legacy — protocolgame bez ticket-gate
    'lastlogintime' => 0,
    'ispremium'     => false,
    'premiumuntil'  => 0,
    'status'        => 'active',
    'gameMode'      => $gameModeDb,                  // B1: gameMode w odpowiedzi
];

json_out(['session' => $session, 'playdata' => $playdata]);
