-- Migration 007: Payment split by world/game mode
-- Adds metadata columns to canary_payments for dual-server checkout context.

CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @sql_add_world_id = (
    SELECT IF(
        (SELECT COUNT(*)
           FROM INFORMATION_SCHEMA.COLUMNS
          WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'canary_payments'
            AND COLUMN_NAME = 'world_id') = 0,
        'ALTER TABLE `canary_payments` ADD COLUMN `world_id` INT(11) NOT NULL DEFAULT 0 AFTER `account_id`',
        'SELECT 1'
    )
);
PREPARE stmt_add_world_id FROM @sql_add_world_id;
EXECUTE stmt_add_world_id;
DEALLOCATE PREPARE stmt_add_world_id;

SET @sql_add_game_mode = (
    SELECT IF(
        (SELECT COUNT(*)
           FROM INFORMATION_SCHEMA.COLUMNS
          WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'canary_payments'
            AND COLUMN_NAME = 'game_mode') = 0,
        'ALTER TABLE `canary_payments` ADD COLUMN `game_mode` VARCHAR(32) NOT NULL DEFAULT ''classic74'' AFTER `world_id`',
        'SELECT 1'
    )
);
PREPARE stmt_add_game_mode FROM @sql_add_game_mode;
EXECUTE stmt_add_game_mode;
DEALLOCATE PREPARE stmt_add_game_mode;

INSERT INTO `_migrations` (`id`, `name`)
VALUES (7, '007_payment_world_split')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
