# Launcher Rust+Tauri - Plan Zadan Wykonawczy

**Data:** 2026-03-02  
**Ostatnia aktualizacja:** 2026-03-03 (Sprint 5 complete — PROJEKT KOMPLETNY)  
**Zrodlo:** `launcher+rust2.md`  
**Cel:** zamienic plan architektury na konkretne zadania wdrozeniowe krok po kroku.

**Commit Sprint 1:** `28499ce41` (2026-03-02) — branch `feature/ticket-gate`  
**Commit Sprint 2:** `5c11b4490` (2026-03-03) — branch `feature/ticket-gate` (NOT pushed)  
**Kompilacja:** wylacznie GitHub Actions (nie lokalnie na WSL)

---

## 1. Zasady realizacji

1. Launcher odpowiada za update, integralnosc, token i start klienta.
2. Klient zachowuje wybor swiata/postaci i flow logowania.
3. Ticket-gate + HMAC zostaje twarda warstwa bezpieczenstwa.
4. Token przekazywac przez `OTC_LAUNCH_TOKEN` (env), nie przez CLI.
5. `filesHash` liczyc z lokalnych plikow, nie z hashy z manifestu.

---

## 2. Kolejnosc etapow

1. Etap 0: kontrakty i specyfikacje.
2. Etap 1: Rust Core (CLI/parytet z Python).
3. Etap 2: Tauri UI v1.
4. Etap 3: integracja z instalka.
5. Etap 4: self-update (helper).
6. Etap 5: hardening.
7. Etap 6: migracja i rollout.
8. Etap 7: CI/CD + release automation.

---

## 3. Backlog zadan (ID + akceptacja)

### Etap 0 - Kontrakty i specyfikacje

| ID | Priorytet | Zadanie | Wynik | Kryterium akceptacji |
|---|---|---|---|---|
| LR-001 | P0 | ✅ Opisac kontrakt `launcher-version.php` | `docs/contracts/launcher-version.md` | Zawiera pola `version`, `minVersion`, `required`, `url` |
| LR-002 | P0 | ✅ Opisac kontrakt `update.php` | `docs/contracts/update-manifest.md` | Okreslone pola required/optional oraz walidacja |
| LR-003 | P0 | ✅ Opisac kontrakt `launcher-token.php` | `docs/contracts/launcher-token.md` | `channel` i `manifestVersion` oznaczone jako wymagane |
| LR-004 | P0 | ✅ Opisac kontrakt `installer-catalog.php` | `docs/contracts/installer-catalog.md` | Zawiera Windows/Linux/Android + `sha256` + `size` |
| LR-005 | P0 | ✅ Zamrozic schemat `manifest.json v2` | `docs/contracts/manifest-v2.md` | Pokrywa `files`, `filesHashExpected`, polityki `overwrite/delete` |
| LR-006 | P0 | ✅ Zamrozic schemat `installed_state.json` | `docs/contracts/installed-state.md` | Pokrywa `updateTransaction`, rollback, `lastErrorCode` |
| LR-007 | P0 | ✅ Zdefiniowac kody bledow launchera `LCH_*` | `docs/contracts/error-codes.md` | Kody mapuja sie na scenariusze runtime |
| LR-008 | P0 | ✅ Ustalic polityke plikow managed/user-owned | `docs/contracts/file-ownership.md` | Jasna lista: co wolno nadpisac/usunac |
| LR-009 | P0 | ✅ Zdefiniowac kontrakt integracji z klientem | `docs/contracts/client-integration.md` | Dokumentuje exe path, env token, channel |
| LR-010 | P0 | ✅ Dodac testy kontraktowe API | `tests/contracts/*` | Testy przechodza dla stable/test |

### Etap 1 - Rust Core (CLI)

| ID | Priorytet | Zadanie | Wynik | Kryterium akceptacji |
|---|---|---|---|---|
| LR-011 | P0 | ✅ Utworzyc workspace Rust | `apps/`, `crates/` | Projekt buduje sie na GHA |
| LR-012 | P0 | ✅ Dodac crate `common-models` | `crates/common-models` | Modele serde dla manifest/token/state |
| LR-013 | P0 | ✅ Dodac crate `launcher-api` (pełna impl.) | `crates/launcher-api` | Klient HTTP do endpointow API |
| LR-014 | P0 | ✅ Dodac crate `launcher-core` (pełna impl.) | `crates/launcher-core` | Moduly planner/patcher/hash/process |
| LR-015 | P0 | ✅ Implementowac pobieranie i walidacje manifestu | `manifest` module | Odrzuca uszkodzony JSON i brak required fields |
| LR-016 | P0 | ✅ Implementowac skan lokalnych plikow i SHA-256 | `file_index` module | Hash kazdego pliku zgodny z fixture |
| LR-017 | P0 | ✅ Implementowac `filesHash` (zgodny z planem) | `integrity` module | Wynik zgodny z referencja API/Python |
| LR-018 | P0 | ✅ Implementowac planner update | `patcher::planner` | Tworzy listy: download/replace/delete/keep |
| LR-019 | P0 | ✅ Implementowac downloader z retry | `downloader` module | Retry dziala i raportuje bledy |
| LR-020 | P0 | ✅ Implementowac verify pobrania po `sha256` | `downloader` module | Hash mismatch zatrzymuje update |
| LR-021 | P0 | ✅ Implementowac staging i atomowa podmiane | `patcher::apply` | Brak half-state po sukcesie |
| LR-022 | P0 | ✅ Implementowac rollback marker i recovery | `state` module | Przerwany update wraca do stanu spojnego |
| LR-023 | P0 | ✅ Implementowac token client (`launcher-token.php`) | `launcher-api` | Wysyla `launcherVersion`, `filesHash`, `channel`, `manifestVersion` |
| LR-024 | P0 | ✅ Implementowac process runner | `process_runner` | Klient startuje z `OTC_LAUNCH_TOKEN` |
| LR-025 | P0 | ✅ Implementowac sync listy serwerow | `serverlist_sync` | Aktualizuje plik listy serwerow klienta |
| LR-026 | P0 | ✅ Implementowac flow CLI `check->update->token->launch` | `apps/launcher-cli` | End-to-end dziala bez UI |
| LR-027 | P0 | ✅ Implementowac zapis `installed_state.json` | `state::store` | Stan aktualizuje sie po kazdej probie update |
| LR-028 | P0 | ✅ Implementowac `repair install` | `repair` command | Potrafi naprawic niezgodne pliki |
| LR-029 | P0 | ✅ Testy jednostkowe core | `crates/*/tests` | Pokrycie parser/hash/planner |
| LR-030 | P0 | ✅ Testy integracyjne core + fake API | `tests/integration` | Scenariusze token OK/FAIL, update OK/FAIL |
| LR-071 | P0 | ✅ Zaimplementowac modele serde: `ManifestV2`, `ManifestV1`, `NormalizedManifest` | `models::manifest` | Obsluga v1 i v2 bez rozjazdu kontraktow |
| LR-072 | P0 | ✅ Zaimplementowac `parse_manifest_compat()` (v1 -> normalized v2) | `manifest parser` | Dla v1 mapuje domyslne pola (`managed`, `action`, `includeInFilesHash`) |
| LR-073 | P0 | ✅ Zaimplementowac `validate_basic()` dla manifestu | `manifest validator` | Odrzuca puste pola i duplikaty `path` |
| LR-074 | P0 | ✅ Zaimplementowac bezpieczna walidacje sciezek (path traversal) | `path validator` | Odrzuca `..`, sciezki absolutne i niebezpieczne segmenty |
| LR-075 | P0 | ✅ Dodac walidacje pol zaleznych od `action` | `manifest validator` | `file` wymaga hash/size, `delete` nie wymaga hash/url |
| LR-076 | P0 | ✅ Wdrozyc polityke `filesHashExpected` (v1 opcjonalne, v2 wymagane) | `compat policy` | Launcher failuje dla v2 bez `filesHashExpected` |
| LR-077 | P0 | ✅ Zaimplementowac `InstalledState` + `UpdateTransaction` wg specyfikacji | `models::installed_state` | Pokrywa statusy update i metadane rollback |
| LR-078 | P0 | ✅ Dodac atomiczny zapis `installed_state.json` (`tmp + fsync + rename`) | `state::store` | Brak uszkodzonego state po crashu |
| LR-079 | P1 | ✅ Dodac warstwe DTO statusow dla Tauri | `models::dto` | Front dostaje tylko statusy/komunikaty, nie surowy manifest |
| LR-080 | P1 | ✅ Zablokowac logike bezpieczenstwa w UI (thin frontend) | `tauri integration` | Tauri wywoluje tylko komendy core |
| LR-081 | P0 | ✅ Zaimplementowac `UpdatePlan` (`to_download`, `to_replace`, `to_delete`, `to_keep`) | `update::planner` | Plan zmian jest deterministyczny i testowalny |
| LR-082 | P0 | ✅ Zaimplementowac referencyjne `compute_files_hash()` | `integrity::hash` | Zgodnosc 1:1 z regula sort + `MISSING` |
| LR-083 | P0 | ✅ Dodac zestaw fixture: `manifest_v1`, `manifest_v2`, lokalne pliki | `tests/fixtures` | Testy parsera/plannera/hash uruchamiaja sie offline |
| LR-084 | P0 | ✅ Testy parsera i migracji v1->v2 (happy path + reject cases) | `tests/manifest_compat` | Wykrywa regresje kompatybilnosci |

### Etap 2 - Tauri UI v1

| ID | Priorytet | Zadanie | Wynik | Kryterium akceptacji |
|---|---|---|---|---|
| LR-031 | P0 | ✅ Utworzyc app Tauri | `apps/launcher-tauri` | App startuje na Windows/Linux |
| LR-032 | P0 | ✅ Podpiac komendy z `launcher-core` | Tauri commands | UI nie trzyma logiki bezpieczenstwa |
| LR-033 | P0 | ✅ Ekran statusu (launcher/client/api) | UI screen | Pokazuje wersje i status endpointow |
| LR-034 | P0 | ✅ Ekran aktualizacji z progress barem | UI screen | Pokazuje postep plikow i etapow |
| LR-035 | P0 | ✅ Ekran startu gry | UI screen | Startuje klienta po tokenie |
| LR-036 | P1 | ✅ Ekran bledow i diagnostyki | UI screen | Pokazuje `LCH_*` i zrozumialy komunikat |
| LR-037 | P1 | ✅ Eksport logow | UI action | Tworzy archiwum/log bundle |
| LR-038 | P1 | ✅ Ustawienia (`channel`, install path) | UI screen | Zapis i odczyt ustawien dziala |
| LR-039 | P1 | ✅ Widok statusu API/serwera (read-only) | UI widget | Dane widoczne bez ingerencji w login flow |
| LR-040 | P1 | ✅ UX retry po bledzie | UI flow | Retry dziala bez restartu aplikacji |

### Etap 3 - Integracja z instalka + Download Center

| ID | Priorytet | Zadanie | Wynik | Kryterium akceptacji |
|---|---|---|---|---|
| LR-041 | P0 | ✅ Zdefiniowac model instalatora bootstrap | `docs/installer-bootstrap.md` | Instalka instaluje launcher i minimalny config |
| LR-042 | P0 | ✅ Zintegrowac instalke z launcherem | installer config | Pierwszy start uruchamia launcher |
| LR-043 | P1 | ✅ Dodac endpoint `installer-catalog.php` | `api/installer-catalog.php` | Zwraca artefakty Windows/Linux/Android |
| LR-044 | P1 | ✅ Dodac widok Download Center | UI tab | Lista artefaktow pobiera sie z API |
| LR-045 | P1 | ✅ Dodac walidacje checksum pobieranych instalek | core/UI | Niepoprawny hash blokuje finalizacje |
| LR-046 | P1 | ✅ Dodac polityke podpisow artefaktow | docs + verify step | Podpisy `.sig` sa publikowane i weryfikowane |

### Etap 4 - Self-update launchera

| ID | Priorytet | Zadanie | Wynik | Kryterium akceptacji |
|---|---|---|---|---|
| LR-047 | P1 | ✅ Utworzyc `launcher-helper` | `crates/launcher-helper` | Helper potrafi podmienic binarke po zamknieciu launchera |
| LR-048 | P1 | ✅ Integracja check `launcher-version.php` | `self_update` module | `required=true` wymusza update launchera |
| LR-049 | P1 | ✅ Pobieranie paczki self-update + verify | `self_update` module | Update paczki przechodzi verify hash/podpis |
| LR-050 | P1 | ✅ Restart launchera po podmianie | helper flow | Launcher wraca po udanym update |
| LR-051 | P1 | ✅ Scenariusz rollback self-update | helper flow | Nieudany update nie brickuje launchera |

### Etap 5 - Hardening (po stabilnym v1)

| ID | Priorytet | Zadanie | Wynik | Kryterium akceptacji |
|---|---|---|---|---|
| LR-052 | P2 | ✅ Challenge-response dla launch-token flow | design + implementation | API i launcher obsluguja nonce flow |
| LR-053 | P2 | ✅ Podpis manifestu (silniejszy model) | verify signature | Launcher odrzuca manifest bez poprawnego podpisu |
| LR-054 | P2 | ✅ Telemetria techniczna (opt-in) | metrics pipeline | Metryki update/token bledow widoczne |
| LR-055 | P2 | ✅ Dashboard odrzuconych tokenow/ticketow | ops dashboard | Widoczne trendy i powody odrzucen |
| LR-056 | P2 | ✅ Rotacja kluczy HMAC (`kid`) | API+validator update | Multi-key validation przechodzi testy |

### Etap 6 - Migracja i rollout

| ID | Priorytet | Zadanie | Wynik | Kryterium akceptacji |
|---|---|---|---|---|
| LR-057 | P0 | ✅ Faza M1: parytet Rust vs Python | parity report | Te same endpointy, ten sam `filesHash`, ten sam flow |
| LR-058 | P0 | ✅ Faza M2: kanal testowy Rust launcher | test channel rollout | Rust launcher dziala na test/dev, stable na Python |
| LR-059 | P0 | ✅ Faza M3: soft rollout | rollout config | Stopniowe wlaczanie bez regresji krytycznych |
| LR-060 | P1 | ✅ Faza M4: full rollout | production default | Rust launcher domyslny, Python jako fallback czasowy |
| LR-061 | P1 | ✅ Runbook rollback i fallback | `docs/runbooks/rollback.md` | Zespol ma procedury awaryjne |

### Etap 7 - GitHub Actions (CI/CD)

| ID | Priorytet | Zadanie | Wynik | Kryterium akceptacji |
|---|---|---|---|---|
| LR-062 | P0 | ✅ Dodac `ci.yml` (fmt, clippy, test) | `.github/workflows/ci.yml` | PR nie przechodzi bez zielonego CI |
| LR-063 | P0 | ✅ Dodac contract-tests job | `ci.yml` job | Waliduje zgodnosc payloadow i schema |
| LR-064 | P0 | ✅ Dodac matrix build Windows/Linux | workflow jobs | Artefakty powstaja na obu platformach |
| LR-065 | P0 | ✅ Dodac `build-launcher.yml` | `.github/workflows/build-launcher.yml` | Build uruchamialny manualnie i dla `-rc` |
| LR-066 | P0 | ✅ Dodac `release-launcher.yml` | `.github/workflows/release-launcher.yml` | Tag release publikuje artefakty |
| LR-067 | P1 | ✅ Automatycznie generowac `checksums.txt` | release artifact | Wszystkie pliki maja hash |
| LR-068 | P1 | ✅ Automatycznie publikowac podpisy `.sig` | release artifact | Podpisy dostepne przy release |
| LR-069 | P1 | ✅ Generowac `installer-catalog.json` z release | script + artifact | Katalog zgodny z endpointem API |
| LR-070 | P1 | ✅ Smoke check po release | release gate | Endpointy i artefakty przechodza check |

---

## 4. Testy akceptacyjne (bramka produkcyjna)

| ID | Test | Oczekiwany wynik |
|---|---|---|
| AT-001 | ✅ API offline przy starcie | Launcher fail-closed, brak wejscia do gry |
| AT-002 | ✅ Uszkodzony plik lokalny | Redownload + poprawny hash |
| AT-003 | ✅ Poprawny `filesHash` | Token wydany, start klienta dziala |
| AT-004 | ✅ Niepoprawny `filesHash` | Token odrzucony |
| AT-005 | ✅ Ponowne uzycie tokena | Login odrzucony (one-time use) |
| AT-006 | ✅ Zly kanal (`channel`) | Odrzucenie tokena/walidacji |
| AT-007 | ✅ Przerwany update | Recovery/rollback przy kolejnym starcie |
| AT-008 | ✅ Self-update sukces | Launcher podmieniony i restartuje sie |
| AT-009 | ✅ Self-update fail | Launcher wraca do poprzedniej wersji |
| AT-010 | ✅ Download Center checksum | Bledny plik nie jest akceptowany |
| AT-011 | ✅ Parser v1/v2 | v1 i v2 mapuja sie do jednego `NormalizedManifest` |
| AT-012 | ✅ Duplikat `path` w manifeście | Manifest jest odrzucany |
| AT-013 | ✅ Path traversal w `files[].path` | Manifest jest odrzucany |
| AT-014 | ✅ `action=delete` bez `sha256/size` | Manifest przechodzi walidacje |
| AT-015 | ✅ Crash w trakcie zapisu state | `installed_state.json` pozostaje spojny |

---

## 5. Plan realizacji (5 sprintow)

1. **Sprint 1:** ✅ LR-001..LR-012 + LR-062..LR-063 + LR-071..LR-078 + LR-081..LR-084. Commit `28499ce41`.
2. **Sprint 2:** ✅ LR-004 + LR-010 + LR-013..LR-030. Commit `5c11b4490` + sprint3-patch.
3. **Sprint 3:** ✅ KOMPLETNY. LR-031..LR-040 + LR-064 + LR-065 + LR-079 + LR-080.
4. **Sprint 4:** ✅ KOMPLETNY. LR-041..LR-051 + LR-046 + LR-066..LR-070. Commit `75d5e8543`.
5. **Sprint 5:** ✅ KOMPLETNY. LR-052..LR-061 + AT-001..AT-015. Commit `2c5ecc431`.

---

## 6. Pierwsze zadania do odpalenia od razu

1. LR-001, LR-002, LR-003, LR-005.
2. LR-006 i LR-010.
3. LR-011, LR-012, LR-071, LR-072.
4. LR-074, LR-075, LR-082.
5. LR-062.

To jest minimalny zestaw, ktory odblokowuje dalsze kodowanie bez ryzyka niezgodnosci API.

---

## 7. Zadania doprecyzowujace krok po kroku (z przykladami z `launcher+rust2.md`)

### 7.1 Parser kompatybilny v1->v2

1. **Krok 1:** dodac `ManifestV1Raw`, `ManifestV2Raw`, `NormalizedManifest`.
2. **Krok 2:** dodac `parse_manifest_compat()` z wykrywaniem `schemaVersion`.
3. **Krok 3:** dla braku `schemaVersion` uruchomic fallback `normalize_v1()`.
4. **Krok 4:** po normalizacji zawsze uruchomic `validate_basic()`.
5. **Krok 5:** dopisac testy `v1 -> normalized` i `v2 -> normalized`.

Przyklad (z planu, szkic):

```rust
pub fn parse_manifest_compat(json_text: &str) -> Result<NormalizedManifest, ManifestParseError> {
    let value: serde_json::Value = serde_json::from_str(json_text)?;
    let normalized = match value.get("schemaVersion").and_then(|v| v.as_str()) {
        Some(schema) if schema.starts_with('2') => normalize_v2(serde_json::from_value(value)?)?,
        Some(other) => return Err(ManifestParseError::UnsupportedSchema(other.to_string())),
        None => normalize_v1(serde_json::from_value(value)?)?,
    };
    normalized.validate_basic()?;
    Ok(normalized)
}
```

### 7.2 Walidacja sciezek i pol zaleznych od `action`

1. **Krok 1:** dodac helper `validate_safe_rel_path(path)`.
2. **Krok 2:** odrzucac `..`, sciezki absolutne, puste path i niebezpieczne segmenty.
3. **Krok 3:** walidowac duplikaty `path` w `validate_basic()`.
4. **Krok 4:** dla `action=file` + `managed=true` wymagac `sha256` i `size`.
5. **Krok 5:** dla `action=delete` nie wymagac `sha256`, `size`, `url`.

Przyklad (z planu, szkic):

```rust
pub fn validate_safe_rel_path(path: &str) -> Result<(), String> {
    let p = path.replace('\\', "/");
    if p.trim().is_empty() { return Err("empty path".into()); }
    if p.starts_with('/') { return Err("absolute path not allowed".into()); }
    if p.contains("../") || p == ".." { return Err("path traversal not allowed".into()); }
    if p.contains(':') { return Err("colon not allowed in relative manifest path".into()); }
    Ok(())
}
```

### 7.3 `filesHashExpected`, `compute_files_hash()` i kompatybilnosc

1. **Krok 1:** v1: `filesHashExpected` opcjonalne; v2: wymagane.
2. **Krok 2:** liczyc hash po `path` posortowanym rosnaco.
3. **Krok 3:** uwzgledniac tylko `managed=true`, `action=file`, `includeInFilesHash!=false`.
4. **Krok 4:** brak pliku lokalnego mapowac na `MISSING`.
5. **Krok 5:** wynik porownywac z oczekiwanym hashem i blokowac token przy mismatch.

Przyklad zasad mapowania v1->v2 (z planu):

```text
schemaVersion brak -> "1-compat"
manifestId brak -> "${channel}:${version}"
filesHashExpected brak -> None
files[].managed -> true
files[].action -> file
files[].includeInFilesHash -> true
```

### 7.4 `InstalledState` i odporny zapis stanu

1. **Krok 1:** wdrozyc `InstalledState`, `UpdateTransaction`, `UpdateTxStatus`.
2. **Krok 2:** przy starcie sprawdzac, czy poprzedni update byl przerwany.
3. **Krok 3:** zapis state robic atomowo (`tmp + fsync + rename`).
4. **Krok 4:** przy bledzie patchera ustawic `rollback_required`.
5. **Krok 5:** po recovery ustawic spójny `lastUpdateResult`.

Przyklad statusow (z planu):

```rust
pub enum UpdateTxStatus {
    Idle, Preparing, Downloading, Verifying,
    Applying, Finalizing, RollbackRequired, RollbackInProgress,
}
```

### 7.5 Cienkie API `LauncherCore` dla Tauri

1. **Krok 1:** Tauri wywoluje tylko komendy backendowe.
2. **Krok 2:** w UI nie trzymac surowych struktur manifestu.
3. **Krok 3:** wystawiac do UI DTO/statusy zamiast logiki biznesowej.
4. **Krok 4:** mapowac bledy `LCH_*` na komunikaty user-facing.
5. **Krok 5:** trzymac flow `check -> update -> hash -> token -> launch` po stronie core.

Przyklad API core (z planu, szkic):

```rust
impl LauncherCore {
    pub fn fetch_manifest(&self, channel: &str) -> Result<NormalizedManifest, LauncherError> { todo!() }
    pub fn plan_update(&self, manifest: &NormalizedManifest) -> Result<UpdatePlan, LauncherError> { todo!() }
    pub fn compute_files_hash(&self, manifest: &NormalizedManifest) -> Result<String, LauncherError> { todo!() }
    pub fn request_launch_token(&self, launcher_version: &str, manifest_version: Option<&str>, files_hash: &str, channel: &str) -> Result<String, LauncherError> { todo!() }
    pub fn launch_client_with_env(&self, token: &str) -> Result<(), LauncherError> { todo!() }
}
```

### 7.6 Powiazanie tych doprecyzowan z backlogiem LR

1. Parser i normalizacja: `LR-071`, `LR-072`, `LR-084`.
2. Walidacje: `LR-073`, `LR-074`, `LR-075`, `AT-012`, `AT-013`, `AT-014`.
3. Hash i zgodnosc: `LR-076`, `LR-082`, `AT-003`, `AT-004`.
4. State i recovery: `LR-077`, `LR-078`, `AT-007`, `AT-015`.
5. Thin Tauri: `LR-079`, `LR-080`, `LR-032`.
