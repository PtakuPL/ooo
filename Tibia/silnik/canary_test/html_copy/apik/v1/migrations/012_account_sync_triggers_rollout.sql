-- Migration 012: Manage account sync triggers in migration system (K180)
-- Goal: keep canaryaac -> canary/canary_modern sync reproducible after DB rebuild.

SET @has_source_accounts := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'canaryaac'
      AND TABLE_NAME = 'accounts'
);

SET @has_canary_accounts := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'canary'
      AND TABLE_NAME = 'accounts'
);

SET @has_modern_accounts := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'canary_modern'
      AND TABLE_NAME = 'accounts'
);

-- Seed/repair canary accounts.
SET @sql_seed_canary := IF(
    @has_source_accounts = 1 AND @has_canary_accounts = 1,
    'INSERT INTO canary.accounts (id, name, password, email, type, creation)
     SELECT a.id, a.name, COALESCE(a.engine_password_sha1, ''0''), a.email, a.type, UNIX_TIMESTAMP(a.creation)
     FROM canaryaac.accounts a
     ON DUPLICATE KEY UPDATE
       name = VALUES(name),
       password = VALUES(password),
       email = VALUES(email),
       type = VALUES(type)',
    'SELECT 1'
);
PREPARE stmt_seed_canary FROM @sql_seed_canary;
EXECUTE stmt_seed_canary;
DEALLOCATE PREPARE stmt_seed_canary;

-- Seed/repair canary_modern accounts.
SET @sql_seed_modern := IF(
    @has_source_accounts = 1 AND @has_modern_accounts = 1,
    'INSERT INTO canary_modern.accounts (id, name, password, email, type, creation)
     SELECT a.id, a.name, COALESCE(a.engine_password_sha1, ''0''), a.email, a.type, UNIX_TIMESTAMP(a.creation)
     FROM canaryaac.accounts a
     ON DUPLICATE KEY UPDATE
       name = VALUES(name),
       password = VALUES(password),
       email = VALUES(email),
       type = VALUES(type)',
    'SELECT 1'
);
PREPARE stmt_seed_modern FROM @sql_seed_modern;
EXECUTE stmt_seed_modern;
DEALLOCATE PREPARE stmt_seed_modern;

-- canary triggers: drop old definitions first.
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

-- modern triggers: drop old definitions first.
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

-- Recreate canary insert trigger.
SET @sql_create_acc_sync_ai := IF(
    @has_source_accounts = 1 AND @has_canary_accounts = 1,
    'CREATE TRIGGER canaryaac.acc_sync_ai
     AFTER INSERT ON canaryaac.accounts
     FOR EACH ROW
     INSERT INTO canary.accounts (id, name, password, email, type, creation)
     VALUES (NEW.id, NEW.name, COALESCE(NEW.engine_password_sha1, ''0''), NEW.email, NEW.type, UNIX_TIMESTAMP(NEW.creation))
     ON DUPLICATE KEY UPDATE
       name = NEW.name,
       password = COALESCE(NEW.engine_password_sha1, canary.accounts.password),
       email = NEW.email,
       type = NEW.type',
    'SELECT 1'
);
PREPARE stmt_create_acc_sync_ai FROM @sql_create_acc_sync_ai;
EXECUTE stmt_create_acc_sync_ai;
DEALLOCATE PREPARE stmt_create_acc_sync_ai;

-- Recreate canary update trigger.
SET @sql_create_acc_sync_au := IF(
    @has_source_accounts = 1 AND @has_canary_accounts = 1,
    'CREATE TRIGGER canaryaac.acc_sync_au
     AFTER UPDATE ON canaryaac.accounts
     FOR EACH ROW
     INSERT INTO canary.accounts (id, name, password, email, type, creation)
     VALUES (NEW.id, NEW.name, COALESCE(NEW.engine_password_sha1, ''0''), NEW.email, NEW.type, UNIX_TIMESTAMP(NEW.creation))
     ON DUPLICATE KEY UPDATE
       name = NEW.name,
       password = COALESCE(NEW.engine_password_sha1, canary.accounts.password),
       email = NEW.email,
       type = NEW.type',
    'SELECT 1'
);
PREPARE stmt_create_acc_sync_au FROM @sql_create_acc_sync_au;
EXECUTE stmt_create_acc_sync_au;
DEALLOCATE PREPARE stmt_create_acc_sync_au;

-- Recreate canary delete trigger.
SET @sql_create_acc_sync_ad := IF(
    @has_source_accounts = 1 AND @has_canary_accounts = 1,
    'CREATE TRIGGER canaryaac.acc_sync_ad
     AFTER DELETE ON canaryaac.accounts
     FOR EACH ROW
     DELETE FROM canary.accounts WHERE id = OLD.id',
    'SELECT 1'
);
PREPARE stmt_create_acc_sync_ad FROM @sql_create_acc_sync_ad;
EXECUTE stmt_create_acc_sync_ad;
DEALLOCATE PREPARE stmt_create_acc_sync_ad;

-- Recreate modern insert trigger.
SET @sql_create_modern_sync_ai := IF(
    @has_source_accounts = 1 AND @has_modern_accounts = 1,
    'CREATE TRIGGER canaryaac.modern_sync_ai
     AFTER INSERT ON canaryaac.accounts
     FOR EACH ROW
     INSERT INTO canary_modern.accounts (id, name, password, email, type, creation)
     VALUES (NEW.id, NEW.name, COALESCE(NEW.engine_password_sha1, ''0''), NEW.email, NEW.type, UNIX_TIMESTAMP(NEW.creation))
     ON DUPLICATE KEY UPDATE
       name = NEW.name,
       password = COALESCE(NEW.engine_password_sha1, canary_modern.accounts.password),
       email = NEW.email,
       type = NEW.type',
    'SELECT 1'
);
PREPARE stmt_create_modern_sync_ai FROM @sql_create_modern_sync_ai;
EXECUTE stmt_create_modern_sync_ai;
DEALLOCATE PREPARE stmt_create_modern_sync_ai;

-- Recreate modern update trigger.
SET @sql_create_modern_sync_au := IF(
    @has_source_accounts = 1 AND @has_modern_accounts = 1,
    'CREATE TRIGGER canaryaac.modern_sync_au
     AFTER UPDATE ON canaryaac.accounts
     FOR EACH ROW
     INSERT INTO canary_modern.accounts (id, name, password, email, type, creation)
     VALUES (NEW.id, NEW.name, COALESCE(NEW.engine_password_sha1, ''0''), NEW.email, NEW.type, UNIX_TIMESTAMP(NEW.creation))
     ON DUPLICATE KEY UPDATE
       name = NEW.name,
       password = COALESCE(NEW.engine_password_sha1, canary_modern.accounts.password),
       email = NEW.email,
       type = NEW.type',
    'SELECT 1'
);
PREPARE stmt_create_modern_sync_au FROM @sql_create_modern_sync_au;
EXECUTE stmt_create_modern_sync_au;
DEALLOCATE PREPARE stmt_create_modern_sync_au;

-- Recreate modern delete trigger.
SET @sql_create_modern_sync_ad := IF(
    @has_source_accounts = 1 AND @has_modern_accounts = 1,
    'CREATE TRIGGER canaryaac.modern_sync_ad
     AFTER DELETE ON canaryaac.accounts
     FOR EACH ROW
     DELETE FROM canary_modern.accounts WHERE id = OLD.id',
    'SELECT 1'
);
PREPARE stmt_create_modern_sync_ad FROM @sql_create_modern_sync_ad;
EXECUTE stmt_create_modern_sync_ad;
DEALLOCATE PREPARE stmt_create_modern_sync_ad;

INSERT INTO `_migrations` (`id`, `name`)
VALUES (12, '012_account_sync_triggers')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
