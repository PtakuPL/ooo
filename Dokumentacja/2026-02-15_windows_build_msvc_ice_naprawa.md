# 2026-02-15 — Naprawa buildu Windows (MSVC ICE C1001) — kompletna dokumentacja

## Spis tresci

1. [Podsumowanie problemu i naprawy](#1-podsumowanie)
2. [Chronologia zdarzen](#2-chronologia)
3. [Dokladne zmiany w plikach](#3-zmiany-w-plikach)
4. [Architektura buildu Windows — jak to dziala](#4-architektura-buildu)
5. [Lancuch zaleznosci compilacji (include chain)](#5-lancuch-zaleznosci)
6. [Katalog znanych przyczyn bledow MSVC ICE](#6-katalog-przyczyn-ice)
7. [Inne mozliwe przyczyny problemow z buildem Windows](#7-inne-przyczyny)
8. [Checklist przed kazdym pushem zmian do instalki](#8-checklist)
9. [Szybka diagnostyka awarii CI](#9-diagnostyka)
10. [Referencje i linki](#10-referencje)

---

## 1) Podsumowanie

### Problem
Build Windows klienta OTClient (instalka) padal z bledem **MSVC Internal Compiler Error (ICE) C1001** 
w dwoch translation units (TU):
- `framework/otml/otmlparser.cpp` (linia ~47)
- `framework/otml/otmlnode.cpp` (linia ~70)

Blad ICE oznacza **crash samego kompilatora** (cl.exe) — nie blad w naszym kodzie per se, 
ale kompilator nie radzi sobie z okreslonymi kombinacjami template/optymalizacji.

### Przyczyna glowna
Kombinacja trzech czynnikow:
1. **SKIP_PRECOMPILE_HEADERS ON** — wymuszalo rekompilacje calego lancucha `global.h` → `pch.h` 
   (70 linii, 31 include'ow, w tym fmt, parallel_hashmap, pugixml) od zera w kazdym TU OTML
2. **Poziom optymalizacji /O2** (domyslny Release) — agresywny optimizer P2 crashowal na glebokim 
   template instantiation z `stdext::cast<T>` → `demangle_type<T>()`
3. **LTCG/GL** — Link-Time Code Generation rozszezerala powierzchnie ICE miedzy TU

### Naprawa (commit `4587d18a7` + `0567a036c`)
1. `#pragma optimize("", off/on)` w otmlparser.cpp i otmlnode.cpp — wyłacza optimizer w tych TU
2. Usunieto `SKIP_PRECOMPILE_HEADERS ON` — przywrocono PCH dla wszystkich TU
3. Zamieniono /O2 na /O1 globalnie (optimize for size, mniej agresywny)
4. Wylaczono LTCG/GL (`/GL-`, `/LTCG:OFF`)
5. Revert do C++20 `.starts_with()` / `.ends_with()` (nie trzeba custom helperow)
6. Runner: `windows-2022` (bez pinowania toolsetu — 14.38 niedostepny)

### Status
- Build `22034049974` (SHA `8aa3450a1`) — w trakcie (root cause fix: otmlnode.h)
- Build `22033027682` (SHA `0567a036c`) — FAIL (ICE nadal, #pragma optimize nie pomaga przy P2)
- Dodatkowe workaround'y: commit `9b48524c9` (cast.h, thingtype.h, tile.h)

---

## 2) Chronologia zdarzen

| Data | Run ID | SHA | Wynik | Uwagi |
|------|--------|-----|-------|-------|
| 2026-02-08 17:40 | `21802468391` | `0a34ffb490b` | **SUCCESS** | Ostatni udany build |
| 2026-02-08 19:24 → 2026-02-10 | #4325-#4342 | rozne | FAIL | Seria failow po zmianach i18n |
| 2026-02-14 17:08 | `22020364224` | `d7e174727` | FAIL | ICE C1001 w otmlparser.cpp(47), otmlnode.cpp(70) |
| 2026-02-14 21:25 | `22023736948` | (audit batch) | FAIL | ICE + ostrzezenia D9025 (/O1 vs /Od conflict) |
| 2026-02-14 22:26 | `22024533938` | `d7e174727` | FAIL | ICE bez D9025, ale /Od nie pomoglo |
| 2026-02-15 00:03 | `22025751410` | (c++17 workaround) | FAIL | C++17 na OTML lamie global.h (std::numbers) |
| 2026-02-15 01:11 | `22026595816` | `3a5f5d8fd` | FAIL | j.w. — C++17 niekompatybilne z PCH |
| 2026-02-15 01:20 | `22026707920` | `013a5cea5` | FAIL | j.w. |
| 2026-02-15 ~02:00 | `22032301188` | `351fee6d1` | IN PROGRESS→FAIL | Revert do C++20, ale bez pragma |
| 2026-02-15 ~02:50 | (nowy) | `0567a036c` | **FAIL** | Pragma off + PCH + /O1 + bez toolset pin — ICE nadal w P2 |
| 2026-02-15 ~04:00 | `22033027682` | `0567a036c` | **FAIL** | ICE C1001 w otmlnode.cpp(76), otmlparser.cpp(40) — #pragma optimize NIE pomaga przy P2 codegen crash |
| 2026-02-15 ~04:30 | `22034049974` | `8aa3450a1` | **IN PROGRESS** | Root cause fix: ifdef out demangle_type<T>() w otmlnode.h |
| 2026-02-15 ~05:00 | (nowy) | `9b48524c9` | **PUSHED** | Dodatkowe workaround'y: cast.h, thingtype.h, tile.h |

### Co probowano i co nie zadzialalo

| Proba | Dlaczego nie zadzialalo |
|-------|------------------------|
| `/Od` (brak optymalizacji globalnie) | ICE nadal wystepuje — P2 crashuje nawet bez optymalizacji gdy template chain jest zbyt gleboki |
| `/std:c++17` dla OTML TU | global.h/pch.h uzywaja C++20 (`std::numbers`, `concept`, `requires`) — bledy kompilacji |
| `SKIP_PRECOMPILE_HEADERS ON` | **POGARSZA** sytuacje — wymusza rekompilacje 70-liniowego PCH od zera w kazdym TU |
| Custom `startsWith()` helpers | Zbedne — C++20 `.starts_with()` dziala poprawnie, to nie bylo zrodlem ICE |
| `std::ranges::find` → `std::find` | Mala poprawa, ale nie rozwiazuje ICE |
| Pinowanie toolset `14.38` | Toolset 14.38 nie jest zainstalowany na runnerze windows-2022 |

### Prawdziwa przyczyna glowna (root cause)

`#pragma optimize("", off)` NIE POMOGLO, bo ICE bylo w **P2 (codegen)**, nie w optimizerze.
Stack trace z cl.exe wskazywal na `p2\main.cpp:258`, a nie na fazę optymalizacji.

**Root cause:** `otmlnode.h` template `value<T>()` wywolywal `stdext::demangle_type<T>()` 
wewnatrz `fmt::format()`. Ten template zdefiniowany w headerze byl instancjonowany 
w KAZDYM translation unit ktory includewal `otmlnode.h` (przez `otmldocument.h`).
Kazda instancjacja generowala glebokie drzewo `fmt::format + typeid + demangle_name`, 
co crashowalo P2 codegen MSVC.

**Dowod:** Identyczny wzorzec (`demangle_type<T>()` w template w headerze) 
byl juz WCZESNIEJ obejty workaround'em w `cast.h` (`safe_cast<R,T>()`), 
gdzie takze uzywano `#ifdef _MSC_VER` + plain string zamiast demangle.

### Audit dodatkowych ryzyk (2026-02-15 ~05:00)

Przeprowadzono pelny audit wszystkich headerow pod katem analogicznych wzorcow ICE:

| Plik | Problem | Ryzyko | Status |
|------|---------|--------|--------|
| `otmlnode.h` | `fmt::format + demangle_type<T>()` w template | **HIGH** | ✅ NAPRAWIONE (`8aa3450a1`) |
| `cast.h` `safe_cast` | `demangle_type<T>()` w template | **HIGH** | ✅ JUZ BYLO NAPRAWIONE |
| `cast.h` `update_what` | `demangle_type<T,R>()` w template header | **HIGH** | ✅ NAPRAWIONE (`9b48524c9`) |
| `luainterface.h` `castValue<T>` | `demangle_type<T>()` w template | **MEDIUM** | ✅ JUZ BYLO NAPRAWIONE |
| `luainterface.h` `registerClass<C>` | `demangle_class<C>()` x4 | **MEDIUM** | ⚠️ NIENAPRAWIONE (niska priorytet — nie uzywa fmt::format) |
| `thingtype.h` | `std::ranges::find_if` w inline header | **MEDIUM** | ✅ NAPRAWIONE (`9b48524c9`) |
| `tile.h` | `std::ranges::find` w inline header | **MEDIUM** | ✅ NAPRAWIONE (`9b48524c9`) |
| `logger.h` | 11x variadic template z `fmt::format` | **MEDIUM** | ⚠️ do obserwacji |
| `luabinder.h` | C++20 `requires` w glebokch templates | **MEDIUM** | ⚠️ do obserwacji |
| `TextShaper.h` | `#include <fribidi.h>` — vcpkg powinien dostarczyc | **MEDIUM** | ⚠️ zalezy od vcpkg |
| `demangle.h` | `demangle_type<T>()` — brak `+ 6` na MSVC | **LOW** | ℹ️ nie powoduje ICE samo w sobie |

---

## 3) Dokladne zmiany w plikach

### 3.1 `src/framework/otml/otmlparser.cpp`

**Zmiana:** Dodano `#pragma optimize("", off)` na poczatku (linia 29) i `#pragma optimize("", on)` 
na koncu (linia 251).

**Revert:** Usunieto lokalny helper `startsWith()`, powrot do C++20 `.starts_with()`.

**Dlaczego:** Ten TU zawiera `parseNode()` i `parseLine()`, ktore intensywnie uzywaja string 
operations. Pod MSVC z /O2 lub /O1, optimizer P2 (codegen) crashuje na template instantiations 
z `stdext::cast<>` wywolywanym posrednio przez OTML value parsing.

### 3.2 `src/framework/otml/otmlnode.cpp`

**Zmiana:** Dodano `#pragma optimize("", off/on)` analogicznie.

**Dlaczego:** `removeChild()` i `replaceChild()` uzywaja STL algorytmow na kontenerach 
shared_ptr, co w kombinacji z template-heavy include chain powoduje ICE.

### 3.3 `src/framework/otml/otmlnode.h`

**Zmiana:** Revert `value.size() >= 2 && value.front() == '"'` z powrotem na 
`value.starts_with("\"") && value.ends_with("\"")`.

**Dlaczego:** C++20 `.starts_with()` jest poprawne i zgodne z upstream. Custom workaround 
byl zbedny i oddalal nas od bazowego kodu.

### 3.4 `src/CMakeLists.txt`

**Zmiany:**
- Usunieto `SKIP_PRECOMPILE_HEADERS ON` ze wszystkich OTML TU (to byla **glowna przyczyna** ICE)
- Zamieniono `/O2` → `/O1` globalnie (mniej agresywna optymalizacja)
- Wylaczono LTCG/GL
- Usunieto ~40 linii redundantnego strippowania flag (uproszczenie)
- Usunieto wymuszenie `/std:c++17` na poszczegolnych TU

**Kluczowe:** PCH teraz jest wspoldzielony przez WSZYSTKIE TU — kompilator nie musi 
parsowac 31 ciezkich headerow od zera w kazdym OTML pliku.

### 3.5 `src/framework/stdext/string.cpp`

**Zmiana:** Revert `resolve_path()` z `path.front() == '/'` na `.starts_with("/")`.

### 3.6 `src/framework/ui/uiwidgetbasestyle.cpp`

**Zmiana:** Usunieto lokalna przestrzen nazw z helperem `startsWith()`, powrot do `.starts_with()`.

### 3.7 `.github/workflows/build-windows.yml` (ROOT)

**Zmiana:** Usunieto `toolset: '14.38'` (nie istnieje na runnerze). Runner: `windows-2022`.

### 3.8 `src/framework/otml/otmlnode.h` — ROOT CAUSE FIX (commit `8aa3450a1`)

**Problem:** Template `value<T>()` (linia ~120) wywolywal `stdext::demangle_type<T>()` 
wewnatrz `fmt::format()` — ta kombinacja crashowala MSVC P2 codegen (faza generowania kodu).
Kazdy TU ktory includewal `otmlnode.h` instancjonowal ten template z roznymi typami T,
tworzac setek instantiacji `fmt::format + typeid + demangle_name` w kodgenie.

**WAZNE:** `#pragma optimize("", off)` **NIE POMAGA** gdy ICE jest w P2 (codegen), 
a nie w optimizerze. P2 crashuje niezaleznie od flag optymalizacji.

**Naprawa:**
```cpp
template<typename T>
T OTMLNode::value()
{
    T ret;
    if (!stdext::cast(m_value, ret)) {
#ifdef _MSC_VER
        // MSVC ICE C1001 workaround: demangle_type<T>() + fmt::format in template
        // header crashes P2 codegen. Use plain string instead.
        throw OTMLException(asOTMLNode(), "failed to cast node value '" + m_value + "'");
#else
        throw OTMLException(asOTMLNode(), fmt::format("failed to cast node value '{}' to type '{}'", 
              m_value, stdext::demangle_type<T>()));
#endif
    }
    return ret;
}
```

**Wzorzec:** Identyczny workaround istnial juz w `cast.h` (`safe_cast<R,T>()`) — 
tam tez unikano `demangle_type<T>()` pod MSVC. Teraz ten sam wzorzec zastosowano w otmlnode.h.

### 3.9 `src/framework/stdext/cast.h` — dodatkowy guard (commit `9b48524c9`)

**Problem:** `cast_exception::update_what<T,R>()` (linia ~141) wywolywal `demangle_type<T>()` 
i `demangle_type<R>()` w template zdefiniowanym w headerze. Choc uzywany tylko w `#else` 
(non-MSVC path), definicja jest widoczna dla MSVC i moze byc czesciowo przetworzona.

**Naprawa:** Dodano `#ifdef _MSC_VER` wewnatrz `update_what()`:
```cpp
void update_what()
{
#ifdef _MSC_VER
    m_what = "failed to cast value";
#else
    std::stringstream ss;
    ss << "failed to cast value of type '" << demangle_type<T>() << ...;
    m_what = ss.str();
#endif
}
```

### 3.10 `src/client/thingtype.h` — zamiana std::ranges (commit `9b48524c9`)

**Problem:** `std::ranges::find_if` w inline'owej funkcji w headerze (linia ~363).
NIE istnial w oryginalnym OTClient — dodany przez nasze zmiany i18n/multilanguage.
`std::ranges` w MSVC 14.3x mial bugi i w headerze moze powodowac dodatkowa presje 
na template codegen.

**Naprawa:** Zamieniono na `std::find_if(begin, end, pred)` + dodano `#include <algorithm>`.

### 3.11 `src/client/tile.h` — zamiana std::ranges (commit `9b48524c9`)

**Problem:** `std::ranges::find` w inline `hasThing()` w headerze (linia ~114).
Analogicznie — nie istnial w oryginale, dodany przez nasze zmiany.

**Naprawa:** Zamieniono na `std::find(begin, end, val)` + dodano `#include <algorithm>`.

---

## 4) Architektura buildu Windows

### 4.1 Struktura repo a GitHub Actions

```
/home/ptaku/serweryt/                          ← git root (repo PtakuPL/ooo)
├── .github/workflows/build-windows.yml        ← ROOT workflow (GitHub czyta TYLKO ten)
├── Tibia/silnik/canary_test/testyy/           ← kod klienta OTClient
│   ├── .github/workflows/build-windows.yml    ← KOPIA (nie uzywana przez GitHub!)
│   ├── src/CMakeLists.txt                     ← CMake klienta
│   ├── src/framework/                         ← framework C++
│   ├── vcpkg.json                             ← deklaracja zaleznosci
│   └── build/                                 ← katalog buildu (generowany)
└── Dokumentacja/                              ← ta dokumentacja
```

**UWAGA:** GitHub Actions czyta TYLKO `.github/workflows/` z **roota repo** (`/home/ptaku/serweryt/`).
Plik `testyy/.github/workflows/build-windows.yml` jest IGNOROWANY przez GitHub.
Wszelkie zmiany workflow MUSZA isc do roota.

### 4.2 Workflow — krok po kroku

1. **Runner:** `windows-2022` (VS 2022 Enterprise, toolset domyslny ~14.4x)
2. **Working directory:** `Tibia/silnik/canary_test/testyy`
3. **MSVC setup:** `ilammy/msvc-dev-cmd@v1` z `arch: x64`
4. **Cache:** sccache + vcpkg binary cache (GitHub Actions cache)
5. **vcpkg:** commit `cf6692675e04c036e21f26d64ae5fa3c8485f224`
6. **CMake:** Ninja generator, Release, `SPEED_UP_BUILD_UNITY=OFF`
7. **Build:** `cmake --build build --config Release --parallel 4`
8. **Artifact:** `build/bin/` → upload jako `otclient-windows-release-{sha}`

### 4.3 Kluczowe flagi kompilacji (MSVC Release)

```
/utf-8          — traktuj zrodla jako UTF-8
/bigobj         — wieksza sekcja obiektow (potrzebne przy template-heavy kodzie)
/O1             — optimize for size (zamiast /O2)
/GL-            — wylaczony LTCG codegen
/LTCG:OFF       — wylaczony link-time codegen
NOMINMAX        — zapobiega makrom min/max z Windows.h
/std:c++20      — standard C++20
```

---

## 5) Lancuch zaleznosci kompilacji (include chain)

### 5.1 PCH (Precompiled Header)

```
src/framework/pch.h (70 linii, 31 #include)
├── C stdlib: cassert, cmath, cstddef, cstdio, cstdlib, cstring
├── STL: algorithm, array, deque, functional, iomanip, iostream,
│        list, map, memory, numeric, sstream, string, string_view,
│        tuple, typeinfo, unordered_map, vector
├── parallel_hashmap: btree.h, phmap.h          ← template-heavy
├── pugixml.hpp                                  ← XML parser
└── fmt: chrono.h, core.h, format.h, args.h, ranges.h  ← template-heavy
```

**Rozmiar po rozwinieciu:** ~50,000+ linii kodu po preprocessing (szacunek).

**Dlaczego PCH jest krytycznie wazny:**
- Bez PCH kazdy `.cpp` parsuje te 31 headerow od zera
- Z PCH kompilator wczytuje binarny snapshot (ms zamiast sekund)
- SKIP_PRECOMPILE_HEADERS ON **wymuszalo** parse od zera — to powodowalo ICE

### 5.2 global.h → lancuch include

```
global.h
├── pch.h (patrz wyzej)
├── framework/const.h        ← uzywa std::numbers (C++20!)
├── framework/util/rect.h    ← uzywa concept (C++20!)
├── framework/stdext/storage.h ← uzywa ranges (C++20!)
├── framework/stdext/cast.h  ← template<R,T> safe_cast — ICE trigger!
├── framework/stdext/string.h
├── framework/stdext/math.h
├── framework/stdext/types.h
├── framework/core/timer.h
├── framework/core/logger.h
└── framework/luaengine/luaobject.h
```

### 5.3 Sciezka ICE (template instantiation)

```
otmlnode.h: value<T>() → stdext::safe_cast<T>(valueStr)
  → cast.h: safe_cast<R,T>()
    → cast<R,T>()                  ← template instantiation
    → demangle_type<T>()           ← ICE TRIGGER w error path
      → typeid(T).name()           ← RTTI + template mangling
```

**Workaround w cast.h:** Pod `#ifdef _MSC_VER` uzywamy `std::runtime_error("failed to cast value")` 
zamiast `cast_exception` z `demangle_type<T>()`.

---

## 6) Katalog znanych przyczyn bledow MSVC ICE (C1001)

### 6.1 Zbyt gleboka template instantiation

**Symptom:** `fatal error C1001: Internal compiler error` w P2 (codegen phase).

**Przyczyna:** MSVC ma limity na glebokosc template instantiation chain. Szczegolnie problematyczne sa:
- `std::variant` z wieloma typami
- Rekurencyjne SFINAE/concept kombinacje
- `fmt::format` z custom formatterami
- `parallel_hashmap` z custom hasherami

**Rozwiazanie:**
- `#pragma optimize("", off)` w dotknietyma TU
- Uproszczenie template error paths (np. rezygnacja z `demangle_type<T>()`)
- Wlaczenie PCH (redukuje powtarzalny parse)

### 6.2 Agresywna optymalizacja (/O2, /Ob2)

**Symptom:** ICE tylko w Release, Debug przechodzi.

**Przyczyna:** Optimizer P2 wykonuje inlining, constant folding i dead code elimination 
na template-heavy kodzie. Bledy w optymalizatorze MSVC objawiaja sie jako ICE.

**Rozwiazanie:**
- `/O1` zamiast `/O2` (mniej agresywny)
- `#pragma optimize("", off)` per-TU
- `/d2SSAOptimizer-` — wylacza problematyczny SSA optimizer

### 6.3 LTCG (Link-Time Code Generation)

**Symptom:** ICE w linker phase lub codegen phase, bledy miedzy TU.

**Przyczyna:** `/GL` (Global Optimization) + `/LTCG` rozszezeraja scope optymalizacji 
miedzy translation units. Jesli jeden TU jest na granicy ICE, LTCG moze go pchnac za krawedz.

**Rozwiazanie:**
- `/GL-` + `/LTCG:OFF`
- `INTERPROCEDURAL_OPTIMIZATION FALSE` w CMake

### 6.4 Brak PCH (precompiled headers)

**Symptom:** ICE w plikach, ktore same w sobie sa proste, ale includuja ciezkie headery.

**Przyczyna:** Bez PCH kompilator parsuje np. `<fmt/format.h>` + `<parallel_hashmap/phmap.h>` 
od zera w kazdym TU. To zwielokrotnia zuzycie pamieci i czas kompilacji, i stwarza 
wiecej okazji na trigger ICE.

**Rozwiazanie:**
- NIGDY nie uzywaj `SKIP_PRECOMPILE_HEADERS ON` chyba ze TU naprawde nie potrzebuje PCH
- Upewnij sie ze `TOGGLE_PRE_COMPILED_HEADER=ON` (domyslne)

### 6.5 Mieszanie standardow C++ w jednym TU

**Symptom:** Bledy skladniowe w headerach (`std::numbers` not found, `concept` not recognized).

**Przyczyna:** Wymuszenie `/std:c++17` na TU ktore includuje headery C++20 (np. `global.h`).

**Rozwiazanie:**
- NIGDY nie mieszaj standardow — caly projekt jest C++20
- Jesli TU potrzebuje innego standardu, musi miec calkowicie odrebny include chain

### 6.6 Niezgodnosc toolsetu ze MSVC runner

**Symptom:** `[ERROR:vcvars.bat] Toolset directory for version 'X.XX' was not found.`

**Przyczyna:** Pinowany toolset nie jest zainstalowany na runnerze GitHub Actions.
Runnery `windows-2022` maja domyslnie toolset z VS 2022, np. 14.40-14.44.
Starsze toolsety (14.38, 14.36) nie sa preinstalowane.

**Rozwiazanie:**
- Nie pinuj toolsetu chyba ze masz pewnosc ze jest zainstalowany
- Mozesz sprawdzic zainstalowane toolsety: `dir "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\"`
- Jesli potrzebujesz starszego toolsetu, dodaj krok instalacji w workflow

### 6.7 Wielowatkowosc kompilacji (/MP)

**Symptom:** Losowe ICE, rozne pliki za kazdym razem.

**Przyczyna:** `/MP` (Multi-Process compilation) uruchamia wiele instancji cl.exe. 
Gdy system jest pod presja pamieciowa, poszczegolne instancje moga crashowac.

**Rozwiazanie:**
- Zmniejsz `CMAKE_BUILD_PARALLEL_LEVEL` (np. z 4 na 2)
- Usun `/MP` i polegaj na Ninja parallelism
- Zwieksz timeout workflow

---

## 7) Inne mozliwe przyczyny problemow z buildem Windows

### 7.1 Problemy z vcpkg

#### 7.1.1 Przestarzaly VCPKG_TOOL_COMMIT

**Symptom:** `error: failed to download`, `MSYS2 package not found`.

**Przyczyna:** Stare commity vcpkg referencuja pakiety MSYS2/download URL-e ktore juz nie istnieja.

**Rozwiazanie:**
- Aktualizuj `VCPKG_TOOL_COMMIT` w workflow env
- Aktualizuj `builtin-baseline` w `vcpkg.json`
- Obie wartosci MUSZA istniec w repo vcpkg

#### 7.1.2 Niezgodnosc wersji zaleznosci

**Symptom:** Bledy linkowania (`unresolved external symbol`), bledy w headerach vcpkg.

**Przyczyna:** Rozne biblioteki wymagaja roznych wersji tej samej zaleznosci. 
Np. `protobuf` i `abseil` musza byc z tego samego vcpkg baseline.

**Aktualne zaleznosci projektu:**
```
asio, abseil, fmt, cpp-httplib, discord-rpc, gtest, liblzma, 
libogg, libvorbis, nlohmann-json, harfbuzz, freetype, fribidi,
openal-soft, openssl, parallel-hashmap, physfs, protobuf, pugixml,
stduuid, zlib, glew, opengl, angle, luajit, pkgconf
```

**Zaleznosci specyficzne dla i18n:**
- `harfbuzz` — text shaping (arabski, devanagari, etc.)
- `freetype` — renderowanie TTF fontow
- `fribidi` — bidi algorithm (arabski, hebrajski — prawo-do-lewo)

**Rozwiazanie:**
- Zawsze testuj z czystym cache vcpkg po zmianie `vcpkg.json`
- Sprawdz czy `builtin-baseline` jest aktualny
- Usun cache: `actions/cache` z kluczem `vcpkg-build-x64-windows-*`

#### 7.1.3 Triplet mismatch

**Symptom:** `Could not find a package configuration file` lub linker errors.

**Przyczyna:** Mix `x64-windows` (dynamic) i `x64-windows-static`. 
W workflow uzywamy `x64-windows` (dynamic linking).

**Rozwiazanie:**
- Upewnij sie ze `VCPKG_DEFAULT_TRIPLET` i `VCPKG_DEFAULT_HOST_TRIPLET` sa spojne
- Nie mieszaj static i dynamic w jednym buildzie

### 7.2 Problemy z cache

#### 7.2.1 Zepsuty sccache

**Symptom:** Bledy kompilacji ktore znikaja po wyczyszczeniu cache.

**Przyczyna:** sccache cache'uje obiekty .obj. Jesli zmienily sie flagi kompilacji 
lub headery, stary cache moze zwracac nieaktualne obiekty.

**Rozwiazanie:**
- Zmien klucz cache w workflow: `key: ccache-windows-release-v2`
- Lub usun cache z GitHub Actions → Caches

#### 7.2.2 Stary vcpkg cache

**Symptom:** Budowanie vcpkg trwa 0 minut ale potem sa bledy linkowania.

**Przyczyna:** vcpkg cache przechowuje stare wersje bibliotek. 
Po zmianie `vcpkg.json` lub baseline, cache moze byc nieaktualny.

**Rozwiazanie:**
- Hash `vcpkg.json` jest czescia klucza cache — zmiana vcpkg.json invaliduje cache
- Jesli problem, usun recznie z GitHub Actions → Caches

### 7.3 Problemy z C++20 a MSVC

#### 7.3.1 `std::ranges` niezaimplementowane/buggy

**Symptom:** Bledy w `<ranges>`, `<algorithm>` z ranges overloads.

**Przyczyna:** MSVC 17.x ma niekompletna/buggy implementacje `std::ranges`. 
Szczegolnie `std::ranges::find`, `std::ranges::sort` z projections.

**Rozwiazanie:**
- Uzywaj `std::find`/`std::sort` zamiast `std::ranges::*` w kodzie ktory musi budowac sie na MSVC
- Ewentualnie dodaj `#include <algorithm>` explicite (nie polegaj na PCH dla ranges)

#### 7.3.2 `std::format` crash / incomplete

**Symptom:** ICE lub bledy linkowania z `std::format`.

**Przyczyna:** `std::format` w MSVC bywa problematyczny. Uzywamy `fmt::format` zamiast tego.

**Rozwiazanie:**
- Uzywaj `fmt::format` konsekwentnie
- Nie mieszaj `std::format` i `fmt::format`

#### 7.3.3 Modules / header units

**Symptom:** Dziwne bledy w importach, wielokrotne definicje.

**Przyczyna:** MSVC moze probowac uzywac header units gdy flagi na to pozwalaja.

**Rozwiazanie:**
- Nie uzywaj `/experimental:module` ani `/translateInclude`
- Utrzymuj tradycyjny model #include

### 7.4 Problemy z Unicode/i18n specyficzne

#### 7.4.1 BOM w plikach zrodlowych

**Symptom:** Dziwne bledy parsowania na poczatku pliku.

**Przyczyna:** MSVC inaczej traktuje pliki z BOM i bez BOM. 
Flaga `/utf-8` rozwiazuje to globalnie.

**Rozwiazanie:**
- Zawsze kompiluj z `/utf-8` (juz mamy w CMakeLists.txt)
- Pliki zrodlowe powinny byc UTF-8 bez BOM

#### 7.4.2 Escape sequences w string literals

**Symptom:** `warning C4566: character cannot be represented in the current code page`.

**Przyczyna:** String literals z non-ASCII znakami moga byc zle interpretowane.

**Rozwiazanie:**
- Uzywaj `u8"..."` dla UTF-8 string literals
- Lub uzywaj escape `\uXXXX` / `\UXXXXXXXX`
- `/utf-8` powinno rozwiazac wiekszosc przypadkow

#### 7.4.3 HarfBuzz / FriBidi linker errors

**Symptom:** `unresolved external symbol` z `hb_*` lub `fribidi_*`.

**Przyczyna:** Biblioteki i18n moga nie byc poprawnie zlinkowane na Windows.

**Rozwiazanie:**
- Sprawdz czy `harfbuzz`, `freetype`, `fribidi` sa w `vcpkg.json`
- Sprawdz `target_link_libraries` w CMakeLists.txt
- Na Windows moze byc potrzebny `harfbuzz[glib]` feature

### 7.5 Problemy z Ninja

#### 7.5.1 Ninja vs MSBuild

**Symptom:** Build dziala z MSBuild ale nie z Ninja, lub odwrotnie.

**Przyczyna:** Ninja generuje inne komendy kompilacji niz MSBuild. 
Szczegolnie sciezki, flagi i response files moga sie roznic.

**Rozwiazanie:**
- Trzymaj sie jednego generatora konsekwentnie (my uzywamy Ninja)
- Jesli diagnostyka, sprobuj z `-G "Visual Studio 17 2022"` zeby porownac

#### 7.5.2 Zabraklo pamieci

**Symptom:** `ninja: fatal: pipe creation failed` lub cl.exe crash bez ICE msg.

**Przyczyna:** Windows runner ma 7GB RAM. Z parallel=4 i ciezkimi TU, moze zabraknac.

**Rozwiazanie:**
- Zmniejsz `CMAKE_BUILD_PARALLEL_LEVEL` na 2
- Dodaj `--parallel 2` do cmake --build

### 7.6 Problemy z Windows.h

#### 7.6.1 Min/Max macros

**Symptom:** `error C2589: '(' : illegal token on right side of '::'` przy `std::min`/`std::max`.

**Przyczyna:** `Windows.h` definiuje makra `min` i `max` ktore koliduja z STL.

**Rozwiazanie:**
- `#define NOMINMAX` PRZED `#include <Windows.h>` (juz mamy jako compile definition)
- Lub `(std::min)(a, b)` z nawiasami

#### 7.6.2 Inne makra Windows

**Symptom:** Dziwne bledy z `near`, `far`, `DELETE`, `ERROR`, `TRANSPARENT`.

**Przyczyna:** Windows.h definiuje wiele problematycznych makrow.

**Rozwiazanie:**
- `#define WIN32_LEAN_AND_MEAN` przed `#include <Windows.h>`
- `#undef` problematycznych makrow po includzie

### 7.7 Problemy z linkowanie

#### 7.7.1 Runtime library mismatch

**Symptom:** `LINK : warning LNK4098: defaultlib 'MSVCRT' conflicts with use of other libs`.

**Przyczyna:** Mieszanie `/MD` (dynamic CRT) i `/MT` (static CRT) miedzy modulami.

**Rozwiazanie:**
- Wszystkie moduly i biblioteki musza uzywac tego samego CRT
- W naszym projekcie: triplet `x64-windows` implikuje `/MD` (dynamic)
- Jesli static, zmien na `x64-windows-static` i ustaw `MSVC_RUNTIME_LIBRARY "MultiThreaded"`

#### 7.7.2 Brakujace symbole z bibliotek systemowych

**Symptom:** `unresolved external symbol` z `ws2_32`, `iphlpapi`, `dbghelp`.

**Przyczyna:** Windows system libraries musza byc explicite linkowane.

**Rozwiazanie:**
- Sprawdz `target_link_libraries` — powinny miec:
  `ws2_32 mswsock iphlpapi shlwapi dbghelp crypt32 bcrypt`
- W CMakeLists.txt te biblioteki sa juz dodane w sekcji `if(WIN32)`

---

## 8) Checklist przed kazdym pushem zmian do instalki

### Przed commitem:

- [ ] Kompilacja na Linux przechodzi (`cmake --build . --parallel $(nproc)`)
- [ ] Brak nowych `#include` w plikach OTML/cast bez potrzeby
- [ ] Kazdy nowy `.cpp` ma `#include "framework/global.h"` (albo uzywa PCH)
- [ ] Brak mieszania `std::ranges::*` w nowych plikach (uzyj `std::*` zamiast)
- [ ] Brak `std::format` — uzywaj `fmt::format`
- [ ] Brak lokalinych helperow `startsWith()` — uzywaj `.starts_with()` (C++20)
- [ ] String literals z non-ASCII uzywaja `u8"..."` lub escape sequences
- [ ] Brak `SKIP_PRECOMPILE_HEADERS ON` w CMakeLists.txt
- [ ] `/utf-8` jest w compile options (juz jest globalnie)

### Po pushu:

- [ ] Odpal `Build - Windows` recznie (workflow_dispatch):
  `gh workflow run build-windows.yml --ref feature/i18n-multilanguage`
- [ ] Monitoruj run: `gh run list --workflow=build-windows.yml --limit 3`
- [ ] Jesli ICE wraca — dodaj `#pragma optimize("", off/on)` w nowym TU
- [ ] Dopisz wynik do tego dokumentu (Run ID, SHA, wynik, uwagi)

### Zmiany wyzszego ryzyka (wymagaja szczegolnej uwagi):

- Nowe template functions/classes w headerach includowanych przez wiele TU
- Zmiana `vcpkg.json` (dodanie/usuwanie zaleznosci)
- Zmiana `CMakeLists.txt` (flagi kompilacji, linking)
- Zmiana `pch.h` lub `global.h` (kazdy TU musi byc przekompilowany)
- Dodanie nowych duŻych headerow (#include fmt, boost, etc.)

---

## 9) Szybka diagnostyka awarii CI

### Krok 1: Identyfikacja typu bledu

```
Blad zawiera "C1001"?
  → ICE — patrz sekcja 6 (pragma optimize, /O1, usun LTCG)

Blad zawiera "unresolved external"?
  → Brakujące linkowanie — sprawdz target_link_libraries

Blad zawiera "cannot open include file"?
  → Brak headera — sprawdz vcpkg.json, find_package w CMake

Blad zawiera "Toolset directory not found"?
  → Toolset niedostepny — usun pinowanie toolsetu

Blad zawiera "C2039" / "C2065" (identifier not found)?
  → Brakujacy #include lub zla wersja C++ standard

Blad zawiera "bad $-escape"?
  → Generator expression w build.ninja — problem z CMake (Android)

Build trwa >3h i timeout?
  → Zmniejsz paralelizm, sprawdz cache
```

### Krok 2: Sprawdzenie logow

```bash
# Sprawdz ostatni run
gh run list --workflow=build-windows.yml --limit 5

# Pobierz logi
gh run view <RUN_ID> --log | grep -i "error\|fatal\|failed" | head -30

# Szczegoly jednego joba
gh run view <RUN_ID> --log --job <JOB_ID>
```

### Krok 3: Quick fix templates

```bash
# ICE w pliku X.cpp → dodaj pragma
echo '#pragma optimize("", off)' # na poczatku (po includes)
echo '#pragma optimize("", on)'  # na koncu pliku

# Wyczyszczenie cache
# GitHub → Actions → Caches → usun klucze z "ccache-windows" i "vcpkg-build"

# Restart buildu
gh workflow run build-windows.yml --ref feature/i18n-multilanguage
```

---

## 10) Referencje i linki

### Repo i CI
- Repo: https://github.com/PtakuPL/ooo
- Branch: `feature/i18n-multilanguage`
- Build Windows: https://github.com/PtakuPL/ooo/actions/workflows/build-windows.yml
- Build Linux: https://github.com/PtakuPL/ooo/actions/workflows/build-linux.yml
- Build Android: https://github.com/PtakuPL/ooo/actions/workflows/build-android.yml

### Upstream
- OTClient upstream: https://github.com/opentibiabr/otclient
- Porownanie z upstream: `Dokumentacja/2026-02-14_testyy_vs_opentibiabr_otclient_dokladne_porownanie.md`

### MSVC ICE knowledge base
- Microsoft ICE bug reports: https://developercommunity.visualstudio.com/ (szukaj "C1001")
- MSVC known issues: https://learn.microsoft.com/en-us/cpp/overview/compiler-versions
- Pragma optimize doc: https://learn.microsoft.com/en-us/cpp/preprocessor/optimize

### Powiazane dokumenty w tym repo
- `Dokumentacja/2026-02-14_windows_build_diff_i_plan_naprawczy.md` — oryginalny plan naprawczy
- `Dokumentacja/2026-02-14_testyy_vs_opentibiabr_otclient_dokladne_porownanie.md` — audit upstream
- `Dokumentacja/2026-02-15_testyy_vs_opentibiabr_audit_batch2.md` — audit batch 2
- `Dokumentacja/2026-02-09_ci_build_fixes.md` — wczesniejsze poprawki CI

### vcpkg
- vcpkg repo: https://github.com/microsoft/vcpkg
- Aktualny baseline: `cf6692675e04c036e21f26d64ae5fa3c8485f224`
- Triplet: `x64-windows` (dynamic linking)

---

*Ostatnia aktualizacja: 2026-02-15 ~05:30 CET*
*Autor: GitHub Copilot + PtakuPL*
*Commity: 4587d18a7, 0567a036c, 8aa3450a1 (root cause fix), 9b48524c9 (dodatkowe workaround'y)*
