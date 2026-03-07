-- Migration 002: launcher tables
-- Creates:
--   - launch_tokens
--   - manifest_versions

CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `launch_tokens` (
    `token`             VARCHAR(64) NOT NULL,
    `launcher_version`  VARCHAR(20) NOT NULL,
    `files_hash`        VARCHAR(64) NOT NULL,
    `manifest_version`  VARCHAR(20) NOT NULL DEFAULT '0.0.1',
    `client_ip`         VARCHAR(45) NOT NULL,
    `created_at`        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at`        TIMESTAMP   NOT NULL,
    PRIMARY KEY (`token`),
    INDEX `idx_expires` (`expires_at`),
    INDEX `idx_client_ip` (`client_ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `manifest_versions` (
    `id`           INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `version`      VARCHAR(20)     NOT NULL,
    `channel`      VARCHAR(20)     NOT NULL DEFAULT 'stable',
    `files_hash`   VARCHAR(64)     NOT NULL COMMENT 'expected hash of all files for this version',
    `file_count`   INT UNSIGNED    NOT NULL DEFAULT 0,
    `total_size`   BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `created_at`   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `is_active`    TINYINT(1)      NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_version_channel` (`version`, `channel`),
    INDEX `idx_active_channel` (`is_active`, `channel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `_migrations` (`id`, `name`)
VALUES (2, '002_launcher_tables')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
