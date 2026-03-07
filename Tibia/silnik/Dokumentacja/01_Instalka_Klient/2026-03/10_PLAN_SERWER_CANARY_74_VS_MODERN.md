# Plan: Serwer Canary — Classic 7.4 vs Modern (aby tryb ALL działał)
**Data planu:** 2026-03-06  
**Realizacja:** 2026-03-07  
**Priorytet:** P0 — blokuje kompilację

---

## Stan obecny (audyt 2026-03-06)

## Status realizacji (aktualizacja 2026-03-06 10:31 CET)

### Zakonczone
- `S-01` serverName ujednolicone (`Canary Classic 7.4` / `Canary Modern`)
- `S-04` jeden binary + dwa configi (symlink `canary_modern/canary -> ../canary_test/canary`)
- `S-06` symlinki datapack/data dla modern potwierdzone
- `S-07` skrypt startowy dodany: `start_both_servers.sh` (PID + logi + wait na porty 7171-7174)
- `S-08` `server-status.php` zwraca oba serwery (`classic74`, `modern`) i poprawne porty
- `S-09` `ticketSecret` zgodny w `.env`, `canary_test/config.lua`, `canary_modern/config.lua`
- `S-10` pelna weryfikacja `canary_modern/config.lua` (DB, porty, ip, worldType, ticketSecret, ticketGateEnabled)
- `S-12` brak aktywnego defunct process podczas audytu
- `T-S-01`, `T-S-02`, `T-S-08`, `T-S-09` = PASS (runtime test 2026-03-06)

### W trakcie
- `S-02` finalna walidacja nazw swiatow zwracanych przez API vs naming UX
- `S-03` decyzja operacyjna o buildzie obu serwerow z jednego source w pipeline

### Otwarte
- `S-05`, `S-11`

| Parametr | Classic 7.4 (`canary_test/`) | Modern (`canary_modern/`) |
|---|---|---|
| Login port | 7171 | 7173 |
| Game port | 7172 | 7174 |
| Status port | 7171 | 7173 |
| IP bind | 0.0.0.0 | 0.0.0.0 |
| Baza danych | `canary` | `canary_modern` |
| serverName | "Canary Classic 7.4" | "Canary Modern" |
| worldType | pvp | pvp |
| dataPackDirectory | data-otservbr-global | data-otservbr-global |
| PID | brak procesu (do uruchomienia) | brak procesu (do uruchomienia) |
| Players | n/d (serwer offline w audycie) | n/d (serwer offline w audycie) |
| i18n compact keys | false | false |
| Ticket-gate | TAK | TAK |

---

## Zadania

### S-01 (P0): Ujednolicić `serverName` z konwencją trybu
**Pliki:** `canary_test/config.lua`, `canary_modern/config.lua`
```lua
-- canary_test/config.lua
serverName = "Canary Classic 7.4"    -- było: "Tibia 7.4 test"

-- canary_modern/config.lua  
serverName = "Canary Modern"         -- OK, bez zmian
```
**Dlaczego:** API `login.php` zwraca `serverName` w liście światów — musi być spójne z `gameMode`.

### S-02 (P0): Weryfikacja worldId w API login.php
**Plik:** `/var/www/html/apik/v1/login.php`
- Classic 7.4: `worldId=0`, port 7172, name "Canary Classic 7.4"
- Modern: `worldId=1`, port 7174, name "Canary Modern"
- ALL: oba światy w tablicy `worlds[]`
- **Test:** `curl -s -k https://127.0.0.1/apik/v1/login.php -d '{"email":"...","password":"..."}'` → sprawdzić odpowiedź

### S-03 (P0): Ticket-gate — Modern otrzymuje ticket-gate
**Problem:** `canary_test/` ma ticket-gate (z branch feature/ticket-gate), ale `canary_modern/` używa czystego canary/ (bez ticket-gate).
**Rozwiązanie:**
1. Skopiować pliki ticket-gate z `canary_test/src/server/network/` do `canary_modern/src/server/network/`
2. Lub: skompilować oba z tego samego źródła `canary_test/` z różnymi config.lua
**Decyzja do podjęcia:** Czy oba serwery budujemy z jednego źródła c++? (zalecane — 1 binarny, 2 config.lua)

### S-04 (P0): Jeden binary, dwa configi
**Rekomendacja:** Zamiast dwóch katalogów źródłowych:
```
canary_test/     → kompiluje → canary (binary)
canary_modern/   → TEN SAM binary, inny config.lua
```
Layout po zmianach:
```
canary_test/canary           ← binary (Classic 7.4)
canary_test/config.lua       ← config Classic (port 7171/7172, DB canary)
canary_modern/canary         ← SYMLINK lub KOPIA tego samego binary
canary_modern/config.lua     ← config Modern (port 7173/7174, DB canary_modern)
```
**Kroki:**
1. `ln -sf ../canary_test/canary canary_modern/canary` (lub `cp`)
2. Upewnić się, że `canary_modern/config.lua` ma `coreDirectory` i `dataPackDirectory` ustawione absolutnie lub relatywnie poprawnie

### S-05 (P0): Rozwiązać problem `dataPackDirectory` dla Modern
**Problem:** Oba serwery używają `data-otservbr-global` — to OK jeśli te same questy/NPC. Ale jeśli Modern ma mieć INNE dane:
- **Opcja A:** Ten sam datapack (10.x+ content) → oba config.lua → `data-otservbr-global`
- **Opcja B:** Osobny datapack Modern → `data-canary-modern/` (trzeba stworzyć)
**Decyzja:** Na dziś Opcja A — ten sam datapack. Osobny datapack to zadanie na później.

### S-06 (P0): Sprawdzić czy Modern ma `data/` i `data-otservbr-global/` 
**Plik:** `canary_modern/` katalog
```bash
ls -la canary_modern/data/
ls -la canary_modern/data-otservbr-global/
# Jeśli brak → symlink:
ln -sf ../canary_test/data canary_modern/data
ln -sf ../canary_test/data-otservbr-global canary_modern/data-otservbr-global
```

### S-07 (P1): Skrypt startowy obu serwerów
**Plik:** `start_both_servers.sh` (do stworzenia)
```bash
#!/bin/bash
echo "Starting Classic 7.4..."
cd /home/ptaku/serweryt/Tibia/silnik/canary_test && ./canary &
sleep 2
echo "Starting Modern..."
cd /home/ptaku/serweryt/Tibia/silnik/canary_modern && ./canary &
echo "Both servers starting..."
```

### S-08 (P1): Status endpoint dla obu serwerów
**Plik:** `/var/www/html/apik/v1/server-status.php`
- Sprawdzić czy odpytuje oba porty (7171 + 7173)
- Zwracać status JSON per serwer:
```json
{
  "classic74": {"online": true, "players": 5, "port": 7171},
  "modern": {"online": true, "players": 3, "port": 7173}
}
```

### S-09 (P1): Weryfikacja `ticketSecret` spójności
**Problem:** `.env` ma `TICKET_SECRET=c3fa94c6...`, ale czy `canary_test/config.lua` i `canary_modern/config.lua` mają ten sam secret?
```bash
grep ticketSecret canary_test/config.lua
grep ticketSecret canary_modern/config.lua
# Oba MUSZĄ == .env TICKET_SECRET
```

### S-10 (P1): Config `canary_modern/config.lua` — pełna weryfikacja
Sprawdzić następujące wartości:
- `mysqlDatabase = "canary_modern"` ✅
- `loginProtocolPort = 7173` ✅
- `gameProtocolPort = 7174` ✅
- `statusProtocolPort = 7173` ✅
- `ip = "0.0.0.0"` ✅
- `worldType = "pvp"` ✅
- `ticketSecret` = to samo co w `.env`? → SPRAWDZIĆ
- `ticketGateEnabled = true/false`? → SPRAWDZIĆ

### S-11 (P2): Logi obu serwerów w osobnych plikach
**Cel:** Łatwe debugowanie kiedy oba serwery działają
```lua
-- canary_test/config.lua
logFile = "server_classic74.log"

-- canary_modern/config.lua
logFile = "server_modern.log"
```

### S-12 (P2): Defunct process cleanup
**Stan:** `ps aux` pokazuje defunct canary process (PID 19243)
```bash
# Sprawdzić parent PID i zabić:
kill -9 19243    # zombie process
```

---

## Matryca testów Canary

| # | Test | Oczekiwany wynik | Status |
|---|---|---|---|
| T-S-01 | Classic 7.4 przyjmuje połączenie na 7171/7172 | OK | ✅ PASS |
| T-S-02 | Modern przyjmuje połączenie na 7173/7174 | OK | ✅ PASS |
| T-S-03 | API login.php zwraca 2 światy w mode=all | JSON z 2 entries | ✅ PASS |
| T-S-04 | API login.php zwraca 1 świat w mode=classic74 | JSON z 1 entry port 7172 | ✅ PASS |
| T-S-05 | API login.php zwraca 1 świat w mode=modern | JSON z 1 entry port 7174 | ✅ PASS |
| T-S-06 | Ticket Classic 7.4 → przyjęty na 7172, odrzucony na 7174 | PASS/REJECT | ⬜ |
| T-S-07 | Ticket Modern → przyjęty na 7174, odrzucony na 7172 | PASS/REJECT | ⬜ |
| T-S-08 | Oba serwery działają jednocześnie bez kolizji | Brak crash | ✅ PASS |
| T-S-09 | server-status.php zwraca stan obu | JSON 2 entries | ✅ PASS |
