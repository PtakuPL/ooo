<?php
declare(strict_types=1);

/**
 * verify-email.php — confirms email address via token.
 *
 * GET /apik/v1/verify-email.php?token=<hex64>
 *
 * On success: sets accounts.email_verified = 1, deletes token, redirects to
 * RedDAXE login with ?verified=1 param.
 */

require_once __DIR__ . '/common.php';

$token = trim((string)($_GET['token'] ?? ''));

if ($token === '' || !preg_match('/^[a-f0-9]{64}$/i', $token)) {
    http_response_code(400);
    echo '<!doctype html><html><body><h2>Invalid verification token.</h2></body></html>';
    exit;
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

$apiDb   = getApiDb($ENV);
$globalDb = getGlobalDb($ENV);
$tokenHash = hash('sha256', $token);

// Look up the token
$stmt = $apiDb->prepare(
    "SELECT id, account_id, email, expires_at FROM email_verification_tokens WHERE token_hash = ? LIMIT 1"
);
$stmt->execute([$tokenHash]);
$row = $stmt->fetch();

if (!$row) {
    http_response_code(404);
    echo '<!doctype html><html><body><h2>Verification link is invalid or has already been used.</h2></body></html>';
    exit;
}

if ((int)$row['expires_at'] < time()) {
    // Delete expired token
    $del = $apiDb->prepare("DELETE FROM email_verification_tokens WHERE id = ?");
    $del->execute([$row['id']]);
    http_response_code(410);
    echo '<!doctype html><html><body><h2>Verification link has expired. Please register again.</h2></body></html>';
    exit;
}

$accountId = (int)$row['account_id'];

// Q-01: Transakcja — UPDATE + DELETE atomowo. Jeśli jedno się nie powiedzie, drugie też nie.
try {
    $apiDb->beginTransaction();

    // Mark email as verified in global accounts
    $upd = $globalDb->prepare("UPDATE accounts SET email_verified = 1 WHERE id = ?");
    $upd->execute([$accountId]);

    // Delete used token
    $del = $apiDb->prepare("DELETE FROM email_verification_tokens WHERE id = ?");
    $del->execute([$row['id']]);

    $apiDb->commit();
} catch (\Throwable $e) {
    if ($apiDb->inTransaction()) {
        $apiDb->rollBack();
    }
    error_log('[verify-email.php] Transaction failed: ' . $e->getMessage());
    http_response_code(500);
    echo '<!doctype html><html><body><h2>Verification failed due to a server error. Please try again.</h2></body></html>';
    exit;
}

logTicketEvent('email.verified', [
    'endpoint' => 'verify-email.php',
    'accountId' => $accountId,
    'email' => (string)$row['email'],
], $ENV);

// Redirect to RedDAXE login with success message
header('Location: /reddaxe/account-login.php?verified=1', true, 302);
exit;
