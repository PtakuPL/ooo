-- Rollback 001: ticket-gate core tables
-- Drops:
--   - ticket_sessions
--   - ticket_nonces
-- Keeps:
--   - _migrations (metadata table remains)

CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `ticket_sessions`;
DROP TABLE IF EXISTS `ticket_nonces`;

DELETE FROM `_migrations` WHERE `id` = 1;
