
---

## 28. Wdrozenie napraw (2026-02-22, Codex)

### 28.1 Co wdrozone teraz (kod + build-system)

1. `C2` z sekcji 27.3 - ZREALIZOWANE:
`framework/luaengine/luaexception.cpp` zostal dodany do silnej ochrony MSVC (Group 2) w
`canary_test/testyy/src/CMakeLists.txt`.

2. `I2` z sekcji 27.3 - ZREALIZOWANE:
usunieto ciezka zaleznosc `luaexception.cpp -> luainterface.h`.
Wprowadzono lekki interfejs runtime:
- `clearLuaExceptionStack()`
- `luaExceptionTraceback(...)`
z deklaracja w `luaexception.h` i implementacja w `luainterface.cpp`.

3. `I1` (faza 26.3, throw-path extraction) - CZESCIOWO ZREALIZOWANE:
w `luavaluecasts.h` przeniesiono throw-y z templated lambd do helperow non-template:
- `throwExpiredLuaFunction()`
- `throwLuaBadReturnCount()`
oraz wyciagnieto logowanie do `logLuaCallbackError(...)`.

4. Correctness fix (z mapy bledow Linux/MSVC) - ZREALIZOWANE:
naprawiono bug `luavalue_cast(std::pair<...>)` (`!luavalue_cast` -> `luavalue_cast`) w `luavaluecasts.h`.

5. `C1` (faza 26.3, rozszerzenie ochron CMake) - CZESCIOWO ZREALIZOWANE:
- Group 4 podniesione do pelnej ochrony (`/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` + `SKIP_PRECOMPILE_HEADERS ON`)
- Dodane Group 5 (text/glyph stack): `TTFFont.cpp`, `TextShaper.cpp`, `LocaleShaping.cpp`,
  `bitmapfont.cpp`, `cachedtext.cpp`, `fontmanager.cpp`
- Dodane Group 6 (UI text): `uiwidgettext.cpp`, `uitextedit.cpp`
- Dodane Group 7 (core+ranges): `resourcemanager.cpp`, `module.cpp`

### 28.2 Rejestr plikow sprawdzonych po wdrozeniu (status 100%)

| Plik | Status | Uwaga |
|---|---:|---|
| `canary_test/testyy/src/framework/luaengine/luaexception.h` | 100% | nowe deklaracje helperow i runtime hooks |
| `canary_test/testyy/src/framework/luaengine/luaexception.cpp` | 100% | brak include `luainterface.h`, helpery zdefiniowane 1x |
| `canary_test/testyy/src/framework/luaengine/luainterface.h` | 100% | usuniete duplikowanie deklaracji `throwLuaBadValueCast` |
| `canary_test/testyy/src/framework/luaengine/luainterface.cpp` | 100% | implementacja lekkiego runtime API dla exception path |
| `canary_test/testyy/src/framework/luaengine/luavaluecasts.h` | 100% | throw extraction + fix `pair` cast |
| `canary_test/testyy/src/CMakeLists.txt` | 100% | rozszerzone grupy ochron MSVC 2/4/5/6/7 |

### 28.3 Co jeszcze zostaje po tej iteracji

1. Pelne domkniecie `C1`:
decyzja o `client/shadermanager.cpp` (martwy plik vs dolaczenie do SOURCE).
2. Pelne domkniecie `T1`:
guardy `#ifdef OTC_ENABLE_*` w `TextShaper.h`, `TTFFont.h`, `bitmapfont.h` i odpowiadajacych `.cpp`.
3. Walidacja efektu tylko na GitHub Actions:
po pushu sprawdzic nowy pierwszy fail-point Windows (czy C1001 opuscil `luaexception.cpp`).

### 28.4 Uwagi wykonawcze

1. Nie wykonywano lokalnej kompilacji (zgodnie z ustaleniem: buildy tylko na GitHub Actions).
2. Biezace runy Windows byly `in_progress` podczas wdrazania, wiec ocena finalnego efektu wymaga nowego gate po pushu tych zmian.
