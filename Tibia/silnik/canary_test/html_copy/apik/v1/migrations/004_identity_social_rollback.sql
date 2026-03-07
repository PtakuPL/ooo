-- Rollback 004: identity + social login + sync tables
-- Drops:
--   - account_sync_tokens
--   - oauth_states
--   - account_identity_links
--   - idx_accounts_email (if exists)

CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `account_sync_tokens`;
DROP TABLE IF EXISTS `oauth_states`;
DROP TABLE IF EXISTS `account_identity_links`;

SET @idx_exists := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'accounts'
      AND INDEX_NAME = 'idx_accounts_email'
);
SET @sql_drop_idx := IF(@idx_exists > 0, 'DROP INDEX idx_accounts_email ON accounts', 'SELECT 1');
PREPARE stmt_drop_idx FROM @sql_drop_idx;
EXECUTE stmt_drop_idx;
DEALLOCATE PREPARE stmt_drop_idx;

DELETE FROM `_migrations` WHERE `id` = 4;
