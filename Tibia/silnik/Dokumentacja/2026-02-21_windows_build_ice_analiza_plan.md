# Windows Build — MSVC ICE C1001: analiza, przyczyny, plan naprawy
**Data**: 2026-02-21
**Status**: Build FAIL — `luainterface.cpp#L41` Internal Compiler Error
**Build**: #4396 (commit `f704b47`) — failed po ~50 min
**Poprzedni FAIL**: #4394 (commit `b3225cdd`) — ten sam błąd
**Linux OTC**: #5109 — SUCCESS (ten sam kod)

---

## 1. Aktualny błąd

```
Annotations (Build #4396):
  Error: Internal compiler error in luainterface.cpp#L41
  Error: Process completed with exit code 1
  Warning: The process 'git.exe' failed with exit code 128
```

Linia 41 to `void LuaInterface::init() {` — bezpośrednio po `#pragma optimize("", off)`.

**MSVC ICE C1001** = kompilator MSVC sam się crashuje. To **nie jest błąd w kodzie** — to bug w kompilatorze MSVC 14.44+.

---

## 2. Dlaczego MSVC crashuje — root cause

### 2.1 Mechanizm ICE

MSVC 14.44 (Visual Studio 2022 17.14) ma bug w **P2 phase** (codegen/SSA optimizer) przy:
1. **Głębokich template instantiations** — `bind_fun_specializer<Ret, F, Tuple>` → `pack_values_into_tuple_impl` → `polymorphicPop<T>` → `castValue<T>` → `demangle_type<T>`
2. **throw w lambda wewnątrz template** — MSVC crash w FH4 exception handler
3. **PCH + template headers** — Precompiled headers ładują `luainterface.h` (z `luabinder.h` i `luavaluecasts.h`) do **każdego TU** co zwiększa presję na P2

### 2.2 Łańcuch template instantiation (krytyczny)

```
luafunctions_ui.cpp (434 rejestracji)
  → bindClassMemberFunction<UIWidget>("setWidth", &UIWidget::setWidth)
    → luabinder::bind_mem_fun<UIWidget, void, UIWidget, int>(...)
      → make_mem_func<void, UIWidget, int>(...)
        → MemberFunctionInvoker<void, UIWidget, int>
      → bind_fun_specializer<void, MemberFunctionInvoker<...>, tuple<shared_ptr<UIWidget>, int>>
        → pack_values_into_tuple_impl<tuple, 0, 1>(...)
          → polymorphicPop<shared_ptr<UIWidget>>()
            → castValue<shared_ptr<UIWidget>>()
              → luavalue_cast<shared_ptr<UIWidget>>()

    × 434 razy w jednym TU = ~2000+ template instancji
```

**MSVC nie wytrzymuje** takiej głębokości × ilości instantiacji w jednej Translation Unit.

---

## 3. Mapa plików — co psuje build

### 3.1 Pliki z ochroną MSVC (CMakeLists.txt Groups 1-3)

| Plik | Rejestracji | Flagi | `#pragma optimize off` |
|---|---|---|---|
| `framework/luafunctions_ui.cpp` | **434** | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` | ❌ BRAK |
| `client/luafunctions_entities.cpp` | **472** | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` | ❌ BRAK |
| `client/luafunctions_ui_client.cpp` | **154** | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` | ❌ BRAK |
| `framework/luafunctions.cpp` | **177** | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` | ❌ BRAK |
| `client/luavaluecasts_client.cpp` | 87 | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` | ❌ BRAK |
| `framework/luaengine/luavaluecasts.cpp` | ~30 | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` | ❌ BRAK |
| `framework/luafunctions_graphics.cpp` | 60 | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` | ❌ BRAK |
| `framework/luafunctions_gfx_singletons.cpp` | 49 | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` | ❌ BRAK |
| `framework/luafunctions_net.cpp` | 60 | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` | ❌ BRAK |
| `framework/luafunctions_sound.cpp` | 43 | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` | ❌ BRAK |
| `framework/luaengine/luainterface.cpp` | 9 | `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt` | ✅ TAK |
| `framework/otml/otmlnode.cpp` | 0 | `/Od /Ob0 /d2SSAOptimizer-` | ✅ TAK |
| `framework/otml/otmlparser.cpp` | 0 | `/Od /Ob0 /d2SSAOptimizer-` | ✅ TAK |

**Problem**: Pliki z 434-472 rejestracji mają flagi CMake ale **nie mają** `#pragma optimize("", off)` w samym pliku.

### 3.2 Pliki BEZ ochrony MSVC (includzują `luainterface.h`)

| Plik | `callLuaField` | `castValue` | Template risk |
|---|---|---|---|
| `framework/ui/uiwidget.cpp` (2188 ln) | **29** | 0 | **ŚREDNI** — ale jest w Group 4 z `/d2SSAOptimizer-` |
| `framework/core/application.cpp` | 4 | 0 | niski |
| `framework/core/consoleapplication.cpp` | 1 | 0 | niski |
| `framework/core/garbagecollection.cpp` | 0 | 0 | minimalny |
| `framework/core/logger.cpp` | 0 | 0 | minimalny |
| `framework/core/module.cpp` | 0 | 0 | minimalny |
| `framework/core/resourcemanager.cpp` | 0 | 0 | minimalny |
| `framework/luaengine/luaexception.cpp` | 0 | 0 | minimalny |
| `framework/luaengine/luaobject.cpp` | 0 | 0 | minimalny |
| `main.cpp` | 0 | 0 | minimalny |

### 3.3 Nagłówki template-heavy (headers)

| Header | Template count | Includzowany przez |
|---|---|---|
| `luabinder.h` (265 ln) | ~15 template structs/functions | `luainterface.h` → każdy `.cpp` z lua |
| `luavaluecasts.h` (627 ln) | **157** template decl | `luainterface.h` → każdy `.cpp` z lua |
| `luainterface.h` (549 ln) | ~10 template methods | bezpośrednio 20+ plików |
| `otmlnode.h` (191 ln) | ~10 template methods | via `declarations.h` chain |
| `cast.h` (214 ln) | `safe_cast<R,T>` + `unsafe_cast` | via `stdext` chain |
| `demangle.h` (75 ln) | `demangle_type<T>`, `demangle_class<T>` | via `stdext` chain |

**Krytyczne**: `luavaluecasts.h` z 157 template deklaracji jest includowany **wszędzie** przez chain: cpp → `luainterface.h:405` → `luavaluecasts.h`

---

## 4. Czy to auto-resize buttonów psuje build?

**NIE.** Pliki `10-buttons.otui`, `i18n_layout.lua`, `data/i18n_layout/*.lua` to dane klienta (`.otui` / `.lua`). Nie są kompilowane przez C++. Nie mają żadnego wpływu na build.

---

## 5. Historia prób naprawy (25+ commitów)

| # | Commit | Próba | Efekt |
|---|---|---|---|
| 1 | `8aa3450a1` | `#ifdef _MSC_VER` out `demangle_type<T>` w otmlnode.h | częściowo |
| 2 | `9b48524c9` | guard `cast_exception::update_what` | częściowo |
| 3 | `b7b6fb9df` | `_MSC_VER` guard na `demangle_type<T>()` globalnie | częściowo |
| 4 | `cdae4b4ad` | `OTML_NO_FMT` exclude fmt z OTML TU | częściowo |
| 5 | `77d9cb2a4` | extract throw from `value<T>()` template | częściowo |
| 6 | `d7e174727` | disable Release opt globally | pomogło ale /O0 = wolne |
| 7 | `4587d18a7` | `#pragma optimize off` + PCH + pin toolset 14.38 | częściowo |
| 8 | `fbfb98b27` | comprehensive per-file ICE protection | częściowo |
| 9 | `38b97fa4c-80afe8b93` | split luafunctions.cpp na 4 TU | pomogło na Linux |
| 10 | `f94e5c6fc` | split TU + refactor tuple templates | częściowo |
| 11 | `b3225cddb` | move throw z template | FAIL #4394 |
| 12 | `f704b476d` | dodano `luainterface.cpp` do Group 2 + `#pragma optimize off` | FAIL #4396 |

**Wzorzec**: Każda próba naprawia jedno miejsce ale ICE przenosi się na inny plik. "Whack-a-mole" pattern.

---

## 6. Dlaczego CMake flagi nie wystarczają

### 6.1 `COMPILE_FLAGS` vs `#pragma optimize`

`COMPILE_FLAGS "/Od /Ob0"` w CMakeLists.txt powinno wyłączyć optymalizację. **ALE**:
- CMake z Ninja może nie zawsze poprawnie przekazywać per-file flags (znany issue)
- `SKIP_PRECOMPILE_HEADERS ON` powinno wyłączyć PCH, ale jeśli `ccache/sccache` cachuje stare wyniki — flagi mogą być zignorowone
- `/d2SSAOptimizer-` to undocumented flag — nie gwarantuje stabilności

### 6.2 Dlaczego `luainterface.cpp` dalej crashuje (mimo `/Od`)

`luainterface.cpp` ma tylko 9 rejestracji. ALE:
- Includzuje `luainterface.h` → `luabinder.h` (265 ln templates) → `luavaluecasts.h` (627 ln, 157 templates)
- Nawet z `/Od`, P2 phase musi **przetworzyć parse tree** tych templates
- ICE może być w parsowaniu, nie w optymalizacji — wtedy `/Od` nie pomaga

---

## 7. Plan naprawy — od najpewniejszego

### Plan A: `#pragma optimize off` w KAŻDYM ryzkownym pliku (szybki)

Dodać na początku **wszystkich** plików z Groups 1-3:
```cpp
#if defined(_MSC_VER) && !defined(__clang__)
#pragma optimize("", off)
#endif
```

**Pliki do dodania** (12 plików — dotychczas mają TYLKO flagi CMake, brak pragma):
1. `framework/luafunctions.cpp`
2. `framework/luafunctions_graphics.cpp`
3. `framework/luafunctions_gfx_singletons.cpp`
4. `framework/luafunctions_ui.cpp`
5. `framework/luafunctions_net.cpp`
6. `framework/luafunctions_sound.cpp`
7. `client/luafunctions.cpp`
8. `client/luafunctions_entities.cpp`
9. `client/luafunctions_ui_client.cpp`
10. `client/luavaluecasts_client.cpp`
11. `framework/luaengine/luavaluecasts.cpp`
12. `framework/otml/otmlparser.cpp` (już ma)

**Koszt**: Wolniejsze wykonanie tych TU (brak optimalizacji w runtime)
**Pewność**: Wysoka — `#pragma optimize` jest respektowane nawet gdy CMake flagi nie działają

### Plan B: Dalszy split plików (średni czas)

Podzielić największe pliki:
- `luafunctions_ui.cpp` (434 reg.) → na 3 pliki po ~150 reg.
- `luafunctions_entities.cpp` (472 reg.) → na 3 pliki po ~160 reg.
- `luavaluecasts_client.cpp` (87 casts, 1601 ln) → na 2 pliki

**Koszt**: Ręczna praca splitowania + #include management
**Pewność**: Średnia — zmniejsza presję per TU ale nie eliminuje ICE

### Plan C: Wyeliminować templates z headers (duża zmiana)

Przenieść template body z headerów do `.cpp`:
- `luavaluecasts.h`: przenieść 157 template definitions do `.cpp` z explicit instantiation
- `luabinder.h`: przenieść `bind_fun_specializer` do `.cpp`
- `otmlnode.h`: przenieść `value<T>()` do `.cpp`

**Koszt**: Największy — wymaga `extern template` + explicit instantiation dla każdego typu
**Pewność**: Najwyższa — MSVC nie widzi template definitions w header = brak ICE

### Plan D: Downgrade MSVC toolset (obejście)

W workflow wymusić starszą wersję MSVC (14.38 lub 14.42):
```yaml
# build-windows.yml:
$toolsets = $toolsets | Where-Object { $_ -lt "14.44" }
```

**Problem**: Już próbowano — toolset 14.38 nie jest dostępny na `windows-latest` runner (ma tylko 14.44 + 14.29). 14.29 to VS2019 compat — za stary, nie kompiluje C++20 features.

### Plan E: Użyć Clang-CL zamiast MSVC (alternatywa)

W workflow zmienić kompilator na `clang-cl` (Clang z MSVC ABI):
```cmake
cmake -G "Ninja" -DCMAKE_CXX_COMPILER=clang-cl ...
```

**Problem**: vcpkg buduje dependencje z MSVC — mixing `clang-cl` dla naszego kodu + `MSVC` dla vcpkg libs = potencjalne symbol mismatch (szczególnie protobuf, OpenSSL). Już próbowano (commit `57ebac85a` — revert z clang-cl na MSVC).

---

## 8. Rekomendowana kolejność

1. **Plan A** (natychmiastowy) — dodaj `#pragma optimize off` do 12 plików. Zero ryzyka, 5 minut pracy, push + build #4397.
2. Jeśli Plan A nie wystarczy → **Plan B** — split `luafunctions_ui.cpp` i `luafunctions_entities.cpp`
3. Jeśli Plan B nie wystarczy → **Plan C** — explicit template instantiation (duża zmiana ale definitywna)
4. **Plan D/E** — tylko jako last resort

---

## 9. Dodatkowe obserwacje

### 9.1 Ścieżka `#include` w luainterface.cpp

```
luainterface.cpp
  → #include "luainterface.h"         (549 ln)
    → #include "declarations.h"       → pch chain → WSZYSTKIE framework headers
    → #include "luabinder.h" (L403)   (265 ln, 15 templates)
    → #include "luaexception.h" (L404)
    → #include "luavaluecasts.h" (L405) (627 ln, 157 templates)
  → #include "luaobject.h"
  → #include <framework/core/resourcemanager.h>
```

**Kluczowy problem**: `luainterface.h` includzuje `luabinder.h` i `luavaluecasts.h` **wewnątrz pliku nagłówkowego** — pozycje 403-405 w headerze. KAŻDY plik .cpp który includzuje `luainterface.h` dostaje ~1440 linii template code.

### 9.2 sccache może maskować problem

Workflow używa `sccache` (hendrikmuhs/ccache-action). Jeśli cache ma obiekty z innej wersji flag, mogą być niepoprawnie reużyte. Warto dodać:
```yaml
key: ccache-windows-release-${{ hashFiles('testyy/src/CMakeLists.txt') }}
```

### 9.3 Configure CMake trwa 46 min

To vcpkg buduje dependencje. Nie jest to związane z ICE — vcpkg build jest normalny. ICE występuje w kroku "Build" (12s na logu ale build failuje wcześniej).

### 9.4 Workflow komentarz vs rzeczywistość

```yaml
# The "Select MSVC toolset" step above already skips 14.44 to avoid ICE C1001.
```
Ten komentarz jest **nieaktualny**. Toolset step NIE skipuje 14.44 — bierze "latest" (= 14.44). Komentarz pochodzi ze starego kodu, ale logika filtrowania została usunięta.

---

## 10. Tabela zależności globalnych

```
Plik źródłowy (.cpp)          includuje→   Header template-heavy        →   Template instantiations
─────────────────────────────────────────────────────────────────────────────────────────────────────
luafunctions_ui.cpp            → luainterface.h → luabinder.h (15 tmpl) → 434 bind_mem_fun instantiacji
                                              → luavaluecasts.h (157 tmpl)
luafunctions_entities.cpp      → luainterface.h → luabinder.h            → 472 bind_mem_fun instantiacji
                                              → luavaluecasts.h
client/luavaluecasts_client.cpp → luainterface.h → luavaluecasts.h       → 87 luavalue_cast instantiacji
luafunctions.cpp               → luainterface.h → luabinder.h            → 177 bind instantiacji
luainterface.cpp               → luainterface.h → luabinder.h            →   9 rejestracji ALE ma cały chain
                                              → luavaluecasts.h            w headerze (627+265 ln templates)
otmlnode.cpp                   → otmlnode.h    → cast.h (safe_cast<>)    → ~20 value<T> instantiacji
otmlparser.cpp                 → otmlnode.h    → cast.h                  → ~10 value<T> instantiacji
uiwidget.cpp                   → luainterface.h → luabinder.h            →  29 callLuaField (indirect templates)
                                              → luavaluecasts.h
```

---

## 11. Podsumowanie: co musimy teraz zrobić

| Priorytet | Akcja | Czas | Ryzyko |
|---|---|---|---|
| **1** | Dodać `#pragma optimize("", off)` do 11 plików (Plan A) | 5 min | zero |
| **2** | Push + uruchomić Build Windows #4397 | 50 min (czekanie) | – |
| **3** | Jeśli dalej fail → split `luafunctions_ui.cpp` (434→3×150) | 30 min | niskie |
| **4** | Jeśli dalej fail → `extern template` w `luavaluecasts.h` | 2-3h | średnie |
| ewent. | Poprawić cache key w workflow (dodać hash CMakeLists.txt) | 2 min | zero |
| ewent. | Poprawić nieaktualny komentarz w workflow | 1 min | zero |

---

## 12. Aktualizacja wdrożenia (2026-02-21, Plan A wykonany)

Wdrożono `#pragma optimize("", off)` / `#pragma optimize("", on)` (MSVC, bez clang-cl) w ryzykownych TU:

1. `canary_test/testyy/src/framework/luafunctions.cpp`
2. `canary_test/testyy/src/framework/luafunctions_graphics.cpp`
3. `canary_test/testyy/src/framework/luafunctions_gfx_singletons.cpp`
4. `canary_test/testyy/src/framework/luafunctions_ui.cpp`
5. `canary_test/testyy/src/framework/luafunctions_net.cpp`
6. `canary_test/testyy/src/framework/luafunctions_sound.cpp`
7. `canary_test/testyy/src/client/luafunctions.cpp`
8. `canary_test/testyy/src/client/luafunctions_entities.cpp`
9. `canary_test/testyy/src/client/luafunctions_ui_client.cpp`
10. `canary_test/testyy/src/client/luavaluecasts_client.cpp`
11. `canary_test/testyy/src/framework/luaengine/luavaluecasts.cpp`

Dodatkowo aktywne juz wczesniej:
- `canary_test/testyy/src/framework/luaengine/luainterface.cpp`
- `canary_test/testyy/src/framework/otml/otmlnode.cpp`
- `canary_test/testyy/src/framework/otml/otmlparser.cpp`

Status:
- Plan A (pragma) jest zamkniety po stronie kodu.
- Nastepny krok: walidacja wyłącznie przez nowy run `Build - Windows` na GitHub Actions.

---

## 13. Aktualizacja wdrożenia (2026-02-21, Plan B wykonany)

Wdrożono Plan B dla najcięższego TU `luafunctions_ui.cpp`:

1. Rozdzielono jeden plik na 3 mniejsze TU:
   - `canary_test/testyy/src/framework/luafunctions_ui_widget_core.cpp`
   - `canary_test/testyy/src/framework/luafunctions_ui_widget_style.cpp`
   - `canary_test/testyy/src/framework/luafunctions_ui_layout_text_effects.cpp`
2. `canary_test/testyy/src/framework/luafunctions_ui.cpp` został zredukowany do lekkiego dispatchera:
   - wywołuje `registerLuaFunctions_UIWidgetCore()`
   - wywołuje `registerLuaFunctions_UIWidgetStyle()`
   - wywołuje `registerLuaFunctions_UILayoutTextEffects()`
3. `canary_test/testyy/src/CMakeLists.txt` został zaktualizowany:
   - nowe 3 pliki dodane do `SOURCE_FILES`
   - nowe 3 pliki dodane do Group 2 (per-file flags anty-ICE)

Blad krytyczny (naprawiony):
- W pierwszej iteracji Plan B nowe pliki splitu nie byly podpiete w `CMakeLists.txt`.
- Skutek: build nadal kompilowal tylko stary uklad TU i Plan B byl faktycznie nieaktywny.
- To byl kategoryczny blad integracji CMake (blokujacy walidacje naprawy).

Kontrola zgodności API po split:
- porównanie rejestracji `g_lua.*` względem oryginalnego `luafunctions_ui.cpp`: **434 vs 434**
- różnica bindingów: **brak** (1:1 zachowane rejestracje)

Status:
- Plan B po stronie kodu i CMake jest domknięty.
- Walidacja tylko przez GitHub Actions (`Build - Windows`, a potem `Build - Linux`) na commicie z tymi zmianami.
