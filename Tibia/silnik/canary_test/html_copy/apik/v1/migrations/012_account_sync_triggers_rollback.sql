-- Rollback migration 012: drop account sync triggers managed by this migration.
-- Data rows are not rolled back; only trigger definitions are removed.

SET @has_source_accounts := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'canaryaac'
      AND TABLE_NAME = 'accounts'
);

SET @sql_drop_acc_sync_ai := IF(@has_source_accounts = 1, 'DROP TRIGGER IF EXISTS canaryaac.acc_sync_ai', 'SELECT 1');
PREPARE stmt_drop_acc_sync_ai FROM @sql_drop_acc_sync_ai;
EXECUTE stmt_drop_acc_sync_ai;
DEALLOCATE PREPARE stmt_drop_acc_sync_ai;

SET @sql_drop_acc_sync_au := IF(@has_source_accounts = 1, 'DROP TRIGGER IF EXISTS canaryaac.acc_sync_au', 'SELECT 1');
PREPARE stmt_drop_acc_sync_au FROM @sql_drop_acc_sync_au;
EXECUTE stmt_drop_acc_sync_au;
DEALLOCATE PREPARE stmt_drop_acc_sync_au;

SET @sql_drop_acc_sync_ad := IF(@has_source_accounts = 1, 'DROP TRIGGER IF EXISTS canaryaac.acc_sync_ad', 'SELECT 1');
PREPARE stmt_drop_acc_sync_ad FROM @sql_drop_acc_sync_ad;
EXECUTE stmt_drop_acc_sync_ad;
DEALLOCATE PREPARE stmt_drop_acc_sync_ad;

SET @sql_drop_modern_sync_ai := IF(@has_source_accounts = 1, 'DROP TRIGGER IF EXISTS canaryaac.modern_sync_ai', 'SELECT 1');
PREPARE stmt_drop_modern_sync_ai FROM @sql_drop_modern_sync_ai;
EXECUTE stmt_drop_modern_sync_ai;
DEALLOCATE PREPARE stmt_drop_modern_sync_ai;

SET @sql_drop_modern_sync_au := IF(@has_source_accounts = 1, 'DROP TRIGGER IF EXISTS canaryaac.modern_sync_au', 'SELECT 1');
PREPARE stmt_drop_modern_sync_au FROM @sql_drop_modern_sync_au;
EXECUTE stmt_drop_modern_sync_au;
DEALLOCATE PREPARE stmt_drop_modern_sync_au;

SET @sql_drop_modern_sync_ad := IF(@has_source_accounts = 1, 'DROP TRIGGER IF EXISTS canaryaac.modern_sync_ad', 'SELECT 1');
PREPARE stmt_drop_modern_sync_ad FROM @sql_drop_modern_sync_ad;
EXECUTE stmt_drop_modern_sync_ad;
DEALLOCATE PREPARE stmt_drop_modern_sync_ad;

DELETE FROM `_migrations` WHERE `id` = 12;
