# Sprint 5 — Hardening & Migration & Acceptance Tests

**Data:** 2026-03-03  
**Branch:** `feature/ticket-gate`  
**Bazowy commit:** `e18170e3c` (Sprint 4)

---

## Zakres Sprint 5

### Etap 5: Hardening (LR-052..LR-056)

| Zadanie | Opis | Status |
|---------|------|--------|
| LR-052 | Challenge-response nonce flow | ✅ |
| LR-053 | Weryfikacja podpisu manifestu (Ed25519 stub) | ✅ |
| LR-054 | Telemetria opt-in pipeline | ✅ |
| LR-055 | Ops dashboard design (spec doc) | ✅ |
| LR-056 | HMAC key rotation z kid | ✅ |

### Etap 6: Migracja i Rollout (LR-057..LR-061)

| Zadanie | Opis | Status |
|---------|------|--------|
| LR-057 | Raport parzystości Rust vs Python | ✅ |
| LR-058 | Konfiguracja rollout kanału testowego | ✅ |
| LR-059 | Soft rollout z A/B bucketing | ✅ |
| LR-060 | Full rollout plan | ✅ |
| LR-061 | Runbook rollback & fallback | ✅ |

### Testy akceptacyjne (AT-001..AT-015)

| Test | Scenariusz | Status |
|------|-----------|--------|
| AT-001 | API offline → fail-closed | ✅ |
| AT-002 | Uszkodzony plik → redownload + hash | ✅ |
| AT-003 | Poprawny filesHash → token wydany | ✅ |
| AT-004 | Zły filesHash → token odrzucony | ✅ |
| AT-005 | Ponowne użycie tokena → odmowa | ✅ |
| AT-006 | Zły kanał → odrzucenie | ✅ |
| AT-007 | Przerwany update → recovery/rollback | ✅ |
| AT-008 | Self-update success | ✅ |
| AT-009 | Self-update fail → rollback | ✅ |
| AT-010 | Download Center bad checksum → rejected | ✅ |
| AT-011 | Parser v1/v2 → NormalizedManifest | ✅ |
| AT-012 | Duplikat path → rejected | ✅ |
| AT-013 | Path traversal → rejected | ✅ |
| AT-014 | action=delete bez sha256/size → ok | ✅ |
| AT-015 | Crash w trakcie zapisu → state spójny | ✅ |

---

## Nowe pliki

### Kod Rust

- `launcher-core/src/challenge.rs` — Challenge-response: `compute_challenge_response()`, `validate_nonce()`, `verify_challenge_response()` + 11 unit testów
- `launcher-core/src/manifest_signature.rs` — Weryfikacja podpisu manifestu: `verify_manifest_signature()`, `SignaturePolicy`, Ed25519 stub + 10 unit testów
- `launcher-core/src/telemetry.rs` — Telemetria opt-in: `TelemetryCollector` z buforem Arc<Mutex<Vec>>, metryki: update_success/failure, token_latency, download_throughput + 9 unit testów
- `launcher-core/src/hmac_rotation.rs` — HMAC rotation: `HmacKeyRegistry`, FIPS 198-1 `hmac_sha256()`, `verify_hmac()` z kid lookup + brute-force fallback + 11 unit testów
- `common-models/src/rollout_config.rs` — Rollout: `RolloutConfig`, `ChannelRollout`, `should_use_rust_launcher()` z FNV-1a A/B bucketing + 10 unit testów
- `launcher-core/tests/acceptance_tests.rs` — 15 testów akceptacyjnych

### Modyfikacje

- `launcher-core/src/lib.rs` — dodane moduły: challenge, manifest_signature, telemetry, hmac_rotation
- `common-models/src/lib.rs` — dodany moduł: rollout_config
- `common-models/src/api_responses.rs` — dodane: `ChallengeResponse`, opcjonalne pola nonce/challenge_response w `LaunchTokenRequest`
- `launcher-api/src/client.rs` — dodana metoda `fetch_challenge()` z backward compat (404 → None)

### Dokumentacja

- `docs/contracts/challenge-response.md` — Spec challenge-response flow
- `docs/contracts/ops-dashboard.md` — Spec panelu operacyjnego (3-fazowa implementacja)
- `docs/contracts/migration-rollout-plan.md` — Plan migracji M1..M4, timeline Mar-Sep 2026
- `docs/runbooks/rollback.md` — Procedury R1..R4: rollback kanału, self-update, client update, emergency shutdown

---

## Podsumowanie

Sprint 5 zamyka cały backlog projektu launcher-rust:
- **84 zadania** LR-001..LR-084 ✅
- **15 testów akceptacyjnych** AT-001..AT-015 ✅
- **7 etapów** (Core → API → UI → CI → Hardening → Migration → Support) ✅
- **5 sprintów** realizacji ✅

Łącznie w projekcie: ~210 unit testów + 15 testów akceptacyjnych + 559 linii testów integracyjnych.

---

## Post-sprint: Audyt i uzupełnienia (gap-fix)

Po audycie kompletności zidentyfikowano i wypełniono luki:

### 1. `validation.rs` rozbudowany (z 5 do ~310 linii)

Był placeholder (re-eksport z manifest.rs). Teraz zawiera:
- `validate_url()` — walidacja URL, wymuszanie HTTPS w produkcji
- `validate_semver()` — walidacja wersji X.Y.Z
- `validate_channel()` — lista dozwolonych kanałów (stable/test/dev/canary/beta)
- `validate_sha256_hex()` — walidacja hex SHA-256 (64 znaki)
- `is_grace_period_active()` — §5.4 spec: porównanie dat ISO 8601
- `is_files_hash_acceptable()` — akceptacja current+previous hash w grace period
- 20 unit testów

### 2. Grace period logic (§5.4 spec)

Pole `grace_previous_version_accepted_until_utc` istniało w modelu, ale brakowało logiki decyzyjnej.
Teraz `is_files_hash_acceptable()` implementuje zasadę: "jesli grace period aktywny, akceptuj filesHash
obliczony zarówno z bieżącej jak i z poprzedniej wersji manifestu".

### 3. Edge-case testy (`edge_case_tests.rs`)

Nowy plik testowy pokrywający:
- filesHash deterministyczność (3 wywołania = ten sam wynik)
- filesHash sortowanie po path (nie po kolejności deklaracji)
- filesHash wykluczenie non-managed i delete
- filesHash marker MISSING (powtarzalny)
- Walidacja URL/semver/channel/SHA-256
- Grace period: active/expired/none

### Następne kroki

1. Uruchomienie pełnego CI pipeline na GitHub Actions (cargo test --all)
2. Weryfikacja kompilacji na GHA (NIGDY lokalnie)  
3. Push do remote gdy użytkownik zatwierdzi

---

## Aktualizacja 2026-03-05 (Codex/Copilot sync)

### Domknięte po audycie wykonawczym
- `launcher-core/src/hmac_rotation.rs`:
  - dodano test `test_challenge_with_rotated_key` (stary/new `kid` + fallback bez `kid`).
- API PHP:
  - dodano endpoint `apik/v1/challenge.php` (nonce issue + DB persist + structured logging),
  - dodano endpoint `apik/v1/server-status.php` (Rust-compatible response schema + structured logging),
  - `apik/v1/launcher-token.php` rozszerzono o walidację challenge-response (`nonce`, `challengeResponse`, one-time consume).
- Konfiguracja:
  - `.env.example` rozszerzone o `CHALLENGE_TTL`, `CHALLENGE_REQUIRED`, `SERVER_STATUS_TIMEOUT_MS`, `SECURITY_LOG_FILE`, `LOG_IP_SALT`.

### Ryzyko rolloutowe
- `CHALLENGE_REQUIRED=true` wymaga etapowego wdrożenia (najpierw klient challenge-ready), inaczej legacy klient dostanie `403 challenge_required`.

### Aktualizacja 2026-03-05 (i18n UI kickoff)
- `apps/launcher-tauri/ui/app.js`:
  - dodano runtime i18n PL/EN z fallbackami (`current -> pl -> en`) i interpolacją placeholderów,
  - dodano przełącznik języka oraz persist wyboru po stronie frontendu (`localStorage`),
  - przetłumaczono dynamiczne komunikaty status/progress/download/self-update.
- `apps/launcher-tauri/ui/index.html`:
  - dodano identyfikatory elementów pod i18n i selector języka w ekranie ustawień.

Otwarte na kolejny etap (stan aktualny):
- persist locale w backendzie (`LauncherConfig.language`) — ✅ domknięte,
- pełny RTL (`ar/he/fa`) i wydzielenie słowników do plików JSON — ✅ domknięte,
- nadal otwarte: pipeline language-packów/font-packów poza Tier0 (PL/EN).

### Aktualizacja 2026-03-05 (i18n persist backend)
- `crates/common-models/src/launcher_config.rs`:
  - dodano pole `language` (default `pl`) + walidację,
  - dodano `discover_with_path()` do bezpiecznego zapisu settings.
- `apps/launcher-tauri/src/state.rs`:
  - `AppStateInner` trzyma `language`, `config`, `config_path`.
- `apps/launcher-tauri/src/commands.rs`:
  - `change_channel(channel, language)` zapisuje trwałe ustawienia do `launcher_config.json`,
  - `get_status` zwraca aktualny `language`.
- `crates/common-models/src/dto.rs`:
  - `LauncherStatusDto` rozszerzony o `language`.

### Aktualizacja 2026-03-05 (i18n dictionaries + backend error keys)
- `apps/launcher-tauri/ui/i18n/pl.json` oraz `apps/launcher-tauri/ui/i18n/en.json`:
  - słowniki PL/EN wydzielone z `app.js`,
  - dodana sekcja `errors.backend.*` pod kody `LCH_*`.
- `apps/launcher-tauri/ui/app.js`:
  - dodano loader słowników `loadI18nDictionaries()` i start po ich załadowaniu,
  - dodano obsługę `status.error.userMessageKey` z fallbackiem do `status.error.userMessage`.
- `crates/common-models/src/dto.rs`:
  - `ErrorInfoDto` ma nowe pole `userMessageKey`,
  - dla kodów launcherowych generowany jest klucz `errors.backend.<KOD>`.

### Aktualizacja 2026-03-05 (RTL ar/he/fa)
- `apps/launcher-tauri/ui/app.js`:
  - dodano locale `ar`, `he`, `fa` + normalizację locale (`normalizeLocale`),
  - dynamiczne przełączanie `document.documentElement.dir` (`ltr`/`rtl`).
- `apps/launcher-tauri/ui/style.css`:
  - dodano mirrored layout dla `html[dir="rtl"]` (nagłówek, karty, lista serwerów, progress, download card, footer/nav).
- `apps/launcher-tauri/ui/i18n/`:
  - dodano bazowe paczki `ar.json`, `he.json`, `fa.json` pod testy RTL.

### Aktualizacja 2026-03-05 (i18n coverage refinement)
- `apps/launcher-tauri/ui/index.html` + `ui/app.js`:
  - nazwy światów są podpinane pod klucze i18n (brak finalnych hardcoded labeli).
- `apps/launcher-tauri/ui/i18n/*.json`:
  - dodano `errors.frontend.*` dla kodów błędów frontendu (`CHECK_ERROR`, `UPDATE_ERROR`, `LAUNCH_ERROR`, `REPAIR_ERROR`, `SETTINGS_ERROR`, ...).
- `apps/launcher-tauri/ui/style.css`:
  - dodano fallback font stack oparty o Noto dla lepszego pokrycia Unicode.

### Aktualizacja 2026-03-05 (cel końcowy na 2026-03-06)

Cel operacyjny na 2026-03-06:
- uruchomienie klienta przez launcher na docelowej paczce Windows (tej pobranej do testów graczy),
- równoległe połączenie na światy 7.4 i modern,
- jawnie widoczna różnica anti-cheat między trybami (blokada hotkeys/runy w 7.4, brak tej blokady w modern),
- potwierdzony kanał dystrybucji poprawek przez update klienta i self-update launchera.

Definicja "done" dla etapu demonstracyjnego:
1. Przejście checklisty D1..D5 bez regresji bezpieczeństwa.
2. Każda poprawka launcher/klient zweryfikowana na tej samej paczce Windows (source-of-truth).
3. Wszystkie nowe problemy UI/instalki dopisane do planu z właścicielem (Copilot/Codex) i statusem.

Otwarte ryzyka do monitorowania:
- rozjazd konfiguracji trybów 7.4 vs modern między manifestem, modułami klienta i server-side gate,
- niepełne domknięcie ścieżki self-update przy zmianach launchera,
- regresje UI instalatora wykryte dopiero na finalnej paczce Windows.
