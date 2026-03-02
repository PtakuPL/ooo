-- ============================================================================
-- Ticket-Gate: Migracja bazy danych
-- Wersja: 1.0
-- Data: 2026-03
-- Opis: Tabele wymagane przez system Ticket-Gate (zabezpieczenie klienta)
--       Dotyczy: launcher-token.php, login.php, ticket.php, ticket_validator.cpp
-- ============================================================================
-- UWAGA: Uruchom na bazie `canaryaac` (lub tej, którą wskazuje DB_NAME w .env).
-- Wszystkie tabele używają InnoDB + UTF8MB4.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. launch_tokens — jednorazowe tokeny wystawiane przez launcher-token.php
--    Konsumowane (DELETE) przez login.php po użyciu.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `launch_tokens` (
    `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `token`             VARCHAR(128)    NOT NULL,
    `launcher_version`  VARCHAR(32)     NOT NULL DEFAULT '',
    `files_hash`        VARCHAR(128)    NOT NULL DEFAULT '',
    `manifest_version`  VARCHAR(64)     NOT NULL DEFAULT '',
    `client_ip`         VARCHAR(45)     NOT NULL DEFAULT '',
    `created_at`        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at`        DATETIME        NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_token` (`token`),
    KEY `idx_client_ip_created` (`client_ip`, `created_at`),
    KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 2. manifest_versions — wersje manifestu klienta (pliki + hash)
--    Używane przez launcher-token.php do walidacji files_hash.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `manifest_versions` (
    `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `version`       VARCHAR(64)     NOT NULL DEFAULT '',
    `channel`       VARCHAR(32)     NOT NULL DEFAULT 'stable',
    `files_hash`    VARCHAR(128)    NOT NULL,
    `is_active`     TINYINT(1)      NOT NULL DEFAULT 1,
    `created_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_version_channel_active` (`version`, `channel`, `is_active`),
    KEY `idx_channel_active_id` (`channel`, `is_active`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 3. ticket_sessions — sesje logowania z gameMode
--    Tworzone przez login.php, czytane przez ticket.php.
--    Jednorazowe (DELETE po użyciu przez ticket.php).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `ticket_sessions` (
    `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `session_key`   VARCHAR(128)    NOT NULL,
    `account_id`    INT UNSIGNED    NOT NULL,
    `game_mode`     VARCHAR(32)     NOT NULL DEFAULT '',
    `created_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at`    DATETIME        NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_session_key` (`session_key`),
    KEY `idx_expires_at` (`expires_at`),
    KEY `idx_account_id` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 4. ticket_nonces — jednorazowe nonce z ticketów HMAC
--    Zapisywane przez ticket.php (PHP) i ticket_validator.cpp (C++).
--    Zapobiegają replay attack.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `ticket_nonces` (
    `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `nonce`         VARCHAR(64)     NOT NULL,
    `account_id`    INT UNSIGNED    NOT NULL DEFAULT 0,
    `created_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at`    DATETIME        NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_nonce` (`nonce`),
    KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 5. ALTER players — dodaj kolumnę world_id (FIX-AUD16)
--    Pozwala przypisać gracza do konkretnego świata (0=classic74, 1=modern).
--    Domyślnie 0 (classic) — istniejące postacie zachowują dotychczasowy świat.
-- ---------------------------------------------------------------------------
-- Bezpieczne dodanie kolumny (ignoruje błąd jeśli już istnieje):
SET @sql_add_world_id = (
    SELECT IF(
        (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
         WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'players' AND COLUMN_NAME = 'world_id') = 0,
        'ALTER TABLE `players` ADD COLUMN `world_id` TINYINT UNSIGNED NOT NULL DEFAULT 0 AFTER `deletion`',
        'SELECT 1 /* world_id already exists */'
    )
);
PREPARE stmt_world_id FROM @sql_add_world_id;
EXECUTE stmt_world_id;
DEALLOCATE PREPARE stmt_world_id;

-- ---------------------------------------------------------------------------
-- 6. Czyszczenie wygasłych rekordów (opcjonalny EVENT scheduler)
--    Uruchom: SET GLOBAL event_scheduler = ON;
-- ---------------------------------------------------------------------------
-- Usuwaj wygasłe tokeny, sesje i nonce co 5 minut:
/*
CREATE EVENT IF NOT EXISTS `evt_ticket_gate_cleanup`
    ON SCHEDULE EVERY 5 MINUTE
    DO
    BEGIN
        DELETE FROM `launch_tokens`   WHERE `expires_at` < NOW();
        DELETE FROM `ticket_sessions` WHERE `expires_at` < NOW();
        DELETE FROM `ticket_nonces`   WHERE `expires_at` < NOW();
    END;
*/

-- ---------------------------------------------------------------------------
-- 7. Przykładowy wpis manifest_versions (do dostosowania)
-- ---------------------------------------------------------------------------
-- INSERT INTO `manifest_versions` (`version`, `channel`, `files_hash`, `is_active`)
-- VALUES ('1.0.0', 'stable', 'sha256:abcdef1234567890...', 1);

-- ============================================================================
-- Koniec migracji ticket-gate
-- ============================================================================
