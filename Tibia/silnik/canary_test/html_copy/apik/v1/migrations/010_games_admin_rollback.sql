-- Migration 010 ROLLBACK: Games table admin management
-- Reverts: game_mode, login_port, description, visible, updated_at columns from games
-- Drops: admin_api_keys, admin_audit_log tables

ALTER TABLE `games`
    DROP COLUMN IF EXISTS `game_mode`,
    DROP COLUMN IF EXISTS `login_port`,
    DROP COLUMN IF EXISTS `description`,
    DROP COLUMN IF EXISTS `visible`,
    DROP COLUMN IF EXISTS `updated_at`;

DROP INDEX IF EXISTS `idx_games_game_mode` ON `games`;
DROP TABLE IF EXISTS `admin_audit_log`;
DROP TABLE IF EXISTS `admin_api_keys`;
