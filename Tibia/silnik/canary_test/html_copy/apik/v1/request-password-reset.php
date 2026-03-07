<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * request-password-reset.php — sends password reset email.
 *
 * Request JSON:
 * { "type": "request_password_reset", "email": "user@example.com" }
 *
 * Always returns {"ok":true} to avoid email enumeration.
 */

require_once __DIR__ . '/common.php';
require_once __DIR__ . '/mailer.php';

$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    json_out(['ok' => true]); // silent — no info leak
    exit;
}

$email = strtolower(trim((string)($req['email'] ?? '')));
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    json_out(['ok' => true]);
    exit;
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

// Rate limit: max 3 reset requests per email per hour
$apiDb = getApiDb($ENV);
$emailHashRate = hash('sha256', 'reset:' . $email);
$rl = applyRateLimit($apiDb, 'reset:email', $emailHashRate, 3, 3600);
if (!$rl['allowed']) {
    logTicketEvent('password_reset.rate_limited', [
        'email' => $email,
        'retryAfter' => $rl['retryAfter'],
    ], $ENV);
    json_out(['ok' => true]); // silent
    exit;
}

// Look up account
$globalDb = getGlobalDb($ENV);
$stmt = $globalDb->prepare("SELECT id, name, email FROM accounts WHERE email = ? LIMIT 1");
$stmt->execute([$email]);
$account = $stmt->fetch();

if (!$account) {
    // No account — silent success (anti-enumeration)
    logTicketEvent('password_reset.no_account', ['email' => $email], $ENV);
    json_out(['ok' => true]);
    exit;
}

$accountId = (int)$account['id'];

// Invalidate any existing tokens for this account
$delStmt = $apiDb->prepare("DELETE FROM password_reset_tokens WHERE account_id = ?");
$delStmt->execute([$accountId]);

// Generate new token
$resetToken = bin2hex(random_bytes(32));
$tokenHash  = hash('sha256', $resetToken);
$expiresAt  = time() + 3600; // 1 hour

$ins = $apiDb->prepare(
    "INSERT INTO password_reset_tokens (account_id, email, token_hash, expires_at, created_at)
     VALUES (?, ?, ?, ?, NOW())"
);
$ins->execute([$accountId, $email, $tokenHash, $expiresAt]);

// Send reset email
$siteUrl = rtrim((string)($ENV['SITE_URL'] ?? 'https://reddaxe.pl'), '/');
$resetUrl = $siteUrl . '/reddaxe/reset-password.php?token=' . $resetToken;
$accountName = (string)$account['name'];

$htmlBody = '<h2>Reset hasla</h2>'
    . '<p>Cześć ' . htmlspecialchars($accountName) . ',</p>'
    . '<p>Ktos zażądał resetu hasła dla Twojego konta. Kliknij w poniższy link:</p>'
    . '<p><a href="' . htmlspecialchars($resetUrl) . '">' . htmlspecialchars($resetUrl) . '</a></p>'
    . '<p>Link wygasa po 1 godzinie. Jeśli to nie Ty — zignoruj tę wiadomość.</p>';
$plainBody = "Reset hasla\nCzesc $accountName,\nKliknij: $resetUrl\nLink wygasa po 1 godzinie.";

$mailResult = apiSendMail($ENV, $email, 'Reset hasla - RedDAXE', $htmlBody, $plainBody);

if (!($mailResult['ok'] ?? false)) {
    logTicketEvent('password_reset.mail_failed', [
        'accountId' => $accountId,
        'error' => (string)($mailResult['error'] ?? 'unknown'),
    ], $ENV);
} else {
    logTicketEvent('password_reset.sent', [
        'accountId' => $accountId,
        'email' => $email,
    ], $ENV);
}

json_out(['ok' => true]);
