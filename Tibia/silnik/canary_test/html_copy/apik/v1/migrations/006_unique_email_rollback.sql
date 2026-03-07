-- 006_unique_email_rollback.sql
-- Luka #6: Wycofanie UNIQUE na accounts.email

ALTER TABLE accounts DROP INDEX uq_accounts_email;
