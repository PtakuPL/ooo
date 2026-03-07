<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * GET /api/v1/challenge.php
 *
 * Wydaje jednorazowy nonce (challenge-response dla launcher-token).
 * Nonce jest zapisywany do ticket_nonces z account_id=0.
 */

require_once __DIR__ . '/common.php';
$requestStartedAt = microtime(true);

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);
$channel = isset($_GET['channel']) ? trim((string)$_GET['channel']) : ($ENV['UPDATE_CHANNEL'] ?? 'stable');

$challengeTtl = isset($ENV['CHALLENGE_TTL']) ? (int)$ENV['CHALLENGE_TTL'] : 30;
if ($challengeTtl <= 0) {
    $challengeTtl = 30;
}
if ($challengeTtl > 30) {
    $challengeTtl = 30;
}

// F1: multi-DB — ticket_nonces is in API_DB
try {
    $apiDb = getApiDb($ENV);
} catch (\Exception $e) {
    logTicketEvent('challenge.rejected.db_connect_failed', [
        'endpoint' => 'challenge.php',
        'ipHash' => $ipHash,
        'channel' => $channel,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendLauncherError('internal_error', 'Database connection failed.', 500);
}

$now = time();
$expiresAt = $now + $challengeTtl;
$nonce = '';
$inserted = false;
$lastDbErr = '';

for ($attempt = 0; $attempt < 3; $attempt++) {
    $nonce = bin2hex(random_bytes(16));
    try {
        $stmt = $apiDb->prepare(
            "INSERT INTO ticket_nonces (nonce, account_id, expires_at) VALUES (?, 0, ?)"
        );
        $ok = $stmt->execute([$nonce, $expiresAt]);
        if ($ok) {
            $inserted = true;
            break;
        }
    } catch (\PDOException $e) {
        $lastDbErr = $e->getMessage();
        // 23000 = integrity constraint (duplicate key)
        if ($e->getCode() !== '23000') {
            break;
        }
    }
}

if (!$inserted) {
    logTicketEvent('challenge.rejected.db_insert_failed', [
        'endpoint' => 'challenge.php',
        'ipHash' => $ipHash,
        'channel' => $channel,
        'dbError' => $lastDbErr,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);
    sendLauncherError('internal_error', 'Failed to issue challenge nonce.', 500);
}

// Cleanup wygasłych challenge nonce (account_id=0) co ~10 requestów.
if (mt_rand(1, 10) === 1) {
    $cleanup = $apiDb->prepare("DELETE FROM ticket_nonces WHERE account_id = 0 AND expires_at < ?");
    $cleanup->execute([$now]);
}

logTicketEvent('challenge.issued', [
    'endpoint' => 'challenge.php',
    'ipHash' => $ipHash,
    'channel' => $channel,
    'ttl' => $challengeTtl,
    'nonceHash' => substr(hash('sha256', $nonce), 0, 12),
    'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
], $ENV);

json_out([
    'nonce' => $nonce,
    'expiresInSeconds' => $challengeTtl,
    'issuedAtUtc' => gmdate('c', $now),
]);
