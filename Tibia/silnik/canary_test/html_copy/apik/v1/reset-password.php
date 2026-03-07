<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * reset-password.php — consumes a password-reset token and sets new password.
 *
 * Request JSON:
 * {
 *   "type": "reset_password",
 *   "token": "<hex64>",
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

$token   = trim((string)($req['token'] ?? ''));
$newPass = (string)($req['newPassword'] ?? '');
$confirm = (string)($req['newPasswordConfirm'] ?? '');

if (!preg_match('/^[a-f0-9]{64}$/i', $token)) {
    sendLauncherError('invalid_token', 'Invalid or missing reset token.', 400);
}
if (strlen($newPass) < 6 || strlen($newPass) > 72) {
    sendLauncherError('invalid_password', 'Password must be 6-72 characters.', 400);
}
if (!hash_equals($newPass, $confirm)) {
    sendLauncherError('password_mismatch', 'Passwords do not match.', 400);
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

$apiDb    = getApiDb($ENV);
$globalDb = getGlobalDb($ENV);

$tokenHash = hash('sha256', $token);

$stmt = $apiDb->prepare(
    "SELECT id, account_id, email, expires_at, used_at FROM password_reset_tokens WHERE token_hash = ? LIMIT 1"
);
$stmt->execute([$tokenHash]);
$row = $stmt->fetch();

if (!$row) {
    sendLauncherError('token_invalid', 'Reset link is invalid or has already been used.', 404);
}
if ($row['used_at'] !== null) {
    sendLauncherError('token_used', 'This reset link has already been used.', 410);
}
if ((int)$row['expires_at'] < time()) {
    $del = $apiDb->prepare("DELETE FROM password_reset_tokens WHERE id = ?");
    $del->execute([$row['id']]);
    sendLauncherError('token_expired', 'Reset link has expired. Please request a new one.', 410);
}

$accountId = (int)$row['account_id'];

// Update password in global accounts (SHA1)
$engineSha1 = sha1($newPass);
$upd = $globalDb->prepare("UPDATE accounts SET password = ?, engine_password_sha1 = ? WHERE id = ?");
$upd->execute([$engineSha1, $engineSha1, $accountId]);

// Mark token as used
$used = $apiDb->prepare("UPDATE password_reset_tokens SET used_at = NOW() WHERE id = ?");
$used->execute([$row['id']]);

logTicketEvent('password_reset.completed', [
    'endpoint' => 'reset-password.php',
    'accountId' => $accountId,
    'email' => (string)$row['email'],
], $ENV);

json_out(['ok' => true]);
