# 2026-02-14 — Build Windows: dokładne różnice (ostatni success vs ostatni fail) + aktualny plan naprawczy

## 1) Zakres porównania

Porównanie wykonane dla:

1. Ostatni **udany** run `Build - Windows`
- Run ID: `21802468391`
- Data: `2026-02-08 17:40:52 UTC`
- SHA: `0a34ffb490b9a1b0b74256d69f87adf3c9394915`
- URL: https://github.com/PtakuPL/ooo/actions/runs/21802468391

2. Ostatni **nieudany** run `Build - Windows`
- Run ID: `22020364224`
- Data: `2026-02-14 16:08:58 UTC`
- SHA: `47f655b53f8ed3fd97fc7d839d56b26dfaf21ffb`
- URL: https://github.com/PtakuPL/ooo/actions/runs/22020364224

## 2) Twarde dane z najnowszego fail run (`22020364224`)

Błąd kompilacji w kroku `Build`:

1. `framework/otml/otmlnode.cpp`
- `fatal error C1001` w `otmlnode.cpp(69)`
- `FAILED: ... otmlnode.cpp.obj`

2. `framework/otml/otmlparser.cpp`
- `fatal error C1001` w `otmlparser.cpp(35)`
- `FAILED: ... otmlparser.cpp.obj`
- ostrzeżenie: `D9025 overriding '/O1' with '/Od'`

3. Koniec joba:
- `ninja: build stopped: subcommand failed.`
- `Access violation`
- exit code `1`

## 3) Dokładna różnica workflow (success SHA vs latest fail SHA)

Porównanie pliku workflow:
- `canary_test/testyy/.github/workflows/build-windows.yml`

Wynik:
- **Brak różnic** między SHA `0a34ffb...` i `47f655b...`.
- To oznacza, że problem nie wynika z różnicy w samym workflow Windows.

## 4) Dokładne różnice w kodzie (success SHA vs latest fail SHA)

Zmodyfikowane pliki, które weszły między `0a34ffb...` -> `47f655b...` i dotyczą obszaru awarii:

1. `canary_test/testyy/src/CMakeLists.txt`
- Przebudowa sekcji MSVC (warunkowanie pod `CMAKE_CXX_COMPILER_ID STREQUAL "MSVC"`)
- Per-file flags:
  - `luavaluecasts.cpp`, `otmlparser.cpp`, `uiwidgetbasestyle.cpp`
  - `COMPILE_FLAGS "/Od /d2SSAOptimizer-"`
  - `SKIP_PRECOMPILE_HEADERS ON`
- Czyszczenie `/GL` i `/LTCG` we flagach.

2. `canary_test/testyy/src/framework/stdext/cast.h`
- `_MSC_VER`: uproszczone `safe_cast/unsafe_cast` (noinline + `runtime_error`) bez demangle w ścieżce błędu.

3. `canary_test/testyy/src/framework/luaengine/luainterface.h`
- `_MSC_VER`: fallback tekstowy zamiast `demangle_type<T>()` w `LuaBadValueCastException`.

4. `canary_test/testyy/src/framework/otml/otmlnode.h`
- `_MSC_VER`: osobna ścieżka błędu dla `value<T>()` (bez demangle typu).

5. `canary_test/testyy/src/framework/luaengine/luavaluecasts.cpp`
- `bool -> string`: z `unsafe_cast` na jawne `"true"/"false"`.

## 5) Co zostało poprawione teraz (po analizie latest fail)

Wprowadzono poprawki robocze pod latest fail `22020364224`:

1. `canary_test/testyy/src/CMakeLists.txt`
- Dodany `framework/otml/otmlnode.cpp` do per-file workaround MSVC.
- Wzmocnione flagi per-file:
  - z `"/Od /d2SSAOptimizer-"`
  - na `"/Od /Ob0 /Oy- /d2SSAOptimizer-"`
- Usunięte `.h` z `SOURCE_FILES` (czyszczenie niespójności listy źródeł):
  - `framework/core/unzipper.h`
  - `framework/platform/androidmanager.h`
  - `framework/platform/androidwindow.h`

2. `canary_test/testyy/src/framework/otml/otmlnode.cpp`
- Uproszczenie kodu pod MSVC (m.in. lżejsza ścieżka wyjątków, mniej template-heavy operacji).
- Zamiana `std::ranges::find` -> `std::find` w miejscach newralgicznych.

3. `canary_test/testyy/src/framework/otml/otmlparser.cpp`
- Uproszczenia parsera redukujące presję na template/optimizer MSVC.

4. `canary_test/testyy/src/framework/otml/otmlnode.h`
- Dalsze odchudzenie ścieżki `_MSC_VER`: bez `fmt::format` dla cast-error (składanie stringa bezpośrednio).

## 6) Dodatkowy audit pod "wszystkie litery świata" (Unicode)

Sprawdzone ostatnio ruszane pliki klienta pod ryzyko psucia UTF-8 i operacji byte-wise.

Wykryte i poprawione:

1. `canary_test/testyy/src/client/game.cpp`
- `formatCreatureName` robiło `std::toupper` po `char` (byte-wise), co mogło uszkadzać UTF-8 dla znaków spoza ASCII.
- Zmienione na `stdext::ucwords(formatedName)` (operacja na codepointach UTF-8).

2. `canary_test/testyy/src/framework/stdext/string.cpp`
- `eraseWhiteSpace` używało `isspace` bez bezpiecznego castu.
- Zmienione na lambdę z `unsigned char` + `std::isspace(...) != 0`.

Dodatkowo zweryfikowano:
- po zmianach brak bezpośrednich `std::toupper/std::tolower` na surowym `char` poza kontrolowaną ścieżką ASCII (`cp < 128`) w `stdext/string.cpp`.

## 7) Plan naprawczy (zadania i podpunkty) — doprowadzenie `Build - Windows` do green

## Zadanie A — Walidacja latest hotfix

1. Uruchomić ręcznie `Build - Windows` na branchu z aktualnymi poprawkami.
2. Sprawdzić w logu build:
- czy `otmlnode.cpp` kompiluje się z `/Od /Ob0 /Oy- /d2SSAOptimizer-`
- czy ma `SKIP_PRECOMPILE_HEADERS ON` (brak `/Yu...` dla tego TU)
3. Potwierdzić, że pierwszy błąd C1001 (jeśli wystąpi) nie jest już w `otmlnode.cpp` / `otmlparser.cpp`.

## Zadanie B — Iteracyjna stabilizacja TU (tylko gdy dalej C1001)

1. Brać **pierwszy** padający TU z logu.
2. Dodać go do per-file workaround MSVC (`/Od /Ob0 /Oy- /d2SSAOptimizer-`, `SKIP_PRECOMPILE_HEADERS ON`).
3. Nie rozlewać zmian globalnie; robić minimalne, celowane poprawki.

## Zadanie C — Utrzymanie spójności źródeł `.cpp/.c/.h`

1. Trzymać tylko pliki kompilowalne (`.cpp/.c/.rc`) w `SOURCE_FILES`.
2. Nagłówki zostawiać poza listą kompilacji.
3. Kontrolować przypadki `#include "*.c"` (są 2 użycia, intencjonalne), ale nie rozszerzać tego wzorca.

## Zadanie D — Unicode safety (równolegle)

1. Dla operacji case/trim unikać byte-wise transformacji na `char`.
2. W miejscach formatowania tekstu UI używać ścieżki UTF-8 (`utf8ToU32`/`u32ToUtf8`).
3. Każdy nowy helper tekstowy: jawnie określić, czy działa na bajtach, czy na codepointach.

## 8) Definition of Done

1. Nowy run `Build - Windows` zakończony `success`.
2. Brak `fatal error C1001` w logach kompilacji.
3. Artefakt Windows wygenerowany (`Create and Upload Artifact` = success).
4. Potwierdzenie, że `formatCreatureName` nie uszkadza UTF-8 dla znaków spoza ASCII.
