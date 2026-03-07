-- Migration 009 rollback: remove payment provider idempotency and ledger tables

DROP TABLE IF EXISTS `payment_ledger_entries`;
DROP TABLE IF EXISTS `payment_provider_events`;

DELETE FROM `_migrations`
WHERE `id` = 9;
