-- Migration 003: cleanup events
-- Requires:
--   - EVENT privilege
--   - event_scheduler enabled on MySQL/MariaDB
--
-- NOTE:
--   migrate.php attempts to enable event_scheduler before applying this migration.
--   If scheduler cannot be enabled by permissions, events are still created and
--   can be activated later by DBA (SET GLOBAL event_scheduler = ON;).

CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE EVENT IF NOT EXISTS `cleanup_expired_nonces`
ON SCHEDULE EVERY 15 MINUTE
DO
DELETE FROM `ticket_nonces` WHERE `expires_at` < UNIX_TIMESTAMP();

CREATE EVENT IF NOT EXISTS `cleanup_expired_tokens`
ON SCHEDULE EVERY 15 MINUTE
DO
DELETE FROM `launch_tokens` WHERE `expires_at` < NOW();

CREATE EVENT IF NOT EXISTS `cleanup_expired_sessions`
ON SCHEDULE EVERY 15 MINUTE
DO
DELETE FROM `ticket_sessions` WHERE `expires_at` < UNIX_TIMESTAMP();

INSERT INTO `_migrations` (`id`, `name`)
VALUES (3, '003_cleanup_events')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
