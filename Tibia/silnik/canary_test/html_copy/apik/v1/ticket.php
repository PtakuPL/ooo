<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * /api/v1/ticket.php — B3: Endpoint generujący ticket HMAC dla ticket-gate.
 *
 * Flow:
 *   1. Klient wysyła POST z {sessionKey, characterName, gameMode, worldName, type:"ticket"}
 *   2. ticket.php:
 *      a) Weryfikuje sessionKey → istnieje w ticket_sessions, nie wygasła
 *      b) Sprawdza characterName → należy do konta z sesji
 *      c) Sprawdza gameMode → zgadza się z sesją
 *      d) Generuje ticket: base64(json_payload).hmac_hex
 *      e) Zapisuje nonce do ticket_nonces (audit + backup)
 *   3. Zwraca {ticket: "base64.hmac", expiresAt: unix_ts}
 *
 * HMAC jest obliczany na base64-encoded payload (NIE surowy JSON).
 * To samo co robi Canary ticket_validator.cpp (FIX5).
 * Format: base64encode(json_payload) + "." + hex(HMAC-SHA256(base64encode(json_payload), secret))
 *
 * TICKET_SECRET w .env MUSI być identyczny z ticketSecret w config.lua Canary.
 */

// FIX42: Shared utilities (loadEnvFiles, sendError, json_out)
require_once __DIR__ . '/common.php';

// ------- read request -------
$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    sendError('Invalid JSON request.');
}

$action = isset($req['type']) ? (string)$req['type'] : '';
if ($action !== 'ticket') {
    sendError("Unrecognized event. Expected type=ticket.");
}

$sessionKey    = isset($req['sessionKey'])    ? trim((string)$req['sessionKey']) : '';
$characterName = isset($req['characterName']) ? trim((string)$req['characterName']) : '';
$gameMode      = isset($req['gameMode'])      ? trim((string)$req['gameMode']) : '';
$worldName     = isset($req['worldName'])     ? trim((string)$req['worldName']) : '';

if ($sessionKey === '' || $characterName === '') {
    sendError('Missing required fields: sessionKey, characterName.');
}

// ------- DB config -------
$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

$dbhost = $ENV['DB_HOST'] ?? '127.0.0.1';
$dbuser = $ENV['DB_USER'] ?? 'ptaku';
$dbpass = $ENV['DB_PASS'] ?? '12345678';
$dbname = $ENV['DB_NAME'] ?? 'canaryaac';
$dbport = isset($ENV['DB_PORT']) ? (int)$ENV['DB_PORT'] : 3306;

$ticketSecret = $ENV['TICKET_SECRET'] ?? '';
$ticketTtl    = isset($ENV['TICKET_TTL']) ? (int)$ENV['TICKET_TTL'] : 30;

// FIX57: Sprawdź oba placeholdery — ticket.php i .env.example używają różnych
$secretPlaceholders = ['ZMIEN_NA_LOSOWY_KLUCZ_64_ZNAKI_HEX', 'ZMIEN_WYGENERUJ_NOWY_KLUCZ'];
if ($ticketSecret === '' || in_array($ticketSecret, $secretPlaceholders, true)) {
    // KRYTYCZNE: brak skonfigurowanego klucza HMAC
    error_log('[ticket.php] TICKET_SECRET is not configured in .env!');
    sendError('Server configuration error.');
}

// ------- connect -------
$mysqli = @new mysqli($dbhost, $dbuser, $dbpass, $dbname, $dbport);
if ($mysqli->connect_errno) {
    sendError('Database connection failed.');
}
$mysqli->set_charset('utf8mb4');

// ------- 1. Weryfikuj sessionKey -------
$now = time();
$stmt = $mysqli->prepare(
    "SELECT account_id, game_mode, expires_at FROM ticket_sessions WHERE session_key = ? LIMIT 1"
);
$stmt->bind_param('s', $sessionKey);
$stmt->execute();
$res = $stmt->get_result();
if ($res->num_rows === 0) {
    $stmt->close();
    sendError('Invalid or expired session.');
}
$sess = $res->fetch_assoc();
$stmt->close();

if ((int)$sess['expires_at'] < $now) {
    // Sesja wygasła — wyczyść i odrzuć
    $del = $mysqli->prepare("DELETE FROM ticket_sessions WHERE session_key = ?");
    $del->bind_param('s', $sessionKey);
    $del->execute();
    $del->close();
    sendError('Session has expired. Please log in again.');
}

$accountId    = (int)$sess['account_id'];
$sessGameMode = (string)$sess['game_mode'];

// ------- 2. Sprawdź gameMode — musi zgadzać się z sesją -------
if ($gameMode !== '' && $gameMode !== $sessGameMode) {
    sendError('Game mode mismatch with session.');
}
// Użyj gameMode z sesji (autorytatywny)
$effectiveGameMode = $sessGameMode;

// ------- 2b. FIX13: Sprawdź worldName — nie może być pusty -------
if ($worldName === '') {
    sendError('Missing required field: worldName.');
}

// ------- 2c. FIX20+FIX53: Sprawdź world↔gameMode — mapowanie po worldId (numeryczne) + worldName (fallback) -------
// FIX53: Dodano worldId (numeryczne) obok worldName (string) — odporniejsze na rename/lokalizację
// FIX58: World IDs zsynchronizowane z login.php (classic74=0, modern=1)
$worldMap = [
    'classic74' => ['id' => 0, 'names' => ['Classic 7.4']],
    'modern'    => ['id' => 1, 'names' => ['Modern']],
];
if (isset($worldMap[$effectiveGameMode])) {
    $entry = $worldMap[$effectiveGameMode];
    // Waliduj: worldName musi być na liście dozwolonych dla tego gameMode
    if (!in_array($worldName, $entry['names'], true)) {
        sendError('World "' . $worldName . '" is not allowed for game mode "' . $effectiveGameMode . '".');
    }
} else {
    // Nieznany gameMode — przepuść z logiem (forward-compatible)
    error_log("[ticket.php] FIX20 WARNING: Unknown gameMode '{$effectiveGameMode}' — worldName not validated.");
}
$stmt = $mysqli->prepare(
    "SELECT id, name FROM players WHERE account_id = ? AND name = ? AND deletion = 0 LIMIT 1"
);
$stmt->bind_param('is', $accountId, $characterName);
$stmt->execute();
$res = $stmt->get_result();
if ($res->num_rows === 0) {
    $stmt->close();
    sendError('Character does not belong to this account.');
}
$player = $res->fetch_assoc();
$stmt->close();

// Użyj nazwy z DB (canonical case)
$canonicalName = (string)$player['name'];

// ------- 4. Generuj ticket HMAC -------
$nonce     = bin2hex(random_bytes(16)); // 32 znaki hex
$issuedAt  = $now;
$expiresAt = $now + $ticketTtl;

$payload = json_encode([
    'accountId'     => $accountId,
    'characterName' => $canonicalName,
    'gameMode'      => $effectiveGameMode,
    'worldName'     => $worldName,
    'nonce'         => $nonce,
    'issuedAt'      => $issuedAt,
    'expiresAt'     => $expiresAt,
], JSON_UNESCAPED_SLASHES);

// FIX5: HMAC na base64(payload), NIE na surowym JSON
// Identyczne podejście jak ticket_validator.cpp w Canary
$payloadB64 = base64_encode($payload);
$hmacHex    = hash_hmac('sha256', $payloadB64, $ticketSecret);

$ticket = $payloadB64 . '.' . $hmacHex;

// ------- 5. Zapisz nonce do ticket_nonces (audit/backup) -------
$stmt = $mysqli->prepare(
    "INSERT INTO ticket_nonces (nonce, account_id, expires_at) VALUES (?, ?, ?)"
);
$stmt->bind_param('sii', $nonce, $accountId, $expiresAt);
$stmt->execute();
$stmt->close();

// Cleanup: okazyjnie usuń wygasłe nonce'y (~5% requestów)
if (mt_rand(1, 20) === 1) {
    $mysqli->query("DELETE FROM ticket_nonces WHERE expires_at < {$now}");
}

$mysqli->close();

// ------- Odpowiedź -------
json_out([
    'ticket'    => $ticket,
    'expiresAt' => $expiresAt,
]);
