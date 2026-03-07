# Plan separacji baz danych, konta globalnego i API
**Data:** 2026-03-07  
**Kontekst:** Faza po ticket-gate, przed kompilacją serwera/instalki/launchera  
**Cel:** Architektura skalowalna na wiele gier, wiele serwerów, launcher desktop + Android

---

## 0. STATUS REALIZACJI (2026-03-07)

| # | Zadanie | Status | Uwagi |
|---|---------|--------|-------|
| S1a | CREATE TABLE games, account_games, launcher_updates | ✅ DONE | W canaryaac, kolumny: slug, game_mode, engine_db_*, game_host/port, platform_* |
| S1b | INSERT dane + backfill account_games | ✅ DONE | 2 gry (tibia_classic74, tibia_modern), 82 account_games (41 kont × 2 gry) |
| P1 | Aliasy DB w .env (GLOBAL_DB_*, API_DB_*, CMS_DB_*) | ✅ DONE | Teraz wskazują na canaryaac, ready to switch |
| P2 | Factory functions (getGlobalDb, getApiDb, getGameDb) | ✅ DONE | W common.php, getGameDb() czyta z tabeli games |
| S2 | login.php — dynamic worlds from games table | ✅ DONE | Usunięto hardkod classic74/modern, world_id = sort_order-1, dynamiczna walidacja gameMode |
| S3 | Nowy endpoint games-list.php | ✅ DONE | Zwraca listę gier gracza (slug, name, port, platforms, status) |
| S4 | CREATE DATABASE global_accounts | ✅ DONE | 7 tabel: accounts, games, account_games, account_identity_links, account_authentication, account_registration, launcher_updates |
| S5 | CREATE DATABASE api_core | ✅ DONE | 7 tabel: ticket_sessions, launch_tokens, ticket_nonces, oauth_states, oauth_rate_limits, account_sync_tokens, manifest_versions |
| S6 | CREATE DATABASE cms_web | ✅ DONE | 27 tabel: myaac_*, z_polls*, arena_*, _migrations |
| S7 | Migracja tabel (mysqldump --skip-triggers) | ✅ DONE | Dane skopiowane, oryginały pozostają w canaryaac |
| S7b | Aliasy .env → nowe bazy | ✅ READY | Aliasy gotowe, wskazują na canaryaac. Switch po refaktorze endpointów na multi-DB |
| | | |
| **F1:** | Refaktor endpointów na multi-DB connections | ✅ DONE | Wszystkie 16 endpointów przekonwertowane z mysqli na PDO multi-DB (getGlobalDb/getApiDb/getEnginePdo/getBothEnginePdos) |
| **F3:** | Switch .env aliasy na nowe bazy | ✅ DONE | GLOBAL_DB_NAME=global_accounts, API_DB_NAME=api_core, CMS_DB_NAME=cms_web — fizycznie rozdzielone |

---

## 1. Stan obecny — audyt

### 1.1 Bazy danych
| Baza | Rola | Tabele | Kto używa |
|------|------|--------|-----------|
| `canaryaac` | MASTER — MyAAC + AAC custom + Classic 7.4 engine | 107 (16 myaac_, 14 custom, 73 engine) | MyAAC, API (login, ticket, launcher-token, account-context, toplist), RedDAXE |
| `canary` | Raw Classic 7.4 engine | 73 (identyczne z canaryaac engine) | auth_probe.php, serwer gry |
| `canary_modern` | Modern 14.x engine | 73 | highscores, online, getModernDb() |
| `myaac` | Pusta — relikt | 0 | Nikt |

### 1.2 Problemy obecnej architektury
1. **`canaryaac` = monolityczny worek** — konta globalne, sesje API, tokeny launchera, tabele gry Classic 7.4, tabele MyAAC CMS — wszystko razem
2. **Duplikacja** — `canaryaac` i `canary` mają te same tabele engine (accounts, players, etc.)
3. **Brak bazy kont globalnych** — konta (`accounts`) są w `canaryaac` = powiązane z jednym serwerem gry
4. **Brak osobnej bazy API** — `launch_tokens`, `ticket_sessions`, `ticket_nonces`, `oauth_*` siedzą w `canaryaac`
5. **Topki/online** — łączone w PHP z dwóch baz, ale same dane leżą w engine DB razem z sesami gry
6. **Brak skalowalności** — dodanie trzeciego serwera gry = trzeci hardkod w kodzie

### 1.3 Połączenia w kodzie
| Komponent | Biblioteka DB | Baza | Plik konfiguracyjny |
|-----------|--------------|------|---------------------|
| MyAAC website | Eloquent | canaryaac | config.local.php |
| database_modern.php | PDO | canary_modern | config.local.php → `modern_database_name` |
| API login/ticket/token | mysqli | canaryaac | apik/v1/.env → DB_* |
| API common.php | PDO | canary / canary_modern | apik/v1/.env → ENGINE_DB_* / ENGINE_MODERN_DB_* |
| API auth_probe | PDO | canaryaac + canary | apik/v1/.env |
| Serwer gry Classic | C++ | canary | config.lua |
| Serwer gry Modern | C++ | canary_modern | config_modern.lua |

---

## 2. Architektura docelowa — 5 warstw baz

```
┌─────────────────────────────────────────────────────────────┐
│                    LAUNCHER (Desktop + Android)              │
│         pobiera gry, aktualizuje, loguje się globalnie      │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTPS / API
┌────────────────────────▼────────────────────────────────────┐
│                      API GATEWAY                             │
│           /apik/v1/ — login, token, sync, manifest           │
│     Łączy się z: global_accounts + api_core + engine DBs     │
└────────────────────────┬────────────────────────────────────┘
                         │
   ┌─────────┬───────────┼───────────┬──────────────┐
   ▼         ▼           ▼           ▼              ▼
┌───────┐ ┌───────┐ ┌─────────┐ ┌──────────┐ ┌──────────┐
│GLOBAL │ │ API   │ │ ENGINE  │ │ ENGINE   │ │ ENGINE   │
│ACCTS  │ │ CORE  │ │ tibia74 │ │ modern14 │ │ cs16_s01 │
│       │ │       │ │         │ │          │ │ (future) │
└───────┘ └───────┘ └─────────┘ └──────────┘ └──────────┘
```

### 2.1 Baza `global_accounts`
**Dedykowana baza kont globalnych — niezależna od żadnej gry.**

| Tabela | Opis |
|--------|------|
| `accounts` | id, name, email, password (argon2), premium_days, creation, last_login, web_flags |
| `account_games` | account_id → game_id (jakie gry ma przypisane) |
| `games` | id, slug (`tibia_classic74`, `tibia_modern`, `cs16_dust2`), name, engine_db_name, status |
| `account_identity_links` | OAuth/Discord/Google linki |
| `account_2fa` | dwuskładnikowa auth (TOTP/SMS) — przyszłość |

**Zasada:** Gracz zakłada JEDNO konto globalne → loguje się do launchera → launcher pokazuje gry → każda gra ma osobne postacie w swoim engine DB.

### 2.2 Baza `api_core`
**Dane operacyjne API — tokeny, sesje, rate-limity, manifesty.**

| Tabela | Opis |
|--------|------|
| `api_sessions` | session_key, account_id, game_id, ip, expires_at (obecne: ticket_sessions) |
| `launch_tokens` | token, account_id, launcher_version, ip, expires_at |
| `ticket_nonces` | nonce, session_id, challenge, expires_at |
| `oauth_states` | state, provider, account_id, expires_at |
| `oauth_rate_limits` | ip, counter, window_start |
| `manifest_versions` | game_id, version, channel, files_hash, created_at |
| `launcher_updates` | game_id, platform (win/linux/android), version, download_url, sha256 |
| `account_sync_tokens` | sync token data |

### 2.3 Bazy `engine_*` (per serwer gry)
**Każdy serwer gry ma swoją bazę — osobne postacie, domy, gildie, topki.**

Przykłady:
- `engine_tibia_classic74` (obecnie: `canary`)
- `engine_tibia_modern` (obecnie: `canary_modern`)
- `engine_cs16_dust2` (przyszłość)
- `engine_cs16_inferno` (przyszłość)
- `engine_tibia_classic74_pvp` (przyszłość — drugi serwer 7.4)

Każda zawiera TYLKO tabele silnika gry (players, houses, guilds, etc.).
**NIE** zawiera accounts (konta są w `global_accounts`).

### 2.4 Baza `cms_web`
**Tabele CMS (MyAAC) — news, FAQ, galeria, menu, konfiguracja.**

| Tabela | Opis |
|--------|------|
| `myaac_*` | Wszystkie 16+ tabel MyAAC CMS |
| `z_polls*` | Ankiety |
| `arena_*` | System aren (jeśli globalny; jeśli per-game → engine) |

### 2.5 Baza `highscores_cache` (opcjonalna optymalizacja)
**Zmaterializowane topki — odczytywane często, zapisywane rzadko.**

| Tabela | Opis |
|--------|------|
| `hs_combined` | game_id, player_name, level, vocation, rank, updated_at |
| `hs_per_game` | game_id, player_id, metric, value, rank |

Topki aktualizowane co X minut cronem (nie live query z engine DB).
Przy 10+ serwerach gry, live query do każdego engine DB = zabójcze.

---

## 3. Mapowanie migracji: obecne → docelowe

| Obecna lokalizacja | Docelowa baza | Uwagi |
|--------------------|---------------|-------|
| `canaryaac.accounts` | `global_accounts.accounts` | Kluczowa migracja — account_id musi być zachowane |
| `canaryaac.account_identity_links` | `global_accounts.account_identity_links` | |
| `canaryaac.account_authentication` | `global_accounts.account_authentication` | Albo usunąć jeśli argon2 w accounts |
| `canaryaac.account_registration` | `global_accounts.accounts` (merge) | |
| `canaryaac.ticket_sessions` | `api_core.api_sessions` | Rename |
| `canaryaac.launch_tokens` | `api_core.launch_tokens` | |
| `canaryaac.ticket_nonces` | `api_core.ticket_nonces` | |
| `canaryaac.oauth_states` | `api_core.oauth_states` | |
| `canaryaac.oauth_rate_limits` | `api_core.oauth_rate_limits` | |
| `canaryaac.account_sync_tokens` | `api_core.account_sync_tokens` | |
| `canaryaac.manifest_versions` | `api_core.manifest_versions` | |
| `canaryaac.myaac_*` | `cms_web.myaac_*` | 16 tabel |
| `canaryaac.z_polls*` | `cms_web.z_polls*` | |
| `canaryaac.players` + engine tables | `engine_tibia_classic74.*` | = obecne `canary` |
| `canary_modern.*` | `engine_tibia_modern.*` | Rename |
| `canaryaac.arena_*` | `cms_web.arena_*` lub `engine_*` | Zależy od scope |

---

## 4. Wpływ na launcher i wieloplatformowość

### 4.1 Flow logowania (desktop + Android)
```
Launcher (Win/Linux/Android)
  │
  ├─ POST /apik/v1/login.php  {email, password}
  │   └─ API sprawdza global_accounts.accounts
  │   └─ Zwraca: sessionKey, lista gier z account_games
  │
  ├─ GET /apik/v1/games-list.php  {sessionKey}
  │   └─ API sprawdza games + account_games
  │   └─ Zwraca: [{slug, name, version, updateUrl, platform_support}]
  │
  ├─ POST /apik/v1/launcher-token.php  {sessionKey, gameSlug}
  │   └─ API tworzy launch_token w api_core
  │   └─ Zwraca: launchToken + ticketHex
  │
  └─ Launcher odpala grę z tokenem
      └─ Klient gry → POST /apik/v1/ticket.php
```

### 4.2 Pobieranie gier z launchera
```
Launcher
  ├─ GET /apik/v1/manifest.php?game=tibia_classic74&platform=windows
  │   └─ API czyta api_core.manifest_versions + api_core.launcher_updates
  │   └─ Zwraca: {version, files[], sha256, downloadUrl}
  │
  ├─ Porównuje z lokalną wersją
  │   └─ Jeśli starsza → pobiera delta/pełny update
  │   └─ Jeśli brak gry → "Zainstaluj" (pełne pobranie)
  │
  └─ Gra dostępna po pobraniu + weryfikacji hash
```

### 4.3 Android — różnice
- Launcher = APK (Kotlin/Flutter) zamiast Rust
- Gry = albo natywne APK, albo assety pobierane wewnątrz launchera
- API identyczne — te same endpointy
- Manifest rozszerzony o `platform: android` + `arch: arm64/x86_64`

---

## 5. Co trzeba zrobić TERAZ (przed kompilacją)

### KRYTYCZNE — blokujące dalsze prace
| # | Zadanie | Dlaczego teraz | Trudność |
|---|---------|----------------|----------|
| S1 | **Dodać tabelę `games` i `account_games` do `canaryaac`** | Launcher musi wiedzieć jakie gry gracz ma. Bez tego nie zrobimy listy gier w launcherze | Mała |
| S2 | **Wydzielić endpointy API od konkretnej gry** — `login.php` nie powinien hardkodować game_mode | Każda nowa gra = nowy hardkod. Teraz jest `classic74`/`modern`, potem będzie 20 game slugów | Średnia |
| S3 | **API: dodać `/apik/v1/games-list.php`** — zwraca listę gier gracza | Launcher desktop i Android tego potrzebuje | Mała |

### WAŻNE — ale mogą poczekać do fazy launcher/instalka
| # | Zadanie | Kiedy |
|---|---------|-------|
| S4 | Fizycznie wydzielić `global_accounts` z `canaryaac` | Przy deploy na produkcję / wiele instancji |
| S5 | Fizycznie wydzielić `api_core` z `canaryaac` | Przy deploy na produkcję |
| S6 | Fizycznie wydzielić `cms_web` z `canaryaac` | Przy deploy na produkcję |
| S7 | Przenieść accounts z engine DB → global_accounts (foreign keys) | Przy następnym schema reset |
| S8 | System cache topek (highscores_cache) | Przy >3 serwerach gry |
| S9 | Manifest per-platform (windows/linux/android) | Przy budowie launchera Android |

### DOBRE PRAKTYKI — wdrożyć od teraz
| # | Praktyka | Opis |
|---|----------|------|
| P1 | **Konfiguracja multi-DB w .env** | Dodać sekcje per-baza: `GLOBAL_DB_*`, `API_DB_*`, `ENGINE_*_DB_*` — nawet jeśli teraz wskazują na tę samą bazę, aliasy pozwolą potem łatwo rozdzielić |
| P2 | **Factory PDO per baza** | Zamiast `getModernDb()` → `getGameDb('tibia_modern')` z rejestrem gier |
| P3 | **Nigdy nie robić JOIN między bazami** | Zawsze merge w PHP — to już jest tak zrobione, utrzymać |
| P4 | **account_id jest globalny** | Każdy engine DB przechowuje `account_id` jako FK → global_accounts (nawet jeśli teraz jest w tej samej bazie) |

---

## 6. Schemat .env — docelowy (kompatybilny wstecz)

```env
# === GLOBAL ACCOUNTS DB ===
GLOBAL_DB_HOST=127.0.0.1
GLOBAL_DB_NAME=canaryaac        # <- teraz = canaryaac, potem = global_accounts
GLOBAL_DB_USER=ptaku
GLOBAL_DB_PASS=12345678
GLOBAL_DB_PORT=3306

# === API CORE DB ===
API_DB_HOST=127.0.0.1
API_DB_NAME=canaryaac            # <- teraz = canaryaac, potem = api_core
API_DB_USER=ptaku
API_DB_PASS=12345678
API_DB_PORT=3306

# === CMS DB (MyAAC website tables) ===
CMS_DB_HOST=127.0.0.1
CMS_DB_NAME=canaryaac            # <- teraz = canaryaac, potem = cms_web
CMS_DB_USER=ptaku
CMS_DB_PASS=12345678
CMS_DB_PORT=3306

# === ENGINE DBs (per game server) ===
ENGINE_TIBIA_CLASSIC74_DB_HOST=127.0.0.1
ENGINE_TIBIA_CLASSIC74_DB_NAME=canary
ENGINE_TIBIA_CLASSIC74_DB_USER=ptaku
ENGINE_TIBIA_CLASSIC74_DB_PASS=12345678

ENGINE_TIBIA_MODERN_DB_HOST=127.0.0.1
ENGINE_TIBIA_MODERN_DB_NAME=canary_modern
ENGINE_TIBIA_MODERN_DB_USER=ptaku
ENGINE_TIBIA_MODERN_DB_PASS=12345678

# Przyszłość:
# ENGINE_CS16_DUST2_DB_HOST=...
# ENGINE_CS16_DUST2_DB_NAME=engine_cs16_dust2
```

**Zaleta:** Teraz 3 bazy logiczne wskazują na `canaryaac`. Gdy będziemy gotowi do separacji → zmieniamy TYLKO .env, zero zmian w kodzie.

---

## 7. Tabele do dodania TERAZ

### 7.1 `games` — rejestr gier w platformie
```sql
CREATE TABLE IF NOT EXISTS `games` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `slug` VARCHAR(64) NOT NULL UNIQUE,
    `name` VARCHAR(128) NOT NULL,
    `engine_type` VARCHAR(32) NOT NULL DEFAULT 'canary',
    `engine_db_name` VARCHAR(64) NOT NULL,
    `engine_db_host` VARCHAR(128) NOT NULL DEFAULT '127.0.0.1',
    `game_host` VARCHAR(128) NOT NULL DEFAULT '127.0.0.1',
    `game_port` INT UNSIGNED NOT NULL DEFAULT 7172,
    `platform_windows` TINYINT(1) NOT NULL DEFAULT 1,
    `platform_linux` TINYINT(1) NOT NULL DEFAULT 1,
    `platform_android` TINYINT(1) NOT NULL DEFAULT 0,
    `status` ENUM('active','maintenance','disabled') NOT NULL DEFAULT 'active',
    `sort_order` INT NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 7.2 `account_games` — powiązanie konto → gry
```sql
CREATE TABLE IF NOT EXISTS `account_games` (
    `account_id` INT NOT NULL,
    `game_id` INT UNSIGNED NOT NULL,
    `joined_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`account_id`, `game_id`),
    KEY `idx_game` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 7.3 Dane początkowe
```sql
INSERT INTO `games` (`slug`, `name`, `engine_type`, `engine_db_name`, `game_port`, `sort_order`) VALUES
('tibia_classic74', 'Tibia Classic 7.4', 'canary', 'canary', 7172, 1),
('tibia_modern',    'Tibia Modern',      'canary', 'canary_modern', 7174, 2);
```

---

## 8. Diagram zależności — kto co czyta

```
                    ┌──────────────┐
                    │  LAUNCHER    │
                    │ (Win/And)    │
                    └──────┬───────┘
                           │
              ┌────────────▼────────────┐
              │     API GATEWAY         │
              │  /apik/v1/              │
              └──┬─────┬─────┬──────┬──-┘
                 │     │     │      │
    ┌────────────▼┐ ┌──▼──┐ ┌▼─────┐ ┌▼──────────┐
    │global_accts │ │api_ │ │cms_  │ │engine_*   │
    │             │ │core │ │web   │ │(per game) │
    │- accounts   │ │     │ │      │ │           │
    │- acc_games  │ │- ses│ │- news│ │- players  │
    │- games      │ │- tok│ │- faq │ │- houses   │
    │- identity   │ │- non│ │- menu│ │- guilds   │
    │             │ │- man│ │- poll│ │- market   │
    └─────────────┘ └─────┘ └──────┘ └───────────┘
         ▲              ▲        ▲          ▲
         │              │        │          │
    login.php     launcher-   MyAAC    highscores
    register      token.php   CMS      online
    games-list    ticket.php           serwer gry
```

---

## 9. Harmonogram migracji (proponowany)

| Faza | Kiedy | Co robimy |
|------|-------|-----------|
| **F0 — Teraz** | Marzec 2026 | Dodać tabele `games` + `account_games`, nowy .env z aliasami, endpoint `games-list.php` |
| **F1 — Kompilacja serwera** | Kwiecień 2026 | Użyć `games` w login.php zamiast hardkodu classic74/modern, testy z wieloma game slugami |
| **F2 — Launcher desktop** | Maj 2026 | Launcher czyta games-list, manifest per game, pobiera/aktualizuje gry |
| **F3 — Fizyczna separacja** | Przed produkcją | CREATE DATABASE `global_accounts`, `api_core`, `cms_web` + migracja danych + zmiana .env |
| **F4 — Launcher Android** | Po desktop | Manifest z `platform=android`, APK builder, ten sam API |
| **F5 — Nowe gry** | Ongoing | INSERT INTO `games` + nowy engine DB + klient + manifest |

---

## 10. Reguły dla całego zespołu

1. **Konto globalne nie należy do żadnej gry** — accounts jest w global_accounts, NIE w engine DB
2. **Każda gra = osobna baza engine** — nigdy nie mieszać players z dwóch gier w jednej bazie
3. **API nie wie o strukturze gry** — API wie tylko: account_id, game_slug, session_key. Nie wie o vocation, level, etc.
4. **Topki/online = cache lub merge w PHP** — nigdy cross-DB JOIN
5. **Launcher = głupi klient** — nie wie o bazach, nie łączy się z DB, tylko z API via HTTPS
6. **Android = ten sam API co desktop** — zero duplikacji backendów
7. **Nowa gra = 3 kroki**: (a) CREATE DATABASE engine_x, (b) INSERT INTO games, (c) skonfiguruj klienta w manifest

---

## 11. Wpływ na obecny kod — co trzeba zmienić

### Teraz (S1-S3)
| Plik | Zmiana |
|------|--------|
| `apik/v1/.env` | Dodać aliasy GLOBAL_DB_*, API_DB_*, zachować stare dla kompatybilności |
| `canaryaac` SQL | CREATE TABLE `games`, `account_games` + INSERT dane początkowe |
| `apik/v1/games-list.php` | NOWY — zwraca listę gier dla zalogowanego gracza |
| `apik/v1/login.php` | Zamienić hardkod `classic74`/`modern` na lookup z tabeli `games` |
| `apik/v1/common.php` | `getEnginePdo()` — czytać host/name z tabeli `games` zamiast .env |

### Przy fizycznej separacji (S4-S7)
| Plik | Zmiana |
|------|--------|
| `apik/v1/common.php` | `getGlobalDb()`, `getApiDb()`, `getCmsDb()` — nowe factory |
| `config.local.php` | `database_name` → `cms_web` (dla MyAAC) |
| `system/login.php` | Eloquent connection → `global_accounts` zamiast `canaryaac` |
| `system/database_modern.php` | Zastąpić `getGameDb($slug)` universal factory |
| Migracja SQL | mysqldump + selective import |
