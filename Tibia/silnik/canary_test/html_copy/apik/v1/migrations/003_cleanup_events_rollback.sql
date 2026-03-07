-- Rollback 003: cleanup events
-- Drops:
--   - cleanup_expired_nonces
--   - cleanup_expired_tokens
--   - cleanup_expired_sessions

CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP EVENT IF EXISTS `cleanup_expired_nonces`;
DROP EVENT IF EXISTS `cleanup_expired_tokens`;
DROP EVENT IF EXISTS `cleanup_expired_sessions`;

DELETE FROM `_migrations` WHERE `id` = 3;
