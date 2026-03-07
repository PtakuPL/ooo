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
 *      e) NIE zapisuje nonce w DB — nonce konsumuje Canary przy pierwszym użyciu
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
$requestStartedAt = microtime(true);

// ------- read request -------
$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    logTicketEvent('ticket.rejected.invalid_json', [
        'endpoint' => 'ticket.php',
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ]);
    sendError('Invalid JSON request.');
}

$action = isset($req['type']) ? (string)$req['type'] : '';
if ($action !== 'ticket') {
    logTicketEvent('ticket.rejected.invalid_action', [
        'endpoint' => 'ticket.php',
        'action' => $action,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ]);
    sendError("Unrecognized event. Expected type=ticket.");
}

$sessionKey    = isset($req['sessionKey'])    ? trim((string)$req['sessionKey']) : '';
$characterName = isset($req['characterName']) ? trim((string)$req['characterName']) : '';
$gameMode      = isset($req['gameMode'])      ? trim((string)$req['gameMode']) : '';
$worldName     = isset($req['worldName'])     ? trim((string)$req['worldName']) : '';
$sessionKeyHash = $sessionKey !== '' ? substr(hash('sha256', $sessionKey), 0, 12) : '';

if ($sessionKey === '' || $characterName === '') {
    logTicketEvent('ticket.rejected.missing_fields', [
        'endpoint' => 'ticket.php',
        'hasSessionKey' => $sessionKey !== '',
        'hasCharacterName' => $characterName !== '',
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ]);
    sendError('Missing required fields: sessionKey, characterName.');
}

// ------- DB config (F1: multi-DB) -------
$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);
$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);

$ticketSecret = $ENV['TICKET_SECRET'] ?? '';
$ticketTtl    = isset($ENV['TICKET_TTL']) ? (int)$ENV['TICKET_TTL'] : 30;

// FIX57: Sprawdź oba placeholdery — ticket.php i .env.example używają różnych
$secretPlaceholders = ['ZMIEN_NA_LOSOWY_KLUCZ_64_ZNAKI_HEX', 'ZMIEN_WYGENERUJ_NOWY_KLUCZ'];
if ($ticketSecret === '' || in_array($ticketSecret, $secretPlaceholders, true)) {
    // KRYTYCZNE: brak skonfigurowanego klucza HMAC
    error_log('[ticket.php] TICKET_SECRET is not configured in .env!');
    logTicketEvent('ticket.rejected.server_config_secret_missing', [
        'endpoint' => 'ticket.php',
        'ipHash' => $ipHash,
        'sessionKeyHash' => $sessionKeyHash,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendError('Server configuration error.');
}

// F1: multi-DB connections
$apiDb    = getApiDb($ENV);     // ticket_sessions
$globalDb = getGlobalDb($ENV);  // games (for world validation)

// ------- INS-40: Rate-limit per IP (5/min) + per sessionKey (3/min) -------
$rlIp = applyRateLimit($apiDb, 'ticket:ip', $ipHash, 5, 60);
if (!$rlIp['allowed']) {
    logTicketEvent('ticket.rejected.rate_limit_ip', [
        'endpoint' => 'ticket.php',
        'ipHash' => $ipHash,
        'retryAfter' => $rlIp['retryAfter'],
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    header('Retry-After: ' . $rlIp['retryAfter']);
    sendError('Too many requests. Please wait.', 429);
}

$sessionKeyHashRate = hash('sha256', 'ticket:' . $sessionKey);
$rlSession = applyRateLimit($apiDb, 'ticket:session', $sessionKeyHashRate, 3, 60);
if (!$rlSession['allowed']) {
    logTicketEvent('ticket.rejected.rate_limit_session', [
        'endpoint' => 'ticket.php',
        'ipHash' => $ipHash,
        'sessionKeyHash' => $sessionKeyHash,
        'retryAfter' => $rlSession['retryAfter'],
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    header('Retry-After: ' . $rlSession['retryAfter']);
    sendError('Too many ticket requests for this session. Please wait.', 429);
}

// ------- 1. Weryfikuj sessionKey (API_DB) -------
$now = time();
$stmt = $apiDb->prepare(
    "SELECT account_id, game_mode, expires_at FROM ticket_sessions WHERE session_key = ? LIMIT 1"
);
$stmt->execute([$sessionKey]);
$sess = $stmt->fetch();
if (!$sess) {
    logTicketEvent('ticket.rejected.invalid_session', [
        'endpoint' => 'ticket.php',
        'ipHash' => $ipHash,
        'sessionKeyHash' => $sessionKeyHash,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendError('Invalid or expired session.');
}

if ((int)$sess['expires_at'] < $now) {
    // Sesja wygasła — wyczyść i odrzuć
    $del = $apiDb->prepare("DELETE FROM ticket_sessions WHERE session_key = ?");
    $del->execute([$sessionKey]);
    logTicketEvent('ticket.rejected.session_expired', [
        'endpoint' => 'ticket.php',
        'ipHash' => $ipHash,
        'sessionKeyHash' => $sessionKeyHash,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendError('Session has expired. Please log in again.');
}

$accountId = (int)$sess['account_id'];
$sessGameMode = (string)$sess['game_mode'];

// ------- 2. Sprawdź gameMode względem sesji (K1/K4) -------
$validModes = ['classic74', 'modern', 'all', ''];
if (!in_array($gameMode, $validModes, true)) {
    logTicketEvent('ticket.rejected.invalid_game_mode', [
        'endpoint' => 'ticket.php',
        'ipHash' => $ipHash,
        'sessionKeyHash' => $sessionKeyHash,
        'requestGameMode' => $gameMode,
        'sessionGameMode' => $sessGameMode,
        'accountId' => $accountId,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendError('Invalid game mode.');
}

if ($sessGameMode === 'all') {
    // Sesja neutralna: user MUSI wybrać docelowy serwer na etapie ticketu.
    if ($gameMode === '' || $gameMode === 'all') {
        logTicketEvent('ticket.rejected.game_mode_required', [
            'endpoint' => 'ticket.php',
            'ipHash' => $ipHash,
            'sessionKeyHash' => $sessionKeyHash,
            'sessionGameMode' => $sessGameMode,
            'accountId' => $accountId,
            'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
        ], $ENV);
        sendError('Game mode selection required for this session.');
    }
    $effectiveGameMode = $gameMode;
} else {
    if ($gameMode !== '' && $gameMode !== $sessGameMode) {
        logTicketEvent('ticket.rejected.game_mode_mismatch', [
            'endpoint' => 'ticket.php',
            'ipHash' => $ipHash,
            'sessionKeyHash' => $sessionKeyHash,
            'requestGameMode' => $gameMode,
            'sessionGameMode' => $sessGameMode,
            'accountId' => $accountId,
            'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
        ], $ENV);
        sendError('Game mode mismatch with session.');
    }
    // Sesja trybowa: użyj wartości z sesji jako autorytatywnej.
    $effectiveGameMode = $sessGameMode;
}

// ------- 2b. FIX13: Sprawdź worldName — nie może być pusty -------
if ($worldName === '') {
    logTicketEvent('ticket.rejected.world_missing', [
        'endpoint' => 'ticket.php',
        'ipHash' => $ipHash,
        'sessionKeyHash' => $sessionKeyHash,
        'accountId' => $accountId,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendError('Missing required field: worldName.');
}

// ------- 2c. F1: Dynamic world↔gameMode from games table (GLOBAL_DB) -------
// Replace hardcoded $worldMap with DB lookup from games.
$gStmt = $globalDb->prepare(
    "SELECT game_mode, name, sort_order FROM games WHERE game_mode = ? AND status = 'active' LIMIT 1"
);
$gStmt->execute([$effectiveGameMode]);
$gameRow = $gStmt->fetch();

$worldId = 0;
if ($gameRow) {
    $worldId = (int)$gameRow['sort_order'] - 1;
    // Waliduj: worldName musi pasować do nazwy gry z DB
    if ($worldName !== $gameRow['name']) {
        logTicketEvent('ticket.rejected.world_mode_mismatch', [
            'endpoint' => 'ticket.php',
            'ipHash' => $ipHash,
            'sessionKeyHash' => $sessionKeyHash,
            'accountId' => $accountId,
            'gameMode' => $effectiveGameMode,
            'worldName' => $worldName,
            'worldId' => $worldId,
            'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
        ], $ENV);
        sendError('World "' . $worldName . '" is not allowed for game mode "' . $effectiveGameMode . '".');
    }
} else {
    // FIX-AUD17: Nieznany gameMode — FAIL-CLOSED zamiast przepuszczania z logiem.
    error_log("[ticket.php] FIX-AUD17 BLOCKED: Unknown gameMode '{$effectiveGameMode}' — rejecting ticket request.");
    logTicketEvent('ticket.rejected.unknown_game_mode', [
        'endpoint' => 'ticket.php',
        'ipHash' => $ipHash,
        'sessionKeyHash' => $sessionKeyHash,
        'accountId' => $accountId,
        'gameMode' => $effectiveGameMode,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendError('Unknown game mode "' . $effectiveGameMode . '". Contact administrator.');
}

// ------- 3. Sprawdź characterName (ENGINE_DB) -------
$engineDb = getEnginePdo($ENV, $effectiveGameMode);
$playerWorldCol = 'none';
$stmt = null;
try {
    $stmt = $engineDb->prepare(
        "SELECT id, name, world FROM players WHERE account_id = ? AND name = ? AND deletion = 0 LIMIT 1"
    );
    $playerWorldCol = 'world';
} catch (\PDOException $e) {
    try {
        $stmt = $engineDb->prepare(
            "SELECT id, name, world_id FROM players WHERE account_id = ? AND name = ? AND deletion = 0 LIMIT 1"
        );
        $playerWorldCol = 'world_id';
    } catch (\PDOException $e2) {
        $stmt = $engineDb->prepare(
            "SELECT id, name FROM players WHERE account_id = ? AND name = ? AND deletion = 0 LIMIT 1"
        );
    }
}

$stmt->execute([$accountId, $characterName]);
$player = $stmt->fetch();
if (!$player) {
    logTicketEvent('ticket.rejected.character_not_owned', [
        'endpoint' => 'ticket.php',
        'ipHash' => $ipHash,
        'sessionKeyHash' => $sessionKeyHash,
        'accountId' => $accountId,
        'characterName' => $characterName,
        'gameMode' => $effectiveGameMode,
        'worldId' => $worldId,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendError('Character does not belong to this account.');
}

// Użyj nazwy z DB (canonical case)
$canonicalName = (string)$player['name'];

// K4: Sprawdź, czy postać należy do docelowego świata/serwera.
$characterWorldId = null;
if ($playerWorldCol === 'world' && isset($player['world']) && $player['world'] !== null) {
    $characterWorldId = (int)$player['world'];
} elseif ($playerWorldCol === 'world_id' && isset($player['world_id']) && $player['world_id'] !== null) {
    $characterWorldId = (int)$player['world_id'];
}

if ($characterWorldId !== null && $characterWorldId !== $worldId) {
    logTicketEvent('ticket.rejected.character_world_mismatch', [
        'endpoint' => 'ticket.php',
        'ipHash' => $ipHash,
        'sessionKeyHash' => $sessionKeyHash,
        'accountId' => $accountId,
        'characterName' => $canonicalName,
        'characterWorldId' => $characterWorldId,
        'requestWorldId' => $worldId,
        'gameMode' => $effectiveGameMode,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendError('Character is not assigned to selected server.', 403);
}

// ------- 4. Generuj ticket HMAC -------
$nonce     = bin2hex(random_bytes(16)); // 32 znaki hex
$issuedAt  = $now;
$expiresAt = $now + $ticketTtl;

$payload = json_encode([
    'accountId'     => $accountId,
    'characterName' => $canonicalName,
    'gameMode'      => $effectiveGameMode,
    'worldName'     => $worldName,
    'worldId'       => $worldId,
    'nonce'         => $nonce,
    // iat: canonical issue-time key used by Canary maxAge policy.
    // issuedAt: kept for backward compatibility with older parser variants.
    'iat'           => $issuedAt,
    'issuedAt'      => $issuedAt,
    'expiresAt'     => $expiresAt,
], JSON_UNESCAPED_SLASHES);

// FIX5: HMAC na base64(payload), NIE na surowym JSON
// Identyczne podejście jak ticket_validator.cpp w Canary
$payloadB64 = base64_encode($payload);
$hmacHex    = hash_hmac('sha256', $payloadB64, $ticketSecret);

$ticket = $payloadB64 . '.' . $hmacHex;

logTicketEvent('ticket.issued', [
    'endpoint' => 'ticket.php',
    'ipHash' => $ipHash,
    'sessionKeyHash' => $sessionKeyHash,
    'accountId' => $accountId,
    'characterName' => $canonicalName,
    'gameMode' => $effectiveGameMode,
    'worldId' => $worldId,
    'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
], $ENV);

// ------- Odpowiedź -------
json_out([
    'ticket'    => $ticket,
    'expiresAt' => $expiresAt,
]);
