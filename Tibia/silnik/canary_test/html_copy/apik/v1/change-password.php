<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * change-password.php — API endpoint for changing account password.
 *
 * Request JSON:
 * {
 *   "type": "change_password",
 *   "sessionKey": "...",
 *   "currentPassword": "...",
 *   "newPassword": "...",
 *   "newPasswordConfirm": "..."
 * }
 */

require_once __DIR__ . '/common.php';

$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    sendLauncherError('invalid_json', 'Invalid JSON request.', 400);
}

$sessionKey = trim((string)($req['sessionKey'] ?? ''));
$currentPassword = (string)($req['currentPassword'] ?? '');
$newPassword = (string)($req['newPassword'] ?? '');
$newPasswordConfirm = (string)($req['newPasswordConfirm'] ?? '');

if ($sessionKey === '' || $currentPassword === '' || $newPassword === '') {
    sendLauncherError('missing_fields', 'sessionKey, currentPassword and newPassword are required.', 400);
}

if (strlen($newPassword) < 6 || strlen($newPassword) > 72) {
    sendLauncherError('invalid_password_length', 'New password must be between 6 and 72 characters.', 400);
}

if ($newPasswordConfirm !== '' && !hash_equals($newPassword, $newPasswordConfirm)) {
    sendLauncherError('password_mismatch', 'New password confirmation does not match.', 400);
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);

$apiDb = getApiDb($ENV);
$globalDb = getGlobalDb($ENV);

// Rate limit: 5 attempts per account per 5 minutes
$rl = applyRateLimit($apiDb, 'change_password:session', hash('sha256', $sessionKey), 5, 300);
if (!$rl['allowed']) {
    logTicketEvent('change_password.rejected.rate_limited', [
        'endpoint' => 'change-password.php',
        'ipHash' => $ipHash,
    ], $ENV);
    sendLauncherError('rate_limited', 'Too many password change attempts. Try again later.', 429);
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

// Get current account
$stmt = $globalDb->prepare("SELECT id, password FROM accounts WHERE id = ? LIMIT 1");
$stmt->execute([$accountId]);
$acc = $stmt->fetch();

if (!$acc) {
    sendLauncherError('account_not_found', 'Account not found.', 404);
}

// Verify current password
$stored = (string)$acc['password'];
$ok = false;
if (strlen($stored) === 40 && ctype_xdigit($stored)) {
    $ok = hash_equals(strtolower($stored), strtolower(sha1($currentPassword)));
} elseif (str_starts_with($stored, '$2') || str_starts_with($stored, '$argon2')) {
    $ok = password_verify($currentPassword, $stored);
} else {
    $ok = hash_equals($stored, $currentPassword);
}

if (!$ok) {
    logTicketEvent('change_password.rejected.bad_password', [
        'endpoint' => 'change-password.php',
        'accountId' => $accountId,
        'ipHash' => $ipHash,
    ], $ENV);
    sendLauncherError('invalid_current_password', 'Current password is incorrect.', 403);
}

// Update password — SHA1 format (same as register-account-lib.php)
$newHash = sha1($newPassword);
$stmt = $globalDb->prepare("UPDATE accounts SET password = ? WHERE id = ?");
$stmt->execute([$newHash, $accountId]);

logTicketEvent('change_password.success', [
    'endpoint' => 'change-password.php',
    'accountId' => $accountId,
    'ipHash' => $ipHash,
], $ENV);

json_out(['ok' => true, 'message' => 'Password changed successfully.']);
