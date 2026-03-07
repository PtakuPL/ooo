-- Rollback 005: OAuth rate-limit buckets
-- Drops:
--   - oauth_rate_limits

CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `oauth_rate_limits`;

DELETE FROM `_migrations` WHERE `id` = 5;

