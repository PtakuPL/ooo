-- Migration 004: identity + social login + cross-channel sync
-- Creates:
--   - account_identity_links   (provider identities linked to local account)
--   - oauth_states             (short-lived OAuth state/PKCE data)
--   - account_sync_tokens      (one-time WWW <-> launcher sync tokens)
--   - idx_accounts_email       (non-unique lookup index; UNIQUE handled in separate dedupe step)

CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `account_identity_links` (
    `id`                    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `account_id`            INT UNSIGNED    NOT NULL,
    `provider`              VARCHAR(32)     NOT NULL,
    `provider_user_id`      VARCHAR(191)    NOT NULL,
    `provider_email`        VARCHAR(255)    DEFAULT NULL,
    `provider_display_name` VARCHAR(191)    DEFAULT NULL,
    `provider_avatar_url`   VARCHAR(512)    DEFAULT NULL,
    `is_primary`            TINYINT(1)      NOT NULL DEFAULT 0,
    `metadata_json`         LONGTEXT        DEFAULT NULL,
    `linked_at`             TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_login_at`         TIMESTAMP       NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_provider_user` (`provider`, `provider_user_id`),
    KEY `idx_account_provider` (`account_id`, `provider`),
    KEY `idx_provider_email` (`provider`, `provider_email`),
    KEY `idx_linked_at` (`linked_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `oauth_states` (
    `state`                 VARCHAR(128)  NOT NULL,
    `provider`              VARCHAR(32)   NOT NULL,
    `code_verifier_hash`    VARCHAR(128)  DEFAULT NULL,
    `redirect_uri`          VARCHAR(512)  DEFAULT NULL,
    `requested_account_id`  INT UNSIGNED  DEFAULT NULL,
    `created_at`            TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at`            INT UNSIGNED  NOT NULL,
    `consumed_at`           TIMESTAMP     NULL DEFAULT NULL,
    PRIMARY KEY (`state`),
    KEY `idx_provider_expires` (`provider`, `expires_at`),
    KEY `idx_oauth_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `account_sync_tokens` (
    `token`         VARCHAR(128)  NOT NULL,
    `account_id`    INT UNSIGNED  NOT NULL,
    `source`        VARCHAR(32)   NOT NULL,
    `target`        VARCHAR(32)   NOT NULL,
    `created_at`    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at`    INT UNSIGNED  NOT NULL,
    `used_at`       TIMESTAMP     NULL DEFAULT NULL,
    `metadata_json` LONGTEXT      DEFAULT NULL,
    PRIMARY KEY (`token`),
    KEY `idx_sync_account` (`account_id`),
    KEY `idx_sync_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add non-unique email index for fast lookup.
-- UNIQUE(email) is intentionally deferred because current data may contain duplicates.
SET @idx_exists := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'accounts'
      AND INDEX_NAME = 'idx_accounts_email'
);
SET @sql_idx := IF(@idx_exists = 0, 'CREATE INDEX idx_accounts_email ON accounts (email)', 'SELECT 1');
PREPARE stmt_idx FROM @sql_idx;
EXECUTE stmt_idx;
DEALLOCATE PREPARE stmt_idx;

INSERT INTO `_migrations` (`id`, `name`)
VALUES (4, '004_identity_social')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
