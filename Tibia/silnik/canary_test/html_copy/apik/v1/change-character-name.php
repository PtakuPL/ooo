<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * change-character-name.php — API endpoint for renaming a character.
 *
 * Request JSON:
 * {
 *   "type": "change_character_name",
 *   "sessionKey": "...",
 *   "playerId": 123,
 *   "gameMode": "classic74" | "modern",
 *   "newName": "..."
 * }
 *
 * Validates:
 * - session ownership
 * - character belongs to the account
 * - character is not online
 * - character is not deleted
 * - new name is valid and not taken
 */

require_once __DIR__ . '/common.php';

$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    sendLauncherError('invalid_json', 'Invalid JSON request.', 400);
}

$sessionKey = trim((string)($req['sessionKey'] ?? ''));
$playerId = isset($req['playerId']) ? (int)$req['playerId'] : 0;
$gameMode = trim((string)($req['gameMode'] ?? ''));
$newName = trim((string)($req['newName'] ?? ''));

if ($sessionKey === '' || $playerId <= 0 || $gameMode === '' || $newName === '') {
    sendLauncherError('missing_fields', 'sessionKey, playerId, gameMode and newName are required.', 400);
}

if (!in_array($gameMode, ['classic74', 'modern'], true)) {
    sendLauncherError('invalid_game_mode', 'gameMode must be classic74 or modern.', 400);
}

// Validate name: 3-29 chars, letters and spaces only, no leading/trailing spaces, no double spaces
if (strlen($newName) < 3 || strlen($newName) > 29) {
    sendLauncherError('invalid_name_length', 'Character name must be between 3 and 29 characters.', 400);
}

if (!preg_match('/^[A-Za-z ]+$/', $newName)) {
    sendLauncherError('invalid_name_chars', 'Character name may only contain letters and spaces.', 400);
}

if (preg_match('/  /', $newName)) {
    sendLauncherError('invalid_name_spaces', 'Character name may not contain consecutive spaces.', 400);
}

if ($newName !== trim($newName)) {
    sendLauncherError('invalid_name_trim', 'Character name may not start or end with a space.', 400);
}

// Format: capitalize each word
$newName = implode(' ', array_map('ucfirst', array_map('strtolower', explode(' ', $newName))));

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);

$apiDb = getApiDb($ENV);

// Rate limit: 3 attempts per session per 10 minutes
$rl = applyRateLimit($apiDb, 'change_char_name:session', hash('sha256', $sessionKey), 3, 600);
if (!$rl['allowed']) {
    logTicketEvent('change_character_name.rejected.rate_limited', [
        'endpoint' => 'change-character-name.php',
        'ipHash' => $ipHash,
    ], $ENV);
    sendLauncherError('rate_limited', 'Too many rename attempts. Try again later.', 429);
}

// Verify session
$now = time();
$stmt = $apiDb->prepare("SELECT account_id FROM ticket_sessions WHERE session_key = ? AND expires_at >= ?");
$stmt->execute([$sessionKey, $now]);
$session = $stmt->fetch();

if (!$session) {
    sendLauncherError('invalid_session', 'Session expired or invalid. Please log in again.', 401);
}

$accountId = (int)$session['account_id'];

// Connect to the correct engine DB
$engineDb = getEnginePdo($ENV, $gameMode);

// Verify character belongs to this account
$stmt = $engineDb->prepare("SELECT id, name, account_id, deletion FROM players WHERE id = ? LIMIT 1");
$stmt->execute([$playerId]);
$player = $stmt->fetch();

if (!$player) {
    sendLauncherError('player_not_found', 'Character not found.', 404);
}

if ((int)$player['account_id'] !== $accountId) {
    sendLauncherError('not_owner', 'This character does not belong to your account.', 403);
}

if ((int)$player['deletion'] !== 0) {
    sendLauncherError('player_deleted', 'Cannot rename a deleted character.', 400);
}

// Check if player is online (players_online table or online column)
try {
    $stmt = $engineDb->prepare("SELECT player_id FROM players_online WHERE player_id = ? LIMIT 1");
    $stmt->execute([$playerId]);
    if ($stmt->fetch()) {
        sendLauncherError('player_online', 'Cannot rename a character that is currently online.', 400);
    }
} catch (\PDOException $e) {
    // players_online table might not exist — skip check
}

// Check name not taken in this engine
$stmt = $engineDb->prepare("SELECT id FROM players WHERE LOWER(name) = LOWER(?) AND id != ? LIMIT 1");
$stmt->execute([$newName, $playerId]);
if ($stmt->fetch()) {
    sendLauncherError('name_taken', 'This character name is already taken.', 409);
}

// Also check the other engine DB to prevent cross-server name conflicts
$otherMode = ($gameMode === 'modern') ? 'classic74' : 'modern';
try {
    $otherDb = getEnginePdo($ENV, $otherMode);
    $stmt = $otherDb->prepare("SELECT id FROM players WHERE LOWER(name) = LOWER(?) LIMIT 1");
    $stmt->execute([$newName]);
    if ($stmt->fetch()) {
        sendLauncherError('name_taken', 'This character name is already taken on another server.', 409);
    }
} catch (\PDOException $e) {
    // Other engine DB unavailable — allow (name will be unique in current engine)
}

$oldName = (string)$player['name'];

// Update character name
$stmt = $engineDb->prepare("UPDATE players SET name = ? WHERE id = ?");
$stmt->execute([$newName, $playerId]);

// Update player_deaths references (same as MyAAC change-name.php logic)
try {
    $stmt = $engineDb->prepare(
        "UPDATE player_deaths SET killed_by = ? WHERE is_player = 1 AND killed_by = ?"
    );
    $stmt->execute([$newName, $oldName]);

    $stmt = $engineDb->prepare(
        "UPDATE player_deaths SET mostdamage_by = ? WHERE mostdamage_is_player = 1 AND mostdamage_by = ?"
    );
    $stmt->execute([$newName, $oldName]);
} catch (\PDOException $e) {
    // player_deaths table might not exist or have different schema — skip
}

logTicketEvent('change_character_name.success', [
    'endpoint' => 'change-character-name.php',
    'accountId' => $accountId,
    'playerId' => $playerId,
    'gameMode' => $gameMode,
    'oldName' => $oldName,
    'newName' => $newName,
    'ipHash' => $ipHash,
], $ENV);

json_out([
    'ok' => true,
    'message' => 'Character name changed successfully.',
    'oldName' => $oldName,
    'newName' => $newName,
]);
