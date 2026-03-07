<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * account-profile-switch.php
 *
 * Switch active profile (gameMode scope) for an existing sessionKey.
 * This is the launcher/API equivalent of WWW account profile switching.
 *
 * Request JSON:
 * {
 *   "type": "account_profile_switch",
 *   "sessionKey": "...",
 *   "gameMode": "all|classic74|modern"
 * }
 */

require_once __DIR__ . '/common.php';

function profileSwitchError(string $code, string $message, int $httpCode = 400): void
{
    sendLauncherError($code, $message, $httpCode);
}

function profileSwitchNormalizeMode(string $mode): string
{
    $mode = strtolower(trim($mode));
    if (!in_array($mode, ['all', 'classic74', 'modern'], true)) {
        return 'all';
    }
    return $mode;
}

$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
if (!is_array($req)) {
    profileSwitchError('invalid_json', 'Invalid JSON request.');
}

$action = isset($req['type']) ? trim((string)$req['type']) : 'account_profile_switch';
if (!in_array($action, ['account_profile_switch', 'session_profile_switch'], true)) {
    profileSwitchError('invalid_action', 'Expected type=account_profile_switch.');
}

$sessionKey = trim((string)($req['sessionKey'] ?? ''));
if ($sessionKey === '') {
    profileSwitchError('missing_session_key', 'Missing sessionKey.');
}

$requestedMode = profileSwitchNormalizeMode((string)($req['gameMode'] ?? 'all'));

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);
$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);

// F1: multi-DB — ticket_sessions is in API_DB
$apiDb = getApiDb($ENV);

$now = time();
$stmt = $apiDb->prepare(
    "SELECT session_key, account_id, expires_at
     FROM ticket_sessions
     WHERE session_key = ?
     LIMIT 1"
);
$stmt->execute([$sessionKey]);
$session = $stmt->fetch();
if (!$session) {
    profileSwitchError('invalid_session', 'Invalid sessionKey.', 401);
}

if ((int)$session['expires_at'] < $now) {
    profileSwitchError('expired_session', 'Session expired.', 401);
}

$update = $apiDb->prepare(
    "UPDATE ticket_sessions
     SET game_mode = ?
     WHERE session_key = ?
     LIMIT 1"
);
$update->execute([$requestedMode, $sessionKey]);

logTicketEvent('account.profile_switched', [
    'endpoint' => 'account-profile-switch.php',
    'ipHash' => $ipHash,
    'accountId' => (int)$session['account_id'],
    'sessionKeyPrefix' => substr($sessionKey, 0, 12),
    'gameMode' => $requestedMode,
], $ENV);

json_out([
    'ok' => true,
    'session' => [
        'sessionKey' => $sessionKey,
        'accountId' => (int)$session['account_id'],
        'gameMode' => $requestedMode,
        'expiresAt' => (int)$session['expires_at'],
    ],
    'activeProfile' => [
        'gameMode' => $requestedMode,
        'allowedModes' => ['all', 'classic74', 'modern'],
    ],
]);
