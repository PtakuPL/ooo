-- Rollback 002: launcher tables
-- Drops:
--   - manifest_versions
--   - launch_tokens

CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `manifest_versions`;
DROP TABLE IF EXISTS `launch_tokens`;

DELETE FROM `_migrations` WHERE `id` = 2;
