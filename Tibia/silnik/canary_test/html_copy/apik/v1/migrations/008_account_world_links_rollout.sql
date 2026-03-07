-- Migration 008: account_world_links for global account -> per-world profile mapping

CREATE TABLE IF NOT EXISTS `account_world_links` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `account_id` INT(11) UNSIGNED NOT NULL,
    `game_mode` VARCHAR(32) NOT NULL,
    `world_id` INT(11) NOT NULL DEFAULT 0,
    `world_account_id` INT(11) UNSIGNED DEFAULT NULL,
    `provision_state` VARCHAR(32) NOT NULL DEFAULT 'active',
    `last_synced_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_account_world_mode` (`account_id`, `game_mode`),
    KEY `idx_game_mode_world` (`game_mode`, `world_id`),
    KEY `idx_world_account_id` (`world_account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bootstrap existing accounts for classic74 and modern worlds.
INSERT INTO `account_world_links` (
    `account_id`, `game_mode`, `world_id`, `world_account_id`, `provision_state`, `last_synced_at`
)
SELECT a.`id`, 'classic74', 0, a.`id`, 'active', UTC_TIMESTAMP()
FROM `accounts` a
ON DUPLICATE KEY UPDATE
    `world_id` = VALUES(`world_id`),
    `world_account_id` = VALUES(`world_account_id`),
    `provision_state` = 'active',
    `last_synced_at` = UTC_TIMESTAMP();

INSERT INTO `account_world_links` (
    `account_id`, `game_mode`, `world_id`, `world_account_id`, `provision_state`, `last_synced_at`
)
SELECT a.`id`, 'modern', 1, a.`id`, 'active', UTC_TIMESTAMP()
FROM `accounts` a
ON DUPLICATE KEY UPDATE
    `world_id` = VALUES(`world_id`),
    `world_account_id` = VALUES(`world_account_id`),
    `provision_state` = 'active',
    `last_synced_at` = UTC_TIMESTAMP();

INSERT INTO `_migrations` (`id`, `name`)
VALUES (8, '008_account_world_links')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
