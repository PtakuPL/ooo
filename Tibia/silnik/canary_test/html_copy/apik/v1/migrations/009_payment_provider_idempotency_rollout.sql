-- Migration 009: payment provider callbacks idempotency + payment ledger audit

CREATE TABLE IF NOT EXISTS `payment_provider_events` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `provider` VARCHAR(32) NOT NULL,
    `event_type` VARCHAR(32) NOT NULL DEFAULT 'callback',
    `provider_txn_id` VARCHAR(128) NOT NULL,
    `reference` VARCHAR(128) DEFAULT NULL,
    `game_mode` VARCHAR(32) NOT NULL DEFAULT 'classic74',
    `world_id` INT(11) NOT NULL DEFAULT 0,
    `signature_valid` TINYINT(1) NOT NULL DEFAULT 0,
    `event_hash` CHAR(64) NOT NULL,
    `payload_json` LONGTEXT DEFAULT NULL,
    `status` VARCHAR(32) NOT NULL DEFAULT 'received',
    `error_message` VARCHAR(255) DEFAULT NULL,
    `received_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `processed_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_provider_txn_event` (`provider`, `provider_txn_id`, `event_type`),
    KEY `idx_reference` (`reference`),
    KEY `idx_status` (`status`),
    KEY `idx_world` (`game_mode`, `world_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `payment_ledger_entries` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `account_id` INT(11) UNSIGNED NOT NULL,
    `payment_id` INT(11) UNSIGNED DEFAULT NULL,
    `provider` VARCHAR(32) NOT NULL,
    `provider_txn_id` VARCHAR(128) NOT NULL,
    `entry_type` VARCHAR(32) NOT NULL DEFAULT 'credit',
    `game_mode` VARCHAR(32) NOT NULL DEFAULT 'classic74',
    `world_id` INT(11) NOT NULL DEFAULT 0,
    `coins_delta` INT(11) NOT NULL DEFAULT 0,
    `amount_gross` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    `currency` VARCHAR(8) NOT NULL DEFAULT 'BRL',
    `metadata_json` LONGTEXT DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_provider_txn_entry` (`provider`, `provider_txn_id`, `entry_type`),
    KEY `idx_account_created` (`account_id`, `created_at`),
    KEY `idx_world_created` (`game_mode`, `world_id`, `created_at`),
    KEY `idx_payment_id` (`payment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `_migrations` (`id`, `name`)
VALUES (9, '009_payment_provider_idempotency')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
