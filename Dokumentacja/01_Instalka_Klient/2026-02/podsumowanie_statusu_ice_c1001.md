# Podsumowanie statusu ICE C1001 — po Rundzie 2

**Data:** 2026-02-21  
**Kontekst:** Analiza wyników CI po wdrożeniu Kroku 1 (include'y)

---

## Podsumowanie aktualnej sytuacji

**Krok 1 ✅ — zadziałał:** Dodanie include'ów naprawiło błędy C2139 i C2665 (4 z 6 błędów zniknęło).

**Pozostały problem:** ICE C1001 w **3 plikach** — MSVC 14.44 crashuje (ACCESS VIOLATION w cl.exe) przy generowaniu kodu dla szablonów, **mimo** już zastosowanych flag `/Od /Ob0 /d2SSAOptimizer-`.

## Nowy plan — 3 kroki do wdrożenia RAZEM

| Krok | Co | Szansa | Ryzyko |
|------|----|--------|--------|
| **2A** | Dodać flagi `/d2FH4-` i `/d2notypeopt` do CMakeLists.txt (Grupa 2) | ~60% | zerowe |
| **2B** | Naprawić `if constexpr` / `else if` w `luainterface.h:484` — wydzielić do `else { if(...) }` | ~30% | zerowe |
| **2C** | Refaktoryzacja `luabinder.h` — zamienić rekurencyjne szablony (`pack_values_into_tuple<N>`, `expand_fun_arguments<N>`) na fold expressions / `std::apply` | ~90% | średnie |

**Łącznie ~95% szansy na naprawę ICE.**

Krok 2D (backup): ClangCL lub pin MSVC 14.29 — tylko jeśli 2A-2C zawiodą.

## Szczegóły błędów z Rundy 2

**Run ID:** 22234136342 (MSVC 14.44.35207)

| # | Plik kompilacji | Crash w | Exit code |
|---|-----------------|---------|-----------|
| 1 | `luafunctions_graphics.cpp` | `luainterface.h:484` | 0xC0000005 |
| 2 | `luafunctions_gfx_singletons.cpp` | `luainterface.h:484` | 0xC0000005 |
| 3 | `luafunctions.cpp` | `luabinder.h:171` | 0xC0000005 |

**Potwierdzenie flag:** Ostrzeżenia D9025 (`overriding '/O1' with '/Od'`, `overriding '/Ob2' with '/Ob0'`) potwierdzają że per-file flagi DZIAŁAJĄ ale ICE występuje w fazie P2 codegen, nie w optymalizacji.

## Analiza techniczna crash'ów

### Crash 1 & 2: `luainterface.h:484` — `castValue<T>()`

```cpp
template<class T>
T LuaInterface::castValue(int index) {
    T o;
    if constexpr (std::is_same_v<T, std::string_view>) {
        o = g_lua.toVString(index);
    } else if (!luavalue_cast(index, o))   // <-- crash tutaj
        throw LuaBadValueCastException(...);
    return o;
}
```

Problem: Mieszanie `if constexpr` z runtime `else if` + overload resolution `luavalue_cast()` z wieloma template specjalizacjami.

### Crash 3: `luabinder.h:171` — `bind_fun_specializer`

```cpp
template<typename Ret, typename F, typename Tuple>
LuaCppFunction bind_fun_specializer(const F& f) {
    enum { N = std::tuple_size_v<Tuple> };
    return [=](LuaInterface* lua) -> int {
        // ... pack_values_into_tuple<N>::call(tuple, lua);   <-- rekurencja N
        // ... expand_fun_arguments<N, Ret>::call(tuple, f, lua);  <-- rekurencja N
    };
}
```

Problem: Rekurencyjne szablony `pack_values_into_tuple<N>` i `expand_fun_arguments<N, Ret>` tworzą N poziomów instancjacji. Przy 800-950 bindowaniach w jednym TU, MSVC P2 codegen pada.

## Dlaczego istniejące flagi nie wystarczają

- `/Od` (no optimization) — wyłącza optymalizację, ale crash jest w **codegen** (generowaniu kodu maszynowego), nie w optymalizacji
- `/Ob0` (no inlining) — zmniejsza presję ale nie eliminuje rekurencyjnych instancjacji szablonów
- `/d2SSAOptimizer-` — wyłącza SSA optimizer, ale crash jest PRZED SSA (w P2)
- `SKIP_PRECOMPILE_HEADERS ON` — poprawne, eliminuje interakcję PCH
