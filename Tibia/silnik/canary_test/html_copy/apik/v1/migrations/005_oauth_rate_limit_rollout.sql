-- Migration 005: OAuth rate-limit buckets
-- Creates:
--   - oauth_rate_limits (short-lived counters for OAuth abuse protection)

CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `oauth_rate_limits` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `bucket`      VARCHAR(64)     NOT NULL,
    `key_hash`    VARCHAR(64)     NOT NULL,
    `created_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at`  INT UNSIGNED    NOT NULL,
    `metadata_json` LONGTEXT      DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_bucket_key_expires` (`bucket`, `key_hash`, `expires_at`),
    KEY `idx_oauth_rate_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `_migrations` (`id`, `name`)
VALUES (5, '005_oauth_rate_limit')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

