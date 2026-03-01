# MSVC ICE C1001 — Kompleksowa analiza wszystkich 169 TUs

**Data:** 2026-02-19  
**Build:** #4372 (commit 62ff53e80) — FAILED  
**Błąd:** `framework/luafunctions.cpp` → `luabinder.h:171` → ICE C1001 (code=3221225477)  
**Przyczyna:** 794+ instancjacji szablonów `bind_singleton_mem_fun`/`bind_mem_fun` bez flagi `/d2SSAOptimizer-`

---

## Problem

MSVC 14.44 (Visual Studio 2022, windows-2022 runner) ma bug w P2 codegen (SSA optimizer, `p2/main.cpp:258`). Crash następuje gdy Translation Unit (TU) ma zbyt dużo instancjacji złożonych szablonów — szczególnie:

- `bind_singleton_mem_fun<C, Ret, FC, Args...>` z `luabinder.h`
- `bind_mem_fun<...>` z `luabinder.h`
- Zagnieżdżone szablony: `safe_cast<R,T>()` → `demangle_type<T>()`

Poprzedni branch `serwer-7.4` miał 788 bindingów w `framework/luafunctions.cpp` — był na granicy ale przechodził. Master dodał 6 nowych bindingów (clearGlyphCaches, setLocaleTag, getLocaleTag, setAutoFitParent*, isAutoFitParent) i przekroczył próg ICE.

---

## Analiza ryzyka — wszystkie 169 TUs

### KRYTYCZNE (crash lub bliskie crash)

| Plik | Linii | Bindingów | Status | Akcja |
|------|-------|-----------|--------|-------|
| `framework/luafunctions.cpp` | 1053 | **836** | **CRASH** | `/Od /Ob0 /d2SSAOptimizer-` + `SKIP_PCH` |
| `client/luafunctions.cpp` | 1103 | **942** | Przechodzi (graniczne) | `/Od /Ob0 /d2SSAOptimizer-` + `SKIP_PCH` |

### WYSOKIE RYZYKO

| Plik | Linii | Czynnik ryzyka | Akcja |
|------|-------|----------------|-------|
| `client/luavaluecasts_client.cpp` | 1601 | 87 `luavalue_cast<>` instancjacji | `/Od /Ob0 /d2SSAOptimizer-` + `SKIP_PCH` |
| `framework/luaengine/luavaluecasts.cpp` | 365 | 23 `luavalue_cast<>` instancjacji | `/Od /Ob0 /d2SSAOptimizer-` + `SKIP_PCH` |
| `framework/ui/uiwidget.cpp` | 2168 | 23× `std::ranges`, include `luainterface.h` | `/d2SSAOptimizer-` |
| `framework/ui/uiwidgetbasestyle.cpp` | 435 | 22× `safe_cast<>` instancjacji | `/d2SSAOptimizer-` |
| `client/protocolgameparse.cpp` | 6222 | Największy plik, 48× fmt | `/d2SSAOptimizer-` |

### ŚREDNIE RYZYKO (monitoring)

| Plik | Linii | Czynnik ryzyka |
|------|-------|----------------|
| `framework/luaengine/luainterface.cpp` | 1407 | 7 bindingów, include `luabinder.h` |
| `client/map.cpp` | 1471 | 5× `std::ranges` |
| `client/tile.cpp` | 1004 | 6× `std::ranges` |
| `client/protocolgamesend.cpp` | 1506 | 129× shared_ptr casts |
| `framework/core/resourcemanager.cpp` | 805 | 4× `std::ranges`, 19× fmt |
| `client/game.cpp` | 2012 | include `luavaluecasts_client.h` |
| `client/creature.cpp` | 1270 | include `luavaluecasts_client.h` |
| `framework/text/TTFFont.cpp` | 601 | 28× fmt |
| `framework/platform/win32window.cpp` | 1155 | 2 bindingi, 26× fmt |

### NISKIE RYZYKO (~15 plików)

Pliki z drobnymi wzorcami: `module.cpp`, `modulemanager.cpp`, `x11window.cpp`, `protocolhttp.cpp`, `bitmapfont.cpp`, `mapview.cpp`, `uigraph.cpp`, `crypt.cpp`, `protocol.cpp`, `string.cpp`, `animatedtext.cpp`, `connection.cpp`, `unixplatform.cpp`, `thingtypemanager.cpp`

### BEZPIECZNE (~140 plików)

Pozostałe — 0 bindingów, 0 `std::ranges`, 0 `safe_cast`, minimalne fmt, poniżej 500 linii.

---

## Aktualne zabezpieczenia (CMakeLists.txt)

| Zabezpieczenie | Co chroni |
|---|---|
| Globalne `/O2` → `/O1` | Wszystkie pliki |
| `/GL-` + `/LTCG:OFF` | Wszystkie pliki |
| `INTERPROCEDURAL_OPTIMIZATION FALSE` | Target-level |
| `#ifdef _MSC_VER` w `cast.h` | Wyłącza `demangle_type<T>()` w MSVC |
| `#ifndef OTML_NO_FMT` w `pch.h` + `logger.h` | Pliki OTML bez fmt |
| `/Od /Ob0 /d2SSAOptimizer-` + `SKIP_PCH` + `OTML_NO_FMT` | `otmlnode.cpp`, `otmlparser.cpp` |

### Dodane w tym commicie:

| Zabezpieczenie | Co chroni |
|---|---|
| `/Od /Ob0 /d2SSAOptimizer-` + `SKIP_PCH` | `framework/luafunctions.cpp`, `client/luafunctions.cpp` |
| `/Od /Ob0 /d2SSAOptimizer-` + `SKIP_PCH` | `luavaluecasts_client.cpp`, `luavaluecasts.cpp` |
| `/d2SSAOptimizer-` | `uiwidget.cpp`, `uiwidgetbasestyle.cpp`, `protocolgameparse.cpp` |

---

## `starts_with`/`ends_with` — stan

7 call-sites w 4 plikach — to C++20 `std::string::starts_with()`, NIE `std::ranges::starts_with()`. W pełni obsługiwane przez MSVC 14.44, **NIE** powodują ICE:

- `otmlnode.h:114` — w OTML_NO_FMT TU (chroniony)
- `otmlparser.cpp:102,203` — w OTML_NO_FMT TU (chroniony)
- `uiwidgetbasestyle.cpp:52,61,314` — z `/d2SSAOptimizer-` (chroniony)
- `string.cpp:47` — niskie ryzyko

## `std::ranges` — stan

55 call-sites w 17 plikach. Nie jest bezpośrednim triggerem ICE ale zwiększa obciążenie szablonowe. Największe koncentracje:
- `uiwidget.cpp` — 23 użycia (chroniony `/d2SSAOptimizer-`)
- `tile.cpp` — 6 użyć
- `map.cpp` — 5 użyć

---

## Łańcuch include — klucz do zrozumienia

```
pch.h                              ← każdy plik go wciąga
  └─ fmt/format.h, fmt/ranges.h   ← chyba że OTML_NO_FMT
  
global.h → pch.h
  └─ stdext/stdext.h
       └─ cast.h                   ← safe_cast<>, demangle_type<>
       └─ string.h                 ← to_string/from_string

luainterface.h
  └─ luabinder.h                   ← bind_fun, bind_mem_fun — TRIGGER ICE
  └─ luavaluecasts.h
```

18 plików włącza `luainterface.h` lub `luabinder.h`. Ale ICE trigger to **instancjacja** szablonów — samo włączenie headera bez wywoływania `bindSingletonFunction` nie powoduje ICE.

---

## Podsumowanie zmian

| Kategoria | Liczba plików | Odpowiedź |
|---|---|---|
| KRYTYCZNE — crash/bliskie crash | 2 | `/Od /Ob0 /d2SSAOptimizer-` + `SKIP_PCH` |
| WYSOKIE — ciężki template load | 5 | `/Od /Ob0 /d2SSAOptimizer-` lub `/d2SSAOptimizer-` |
| ŚREDNIE — duże TU, umiarkowane szablony | 9 | Monitoring |
| NISKIE | ~15 | Brak akcji |
| BEZPIECZNE | ~140 | Brak akcji |
| **Już chronione** | 2 (OTML) | Bez zmian |

---

*Dokument stworzony: 2026-02-19. Autor: Copilot + Ptaku.*  
*Powiązane:*
- `2026-02-09_ci_build_fixes.md` — pierwsze naprawy ICE
- `2026-02-09_ci_build_fixes_v2.md` — kontynuacja WASM/Windows
- `2026-02-16_build_failure_const_luabinder.md` — const problem w fontmanager
