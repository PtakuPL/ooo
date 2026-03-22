-- Rollback migration 011: Remove verifier_hash from account_sync_tokens

SET @col_exists := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'account_sync_tokens'
      AND COLUMN_NAME = 'verifier_hash'
);

SET @sql_drop := IF(
    @col_exists = 1,
    'ALTER TABLE `account_sync_tokens` DROP COLUMN `verifier_hash`',
    'SELECT 1'
);
PREPARE stmt_drop FROM @sql_drop;
EXECUTE stmt_drop;
DEALLOCATE PREPARE stmt_drop;

DELETE FROM `_migrations` WHERE `id` = 11;
