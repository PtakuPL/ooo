# Plan: API — Audyt Endpointów, Poprawki, Nowe Funkcje
**Data planu:** 2026-03-06  
**Realizacja:** 2026-03-07  
**Priorytet:** P0/P1 — API jest kręgosłupem systemu

---

## Stan obecny (audyt 2026-03-06)

## Status realizacji (aktualizacja 2026-03-06 10:07 CET)

### Zakonczone
- `API-01` naprawione env: `ENGINE_DB_NAME=canary` + `ENGINE_MODERN_DB_*` (runtime + repo templates)
- `API-02` `MULTI_WORLD=true` (runtime + repo templates)
- `API-06` helper dual-engine w `common.php` dostepny (`getEnginePdo`, `getBothEnginePdos`)

### W trakcie
- brak

### Otwarte
- `API-07`..`API-15`

### Zakonczone (dodatkowo 2026-03-06 10:18 CET)
- `API-03` `login.php` dual-world zweryfikowany i poprawiony (mode-specific filtruje postacie po swiecie)
- `API-04` `account-context.php` zwraca poprawne `charactersByWorld` i liczniki
- `API-05` `ticket.php` world mismatch zwraca HTTP `403` (fail-closed)

### Plik .env — kluczowe ustawienia
- `DB_NAME=canaryaac` (master DB)
- `ENGINE_DB_NAME=canary` ✅ (engine classic)
- `ENGINE_MODERN_DB_NAME=canary_modern` ✅
- `WORLD_CLASSIC74_IP=127.0.0.1:7172`, `WORLD_MODERN_IP=127.0.0.1:7174`
- `TICKET_SECRET=c3fa94c6...` (spójne z serwerem?)
- `CLIENT_LOCKED=true`
- `MULTI_WORLD=true` ✅

### 30 endpointów PHP
```
account-context.php          account-sync-consume.php
account-sync-token.php       account-sync-www-login.php
account-sync-www-token.php   auth_probe.php
challenge.php                common.php (helper)
dashboard-errors.php         diag_players.php
echo.php                     error-report.php
generate_manifest.php        health.php
installer-catalog.php        launcher-token.php
launcher-version.php         login.php
oauth-callback.php           oauth-start.php
peek_env.php                 ping.php
players-list.php             pwcheck.php
register-account-lib.php     register-account.php
server-status.php            ticket.php
toplist.php                  update.php
```

---

## Zadania

### API-01 (P0): Naprawić ENGINE_DB w .env
**Plik:** `/var/www/html/apik/v1/.env`
```ini
# BYŁO (błędne):
ENGINE_DB_NAME=canaryaac

# POWINNO BYĆ:
ENGINE_DB_NAME=canary

# DODAĆ nową zmienną:
ENGINE_MODERN_DB_HOST=127.0.0.1
ENGINE_MODERN_DB_NAME=canary_modern
ENGINE_MODERN_DB_USER=ptaku
ENGINE_MODERN_DB_PASS=12345678
ENGINE_MODERN_DB_PORT=3306
```

### API-02 (P0): Ustawić MULTI_WORLD=true
**Plik:** `/var/www/html/apik/v1/.env`
```ini
# BYŁO:
MULTI_WORLD=false
# POWINNO BYĆ:
MULTI_WORLD=true
```

### API-03 (P0): login.php — weryfikacja dual-world response
**Plik:** `/var/www/html/apik/v1/login.php`
- Sprawdzić czy `mode` parameter (z request body lub sesji) determinuje listę światów
- Mode `all` → zwracać oba światy:
```json
{
  "session": {"sessionKey": "..."},
  "playdata": {
    "worlds": [
      {"id": 0, "name": "Canary Classic 7.4", "ip": "127.0.0.1", "port": 7172, "pvpType": 0},
      {"id": 1, "name": "Canary Modern", "ip": "127.0.0.1", "port": 7174, "pvpType": 0}
    ],
    "characters": [
      {"name": "Knight Test", "worldId": 0},
      {"name": "Ptaku Modern", "worldId": 1}
    ]
  }
}
```
- Mode `classic74` → tylko worldId=0
- Mode `modern` → tylko worldId=1

### API-04 (P0): account-context.php — zwracać postacie per świat
**Plik:** `/var/www/html/apik/v1/account-context.php`
- Endpoint musi zwracać:
```json
{
  "account": {"id": 6, "name": "ptakukolo", "email": "..."},
  "servers": [
    {"id": 0, "name": "Canary Classic 7.4", "mode": "classic74", "online": true},
    {"id": 1, "name": "Canary Modern", "mode": "modern", "online": true}
  ],
  "characters": {
    "classic74": [{"id": 6, "name": "GOD", "level": 1, "vocation": "None"}],
    "modern": [{"id": 7, "name": "Ptaku Modern", "level": 8, "vocation": "Knight"}]
  },
  "hasCharacterClassic": true,
  "hasCharacterModern": true
}
```
- Launcher używa tego do: wyświetlenia serwerów, blokady "Graj" gdy brak postaci, linku "Utwórz postać"

### API-05 (P0): ticket.php — walidacja world mismatch
**Plik:** `/var/www/html/apik/v1/ticket.php`
- Ticket zawiera `worldId` + `characterId`
- API musi sprawdzić: postać z `characterId` należy do `worldId`
- Odrzucić ticket jeśli mismatch (fail-closed)
```php
// Pseudokod walidacji:
$character = getCharacterById($ticket['characterId']);
if ($character['world_id'] !== $ticket['worldId']) {
    return json_response(403, ['error' => 'CHARACTER_WORLD_MISMATCH']);
}
```

### API-06 (P0): common.php — dual PDO connection
**Plik:** `/var/www/html/apik/v1/common.php`
```php
// Dodać helper do wyboru engine DB:
function getEngineDb(int $worldId): PDO {
    if ($worldId === 0) {
        return new PDO(
            "mysql:host=" . getenv('ENGINE_DB_HOST') . ";dbname=" . getenv('ENGINE_DB_NAME'),
            getenv('ENGINE_DB_USER'),
            getenv('ENGINE_DB_PASS')
        );
    } elseif ($worldId === 1) {
        return new PDO(
            "mysql:host=" . getenv('ENGINE_MODERN_DB_HOST') . ";dbname=" . getenv('ENGINE_MODERN_DB_NAME'),
            getenv('ENGINE_MODERN_DB_USER'),
            getenv('ENGINE_MODERN_DB_PASS')
        );
    }
    throw new \InvalidArgumentException("Unknown worldId: $worldId");
}
```

### API-07 (P1): players-list.php — dual-world support
**Plik:** `/var/www/html/apik/v1/players-list.php`
- Parametr `mode=all|classic74|modern`
- `all` → query obu engine DB, merge, oznaczyć `server` field
- `classic74` → query tylko `canary.players`
- `modern` → query tylko `canary_modern.players`

### API-08 (P1): toplist.php — dual-world support
**Plik:** `/var/www/html/apik/v1/toplist.php`
- Jak players-list: mode parameter, merge results
- Dodać pole `server: "classic74"|"modern"` do każdego wyniku
- Sortowanie po merge (np. top 100 z obu serwerów razem)

### API-09 (P1): server-status.php — raportować oba serwery
**Plik:** `/var/www/html/apik/v1/server-status.php`
- Sprawdzać status na portach 7171 (classic) i 7173 (modern)
- Zwracać:
```json
{
  "servers": [
    {"name": "Classic 7.4", "mode": "classic74", "online": true, "players": 5, "uptime": 3600},
    {"name": "Modern", "mode": "modern", "online": true, "players": 3, "uptime": 3600}
  ]
}
```

### API-10 (P1): register-account.php — globalne konto
**Plik:** `/var/www/html/apik/v1/register-account.php`
- Konto tworzone w `canaryaac.accounts` (master)
- Triggery syncują do `canary` + `canary_modern` automatycznie
- Sprawdzić: czy register-account odpowiednio hashuje hasło (argon2 w canaryaac, sha1 w engine)
- Sprawdzić: czy `engine_password_sha1` jest wypełniany przy rejestracji

### API-11 (P1): launcher-token.php — walidacja sesji
**Plik:** `/var/www/html/apik/v1/launcher-token.php`
- Po loginie w launcherze → generuje launch token
- Token używany do: startu klienta (ticket-gate), auto-login www
- Sprawdzić: TTL, one-time-use, rate-limit

### API-12 (P1): Normalizacja błędów API
**Wszystkie endpointy** powinny zwracać:
```json
{
  "errorCode": 3,
  "errorMessage": "Account name or password is not correct."
}
```
Sprawdzić spójność formatu we wszystkich 30 plikach.

### API-13 (P1): account-sync-* flow — weryfikacja
**Pliki:**
- `account-sync-token.php` — generuje jednorazowy token
- `account-sync-consume.php` — konsumuje token (one-time-use)
- `account-sync-www-login.php` — auto-login na www z tokenem launchera
- `account-sync-www-token.php` — generuje token www→launcher

**Testy:**
1. Wygenerować token → consume → OK
2. Consume drugi raz → REJECT (replay protection)
3. Czekać > TTL → consume → REJECT (expired)

### API-14 (P2): Usunąć/zabezpieczyć diagnostyczne endpointy
**Pliki do zabezpieczenia (dev-only, nie prod):**
- `peek_env.php` — wyświetla zmienne .env! **NIEBEZPIECZNE**
- `echo.php` — echo request
- `auth_probe.php` — diagnostyka auth
- `diag_players.php` — diagnostyka graczy
- `dashboard-errors.php` — błędy

**Opcje:**
1. Dodać `if (!DEV_MODE) { http_response_code(404); exit; }` na górze każdego
2. Usunąć z produkcji
3. Zabezpieczyć API key / IP whitelist

### API-15 (P2): Checklista rotacji sekretów
| Secret | Plik | Rotować? |
|---|---|---|
| `TICKET_SECRET` | .env + config.lua (oba serwery) | Przed prod deploy |
| `PAYPAL_CLIENT_SECRET` | .env | Sandbox OK, prod → nowy |
| MySQL password | .env + config.lua | Przed prod |
| OAuth secrets | .env | Jeśli social login |

---

## Matryca testów API

| # | Endpoint | Test | Oczekiwany wynik | Status |
|---|---|---|---|---|
| T-API-01 | login.php (mode=all) | POST + credentials | 2 worlds + characters | ✅ PASS (2026-03-06) |
| T-API-02 | login.php (mode=classic74) | POST + credentials | 1 world port 7172 | ✅ PASS (2026-03-06) |
| T-API-03 | login.php (mode=modern) | POST + credentials | 1 world port 7174 | ✅ PASS (2026-03-06) |
| T-API-04 | account-context.php | GET + session | servers + characters per world | ✅ PASS (2026-03-06) |
| T-API-05 | ticket.php | Valid ticket | 200 OK + game params | ✅ PASS (2026-03-06) |
| T-API-06 | ticket.php | Ticket world mismatch | 403 REJECT | ✅ PASS (2026-03-06) |
| T-API-07 | register-account.php | POST new account | 201 + sync triggers fire | ⬜ |
| T-API-08 | sync-token → consume | Issue + consume | 200 first, 409 replay | ⬜ |
| T-API-09 | server-status.php | GET | Both servers status | ⬜ |
| T-API-10 | health.php | GET | 200 OK | ⬜ |
| T-API-11 | players-list (all) | GET | Merged list both DBs | ⬜ |
| T-API-12 | peek_env.php (non-dev) | GET | 404 or forbidden | ⬜ |
