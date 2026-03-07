# 2026-02-14 - Audit i18n klienta vs oryginal + wplyw na CI (Windows/Android)

## 1) Korekta baz i zakres

Korekta po uwadze: "oryginal" traktujemy jako katalog `Tibia/silnik/canary`.

Twarde fakty:
1. `canary` to kod serwera, nie klienta OTClient.
2. W `canary` brakuje plikow build klienta:
   - `canary/.github/workflows/build-windows.yml` (brak)
   - `canary/.github/workflows/build-android.yml` (brak)
   - `canary/src/framework/otml/otmlparser.cpp` (brak)

Wniosek:
- dla kompilacji Windows/Android klienta nie da sie wykonac pelnego diffu "client build vs canary", bo `canary` nie zawiera klienta.
- praktyczny baseline klienta to snapshot: `Tibia/silnik/canary_test/oryginall/otclient`.
- dodatkowy baseline z oficjalnego upstream:
  - `Dokumentacja/2026-02-14_testyy_vs_opentibiabr_otclient_dokladne_porownanie.md`

## 2) Baseline CI (zweryfikowane)

Weryfikacja przez GitHub Actions API: `2026-02-14 22:41 UTC`.

1. Ostatni udany `build-windows.yml`:
- Run ID: `21802468391`
- SHA: `0a34ffb490b9a1b0b74256d69f87adf3c9394915`
- Czas startu: `2026-02-08T17:40:52Z`
- URL: https://github.com/PtakuPL/ooo/actions/runs/21802468391

2. Ostatni nieudany `build-windows.yml`:
- Run ID: `22024533938`
- SHA: `d7e1747279e0f4ed86cea02872cda94e33e48afa`
- Czas startu: `2026-02-14T21:26:56Z`
- URL: https://github.com/PtakuPL/ooo/actions/runs/22024533938

3. Ostatni nieudany `build-android.yml`:
- Run ID: `22023855055`
- SHA: `b69e05a733b2f1f9b22764fe648f63f435f73285`
- Czas startu: `2026-02-14T20:34:25Z`
- URL: https://github.com/PtakuPL/ooo/actions/runs/22023855055

Uwaga:
- dla Android w ostatnich 100 runach tego workflow nie znaleziono runu z `conclusion=success`.

## 3) Dokladne roznice: Windows success vs Windows fail

Porownanie SHA:
- `0a34ffb490b9a1b0b74256d69f87adf3c9394915..d7e1747279e0f4ed86cea02872cda94e33e48afa`

### 3.1 Workflow Windows

`git diff --name-status ... -- .github/workflows/build-windows.yml`

Wynik:
- brak zmian w `build-windows.yml`.

### 3.2 Zmiany build-related (dokladna lista)

`git diff --name-status ... -- .github/workflows/build-android.yml Tibia/silnik/canary_test/testyy/src/CMakeLists.txt Tibia/silnik/canary_test/testyy/src/framework/luaengine/luainterface.h Tibia/silnik/canary_test/testyy/src/framework/otml/otmlnode.cpp Tibia/silnik/canary_test/testyy/src/framework/otml/otmlparser.cpp Tibia/silnik/canary_test/testyy/src/framework/stdext/cast.h`

Wynik:
1. `M .github/workflows/build-android.yml`
2. `M Tibia/silnik/canary_test/testyy/src/CMakeLists.txt`
3. `M Tibia/silnik/canary_test/testyy/src/framework/luaengine/luainterface.h`
4. `M Tibia/silnik/canary_test/testyy/src/framework/otml/otmlnode.cpp`
5. `M Tibia/silnik/canary_test/testyy/src/framework/otml/otmlparser.cpp`
6. `M Tibia/silnik/canary_test/testyy/src/framework/stdext/cast.h`

Stat:
- `219 insertions(+), 56 deletions(-)` na tych 6 plikach.

### 3.3 Punkt awarii Windows (latest fail)

Z logu runu `22024533938`:
1. `otmlparser.cpp(47)` -> `fatal error C1001` (MSVC Internal Compiler Error)
2. `otmlnode.cpp(70)` -> `fatal error C1001`
3. `ninja: build stopped: subcommand failed`
4. `Access violation`

Wniosek:
- to nadal ICE kompilatora MSVC na TU `otmlparser.cpp` i `otmlnode.cpp`.

## 4) Porownanie klienta: aktualny `testyy` vs oryginalny `oryginall/otclient`

To porownanie jest potrzebne, bo samo `canary` nie zawiera klienta.

Najwazniejsze roznice:

1. Workflowy klienta:
- `build-windows.yml` i `build-android.yml` sa mocno przebudowane (nowe runnery, cache, vcpkg, inne kroki build/test/artifacts).

2. `src/CMakeLists.txt`:
- duzy zakres zmian: nowe opcje feature-flag, przebudowa targetu, rozszerzenia dependency stack, workaroundy MSVC ICE, zmiany dla Android/WASM.

3. OTML:
- `otmlparser.cpp` i `otmlnode.cpp` mocno przepisane (m.in. `std::string_view`, zmiany struktur i obslugi bledow).

4. Dodatkowe zmiany runtime:
- `cast.h`, `luainterface.h`, `luavaluecasts.cpp`, `game.cpp`, `stdext/string.cpp`.

Wniosek:
- aktualny kod jest istotnie oddalony od oryginalnego klienta, a roznice wykraczaja poza samo i18n.

## 5) Weryfikacja hipotezy ".cpp/.h niezgodne" i "harfbuzz/stduuid"

1. `SOURCE_FILES` w `Tibia/silnik/canary_test/testyy/src/CMakeLists.txt`:
- wpisy `.h/.hpp`: brak
- wpisy `.c`: brak
- wpisy `.cpp`: 173

2. To oznacza, ze build nie kompiluje headerow jako osobnych TU.

3. Bledy nie sa typu "missing file/include":
- nie ma symptomu `C1083` w znanych logach faili.

4. HarfBuzz/stduuid:
- obecny punkt awarii to ICE na `otml*`, nie blad braku biblioteki/linkera.
- hipoteza "brak .h/.cpp dla harfbuzz/stduuid" nie ma teraz twardego potwierdzenia.

## 6) Zmiana jezyka runtime (czy potrzebny restart)

Aktualna sciezka:
1. `setLocale(...)` zapisuje locale w settings.
2. `g_fonts.clearAllFontCaches()` czysci cache fontow.
3. `g_modules.reloadModules()` przeladowuje moduly.

Wniosek:
- standardowa zmiana jezyka nie wymaga restartu aplikacji.

## 7) Co dalej (krotko)

1. Android:
- naprawic wyciek `$<...>` do `build.ninja` w linkowaniu (OpenSSL/CMake target linking).

2. Windows:
- zawezac i uproscic `otmlparser.cpp` i `otmlnode.cpp` pod MSVC, bo tam pozostaje `C1001`.

3. Dokumentacja:
- kontynuowac dopisywanie run ID + SHA + pierwszy blad po kazdej iteracji.
