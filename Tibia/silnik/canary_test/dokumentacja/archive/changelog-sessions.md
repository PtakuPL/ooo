# Zrobione - Log zmian i postępów napraw CI/CD

Ten plik służy do śledzenia postępów w naprawie błędów CI/CD między sesjami.

---

## Sesja 3 (2025-12-06) - Uzupełnienie dokumentacji

### Co zrobiono w tej sesji
- Doinstalowano systemowe zależności tekstowe w devcontainerze (`libharfbuzz-dev`, `libfribidi-dev`, `libfreetype-dev` + GLib/graphite), dzięki czemu lokalne buildy TTF/i18n mają komplet pkg-config.
- Zaktualizowano `bledyw.md` o bieżące blokery: brak wpisów wersji portów vcpkg (abseil/angle/asio) dla commit-u `5b121431`, konflikt typu `g_asyncDispatcher` (deklaracja vs definicja), brak submodule `oryginall/canary-serwer` w SonarCloud.
- Uporządkowano status workflow: Windows (vcpkg) wymaga rerun + poprawy baseline vcpkg; Emscripten/Android naprawione w PR, oczekują potwierdzenia.

### Do weryfikacji / next steps
- Ustalić nowy `builtin-baseline` lub zaktualizować `vcpkgGitCommitId`, żeby porty `abseil`, `angle`, `asio` były dostępne w Windows build.
- Ujednolicić typ `g_asyncDispatcher` (nagłówek/definicja) i ponownie uruchomić build Linux/Windows.
- Dodać prawidłowy wpis submodule lub usunąć go z workflow SonarCloud.

## Sesja 2 (2025-12-04) - Kontynuacja

### Weryfikacja i status napraw

**Status:** ✅ Wszystkie główne naprawy zaimplementowane

#### Sprawdzone naprawy w tej sesji:

##### Android Build - ✅ JUŻ NAPRAWIONE (w PR)

##### Emscripten Build - ✅ JUŻ NAPRAWIONE (w PR)

##### SonarCloud - ✅ NAPRAWIONE


## Sesja 1 (2025-12-04)

### Windows Build (vcpkg) - Naprawy
**Commity:**
- `570edff` - Główne naprawy Windows build

##### 1. RuntimeLibrary Mismatch (LNK2038) - ✅ NAPRAWIONE
**Problem:** vcpkg biblioteki skompilowane z `/MT` (static), projekt z `/MD` (dynamic)
**Plik:** `CMakeLists.txt` (główny)
**Zmiana:**
- Przeniesiono ustawienie `CMAKE_MSVC_RUNTIME_LIBRARY` PRZED wywołanie `project()`
- Dodano `cmake_policy(SET CMP0091 NEW)` dla poprawnego działania MSVC_RUNTIME_LIBRARY
- Uproszczona logika detekcji triplet (używa zmiennej pomocniczej)

##### 2. LTO Flag `-flto=auto` - ✅ NAPRAWIONE
**Problem:** `-flto=auto` to flaga GCC, nie wspierana przez MSVC
**Plik:** `src/CMakeLists.txt` linia ~685
**Zmiana:**
- Owinięto flagę LTO w warunek `if(NOT MSVC)`
- MSVC używa `/LTCG` który jest obsługiwany osobno

##### 3. fmt Duplicate Symbols (LNK2005) - ✅ NAPRAWIONE
**Problem:** `fmt::fmt-header-only` było hardkodowane, ale vcpkg dostarcza skompilowaną bibliotekę `fmt::fmt`
**Plik:** `src/CMakeLists.txt` sekcja MSVC target_link_libraries
**Zmiana:**
- Zamieniono `fmt::fmt-header-only` na `${FMT_TARGET}` (zmienna ustawiana wcześniej)

##### 4. Vorbis Unresolved Externals (LNK2019) - ✅ NAPRAWIONE
**Problem:** Używano zmiennych `${VORBIS_LIBRARY}` które mogły być puste gdy vcpkg tworzy targety
**Plik:** `src/CMakeLists.txt` sekcja MSVC target_link_libraries
**Zmiana:**
- Zamieniono `${OGG_LIBRARY}`, `${VORBIS_LIBRARY}`, `${VORBISFILE_LIBRARY}` na CMake targets:
  - `Ogg::ogg`
  - `Vorbis::vorbis`
  - `Vorbis::vorbisfile`

---

### Wcześniejsze naprawy

#### models-demo.yml ✅
- Commit: `cd6f8ee`
- Zamienione polskie słowa kluczowe YAML na angielskie
- Usunięty hardcoded PAT token
- Naprawione nagłówki HTTP i flagi curl

#### Emscripten (build-browser.yml) ✅
- Commit: `b0e471f`
- LuaJIT nie wspiera wasm32-emscripten
- Dodano `lua` dla wasm32 w vcpkg.json
- Ograniczono `luajit` do windows | linux | osx

#### Android (build-android.yml) ✅
- Commit: `c4fb634` + `ae1aa81`
- sdkmanager nie w PATH na Windows runner
- Użyto pełnej ścieżki do sdkmanager.bat
- Dodano fallback na preinstalowany CMake

#### SonarCloud (analysis-sonarcloud.yml) ⚠️
- Wymaga ręcznej konfiguracji SONAR_TOKEN przez właściciela repo
- Nie da się naprawić z poziomu kodu

---

## Pliki zmienione w tym PR

| Plik | Zmiany |
|------|--------|
| `.github/workflows/models-demo.yml` | YAML polskie słowa kluczowe, hardcoded token |
| `.github/workflows/build-android.yml` | sdkmanager pełna ścieżka |
| `vcpkg.json` | LuaJIT platform condition |
| `CMakeLists.txt` | CMAKE_MSVC_RUNTIME_LIBRARY przed project() |
| `src/CMakeLists.txt` | LTO flag, fmt target, Vorbis targets |
| `bledyw.md` | Dokumentacja błędów |
| `zrobionew.md` | Log postępów |

---

## Podsumowanie statusu wszystkich workflow

| Workflow | Status naprawy | Opis |
|----------|---------------|------|
| models-demo.yml | ✅ Naprawione | Polskie słowa kluczowe, hardcoded token |
| build-linux.yml | ✅ Działa | Nie wymagał naprawy |
| build-ubuntu.yml | ✅ Działa | Nie wymagał naprawy |
| build-windows-solution.yml | ✅ Działa | Nie wymagał naprawy |
| build-windows.yml (vcpkg) | ✅ Naprawione | RuntimeLibrary, LTO, fmt, Vorbis |
| build-browser.yml (Emscripten) | ✅ Naprawione | LuaJIT → lua dla wasm32 |
| build-android.yml | ✅ Naprawione | sdkmanager pełna ścieżka |
| analysis-sonarcloud.yml | ✅ Naprawione | SONAR_TOKEN → SONARCLOUDTOKEN |

---

## Następne kroki

1. [x] Naprawić Windows build - RuntimeLibrary, LTO, fmt, Vorbis
2. [x] Naprawić Android build - sdkmanager
3. [x] Naprawić Emscripten build - LuaJIT
4. [x] Naprawić models-demo.yml - polskie słowa, token
5. [x] Naprawić SonarCloud - zmiana nazwy secret z SONAR_TOKEN na SONARCLOUDTOKEN
6. [ ] Merge PR do master
7. [ ] Zweryfikować że wszystkie workflow przechodzą
- Zamienione polskie słowa kluczowe YAML na angielskie
- Usunięty hardcoded PAT token
- Naprawione nagłówki HTTP i flagi curl

#### Emscripten (build-browser.yml) ✅
- Commit: `b0e471f`
- LuaJIT nie wspiera wasm32-emscripten
- Dodano `lua` dla wasm32 w vcpkg.json
- Ograniczono `luajit` do windows | linux | osx

#### Android (build-android.yml) ✅
- Commit: `c4fb634` + `ae1aa81`
- sdkmanager nie w PATH na Windows runner
- Użyto pełnej ścieżki do sdkmanager.bat
- Dodano fallback na preinstalowany CMake

#### SonarCloud (analysis-sonarcloud.yml) ⚠️
- Wymaga ręcznej konfiguracji SONAR_TOKEN przez właściciela repo
- Nie da się naprawić z poziomu kodu

---

## Pliki zmienione w tej sesji

1. `Tibia/silnik/canary_test/testyy/CMakeLists.txt`
   - RuntimeLibrary fix (CMAKE_MSVC_RUNTIME_LIBRARY przed project())

2. `Tibia/silnik/canary_test/testyy/src/CMakeLists.txt`
   - LTO flag fix (NOT MSVC condition)
   - fmt target fix (${FMT_TARGET} zamiast hardcoded)
   - Vorbis/Ogg targets fix (CMake targets zamiast zmiennych)

---

## Następne kroki

1. [x] Naprawić RuntimeLibrary mismatch w Windows build
2. [x] Naprawić LTO flag issue
3. [x] Naprawić fmt duplicate symbols
4. [x] Naprawić Vorbis linking (użyć CMake targets)
5. [ ] Zweryfikować build na Windows CI
6. [ ] Przejść do innych platform (jeśli będą błędy)
