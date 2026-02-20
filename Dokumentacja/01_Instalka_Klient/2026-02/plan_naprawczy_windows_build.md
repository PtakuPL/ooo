# Plan Naprawczy: Windows Build - Instalka OTC Client

**Data:** 2026-02-20 (aktualizacja: 2026-02-21)  
**Źródło:** Analiza logów CI + badanie ChatGPT (`badanie_chatgpt_kompilacja.md`)  
**Run ID (początkowy):** 22203119029 | **Run ID (po Kroku 1):** 22234136342  
**Kompilator:** MSVC 14.44.35207 / VS 2022 Enterprise, runner windows-2022

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

## Nowy plan naprawczy (po Rundzie 2)

### Krok 2A: Dodatkowe flagi MSVC dla P2 codegen [NIEINWAZYJNY]

Dodać do per-file COMPILE_FLAGS w `src/CMakeLists.txt` (Grupa 2):
```cmake
COMPILE_FLAGS "/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt"
```
- **`/d2FH4-`** — wyłącza nowy model obsługi wyjątków FH4. Crash w `luabinder.h:171` jest w lambdzie z `throw` — FH4 może generować błędny kod dla exception handling w template-lambdach
- **`/d2notypeopt`** — wyłącza optymalizację typów w fazie P2, co zapobiega ACCESS VIOLATION w codegeneratorze

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

---

## Rekomendowana kolejność implementacji

Wszystkie kroki 2A + 2B + 2C zaimplementować RAZEM w jednym commicie:

| Priorytet | Krok | Zmiana | Szansa | Ryzyko | Czas |
|-----------|------|--------|--------|--------|------|
| ✅ Zrobione | Krok 1: Include'y | kod (.cpp) | — | — | — |
| **1** | Krok 2A: Flagi `/d2FH4-` `/d2notypeopt` | CMakeLists.txt | ~60% | zerowe | 5 min |
| **2** | Krok 2B: Fix `if constexpr` | luainterface.h | ~30% | zerowe | 5 min |
| **3** | Krok 2C: Fold expressions | luabinder.h | ~90% | średnie | 30 min |
| *backup* | Krok 2D: ClangCL / pin MSVC | workflow | ~100% | wysokie | 20 min |

**Łączna szansa naprawy przy 2A+2B+2C razem: ~95%.**

---

## Status realizacji

- [x] Krok 1: Dodanie include'ów ✅ (commit: 2026-02-20, naprawiono C2139/C2665)
- [ ] Krok 2A: Flagi `/d2FH4-` `/d2notypeopt` w CMakeLists.txt
- [ ] Krok 2B: Fix `if constexpr` / `else if` w luainterface.h
- [ ] Krok 2C: Refaktor rekurencyjnych szablonów → fold expressions w luabinder.h
- [ ] Krok 2D: Backup — ClangCL lub pin MSVC (jeśli 2A-2C zawiodą)
