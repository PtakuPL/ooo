-- 006_unique_email_rollout.sql
-- Luka #6: Dodanie UNIQUE na accounts.email
-- Krok 1: Usun puste/zduplikowane konta bez nazwy i bez postaci (test setup duplicates)
-- Krok 2: Dodaj indeks UNIQUE

-- Usun duplikaty: zostawia rekord z najnizszym id, usuwa resztę
-- (tylko konta bez postaci i bez nazwy)
DELETE a FROM accounts a
  LEFT JOIN players p ON p.account_id = a.id
  WHERE a.id NOT IN (
    SELECT min_id FROM (
      SELECT MIN(id) AS min_id FROM accounts GROUP BY email
    ) AS keep
  )
  AND p.id IS NULL
  AND (a.name IS NULL OR a.name = '');

-- Indeks UNIQUE na email
ALTER TABLE accounts ADD UNIQUE INDEX uq_accounts_email (email);
