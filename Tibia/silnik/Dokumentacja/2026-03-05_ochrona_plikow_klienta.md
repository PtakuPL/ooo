# Ochrona plików klienta — system kategoryzacji i integrity check

**Data:** 2026-03-05  
**Status:** ✅ Manifest v1.0.2 wygenerowany z kategoriami  
**Gałąź:** `feature/ticket-gate`  
**Powiązane:** `2026-03-05_plan_2_agenty_copilot_codex.md` → Faza 4.5

---

## 1. Problem

Paczka OTClient zawiera **290 plików `.lua`** w czytelnej formie (plain text).  
Użytkownik po ściągnięciu klienta ma pełny dostęp do:

- `init.lua` — konfiguracja serwerów, `CLIENT_LOCKED`, `GameModes`, porty, adresy
- `modules/*/` — 70+ modułów Lua (entergame, serverlist, battle, console, features...)
- `data/locales/*.lua` — 111 plików locale

**Ryzyka:**
1. Zmiana `CLIENT_LOCKED = false` → odblokowanie dodawania serwerów
2. Zmiana adresu serwera/portu → ominięcie ticket gate
3. Wyłączenie modułów bezpieczeństwa
4. Edycja logiki gry (gamelib, interface, itp.)
5. Podmiana tłumaczeń na obraźliwe treści

---

## 2. Strategia: 3 warstwy ochrony

### Warstwa 1: Kategoryzacja plików w manifeście (✅ ZROBIONE)

Każdy plik w manifeście ma pola `managed` i `overwritePolicy`:

| Kategoria | managed | overwritePolicy | Przykłady | Opis |
|-----------|---------|-----------------|-----------|------|
| **System** | `true` | `if_hash_differs` | `otclient.exe`, `*.dll`, `*.lua` (modules/), `*.spr`, `*.lzma` | Kontrolowane, nadpisywane przy update gdy hash się zmieni |
| **Ustawienia użytkownika** | `true` | `preserve_user` | `otclientrc.lua`, `data/settings/*` | Nie nadpisuj jeśli plik już istnieje lokalnie |
| **Niezarządzane** | `false` | `never` | `records/*`, `screenshots/*` | Launcher w ogóle nie rusza — pliki użytkownika |

### Warstwa 2: Integrity check plików krytycznych (🔧 DO ZROBIENIA w Rust)

Launcher **przed uruchomieniem klienta** sprawdza SHA-256 krytycznych plików:

1. Pobierz listę `criticalFiles[]` z manifestu (path + sha256)
2. Dla każdego pliku: oblicz SHA-256 na dysku i porównaj z oczekiwanym
3. Jeśli hash nie zgadza się → **BLOKADA uruchomienia** + komunikat:
   - *"Pliki klienta zostały zmodyfikowane. Napraw instalację."*
   - Przycisk "Napraw" → redownload zmodyfikowanych plików

### Warstwa 3: Lua bytecode (przyszłość — decyzja usera)

Kompilacja `.lua → .luac` (bytecode) w GHA build pipeline:
```bash
luac -o init.luac init.lua
```
- Wymaga zmian w OTClient build pipeline
- Nie blokuje teraz — Warstwa 1+2 wystarczą na start

---

## 2b. Wymaganie: Workflow budowania czystej paczki klienta (GHA)

**WAŻNE:** Obecna paczka testowa (`canary_test/testyy/`) to kopia repozytorium OTClient — zawiera 1298 plików źródłowych (`.cpp`, `.h`, `.hpp`), katalog `src/`, CMakeLists.txt itd.

Gracze powinni dostawać **czystą, skompilowaną paczkę** — tak jak robi to opentibia-br w swoich GitHub Releases:
- Tylko `otclient.exe` + DLL + moduły Lua + assety (sprites, .lzma, data/)
- Bez kodu źródłowego, bez CMake, bez `src/`, bez plików deweloperskich

`generate_manifest.php` wyklucza te pliki z manifestu (filtry `src/`, `cmake/`, `*.cpp` itd.), ale to **obejście tymczasowe**. Właściwym rozwiązaniem jest workflow GHA (`build-client-package.yml`) który:

1. Kompiluje OTClient z vcpkg + CMake (Release)
2. Inject nasz `init.lua` (CLIENT_LOCKED, serwery, tryby gry)
3. Inject nasze zmodyfikowane moduły
4. Stripuje pliki deweloperskie
5. Pakuje ZIP + generuje manifest
6. Upload jako artefakt GHA

**Szczegóły:** patrz `2026-03-05_plan_2_agenty_copilot_codex.md` → Faza 4.7

---

## 3. Implementacja w generate_manifest.php

### Plik: `/var/www/html/apik/v1/generate_manifest.php`

### Funkcja `categorizeFile(path)`

```php
function categorizeFile(string $path): array {
    // 1. USER FILES — nie nadpisuj jeśli istnieją
    if ($path === 'otclientrc.lua' || str_starts_with($path, 'data/settings/')) {
        return ['managed' => true, 'overwritePolicy' => 'preserve_user'];
    }
    // 2. UNMANAGED — launcher w ogóle nie rusza
    if (str_starts_with($path, 'records/') || str_starts_with($path, 'screenshots/')) {
        return ['managed' => false, 'overwritePolicy' => 'never'];
    }
    // 3. Wszystko inne — zarządzane, aktualizowane przy różnicy hash
    return ['managed' => true, 'overwritePolicy' => 'if_hash_differs'];
}
```

### Funkcja `buildCriticalFilesList(files, patterns)`

Filtruje pliki z manifestu wg listy krytycznych ścieżek i zwraca `[{path, sha256}]`.

### Lista plików krytycznych

```php
$criticalFilePatterns = [
    'init.lua',
    'meta.lua',
    'modules/client_entergame/entergame.lua',
    'modules/client_entergame/characterlist.lua',
    'modules/client_serverlist/serverlist.lua',
    'modules/client_serverlist/addserver.lua',
    'modules/startup/startup.lua',
];
```

### Sekcja `criticalFiles[]` w manifeście

Dodana do outputu JSON manifestu:
```json
{
  "criticalFiles": [
    {"path": "init.lua", "sha256": "abc..."},
    {"path": "meta.lua", "sha256": "def..."},
    ...
  ]
}
```

---

## 4. Wyniki: manifest v1.0.2

Wygenerowany `2026-03-05`:

| Metryka | Wartość |
|---------|--------|
| **Pliki ogółem** | 7232 |
| **Pliki managed `if_hash_differs`** | 7230 |
| **Pliki `preserve_user`** | 1 (`otclientrc.lua`) |
| **Pliki unmanaged `never`** | 1 (`records/test1098.cam`) |
| **Pliki krytyczne (integrity check)** | 7 |

### 7 plików krytycznych:
1. `init.lua` — config serwerów, CLIENT_LOCKED, GameModes
2. `meta.lua` — metadane klienta
3. `modules/client_entergame/entergame.lua` — logika logowania
4. `modules/client_entergame/characterlist.lua` — lista postaci
5. `modules/client_serverlist/serverlist.lua` — lista serwerów
6. `modules/client_serverlist/addserver.lua` — dodawanie serwerów (zablokowane)
7. `modules/startup/startup.lua` — sekwencja startowa

---

## 5. Obsługa w Rust (istniejąca infrastruktura)

### Model: `common-models/src/manifest.rs`

```
OverwritePolicy:
  - Always         — zawsze nadpisuj
  - IfHashDiffers  — nadpisuj gdy hash inny (domyślny)
  - Never          — nigdy nie nadpisuj
  - PreserveUser   — nie nadpisuj jeśli plik istnieje

DeletePolicy:
  - Allow    — wolno usunąć
  - Protect  — nie usuwaj (domyślny)
  - OrphanCleanup — usuń pliki-sieroty

ManifestFileEntry:
  - managed: bool
  - overwrite_policy: OverwritePolicy
  - delete_policy: DeletePolicy
```

### Planner: `launcher-core/src/planner.rs`

Planner **już obsługuje** wszystkie polityki:
- `managed: false` → `to_keep` (pomijane)
- `OverwritePolicy::Never` → `to_keep` (pomijane)
- `OverwritePolicy::PreserveUser` → `to_keep` jeśli plik istnieje, pobierz jeśli nie
- `OverwritePolicy::IfHashDiffers` → pobierz jeśli hash inny

### Brakujące elementy (Faza 4.5 w planie):

| Element | Opis | Status |
|---------|------|--------|
| `CriticalFileEntry` struct w Rust | Parsowanie `criticalFiles[]` z manifestu | 🔧 do zrobienia |
| `verify_critical_files()` | Sprawdzanie SHA-256 krytycznych plików przed launch | 🔧 do zrobienia |
| `pre_launch_check` Tauri command | Wywołanie weryfikacji, zwrócenie statusu do frontendu | 🔧 do zrobienia |
| Blokada "Graj" w UI | Jeśli integrity check failed → blokada + "Napraw" | 🔧 do zrobienia |

---

## 6. Ścieżki plików

| Co | Gdzie |
|----|-------|
| PHP generator | `/var/www/html/apik/v1/generate_manifest.php` |
| Kopia w repo | `canary_test/html_copy/apik/v1/generate_manifest.php` |
| Manifest v1.0.2 | `/var/www/html/apik/v1/manifests/stable/1.0.2.json` |
| Manifest latest | `/var/www/html/apik/v1/manifests/stable/latest.json` |
| Symlink plików | `/var/www/html/apik/v1/files/stable/1.0.2/` → `canary_test/testyy/` |
| Rust manifest model | `launcher-rust/crates/common-models/src/manifest.rs` |
| Rust planner | `launcher-rust/crates/launcher-core/src/planner.rs` |
| Rust integrity | `launcher-rust/crates/launcher-core/src/integrity.rs` |

---

## 7. Jak dodać nowy plik krytyczny

1. Edytuj `$criticalFilePatterns` w `generate_manifest.php`
2. Regeneruj manifest: `sudo php generate_manifest.php /ścieżka/do/klienta <wersja> <kanał>`
3. Po implementacji Rust: dodaj ścieżkę do testu `test_critical_file_modified_blocks_launch`

## 8. Jak zmienić kategorię pliku

Edytuj funkcję `categorizeFile()` w `generate_manifest.php`:
- Dodaj warunek `str_starts_with($path, 'nowy/prefix/')` z odpowiednim `overwritePolicy`
- Regeneruj manifest
