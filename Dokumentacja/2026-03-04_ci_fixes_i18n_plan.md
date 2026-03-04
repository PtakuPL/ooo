# Sesja 2026-03-04 — CI fixes + plan i18n launchera

**Branch:** `feature/ticket-gate`  
**Commit:** `ae6706ace`

---

## Co zostało zrobione

### 1. Naprawa CI — 10+ błędów clippy + compilation errors

#### Błędy clippy (Launcher Rust CI):
| Plik | Problem | Fix |
|------|---------|-----|
| `patcher.rs:18` | Unused import `sha256_file` | Usunięto |
| `repair.rs:9` | Unused import `PlannedFileAction` | Usunięto |
| `repair.rs:79` | `for (path, _) in &map` → iteracja po keys | `for path in map.keys()` |
| `self_update.rs:291` | Unused variable `target_path` | `_target_path` |
| `hmac_rotation.rs:85` | `.filter(..).next()` | `.find(..)` |
| `hmac_rotation.rs:225` | `hex.len() % 2 != 0` | `!hex.len().is_multiple_of(2)` |
| `manifest_signature.rs:103` | Needless `return` | Usunięto `return` |
| `manifest_signature.rs:188` | Manual modulo check | `is_multiple_of(2)` |

#### Błędy kompilacji (Build Launcher):
| Plik | Problem | Fix |
|------|---------|-----|
| `commands.rs:92,158,328,385` | `ApiClient::new(&api_url)` — oczekiwano `ApiClientConfig`, dostano `&String` | Przełączono na `ApiClient::new(ApiClientConfig { base_url: api_url, ..Default::default() })` |
| `commands.rs` heading | Brak importu `ApiClientConfig` | Dodano do use statement |

### 2. Poprzednie sesje — podsumowanie nierozwiązanych problemów

- **Canary Build** — brakował `find_package(nlohmann_json)` w CMakeLists.txt (naprawiony we wcześniejszym commicie)
- **Windows Build (OTC)** — transient HTTP 503 z GitHub CDN (zlib) — nie jest bug kodu
- **Contract tests** — `test_infer_tags` failed z powodu `p.contains("/modules/")` vs `"modules/"` (naprawiony)
- **cargo fmt** — rozległe reformatowanie ~6 plików (naprawione)

### 3. Plan i18n launchera

Stworzony obszerny plan w `/Dokumentacja/2026-03-04_launcher_i18n_plan.md`:
- 5 faz implementacji (~50-60h)
- System pakietów językowych (bundled en+pl, reszta do pobrania)
- Full Unicode support (CJK, Arabic/RTL, Devanagari, Thai...)
- 53 locale spójne z serwerem Canary
- Tier system (0-5) dla pakietów fontów
- API endpoint `/api/language-packs.php`
- RTL support dla Arabic/Hebrew/Farsi

---

## Oczekujące decyzje

1. **Logo SerwerCanary** — brak logo, potrzebny design
2. **Paleta kolorów** — obecna OK? Potrzebny light mode?
3. **Sidebar redesign** — ikony SVG vs emoji, vertical vs horizontal
4. **Kiedy zaczynamy i18n** — po stabilizacji CI?

---

## Stan CI po sesji

| Workflow | Status | Uwagi |
|----------|--------|-------|
| Launcher Rust CI | ⏳ nowy run (ae6706ace) | 10 clippy + 4 type errors naprawione |
| Build Launcher | ⏳ nowy run | ApiClientConfig fix |
| Canary Build | ⏳ w trakcie | nlohmann_json fix z poprzedniego commitu |
| Build Windows (OTC) | ⏳ retry | CDN 503 — transient |
| Build Linux (OTC) | ✅ passed | — |

---

## Zadania otwarte (dopisek 2026-03-05)

### Cel: zielony CI dla launchera na Ubuntu + Windows

- [ ] **Blocker kompilacji (Ubuntu + Windows):** `apps/launcher-tauri/src/commands.rs` ma zgodność typów z `launcher-api::fetch_manifest` (bez ponownego parsowania `NormalizedManifest` jako JSON string).
- [ ] **Higiena CI (Launcher Rust CI):** domknąć `cargo fmt --check` i `cargo clippy -D warnings` dla workspace `launcher-rust`.
- [ ] **Testy lokalne:** uruchomić `cargo test --workspace` w `launcher-rust` i zweryfikować brak regresji w `launcher-core`.
- [ ] **Weryfikacja GH Actions:** potwierdzić nowy zielony run dla workflow `Build Launcher` i `Launcher Rust CI`.
- [ ] **Dopiero po green CI:** wrócić do tematu buildów OTC Windows (osobny strumień, bo historycznie były też błędy transient/CDN).

### Podział prac, żeby nie psuć sobie nawzajem kodu

- **Codex (ten czat):** `launcher-rust` CI fixes (`commands.rs`, clippy/fmt/testy rust).
- **Copilot:** część C++/OTC/canary oraz równoległe zmiany poza `launcher-rust`.

### Braki do pełnego domknięcia kompilacji na obu OS

- Brak finalnego, potwierdzonego green run po aktualnym pakiecie poprawek.
- Brak jednego źródła prawdy z numerami runów „ostatni fail / pierwszy pass” (do dopisania po rerunie).
