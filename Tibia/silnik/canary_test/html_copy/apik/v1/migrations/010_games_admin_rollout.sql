-- Migration 010: Games table admin management
-- Adds game_mode column (used by login.php, ticket.php, server-status.php)
-- Adds admin_api_keys table for admin-only API access
-- Adds login_port column for servers needing separate login/game ports
--
-- Run on: canaryaac database

-- 1. Add game_mode to games (login.php queries WHERE game_mode = ?)
ALTER TABLE `games`
    ADD COLUMN IF NOT EXISTS `game_mode` VARCHAR(32) NOT NULL DEFAULT '' AFTER `slug`,
    ADD COLUMN IF NOT EXISTS `login_port` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Login protocol port (0 = same as game_port)' AFTER `game_port`,
    ADD COLUMN IF NOT EXISTS `description` VARCHAR(255) NOT NULL DEFAULT '' AFTER `name`,
    ADD COLUMN IF NOT EXISTS `visible` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Shown in launcher/client list' AFTER `status`,
    ADD COLUMN IF NOT EXISTS `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER `created_at`;

-- 2. Add index on game_mode for fast lookups
CREATE INDEX IF NOT EXISTS `idx_games_game_mode` ON `games` (`game_mode`, `status`);

-- 3. Populate game_mode from slug for existing rows
UPDATE `games` SET `game_mode` = 'classic74' WHERE `slug` = 'tibia_classic74' AND `game_mode` = '';
UPDATE `games` SET `game_mode` = 'modern'    WHERE `slug` = 'tibia_modern'    AND `game_mode` = '';

-- 4. Admin API keys table — admin-only endpoints require X-Admin-Key header
CREATE TABLE IF NOT EXISTS `admin_api_keys` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(128) NOT NULL COMMENT 'Human label for the key (e.g. "ptaku-main")',
    `key_hash` VARCHAR(128) NOT NULL COMMENT 'SHA-256 hash of the API key',
    `permissions` VARCHAR(512) NOT NULL DEFAULT '*' COMMENT 'Comma-separated permissions or * for all',
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `last_used_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'NULL = never expires',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_key_hash` (`key_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Audit log for admin actions
CREATE TABLE IF NOT EXISTS `admin_audit_log` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `admin_key_id` INT UNSIGNED NOT NULL,
    `action` VARCHAR(64) NOT NULL COMMENT 'e.g. games.create, games.update, games.delete',
    `target_type` VARCHAR(32) NOT NULL DEFAULT '' COMMENT 'e.g. games',
    `target_id` VARCHAR(64) NOT NULL DEFAULT '' COMMENT 'e.g. game.id',
    `details` JSON DEFAULT NULL COMMENT 'Before/after state or extra info',
    `ip_hash` VARCHAR(64) NOT NULL DEFAULT '',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_admin_key` (`admin_key_id`),
    KEY `idx_action_time` (`action`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
