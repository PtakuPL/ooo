# Błędne kompilacje Windows — MSVC ICE C1001

**Data:** 2026-02-17  
**Status:** DOKUMENT HISTORYCZNY (C1001)  
**Dotyczy:** OTClient — Build Windows (Release) workflow na GitHub Actions  
**Repo:** PtakuPL/ooo, branch master  

## Aktualizacja 2026-02-21 (stan biezacy)

Ten dokument opisuje glownie fale bledow C1001 z 2026-02-17.
Aktualny stan CI Windows/Linux i nowe root-cause (m.in. `vcpkg` download 502 przy `gtest`) jest opisany tutaj:

- `Dokumentacja/01_Instalka_Klient/2026-02/2026-02-21_ci_linux_windows_analiza_poprawek_v3.md`
- `Dokumentacja/01_Instalka_Klient/2026-02/2026-02-21_lista_bledow_od_2026-02-20_linux_windows.md` (zbiorcza lista bledow od 2026-02-20 i opis jak byly naprawiane)

Nowy run Windows odpalony recznie po aktualizacji:
- `22256688321` (`in_progress` na moment zapisu raportu)

---

## 1. Co to znaczy że kompilacja Windows nie przechodzi

Kompilacja Windows to build OTClienta (instalki gry) na GitHub Actions za pomocą kompilatora **MSVC** (Microsoft Visual C++) na runnerze `windows-2022`. Gdy build failuje, oznacza to że:

- **Nie powstaje plik `otclient.exe`** — nie ma nowej wersji instalki do pobrania
- Błąd nie jest w naszym kodzie C++ — to **bug w samym kompilatorze MSVC** (Internal Compiler Error C1001)
- Kompilator MSVC crashuje wewnętrznie podczas optymalizacji naszego kodu (złożone szablony C++20)
- Build Linux i Android mogą przechodzić bez problemu — błąd dotyczy TYLKO kompilatora Microsoftu

### Objawy w logach GitHub Actions

```
Internal compiler error: otmlparser.cpp#L35
Internal compiler error: otmlnode.cpp#L69
Internal compiler error: luabinder.h#L171
Process completed with exit code 1
```

Crash location w kompilatorze: `p2/main.cpp:258` — moduł SSA optimizer MSVC.

---

## 2. Dlaczego to się dzieje

### 2.1 MSVC 14.44 ma buga

Runner `windows-2022` na GitHub Actions ma zainstalowany toolset **MSVC 14.44** (`_MSC_VER=1944`). Ten toolset ma znany bug w module **SSA optimizer** — crashuje na:

1. **Złożonych szablonach C++20** — plik `luabinder.h` z wiązaniami Lua ↔ C++ (`std::function`, `std::mem_fn`, variadic templates, concepts)
2. **`fmt::format()` w template headers** — wywołanie `fmt::format()` wewnątrz template `value<T>()` w `otmlnode.h` crashuje codegen
3. **`demangle_type<T>()`** — template z `typeid(T).name()` powoduje ICE gdy jest intensywnie instantiowany
4. **PCH (Precompiled Headers)** — interakcja PCH z optymalizatorem potęguje problem

### 2.2 Dostępne toolsety na runnerze

GitHub zaktualizował obraz `windows-2022` i zostały TYLKO 2 toolsety:
- `14.44.35207` (MSVC 2022 17.12) — **MA BUGA ICE C1001**
- `14.29.30133` (VS2019 compat) — **za stary** (`_MSC_VER=1929 < 1932` wymagane przez `compiler.h`)

Nie ma możliwości ucieczki na pośredni toolset (14.38-14.43 usunięte z obrazu).

---

## 3. Co trzeba było zrobić — workaroundy C++

Problem rozwiązuje się **zmianami w plikach C++**, a NIE w workflow/cmake. Wielokrotnie próbowaliśmy zmian w workflow (filtrowanie toolsetów, clang-cl, wyłączanie IPO) — to nigdy nie pomagało.

### Zasada: na branchu `serwer-7.4` build przeszedł (#4364), bo tam były aktywne workaroundy C++.

Na `master` te workaroundy zostały **przypadkowo usunięte** przez commity czyszczące (`a61438afe` Initial cleaned master, `bcf4906aa` i18n Faza 5-7).

### 3.1 Lista workaroundów C++ (7 plików)

#### `otmlnode.cpp` — wyłączenie optymalizacji + wyciągnięcie throw z template
```cpp
// Na początku pliku:
#ifdef _MSC_VER
#pragma optimize("", off)
#endif

// Osobna funkcja non-template zamiast inline throw w value<T>():
void throwOTMLNodeCastError(const OTMLNodePtr& node, const std::string& value)
{
    throw OTMLException(node, std::string("failed to cast node value '") + value + "'");
}

// Na końcu pliku:
#ifdef _MSC_VER
#pragma optimize("", on)
#endif
```
Dodatkowo: `std::find()` zamiast `std::ranges::find()`, `std::string` concat zamiast `fmt::format()`.

#### `otmlnode.h` — deklaracja non-template throw function
```cpp
[[noreturn]] void throwOTMLNodeCastError(const OTMLNodePtr& node, const std::string& value);

// W template value<T>() zamiast inline throw:
if (!stdext::cast(m_value, ret)) {
    throwOTMLNodeCastError(asOTMLNode(), m_value);
}
```

#### `otmlparser.cpp` — wyłączenie optymalizacji
```cpp
#ifdef _MSC_VER
#pragma optimize("", off)
#endif
// ... cały plik ...
#ifdef _MSC_VER
#pragma optimize("", on)
#endif
```
Dodatkowo: `std::to_string()` zamiast `stdext::unsafe_cast<string>()`.

#### `pch.h` — guard fmt includes
```cpp
#ifndef OTML_NO_FMT
#include <fmt/chrono.h>
#include <fmt/core.h>
#include <fmt/format.h>
// ...
#endif // OTML_NO_FMT
```

#### `exception.h` — guard fmt w base exception class
```cpp
#ifndef OTML_NO_FMT
#include <fmt/format.h>
// ... template ctor z fmt ...
#endif
```

#### `demangle.h` — fallback dla MSVC
```cpp
template<typename T> std::string demangle_type()
{
#ifdef _MSC_VER
    return "(type info unavailable on MSVC)";
#else
    return demangle_name(typeid(T).name());
#endif
}
```

#### `src/CMakeLists.txt` — flagi kompilacji per-file
```cmake
# OTML pliki: wyłączenie optymalizacji + SSA optimizer + PCH + fmt
set_source_files_properties(
  framework/otml/otmlparser.cpp
  framework/otml/otmlnode.cpp
  PROPERTIES COMPILE_FLAGS "/Od /d2SSAOptimizer- /Y- -DOTML_NO_FMT" SKIP_PRECOMPILE_HEADERS ON
)
# Inne pliki z ICE:
set_source_files_properties(
  framework/luaengine/luavaluecasts.cpp
  framework/luafunctions.cpp
  framework/ui/uiwidgetbasestyle.cpp
  PROPERTIES COMPILE_FLAGS "/Od /d2SSAOptimizer- /Y-" SKIP_PRECOMPILE_HEADERS ON
)
```

---

## 4. Chronologia prób naprawy (od najstarszej)

| Nr | Commit | Co próbowano | Typ zmiany | Wynik |
|---|---|---|---|---|
| 1 | `3e281f373` | Revert uproszczonego OTML cast | C++ | ❌ |
| 2 | `4587d18a7` | `#pragma optimize("", off)` + pin toolset 14.38 | C++ + workflow | ✅ (na tamtym runnerze) |
| 3 | `8aa3450a1` | ifdef `demangle_type<T>` w otmlnode.h | C++ | ❌ |
| 4 | `9a2b7d7ca` | Eliminacja ALL `fmt::format` z OTML | C++ | ✅ |
| 5 | `06d2c9d2e` | Disable PCH for OTML files | C++ | ✅ |
| 6 | `cdae4b4ad` | `OTML_NO_FMT` exclude fmt z OTML TUs via CMake | C++ + CMake | ✅ |
| 7 | `77d9cb2a4` | Extract throw from `value<T>()` template | C++ | ✅ ← **serwer-7.4 build #4364 PASSED** |
| 8 | `bcf4906aa` | **(!) Usunięcie workaroundów** — i18n Faza 5-7 | C++ (regresja) | ❌ buildy #4365-#4369 |
| 9 | `57ebac85a` | Revert clang-cl na MSVC cl.exe | Workflow | ❌ |
| 10 | `51c003a0a` | Usunięcie filtru toolset 14.44 | Workflow | ❌ |
| 11 | `1df3a8fac` | Per-file `/Od /d2SSAOptimizer- /Y-` **BEZ** workaroundów C++ | CMake | ❌ |
| 12 | `70c2ec058` | **Przywrócenie WSZYSTKICH workaroundów C++ z serwer-7.4** | C++ + CMake | ⏳ oczekuje |

### Kluczowa lekcja

**Zmiany w workflow/cmake NIGDY nie naprawiły ICE.** Jedyne co działa to modyfikacje samego kodu C++ — unikanie wzorców które crashują kompilator MSVC:
- Brak `fmt::format()` w template headers
- Brak `demangle_type<T>()` na ścieżce MSVC
- `#pragma optimize("", off)` na problematycznych TU
- Wyciągnięcie `throw` z template do osobnej non-template funkcji
- Wyłączenie PCH dla dotkniętych plików

---

## 5. ZASADY — jak uniknąć powtórki

1. **NIGDY nie usuwaj `#ifdef _MSC_VER` / `#pragma optimize` z plików OTML** — nawet przy "czyszczeniu" kodu
2. **NIGDY nie usuwaj `OTML_NO_FMT` guard z `pch.h`** — to nie jest "zbędny ifdef"
3. **NIGDY nie zamieniaj `throwOTMLNodeCastError()` na inline throw** w template `value<T>()`
4. **Przy merge/sync z upstream** — sprawdź czy workaroundy ICE nadal są obecne
5. **Branch `serwer-7.4`** — zawiera działające wersje plików, użyj jako referencję
6. **Build Linux PRZECHODZI = NIE ZNACZY że Windows przejdzie** — to są różne kompilatory

---

## 6. Powiązane dokumenty

- [2026-02-17_windows_build_fix_msvc_toolset.md](2026-02-17_windows_build_fix_msvc_toolset.md) — próba naprawy via toolset filter
- [2026-02-17_windows_build_ICE_C1001_analiza_i_plan.md](2026-02-17_windows_build_ICE_C1001_analiza_i_plan.md) — pełna analiza techniczna
- [2026-02-08_plan_fonty_unicode_kompilacja.md](2026-02-08_plan_fonty_unicode_kompilacja.md) — ogólny plan kompilacji
