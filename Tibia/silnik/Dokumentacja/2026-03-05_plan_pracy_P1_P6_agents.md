# PLAN PRACY — Podział na agentów + specyfikacja P1–P6

**Data:** 2026-03-05  
**Gałąź:** `feature/ticket-gate`  
**Git root:** `/home/ptaku/serweryt/`

---

## SPIS TREŚCI

1. [Podział agentów — kto co robi](#1-podział-agentów)
2. [P1 — SQL rollout + rollback](#p1)
3. [P2 — Testy replay/expired/clock-skew](#p2)
4. [P3 — Structured logging odrzuceń](#p3)
5. [P4 — Runbook fresh install](#p4)
6. [P5 — Hardening packaging](#p5)
7. [P6 — Rozdzielenie apiPort/gamePort](#p6)
8. [Backlog — przyszłe zadania](#backlog)

---

## 1. PODZIAŁ AGENTÓW

### Agent A — „Backend & DB" (P1 + P3)
**Zakres:** SQL, PHP API, serwer Canary C++, bazy danych

**Zadania:**
- [P1] Migracje SQL: rollout + rollback skrypty, cleanup events
- [P3] Structured logging w PHP (ticket.php, launcher-token.php)
- Cleanup cron (wygasłe nonce/tokeny/sesje)
- Rate limiting w nginx

**Pliki do edycji:**
- `/var/www/html/apik/v1/schema_ticket_gate.sql` → rollout
- `/var/www/html/apik/v1/schema_launcher.sql` → rollout
- Nowe: `migrations/001_rollout.sql`, `migrations/001_rollback.sql`
- `/var/www/html/apik/v1/ticket.php` → structured logging
- `/var/www/html/apik/v1/launcher-token.php` → structured logging
- `/var/www/html/apik/v1/common.php` → logger helper

**NIE DOTYKAJ:**
- Plików Rust (`launcher-rust/`)
- Plików frontend (`ui/`)
- Workflow YAML (`.github/`)

---

### Agent B — „Testy & Bezpieczeństwo" (P2 + P5)
**Zakres:** Testy Rust, hardening, kryptografia

**Zadania:**
- [P2] Testy ticketów w Rust: replay, expired, clock-skew, edge cases
- [P5] Checksum/podpisy artefaktów: Ed25519 manifest signature, artefact signing policy
- Testy integracyjne launcher-api ↔ mock API

**Pliki do edycji:**
- `launcher-rust/tests/` → nowe pliki testowe
- `launcher-rust/crates/launcher-core/src/challenge.rs` → testy
- `launcher-rust/crates/launcher-core/src/hmac_rotation.rs` → testy
- `launcher-rust/crates/launcher-core/src/manifest_signature.rs` → testy
- `launcher-rust/docs/contracts/artifact-signing-policy.md` → uzupełnienie

**NIE DOTYKAJ:**
- Plików PHP
- Frontend UI
- state.rs / commands.rs (chyba że dodajesz testy)

---

### Agent C — „Dokumentacja & Runbook" (P4 + P6)
**Zakres:** Dokumentacja, konfiguracja, port separation

**Zadania:**
- [P4] Runbook fresh install: krok po kroku od zera (API + Canary + launcher + DNS + SSL)
- [P6] Rozdzielenie apiPort/gamePort: analiza gdzie jest hardcoded, plan zmian
- Update istniejących docs
- AGENT_COMMUNICATION.md → aktualizacja statusu

**Pliki do edycji:**
- `Dokumentacja/` → nowe .md pliki
- `launcher-rust/docs/runbooks/` → nowe runbooki
- `launcher-rust/docs/contracts/` → przegląd i uzupełnienie
- Analiza (read-only): `canary/src/`, `canary_test/config.lua`, PHP API

**NIE DOTYKAJ:**
- Kodu źródłowego (Rust, PHP, C++)
- Workflow YAML

---

### Agent główny (Copilot) — koordynacja
**Zakres:** Review, merge conflictów, push, decyzje architektoniczne

---

## ZASADY WSPÓŁPRACY AGENTÓW

1. **Żaden agent nie pushuje samodzielnie** — tylko Agent główny (Copilot) commituje i pushuje
2. **Każdy agent pracuje na swoich plikach** — listy plików powyżej są rozdzielne
3. **Komunikacja przez** `/home/ptaku/serweryt/Dokumentacja/AGENT_COMMUNICATION.md`
4. **Kompilacja TYLKO na GHA** — nigdy lokalnie (`cargo build`, `npm`, etc.)
5. **Testy mogą być pisane bez uruchamiania** — weryfikacja przez CI push

---

## CEL KOŃCOWY NA 2026-03-06 (JUTRO)

Cel wspólny dla Copilot + Codex:
1. Uruchomić launcher z docelowej paczki Windows pobranej do testów graczy (ta paczka = źródło prawdy).
2. Odpalić równolegle klienta dla trybu 7.4 i modern.
3. Pokazać różnicę polityk bezpieczeństwa: blokady hotkeys/runy w 7.4 oraz brak tej blokady w modern.
4. Potwierdzić, że poprawki klienta i launchera są dostarczane kanałem update/self-update (bez ręcznej reinstalki).

### Kryteria akceptacji (D1..D5)

| ID | Kryterium | Status |
|----|-----------|--------|
| D1 | Testy akceptacyjne wykonane na tej samej paczce Windows co u usera | ⏳ |
| D2 | Jednoczesne logowanie na 7.4 i modern działa z launchera | ⏳ |
| D3 | Różnice anti-cheat między trybami są widoczne i powtarzalne | ⏳ |
| D4 | Naruszenie pliku krytycznego blokuje start i przechodzi przez repair | ⏳ |
| D5 | Self-update launchera dostarcza nową poprawkę do klienta końcowego | ⏳ |

### Zadania do domknięcia celu

| # | Zadanie | Właściciel | Status |
|---|---------|------------|--------|
| J1 | Spisać checklistę testową dual-mode (7.4 + modern) z expected result (`2026-03-05_dual_mode_test_checklista_J1.md`) | Codex | ✅ |
| J2 | Domknąć mapę blokad hotkeys/runy dla 7.4 i wyjątki dla modern | Copilot | ⏳ |
| J3 | Zweryfikować ścieżkę self-update jako standard dystrybucji poprawek launchera | Copilot | ⏳ |
| J4 | Rejestrować każdy bug UI/instalki w dokumentacji roboczej z ownerem i statusem | Copilot + Codex | ⏳ |

---

## P1 — SQL ROLLOUT + ROLLBACK {#p1}

### Cel
Automatyczne migracje SQL z numerowanymi wersjami i możliwością rollback.

### Status realizacji (2026-03-05 15:42)
- ✅ Utworzono katalog `canary_test/html_copy/apik/v1/migrations/` i komplet plików:
  - `001_ticket_gate_rollout.sql` / `001_ticket_gate_rollback.sql`
  - `002_launcher_tables_rollout.sql` / `002_launcher_tables_rollback.sql`
  - `003_cleanup_events_rollout.sql` / `003_cleanup_events_rollback.sql`
  - `migrate.php` (CLI runner: `status`, `rollout`, `rollback <target>`)
- ✅ Walidacja techniczna: `php -l migrate.php` oraz `php migrate.php status`.
- ⏳ Oczekuje: uruchomienie `rollout` na docelowej DB + potwierdzenie `SHOW EVENTS`.

### Problemy wykryte przez Codex (do wspólnego domknięcia)
1. `event_scheduler` może wymagać uprawnień DBA do `SET GLOBAL event_scheduler = ON`.
2. W repo są równoległe źródła schemy (`schema_*.sql` i `sql/ticket_gate_migration.sql`) — trzeba wskazać canonical path wdrożenia.
3. Należy utrzymać zgodność `manifest_versions` z `generate_manifest.php` (`file_count`, `total_size`).

### Co trzeba zrobić

#### 1.1 Struktura migracji
```
/var/www/html/apik/v1/migrations/
├── 001_ticket_gate_rollout.sql      # CREATE TABLE ticket_nonces, ticket_sessions
├── 001_ticket_gate_rollback.sql     # DROP TABLE ticket_sessions, ticket_nonces
├── 002_launcher_tables_rollout.sql  # CREATE TABLE launch_tokens, manifest_versions
├── 002_launcher_tables_rollback.sql # DROP TABLE manifest_versions, launch_tokens
├── 003_cleanup_events_rollout.sql   # EVENT scheduler: usuwanie wygasłych rekordów
├── 003_cleanup_events_rollback.sql  # DROP EVENT
└── migrate.php                      # Runner migracji (CLI)
```

#### 1.2 Rollout SQL: `001_ticket_gate_rollout.sql`
```sql
-- Migration 001: ticket-gate tables
-- Wymagane przez: ticket.php, login.php

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `ticket_nonces` (
    `nonce`      VARCHAR(64) NOT NULL,
    `account_id` INT NOT NULL DEFAULT 0,
    `expires_at` INT UNSIGNED NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`nonce`),
    INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ticket_sessions` (
    `session_key`    VARCHAR(128) NOT NULL,
    `account_id`     INT NOT NULL,
    `game_mode`      VARCHAR(32) NOT NULL DEFAULT 'modern',
    `created_at`     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at`     INT UNSIGNED NOT NULL,
    PRIMARY KEY (`session_key`),
    INDEX `idx_account` (`account_id`),
    INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela migracji (metadata)
CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

INSERT INTO `_migrations` (`id`, `name`) VALUES (1, '001_ticket_gate');

COMMIT;
```

#### 1.3 Rollback SQL: `001_ticket_gate_rollback.sql`
```sql
START TRANSACTION;
DROP TABLE IF EXISTS `ticket_sessions`;
DROP TABLE IF EXISTS `ticket_nonces`;
DELETE FROM `_migrations` WHERE `id` = 1;
COMMIT;
```

#### 1.4 Cleanup events: `003_cleanup_events_rollout.sql`
```sql
-- Automatyczne czyszczenie wygasłych rekordów (co 15 minut)

SET GLOBAL event_scheduler = ON;

CREATE EVENT IF NOT EXISTS `cleanup_expired_nonces`
ON SCHEDULE EVERY 15 MINUTE
DO DELETE FROM `ticket_nonces` WHERE `expires_at` < UNIX_TIMESTAMP();

CREATE EVENT IF NOT EXISTS `cleanup_expired_tokens`
ON SCHEDULE EVERY 15 MINUTE
DO DELETE FROM `launch_tokens` WHERE `expires_at` < NOW();

CREATE EVENT IF NOT EXISTS `cleanup_expired_sessions`
ON SCHEDULE EVERY 15 MINUTE
DO DELETE FROM `ticket_sessions` WHERE `expires_at` < UNIX_TIMESTAMP();

INSERT INTO `_migrations` (`id`, `name`) VALUES (3, '003_cleanup_events');
```

#### 1.5 migrate.php (CLI runner)
```
php migrate.php rollout    # Uruchom wszystkie niezastosowane migracje
php migrate.php rollback 2 # Cofnij do migracji 2 (usuń 3)
php migrate.php status     # Pokaż zastosowane migracje
```

### Kryteria akceptacji P1
- [x] Tabele tworzone idempotentnie (IF NOT EXISTS)
- [x] Rollback każdej migracji odwraca rollout
- [x] `_migrations` tabela śledzi stan
- [ ] Cleanup events działają (test: `SHOW EVENTS`)
- [x] migrate.php działa z CLI

---

## P2 — TESTY REPLAY/EXPIRED/CLOCK-SKEW {#p2}

### Cel
Sprawdzenie że system ticketów poprawnie odrzuca:
- Ponownie użyte nonce (replay attack)
- Ticket z przeszłości (expired)
- Ticket z przyszłości (clock skew)

### Co trzeba zrobić

#### 2.1 Nowe testy w Rust (`launcher-rust/tests/ticket_security_tests.rs`)

```rust
// Test 1: Replay protection — ten sam nonce użyty drugi raz
#[test]
fn test_ticket_replay_rejected() { ... }

// Test 2: Expired ticket (expires_at w przeszłości)
#[test]
fn test_expired_ticket_rejected() { ... }

// Test 3: Clock skew — ticket z przyszłości (expires_at > now + max_skew)
#[test]
fn test_future_ticket_clock_skew() { ... }

// Test 4: Tampered HMAC — zmieniony payload bez aktualizacji HMAC
#[test]
fn test_tampered_hmac_rejected() { ... }

// Test 5: Empty nonce
#[test]
fn test_empty_nonce_rejected() { ... }

// Test 6: Oversized payload (>4KB)
#[test]
fn test_oversized_payload_rejected() { ... }

// Test 7: Valid ticket — happy path
#[test]
fn test_valid_ticket_accepted() { ... }

// Test 8: Multiple game modes (modern, classic74)
#[test]
fn test_game_mode_variants() { ... }

// Test 9: Grace period (5s window after expiry)
#[test]
fn test_grace_period_within() { ... }

// Test 10: Grace period exceeded
#[test]
fn test_grace_period_exceeded() { ... }
```

#### 2.2 Testy PHP (opcjonalnie: `tests/ticket_api_test.php`)

```php
// Test: POST /ticket.php z wygasłą sesją → 401
// Test: POST /ticket.php z poprawną sesją → 200 + valid HMAC
// Test: POST /ticket.php bez session_key → 400
// Test: Nonce unikalność (2x ten sam → 409)
```

#### 2.3 Testy challenge-response (`launcher-core/src/challenge.rs`)

Istniejące testy + dodać:
- `test_challenge_with_rotated_key` — stary kid, nowy kid
- `test_challenge_response_timing` — max 30s na odpowiedź
- `test_challenge_with_empty_nonce` — edge case

### Kryteria akceptacji P2
- [ ] 10+ nowych testów Rust (ticket security)
- [ ] Replay, expired, clock-skew, tampered HMAC — all fail
- [ ] Valid ticket — pass
- [ ] Grace period edge case — 5s OK, 6s fail
- [ ] `cargo test` zielone (sprawdzone na CI)

### Status realizacji (2026-03-05 15:55)
- ✅ `launcher-api/src/client.rs`:
  - dodano walidację challenge (`nonce` non-empty + min 32 + hex, `TTL <= 30s`)
  - dodano testy:
    - `test_validate_challenge_response_ok`
    - `test_validate_challenge_response_empty_nonce`
    - `test_validate_challenge_response_nonce_not_hex`
    - `test_validate_challenge_response_nonce_too_short`
    - `test_validate_challenge_response_ttl_zero`
    - `test_validate_challenge_response_ttl_too_high`
- ✅ `launcher-core/src/planner.rs`:
  - `test_resolve_file_url_absolute_v2_unchanged`
  - `test_plan_missing_base_url_error_when_entry_url_empty`
- ✅ `common-models/src/manifest.rs`:
  - `test_parse_v2_servers_field`

### Problemy wykryte przez Codex (do wspólnego domknięcia)
1. Nowa walidacja launchera odrzuca challenge z `expiresInSeconds > 30`; wymaga potwierdzenia kontraktu `challenge.php` po stronie API.
2. Część punktów P2 z sekcji 2.1 (strict replay/expired/clock-skew ticketów) dotyczy logiki serwerowej PHP/DB, więc wymaga osobnej warstwy testowej poza aktualnym zakresem testów launcherowych.

### Status realizacji (2026-03-05 16:03)
- ✅ `launcher-core/src/hmac_rotation.rs`:
  - dodano `test_challenge_with_rotated_key` (stary+nowy `kid` + fallback bez `kid`)
- ✅ `P2` challenge/planner/manifest coverage rozszerzone i zsynchronizowane z taskboardem 2-agentowym.
- ⏳ otwarte: testy stricte ticket replay/expired/clock-skew dla ścieżki serwerowej (PHP/DB + Canary).

---

## P3 — STRUCTURED LOGGING ODRZUCEŃ {#p3}

### Cel
JSON-formatted logi dla każdego odrzuconego ticketu/tokenu, gotowe na Grafana/Loki/ELK.

### Status realizacji (2026-03-05 15:48)
- ✅ Dodano logger helpery w `common.php`:
  - `hashClientIp()`
  - `logTicketEvent()`
- ✅ Zalogowane eventy w:
  - `ticket.php` (`ticket.issued`, `ticket.rejected.*`)
  - `launcher-token.php` (`launcher_token.issued`, `launcher_token.rejected.*`)
- ✅ Dodano template logrotate:
  - `canary_test/html_copy/apik/v1/logrotate/serwercanary`
- ℹ️ Status historyczny (15:48):
  - brak plików `challenge.php` i `server-status.php` w ówczesnym drzewie `apik/v1` (rozwiązane w update 16:03).

### Status realizacji (2026-03-05 16:03)
- ✅ Dodano brakujące endpointy:
  - `canary_test/html_copy/apik/v1/challenge.php`
  - `canary_test/html_copy/apik/v1/server-status.php`
- ✅ Endpointy logują zdarzenia:
  - `challenge.issued` / `challenge.rejected.*`
  - `server_status.checked` / `server_status.rejected.*`
- ✅ `launcher-token.php` rozszerzony o opcjonalną/wymaganą walidację challenge-response:
  - `nonce` + `challengeResponse`
  - one-time nonce consume (`ticket_nonces.account_id=0`)
  - nowe eventy `launcher_token.rejected.challenge_*` i `launcher_token.challenge_validated`
- ✅ `.env.example` uzupełnione o:
  - `CHALLENGE_TTL`, `CHALLENGE_REQUIRED`, `SERVER_STATUS_TIMEOUT_MS`, `SECURITY_LOG_FILE`, `LOG_IP_SALT`

### Co trzeba zrobić

#### 3.1 Logger w PHP (`common.php`)

```php
function logTicketEvent(string $event, array $data): void {
    $entry = json_encode([
        'ts' => gmdate('Y-m-d\TH:i:s\Z'),
        'event' => $event,
        'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
        'ua' => substr($_SERVER['HTTP_USER_AGENT'] ?? '', 0, 200),
    ] + $data, JSON_UNESCAPED_UNICODE);

    error_log($entry . "\n", 3, '/var/log/serwercanary/ticket-gate.jsonl');
}
```

#### 3.2 Eventy do logowania

| Event | Gdzie | Dane |
|-------|-------|------|
| `token.issued` | launcher-token.php | launcher_version, channel, files_hash |
| `token.rejected.hash_mismatch` | launcher-token.php | expected_hash, actual_hash |
| `token.rejected.version_old` | launcher-token.php | min_version, actual_version |
| `ticket.issued` | ticket.php | account_id, game_mode, nonce |
| `ticket.rejected.session_expired` | ticket.php | session_key |
| `ticket.rejected.session_invalid` | ticket.php | session_key |
| `ticket.rejected.rate_limit` | ticket.php | account_id, attempts |
| `challenge.issued` | challenge.php | — |
| `server_status.checked` | server-status.php | servers_online_count |

#### 3.3 Log rotation (logrotate)

```
# /etc/logrotate.d/serwercanary
/var/log/serwercanary/*.jsonl {
    daily
    rotate 30
    compress
    missingok
    notifempty
    create 0644 www-data www-data
}
```

#### 3.4 Katalog logów
```bash
sudo mkdir -p /var/log/serwercanary
sudo chown www-data:www-data /var/log/serwercanary
```

### Kryteria akceptacji P3
- [ ] Każdy endpoint loguje zdarzenia w formacie JSON Lines
  Status: ✅ endpointy `ticket.php`, `launcher-token.php`, `challenge.php`, `server-status.php` logują zdarzenia.
- [ ] Logi w `/var/log/serwercanary/ticket-gate.jsonl`
  Status: domyślna ścieżka ustawiona na `/var/log/serwercanary/security-events.log` (wymaga deploy katalogu/praw).
- [x] Logrotate skonfigurowany
  Status: template gotowy w repo (`apik/v1/logrotate/serwercanary`), do wdrożenia przez Copilot na hosta.
- [ ] Brak wrażliwych danych w logach (NIE: hasła, tokeny, session_key)
- [ ] IP + User-Agent + timestamp w każdym wpisie

---

## P4 — RUNBOOK FRESH INSTALL {#p4}

### Cel
Krok-po-krok instalacja całego systemu od zera na czystym Ubuntu 22.04/24.04.

### Struktura runbooka

```
launcher-rust/docs/runbooks/fresh-install.md

## Wymagania
  - Ubuntu 22.04+ / Windows Server
  - MySQL 8.0+
  - nginx 1.18+
  - PHP 8.1+ (php-fpm, php-mysql, php-json)
  - Domena (np. serwercanary.pl) + SSL cert

## Krok 1: Baza danych
  - mysql -u root -p < schema_ticket_gate.sql
  - mysql -u root -p < schema_launcher.sql
  - php migrate.php rollout

## Krok 2: PHP API
  - cp -r apik/v1/ /var/www/html/apik/v1/
  - cp .env.example .env → edytuj HMAC_SECRET, DB_*
  - chmod 640 .env
  - chown www-data:www-data .env

## Krok 3: nginx
  - Konfiguracja HTTPS z certbot
  - Proxy pass do PHP-FPM
  - Rate limiting

## Krok 4: Serwer Canary
  - Kompilacja z -DTICKET_GATE=ON
  - Konfiguracja config.lua: loginProtocolPort, gameProtocolPort
  - HMAC_SECRET env var (ten sam co w .env PHP!)

## Krok 5: Manifest klienta
  - Zbuduj OTClient (GHA)
  - Wgraj pliki na serwer
  - php generate_manifest.php > manifests/stable.json

## Krok 6: Launcher
  - Pobierz artefakty z GHA
  - Stwórz launcher_config.json z apiBaseUrl
  - Rozpakuj obok client/
  - Uruchom launcher → powinien pobrać klienta

## Krok 7: Weryfikacja
  - curl https://api.serwercanary.pl/apik/v1/launcher-version.php
  - curl https://api.serwercanary.pl/apik/v1/server-status.php
  - Uruchom launcher → Graj → powinien się zalogować

## Troubleshooting
  - ERR_CONNECTION_REFUSED → sprawdź nginx
  - LCH_TOKEN_INVALID → sprawdź HMAC_SECRET
  - 502 Bad Gateway → sprawdź php-fpm
```

### Rozdzielenie apiPort/gamePort (P6 — powiązane)

#### Analiza — gdzie portowe konfiguracje:

| Plik | Co | Obecny stan |
|------|-----|------------|
| `canary/config.lua.dist` | `loginProtocolPort = 7171` | Jeden port na login+game |
| `canary_test/config.lua` | `loginProtocolPort = 7171`, `gameProtocolPort = 7172` | Rozdzielone |
| `.env` PHP | `WORLD_PORT=7172` `OTS_GAME_PORT=7172` | Tylko game port |
| `server-status.php` | TCP connect do port 7172 | Hardcoded |
| `launcher_config.json` | Brak portów | Nie obsługuje |
| Manifest `servers[]` | `port: 7171` | Login port |

#### Co trzeba rozdzielić:
1. **API port** (launcher-version, update, token) — to HTTP/HTTPS, nie tibia port
2. **Login port** (7171) — tibia protokół logowania
3. **Game port** (7172) — tibia protokół gry
4. **Status check port** — w server-status.php: TCP connect

Obecnie confusion:
- "apiPort" w kontekście Canary = login port (7171)
- "apiPort" w kontekście launchera = HTTP API (443/HTTPS)
- "gamePort" = tibia game protocol (7172)

#### Plan rozdzielenia:
1. W `server-status.php`: osobne check dla login port i game port
2. W `ServerStatusResponse` (Rust): dodaj `login_port` + `game_port` jako oddzielne pola
3. W `manifest.servers[]`: dodaj `login_port` i `game_port`
4. W `config.lua.dist`: jasna dokumentacja portów
5. W `.env`: `LOGIN_PORT=7171`, `GAME_PORT=7172`, `API_BASE_URL=https://...`

### Kryteria akceptacji P4
- [ ] Runbook od zera do działającego systemu
- [ ] Każdy krok testowalny (curl/wget)
- [ ] Troubleshooting sekcja ≥10 scenariuszy
- [ ] Diagram sieciowy (porty, kierunki, firewalle)

### Kryteria akceptacji P6
- [ ] Jasna terminologia: loginPort, gamePort, apiBaseUrl
- [ ] server-status.php sprawdza oba porty
- [ ] Manifest v2 servers[] z login_port + game_port
- [ ] config.lua.dist z komentarzami

---

## P5 — HARDENING PACKAGING {#p5}

### Cel
Artefakty launchera (ZIP) z checksumami SHA-256 i opcjonalnie podpisem Ed25519.

### Co trzeba zrobić

#### 5.1 Istniejące elementy (już zaimplementowane)

| Element | Plik | Status |
|---------|------|--------|
| SHA-256 per-file w manifest | `manifest.rs` | ✅ Gotowe |
| `filesHash` obliczany po update | `integrity.rs` | ✅ Gotowe |
| `artifact_verify.rs` | SHA-256 + size check | ✅ Gotowe |
| `manifest_signature.rs` | Ed25519 verify | ✅ Gotowe (kod) |
| `challenge.rs` | HMAC challenge-response | ✅ Gotowe |
| `hmac_rotation.rs` | Key ID rotation | ✅ Gotowe |
| CI checksums job | `build-launcher.yml` | ✅ SHA-256 sum |

#### 5.2 Brakujące elementy

| Element | Opis | Wysiłek |
|---------|------|---------|
| Ed25519 klucz prywatny (serwer) | Generacja klucza, przechowywanie w GitHub Secrets | 2h |
| Podpisywanie manifestu w CI | Po `generate_manifest.php` → Ed25519 sign | 3h |
| Weryfikacja podpisu w launcherze | `manifest_signature::verify()` wciągnięte do `check_for_updates` | 2h |
| Podpisywanie artefaktów ZIP | CI job: sign each .zip z Ed25519 | 3h |
| Weryfikacja ZIP w launcher self-update | `perform_self_update` → verify signature | 2h |
| Konfiguracja public key | Embedded w launcher binary lub `launcher_config.json` | 1h |

#### 5.3 Schemat podpisów

```
[CI Build]
    │
    ├── cargo build → launcher.zip
    ├── sha256sum launcher.zip → checksums.txt
    └── ed25519_sign(checksums.txt, PRIVATE_KEY) → checksums.txt.sig
    
[Manifest Generation]
    │
    ├── php generate_manifest.php → manifest.json
    └── ed25519_sign(manifest.json, PRIVATE_KEY) → manifest.json.sig

[Launcher weryfikuje]
    │
    ├── fetch manifest.json + manifest.json.sig
    ├── ed25519_verify(manifest.json, sig, PUBLIC_KEY) → OK/FAIL
    └── Jeśli FAIL → "Manifest signature invalid" → abort update
```

### Kryteria akceptacji P5
- [ ] Ed25519 key pair wygenerowany
- [ ] Public key embedded w launcherze
- [ ] Manifest podpisywany w pipeline
- [ ] Launcher weryfikuje podpis przed aktualizacją
- [ ] Artefakty ZIP z checksumami SHA-256
- [ ] Testy: tampered manifest → rejected

---

## BACKLOG — PRZYSZŁE ZADANIA {#backlog}

### Priorytet Wysoki (po P1-P6)

| # | Zadanie | Komponent | Agent |
|---|---------|-----------|-------|
| F1 | Prawdziwy manifest z OTClient build | API + CI | Copilot |
| F2 | CDN dla plików klienta | infra | Copilot |
| F3 | OTClient ticket module (Lua) | OTClient | Copilot |
| F4 | TICKET_GATE w CMake Canary | Canary C++ | Agent B |
| F5 | Progress bar real-time (Tauri events) | Launcher | Copilot |
| F6 | Retry/resume download | Launcher core | Agent B |
| F7 | Instalator NSIS/WiX | Packaging | Agent C |

### Priorytet Średni

| # | Zadanie | Komponent |
|---|---------|-----------|
| F8 | i18n w launcherze (5 faz, ~50h) | Launcher + API |
| F9 | Dual server mode (7.4 retro) | Canary + OTClient |
| F10 | Dark/Light theme | Launcher UI |
| F11 | Telemetry dashboard | Landing page |
| F12 | A/B rollout testing | Launcher core |

### Priorytet Niski

| # | Zadanie | Komponent |
|---|---------|-----------|
| F13 | Android launcher (Kotlin/Flutter) | Osobny projekt |
| F14 | macOS build | CI |
| F15 | Auto-updater bez helpera (swap-in-place) | Launcher |
| F16 | Bandwidth throttling UI | Launcher settings |

---

## REKOMENDACJA — CO ROBIĆ TERAZ

### Optymalny plan dla 3+1 agentów:

| Agent | Zadanie | Pliki | Czas |
|-------|---------|-------|------|
| **Agent A** | P1 (SQL) + P3 (logging) | PHP, SQL, nginx | ~4h |
| **Agent B** | P2 (testy) + P5 (hardening) | Rust tests, docs | ~5h |
| **Agent C** | P4 (runbook) + P6 (porty) | Docs, analiza | ~3h |
| **Copilot** | Review, push, koordynacja | Wszystko | ciągłe |

### Kolejność:
1. **Najpierw P1** — bez tabel w DB nic nie działa
2. **Równolegle P2 + P3** — niezależne od siebie
3. **P4 + P6** — dokumentacja i analiza, nie blokują kodu
4. **Na końcu P5** — wymaga key generation + CI changes

### Gotowość do merge:
Po ukończeniu P1-P6 → merge `feature/ticket-gate` → `master` (squash merge rekomendowany ze względu na 702 commity).
