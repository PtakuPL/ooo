<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * register-account.php — K5
 * Tworzy konto wspólne dla obu serwerów (classic74 + modern).
 *
 * Request JSON:
 * {
 *   "type": "register",
 *   "accountName": "gracz123",
 *   "email": "gracz@example.com",
 *   "password": "tajne_haslo",
 *   "passwordConfirm": "tajne_haslo"
 * }
 */

require_once __DIR__ . '/common.php';
require_once __DIR__ . '/register-account-lib.php';

function respondRegisterError(string $code, string $message, int $httpCode = 400): void
{
    sendLauncherError($code, $message, $httpCode);
}

$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    respondRegisterError('invalid_json', 'Invalid JSON request.');
}

$action = isset($req['type']) ? trim((string)$req['type']) : 'register';
if ($action !== 'register' && $action !== 'register_account') {
    respondRegisterError('invalid_action', 'Expected type=register.');
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

// W71: Rate limiting — max 3 registrations per IP per hour
$apiDb = getApiDb($ENV);
$clientIpForRate = getClientIp($ENV);
$ipHashRate = hashClientIp($clientIpForRate, $ENV);
$rlIp = applyRateLimit($apiDb, 'register:ip', $ipHashRate, 3, 3600);
if (!$rlIp['allowed']) {
    logTicketEvent('register.rejected.rate_limited', [
        'endpoint' => 'register-account.php',
        'ipHash' => $ipHashRate,
        'retryAfter' => $rlIp['retryAfter'],
    ], $ENV);
    respondRegisterError('rate_limited', 'Too many registration attempts. Please try again later.', 429);
}

$result = register_account_shared($req, $ENV);
if (!($result['ok'] ?? false)) {
    respondRegisterError(
        (string)($result['error'] ?? 'register_failed'),
        (string)($result['message'] ?? 'Cannot create account.'),
        (int)($result['httpCode'] ?? 400)
    );
}

json_out([
    'ok' => true,
    'accountId' => (int)$result['accountId'],
    'accountName' => (string)$result['accountName'],
    'email' => (string)$result['email'],
    'emailVerificationSent' => (bool)($result['emailVerificationSent'] ?? false),
]);
