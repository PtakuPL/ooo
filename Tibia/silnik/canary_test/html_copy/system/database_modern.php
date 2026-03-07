<?php
/**
 * Dual-database helper for multi-server CanaryAAC
 *
 * Provides a second PDO connection to canary_modern database.
 * Used by pages that need to query Modern server data (highscores, shop, etc.)
 *
 * Usage:
 *   require_once __DIR__ . '/database_modern.php';
 *   $modernDb = getModernDb();
 *   if ($modernDb) { $stmt = $modernDb->query('SELECT ...'); }
 *
 * @package K50 — Dual PDO multi-server
 */

defined('MYAAC') or die('Direct access not allowed!');

/**
 * Get PDO connection to canary_modern database.
 * Reuses a singleton connection. Returns null if connection fails.
 */
function getModernDb(): ?PDO
{
    static $modernPdo = null;
    static $tried = false;

    if ($tried) {
        return $modernPdo;
    }
    $tried = true;

    global $config;

    $dbName = $config['modern_database_name'] ?? 'canary_modern';
    $host   = $config['database_host'] ?? '127.0.0.1';
    $port   = $config['database_port'] ?? '3306';
    $user   = $config['database_user'] ?? '';
    $pass   = $config['database_password'] ?? '';
    $socket = $config['database_socket'] ?? '';

    $dsn = 'mysql:dbname=' . $dbName . ';host=' . $host;
    if (!empty($port) && $port !== '3306') {
        $dsn .= ';port=' . $port;
    }
    if (!empty($socket)) {
        $dsn .= ';unix_socket=' . $socket;
    }
    $dsn .= ';charset=utf8mb4';

    try {
        $modernPdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    } catch (PDOException $e) {
        error_log('K50 ModernDB connection failed: ' . $e->getMessage());
        $modernPdo = null;
    }

    return $modernPdo;
}

/**
 * Get player count from canary_modern database.
 */
function getModernPlayerCount(): int
{
    $db = getModernDb();
    if (!$db) return 0;
    $stmt = $db->query('SELECT COUNT(*) FROM players');
    return (int)$stmt->fetchColumn();
}

/**
 * Get online player count from canary_modern database.
 */
function getModernOnlineCount(): int
{
    $db = getModernDb();
    if (!$db) return 0;
    $stmt = $db->query('SELECT COUNT(*) FROM players_online');
    return (int)$stmt->fetchColumn();
}
