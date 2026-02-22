# PLAN NAPRAWY / POPRAWY PLIKÓW — MSVC ICE C1001 + Correctness

**Data**: 2026-02-22
**Autor**: Agent A (Copilot) — synteza z pełnego audytu 376 plików (Sekcje 17-26)
**Cel**: Jeden dokument wykonawczy — co, gdzie, dlaczego i w jakiej kolejności naprawiamy

---

## SPIS TREŚCI

1. [Diagnoza — co się dzieje i dlaczego](#1-diagnoza)
2. [Mapa wszystkich problemów](#2-mapa-problemów)
3. [Plan naprawy — 6 faz](#3-plan-naprawy)
4. [Szczegółowe instrukcje per plik](#4-instrukcje-per-plik)
5. [Kolejność commitów i walidacja CI](#5-kolejność-commitów)
6. [Definicja sukcesu](#6-definicja-sukcesu)

---

## 1. DIAGNOZA

### Co się dzieje?

MSVC 14.44+ (Visual Studio 2022, GitHub Actions `windows-latest`) wywala **Internal Compiler Error (ICE) C1001** podczas kompilacji projektu OTClient. Błąd pochodzi z backendu kompilatora (`p2/main.cpp:258`) — crashuje SSA optimizer i/lub FH4 exception handler przy przetwarzaniu ciężkich template TU.

### Dlaczego?

**Wzorzec whack-a-mole**: Gdy naprawiamy jeden plik (np. dodamy `#pragma optimize off`), ICE przenosi się do następnego ciężkiego TU. To dowodzi, że problem nie jest w jednym konkretnym pliku — to **kumulacyjna presja template** na kompilator MSVC P2 phase.

### Główne źródła presji:

| Czynnik | Skala | Dlaczego groźny |
|---------|-------|-----------------|
| `luainterface.h` include chain | 26 TU × 1442 ln szablonów | Każdy TU dostaje ~1442 linii template definitions |
| `throw` w template lambda body | 3 miejsca × 26 TU | MSVC P2 crashuje na throw+catch w variadic template lambda |
| `std::ranges` w ciężkich TU | 23× w uiwidget.cpp, 4× w resourcemanager.cpp | MSVC 14.44 ma regression w ranges codegen |
| HarfBuzz/FriBidi w include chain | 6+ TU bez ochrony | ~20K linii external headers propagowanych bezwarunkowo |
| Brak ochrony CMake | 8+ ciężkich plików | Kompilowane z pełnym /O2 zamiast /Od |

---

## 2. MAPA WSZYSTKICH PROBLEMÓW

### 2.1 Problemy powodujące ICE C1001 (build failure)

#### 🔴 ICE-1: throw LuaException w template lambda body
- **Plik**: `framework/luaengine/luavaluecasts.h`
- **Linie**: 300, 340, 343
- **Opis**: 3× `throw LuaException(...)` wewnątrz variadic template lambda `luavalue_cast<std::function<...>>`
- **Mechanizm**: MSVC P2 codegen crashuje na throw+catch w template lambda, zwłaszcza z FH4 exception handling. Każdy z 26 TU includzujących `luainterface.h` instantiuje te szablony.
- **Dowód**: Wzorzec jest identyczny jak w luabinder.h, gdzie `throwLuaNilMemberCall()` został już wyciągnięty (i zadziałało).

#### 🔴 ICE-2: Bezwarunkowe #include HarfBuzz/FriBidi
- **Plik**: `framework/text/TextShaper.h` (linie 7-9)
- **Rozprzestrzenianie**: TextShaper.h → TTFFont.h → bitmapfont.h → cachedtext.cpp, fontmanager.cpp, uitextedit.cpp, etc.
- **Opis**: `#include <hb.h>`, `<hb-ft.h>`, `<fribidi.h>` bez `#ifdef OTC_ENABLE_*` guard. HarfBuzz to ~15K linii headers, FriBidi ~5K — ciągnięte do 6+ TU.
- **Mechanizm**: Zwiększa presję na P2 phase — więcej kodu do optymalizacji w każdym TU.

#### 🔴 ICE-3: uiwidget.cpp — najcięższy niechroniony TU
- **Plik**: `framework/ui/uiwidget.cpp` (2189 linii)
- **CMake Group**: 4 (TYLKO `/d2SSAOptimizer-` — najlżejsza ochrona!)
- **Opis**: 23× `std::ranges` + 29× `callLuaField<T>` template instantiation + include `luainterface.h` (549+ ln szablonów)
- **Mechanizm**: Group 4 nie daje `/Od /Ob0 /d2FH4- /d2notypeopt` — kompilator próbuje optymalizować 2189 linii z setkami template instances

#### 🟠 ICE-4: protocolgameparse.cpp — NAJWIĘKSZY plik, słaba ochrona
- **Plik**: `client/protocolgameparse.cpp` (6223 linie!)
- **CMake Group**: 4 (TYLKO `/d2SSAOptimizer-`)
- **Opis**: Największy plik w codebase. 48× fmt/g_logger, 11× throw, include luavaluecasts_client.h
- **Mechanizm**: Sam rozmiar TU + fmt template pressure przy minimalnej ochronie

#### 🟠 ICE-5: 8 plików text/UI stack BEZ jakiejkolwiek ochrony CMake
- **Pliki bez ochrony**: TTFFont.cpp (602 ln, 14× fmt), TextShaper.cpp (245), LocaleShaping.cpp (404), bitmapfont.cpp (896 ln, 11× fmt), cachedtext.cpp (254), fontmanager.cpp (120), uiwidgettext.cpp (265), uitextedit.cpp (1145)
- **Suma**: 3931 linii kompilowanych z PEŁNYM `/O2` (po zmianie globalnej na `/O1`, ale bez per-file protection)
- **Mechanizm**: Te pliki ciągną HarfBuzz/FriBidi headers + fmt, kompilowane bez żadnych MSVC workaroundów

#### 🟡 ICE-6: resourcemanager.cpp — ranges + luainterface bez ochrony
- **Plik**: `framework/core/resourcemanager.cpp` (806 ln)
- **CMake Group**: ❌ BRAK
- **Opis**: 4× `std::ranges` + include `luainterface.h` (549+ ln szablonów) + `<ranges>` header
- **Mechanizm**: Dodatkowa presja template+ranges bez żadnej ochrony

### 2.2 Bugi logiczne (nie powodują ICE, ale psują runtime)

#### 🟡 BUG-1: Odwrócona logika pair luavalue_cast
- **Plik**: `framework/luaengine/luavaluecasts.h`, linie 569, 576
- **Opis**: `if (!luavalue_cast(-1, value)) pair.first = value;` — negacja `!` powoduje przypisanie wartości przy NIEPOWODZENIU castowania
- **Naprawa**: Usunąć `!`

#### 🟡 BUG-2: Position::operator< — nie jest lexicographic strict-weak-order
- **Plik**: `client/position.h`, linia 253
- **Opis**: `x < other.x || y < other.y || z < other.z` — to nie jest prawidłowy porządek leksykograficzny. Powinno być: `x < other.x || (x == other.x && (y < other.y || (y == other.y && z < other.z)))`
- **Skutek**: `std::map<Position>` i `std::set<Position>` mogą działać niepoprawnie

#### 🟡 BUG-3: UIGraph::onStyleApply — niezgodność sygnatury z bazą
- **Pliki**: `client/uigraph.h:77`, `framework/ui/uiwidget.h:273`
- **Opis**: `UIGraph::onStyleApply(const std::string&, ...)` nie nadpisuje `UIWidget::onStyleApply(std::string_view, ...)` — brak `override`, inny typ parametru
- **Skutek**: Callback stylu dla UIGraph nie jest wywoływany polimorficznie

#### 🟡 BUG-4: Houses — doorId indexing + XML format mismatch
- **Plik**: `client/houses.cpp`, linie 60-62, 93 vs 146
- **Opis**: `addDoor` rozjeżdża mapowanie ID→slot. Save/load używa różnych formatów XML (`houseid` atrybut vs child)

#### 🟡 BUG-5: Minimap — flags == 0 pomija klasyfikację kolorów
- **Plik**: `client/minimap.cpp`, linie 267, 276
- **Opis**: Pętle `nonWalkableColors`/`nonPathableColors` działają tylko gdy `flags != 0`

### 2.3 Undefined Behavior / Memory bugs (correctness)

#### 🔴 UB-1: win32crashhandler.cpp — GlobalFree na buforze stosowym
- **Plik**: `framework/platform/win32crashhandler.cpp:130`
- **Opis**: `GlobalFree(pSym)` zwalnia wskaźnik na bufor na stosie (`symBuffer`) — UB

#### 🔴 UB-2: crypt.cpp — xorCrypt pointer arithmetic na kopii lambdy
- **Plik**: `framework/util/crypt.cpp:123-124`
- **Opis**: `&c - &out[0]` gdzie `c` jest kopią parametru lambdy — UB

#### 🔴 UB-3: androidmanager.cpp — malloc + delete[] mismatch
- **Plik**: `framework/platform/androidmanager.cpp:73, 80`
- **Opis**: Alokacja `malloc`, zwolnienie `delete[]` — allocator mismatch

### 2.4 Problemy w util headers (template)

#### 🟡 UTIL-1: size.h operator/= — nie modyfikuje wd/ht
- **Plik**: `framework/util/size.h:59`

#### 🟡 UTIL-2: rect.h setSize() — width/height vs width()/height()
- **Plik**: `framework/util/rect.h:84`

#### 🟡 UTIL-3: matrix.h — złe stride w operator= z bufora
- **Plik**: `framework/util/matrix.h:141`
- **Opis**: `i * N + j` zamiast `i * M + j`

### 2.5 Problemy Windows-specific

#### 🟡 WIN-1: win32platform.cpp — brak LocalFree po CommandLineToArgvW
- **Plik**: `framework/platform/win32platform.cpp:44`

#### 🟡 WIN-2: win32window.cpp — WS_EX_TOPMOST w GWL_STYLE
- **Plik**: `framework/platform/win32window.cpp:946, 949`

### 2.6 Problemy code quality

#### 🟡 CODE-1: using namespace w publicznym headerze
- **Plik**: `client/thingtype.h:36`
- **Opis**: `using namespace otclient::protobuf;` — rozlewa namespace na wszystkie TU

#### 🟡 CODE-2: Możliwa literówka Lua klucza
- **Plik**: `client/luavaluecasts_client.cpp:884`
- **Opis**: `g_lua.setField("xperiencee")` — podwójne 'e' na końcu

---

## 3. PLAN NAPRAWY — 6 FAZ

### Faza 1: ICE CORE FIX — throw extraction (PRIORYTET NAJWYŻSZY)

**Cel**: Usunąć GŁÓWNĄ przyczynę ICE — throw w template lambda body

**Zmiany (3 pliki)**:

| # | Plik | Zmiana |
|---|------|--------|
| 1a | `framework/luaengine/luaexception.h` | Dodać deklaracje 2 nowych helperów: `throwExpiredLuaFunction()`, `throwLuaBadReturnCount()` |
| 1b | `framework/luaengine/luaexception.cpp` | Dodać definicje z `[[noreturn]]` + `__declspec(noinline)` |
| 1c | `framework/luaengine/luavaluecasts.h` | Zamienić 3× inline throw na wywołania helperów + wyciągnąć g_logger.error do non-template helper |

**Dlaczego to zadziała**: Identyczny wzorzec już zadziałał dla `throwLuaNilMemberCall()` w luabinder.h — ICE przestał crashować na tym throw.

---

### Faza 2: CMake Protection Expansion (PRIORYTET WYSOKI)

**Cel**: Rozszerzyć ochronę MSVC na niechronione pliki + wzmocnić Group 4

**Zmiany (1 plik — CMakeLists.txt)**:

| # | Zmiana | Flagi |
|---|--------|-------|
| 2a | **Upgrade Group 4**: uiwidget.cpp, protocolgameparse.cpp → pełna ochrona | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` + `SKIP_PRECOMPILE_HEADERS ON` |
| 2b | **Nowa Group 5** (text stack): TTFFont.cpp, TextShaper.cpp, LocaleShaping.cpp, bitmapfont.cpp, cachedtext.cpp, fontmanager.cpp | `/Od /Ob0 /d2SSAOptimizer-` + `SKIP_PRECOMPILE_HEADERS ON` |
| 2c | **Nowa Group 6** (UI text): uiwidgettext.cpp, uitextedit.cpp | `/d2SSAOptimizer-` |
| 2d | **uiwidgetbasestyle.cpp** — zostaje w Group 4 (upgrade z 2a) | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` + `SKIP_PRECOMPILE_HEADERS ON` |

**Dlaczego**: uiwidget.cpp (23× ranges + 29× callLuaField) to 2. najcięższy TU po luavaluecasts — musi mieć pełną ochronę. Pliki text stack ciągną HarfBuzz/FriBidi headers i fmt — muszą mieć przynajmniej `/Od`.

---

### Faza 3: #ifdef OTC_ENABLE_* Guards (PRIORYTET WYSOKI)

**Cel**: Dodać warunkową kompilację do text stack — nie includować HarfBuzz/FriBidi bezwarunkowo

**Zmiany (3 pliki)**:

| # | Plik | Zmiana |
|---|------|--------|
| 3a | `framework/text/TextShaper.h` | Owinąć `#include <hb.h>`, `<hb-ft.h>` w `#ifdef OTC_ENABLE_HARFBUZZ`, `<fribidi.h>` w `#ifdef OTC_ENABLE_FRIBIDI` |
| 3b | `framework/text/TTFFont.h` | Owinąć `#include <hb.h>`, `<hb-ft.h>` w `#ifdef OTC_ENABLE_HARFBUZZ`, FreeType includes w `#ifdef OTC_ENABLE_TTF` |
| 3c | `framework/text/TextShaper.cpp` | Owinąć ciało shape() i applyBidiReordering() w `#ifdef` |
| 3d | `framework/text/TTFFont.cpp` | Owinąć ciała metod FreeType/HarfBuzz w `#ifdef` |
| 3e | `framework/graphics/bitmapfont.h` | Owinąć `#include <framework/text/TTFFont.h>` w `#ifdef OTC_ENABLE_TTF` + forward declare `TTFFont` |
| 3f | `framework/graphics/bitmapfont.cpp` | Owinąć TTF code paths w `#ifdef OTC_ENABLE_TTF` |

**UWAGA**: OTC_ENABLE_TTF/HARFBUZZ/FRIBIDI są ZAWSZE definiowane przez CMake (otc_textstack INTERFACE), więc ta zmiana nie zmienia zachowania — ale daje MSVC kompilatorowi sygnał, że te includes są warunkowe, i pozwala w przyszłości budować bez text stack.

---

### Faza 4: std::ranges → std algorithms (PRIORYTET ŚREDNI)

**Cel**: Zmniejszyć presję ranges na MSVC w najcięższych TU

**Zmiany (3 pliki)**:

| # | Plik | Zmiana | Ilość |
|---|------|--------|------:|
| 4a | `framework/core/resourcemanager.cpp` | `std::ranges::find` → `std::find`, `std::ranges::reverse_view` → `std::reverse_iterator` / `rbegin/rend` | 4 |
| 4b | `framework/core/module.cpp` | `std::ranges::find` → `std::find` | 2 |
| 4c | `framework/ui/uiwidget.cpp` | `std::ranges::find` → `std::find`, `std::ranges::reverse_view` → reverse iterator, `std::ranges::rotate` → `std::rotate`, `std::ranges::reverse` → `std::reverse` | 23 |

**Dlaczego**: MSVC 14.44 ma regression w `<ranges>` codegen. `std::find`, `std::rotate`, `std::reverse` to klasyczne algorytmy z `<algorithm>` — lżejsze dla P2 optimizer. Zamiana 23 ranges w uiwidget.cpp DRAMATYCZNIE zmniejszy presję na ten TU.

**UWAGA**: Faza 4 jest OPCJONALNA jeśli Faza 2 (upgrade Group 4 → pełna ochrona) wystarczy. Ale obie razem dają najlepszy efekt.

---

### Faza 5: Bug fixes (PRIORYTET ŚREDNI — nie ICE, ale poprawność)

**5a — Runtime/UB (krytyczne)**:

| # | Plik | Linia | Zmiana |
|---|------|------:|--------|
| 5a.1 | `win32crashhandler.cpp` | 130 | Usunąć `GlobalFree(pSym)` — pSym wskazuje na bufor stosowy |
| 5a.2 | `crypt.cpp` | 123-124 | Przepisać xorCrypt z jawnym indeksem zamiast pointer arithmetic na kopii lambdy |
| 5a.3 | `androidmanager.cpp` | 73, 80 | Zamienić `delete[]` na `free()` (zgodne z `malloc`) |

**5b — Logika/API**:

| # | Plik | Linia | Zmiana |
|---|------|------:|--------|
| 5b.1 | `luavaluecasts.h` | 569, 576 | Usunąć `!` z warunku `if (!luavalue_cast...)` → `if (luavalue_cast...)` |
| 5b.2 | `position.h` | 253 | Naprawić operator< na prawidłowy porządek leksykograficzny |
| 5b.3 | `uigraph.h` | 77 | Zmienić `const std::string&` → `std::string_view` + dodać `override` |
| 5b.4 | `uiverticallayout.cpp` | 63, 65-66 | Naprawić warunek align i oś obliczeń w gałęzi "right" |
| 5b.5 | `uimap.cpp` | 117, 126 | Użyć `delta` w `zoomOut()` zamiast stałego `+2` |
| 5b.6 | `thingtype.h` | 36 | Usunąć `using namespace otclient::protobuf;` → jawne kwalifikacje |

**5c — Windows-specific**:

| # | Plik | Linia | Zmiana |
|---|------|------:|--------|
| 5c.1 | `win32platform.cpp` | 44 | Dodać `LocalFree(wchar_argv)` po `CommandLineToArgvW` |
| 5c.2 | `win32window.cpp` | 946, 949 | Oddzielić `WS_EX_TOPMOST` od `GWL_STYLE` → użyć `GWL_EXSTYLE` |

**5d — Util templates**:

| # | Plik | Linia | Zmiana |
|---|------|------:|--------|
| 5d.1 | `size.h` | 59 | Naprawić `operator/=` — realna modyfikacja `wd/ht` |
| 5d.2 | `rect.h` | 84 | `setSize()` → `size.width()` / `size.height()` zamiast `.width` / `.height` |
| 5d.3 | `matrix.h` | 141 | Naprawić stride: `i * N + j` → `i * M + j` |

---

### Faza 6: Stabilizacja (PRIORYTET NISKI — po zielonym CI)

| # | Zmiana |
|---|--------|
| 6a | Rozważyć PIMPL pattern dla TTFFont.h — ukryć FreeType/HarfBuzz w .cpp |
| 6b | Forward declaration `class TTFFont` w bitmapfont.h zamiast pełnego include |
| 6c | Sprawdzić czy `client/shadermanager.cpp` powinien być w SOURCE_FILES |
| 6d | Rozważyć dodanie `module.cpp` do CMake Group (2× ranges + luainterface.h) |
| 6e | Opcjonalnie: `extern template` deklaracje w luavaluecasts.h dla najczęstszych typów |

---

## 4. SZCZEGÓŁOWE INSTRUKCJE PER PLIK

### 4.1 luaexception.h — dodać deklaracje helperów

```cpp
// Dodać na końcu pliku, PRZED zamykającym #endif:

// Non-template [[noreturn]] helpers — called from luavaluecasts.h template lambdas.
// Extracting throw from template body prevents MSVC P2 ICE C1001.
[[noreturn]] void throwExpiredLuaFunction();
[[noreturn]] void throwLuaBadReturnCount();
// Non-template error logger — called from template catch blocks.
void logLuaCallbackError(const char* what);
```

### 4.2 luaexception.cpp — dodać definicje helperów

```cpp
// Dodać na końcu pliku:

[[noreturn]]
#ifdef _MSC_VER
__declspec(noinline)
#endif
void throwExpiredLuaFunction()
{
    throw LuaException("attempt to call an expired lua function from C++,"
                       "did you forget to hold a reference for that function?", 0);
}

[[noreturn]]
#ifdef _MSC_VER
__declspec(noinline)
#endif
void throwLuaBadReturnCount()
{
    throw LuaException("a function from lua didn't retrieve the expected number of results", 0);
}

#ifdef _MSC_VER
__declspec(noinline)
#endif
void logLuaCallbackError(const char* what)
{
    g_logger.error("lua function callback failed: {}", what);
}
```

### 4.3 luavaluecasts.h — zamienić inline throw na helpery

**Linia 300 (w `luavalue_cast<void(Args...)>` lambda)**:
```cpp
// PRZED:
throw LuaException("attempt to call an expired lua function from C++,"
                   "did you forget to hold a reference for that function?", 0);

// PO:
throwExpiredLuaFunction();
```

**Linia 303 (catch block)**:
```cpp
// PRZED:
g_logger.error("lua function callback failed: {}", e.what());

// PO:
logLuaCallbackError(e.what());
```

**Linia 340 (w `luavalue_cast<Ret(Args...)>` lambda)**:
```cpp
// PRZED:
throw LuaException("a function from lua didn't retrieve the expected number of results", 0);

// PO:
throwLuaBadReturnCount();
```

**Linia 343**:
```cpp
// PRZED:
throw LuaException("attempt to call an expired lua function from C++,"
                   "did you forget to hold a reference for that function?", 0);

// PO:
throwExpiredLuaFunction();
```

**Linia 346 (catch block)**:
```cpp
// PRZED:
g_logger.error("lua function callback failed: {}", e.what());

// PO:
logLuaCallbackError(e.what());
```

**Linie 569, 576 (pair cast bug fix)**:
```cpp
// PRZED:
if (!luavalue_cast(-1, value))
    pair.first = value;

// PO:
if (luavalue_cast(-1, value))
    pair.first = value;
```
(analogicznie dla pair.second)

### 4.4 CMakeLists.txt — rozszerzyć ochronę MSVC

```cmake
    # Group 4 UPGRADED: Large complex TUs — NOW with full protection.
    #   uiwidget.cpp: 2189 lines, 23× std::ranges, 29× callLuaField<T> templates
    #   uiwidgetbasestyle.cpp: 22× safe_cast<> template instantiations
    #   protocolgameparse.cpp: 6223 lines, 48× fmt calls, largest TU in project
    set_source_files_properties(
      framework/ui/uiwidget.cpp
      framework/ui/uiwidgetbasestyle.cpp
      client/protocolgameparse.cpp
      PROPERTIES
        COMPILE_FLAGS "/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt"
        SKIP_PRECOMPILE_HEADERS ON
    )

    # Group 5: Text stack (i18n/glyph) — HarfBuzz + FriBidi + FreeType headers
    #   These files were added for i18n support and pull in heavy external
    #   library headers. Without protection they compile with full /O1
    #   which can contribute to ICE.
    set_source_files_properties(
      framework/text/TTFFont.cpp
      framework/text/TextShaper.cpp
      framework/text/LocaleShaping.cpp
      framework/graphics/bitmapfont.cpp
      framework/graphics/cachedtext.cpp
      framework/graphics/fontmanager.cpp
      PROPERTIES
        COMPILE_FLAGS "/Od /Ob0 /d2SSAOptimizer-"
        SKIP_PRECOMPILE_HEADERS ON
    )

    # Group 6: UI text files — modified for Unicode/i18n, include
    #   bitmapfont.h → TTFFont.h → HarfBuzz chain
    set_source_files_properties(
      framework/ui/uiwidgettext.cpp
      framework/ui/uitextedit.cpp
      PROPERTIES
        COMPILE_FLAGS "/d2SSAOptimizer-"
    )
```

### 4.5 TextShaper.h — dodać #ifdef guards

```cpp
#pragma once
#include <string>
#include <vector>
#include <memory>

// HarfBuzz / FriBidi — conditional on CMake feature flags
#ifdef OTC_ENABLE_HARFBUZZ
#include <hb.h>
#include <hb-ft.h>
#endif

#ifdef OTC_ENABLE_FRIBIDI
#include <fribidi.h>
#endif

// ... reszta pliku bez zmian, ale typy hb_font_t* w sygnaturze shape()
// muszą być wewnątrz #ifdef OTC_ENABLE_HARFBUZZ albo użyć void*+cast
```

### 4.6 TTFFont.h — dodać #ifdef guards

```cpp
// PRZED:
#include <ft2build.h>
#include FT_FREETYPE_H
#include <hb.h>
#include <hb-ft.h>

// PO:
#ifdef OTC_ENABLE_TTF
#include <ft2build.h>
#include FT_FREETYPE_H
#endif
#ifdef OTC_ENABLE_HARFBUZZ
#include <hb.h>
#include <hb-ft.h>
#endif
```

---

## 5. KOLEJNOŚĆ COMMITÓW I WALIDACJA CI

### Commit 1: Faza 1 (ICE CORE FIX)
```
Pliki: luaexception.h, luaexception.cpp, luavaluecasts.h
Opis: Extract throw from template lambdas to [[noreturn]] helpers
CI gate: Windows build — oczekujemy brak C1001 w luavaluecasts path
```

### Commit 2: Faza 2 (CMake Protection)
```
Pliki: CMakeLists.txt
Opis: Upgrade Group 4 + add Groups 5-6 for text stack protection
CI gate: Windows Configure + Build — brak nowych ICE
```

### Commit 3: Faza 3 (#ifdef guards)
```
Pliki: TextShaper.h, TTFFont.h, TextShaper.cpp, TTFFont.cpp, bitmapfont.h, bitmapfont.cpp
Opis: Add OTC_ENABLE_* guards for HarfBuzz/FriBidi includes
CI gate: Linux + Windows — brak regression
```

### Commit 4: Faza 4 (ranges → std algorithms) — OPCJONALNY
```
Pliki: resourcemanager.cpp, module.cpp, uiwidget.cpp
Opis: Replace std::ranges with std algorithms for MSVC compatibility
CI gate: Windows build stability
```

### Commit 5: Faza 5 (Bug fixes)
```
Pliki: luavaluecasts.h, position.h, uigraph.h, win32crashhandler.cpp, crypt.cpp, etc.
Opis: Fix runtime bugs and UB found during audit
CI gate: Linux + Windows full build
```

### Commit 6: Faza 6 (Stabilizacja) — PO ZIELONYM CI
```
Opcjonalne refaktory: PIMPL, forward declarations, extern template
CI gate: Full smoke test
```

---

## 6. DEFINICJA SUKCESU

| Kryterium | Status |
|-----------|--------|
| ❌ Windows CI build przechodzi bez C1001 | Do zrobienia |
| ❌ Linux CI build przechodzi bez regression | Do zrobienia |
| ❌ Wszystkie krytyczne UB naprawione | Do zrobienia |
| ❌ CMake ma jawne grupy ochronne dla WSZYSTKICH ciężkich TU | Do zrobienia |
| ❌ Text stack headers mają #ifdef guards | Do zrobienia |
| ❌ Pair luavalue_cast bug naprawiony | Do zrobienia |
| ❌ Position::operator< naprawiony | Do zrobienia |
| ❌ Dokumentacja audytu i napraw kompletna | Do zrobienia |

---

## PODSUMOWANIE PRIORYTETÓW

```
   NAJWYŻSZY ├─ Faza 1: Extract throw z template lambda (luavaluecasts.h)
             │           → bezpośrednio naprawia mechanizm ICE
             │
    WYSOKI   ├─ Faza 2: CMake Groups 5-6 + upgrade Group 4
             │           → chroni 8+ plików, wzmacnia uiwidget.cpp
             │
    WYSOKI   ├─ Faza 3: #ifdef OTC_ENABLE_* guards
             │           → zmniejsza include chain pressure o ~20K linii
             │
    ŚREDNI   ├─ Faza 4: std::ranges → std algorithms (OPCJONALNA)
             │           → zmniejsza presję ranges na MSVC 14.44
             │
    ŚREDNI   ├─ Faza 5: Bug fixes (UB, logic, Windows)
             │           → poprawność runtime, niezależne od ICE
             │
    NISKI    └─ Faza 6: Stabilizacja (PIMPL, forward decl, extern template)
                         → optymalizacja po zielonym CI
```
