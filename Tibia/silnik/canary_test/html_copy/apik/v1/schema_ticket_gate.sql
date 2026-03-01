-- B4: Tabela ticket_nonces — jednorazowe nonce'y do ticket-gate HMAC
-- Replay protection: Canary konsumuje nonce server-side (in-memory),
-- ale PHP insertuje tu nonce przy generowaniu ticketu dla audyt/cleanup.
-- Atomowe DELETE w ticket.php NIE jest potrzebne (nonce jest w payload, Canary weryfikuje),
-- tabela służy jako backup/audit + cleanup expired.

CREATE TABLE IF NOT EXISTS `ticket_nonces` (
    `nonce`      VARCHAR(64)  NOT NULL,
    `account_id` INT          NOT NULL DEFAULT 0,
    `expires_at` INT UNSIGNED NOT NULL,
    `created_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`nonce`),
    INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- B4: Tabela ticket_sessions — sesje logowania z gameMode
-- Po udanym loginie login.php tworzy rekord z session_key + gameMode.
-- ticket.php weryfikuje session_key i pobiera gameMode/account_id.

CREATE TABLE IF NOT EXISTS `ticket_sessions` (
    `session_key`    VARCHAR(128) NOT NULL,
    `account_id`     INT          NOT NULL,
    `game_mode`      VARCHAR(32)  NOT NULL DEFAULT 'modern',
    `created_at`     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at`     INT UNSIGNED NOT NULL,
    PRIMARY KEY (`session_key`),
    INDEX `idx_account` (`account_id`),
    INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
