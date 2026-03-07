-- Migration 001: ticket-gate core tables
-- Creates:
--   - _migrations
--   - ticket_nonces
--   - ticket_sessions

CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ticket_nonces` (
    `nonce`      VARCHAR(64)  NOT NULL,
    `account_id` INT          NOT NULL DEFAULT 0,
    `expires_at` INT UNSIGNED NOT NULL,
    `created_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`nonce`),
    INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ticket_sessions` (
    `session_key` VARCHAR(128) NOT NULL,
    `account_id`  INT          NOT NULL,
    `game_mode`   VARCHAR(32)  NOT NULL DEFAULT 'modern',
    `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at`  INT UNSIGNED NOT NULL,
    PRIMARY KEY (`session_key`),
    INDEX `idx_account` (`account_id`),
    INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `_migrations` (`id`, `name`)
VALUES (1, '001_ticket_gate')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
