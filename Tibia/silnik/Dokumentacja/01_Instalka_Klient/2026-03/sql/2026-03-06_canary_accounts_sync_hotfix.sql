-- HOTFIX 2026-03-06
-- Cel:
-- 1) wyrownac canary.accounts do canaryaac.accounts po ID
-- 2) naprawic triggery sync canaryaac -> canary, aby pracowaly po ID (nie po name)
--
-- Uwaga operacyjna:
-- - najpierw wykonac backupy DB (mysqldump)
-- - NIE aktualizowac account_vipgroups przed utworzeniem docelowego account_id
--   (blad FK 1452). FK przepina sie automatycznie po UPDATE accounts.id.

START TRANSACTION;

-- Remap kont testowych (historycznie w canary pod id 83..96) do id 10..23
UPDATE canary.accounts SET id = 10 WHERE id = 83;
UPDATE canary.accounts SET id = 11 WHERE id = 84;
UPDATE canary.accounts SET id = 12 WHERE id = 85;
UPDATE canary.accounts SET id = 13 WHERE id = 86;
UPDATE canary.accounts SET id = 14 WHERE id = 87;
UPDATE canary.accounts SET id = 15 WHERE id = 88;
UPDATE canary.accounts SET id = 16 WHERE id = 89;
UPDATE canary.accounts SET id = 17 WHERE id = 90;
UPDATE canary.accounts SET id = 18 WHERE id = 91;
UPDATE canary.accounts SET id = 19 WHERE id = 92;
UPDATE canary.accounts SET id = 20 WHERE id = 93;
UPDATE canary.accounts SET id = 21 WHERE id = 94;
UPDATE canary.accounts SET id = 22 WHERE id = 95;
UPDATE canary.accounts SET id = 23 WHERE id = 96;

-- Synchronizacja pol po ID (name/email/password + podstawowe pola konta)
UPDATE canary.accounts c
JOIN canaryaac.accounts a ON a.id = c.id
SET
    c.name = a.name,
    c.password = COALESCE(a.engine_password_sha1, c.password),
    c.email = a.email,
    c.type = a.type,
    c.premdays = a.premdays,
    c.premdays_purchased = a.premdays_purchased,
    c.lastday = a.lastday,
    c.coins = a.coins,
    c.coins_transferable = a.coins_transferable,
    c.tournament_coins = a.tournament_coins,
    c.recruiter = a.recruiter,
    c.house_bid_id = a.house_bid_id,
    c.page_access = a.page_access;

-- Doinsertuj brakujace ID z master
INSERT INTO canary.accounts (
    id, name, password, email, type,
    premdays, premdays_purchased, lastday,
    coins, coins_transferable, tournament_coins,
    creation, recruiter, house_bid_id, page_access
)
SELECT
    a.id,
    a.name,
    COALESCE(a.engine_password_sha1, '0'),
    a.email,
    a.type,
    a.premdays,
    a.premdays_purchased,
    a.lastday,
    a.coins,
    a.coins_transferable,
    a.tournament_coins,
    a.creation,
    a.recruiter,
    a.house_bid_id,
    a.page_access
FROM canaryaac.accounts a
LEFT JOIN canary.accounts c ON c.id = a.id
WHERE c.id IS NULL;

COMMIT;

DROP TRIGGER IF EXISTS canaryaac.acc_sync_ai;
DROP TRIGGER IF EXISTS canaryaac.acc_sync_au;

DELIMITER //
CREATE TRIGGER canaryaac.acc_sync_ai
AFTER INSERT ON canaryaac.accounts
FOR EACH ROW
BEGIN
    INSERT INTO canary.accounts (
        id, name, password, email, type,
        premdays, premdays_purchased, lastday,
        coins, coins_transferable, tournament_coins,
        creation, recruiter, house_bid_id, page_access
    ) VALUES (
        NEW.id,
        NEW.name,
        COALESCE(NEW.engine_password_sha1, '0'),
        NEW.email,
        NEW.type,
        NEW.premdays,
        NEW.premdays_purchased,
        NEW.lastday,
        NEW.coins,
        NEW.coins_transferable,
        NEW.tournament_coins,
        NEW.creation,
        NEW.recruiter,
        NEW.house_bid_id,
        NEW.page_access
    ) ON DUPLICATE KEY UPDATE
        name = NEW.name,
        password = COALESCE(NEW.engine_password_sha1, canary.accounts.password),
        email = NEW.email,
        type = NEW.type,
        premdays = NEW.premdays,
        premdays_purchased = NEW.premdays_purchased,
        lastday = NEW.lastday,
        coins = NEW.coins,
        coins_transferable = NEW.coins_transferable,
        tournament_coins = NEW.tournament_coins,
        creation = NEW.creation,
        recruiter = NEW.recruiter,
        house_bid_id = NEW.house_bid_id,
        page_access = NEW.page_access;
END //

CREATE TRIGGER canaryaac.acc_sync_au
AFTER UPDATE ON canaryaac.accounts
FOR EACH ROW
BEGIN
    UPDATE canary.accounts
    SET
        name = NEW.name,
        password = COALESCE(NEW.engine_password_sha1, password),
        email = NEW.email,
        type = NEW.type,
        premdays = NEW.premdays,
        premdays_purchased = NEW.premdays_purchased,
        lastday = NEW.lastday,
        coins = NEW.coins,
        coins_transferable = NEW.coins_transferable,
        tournament_coins = NEW.tournament_coins,
        creation = NEW.creation,
        recruiter = NEW.recruiter,
        house_bid_id = NEW.house_bid_id,
        page_access = NEW.page_access
    WHERE id = NEW.id;
END //
DELIMITER ;

-- Smoke test (manual):
-- 1) INSERT konto testowe do canaryaac.accounts
-- 2) UPDATE email/nazwa
-- 3) DELETE konto
-- 4) Sprawdz, czy canary + canary_modern odzwierciedlaja wszystkie operacje
