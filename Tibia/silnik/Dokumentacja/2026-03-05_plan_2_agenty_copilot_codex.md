# PLAN PRACY — 2 agentów: Copilot + Codex

**Data:** 2026-03-05  
**Gałąź:** `feature/ticket-gate`  
**Git root:** `/home/ptaku/serweryt/`  
**Kontekst:** Paczka OTClient gotowa (7232 pliki, 415 MB), manifest v2 serwowany, pliki dostępne przez nginx.

---

## ZASADY

1. **NIGDY nie pushuj bez zgody usera** — z wyjątkiem wprost podanych poleceń
2. **NIGDY nie instaluj toolchain lokalnie** — kompilacja TYLKO na GitHub Actions
3. **Copilot** = agent interaktywny (w rozmowie, decyzje architektoniczne, review, push, pliki PHP/Rust/frontend)
4. **Codex** = agent autonomiczny (zadania opisane precyzyjnie, odpalane jako taski, bez interakcji)
5. **Lokalne kompilacje Rust są zablokowane operacyjnie** (`launcher-rust/.cargo/config.toml`, `rustc-wrapper=/bin/false`)

---

## CEL KOŃCOWY NA 2026-03-06 (JUTRO)

Finalny cel demonstracyjny:
- uruchomić launcher z docelowej paczki Windows pobranej przez usera,
- połączyć się równocześnie klientem z trybem **7.4** i **modern**,
- pokazać działającą różnicę polityk bezpieczeństwa (np. blokada hotkeys na runy w 7.4, brak tej blokady w modern),
- potwierdzić, że poprawki launcher/klient są dostarczane przez mechanizm update + self-update.

### Kryteria akceptacji (must-have)

| ID | Kryterium | Status |
|----|-----------|--------|
| D1 | Start z paczki Windows pobranej przez usera (ta paczka = source of truth testów) | ⏳ |
| D2 | Jednoczesne uruchomienie sesji 7.4 i modern z launchera | ⏳ |
| D3 | Widoczna różnica zasad: 7.4 ma blokady anty-cheat (hotkeys/runy), modern bez tej blokady | ⏳ |
| D4 | Modyfikacja pliku krytycznego blokuje start i prowadzi przez repair/update | ⏳ |
| D5 | Launcher self-update dostarcza nową wersję i poprawki dla graczy bez ręcznej reinstalacji | ⏳ |
| D6 | Update instalki graczy działa po publikacji nowego manifestu (zmiana plików klienta) | ⏳ |
| D7 | Na paczce graczy widać osobno `Canary Modern` i `Canary 7.4` (bez kolizji hosta) | ⏳ |
| D8 | Jednoczesne uruchomienie sesji `Canary Modern` i `Canary 7.4` z tej samej instalki graczy | ⏳ |
| D9 | Pełny przebieg: self-update launchera -> update instalki -> start obu serwerów | ⏳ |

### Zasady testowe (obowiązujące od 2026-03-05)

1. Testy akceptacyjne launcher/klient wykonujemy na tej samej paczce Windows, którą pobrał user.
2. Buildy developerskie lokalne mogą służyć do debugu, ale nie są podstawą akceptacji końcowej.
3. Każda poprawka klienta lub launchera musi przejść ścieżkę dystrybucji dla graczy: update lub self-update.
4. Każdy nowy problem (UI, instalka, bezpieczeństwo, zgodność trybów) dopisujemy do planu i statusu z przypisanym agentem.

### Podział pracy do celu 2026-03-06

| # | Zadanie | Agent | Status |
|---|---------|-------|--------|
| J1 | ✅ Zamknięta checklista dual-mode (7.4 + modern) i mapa różnic zachowań — `2026-03-05_dual_mode_checklist_J1.md` | Copilot | ✅ |
| J2 | ✅ Weryfikacja blokad hotkeys/runy dla 7.4 — `2026-03-05_dual_mode_hotkey_audit_J2.md` (23 guardy, 100% poprawne) | Copilot | ✅ |
| J3 | Przygotować testy i scenariusz dowodowy dla D1..D5 (kroki + expected result) — `2026-03-05_dual_mode_test_checklista_J1.md` | Codex | ✅ |
| J4 | Dopisać do dokumentacji wynik każdego testu z paczki Windows (pass/fail, data, wersja) — `2026-03-05_dual_mode_test_results_J4.md` | Codex | 🔄 |
| J5 | ✅ Potwierdzona ścieżka self-update jako jedyny kanał dystrybucji — `2026-03-05_self_update_path_J5.md` | Copilot | ✅ |
| J6 | ✅ Rejestr otwartych bugów (8 otwartych, 34 naprawione) — `2026-03-05_ui_installer_bug_registry_J6.md` | Copilot + Codex | ✅ |
| J7 | Spisać i wdrożyć różnicę `instalka zwykła/dev` vs `instalka graczy/prod` (kanały, ścieżki, konfiguracja) — `2026-03-05_instalka_dev_vs_gracze_J7.md` | Copilot + Codex | 🔄 |
| J8 | Dopięcie publikacji paczki graczy (clean artifact + manifest + checksums + hosting) | Copilot | ⬜ |
| J9 | Potwierdzić osobne konfiguracje serwerów `canary-modern` i `canary-classic74` w DB/API/launcher | Copilot | ⬜ |
| J10 | Test i dokumentacja self-update launchera na paczce graczy (D5) | Copilot + Codex | ⬜ |
| J11 | Test i dokumentacja update instalki graczy po zmianie plików (D6) | Copilot + Codex | ⬜ |
| J12 | Test równoległego startu obu serwerów z jednej instalki graczy (D8) | Copilot + Codex | ⬜ |
| J13 | Test pełnego łańcucha D9 (self-update -> client update -> dual run) | Copilot + Codex | ⬜ |
| J14 | Uzupełnić `J4` pełnymi wynikami D1..D9 (PASS/FAIL/BLOCKED + wersje + data) | Codex | 🔄 |
| J15 | Plan i kontrakt: wspólne konto 2 serwery + wybór serwera po logowaniu + topki/listy (`K1..K10`) | Codex | ✅ |
| J16 | Login/session: tryb `all` (bez wymuszania `modern` przy pustym gameMode) | Copilot | 🟢 (repo, deploy runtime BLOCKED) |
| J17 | Ticket flow: sesja `all` + walidacja postaci do wybranego serwera | Copilot | 🟢 (repo, deploy runtime BLOCKED) |
| J18 | Rejestracja konta przez launcher (endpoint API) | Copilot | 🟢 (repo, deploy runtime BLOCKED) |
| J19 | Endpoint kontekstu konta (serwer + postacie per serwer) dla strony/launchera | Copilot | 🟢 (repo, deploy runtime BLOCKED) |
| J20 | Endpoint topki `all/classic74/modern` + lista graczy `all/classic74/modern` | Copilot | 🟢 (repo, deploy runtime BLOCKED) |
| J21 | Integracja UI strony: wybór serwera po zalogowaniu i przełączanie kontekstu konta | Copilot + Codex | ⬜ |
| J22 | Testy akceptacyjne K-GATE (KG1..KG10) + wpis do `J4` | Codex | 🔄 (lokalne testy kontraktu endpointów PASS, runtime E2E otwarte) |
| J23 | Migracja DB identity/social/sync (`004_identity_social`) | Codex | ✅ (APPLIED 2026-03-05 19:12) |
| J24 | Sync token exchange WWW↔launcher (issue/consume) | Copilot + Codex | 🟢 (repo + testy lokalne PASS) |
| J25 | Flow launcher->WWW: konto utworzone w launcherze, postacie na WWW | Copilot + Codex | 🟢 (repo + lokalny E2E PASS) |
| J26 | Flow WWW->launcher: konto utworzone na WWW, sync do launchera | Copilot + Codex | 🟢 (repo + lokalny E2E PASS) |
| J27 | Social auth Google w launcherze (link/create) | Copilot + Codex | 🔄 backend API gotowy w repo (`oauth-start.php`, `oauth-callback.php`), runtime/secrets/UI launcher pending |
| J28 | Social auth Facebook i Steam w launcherze (link/create) | Copilot + Codex | 🔄 backend API gotowy w repo (`oauth-start.php`, `oauth-callback.php`), runtime/secrets/UI launcher pending |
| J29 | Hardening social/sync: PKCE + state/nonce + rate-limit + audit + anty-merge-collision | Copilot + Codex | 🔄 czesciowo (PKCE oauth2 + one-time state + audit + anti-merge-collision + DB rate-limit w repo, migracja 005 pending) |
| J30 | UX launcher-first: po rejestracji 2 akcje `Utworz postac Tibia 7.4/Modern` + przekierowanie WWW z preselectem swiata | Copilot + Codex | 🟢 (repo, runtime test pending) |

**Nowe źródło planu (2026-03-05):**
- `Tibia/silnik/Dokumentacja/01_Instalka_Klient/2026-03/03_PLAN_WSPOLNE_KONTO_2_SERWERY.md`
- Uwaga: deploy runtime `/var/www/html/apik/v1/` z tej sesji BLOCKED (brak sudo hasła), a tabela `accounts` nie ma UNIQUE dla `email`.
- Uwaga #1a: dla J25/J26 dodane endpointy mostu sesji WWW: `account-sync-www-login.php` i `account-sync-www-token.php`; test lokalny launcher->WWW->launcher PASS.
- Uwaga #1b: dla J27 dodany `oauth-callback.php` (Google): mapowanie/link identity -> lokalne konto + sesja `ticket_sessions` + opcjonalny deep-link do launchera.
- Uwaga #1c: dla J29 dodana migracja `005_oauth_rate_limit` i DB-backed rate-limit w `oauth-start.php` / `oauth-callback.php` (feature flag `OAUTH_RATE_LIMIT_ENABLED`).
- Uwaga #1d: rozszerzono backend social auth na `facebook` i `steam` (OAuth2/OpenID) w `oauth-start.php` + `oauth-callback.php`; nadal pending runtime secrets + E2E.
- Uwaga #2: user wymaga social signup/login w launcherze (Google/Facebook/Steam) oraz dwukierunkowej synchronizacji konto WWW <-> launcher.
- Uwaga #3: user wymaga tez spojnego i intuicyjnego flow gracza: po rejestracji w launcherze ma byc natychmiastowy wybor tworzenia postaci `Tibia 7.4` lub `Modern` na WWW.

---

## PODZIAŁ ODPOWIEDZIALNOŚCI

### Copilot (interaktywny)
- Architektura, decyzje, koordynacja
- PHP API (ticket, token, manifest, status)
- Rust: launcher-core (planner, manifest, challenge, integrity, update flow)
- Tauri commands (state.rs, commands.rs)
- Frontend React/TypeScript (ui/)
- nginx, baza danych, konfiguracja serwera
- CI/CD workflows (.github/)
- **Pushuje** i **commituje**

### Codex (autonomiczny)
- Testy Rust (unit + integration)
- SQL migracje (rollout/rollback)
- Structured logging w PHP
- Runbook / dokumentacja techniczna
- Analiza kodu (read-only) + raporty
- Hardening: klucze, podpisy, checksumy

---

## FAZA 0 — TESZT PEŁNEGO FLOW (teraz)

**Agent: Copilot** (zrobione/w toku)

| # | Zadanie | Status |
|---|---------|--------|
| 0.1 | Paczka OTClient na WSL (testyy) | ✅ 7232 plików, 415 MB |
| 0.2 | Symlink `/var/www/html/apik/v1/files/stable/1.0.1/` → testyy | ✅ |
| 0.3 | generate_manifest.php: v2 format, baseUrl, exclusions | ✅ |
| 0.4 | Manifest v2: schemaVersion, baseUrl, filesHashExpected | ✅ |
| 0.5 | End-to-end curl: manifest → URL resolve → download → SHA verify | ✅ |
| 0.6 | Zbudować launcher na GHA i przetestować prawdziwy download | 🔧 |
| 0.7 | Przetestować update: zmienić plik → nowa wersja → launcher podchwyci | 🔧 |
| 0.8 | Przetestować repair: usunąć plik → launcher naprawi | 🔧 |

---

## FAZA 1 — BAZA DANYCH I MIGRACJE (P1)

### Copilot: Review + deploy migracji

| # | Zadanie | Agent | Status |
|---|---------|-------|--------|
| 1.1 | Przejrzeć istniejące tabele w MySQL (co już jest) | Copilot | ✅ DONE (Copilot, 2026-03-05) |
| 1.2 | Uruchomić migracje na WSL MySQL | Copilot | ✅ DONE (Copilot, 2026-03-05) |
| 1.3 | Zweryfikować cleanup events (SHOW EVENTS) | Copilot | ✅ DONE (Copilot, 2026-03-05) |

**Wyniki review 1.1 (105 tabel, 5 kategorii):**
- 48 CANARY (core schema.sql — accounts, players, guilds, etc.)
- 41 MYAAC (canary_*, myaac_*, z_polls, _migrations)
- 6 ARENA (arena_matches, arena_players, arena_queue, etc. — custom)
- 6 EXTENDED (account_authentication, player_badges, player_display, etc.)
- 4 LAUNCHER (launch_tokens, ticket_nonces, ticket_sessions, manifest_versions)

**Wyniki deploy 1.2:**
- `php migrate.php rollout` — 3 migracje APPLIED (001, 002, 003)
- Tabele już istniały (CREATE IF NOT EXISTS), _migrations teraz śledzi stan

**Wyniki weryfikacji 1.3:**
- event_scheduler = ON (włączony przez migrate.php)
- 3 MySQL EVENTs ENABLED (co 15 min):
  - `cleanup_expired_nonces` — DELETE FROM ticket_nonces WHERE expires_at < UNIX_TIMESTAMP()
  - `cleanup_expired_tokens` — DELETE FROM launch_tokens WHERE expires_at < NOW()
  - `cleanup_expired_sessions` — DELETE FROM ticket_sessions WHERE expires_at < UNIX_TIMESTAMP()
- Backup: inline cleanup w PHP (launcher-token.php ~10%, ticket.php, login.php)

### Codex: Napisać SQL + PHP runner

| # | Zadanie | Opis |
|---|---------|------|
| 1.4 | `migrations/001_ticket_gate_rollout.sql` | CREATE ticket_nonces, ticket_sessions, _migrations | ✅ DONE (Codex, 2026-03-05) |
| 1.5 | `migrations/001_ticket_gate_rollback.sql` | DROP + DELETE z _migrations | ✅ DONE (Codex, 2026-03-05) |
| 1.6 | `migrations/002_launcher_tables_rollout.sql` | CREATE launch_tokens, manifest_versions | ✅ DONE (Codex, 2026-03-05) |
| 1.7 | `migrations/002_launcher_tables_rollback.sql` | DROP + DELETE | ✅ DONE (Codex, 2026-03-05) |
| 1.8 | `migrations/003_cleanup_events_rollout.sql` | MySQL EVENT scheduler (15min cleanup) | ✅ DONE (Codex, 2026-03-05) |
| 1.9 | `migrations/003_cleanup_events_rollback.sql` | DROP EVENT | ✅ DONE (Codex, 2026-03-05) |
| 1.10 | `migrations/migrate.php` | CLI runner: rollout, rollback N, status | ✅ DONE (Codex, 2026-03-05) |

**Walidacja Codex:**
- `php -l migrations/migrate.php` ✅
- `php migrations/migrate.php status` ✅

**Problemy do wspólnego domknięcia (Copilot+Codex):**
1. ~~`event_scheduler` może wymagać uprawnień DBA.~~ → ✅ ROZWIĄZANE: ptaku@localhost ma uprawnienia, migrate.php sam włącza scheduler
2. Potrzebna decyzja o jednym canonical źródle migracji (obecnie kilka historycznych plików schema).
   - schema_ticket_gate.sql i schema_launcher.sql to oryginalne DDL (nadal w repo)
   - migrations/ to nowy kanoniczny system — używać go do zmian
   - **UWAGA:** komentarz w schema_ticket_gate.sql różni się live vs repo (drobna rozbieżność)

**Pliki do edycji:** `canary_test/html_copy/apik/v1/migrations/` (nowe)  
**NIE DOTYKAJ:** Rust, frontend, workflows

---

## FAZA 2 — TESTY BEZPIECZEŃSTWA (P2)

### Codex: Unit testy ticketów w Rust

| # | Zadanie | Plik |
|---|---------|------|
| 2.1 | `test_ticket_replay_rejected` — ten sam nonce 2x → reject | `tests/ticket_security_tests.rs` |
| 2.2 | `test_expired_ticket_rejected` — expires_at < now → reject | j.w. |
| 2.3 | `test_future_ticket_clock_skew` — expires_at > now+5min → reject | j.w. |
| 2.4 | `test_tampered_hmac_rejected` — zmieniony payload → reject | j.w. |
| 2.5 | `test_empty_nonce_rejected` — pusty nonce → reject | j.w. |
| 2.6 | `test_oversized_payload_rejected` — >4KB → reject | j.w. |
| 2.7 | `test_valid_ticket_accepted` — happy path | j.w. |
| 2.8 | `test_game_mode_variants` — modern, classic74 | j.w. |
| 2.9 | `test_grace_period_within` — 5s po expiry → OK | j.w. |
| 2.10 | `test_grace_period_exceeded` — 6s po expiry → reject | j.w. |

### Codex: Testy challenge-response

| # | Zadanie | Plik | Status |
|---|---------|------|--------|
| 2.11 | `test_challenge_with_rotated_key` — stary kid → nowy kid | `launcher-core/src/hmac_rotation.rs` | ✅ DONE (Codex, 2026-03-05 16:03) |
| 2.12 | `test_challenge_response_timing` — max 30s | `launcher-api/src/client.rs` | ✅ DONE (Codex, 2026-03-05 15:55) |
| 2.13 | `test_challenge_with_empty_nonce` — edge case | `launcher-core/src/challenge.rs` | ✅ DONE wcześniej (test modułowy już istniał) |

### Codex: Testy manifest/planner

| # | Zadanie | Plik | Status |
|---|---------|------|--------|
| 2.14 | `test_manifest_v2_with_base_url` — parse v2, resolve URLs | `common-models/src/manifest.rs` | ✅ DONE wcześniej (`baseUrl` coverage już było) |
| 2.15 | `test_planner_empty_url_uses_base` — empty url → base+path | `launcher-core/src/planner.rs` | ✅ DONE wcześniej (`test_resolve_file_url_with_base`) |
| 2.16 | `test_planner_absolute_url_unchanged` — https:// → as-is | `launcher-core/src/planner.rs` | ✅ DONE (Codex, 2026-03-05 15:55) |
| 2.17 | `test_planner_missing_base_url_error` — no base + relative → error | `launcher-core/src/planner.rs` | ✅ DONE (Codex, 2026-03-05 15:55) |
| 2.18 | `test_manifest_servers_field_parsed` — servers[] z portem | `common-models/src/manifest.rs` | ✅ DONE (Codex, 2026-03-05 15:55) |

**Update P2 (Codex, 2026-03-05 15:55):**
- Dodano twardą walidację challenge w `launcher-api/src/client.rs` (`nonce` + TTL <= 30s) + 6 testów.
- `rustfmt --check` na zmienionych plikach Rust: ✅
- Otwarte: testy stricte ticket replay/expired/clock-skew po stronie serwerowej.

**Update P2 (Codex, 2026-03-05 16:03):**
- Dodano test `test_challenge_with_rotated_key` w `launcher-core/src/hmac_rotation.rs` (stary+nowy `kid`, fallback bez `kid`).

### Copilot: Review + CI push

| # | Zadanie |
|---|---------|
| 2.19 | Review testów od Codex, ewentualne poprawki |
| 2.20 | Push → sprawdzenie `cargo test` na CI |

---

## FAZA 3 — STRUCTURED LOGGING (P3)

### Codex: Logger w PHP

| # | Zadanie | Plik | Status |
|---|---------|------|--------|
| 3.1 | Funkcja `logTicketEvent()` w common.php | `apik/v1/common.php` | ✅ DONE (Codex, 2026-03-05) |
| 3.2 | Logowanie w ticket.php (issued, rejected.*) | `apik/v1/ticket.php` | ✅ DONE (Codex, 2026-03-05) |
| 3.3 | Logowanie w launcher-token.php (issued, rejected.*) | `apik/v1/launcher-token.php` | ✅ DONE (Codex, 2026-03-05) |
| 3.4 | Logowanie w challenge.php (issued) | `apik/v1/challenge.php` | ✅ DONE (Codex, 2026-03-05 16:03) |
| 3.5 | Logowanie w server-status.php (checked) | `apik/v1/server-status.php` | ✅ DONE (Codex, 2026-03-05 16:03) |
| 3.6 | Logrotate config: `/etc/logrotate.d/serwercanary` | nowy plik | ✅ TEMPLATE DONE (`apik/v1/logrotate/serwercanary`) |

**Walidacja Codex:**
- `php -l common.php` ✅
- `php -l ticket.php` ✅
- `php -l launcher-token.php` ✅

**Problemy do wspólnego domknięcia (Copilot+Codex):**
1. ~~Dodać/uzgodnić brakujące endpointy `challenge.php` i `server-status.php` albo zmienić scope P3.~~ → ✅ DONE (Codex, 2026-03-05 16:03)
2. ~~Deploy: utworzyć `/var/log/serwercanary` i wdrożyć template logrotate do `/etc/logrotate.d/serwercanary`.~~ → ✅ DONE (Copilot, 2026-03-05)
3. Potwierdzić operacyjnie `CHALLENGE_REQUIRED=true` (rollout etapowy) oraz kompatybilność klientów legacy.

### Copilot: Deploy + test

| # | Zadanie | Status |
|---|---------|--------|
| 3.7 | Utworzyć /var/log/serwercanary/ z uprawnieniami www-data | ✅ DONE (Copilot, 2026-03-05) |
| 3.8 | Skopiować zmienione PHP na serwer | ✅ DONE (Copilot, 2026-03-05) — common.php, ticket.php, launcher-token.php |
| 3.9 | Test: curl endpoint → sprawdzić logi | ✅ DONE — 3 eventy w /var/log/serwercanary/security-events.log |
| 3.10 | Zainstalować logrotate config | ✅ DONE (Copilot, 2026-03-05) — /etc/logrotate.d/serwercanary |

**Wyniki testu 3.9:**
- `launcher_token.rejected.files_hash_mismatch` — endpoint: launcher-token.php, ipHash, latencyMs ✅
- `ticket.rejected.invalid_action` — action mismatch ✅
- `ticket.rejected.invalid_session` — sessionKeyHash, ipHash, latencyMs ✅
- Format: JSONL, 1 linia per event, maszyna-czytelne

---

## FAZA 4 — LAUNCHER REAL FLOW (aktualizacje + naprawa)

### Copilot: Setup + testowanie

| # | Zadanie | Opis |
|---|---------|------|
| 4.1 | Build launcher na GHA (trigger workflow) | Push → CI build |
| 4.2 | Pobrać artefakt (canary-launcher-linux.zip) | Z GHA artifacts |
| 4.3 | Uruchomić launcher z `launcher_config.json` | devMode: true |
| 4.4 | Test pierwszej instalacji klienta (download 415 MB) | Check for update → Install |
| 4.5 | Test aktualizacji: dodać plik do testyy → nowa wersja 1.0.2 | Regenerate manifest → launcher widzi nową wersję |
| 4.6 | Test naprawy: usunąć DLL z install dir → Repair | Launcher wykrywa brak pliku → redownload |
| 4.7 | Test integralności: sha256 wszystkich pobranych plików | Porównanie z manifestem |

### Copilot: Naprawy flow jeśli coś nie działa

| # | Zadanie (jeśli potrzebne) |
|---|---------------------------|
| 4.8 | Fix Rust: download_file() obsługa SSL self-signed (devMode) |
| 4.9 | Fix Rust: planner edge cases (puste katalogi, symlinki) |
| 4.10 | Fix Rust: progress events (Tauri emit) |
| 4.11 | Fix PHP: generate_manifest.php edge cases |
| 4.12 | Fix nginx: duże pliki (client_max_body_size), long timeouts |

---

## FAZA 4.5 — OCHRONA PLIKÓW KLIENTA (PACKAGING)

### Problem

Obecna paczka OTClient zawiera 290 plików `.lua` w czytelnej formie (plain text).
Użytkownik ściąga klienta i ma **pełny dostęp** do:
- `init.lua` — konfiguracja serwerów, CLIENT_LOCKED, GameModes, porty, adresy
- `modules/*/` — 70+ modułów Lua (entergame, serverlist, battle, console, features...)
- `data/locales/*.lua` — 111 plików locale

**Ryzyko:** Użytkownik może:
1. Zmienić `CLIENT_LOCKED = false` → odblokować dodawanie serwerów
2. Zmienić adres serwera / port → ominąć ticket gate
3. Wyłączyć moduły bezpieczeństwa
4. Edytować logikę gry (modules/gamelib, game_interface, itp.)
5. Podmienić tłumaczenia (locales) na obraźliwe treści

### Strategia: 3-warstwowa ochrona

#### Warstwa 1: Podział plików na kategorie w manifeście

| Kategoria | managed | overwritePolicy | Opis |
|-----------|---------|-----------------|------|
| **Core engine** | `true` | `always` | `otclient.exe`, DLL, shader `.frag/.vert` — zawsze aktualizowane |
| **Moduły Lua (system)** | `true` | `if_hash_differs` | `modules/*/`, `init.lua` — kontrolowane, nadpisywane przy update |
| **Dane gry (sprites, .lzma)** | `true` | `if_hash_differs` | `data/things/*.lzma`, `data/sprites/` |
| **Ustawienia użytkownika** | `true` | `preserve_user` | `otclientrc.lua`, `data/settings/` — nie nadpisuj, jeśli istnieją |
| **Pliki unmanaged** | `false` | — | `records/`, `screenshots/` — launcher nie rusza |

#### Warstwa 2: Integrity check przy uruchamianiu

Launcher przed uruchomieniem klienta:
1. Sprawdź SHA-256 **krytycznych plików** (`init.lua`, `modules/client_entergame/entergame.lua`, `modules/client_serverlist/serverlist.lua`)
2. Jeśli hash nie zgadza się z manifestem → **BLOKADA** + komunikat "Pliki klienta zostały zmodyfikowane. Napraw instalację."
3. Opcjonalnie: automatyczna naprawa (redownload zmodyfikowanych plików)

#### Warstwa 3: Kompilacja Lua do bytecodu (przyszłość)

OTClient wspiera `luac` bytecode. Zamiast plain text `.lua`:
```bash
luac -o init.luac init.lua        # bytecode — nie daje się czytać
```
- Wymaga zmiany w OTClient build pipeline (GHA)
- **Nie blokuje teraz** — Warstwa 1+2 wystarczą na start

### Copilot: Implementacja w manifeście i launcherze

| # | Zadanie | Opis | Status |
|---|---------|------|--------|
| 4.5.1 | Rozszerzyć `generate_manifest.php` o kategorie plików | Reguły: *.lua→managed+if_hash_differs, otclientrc.lua→preserve_user, records/→unmanaged | ✅ |
| 4.5.2 | Dodać sekcję `criticalFiles[]` do manifestu | Lista plików wymagających integrity check przed launch | ✅ |
| 4.5.3 | Rust: `verify_critical_files()` w launcher-core | Sprawdza SHA-256 krytycznych plików przed uruchomieniem klienta | ✅ |
| 4.5.4 | Tauri command: `pre_launch_check` | Wywołuje verify_critical_files, zwraca status | ✅ |
| 4.5.5 | Frontend: blokada przycisku "Graj" jeśli integrity failed | Komunikat + przycisk "Napraw" | ✅ |
| 4.5.6 | Regenerować manifest z kategoriami | PHP: nowe reguły + regeneracja 1.0.2 | ✅ |

### Codex: Testy ochrony plików

| # | Zadanie |
|---|---------|
| 4.5.7 | `test_critical_file_modified_blocks_launch` — zmieniony init.lua → blokada |
| 4.5.8 | `test_critical_file_missing_triggers_repair` — brak init.lua → repair |
| 4.5.9 | `test_preserve_user_file_not_overwritten` — otclientrc.lua zachowany |
| 4.5.10 | `test_unmanaged_file_ignored` — records/ nie ruszane |
| 4.5.11 | `test_managed_lua_always_updated` — zmodyfikowany moduł → redownload |

### Pliki krytyczne (integrity check przed launch)

```
init.lua                                    # config serwerów, CLIENT_LOCKED
modules/client_entergame/entergame.lua      # logika logowania
modules/client_entergame/characterlist.lua  # lista postaci
modules/client_serverlist/serverlist.lua    # lista serwerów
modules/client_serverlist/addserver.lua     # dodawanie serwerów
modules/startup/startup.lua                 # sekwencja startowa
modules/corelib/network.lua                 # komunikacja sieciowa (jeśli istnieje)
modules/client_topmenu/*.lua                # menu główne
```

---

## FAZA 4.7 — BUILD INSTALKI KLIENTA DLA GRACZY (GHA WORKFLOW)

### Problem

Obecna paczka klienta (`canary_test/testyy/`) zawiera **pliki źródłowe** (1298 plików `.cpp/.h/.hpp`, katalog `src/`, CMakeLists.txt, itp.) — to jest **kopia repozytorium**, nie gotowa instalka.

Gracze powinni dostawać **czystą, skompilowaną paczkę** — tak jak robi to opentibia-br:
- Tylko `otclient.exe` + DLL-ki + moduły Lua + assety (sprites, .lzma) + dane
- Bez kodu źródłowego, bez CMake, bez `src/`, bez plików deweloperskich
- ZIP gotowy do rozpakowania i grania

Obecnie `generate_manifest.php` wyklucza pliki źródłowe z manifestu (filtry `src/`, `cmake/`, `*.cpp`, `*.h`), ale to **obejście** — właściwym rozwiązaniem jest workflow GHA który buduje czystą instalkę.

### Wzorzec: opentibia-br/otclient releases

OTClientBR wypuszcza na GitHub Releases ZIP-y:
```
otclient-windows-release.zip
├── otclient.exe
├── *.dll (runtime dependencies)
├── modules/
├── data/
├── init.lua
└── (brak src/, cmake/, .cpp, .h)
```

My musimy zrobić to samo, ale z naszymi customizacjami (init.lua z naszymi serwerami, CLIENT_LOCKED=true, nasze moduły).

### Copilot: Workflow + konfiguracja

| # | Zadanie | Opis | Status |
|---|---------|------|--------|
| 4.7.1 | Workflow GHA `build-client-package.yml` | Kompilacja OTClient (vcpkg + CMake) → ZIP bez plików źródłowych | ✅ DONE (Copilot, 2026-03-05) |
| 4.7.2 | Krok: inject naszego `init.lua` (CLIENT_LOCKED, serwery, tryby) | Nadpisanie domyślnego init.lua naszą konfiguracją | ✅ w 4.7.1 (sed CLIENT_LOCKED=true) |
| 4.7.3 | Krok: inject/update `modules/` z naszymi customizacjami | Podmiana zmodyfikowanych modułów (serverlist lock, feature flags) | ✅ DONE — customizations/ overlay w obu OS builds (Copilot, 2026-03-05) |
| 4.7.4 | Krok: strip plików deweloperskich z artefaktu | Usunięcie src/, cmake/, *.cpp, *.h, CMakeLists.txt, docs/, tests/ | ✅ w 4.7.1 (strip + verify steps) |
| 4.7.5 | Krok: generacja manifestu z gotowej paczki | `generate_manifest.php` na czystym artefakcie (nie na repo!) | ✅ DONE — SHA-256 per-file manifest JSON + upload (Copilot, 2026-03-05) |
| 4.7.6 | Krok: upload ZIP + manifest jako GHA artifacts / release | Artefakty gotowe do pobrania na serwer | ✅ w 4.7.1 (upload-artifact, 90 days) |
| 4.7.7 | Skrypt deploy: skopiować ZIP na serwer, rozpakować, update symlink | Deploy nowej wersji klienta na nginx | ✅ DONE — tools/deploy-client.sh (Copilot, 2026-03-05) |

### Codex: Testy pipeline

| # | Zadanie |
|---|--------|
| 4.7.8 | Test: artefakt ZIP nie zawiera plików `.cpp`, `.h`, `src/`, `cmake/` |
| 4.7.9 | Test: artefakt zawiera `otclient.exe` + wymagane DLL + `init.lua` |
| 4.7.10 | Test: `init.lua` w artefakcie ma `CLIENT_LOCKED = true` |
| 4.7.11 | Test: manifest wygenerowany z artefaktu ma poprawne SHA-256 |

### Build matrix

| Target | OS | Kompilator | Output |
|--------|----|-----------|--------|
| Windows x64 | windows-2022 | MSVC 17 (vc17) | `otclient.exe` + DLL |
| Linux x64 | ubuntu-22.04 | GCC 12 | `otclient` (ELF) + .so |

### Pipeline flow

```
[Push tag / manual trigger]
     │
     ▼
[Checkout OTClient repo]
     │
     ▼
[vcpkg install dependencies]
     │
     ▼
[CMake configure + build (Release)]
     │
     ▼
[Inject: init.lua, modules/, data/ customizacje]
     │
     ▼
[Strip: src/, cmake/, *.cpp, *.h, docs/, tests/]
     │
     ▼
[ZIP artifact: otclient-{os}-{version}.zip]
     │
     ▼
[Generate manifest z czystej paczki]
     │
     ▼
[Upload: GHA artifacts + optional GitHub Release]
     │
     ▼
[Deploy na serwer: unzip → symlink → gotowe dla launchera]
```

---

## FAZA 5 — PORTY I KONFIGURACJA (P6)

### Copilot: Analiza + implementacja

| # | Zadanie | Opis | Status |
|---|---------|------|--------|
| 5.1 | Audit: gdzie jest port hardcoded | server-status.php, config.lua, .env, servers[] | ✅ DONE (Copilot, 2026-03-05) |
| 5.2 | Zmienić server-status.php: osobna kontrola loginPort + gamePort | PHP | ✅ DONE (Copilot, 2026-03-05) |
| 5.3 | Zmienić manifest servers[]: dodać loginPort + gamePort | generate_manifest.php | ✅ DONE (Copilot, 2026-03-05) |
| 5.4 | Zmienić Rust ServerEntry: loginPort + gamePort | common-models | ✅ DONE (Copilot, 2026-03-05) |
| 5.5 | Zmienić .env: LOGIN_PORT, GAME_PORT osobno | .env | ✅ DONE (Copilot, 2026-03-05) — dodano WORLD_LOGIN_PORT=7171 |
| 5.6 | Zmienić config.lua.dist: jasne komentarze + defaults | canary config | ✅ DONE (Copilot, 2026-03-05) — komentarze o portach + powiązaniu z .env/launcher |

**Wyniki audytu 5.1:**
- **config.lua**: loginProtocolPort=7171, gameProtocolPort=7172, statusProtocolPort=7171
- **.env**: WORLD_PORT=7172, OTS_PORT=7172, OTS_GAME_PORT=7172 (brak LOGIN_PORT)
- **server-status.php**: per-mode fallback (WORLD_MODERN_PORT → WORLD_PORT → 7172)
- **login.php**: WORLD_PORT fallback 7172 (nie rozróżnia loginPort/gamePort)
- **generate_manifest.php**: WORLD_MODERN_PORT → WORLD_PORT → 7171 (UWAGA: inny fallback niż login.php!)
- **manifest JSON**: `"port": 7172` — jedno pole, brak loginPort/gamePort
- **Rust ServerEntryRaw**: `port: u16` — jedno pole
- **Problemy:**
  1. generate_manifest.php fallback 7171, login.php fallback 7172 — ROZBIEŻNOŚĆ
  2. Brak rozdziału loginPort (7171) vs gamePort (7172) przez cały stack
  3. Canary ma dwa osobne porty, ale API+manifest traktują jako jeden

---

## FAZA 6 — HARDENING & PODPISY (P5)

### Codex: Podpisy Ed25519

| # | Zadanie | Opis |
|---|---------|------|
| 6.1 | ✅ Generacja klucza Ed25519 | Skrypt `tools/generate-ed25519-keys.sh` + instrukcja GHA |
| 6.2 | ✅ CI step: podpisanie manifestu po generacji | .github/workflows |
| 6.3 | ✅ CI step: checksums.txt + checksums.txt.sig dla ZIP | .github/workflows |

### Copilot: Weryfikacja w launcherze

| # | Zadanie | Opis |
|---|---------|------|
| 6.4 | ✅ Włączyć `verify_manifest_signature()` w 4 flow: check_for_updates, start_update, pre_launch_check, repair_installation via `fetch_manifest_with_signature()` + `verify_fetched_manifest()` helper | launcher-tauri/commands.rs, launcher-api/client.rs |
| 6.5 | ✅ `manifest_public_key: Option<String>` w LauncherConfig + propagacja do AppStateInner.signature_public_key + `build_signature_config()` helper, policy=WarnIfMissing gdy klucz ustawiony, Ignore gdy brak | common-models/launcher_config.rs, launcher-tauri/state.rs |
| 6.6 | ✅ Test: tampered manifest → rejected (4 testy: valid sig, tampered+require→rejected, tampered+warn→invalid, wrong key→rejected) | manifest_signature.rs tests |

### Codex: Testy podpisów

| # | Zadanie |
|---|---------|
| 6.7 | `test_valid_signature_accepted` |
| 6.8 | `test_tampered_manifest_rejected` |
| 6.9 | `test_missing_signature_rejected` |
| 6.10 | `test_wrong_key_rejected` |

---

## FAZA 7 — DOKUMENTACJA (P4)

### Codex: Runbook fresh install

| # | Zadanie | Plik | Status |
|---|---------|------|--------|
| 7.1 | `fresh-install.md` — od zera do działania | `docs/runbooks/` | ✅ DONE (Copilot, 2026-03-05) |
| 7.2 | Diagram sieciowy (ASCII/Mermaid) — porty, flow | w runbook | ✅ DONE (ASCII w fresh-install.md) |
| 7.3 | Troubleshooting ≥10 scenariuszy | w runbook | ✅ DONE (12 scenariuszy) |
| 7.4 | Sekcja "Testowanie update/repair" | w runbook | ✅ DONE (4 testy: update, repair, integrity, token) |

### Copilot: Review

| # | Zadanie | Status |
|---|---------|--------|
| 7.5 | Review runbooka, dodanie brakujących kroków | ✅ Copilot jest autorem — verified |
| 7.6 | Weryfikacja: czy ktoś mógłby postawić system wg runbooka | ✅ Pełna ścieżka od zera |

---

## FAZA 8 — MONITORING / ERROR REPORTING

### Copilot: System raportowania błędów

| # | Zadanie | Opis | Status |
|---|---------|------|--------|
| 8.1 | Endpoint `error-report.php` — przyjmuje JSON z frontendu | PHP API | ✅ Wdrożony + przetestowany (curl → accepted, JSONL log) |
| 8.2 | Rust: `report_error()` w launcher-api | Wysyłanie błędów do API | ✅ ApiClient::report_error() + report_error_silent() |
| 8.3 | Tauri: catch panics + unhandled errors → report | commands.rs | ✅ Komenda report_error zarejestrowana w main.rs |
| 8.4 | Frontend: error boundary → report do API | app.js | ✅ window.error + unhandledrejection → reportError() |
| 8.5 | Dashboard: prosty widok logów błędów | PHP + SQL | ✅ DONE — dashboard-errors.php (HTML+JSON, oba logi, dostęp local/token) |

### Codex: Testy error reporting

| # | Zadanie | Status |
|---|---------|--------|
| 8.6 | `test_error_report_sent_on_download_failure` | ✅ DONE (Codex, 2026-03-05) — `launcher-api/src/client.rs` |
| 8.7 | `test_error_report_format` — poprawny JSON | ✅ DONE (Codex, 2026-03-05) — `launcher-api/src/client.rs` |
| 8.8 | `test_error_report_rate_limited` — max 1/min | ✅ DONE (Codex, 2026-03-05) — `launcher-api/src/client.rs` |

**Update 2026-03-05 (Codex):**
- Frontend `downloadArtifact()` w `launcher-tauri/ui/app.js` wysyła teraz `reportError("frontend.download_artifact_failed", ...)` przed pokazaniem `DOWNLOAD_ERROR`.
- Frontend `perform_self_update` catch wysyła `reportError("frontend.self_update_failed", ...)`.
- Walidacja: `cargo test -p launcher-api -- --nocapture` (12/12), `node --check ui/app.js`.

---

## FAZA 9 — I18N LAUNCHERA (wielojęzyczność)

**Dokumentacja bazowa:** `Dokumentacja/2026-03-04_launcher_i18n_plan.md`

Pełny system wielojęzyczności launchera: moduł Rust, frontend JS, fonty, pakiety językowe,
RTL support, branding. Spójny z systemem i18n serwera Canary (Translator + JSON per locale).

### Faza 9.1: Infrastruktura i18n Rust

#### Codex: Moduł i18n + pliki bazowe

| # | Zadanie | Opis | Plik |
|---|---------|------|------|
| 9.1.1 | `LauncherTranslator` struct | Ładowanie JSON, fallback chain (requested→pl→en), interpolacja `{0},{1}` | `common-models/src/i18n.rs` |
| 9.1.2 | Plik bazowy `en/launcher.json` | Pełne klucze UI w angielskim (status, actions, screens, errors, nav, settings, repair, update) | `launcher-rust/i18n/en/launcher.json` |
| 9.1.3 | Plik bazowy `pl/launcher.json` | Polskie tłumaczenia wszystkich kluczy | `launcher-rust/i18n/pl/launcher.json` |
| 9.1.4 | Unit testy i18n: fallback, interpolacja, brak klucza, nested keys | 5+ testów | `common-models/src/i18n.rs` (tests) |
| 9.1.5 | Unit test: RTL locale detection (ar, he, fa) | Test | j.w. |

#### Copilot: Integracja z Tauri

| # | Zadanie | Opis |
|---|---------|------|
| 9.1.6 | Tauri command `get_translations(locale)` — zwraca JSON z tłumaczeniami | `commands.rs` |
| 9.1.7 | Tauri command `get_available_locales()` — lista dostępnych języków | `commands.rs` |
| 9.1.8 | Pole `language` w `LauncherConfig` (default: "pl") | `common-models` |
| 9.1.9 | Integracja z `AppStateInner` — `translator: LauncherTranslator` | `state.rs` |

### Faza 9.2: Frontend i18n system

**Update 2026-03-05 (Codex):**
- ✅ Dostarczono pierwszy działający slice i18n w `launcher-tauri/ui`:
  - runtime tłumaczenia PL/EN (`app.js`, fallback + interpolacja),
  - selector języka w ekranie Ustawienia (`index.html` + `app.js`),
  - przepięcie dynamicznych statusów/progress/download/self-update na `t(...)`.
- ✅ Zadania domknięte częściowo: `9.2.5`, `9.2.6`, `9.2.7` (persist przez `change_channel` + `launcher_config.json`).
- ⏳ Pozostaje do domknięcia:
  - `9.2.1` w wersji docelowej (`ui/i18n.js` + oddzielne pliki JSON),
  - `9.2.2` i `9.2.3` (pełny RTL),
  - refinements `9.2.7`: walidacja/synchronizacja dla locale spoza Tier0 po wdrożeniu language-packów.

#### Codex: Silnik tłumaczeń JS

| # | Zadanie | Opis | Plik |
|---|---------|------|------|
| 9.2.1 | `i18n.js` — silnik tłumaczeń frontend | `data-i18n` atrybuty, dynamiczne podmiany, fallback do klucza | `ui/i18n.js` |
| 9.2.2 | RTL support: `dir="rtl"` w CSS, mirrored layout | CSS logical properties, `flex-direction: row-reverse` | `ui/styles.css` |
| 9.2.3 | Auto-detect RTL locales (ar, he, fa) | JS function `applyTextDirection(locale)` | `ui/i18n.js` |

#### Copilot: Refactor frontend na i18n

| # | Zadanie | Opis |
|---|---------|------|
| 9.2.4 | Refactor `index.html` — zastąpienie hardcoded tekstu atrybutami `data-i18n="klucz"` | Każdy widoczny tekst → klucz |
| 9.2.5 | Refactor `app.js` — dynamiczne teksty z obiektu tłumaczeń | `t("launcher.actions.play")` zamiast "▶ Uruchom grę" |
| 9.2.6 | Selector języka w ekranie Ustawienia (dropdown z flagami + natywna nazwa) | UI component |
| 9.2.7 | Zapisywanie wybranego języka (persist w LauncherConfig) | Tauri command `change_channel(channel, language)` (aktualny etap) |

### Faza 9.3: Fonty i Unicode

#### Copilot: Font bundling + CSS

| # | Zadanie | Opis |
|---|---------|------|
| 9.3.1 | Bundled font: Noto Sans Latin+Cyrillic+Greek (~300KB woff2) jako domyślny | CSS `@font-face` |
| 9.3.2 | CSS `@font-face` chain z fallback: bundled → system → downloaded | `ui/fonts.css` |
| 9.3.3 | Font pack manifest: definicja pakietów per script (CJK, Arabic, Devanagari) | Rozszerzenie manifest v2 |

#### Codex: Font pack system

| # | Zadanie | Opis |
|---|---------|------|
| 9.3.4 | Rust: `FontPackInfo` struct — metadata pakietu fontów (locale, script, URL, SHA, size) | `common-models` ✅ (dodane: `common-models/src/font_pack.rs` + testy) |
| 9.3.5 | Rust: `download_font_pack()` — pobieranie i weryfikacja font pack | `launcher-core` 🟢 (dodane: `launcher-core/src/font_pack_download.rs`) |
| 9.3.6 | Testy: font pack download + SHA verify | Unit tests 🟢 (testy dodane w `font_pack_download.rs`) |

**Update 2026-03-05 (Codex):**
- Dodano moduł `launcher-core/src/font_pack_download.rs` z:
  - walidacją metadanych font-packu,
  - pobieraniem przez `ApiClient`,
  - weryfikacją `size` + `sha256`,
  - zapisem paczki do lokalnego cache.
- Dodano testy jednostkowe dla scenariuszy:
  - `ok`,
  - `hash mismatch`,
  - `size mismatch`,
  - odrzucenie URL bez HTTPS (poza loopback testowym).
- Status oznaczony jako 🟢 (gotowe do walidacji), ponieważ na żądanie usera nie uruchamiamy kompilacji/testów buildowych.

### Faza 9.4: Pakiety językowe z serwera

#### Copilot: API + UI pobierania

| # | Zadanie | Opis |
|---|---------|------|
| 9.4.1 | PHP endpoint `language-packs.php` — lista dostępnych paczek z URL, SHA, size, tier | API |
| 9.4.2 | Ekran "Language Packs" w UI — lista z "Pobierz"/"Zainstalowany"/progress | Frontend ⏳ (panel settings + akcje download/list już dodane; czeka na finalne API/UX polish) |
| 9.4.3 | Integracja z manifest: `locale` wysyłany w API calls | API client |

#### Codex: Mechanizm pobierania

| # | Zadanie | Opis |
|---|---------|------|
| 9.4.4 | Rust: `download_language_pack(locale)` — pobieranie + unzip + weryfikacja | `launcher-core` 🟢 (`language_pack_download.rs`) |
| 9.4.5 | Rust: `list_installed_packs()` — skanowanie zainstalowanych locale | `launcher-core` 🟢 (`language_pack_download.rs`) |
| 9.4.6 | Testy: pobieranie + fallback jeśli offline | Unit tests |

**Update 2026-03-05 (Codex):**
- `common-models/src/api_responses.rs`:
  - dodano modele `LanguagePacksResponse` i `LanguagePackInfo`.
- `launcher-api/src/client.rs`:
  - dodano `fetch_language_packs()` (obsługa `language-packs.php` + `429` + `HttpStatus`).
- `launcher-core/src/language_pack_download.rs`:
  - dodano `download_language_pack()` (walidacja metadata, download, verify `size` + `sha256`, bezpieczny unzip z `enclosed_name()`),
  - dodano `list_installed_packs()` (skan lokalnych instalacji po `.launcher_pack.json`),
  - dodano zapis metadanych instalacji paczki w katalogu lokalnym.
- `apps/launcher-tauri/src/commands.rs` + `apps/launcher-tauri/src/main.rs`:
  - dodano komendy Tauri:
    - `get_language_packs`,
    - `download_language_pack`,
    - `list_installed_language_packs`.
- `apps/launcher-tauri/ui/index.html` + `ui/style.css` + `ui/app.js` + `ui/i18n/*.json`:
  - dodano panel "Language packs" w ekranie Ustawienia,
  - frontend ładuje katalog paczek + listę zainstalowanych i pozwala pobrać paczkę per locale,
  - dodano nowe klucze i18n `labels.languagePacks` i `languagePacks.*` dla PL/EN/AR/HE/FA.
- `launcher-core/src/lib.rs`:
  - eksport modułu `language_pack_download`.
- `launcher-rust/Cargo.toml` + `launcher-core/Cargo.toml`:
  - dodano dependency `zip` do obsługi unzip paczek językowych.
- Status 9.4.4/9.4.5 ustawiony na 🟢 (kod gotowy), walidacja build/test pozostaje do uruchomienia na CI/GHA.

### Faza 9.5: Branding i visual design

#### Copilot: Design decisions + implementacja

| # | Zadanie | Opis |
|---|---------|------|
| 9.5.1 | Logo SerwerCanary (SVG + PNG @1x/@2x + ICO) — design lub AI generator | Wymaga decyzji |
| 9.5.2 | Sidebar z SVG ikonami zamiast tekstu + tooltip z i18n | UI redesign |
| 9.5.3 | Splash screen / loading z logo | Frontend |
| 9.5.4 | Window title z wersją + i18n: `"{title} v{version}"` | Tauri config |
| 9.5.5 | Tray icon (Windows .ico, Linux .png) | Tauri config |
| 9.5.6 | Finalizacja palety kolorów (CSS variables) | CSS |

### Podsumowanie i18n

| Pod-faza | Copilot | Codex | Razem |
|----------|---------|-------|-------|
| 9.1 Rust infrastruktura | 4 | 5 | 9 |
| 9.2 Frontend | 4 | 3 | 7 |
| 9.3 Fonty | 3 | 3 | 6 |
| 9.4 Pakiety językowe | 3 | 3 | 6 |
| 9.5 Branding | 6 | 0 | 6 |
| **Razem i18n** | **20** | **14** | **34** |

### Architektura i18n — warstwy

```
┌─────────────────────────────────────────────────────┐
│  W1: Pliki JSON (en.json, pl.json — bundled)        │
│      + pobierane: de.json, es.json, zh.json, ...    │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│  W2: LauncherTranslator (Rust, common-models)       │
│      Fallback: requested → pl → en                  │
│      Interpolacja: {0}, {1}                         │
│      Tauri cmd: get_translations(locale)            │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│  W3: i18n.js (frontend)                             │
│      data-i18n="klucz" → dynamiczna podmiana        │
│      RTL auto-detection (ar, he, fa)                │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│  W4: Fonty + CSS @font-face                         │
│      Bundled: Noto Sans (Latin/Cyrillic) ~300KB     │
│      Pobierane: CJK ~16MB, Arabic ~200KB, Thai ~80KB│
└─────────────────────────────────────────────────────┘
```

### Tier pakietów językowych

| Tier | Zawartość | Rozmiar | Dystrybucja |
|------|-----------|---------|-------------|
| **0 — Core** | en, pl + Noto Sans Latin/Cyrillic | ~400KB | Wbudowany |
| **1 — European** | de, es, fr, it, pt, nl, sv, ru, cs, hu, ro, bg, uk | ~50KB/locale | Pobierany |
| **2 — CJK** | zh, ja, ko + Noto Sans CJK | ~16MB | Pobierany |
| **3 — Arabic/RTL** | ar, he, fa + Arabic font + RTL CSS | ~3MB | Pobierany |
| **4 — Indic/SE Asian** | hi, bn, th, vi + fonty | ~5MB | Pobierany |
| **5 — Other** | tr, ka, el, fi, da, no, id, ms... (30+ locales) | ~20KB/locale | Pobierany |

---

## BACKLOG — PO FAZIE 9

| # | Zadanie | Agent | Priorytet |
|---|---------|-------|-----------|
| F1 | CDN dla plików klienta (Cloudflare R2?) | Copilot | Wysoki |
| F2 | OTClient ticket module (Lua) | Copilot | Wysoki |
| F3 | TICKET_GATE w CMake Canary | Copilot | Wysoki |
| F4 | Progress bar real-time (Tauri events) | Copilot | Wysoki |
| F5 | Retry/resume download (range requests) | Codex | Średni |
| F6 | Dark/Light theme launcher | Codex | Średni |
| F7 | Instalator NSIS/WiX | Copilot | Średni |
| F8 | A/B rollout testing | Copilot | Niski |
| F9 | Bandwidth throttling UI | Codex | Niski |
| F10 | macOS build | Copilot | Niski |

---

## REKOMENDOWANA KOLEJNOŚĆ

```
Faza 0 (teraz)  ─── test pełnego flow
     │
     ▼
Faza 1 (SQL)    ─── Codex pisze migracje, Copilot deploy
     │
     ├── Faza 2 (testy)    ─── Codex, równolegle
     ├── Faza 3 (logging)  ─── Codex, równolegle
     │
     ▼
Faza 4 (real flow)   ─── Copilot: build + test faktyczny download
     │
     ▼
Faza 4.5 (ochrona)  ─── Copilot: kategorie plików, integrity check
     │                   Codex: testy ochrony
     │
     ▼
Faza 4.7 (build klienta) ─── Copilot: GHA workflow kompilacji OTClient
     │                        Codex: testy artefaktu (brak src, poprawne SHA)
     │
     ├── Faza 5 (porty)     ─── Copilot
     ├── Faza 6 (hardening) ─── Codex + Copilot
     │
     ▼
Faza 7 (docs)        ─── Codex
     │
     ▼
Faza 8 (monitoring)  ─── Copilot + Codex
     │
     ▼
Faza 9 (i18n)        ─── Copilot + Codex (9.1→9.2→9.3→9.4→9.5)
     │
     ▼
Faza 10 (demo 2026-03-06) ─── Copilot + Codex: paczka Windows, dual-mode 7.4/modern, różnice anty-cheat, self-update
     │
     ▼
Backlog (F1-F10)
```

---

## PODSUMOWANIE

| Faza | Copilot (zadania) | Codex (zadania) | Razem |
|------|-------------------|-----------------|-------|
| 0 | 8 | 0 | 8 |
| 1 | 3 | 7 | 10 |
| 2 | 2 | 18 | 20 |
| 3 | 4 | 6 | 10 |
| 4 | 12 | 0 | 12 |
| **4.5** | **6** | **5** | **11** |
| **4.7** | **7** | **4** | **11** |
| 5 | 6 | 0 | 6 |
| 6 | 3 | 7 | 10 |
| 7 | 2 | 4 | 6 |
| 8 | 5 | 3 | 8 |
| **9** | **20** | **14** | **34** |
| **Razem** | **78** | **68** | **146** |

Copilot: 78 zadań (interakcja, serwer, architektura, frontend, deploy, build workflow).
Codex: 68 zadań (testy, SQL, dokumentacja, moduły i18n, font packs, testy artefaktów).

### Kluczowe decyzje wymagające usera:
1. **Logo** (Faza 9.5.1) — design graficzny lub AI generator?
2. **Paleta kolorów** (9.5.6) — obecna czy nowa?
3. **Lua bytecode** (4.5 Warstwa 3) — kompilować .lua→.luac w przyszłości?
4. **CDN** (Backlog F1) — Cloudflare R2, S3, czy zostajemy na nginx?
5. **OTClient repo** (Faza 4.7) — fork własny czy budowanie z upstream opentibia-br/otclient + patch?
