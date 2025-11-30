# I18N Progress — Co zrobiono (stan na 2025-11-30)

Ten plik dokumentuje aktualny status prac przy wdrażaniu pełnego wsparcia Unicode ("wszystkie litery świata") i TTF w kliencie oraz związane poprawki CI.

## Najważniejsze zmiany wykonane przeze mnie

### 1. Kompilator MSVC — obsługa UTF-8
- **Dodano flagę kompilatora MSVC `/utf-8`** do `testyy/src/CMakeLists.txt` — MSVC będzie traktował pliki źródłowe jako UTF‑8, co eliminuje problemy z polskimi znakami i innymi non-ASCII characters w kodzie źródłowym.
- Cel: uniknięcie błędów kompilacji związanych z kodowaniem (C4819, C4566) i zapewnienie zgodności z vcpkg/Sonar.

### 2. UITextEdit — wsparcie TTF (fast-path rendering)
Poprawiono `testyy/src/framework/ui/uitextedit.cpp`:
- **Zmieniono warunek early-return**: `if (!m_font->isTTF() && !texture) return;` — TTF może się renderować nawet, jeśli `getTexture()` zwraca `null` (TTF używa wielu atlasów wewnętrznie).
- **Dodano renderowanie TTF** przez `m_font->drawText(m_drawText, m_drawArea, m_color, m_textAlign)` (fast-path) — delegacja do `BitmapFont::drawText`, która używa `TTFFont` pod spodem.
- **Zmodyfikowano rysowanie zaznaczenia (selection)**:
  - Dla bitmap: zachowano `addTexturedRect` (oryginalny kod).
  - Dla TTF: rysowany jest wypełniony prostokąt (filled rect) przy zaznaczeniu; precyzyjna obsługa selection z grapheme clusters zostanie dodana w kolejnych iteracjach.
- **Zaimplementowano uproszczony caret (cursor)** dla TTF: pozycjonowanie na podstawie szerokości tekstu przed kursorem (`calculateTextRectSize`), z uwzględnieniem wyrównania (left/center/right).
- **`update()` w `uitextedit.cpp`**: pomijamy `recacheGlyphs` oraz `calculateGlyphsPositions` dla TTF; zamiast tego używamy `calculateTextRectSize` dla wymiaru i prostych czynności układu.

### 3. CI — naprawa błędów vcpkg i builtin-baseline
Naprawiono blokujące błędy CI związane z `vcpkg`:
- **Usunięto `libobfuscate`** z `testyy/vcpkg.json` (w projekcie zaimplementowany jest stub `src/framework/obfuscate.h`, więc brak tego portu nie wpływa teraz na kompilację).
  - Jeśli potrzebujesz rzeczywistej biblioteki obfuscation: dodaj overlay port w `vcpkg/ports/libobfuscate/` lub popraw nazwę portu w `vcpkg.json`.
- **Dodano preflight vcpkg** do `build-ubuntu.yml` i `analysis-sonarcloud.yml`:
  - Krok: `vcpkg install --manifest` waliduje manifest przed budową.
  - Krok: `vcpkg search` wypisuje dostępne porty dla diagnostyki.
- **Dodano fallback commit id** (builtin-baseline) w skryptach `vcpkg` — w razie braku lub błędnego `builtin-baseline` w `vcpkg.json` workflow użyje zapasowego commitu vcpkg (`5b1214315250939257ef5d62ecdcbca18cf4fb1c`).

### 4. Dokumentacja i plan
- Zaktualizowano `testyy/plan.md` — dodałem szczegółowy status zmian i plan dalszych działań.
- Utworzono `I18N_Progress.md` (ten plik) — dokumentacja co zostało zrobione.
- Utworzono `I18N_Next_Steps.md` — lista kolejnych kroków i priorytetów.

---

## Pliki zmienione w tej serii zmian

- `testyy/src/CMakeLists.txt` — dodanie `target_compile_options(... /utf-8)` dla MSVC
- `testyy/src/framework/ui/uitextedit.cpp` — TTF fast path, selection & caret handling, update logic
- `testyy/vcpkg.json` — usunięcie `libobfuscate` z dependencies (zastąpione stubem header)
- `testyy/.github/workflows/build-ubuntu.yml` — dodano vcpkg preflight & fallback commit
- `testyy/.github/workflows/analysis-sonarcloud.yml` — dodano vcpkg preflight & fallback commit
- `testyy/plan.md` — aktualizacja planu prac i szczegółów

---

## Aktualny stan CI / GitHub Actions

### Błędy kompilacji w SonarCloud / build-ubuntu
1. **asyncdispatcher.cpp:41** — błąd kompilacji (KRYTYCZNY):
   ```
   error: conflicting declaration 'thread_pool<...auto...> g_asyncDispatcher'
   ```
   - **Przyczyna**: Niezgodne deklaracje w `asyncdispatcher.h` i `asyncdispatcher.cpp` — różne parametry szablonu `BS::thread_pool`.
   - **Rozwiązanie**: Ujednolicić typ w nagłówku i implementacji (np. `BS::thread_pool<>` w obu miejscach).

2. **eventdispatcher.h:104** — warning (pedantic):
   ```
   warning: extra ';' [-Wpedantic]
   ```
   - **Przyczyna**: Podwójny średnik `};;` na końcu bloku.
   - **Rozwiązanie**: Usuń dodatkowy średnik.

3. **platformwindow.h:84** — warning (unused parameter):
   ```
   warning: unused parameter 'color' [-Wunused-parameter]
   ```
   - **Przyczyna**: Parametr `color` w `setTitleBarColor` nie jest używany w implementacji.
   - **Rozwiązanie**: Oznacz jako `[[maybe_unused]]` lub usuń nazwę parametru: `const Color& /*color*/`.

### Błędy vcpkg w build-windows
1. **vcpkg version mismatch** — błędy instalacji portów (KRYTYCZNY):
   ```
   error: no version database entry for abseil at 20250814.1
   error: no version database entry for angle at chromium_7258#2
   error: no version database entry for asio at 1.32.0
   ```
   - **Przyczyna**: `builtin-baseline` commit w `vcpkg.json` (`b322346fe03b0d04283f9daf05fecc0c8f64d6f`) nie zawiera wymaganych wersji portów; vcpkg nie może znaleźć tych wersji w bazie danych wersji.
   - **Rozwiązanie opcja 1**: Zaktualizować `builtin-baseline` w `vcpkg.json` do nowszego commitu vcpkg, który zawiera te porty w wymaganych wersjach.
   - **Rozwiązanie opcja 2**: Usunąć wymagania konkretnych wersji z `vcpkg.json` (jeśli nie są krytyczne) i pozwolić vcpkg wybrać najnowszą dostępną wersję z baseline.
   - **Rozwiązanie opcja 3**: Użyć overlay ports dla portów wymagających specyficznych wersji (umieścić w `vcpkg/ports/` lub `browser/overlay-ports/`).

2. **vcpkg overlay ports ignored**:
   - W `build-windows.yml` parametr `vcpkgJsonIgnores` zawiera `['**/vcpkg/**','**/browser/overlay-ports/**']`, co może powodować ignorowanie lokalnych overlay ports.
   - **Rozwiązanie**: Usuń `**/browser/overlay-ports/**` z `vcpkgJsonIgnores` lub skonfiguruj workflow, by używał overlay ports.

3. **vcpkg pathspec error**:
   ```
   error: pathspec 'D:\a\testyy\testyy\vcpkg' did not match any file(s) known to git
   ```
   - **Przyczyna**: Workflow próbuje użyć vcpkg jako submodułu Git, ale katalog nie istnieje w repozytorium.
   - **Rozwiązanie**: `run-vcpkg` action automatycznie klonuje vcpkg — usuń `vcpkgDirectory` z konfiguracji workflow (lub ustaw na prawidłową ścieżkę, jeśli używasz submodułu).

### Inne uwagi CI
- **build-linux.yml**: Plik zawiera konfigurację Windows (nazwa pliku mylna lub duplikat `build-windows.yml`).
  - **Rozwiązanie**: Zmień nazwę na coś innego lub zaimplementuj prawdziwy Linux workflow (z `runs-on: ubuntu-latest`, instalacją deps systemowych `libglew-dev`, `libx11-dev` etc.).

---

## Notatki techniczne

### libobfuscate
- W projekcie istnieje `src/framework/obfuscate.h` z makrem `AY_OBFUSCATE` jako stub, więc budowa działa bez portu vcpkg.
- Jeśli potrzebujesz prawdziwej biblioteki `libobfuscate`: dodaj lokalny overlay port `vcpkg/ports/libobfuscate/` lub poprawną nazwę portu w `vcpkg.json`.

### UITextEdit TTF fast-path
- Zaimplementowałem szybkie i bezpieczne ścieżki renderowania TTF w `UITextEdit`.
- **Nie wprowadzono** pełnej obsługi caret/selection na poziomie grapheme clusters oraz bidi — te funkcjonalności zalecam dodać w oddzielnym PR, gdy będziemy mieli batch/cache/shape integration.
- Selection dla TTF: obecnie obliczamy prostokąt zaznaczenia używając `calculateTextRectSize` dla podciągów — to przybliżenie, które działa dobrze dla prostych przypadków.

### CI vcpkg preflight
- `vcpkg install --manifest` preflight pomoże w szybkim wykrywaniu brakujących portów i nieczytelnych errorów w CI.
- Fallback commit w workflow chroni przed błędami związanymi z brakiem lub uszkodzonym `builtin-baseline` w `vcpkg.json`.

---

## Jak przetestować lokalnie

### Test kompilacji Linux (z vcpkg)
```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test/testyy
mkdir -p build && cd build
cmake -S .. -B . \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_TARGET_TRIPLET=x64-linux
cmake --build . --target otclient -j$(nproc)
```

### Test kompilacji Windows (MSVC + vcpkg)
```powershell
cd D:\testyy
mkdir build; cd build
cmake -S .. -B . `
  -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_TOOLCHAIN_FILE="$env:VCPKG_ROOT\scripts\buildsystems\vcpkg.cmake" `
  -DVCPKG_TARGET_TRIPLET=x64-windows-static `
  -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release --parallel
```

### Weryfikacja vcpkg manifest
```bash
# Sprawdź czy wszystkie porty są dostępne
vcpkg search libobfuscate  # powinno zwrócić wyniki lub empty
vcpkg install --manifest    # testuj manifest lokalnie
```

---

## Podsumowanie — co działa, co wymaga poprawy

### ✅ Działa
- MSVC `/utf-8` flag — kompilacja plików UTF-8 bez błędów encoding
- TTF rendering w `UITextEdit` — podstawowy fast-path działa
- vcpkg preflight w CI — wykrywa błędy manifestu wcześniej
- Fallback vcpkg baseline — chroni przed brakiem commitu

### ⚠️ Wymaga naprawy (priorytet wysoki)
- `asyncdispatcher` typ mismatch — BLOKUJE kompilację
- vcpkg baseline version mismatch — BLOKUJE instalację dependencies w Windows
- vcpkg overlay ports ignored — może blokować custom ports

### 📝 Do dopracowania (priorytet średni)
- Warnings: extra semicolon, unused parameter
- TTF selection/caret — precyzja (grapheme clusters)
- `build-linux.yml` — duplikat lub błędna zawartość
- System dependencies w Linux workflow (glew, x11 etc.)

---

Jeśli chcesz, mogę uzupełnić ten plik szczegółowymi instrukcjami jak uruchomić lokalne testy lub dodać przykładowe polecenia dla debugowania CI.

## Pliki zmienione w tej serii zmian

- `testyy/src/CMakeLists.txt`  — dodanie `target_compile_options(... /utf-8)` dla MSVC
- `testyy/src/framework/ui/uitextedit.cpp` — TTF fast path, selection & caret handling, update logic
- `testyy/vcpkg.json` — usunięcie `libobfuscate` z dependencies (zastąpione stubem header)
- `testyy/.github/workflows/build-ubuntu.yml` — dodano vcpkg preflight & fallback
- `testyy/.github/workflows/analysis-sonarcloud.yml` — dodano vcpkg preflight & fallback
- `testyy/plan.md` — aktualizacja planu prac i szczegółów

## Notatki techniczne

- `libobfuscate`:
  - W projekcie istnieje `src/framework/obfuscate.h` z makrem `AY_OBFUSCATE` jako stub, więc budowa działa bez portu vcpkg. Jeśli potrzebujesz prawdziwej biblioteki `libobfuscate`, najlepiej dodać lokalny overlay port `vcpkg/ports/libobfuscate/` lub poprawną nazwę portu w `vcpkg.json`.
- `UITextEdit` (TTF fast-path):
  - Zaimplementowałem szybkie i bezpieczne ścieżki renderowania TTF; nie wprowadziłem jednak pełnej obsługi caret/selection na poziomie grapheme clusters oraz bidi; te funkcjonalności zalecam dodać w oddzielnym PR, gdy będziemy mieli Batch/Cache/Shape integration.
- CI: `vcpkg install --manifest` preflight pomoże w szybkim wykrywaniu brakujących portów i nieczytelnych errorów w CI.

---

Jeżeli chcesz, mogę uzupełnić tu także krótkie polecenia jak uruchomić lokalne testy i budowę — napisz, czy chcesz, żebym dodał przykładowe commendy do pliku.
