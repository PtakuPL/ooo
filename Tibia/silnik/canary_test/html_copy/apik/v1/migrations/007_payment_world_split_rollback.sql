-- Migration 007 rollback: remove payment world split metadata columns

SET @sql_drop_game_mode = (
    SELECT IF(
        (SELECT COUNT(*)
           FROM INFORMATION_SCHEMA.COLUMNS
          WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'canary_payments'
            AND COLUMN_NAME = 'game_mode') = 1,
        'ALTER TABLE `canary_payments` DROP COLUMN `game_mode`',
        'SELECT 1'
    )
);
PREPARE stmt_drop_game_mode FROM @sql_drop_game_mode;
EXECUTE stmt_drop_game_mode;
DEALLOCATE PREPARE stmt_drop_game_mode;

SET @sql_drop_world_id = (
    SELECT IF(
        (SELECT COUNT(*)
           FROM INFORMATION_SCHEMA.COLUMNS
          WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'canary_payments'
            AND COLUMN_NAME = 'world_id') = 1,
        'ALTER TABLE `canary_payments` DROP COLUMN `world_id`',
        'SELECT 1'
    )
);
PREPARE stmt_drop_world_id FROM @sql_drop_world_id;
EXECUTE stmt_drop_world_id;
DEALLOCATE PREPARE stmt_drop_world_id;

DELETE FROM `_migrations` WHERE `id` = 7;
