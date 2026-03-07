-- ============================================================================
-- Migracja 008: Synchronizacja kont canaryaac → canary_modern
-- Data: 2026-03-08
-- Cel: K47 — Opcja B (2 bazy osobne, konta współdzielone przez triggery)
--
-- Istniejące triggery na canaryaac.accounts:
--   - oncreate_accounts (AFTER INSERT → tworzy vipgroups w canaryaac)
--   - acc_sync_ai (AFTER INSERT → sync do canary.accounts)
--   - acc_sync_au (AFTER UPDATE → sync do canary.accounts)
--
-- Nowe triggery:
--   - modern_sync_ai (AFTER INSERT → sync do canary_modern.accounts)
--   - modern_sync_au (AFTER UPDATE → sync do canary_modern.accounts)
--   - modern_sync_ad (AFTER DELETE → usunięcie z canary_modern.accounts)
--
-- Pola synchronizowane (logowanie):
--   id, name, password (z engine_password_sha1), email, type
-- Pola NIE synchronizowane (per-serwer):
--   premdays, lastday, coins, coins_transferable, tournament_coins, house_bid_id
-- ============================================================================

-- -------------------------------------------------------
-- 1) INITIAL SYNC: wgraj brakujące konta z canaryaac
-- -------------------------------------------------------
INSERT INTO canary_modern.accounts (id, name, password, email, type, creation)
SELECT
    a.id,
    a.name,
    COALESCE(a.engine_password_sha1, '0'),
    a.email,
    a.type,
    UNIX_TIMESTAMP(a.creation)
FROM canaryaac.accounts a
WHERE a.id NOT IN (SELECT id FROM canary_modern.accounts);

-- Update istniejącego konta id=6 (ptakukolo) — upewnij się że hasło jest zsyncowane
UPDATE canary_modern.accounts m
JOIN canaryaac.accounts a ON m.id = a.id
SET
    m.name     = a.name,
    m.password = COALESCE(a.engine_password_sha1, m.password),
    m.email    = a.email,
    m.type     = a.type;

-- Ustaw AUTO_INCREMENT na canary_modern powyżej max(id) z canaryaac
SET @max_id = (SELECT MAX(id) FROM canaryaac.accounts);
SET @sql = CONCAT('ALTER TABLE canary_modern.accounts AUTO_INCREMENT = ', @max_id + 1);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -------------------------------------------------------
-- 2) TRIGGER: AFTER INSERT → canary_modern
-- -------------------------------------------------------
DELIMITER //

DROP TRIGGER IF EXISTS canaryaac.modern_sync_ai //
CREATE TRIGGER canaryaac.modern_sync_ai
AFTER INSERT ON canaryaac.accounts
FOR EACH ROW
BEGIN
    INSERT INTO canary_modern.accounts
        (id, name, password, email, type, creation)
    VALUES
        (NEW.id, NEW.name, COALESCE(NEW.engine_password_sha1, '0'), NEW.email, NEW.type,
         UNIX_TIMESTAMP(NEW.creation))
    ON DUPLICATE KEY UPDATE
        name     = NEW.name,
        password = COALESCE(NEW.engine_password_sha1, canary_modern.accounts.password),
        email    = NEW.email,
        type     = NEW.type;
END //

-- -------------------------------------------------------
-- 3) TRIGGER: AFTER UPDATE → canary_modern
-- -------------------------------------------------------
DROP TRIGGER IF EXISTS canaryaac.modern_sync_au //
CREATE TRIGGER canaryaac.modern_sync_au
AFTER UPDATE ON canaryaac.accounts
FOR EACH ROW
BEGIN
    UPDATE canary_modern.accounts
    SET
        name     = NEW.name,
        password = COALESCE(NEW.engine_password_sha1, password),
        email    = NEW.email,
        type     = NEW.type
    WHERE id = NEW.id;
END //

-- -------------------------------------------------------
-- 4) TRIGGER: AFTER DELETE → canary_modern
-- -------------------------------------------------------
DROP TRIGGER IF EXISTS canaryaac.modern_sync_ad //
CREATE TRIGGER canaryaac.modern_sync_ad
AFTER DELETE ON canaryaac.accounts
FOR EACH ROW
BEGIN
    DELETE FROM canary_modern.accounts WHERE id = OLD.id;
END //

DELIMITER ;

-- -------------------------------------------------------
-- 5) WERYFIKACJA
-- -------------------------------------------------------
SELECT 'canaryaac' AS db, COUNT(*) AS konta FROM canaryaac.accounts
UNION ALL
SELECT 'canary_modern', COUNT(*) FROM canary_modern.accounts;
