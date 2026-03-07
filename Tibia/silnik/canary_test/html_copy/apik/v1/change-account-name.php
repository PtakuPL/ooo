<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * change-account-name.php — API endpoint for changing account display name.
 *
 * Request JSON:
 * {
 *   "type": "change_account_name",
 *   "sessionKey": "...",
 *   "newName": "..."
 * }
 */

require_once __DIR__ . '/common.php';

$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    sendLauncherError('invalid_json', 'Invalid JSON request.', 400);
}

$sessionKey = trim((string)($req['sessionKey'] ?? ''));
$newName = trim((string)($req['newName'] ?? ''));

if ($sessionKey === '') {
    sendLauncherError('missing_fields', 'sessionKey is required.', 400);
}

// Validate name: 3-32 chars, alphanumeric + underscore + spaces
if ($newName === '' || strlen($newName) < 3 || strlen($newName) > 32) {
    sendLauncherError('invalid_name_length', 'Account name must be between 3 and 32 characters.', 400);
}

if (!preg_match('/^[A-Za-z0-9_ ]+$/', $newName)) {
    sendLauncherError('invalid_name_chars', 'Account name may only contain letters, digits, underscores and spaces.', 400);
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);

$apiDb = getApiDb($ENV);
$globalDb = getGlobalDb($ENV);

// Rate limit: 3 attempts per session per 10 minutes
$rl = applyRateLimit($apiDb, 'change_name:session', hash('sha256', $sessionKey), 3, 600);
if (!$rl['allowed']) {
    logTicketEvent('change_account_name.rejected.rate_limited', [
        'endpoint' => 'change-account-name.php',
        'ipHash' => $ipHash,
    ], $ENV);
    sendLauncherError('rate_limited', 'Too many name change attempts. Try again later.', 429);
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

// Check if name is already taken by another account
$stmt = $globalDb->prepare("SELECT id FROM accounts WHERE LOWER(name) = LOWER(?) AND id != ? LIMIT 1");
$stmt->execute([$newName, $accountId]);
if ($stmt->fetch()) {
    sendLauncherError('name_taken', 'This account name is already taken.', 409);
}

// Update account name
$stmt = $globalDb->prepare("UPDATE accounts SET name = ? WHERE id = ?");
$stmt->execute([$newName, $accountId]);

logTicketEvent('change_account_name.success', [
    'endpoint' => 'change-account-name.php',
    'accountId' => $accountId,
    'newName' => $newName,
    'ipHash' => $ipHash,
], $ENV);

json_out(['ok' => true, 'message' => 'Account name changed successfully.', 'newName' => $newName]);
