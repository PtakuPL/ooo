#!/usr/bin/env php
<?php
/**
 * W72: cleanup-expired.php — Cron script to purge expired tokens and rate limits.
 *
 * Tables cleaned (api_core DB):
 *   - ticket_sessions       (expires_at INT — UNIX timestamp)
 *   - api_rate_limits        (expires_at INT UNSIGNED)
 *   - oauth_rate_limits      (expires_at INT UNSIGNED)
 *   - launch_tokens          (expires_at TIMESTAMP)
 *   - oauth_states           (expires_at INT UNSIGNED)
 *   - ticket_nonces          (expires_at INT UNSIGNED)
 *   - account_sync_tokens    (expires_at INT UNSIGNED)
 *   - email_verification_tokens (expires_at INT UNSIGNED)
 *   - password_reset_tokens   (expires_at INT UNSIGNED)
 *
 * Usage:
 *   php cleanup-expired.php           # run cleanup, print summary
 *   php cleanup-expired.php --quiet   # run cleanup, no output (cron)
 *
 * Cron example (every hour):
 *   0 * * * * /usr/bin/php /var/www/html/apik/v1/cleanup-expired.php --quiet
 */
declare(strict_types=1);

require_once __DIR__ . '/common.php';

$quiet = in_array('--quiet', $argv ?? [], true);

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

try {
    $apiDb = getApiDb($ENV);
} catch (\Exception $e) {
    if (!$quiet) {
        echo "ERROR: Cannot connect to api_core DB: {$e->getMessage()}\n";
    }
    exit(1);
}

$now = time();
$nowTs = date('Y-m-d H:i:s', $now);
$results = [];

// Tables with INT/UNSIGNED expires_at (UNIX timestamp)
$intTables = [
    'ticket_sessions',
    'api_rate_limits',
    'oauth_rate_limits',
    'oauth_states',
    'ticket_nonces',
    'account_sync_tokens',
    'email_verification_tokens',
    'password_reset_tokens',
];

foreach ($intTables as $table) {
    try {
        $stmt = $apiDb->prepare("DELETE FROM `{$table}` WHERE expires_at < ?");
        $stmt->execute([$now]);
        $results[$table] = $stmt->rowCount();
    } catch (\PDOException $e) {
        $results[$table] = 'ERROR: ' . $e->getMessage();
    }
}

// launch_tokens: expires_at is TIMESTAMP (datetime string comparison)
try {
    $stmt = $apiDb->prepare("DELETE FROM launch_tokens WHERE expires_at < ?");
    $stmt->execute([$nowTs]);
    $results['launch_tokens'] = $stmt->rowCount();
} catch (\PDOException $e) {
    $results['launch_tokens'] = 'ERROR: ' . $e->getMessage();
}

if (!$quiet) {
    echo "=== cleanup-expired.php @ " . date('Y-m-d H:i:s') . " ===\n";
    $totalDeleted = 0;
    foreach ($results as $table => $count) {
        if (is_int($count)) {
            echo "  {$table}: {$count} rows deleted\n";
            $totalDeleted += $count;
        } else {
            echo "  {$table}: {$count}\n";
        }
    }
    echo "  TOTAL: {$totalDeleted} rows cleaned up\n";
}
