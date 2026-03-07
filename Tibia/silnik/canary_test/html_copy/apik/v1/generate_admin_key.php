#!/usr/bin/env php
<?php
/**
 * generate_admin_key.php — Generate and insert an admin API key.
 *
 * Usage:
 *   php generate_admin_key.php [key-name]
 *
 * Example:
 *   php generate_admin_key.php "ptaku-main"
 *
 * This will:
 *   1. Generate a random 32-byte API key
 *   2. Hash it with SHA-256
 *   3. Insert into admin_api_keys table
 *   4. Print the raw key (SAVE IT — it won't be shown again!)
 *
 * INS-61: Part of admin API key system.
 */
declare(strict_types=1);

require_once __DIR__ . '/common.php';

$keyName = $argv[1] ?? 'admin-' . date('Ymd');

$ENV = loadEnvFiles([__DIR__ . '/.env', __DIR__ . '/../.env', '/var/www/html/.env']);

// Generate random key
$rawKey = bin2hex(random_bytes(32));
$keyHash = hash('sha256', $rawKey);

try {
    $db = getGlobalDb($ENV);

    $stmt = $db->prepare(
        "INSERT INTO admin_api_keys (name, key_hash, permissions, is_active)
         VALUES (?, ?, '*', 1)"
    );
    $stmt->execute([$keyName, $keyHash]);

    $id = (int)$db->lastInsertId();

    echo "\n";
    echo "=== Admin API Key Generated ===\n";
    echo "  ID:   {$id}\n";
    echo "  Name: {$keyName}\n";
    echo "  Key:  {$rawKey}\n";
    echo "\n";
    echo "  SAVE THIS KEY! It will NOT be shown again.\n";
    echo "\n";
    echo "  Usage:\n";
    echo "    curl -H 'X-Admin-Key: {$rawKey}' https://your-server/apik/v1/games-manage.php\n";
    echo "\n";

} catch (\Throwable $e) {
    fwrite(STDERR, "ERROR: " . $e->getMessage() . "\n");
    fwrite(STDERR, "Make sure migration 010 has been applied (admin_api_keys table).\n");
    exit(1);
}
