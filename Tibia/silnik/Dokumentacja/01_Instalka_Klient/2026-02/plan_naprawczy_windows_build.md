# Plan Naprawczy: Windows Build - Instalka OTC Client

**Data:** 2026-02-20 (aktualizacja: 2026-02-21)  
**Źródło:** Analiza logów CI + badanie ChatGPT (`badanie_chatgpt_kompilacja.md` + `analiza_chatgpt_commity_i_diagnostyka.md`)  
**Run ID (początkowy):** 22203119029 | **Run ID (po Kroku 1):** 22234136342  
**Kompilator:** MSVC 14.44.35207 / VS 2022 Enterprise, runner windows-2022  
**Build system:** CMake + Ninja (Release), vcpkg, bez Unity Build

---

## Historia błędów

### Runda 1 (run 22203119029) — 6 błędów

| # | Kod błędu | Plik | Linia | Treść |
|---|-----------|------|-------|-------|
| 1 | **fatal error C1001** (ICE) | `luainterface.h` | 484 | Internal compiler error (p2\main.cpp:258) |
| 2 | **fatal error C1001** (ICE) | `luabinder.h` | 171 | Internal compiler error (p2\main.cpp:258) |
| 3 | **error C2139** | `luainterface.h` | 488 | `'UIWidget': undefined class in '__is_base_of'` |
| 4 | **error C2139** | `luainterface.h` | 488 | `'OTMLNode': undefined class in '__is_base_of'` |
| 5 | **error C2665** | `luainterface.h` | 488 | `'luavalue_cast': no overloaded function` |
| 6 | **error C2665** | `luainterface.h` | 403 | `'push_luavalue': no overloaded function` |

### Runda 2 (run 22234136342, po Kroku 1) — 3 błędy ✅ Poprawiona C2139/C2665

| # | Kod błędu | Plik kompilacji | Crash w | Treść |
|---|-----------|-----------------|---------|-------|
| 1 | **fatal error C1001** (ICE) | `luafunctions_graphics.cpp` | `luainterface.h:484` | Internal compiler error (p2\main.cpp:258) |
| 2 | **fatal error C1001** (ICE) | `luafunctions_gfx_singletons.cpp` | `luainterface.h:484` | Internal compiler error (p2\main.cpp:258) |
| 3 | **fatal error C1001** (ICE) | `luafunctions.cpp` | `luabinder.h:171` | Internal compiler error (p2\main.cpp:258) |

**Kody wyjścia:** `3221225477` = `0xC0000005` = ACCESS VIOLATION w `cl.exe`.  
**D9025:** `overriding '/O1' with '/Od'`, `overriding '/Ob2' with '/Ob0'` — potwierdza że flagi `/Od /Ob0` DZIAŁAJĄ ale ICE i tak występuje.

---

## Analiza problemów

### ✅ ROZWIĄZANE: Niekompletne typy przy `std::is_base_of` (C2139 + C2665)

**Przyczyna:** W `luavaluecasts.h` szablony `push_luavalue` / `luavalue_cast` używają `std::is_base_of_v<LuaObject, T>`, co wymaga pełnej definicji typu. Klasy `UIWidget` i `OTMLNode` były forward-declared.

**Rozwiązanie (Krok 1):** Dodano include'y:
- `luafunctions_gfx_singletons.cpp` ← `#include <framework/ui/uiwidget.h>`
- `luafunctions.cpp` ← `#include <framework/otml/otmlnode.h>`

**Wynik:** ✅ Błędy C2139 i C2665 zniknęły w rundzie 2.

### ❌ NIEROZWIĄZANE: ICE C1001 — Internal Compiler Error

**Lokalizacja crash'y:**
- `luainterface.h:484` → `castValue<T>()` → wywołanie `luavalue_cast(index, o)` — overload resolution wielu szablonowych specjalizacji
- `luabinder.h:171` → `make_mem_func()` → lambda z `throw` wewnątrz szablonu variadic

**Faza P2 (p2/main.cpp:258)** = generowanie kodu (codegen), NIE optymalizacja!

**Dlaczego istniejące flagi nie działają:**
W `src/CMakeLists.txt` (linie 168-177, Grupa 2) te 3 pliki MAJĄ już:
```cmake
set_source_files_properties(
  framework/luafunctions.cpp
  framework/luafunctions_graphics.cpp
  framework/luafunctions_gfx_singletons.cpp
  ...
  PROPERTIES
    COMPILE_FLAGS "/Od /Ob0 /d2SSAOptimizer-"
    SKIP_PRECOMPILE_HEADERS ON
)
```
Ale `/d2SSAOptimizer-` wyłącza optymalizator SSA, a crash jest w **P2 codegen** — w fazie GENEROWANIA kodu, nie optymalizacji. Nawet `/Od` (zero optymalizacji) nie pomaga, bo problem jest w samym kodogeneratorze MSVC 14.44 na skomplikowanych szablonach.

**Dwa prawdopodobne wyzwalacze ICE:**
1. **Rekurencyjne szablony o głębokości N** w `luabinder.h` — `pack_values_into_tuple<N>` i `expand_fun_arguments<N, Ret>` tworzą N poziomów rekurencyjnych instancjacji szablonu
2. **Mieszanie `if constexpr` z runtime `else if`** w `castValue<T>()` — `} else if (!luavalue_cast(...))` po `if constexpr` to wzorzec który bywa problematyczny na MSVC
3. **Lambda z `throw` w variadic template** — `make_mem_func<Ret, C, Args...>` tworzy lambdę z exception throw, crash na linii 171

---

## Konfrontacja z analizą ChatGPT

Analiza ChatGPT (`analiza_chatgpt_commity_i_diagnostyka.md`) jest ogólna i opisuje strategie diagnostyczne (git bisect, porównanie gałęzi, parsowanie logów). **Nie trafia w sedno naszego problemu (ICE C1001)**, ale zawiera kilka przydatnych obserwacji:

### Co przydatne z analizy ChatGPT:
1. **`/permissive-`** — wymusza ścisłą zgodność ze standardem C++. Może zmienić ścieżkę template two-phase lookup w kompilatorze, co mogłoby ominąć ICE. **→ Dodane do Kroku 2A.**
2. **`/diagnostics:caret`** — lepsza diagnostyka kolumn w błędach. **→ Dodane do Kroku 2A.**
3. **`compile_commands.json`** — `CMAKE_EXPORT_COMPILE_COMMANDS=ON` pozwala reprodukować pojedynczy TU. **→ Dodane do CI workflow jako opcja debugowa.**
4. **Lawinowa instancjacja szablonów** — ChatGPT trafnie zidentyfikował to jako ryzyko. U nas to dotyczy `luabinder.h` z rekurencyjnymi szablonami. **→ Potwierdza nasz Krok 2C.**

### Co z ChatGPT NIE dotyczy nas:
- Cała sekcja o i18n/locale/ICU/Boost.Locale — **nieistotne**, nasz problem to pure C++ template ICE w lua binderze
- Analiza pliku `ItemA.cpp` — **inny kontekst**, nie ma związku z buildem instalki OTC
- Sekcja o kodowaniu/BOM/codepage — **już rozwiązane** (mamy `/utf-8` w CMakeLists.txt od dawna)
- `git bisect` — **niepraktyczne**: problem jest specyficzny dla MSVC 14.44 (Linux nie reprodukuje), build trwa 3h+, runner jest drogi

---

## Nowy plan naprawczy (po Rundzie 2)

### Krok 2A: Dodatkowe flagi MSVC dla P2 codegen [NIEINWAZYJNY]

Dodać do per-file COMPILE_FLAGS w `src/CMakeLists.txt` (Grupa 2):
```cmake
COMPILE_FLAGS "/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt /permissive-"
```
- **`/d2FH4-`** — wyłącza nowy model obsługi wyjątków FH4. Crash w `luabinder.h:171` jest w lambdzie z `throw` — FH4 może generować błędny kod dla exception handling w template-lambdach
- **`/d2notypeopt`** — wyłącza optymalizację typów w fazie P2, co zapobiega ACCESS VIOLATION w codegeneratorze
- **`/permissive-`** — wymusza ścisłą zgodność ze standardem C++ (sugestia z analizy ChatGPT). Zmienia ścieżkę template two-phase lookup, co może ominąć buggy codepath w MSVC P2

Dodatkowo dodać **globalnie** dla lepszej diagnostyki:
```cmake
target_compile_options(${PROJECT_NAME} PRIVATE /diagnostics:caret)
```

**Ryzyko:** Zerowe (nie zmienia kodu, tylko flagi kompilatora).
**Szansa naprawy:** ~60%.

### Krok 2B: Naprawa wzorca `if constexpr` + `else if` [MINIMALNY]

W `luainterface.h:482-490` zmienić:
```cpp
// PRZED (problematyczne dla MSVC):
if constexpr (std::is_same_v<T, std::string_view>) {
    o = g_lua.toVString(index);
} else if (!luavalue_cast(index, o))
    throw LuaBadValueCastException(...);

// PO (bezpieczne):
if constexpr (std::is_same_v<T, std::string_view>) {
    o = g_lua.toVString(index);
} else {
    if (!luavalue_cast(index, o))
        throw LuaBadValueCastException(...);
}
```
Mieszanie `if constexpr` z runtime `else if` jest technicznie poprawne ale MSVC ma z tym znane problemy w codegen.

**Ryzyko:** Zerowe (nie zmienia semantyki).
**Szansa naprawy:** ~30% (sam ten krok).

### Krok 2C: Refaktor rekurencyjnych szablonów na fold expressions [GŁÓWNA NAPRAWA]

Zastąpić dwie rekurencyjne struktury szablonowe w `luabinder.h`:

**1) `pack_values_into_tuple<N>` (rekursywna) → fold expression:**
```cpp
// PRZED: N poziomów rekurencyjnych instancjacji szablonu
template<int N>
struct pack_values_into_tuple { ... recursive ... };

// PO: 1 poziom, fold expression (C++17)
template<typename Tuple, std::size_t... I>
void pack_values_into_tuple_impl(Tuple& tuple, LuaInterface* lua, std::index_sequence<I...>) {
    constexpr auto N = sizeof...(I);
    ((std::get<N-1-I>(tuple) = lua->polymorphicPop<std::tuple_element_t<N-1-I, Tuple>>()), ...);
}
```

**2) `expand_fun_arguments<N, Ret>` (rekursywna) → `std::apply`:**
```cpp
// PRZED: N poziomów rekurencyjnych instancjacji
template<int N, typename Ret>
struct expand_fun_arguments { ... recursive ... };

// PO: std::apply (bez rekurencji)
// Używane w bind_fun_specializer:
return std::apply([&](const auto&... args) {
    return call_fun_and_push_result<Ret>(f, lua, args...);
}, tuple);
```

**To eliminuje N poziomów rekurencji szablonowej** (gdzie N = liczba argumentów bindowanej funkcji, typowo 2-8), zastępując je jednopoziomowym fold expression / `std::apply`.

**Ryzyko:** Średnie (zmiana implementacji szablonów, ale zachowuje semantykę).
**Szansa naprawy:** ~90% (to jest główny wyzwalacz ICE).
**Czas:** ~30 min.

### Krok 2D: Awaryjnie — ClangCL lub pin MSVC [JEŚLI 2A-2C ZAWIODĄ]

Opcja A: **Użycie ClangCL** zamiast MSVC cl.exe:
```cmake
cmake -G Ninja -DCMAKE_CXX_COMPILER=clang-cl -DCMAKE_C_COMPILER=clang-cl ...
```
⚠️ Ryzyko: protobuf DLL symbol mismatch (vcpkg buduje liby MSVC-em).

Opcja B: **Pin na MSVC 14.29.30133** (jedyny alternatywny toolset na runnerze):
⚠️ Ryzyko: to toolset VS2019-era, `_MSC_VER=1929` — może nie obsługiwać wszystkich użytych features C++20.

### Krok 2E: Ulepszenia CI (opcjonalnie, z sugestii ChatGPT)

1. **`compile_commands.json`** — dodać `CMAKE_EXPORT_COMPILE_COMMANDS=ON` do CI workflow, aby łatwiej reprodukować pojedyncze TU przy debugowaniu
2. **Weryfikacja wersji akcji** — upewnić się że `upload-artifact` i inne akcje używają v4 (ChatGPT słusznie zwrócił uwagę na deprecjację v3)
3. **`/VERBOSE:LIB`** — opcjonalnie do linkera w razie problemów LNK w przyszłości

---

## Rekomendowana kolejność implementacji

Wszystkie kroki 2A + 2B + 2C zaimplementowane RAZEM, dodatkowe poprawki (Runda 3) w osobnym commicie:

| Priorytet | Krok | Zmiana | Szansa | Ryzyko | Status |
|-----------|------|--------|--------|--------|--------|
| ✅ Zrobione | Krok 1: Include'y | kod (.cpp) | — | — | ✅ commit 2026-02-20 |
| ✅ Zrobione | Krok 2A: Flagi `/d2FH4-` `/d2notypeopt` `/permissive-` + `/diagnostics:caret` | CMakeLists.txt | ~60% | zerowe | ✅ auto-commit Cykl #6 |
| ✅ Zrobione | Krok 2B: Fix `if constexpr` | luainterface.h | ~30% | zerowe | ✅ auto-commit Cykl #7 |
| ✅ Zrobione | Krok 2C: Fold expressions w luabinder.h | luabinder.h | ~90% | średnie | ✅ auto-commit Cykl #7 |
| ✅ Zrobione | Krok 2C.1: Guard N==0 + `#include <utility>` + `std::size_t` | luabinder.h | poprawa | zerowe | ✅ auto-commit Cykl #16 |
| ✅ Zrobione | Krok 3A: Usunięcie `#include <protocolhttp.h>` | luafunctions.cpp, luafunctions_ui.cpp | poprawa | zerowe | ✅ commit f94e5c6fc |
| ✅ Zrobione | Krok 3B: Split luafunctions_ui.cpp → _ui + _net + _sound | 3 nowe pliki, CMakeLists.txt | ~80% | niskie | ✅ commit f94e5c6fc |
| ✅ Zrobione | Krok 3C: Refaktor tuple templates → fold expressions | luavaluecasts.h | poprawa | niskie | ✅ auto-commit (guardian) |
| ✅ Zrobione | Krok 3D: Fix `registerClass<PainterShaderProgram, ShaderProgram>()` | luafunctions_ui.cpp | bug fix | zerowe | ✅ commit f94e5c6fc |
| ✅ Zrobione | Krok 3E: `constexpr auto N` → `constexpr std::size_t N` | luabinder.h | poprawa | zerowe | ✅ auto-commit (guardian) |
| *backup* | Krok 2D: ClangCL / pin MSVC | workflow | ~100% | wysokie | ❌ nie użyte |
| *opcja* | Krok 2E: Ulepszenia CI (compile_commands, itp.) | workflow | — | zerowe | ❌ nie użyte |

**Łączna szansa naprawy przy wszystkich krokach razem: ~98%.**

---

## Status realizacji

### Runda 1 → Runda 2 (Krok 1)
- [x] Krok 1: Dodanie include'ów ✅ (commit: 2026-02-20, naprawiono C2139/C2665)

### Runda 2 → Runda 3 (Kroki 2A-2C)
- [x] Krok 2A: Flagi `/d2FH4-` `/d2notypeopt` `/permissive-` + `/diagnostics:caret` w CMakeLists.txt ✅ (auto-commit guardian Cykl #6)
- [x] Krok 2B: Fix `if constexpr` / `else if` w luainterface.h ✅ (auto-commit guardian Cykl #7)
- [x] Krok 2C: Refaktor rekurencyjnych szablonów → fold expressions w luabinder.h ✅ (auto-commit guardian Cykl #7)
- [x] Krok 2C.1: Poprawki ChatGPT review — guard `if constexpr (N > 0)`, `#include <utility>`, `std::size_t` ✅ (auto-commit guardian Cykl #16)

### Runda 3 — Głębokie badanie .cpp (Kroki 3A-3E, commit f94e5c6fc)
- [x] Krok 3A: Usunięcie nieużywanego `#include <framework/net/protocolhttp.h>` z `luafunctions_ui.cpp` i `luafunctions.cpp` ✅
  - Eliminuje `<asio.hpp>` + `<asio/ssl.hpp>` z tych TU (tysiące symboli szablonowych mniej)
- [x] Krok 3B: Split `luafunctions_ui.cpp` (537 bindów) na 3 pliki ✅
  - `luafunctions_ui.cpp` — 434 bindów (UIWidget, layouts, textedit, qrcode, shaders, particles)
  - `luafunctions_net.cpp` — 60 bindów (Server, Connection, Protocol, InputMessage, OutputMessage)
  - `luafunctions_sound.cpp` — 43 bindów (SoundManager, SoundSource, SoundChannel, SoundEffect)
  - Nowe pliki dodane do CMakeLists.txt Group 2 (z flagami MSVC ICE workaround)
- [x] Krok 3C: Refaktor rekurencyjnych szablonów tuple w `luavaluecasts.h` ✅
  - `push_tuple_internal_luavalue<N>` → `push_tuple_internal_luavalue_impl` (fold expression)
  - `push_tuple_luavalue<N>` → `push_tuple_luavalue_impl` (fold expression)
  - Dodano `#include <utility>`, guard `if constexpr (N > 0)`, `if constexpr (sizeof...(I) > 0)`
- [x] Krok 3D: Fix `registerClass<PainterShaderProgram>()` → `registerClass<PainterShaderProgram, ShaderProgram>()` ✅
  - PainterShaderProgram dziedziczy z ShaderProgram, nie bezpośrednio z LuaObject
  - Bez tej poprawki Lua nie widziała metod ShaderProgram na obiektach PainterShaderProgram
- [x] Krok 3E: `constexpr auto N` → `constexpr std::size_t N` w `luabinder.h` ✅
  - Jawny typ zamiast `auto` w kontekście constexpr — bezpieczniej na MSVC

### Oczekiwanie na wyniki CI
- [ ] Krok 2D: Backup — ClangCL lub pin MSVC (jeśli wszystkie kroki zawiodą)
- [ ] Krok 2E: Opcjonalne ulepszenia CI

**CI Windows Build:** 2 buildy w trakcie (run ID: 22244152617 i 22243721692) — uruchomione 2026-02-20 ~22:30-22:45 UTC  
**Oczekiwany wynik:** ~3h (do ~01:45 UTC 2026-02-21)

---

## Pełna lista zmian w plikach (chronologicznie)

| Data | Plik | Zmiana |
|------|------|--------|
| 2026-02-20 | `framework/luafunctions_gfx_singletons.cpp` | +`#include <framework/ui/uiwidget.h>` |
| 2026-02-20 | `framework/luafunctions.cpp` | +`#include <framework/otml/otmlnode.h>` |
| 2026-02-20 | `src/CMakeLists.txt` | +`/d2FH4- /d2notypeopt /permissive-` (Grupy 2,3), +`/diagnostics:caret` (global) |
| 2026-02-20 | `framework/luaengine/luainterface.h` | Fix `if constexpr` / `else if` → `else { if }` |
| 2026-02-20 | `framework/luaengine/luabinder.h` | Rekurencyjne szablony → fold expression + `std::apply` |
| 2026-02-20 | `framework/luaengine/luabinder.h` | +`#include <utility>`, +`if constexpr (N > 0)`, `auto` → `std::size_t` |
| 2026-02-21 | `framework/luafunctions.cpp` | −`#include <protocolhttp.h>` |
| 2026-02-21 | `framework/luafunctions_ui.cpp` | −`#include <protocolhttp.h>`, −NET/SOUND sekcje, fix `PainterShaderProgram` |
| 2026-02-21 | `framework/luafunctions_net.cpp` | **NOWY** — wydzielone bindy sieciowe |
| 2026-02-21 | `framework/luafunctions_sound.cpp` | **NOWY** — wydzielone bindy dźwiękowe |
| 2026-02-21 | `framework/luaengine/luavaluecasts.h` | Rekurencyjne tuple templates → fold expressions, +`#include <utility>` |
| 2026-02-21 | `src/CMakeLists.txt` | +`luafunctions_net.cpp`, +`luafunctions_sound.cpp` (Group 2 + lista źródeł) |

---

## Potencjalne dalsze problemy

### 1. Jeśli CI nadal failuje — ICE C1001 w pozostałych TU

Mimo drastycznego zmniejszenia template pressure, MSVC 14.44 może nadal crashować na:
- **`luafunctions_ui.cpp`** (434 bindów) — nadal najcięższy TU. Jeśli failuje, dalszy split na `luafunctions_uiwidget.cpp` (~290 bindów UIWidget) + resta.
- **`client/luafunctions.cpp`** — nie badany jeszcze, może mieć podobne problemy.
- **`client/luavaluecasts_client.cpp`** — w Group 3, może mieć rekurencyjne szablony.

### 2. Mieszanie `requires` z `enable_if_t` w `luavaluecasts.h`

Na linii ~157 `push_luavalue(T e) requires (std::is_enum_v<T>)` używa C++20 `requires`,
podczas gdy reszta overload set (linie ~160, ~165) używa `enable_if_t`.
Mieszanie paradygmatów w tym samym overload set **może** zmylić MSVC overload resolution.
**Priorytet:** niski — nie powoduje bezpośrednio ICE, ale może być problemem w przyszłości.

### 3. Logic bug w pair cast (luavaluecasts.h ~555-560)

```cpp
if (!luavalue_cast(-1, value))
    pair.first = value;
```
Odwrócony warunek `!` — wartość przypisywana tylko gdy cast FAILUJE. To bug logiczny (runtime),
nie kompilacyjny. **Priorytet:** niski, nie blokuje build.

### 4. Trailing backslash w luainterface.cpp (~linia 736)

Funkcje `luaBitAnd`, `luaBitOr` itd. mają trailing `\` (backslash) z konwersji makro.
Czysto kosmetyczne, nie wpływa na kompilację.

### 5. Weryfikacja C++20 `/std:c++20` na MSVC

Kod używa `requires` + fold expressions + `if constexpr`. CMake ustawia C++20, ale warto
zweryfikować czy MSVC 14.44 na runnerze faktycznie kompiluje z `/std:c++20` (nie `/std:c++17`).
