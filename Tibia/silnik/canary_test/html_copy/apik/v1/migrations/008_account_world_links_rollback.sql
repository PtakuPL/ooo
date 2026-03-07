-- Migration 008 rollback: remove account_world_links mapping table

DROP TABLE IF EXISTS `account_world_links`;

DELETE FROM `_migrations`
WHERE `id` = 8;
