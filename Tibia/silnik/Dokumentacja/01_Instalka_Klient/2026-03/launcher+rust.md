# Launcher Rust+Tauri - Plan Wykonawczy Krok Po Kroku

**Data:** 2026-03-02  
**Status:** execution plan v3  
**Cel:** dowiezc produkcyjny launcher desktop (Rust + Tauri) oraz pipeline build/release na GitHub Actions bez rozbijania obecnego flow API + ticket-gate.

---

## 1. Zakres i zasady

## 1.1 Co jest w zakresie

1. Launcher desktop dla Windows/Linux (Rust + Tauri).
2. Aktualizacja klienta z manifestu (`update.php`).
3. Walidacja integralnosci (sha256 + `filesHash`).
4. Pobranie launch-tokena (`launcher-token.php`).
5. Start klienta z `OTC_LAUNCH_TOKEN` przez env.
6. Download Center: linki do instalek Windows/Linux/Android.
7. CI/CD: testy, build, artefakty, release przez GitHub Actions.

## 1.2 Co jest poza zakresem tego dokumentu

1. Przepisanie klienta OTClient.
2. Przepisanie API login/ticket od zera.
3. Zmiana architektury ticket-gate (to zostaje warstwa twarda).
4. Pelna implementacja launchera Android (tu tylko interfejs katalogu instalek).

## 1.3 Niezmienialne zasady bezpieczenstwa

1. `launch-token` to warstwa utrudniajaca, nie glowny dowod bezpieczenstwa.
2. Finalna decyzja dostepu jest po stronie API + Canary (ticket-gate + HMAC).
3. Token przekazywany przez env, nie przez CLI.
4. `filesHash` liczony z lokalnych plikow, nie z hashy z manifestu.

---

## 2. Stan startowy (co juz macie)

1. Dzialajacy MVP Python (`canary_test/launcher/launcher.py`) z GUI, update, `filesHash`, token i startem klienta.
2. Endpointy API sa dostepne: `update.php`, `launcher-token.php`, `launcher-version.php`.
3. Ticket-gate flow jest zaprojektowany i wdrozony po stronie API/Canary.
4. Istnieje luka kontraktowa: launcher Python nie wysyla `channel` do `launcher-token.php`, a API domyslnie zaklada `stable`.

---

## 3. Kamienie milowe (M0-M8)

1. **M0 - Kontrakty zamrozone:** schema API + state + katalog artefaktow.
2. **M1 - Rust Core dziala w CLI:** parytet funkcji z Python MVP.
3. **M2 - Tauri UI MVP:** update/token/start/logi.
4. **M3 - Download Center:** Windows/Linux/Android z checksum.
5. **M4 - Self-update helper:** bezpieczna podmiana launchera.
6. **M5 - CI green:** lint + test + build matrix.
7. **M6 - Release automation:** tag -> artefakty -> katalog instalek.
8. **M7 - Kanal test:** rollout testowy i telemetryka bledow.
9. **M8 - Stable rollout:** kontrolowane przejscie z fallbackiem.

---

## 4. Backlog zadan (ID, kolejnosc, zaleznosci)

Legenda priorytetu: `P0` krytyczne, `P1` wazne, `P2` dodatkowe.  
Legenda statusu startowego: `TODO`.

| ID | Priorytet | Zadanie | Wynik (artifact) | Zalezy od |
|---|---|---|---|---|
| T001 | P0 | Spisac finalny kontrakt `update.php` (required/optional fields) | `docs/contracts/update-schema.md` | - |
| T002 | P0 | Spisac finalny kontrakt `launcher-token.php` i oznaczyc `channel` jako required | `docs/contracts/launcher-token-schema.md` | T001 |
| T003 | P0 | Spisac kontrakt `launcher-version.php` (`required`, `minVersion`, `url`) | `docs/contracts/launcher-version-schema.md` | T001 |
| T004 | P0 | Zaprojektowac `installer-catalog.php` schema | `docs/contracts/installer-catalog-schema.md` | T001 |
| T005 | P0 | Spisac `installed_state.json` schema + stany transakcji update | `docs/contracts/installed-state-schema.md` | T001 |
| T006 | P0 | Poprawic Python MVP: wysylac `channel` do `launcher-token.php` | patch w `launcher.py` | T002 |
| T007 | P0 | Dodac test kontraktowy API dla stable/test channel | `tests/contracts/api_contract_test.*` | T001,T002,T003 |
| T008 | P0 | Utworzyc workspace Rust (core/api/helper/tauri) | struktura repo | T005 |
| T009 | P0 | Dodac modele Rust: manifest/token/catalog/state | `crates/common-models` | T008 |
| T010 | P0 | Implementacja `manifest fetch + validate` | `launcher-core::manifest` | T009 |
| T011 | P0 | Implementacja `local file scan + sha256` | `launcher-core::file_index` | T009 |
| T012 | P0 | Implementacja zgodnego `filesHash` (fixtures vs Python/API) | `launcher-core::integrity` + testy | T011 |
| T013 | P0 | Implementacja patch planera (download/replace/delete) | `launcher-core::patcher::planner` | T010,T011 |
| T014 | P0 | Implementacja downloadera z verify i retry | `launcher-core::downloader` | T013 |
| T015 | P0 | Implementacja atomowej podmiany + rollback marker | `launcher-core::patcher::apply` | T014,T005 |
| T016 | P0 | Implementacja klienta `launcher-token.php` (z `channel`) | `launcher-api::token_client` | T002,T009 |
| T017 | P0 | Implementacja process runner (`OTC_LAUNCH_TOKEN`) | `launcher-core::process_runner` | T016 |
| T018 | P0 | Implementacja flow CLI: check->update->token->launch | `apps/launcher-cli` | T010..T017 |
| T019 | P0 | Twarde kody bledow `LCH_*` + mapowanie na UI | `crates/error-codes` | T018 |
| T020 | P0 | Testy integracyjne core (fixtures + fake API) | `tests/integration/*` | T018 |
| T021 | P0 | Zbudowac Tauri shell i komendy backendu | `apps/launcher-tauri` | T018,T019 |
| T022 | P0 | Ekran update/progress/logs + retry | UI MVP | T021 |
| T023 | P0 | Ekran start gry + status tokena | UI MVP | T021 |
| T024 | P1 | Ekran ustawien (`channel`, `install path`) | UI MVP+ | T021 |
| T025 | P1 | Ekran Download Center (lista artefaktow) | UI MVP+ | T004,T021 |
| T026 | P1 | Endpoint `installer-catalog.php` po stronie API | `api/installer-catalog.php` | T004 |
| T027 | P1 | Walidacja checksum dla pobieranych instalek z katalogu | `launcher-core::catalog_download` | T025,T026 |
| T028 | P1 | Implementacja helpera self-update | `crates/launcher-helper` | T018 |
| T029 | P1 | Integracja self-update z launcher-version check | `launcher-core::self_update` | T028,T003 |
| T030 | P1 | Recovery po nieudanym self-update | rollback scenariusz | T029,T005 |
| T031 | P0 | GHA: workflow `ci.yml` (fmt, clippy, test) | `.github/workflows/ci.yml` | T008 |
| T032 | P0 | GHA: workflow `build-launcher.yml` (Windows/Linux) | `.github/workflows/build-launcher.yml` | T021,T031 |
| T033 | P0 | GHA: workflow `release-launcher.yml` (tag -> release) | `.github/workflows/release-launcher.yml` | T032 |
| T034 | P1 | GHA: generator `installer-catalog.json` z artefaktow release | job/script release | T033,T026 |
| T035 | P1 | Publikacja checksum i podpisow artefaktow | `.sha256` + `.sig` | T033 |
| T036 | P0 | Testy E2E kanal `test`: update/token/login/start | raport QA | T022,T023,T032 |
| T037 | P0 | Soft rollout: 10% -> 50% -> 100% | plan rollout | T036 |
| T038 | P1 | Utrzymac fallback Python launcher przez 1-2 releasy | runbook rollback | T037 |
| T039 | P2 | Telemetria techniczna (opt-in): update errors, token errors | metrics dashboard | T037 |
| T040 | P2 | Hardening: challenge-response + manifest signature | docs + backlog security | T037 |

---

## 5. Plan sprintowy (kolejnosc wdrozenia)

## Sprint 1 (P0 fundament)

1. T001-T007 (kontrakty + szybka poprawka Python `channel`).
2. T008-T012 (setup Rust + `filesHash` parytet).
3. T031 (CI quality gate).

**Wyjscie sprintu:** kontrakty zamrozone, CI dziala, hash engine zgodny.

## Sprint 2 (Core launcher)

1. T013-T020 (patcher/token/process/flow CLI + testy integracyjne).
2. Domkniecie fail/retry/rollback marker.

**Wyjscie sprintu:** CLI Rust robi to samo co Python MVP.

## Sprint 3 (UI + Build)

1. T021-T024 (Tauri UI MVP).
2. T032 (build launcher na GHA dla Windows/Linux).

**Wyjscie sprintu:** dzialajacy launcher desktop z artefaktem z GHA.

## Sprint 4 (Release + Download Center)

1. T025-T027 (Download Center + API katalogu + checksum validate).
2. T033-T035 (release automation + checksum/signature publish).

**Wyjscie sprintu:** tag release publikuje launcher i katalog instalek.

## Sprint 5 (Stabilizacja produkcyjna)

1. T028-T030 (self-update helper + recovery).
2. T036-T038 (test channel, soft rollout, fallback policy).

**Wyjscie sprintu:** gotowosc produkcyjna z kontrolowanym rolloutem.

---

## 6. GitHub Actions - szczegolowy plan

## 6.1 `ci.yml` (kazdy PR/push)

**Trigger:** `pull_request`, `push` (main/develop).  
**Jobs:**
1. `lint`: `cargo fmt --check`, `cargo clippy --workspace -- -D warnings`.
2. `test`: `cargo test --workspace`.
3. `contract-tests`: testy schematow JSON + zgodnosc payloadow API.

**Warunek merge:** wszystkie joby zielone.

## 6.2 `build-launcher.yml` (manual + tag pre-release)

**Trigger:** `workflow_dispatch`, `push tags: v*-rc*`.  
**Matrix:**
1. `windows-latest` -> `x86_64-pc-windows-msvc`.
2. `ubuntu-latest` -> `x86_64-unknown-linux-gnu`.

**Jobs:**
1. Build Rust core.
2. Build Tauri app.
3. Build helper updater.
4. Generate `sha256` for each artifact.
5. Upload artifacts (`launcher`, `helper`, `checksums.txt`).

## 6.3 `release-launcher.yml` (produkcyjne wydanie)

**Trigger:** `push tags: v*` (bez `-rc`).  
**Jobs:**
1. Pobranie artefaktow z build joba.
2. Podpisanie artefaktow (`.sig`).
3. Publikacja GitHub Release.
4. Generacja `installer-catalog.json`.
5. Publikacja katalogu do API/CDN.
6. Smoke check endpointow (`launcher-version`, `update`, `installer-catalog`).

**Gate release:** smoke check + checksum verify musza przejsc.

## 6.4 Minimalne pliki workflow do dodania

1. `.github/workflows/ci.yml`
2. `.github/workflows/build-launcher.yml`
3. `.github/workflows/release-launcher.yml`
4. `scripts/release/generate_installer_catalog.*`
5. `scripts/release/smoke_check.*`

---

## 7. Definition of Done (per etap)

## 7.1 DoD M1 (Rust CLI parity)

1. Launcher pobiera manifest i aktualizuje pliki poprawnie.
2. `filesHash` zgadza sie z oczekiwanym wynikiem fixtures/API.
3. Token request przechodzi dla `stable` i `test`.
4. Klient startuje z env tokenem.

## 7.2 DoD M3 (Tauri MVP)

1. Uzytkownik widzi postep aktualizacji i sensowne bledy.
2. Retry dziala bez restartu launchera.
3. Logi mozna wyeksportowac.

## 7.3 DoD M6 (Release automation)

1. Tag release automatycznie tworzy artefakty dla Windows/Linux.
2. Publikowane sa checksumy i podpisy.
3. `installer-catalog.json` jest aktualny i dostepny przez API.

## 7.4 DoD M8 (Production rollout)

1. E2E testy kanalu `test` sa zielone.
2. Soft rollout przeszedl bez krytycznych regresji.
3. Jest runbook rollback + fallback do Python launchera.

---

## 8. Testy akceptacyjne (must pass)

1. `API_OFFLINE_BLOCK`: launcher blokuje wejscie przy niedostepnym API.
2. `MANIFEST_HASH_MISMATCH`: uszkodzony plik wymusza redownload.
3. `TOKEN_GOOD`: poprawny token i login flow dzialaja.
4. `TOKEN_REPLAY`: ponowne uzycie tokena jest odrzucone.
5. `TOKEN_WRONG_CHANNEL`: token dla zlego kanalu jest odrzucony.
6. `INTERRUPTED_UPDATE_RECOVERY`: po przerwanym update launcher wraca do spojnego stanu.
7. `SELF_UPDATE_OK`: wymagany update launchera wykonuje sie poprawnie.
8. `SELF_UPDATE_FAIL_ROLLBACK`: nieudany self-update nie brickuje launchera.
9. `CATALOG_DOWNLOAD_VERIFY`: Download Center pobiera i weryfikuje checksum.

---

## 9. Ryzyka i konkretne mitygacje

1. **Ryzyko:** niespojnosc kontraktow API/launcher.  
`Mitygacja:` T001-T007 + testy kontraktowe w CI.

2. **Ryzyko:** aktualizacja kasuje pliki usera.  
`Mitygacja:` polityka `managed/preserve/delete` i bezpieczny planner.

3. **Ryzyko:** self-update uszkadza aplikacje.  
`Mitygacja:` oddzielny helper + rollback marker + smoke po update.

4. **Ryzyko:** pipeline publikuje uszkodzony artefakt.  
`Mitygacja:` checksum/signature + smoke check przed final release.

5. **Ryzyko:** rollout regresji auth/login.  
`Mitygacja:` etap `test` + stopniowy rollout + fallback Python.

---

## 10. Sekwencja "co robimy od jutra" (operacyjnie)

1. Zamknac T001-T005 (kontrakty i schema docs).
2. W tym samym dniu wdrozyc T006 (channel fix w Python launcherze).
3. Utworzyc workspace Rust i CI quality gate (T008,T031).
4. Zrobic `filesHash` parity i testy fixtures (T011,T012,T020).
5. Dopiero potem patcher/token/runner (T013-T017).
6. Gdy CLI jest stabilne, odpalic Tauri UI (T021+).
7. Rownolegle przygotowac workflow build/release (T032-T035).
8. Wejsc na kanal test i rollout (T036+).

---

## 11. Decyzje wymagane od zespolu (blokery)

1. Czy release artifacts trzymacie tylko na GitHub Releases, czy tez na wlasnym CDN.
2. Czy podpisywanie artefaktow jest P0 czy P1.
3. Jaki czas fallbacku Python launchera: 1 release czy 2 releasy.
4. Kto odpowiada za endpoint `installer-catalog.php` i jego publikacje.

---

## 12. Wynik oczekiwany po realizacji planu

1. Jeden launcher desktop (Rust+Tauri) aktualizuje klienta i uruchamia gre bez recznych krokow.
2. Build i release sa powtarzalne i automatyczne przez GitHub Actions.
3. Uzytkownik ma w launcherze zakladke pobierania instalek Windows/Linux/Android.
4. Security model pozostaje zgodny z planem: launcher pomaga, API+Canary decyduja.

