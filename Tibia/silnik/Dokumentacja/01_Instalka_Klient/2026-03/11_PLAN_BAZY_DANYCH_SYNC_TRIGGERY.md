# Plan: Bazy Danych — Sync, Triggery, Brakujące Tabele
**Data planu:** 2026-03-06  
**Realizacja:** 2026-03-07  
**Priorytet:** P0 — blokuje spójność kont i postaci

---

## Stan obecny (audyt 2026-03-06)

## Status realizacji (aktualizacja 2026-03-06 10:07 CET)

### Zakonczone
- `DB-10` backup 3 baz: `/tmp/backup_canaryaac_20260306_100123.sql`, `/tmp/backup_canary_20260306_100123.sql`, `/tmp/backup_canary_modern_20260306_100123.sql`
- `DB-01` trigger DELETE dla `canary` potwierdzony jako istniejacy (`acc_sync_ad`) + triggery `acc_sync_ai/acc_sync_au` poprawione na sync po `id`
- `DB-02` i `DB-03` naprawa rozjazdu kont `canary.accounts` (mapowanie ID + sync danych z `canaryaac`)
- `DB-04` sync `canary_modern.accounts` potwierdzony (brak brakujacych kont z master)
- `DB-05` audyt schematow `accounts` (3 bazy) wykonany
- `T-DB-01..04` PASS (INSERT/UPDATE/DELETE testowego konta, propagacja do obu engine DB)

### W trakcie
- brak

### Otwarte
- `DB-06`..`DB-12`

### Trzy bazy danych
| Baza | Tabel | Rola | Serwer |
|---|---|---|---|
| `canaryaac` | 109 | Master — AAC (strona www, konta, postacie, płatności) | WWW/API |
| `canary` | 73 | Classic 7.4 engine DB (serwer gry czyta i pisze) | Canary 7.4 |
| `canary_modern` | 47 | Modern engine DB (serwer gry czyta i pisze) | Canary Modern |

### Triggery sync (na canaryaac.accounts)
| Trigger | Event | Target | Co robi |
|---|---|---|---|
| `oncreate_accounts` | INSERT | canaryaac (self) | Tworzy VIP groups |
| `acc_sync_ai` | INSERT | `canary.accounts` | Sync konta INSERT → canary |
| `modern_sync_ai` | INSERT | `canary_modern.accounts` | Sync konta INSERT → canary_modern |
| `acc_sync_au` | UPDATE | `canary.accounts` | Sync konta UPDATE → canary |
| `modern_sync_au` | UPDATE | `canary_modern.accounts` | Sync konta UPDATE → canary_modern |
| `acc_sync_ad` | DELETE | `canary.accounts` | Sync konta DELETE → canary |
| `modern_sync_ad` | DELETE | `canary_modern.accounts` | Sync konta DELETE → canary_modern |
| `ondelete_players` | DELETE | canaryaac.players (self) | Czyści domy gracza |
| `oncreate_guilds` | INSERT | canaryaac (self) | Tworzy rangi gildii |

### Konta — stan spójności
| Baza | id=3 | id=6 | id=7 | id=10 | id=11 |
|---|---|---|---|---|---|
| canaryaac | admin@canaryaac.com | ptakukolo | ptakukolo1 | testruntime | testportal01 |
| canary | admin@canaryaac.com ✅ | ptakukolo ✅ | ptakukolo1 ✅ | testruntime ✅ | testportal01 ✅ |
| canary_modern | admin@canaryaac.com ✅ | ptakukolo ✅ | ptakukolo1 ✅ | testruntime ✅ | testportal01 ✅ |

**Uwagi po naprawie:**
1. Historyczny rozjazd ID w `canary.accounts` zostal usuniety; mapowanie kont jest zgodne z `canaryaac`.
2. `canary` i `canary_modern` maja po jednym dodatkowym koncie technicznym `id=1 (god)` poza zbiorem master (nie blokuje sync).

### 26 tabel brakujących w canary_modern
```
account_authentication    canary_achievements    canary_badges
canary_boss               canary_compendium      canary_countdowns
canary_creatures          canary_groups          canary_items
canary_news               canary_payments        canary_polls
canary_polls_answers      canary_polls_questions canary_products
canary_samples            canary_towns           canary_uploads
canary_website            canary_worldquests     canary_worlds
guild_applications        guild_events           player_badges
player_display            account_registration
```

---

## Zadania

### DB-01 (P0): Dodać brakujący trigger DELETE dla canary
```sql
DELIMITER //
CREATE TRIGGER acc_sync_ad AFTER DELETE ON canaryaac.accounts
FOR EACH ROW
BEGIN
    DELETE FROM canary.accounts WHERE id = OLD.id;
END //
DELIMITER ;
```
**Test:** Usunąć testowe konto z canaryaac → sprawdzić czy znikło z canary.

### DB-02 (P0): Initial sync brakujących kont do canary
```sql
-- Sync kont z canaryaac do canary (brakujące)
INSERT INTO canary.accounts (name, password, email, type, premdays)
SELECT 
    a.name, 
    COALESCE(a.engine_password_sha1, '0'), 
    a.email, 
    1, 
    0
FROM canaryaac.accounts a
LEFT JOIN canary.accounts c ON c.id = a.id
WHERE c.id IS NULL;
```
**Uwaga:** canary.accounts może nie mieć AUTO_INCREMENT zsynchronizowanego — sprawdzić schemat.

### DB-03 (P0): Naprawić rozsynchronizowane dane w canary
```sql
-- Naprawić name/email dla istniejących kont w canary
UPDATE canary.accounts c
JOIN canaryaac.accounts a ON c.id = a.id
SET 
    c.name = a.name,
    c.password = COALESCE(a.engine_password_sha1, c.password),
    c.email = a.email;
```

### DB-04 (P0): Sync brakującego konta do canary_modern
```sql
INSERT INTO canary_modern.accounts (id, name, password, email, type, creation)
SELECT 
    a.id,
    a.name, 
    COALESCE(a.engine_password_sha1, '0'), 
    a.email, 
    a.type,
    UNIX_TIMESTAMP(a.creation)
FROM canaryaac.accounts a
LEFT JOIN canary_modern.accounts m ON m.id = a.id
WHERE m.id IS NULL;
```

### DB-05 (P0): Zbadać rozbieżność schematów accounts
```sql
-- Porównać kolumny accounts w 3 bazach:
SHOW COLUMNS FROM canaryaac.accounts;
SHOW COLUMNS FROM canary.accounts;
SHOW COLUMNS FROM canary_modern.accounts;
```
**Kluczowe pytania:**
- Czy `canary.accounts.id` to AUTO_INCREMENT czy ręczne?
- Czy `engine_password_sha1` istnieje w canary/canary_modern? (NIE — triggery mapują na `password`)
- Czy pole `type` jest spójne?

### DB-06 (P1): Stworzenie 26 brakujących tabel w canary_modern
**Lista priorytetowa (potrzebne do gry):**
1. `guild_applications` — jeśli gildie mają działać
2. `guild_events` — wydarzenia gildii  
3. `player_badges` — odznaki graczy
4. `player_display` — ustawienia wyświetlania
5. `account_authentication` — 2FA/recovery keys

**Schema source:** Skopiować DDL z `canary` database:
```bash
for t in guild_applications guild_events player_badges player_display account_authentication account_registration; do
    mysqldump -u ptaku -p12345678 canary "$t" --no-data 2>/dev/null | \
    sed "s/\`canary\`/\`canary_modern\`/g" | \
    mysql -u ptaku -p12345678 canary_modern
done
```

**Tabele `canary_*` (CMS):** To tabele AAC/strony www (news, payments, polls, products, etc.) — **nie są potrzebne w engine DB**. Są w `canaryaac` i obsługiwane przez stronę www.

### DB-07 (P1): Trigger sync dla PLAYERS (tworzenie postaci)
**Problem:** Tworzenie postaci na www (canaryaac.players) musi trafić do odpowiedniej engine DB.
**Ale:** Postacie NIE są synchronizowane 1:1 — Classic i Modern mają OSOBNE postacie!

**Architektura:**
- `canaryaac.players` — master lista (www widzi wszystkie)
- `canary.players` — TYLKO postacie Classic 7.4
- `canary_modern.players` — TYLKO postacie Modern

**Potrzebne:** Mechanizm routing tworzenia postaci:
1. Użytkownik wybiera serwer (Classic/Modern) na www
2. WWW tworzy postać w canaryaac.players Z polem `world_id` (0=classic, 1=modern)
3. Trigger lub API wstawia postać do odpowiedniej engine DB

```sql
-- Trigger INSERT z routingiem:
DELIMITER //
CREATE TRIGGER player_sync_ai AFTER INSERT ON canaryaac.players
FOR EACH ROW
BEGIN
    IF NEW.world_id = 0 THEN
        INSERT INTO canary.players (id, name, group_id, account_id, level, vocation, health, healthmax, experience, lookbody, lookfeet, lookhead, looklegs, looktype, maglevel, mana, manamax, soul, town_id, posx, posy, posz, cap, sex, lastlogin, lastip, save, skull, skulltime, lastlogout, balance, stamina, skill_fist, skill_fist_tries, skill_club, skill_club_tries, skill_sword, skill_sword_tries, skill_axe, skill_axe_tries, skill_dist, skill_dist_tries, skill_shielding, skill_shielding_tries, skill_fishing, skill_fishing_tries, skill_critical_hit_chance, skill_critical_hit_chance_tries, skill_critical_hit_damage, skill_critical_hit_damage_tries, skill_life_leech_chance, skill_life_leech_chance_tries, skill_life_leech_amount, skill_life_leech_amount_tries, skill_mana_leech_chance, skill_mana_leech_chance_tries, skill_mana_leech_amount, skill_mana_leech_amount_tries, manashield, max_manashield, xpboost_stamina, xpboost_value, prey_wildcard, task_points, forge_dusts, forge_dust_level, randomize_mount)
            SELECT id, name, group_id, account_id, level, vocation, health, healthmax, experience, lookbody, lookfeet, lookhead, looklegs, looktype, maglevel, mana, manamax, soul, town_id, posx, posy, posz, cap, sex, lastlogin, lastip, save, skull, skulltime, lastlogout, balance, stamina, skill_fist, skill_fist_tries, skill_club, skill_club_tries, skill_sword, skill_sword_tries, skill_axe, skill_axe_tries, skill_dist, skill_dist_tries, skill_shielding, skill_shielding_tries, skill_fishing, skill_fishing_tries, skill_critical_hit_chance, skill_critical_hit_chance_tries, skill_critical_hit_damage, skill_critical_hit_damage_tries, skill_life_leech_chance, skill_life_leech_chance_tries, skill_life_leech_amount, skill_life_leech_amount_tries, skill_mana_leech_chance, skill_mana_leech_chance_tries, skill_mana_leech_amount, skill_mana_leech_amount_tries, manashield, max_manashield, xpboost_stamina, xpboost_value, prey_wildcard, task_points, forge_dusts, forge_dust_level, randomize_mount
            FROM canaryaac.players WHERE id = NEW.id;
    ELSEIF NEW.world_id = 1 THEN
        INSERT INTO canary_modern.players (id, name, group_id, account_id, level, vocation, health, healthmax, experience, lookbody, lookfeet, lookhead, looklegs, looktype, maglevel, mana, manamax, soul, town_id, posx, posy, posz, cap, sex, lastlogin, lastip, save, skull, skulltime, lastlogout, balance, stamina, skill_fist, skill_fist_tries, skill_club, skill_club_tries, skill_sword, skill_sword_tries, skill_axe, skill_axe_tries, skill_dist, skill_dist_tries, skill_shielding, skill_shielding_tries, skill_fishing, skill_fishing_tries, skill_critical_hit_chance, skill_critical_hit_chance_tries, skill_critical_hit_damage, skill_critical_hit_damage_tries, skill_life_leech_chance, skill_life_leech_chance_tries, skill_life_leech_amount, skill_life_leech_amount_tries, skill_mana_leech_chance, skill_mana_leech_chance_tries, skill_mana_leech_amount, skill_mana_leech_amount_tries, manashield, max_manashield, xpboost_stamina, xpboost_value, prey_wildcard, task_points, forge_dusts, forge_dust_level, randomize_mount)
            SELECT id, name, group_id, account_id, level, vocation, health, healthmax, experience, lookbody, lookfeet, lookhead, looklegs, looktype, maglevel, mana, manamax, soul, town_id, posx, posy, posz, cap, sex, lastlogin, lastip, save, skull, skulltime, lastlogout, balance, stamina, skill_fist, skill_fist_tries, skill_club, skill_club_tries, skill_sword, skill_sword_tries, skill_axe, skill_axe_tries, skill_dist, skill_dist_tries, skill_shielding, skill_shielding_tries, skill_fishing, skill_fishing_tries, skill_critical_hit_chance, skill_critical_hit_chance_tries, skill_critical_hit_damage, skill_critical_hit_damage_tries, skill_life_leech_chance, skill_life_leech_chance_tries, skill_life_leech_amount, skill_life_leech_amount_tries, skill_mana_leech_chance, skill_mana_leech_chance_tries, skill_mana_leech_amount, skill_mana_leech_amount_tries, manashield, max_manashield, xpboost_stamina, xpboost_value, prey_wildcard, task_points, forge_dusts, forge_dust_level, randomize_mount
            FROM canaryaac.players WHERE id = NEW.id;
    END IF;
END //
DELIMITER ;
```

**UWAGA:** Powyższy trigger jest przykładem koncepcji. Dokładna lista kolumn MUSI być wygenerowana na podstawie rzeczywistego schematu `canary.players` vs `canary_modern.players` (mogą się różnić!). Alternatywa: routing na poziomie PHP (bezpieczniejszy).

### DB-08 (P1): Alternatywa — routing postaci w PHP zamiast triggera
**Plik:** `/var/www/html/system/pages/account/characters/create.php` (lub odpowiednik)
```php
// Zamiast triggera - PHP routing tworzenia postaci:
$worldId = (int)$_POST['world_id'];  // 0=classic, 1=modern

// Wstaw do canaryaac (master)
$stmt = $db->prepare("INSERT INTO players (name, account_id, world_id, ...) VALUES (?, ?, ?, ...)");
$stmt->execute([$name, $accountId, $worldId, ...]);
$playerId = $db->lastInsertId();

// Wstaw do engine DB
if ($worldId === 0) {
    $engineDb = getClassicDb();  // canary
} else {
    $engineDb = getModernDb();   // canary_modern
}
$engineStmt = $engineDb->prepare("INSERT INTO players (id, name, account_id, ...) VALUES (?, ?, ?, ...)");
$engineStmt->execute([$playerId, $name, $accountId, ...]);
```
**Zalety PHP nad triggerem:**
- Łatwiejsze debugowanie
- Logi błędów w PHP error_log
- Można dodać walidację (np. czy serwer online)
- Nie wymaga SUPER privilege w MySQL

### DB-09 (P1): Pole `world_id` w canaryaac.players
**Sprawdzić:** Czy canaryaac.players ma kolumnę `world_id`?
```sql
SHOW COLUMNS FROM canaryaac.players LIKE 'world_id';
-- Jeśli brak:
ALTER TABLE canaryaac.players ADD COLUMN world_id TINYINT NOT NULL DEFAULT 0 COMMENT '0=classic74, 1=modern';
CREATE INDEX idx_players_world_id ON canaryaac.players (world_id);
```

### DB-10 (P1): Backup przed operacjami sync
```bash
# OBOWIĄZKOWE przed jakimikolwiek zmianami:
mysqldump -u ptaku -p12345678 canaryaac > /tmp/backup_canaryaac_$(date +%Y%m%d_%H%M).sql
mysqldump -u ptaku -p12345678 canary > /tmp/backup_canary_$(date +%Y%m%d_%H%M).sql
mysqldump -u ptaku -p12345678 canary_modern > /tmp/backup_canary_modern_$(date +%Y%m%d_%H%M).sql
echo "Backupy gotowe w /tmp/"
```

### DB-11 (P2): Monitoring lag sync
```sql
-- Sprawdzenie spójności (do uruchamiania ręcznie):
SELECT 'canaryaac→canary' AS sync,
    (SELECT COUNT(*) FROM canaryaac.accounts) AS master_cnt,
    (SELECT COUNT(*) FROM canary.accounts) AS slave_cnt,
    (SELECT COUNT(*) FROM canaryaac.accounts) - (SELECT COUNT(*) FROM canary.accounts) AS diff;

SELECT 'canaryaac→modern' AS sync,
    (SELECT COUNT(*) FROM canaryaac.accounts) AS master_cnt,
    (SELECT COUNT(*) FROM canary_modern.accounts) AS slave_cnt,
    (SELECT COUNT(*) FROM canaryaac.accounts) - (SELECT COUNT(*) FROM canary_modern.accounts) AS diff;
```

### DB-12 (P2): Procedura rollback DB
W razie problemów:
```bash
# Przywracanie z backupu:
mysql -u ptaku -p12345678 canaryaac < /tmp/backup_canaryaac_YYYYMMDD_HHMM.sql
mysql -u ptaku -p12345678 canary < /tmp/backup_canary_YYYYMMDD_HHMM.sql
mysql -u ptaku -p12345678 canary_modern < /tmp/backup_canary_modern_YYYYMMDD_HHMM.sql
```

---

## Matryca testów DB

| # | Test | SQL/Komenda | Oczekiwany wynik | Status |
|---|---|---|---|---|
| T-DB-01 | INSERT konto w canaryaac → pojawia się w canary | `INSERT INTO canaryaac.accounts (name, password, email) VALUES ('test_sync', SHA1('test'), 'sync@test.com')` | Nowy wiersz w canary.accounts | ✅ PASS (2026-03-06) |
| T-DB-02 | INSERT konto w canaryaac → pojawia się w canary_modern | j.w. | Nowy wiersz w canary_modern.accounts | ✅ PASS (2026-03-06) |
| T-DB-03 | UPDATE konto w canaryaac → propaguje do obu | `UPDATE canaryaac.accounts SET email='new@test.com' WHERE name='test_sync'` | Oba slave'y zaktualizowane | ✅ PASS (2026-03-06) |
| T-DB-04 | DELETE konto z canaryaac → znika z obu | `DELETE FROM canaryaac.accounts WHERE name='test_sync'` | Usunięte z canary I canary_modern | ✅ PASS (2026-03-06) |
| T-DB-05 | Tworzenie postaci Classic → trafia do canary.players | Flow WWW create character | Postać w canary.players, world_id=0 | ⬜ |
| T-DB-06 | Tworzenie postaci Modern → trafia do canary_modern.players | Flow WWW create character | Postać w canary_modern.players, world_id=1 | ⬜ |
| T-DB-07 | Liczba kont spójna | Skrypt monitoring | diff = 0 | ⬜ |
