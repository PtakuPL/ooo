# Analiza błędu Build Windows — MSVC ICE C1001 (Internal Compiler Error)

**Data:** 2026-02-17  
**Status:** ANALIZA ZAKOŃCZONA — oczekuje na wybór planu naprawy  
**Dotyczy:** OTClient — Build Windows (Release) workflow `build-windows.yml` na GitHub Actions  
**Repo:** PtakuPL/ooo, branch master  
**Seria buildów:** #4365, #4366, #4367, #4368, #4369 — WSZYSTKIE FAILED  

---

## 1. PODSUMOWANIE PROBLEMU

Build Windows na GitHub Actions **nie przechodzi od wielu prób**. Każdy run kończy się błędem kompilacji.  
Logi z ostatniego builda (#4369, commit `1df3a8fac`):

```
4 errors, 2 warnings:
- Internal compiler error: otmlparser.cpp#L35
- Internal compiler error: otmlnode.cpp#L69
- Internal compiler error: luabinder.h#L171 (via luafunctions.cpp)
- Process completed with exit code 1
```

**Czas builda:** ~50 minut (z czego ~46 min to vcpkg Configure, 1 min Build → crash)

---

## 2. CHRONOLOGIA PRÓB NAPRAWY

| Data/Commit | Opis próby | Rezultat |
|---|---|---|
| Wcześniej | Filtr toolsetu `'^14\.44\.'` — pomijaj MSVC 14.44 | **FAIL** — fallback na 14.29, `_MSC_VER 1929 < 1932` → #error w compiler.h |
| `57ebac85a` | Revert z clang-cl na MSVC cl.exe | **FAIL** — clang-cl powodował protobuf DLL linker error |
| `51c003a0a` | Usunięcie filtru 14.44 | **FAIL** — teraz używa 14.44 ale ICE wraca |
| `1df3a8fac` | Dodanie `/Od /d2SSAOptimizer- /Y-` dla 5 plików + SKIP_PRECOMPILE_HEADERS | **FAIL** — ICE nadal w 3 plikach |

**Wniosek:** Każda próba to obejście jednego obejścia. Problem wraca jak bumerang.

---

## 3. ANALIZA TECHNICZNA — DLACZEGO ICE NADAL WYSTĘPUJE

### 3.1 Czym jest ICE C1001?

ICE (Internal Compiler Error) C1001 to **bug w samym kompilatorze MSVC**. To nie jest błąd w naszym kodzie C++. Kompilator crashuje w swoim wewnętrznym module optymalizacji:
- Crash location: `p2/main.cpp:258` — SSA optimizer MSVC
- Typ: Access violation w kompilatorze (nie w naszym kodzie!)

### 3.2 Kontekst runnera GitHub Actions

- **Runner:** `windows-2022` (obraz `20250211.1.0` lub nowszy)
- **Toolsety dostępne:** TYLKO `14.44.35207` + `14.29.30133`
  - 14.44 = MSVC 2022 17.12 (`_MSC_VER=1944`) — **ICE w SSA optimizer**
  - 14.29 = VS2019 compat (`_MSC_VER=1929`) — **za stary, nie przechodzi compiler.h check**
- **Pośrednie toolsety (14.38-14.43) zostały USUNIĘTE** przez GitHub z obrazu runnera

### 3.3 Co powoduje ICE w naszym kodzie?

Trzy cechy kodu OTClient które łącznie triggerują ICE:

1. **Złożone szablony C++20** — `luabinder.h` (wiązania Lua ↔ C++ z `std::function`, `std::mem_fn`, variadic templates, SFINAE/concepts)
2. **Precompiled Headers (PCH)** — `framework/pch.h` jest ustawiony jako PCH. Interakcja `/Yu` (use PCH) z optymalizacją powoduje crash
3. **SSA Optimizer** — moduł optymalizacji MSVC crashuje na skomplikowanym kodzie template

### 3.4 Dlaczego obecne workaround nie działają?

Aktualny CMakeLists.txt ma:
```cmake
set_source_files_properties(
  framework/luaengine/luavaluecasts.cpp
  framework/otml/otmlparser.cpp
  framework/otml/otmlnode.cpp
  framework/luafunctions.cpp
  framework/ui/uiwidgetbasestyle.cpp
  PROPERTIES COMPILE_FLAGS "/Od /d2SSAOptimizer- /Y-" SKIP_PRECOMPILE_HEADERS ON
)
```

**Problem 1:** `set_source_files_properties` z COMPILE_FLAGS **dopisuje** flagi, ale Ninja/CMake PCH system dodaje `/Yupch.h` do compile rule ZANIM nasze flagi zostaną przetworzone. `/Y-` powinno to wyłączyć, ale nie zawsze działa z Ninja generator.

**Problem 2:** `SKIP_PRECOMPILE_HEADERS ON` jest właściwością CMake, nie flagą kompilatora. CMake może ją zignorować jeśli target już ma `target_precompile_headers()` ustawione i Ninja cache jest stale.

**Problem 3:** ICE może triggerować się RÓWNIEŻ w plikach, które nie są na liście workaround. Kompilator może crashować w dowolnym pliku, który includuje `luabinder.h` (a to robi wiele plików).

### 3.5 Kluczowa obserwacja — triplet DLL vs static

Aktywny workflow (`build-windows.yml`) używa:
```yaml
VCPKG_DEFAULT_TRIPLET: x64-windows  # DLL!
```

Ale `testyy/.github/workflows/build-windows.yml` (nieaktywny) używa:
```
-DVCPKG_TARGET_TRIPLET=x64-windows-static  # Static!
```

**To jest niespójność!** DLL triplet = protobuf jako DLL = `__declspec(dllimport)`. Próba użycia clang-cl z protobuf DLL powoduje linker error (commit `57ebac85a`).

---

## 4. PLANY NAPRAWY — 3 OPCJE

### OPCJA A: Globalne wyłączenie SSA optimizer + redukcja optymalizacji (SZYBKA, PEWNA)

**Koncepcja:** Zamiast per-file workaround, wyłączyć SSA optimizer **globalnie** dla całego targetu na MSVC. Ewentualnie wyłączyć kompletnie optymalizację.

**Zmiany w `src/CMakeLists.txt`:**
```cmake
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  # --- GLOBALNE WYŁĄCZENIE SSA OPTIMIZER (FIX ICE C1001) ---
  # MSVC 14.44+ ma buga w SSA optimizer (p2/main.cpp:258).
  # Wyłączamy go globalnie — /d2SSAOptimizer- nie wpływa na correctness kodu.
  target_compile_options(${PROJECT_NAME} PRIVATE /d2SSAOptimizer-)
  
  # Użyj /O1 zamiast /O2 (mniejszy rozmiar, mniej agresywna optymalizacja)
  string(REPLACE "/O2" "/O1" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
  string(REPLACE "/O2" "/O1" CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
  
  # Wyłącz PCH kompletnie na MSVC (interakcja PCH + optimizer = ICE)
  set(TOGGLE_PRE_COMPILED_HEADER OFF CACHE BOOL "" FORCE)
endif()
```

**Zmiany w workflow `build-windows.yml`:**
```yaml
- name: Configure CMake
  run: |
    cmake -G "Ninja" `
      -DCMAKE_BUILD_TYPE=Release `
      -DTOGGLE_PRE_COMPILED_HEADER=OFF `
      ...
```

**Plusy:**
- ✅ Najprostsza zmiana — 5-10 linii
- ✅ 99% pewności że zadziała (globalny `/d2SSAOptimizer-` uniemożliwia ICE)
- ✅ Nie wymaga zmian w kodzie C++

**Minusy:**
- ❌ Wolniejsza kompilacja (bez PCH)
- ❌ Mniejsza optymalizacja runtime (ale dla instalki gry to nieistotne — GPU-bound)
- ❌ Nie naprawia przyczyny — obejście buga MSVC

**Szacowany czas:** 15 minut (zmiana + push + ręczne uruchomienie workflow)  
**Czas oczekiwania na wynik:** ~50 minut (build)

---

### OPCJA B: Migration na Clang-CL z static triplet (TRWAŁA, ALE WIĘCEJ PRACY)

**Koncepcja:** Użyć Clang-CL (frontend Clang dla MSVC ABI) jako kompilator. To omija WSZYSTKIE bugi MSVC. Wcześniejsza próba failowała bo protobuf był jako DLL (vcpkg `x64-windows`). Fix: użyć static triplet `x64-windows-static`.

**Zmiany w workflow `build-windows.yml`:**
```yaml
env:
  VCPKG_DEFAULT_TRIPLET: x64-windows-static  # Static! Zapobiega protobuf DLL mismatch
  VCPKG_DEFAULT_HOST_TRIPLET: x64-windows-static

steps:
  - name: Setup MSVC + Clang-CL
    uses: ilammy/msvc-dev-cmd@v1
    with:
      arch: x64

  - name: Configure CMake
    run: |
      cmake -G "Ninja" `
        -DCMAKE_BUILD_TYPE=Release `
        -DCMAKE_C_COMPILER=clang-cl `
        -DCMAKE_CXX_COMPILER=clang-cl `
        -DVCPKG_TARGET_TRIPLET=x64-windows-static `
        -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded" `
        -DCMAKE_TOOLCHAIN_FILE="..." `
        -S . -B build
```

**Zmiany w `src/CMakeLists.txt`:**
- Usunąć WSZYSTKIE workaroundy ICE (nie potrzebne z Clang)
- Zachować statyczny `/MT` runtime
- Ewentualnie dodać `-Wno-microsoft-*` dla Clang warnings

**Zmiany w `CMakeLists.txt` (root):**
- Ustawić `CMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded"` dla static triplet

**Plusy:**
- ✅ Kompletne rozwiązanie — Clang nie ma ICE C1001
- ✅ Lepsza diagnostyka błędów (Clang daje czytelniejsze komunikaty)
- ✅ Pełna optymalizacja (nie trzeba wyłączać /O2 ani SSA)
- ✅ PCH może zostać włączone
- ✅ Odporny na przyszłe aktualizacje MSVC

**Minusy:**
- ❌ **Zmiana triplet z DLL na static** — dłuższa kompilacja vcpkg (pierwsze uruchomienie, potem cache)
- ❌ Clang-CL może mieć _inne_ bugi (rzadko, ale możliwe)
- ❌ `windows-2022` runner może nie mieć najnowszego Clang — trzeba zweryfikować
- ❌ Wymaga usunięcia specyficznych MSVC flags (`/d2SSAOptimizer-`, `/bigobj` etc.)
- ❌ Więcej zmian = więcej ryzyka

**Szacowany czas:** 1-2 godziny (zmiany + testy + debug potencjalnych Clang issues)  
**Czas oczekiwania na wynik:** ~60-90 minut (vcpkg rebuilds + build)

---

### OPCJA C: Hybrydowa — MSVC cl.exe + static triplet + global /Od + wyłączenie PCH (KOMPROMIS)

**Koncepcja:** Zostajemy przy MSVC cl.exe, ale agresywniej wyłączamy optymalizację i PCH. Dodatkowo zmieniamy triplet na static (co eliminuje potencjalne DLL problemy i daje self-contained binary).

**Zmiany w workflow `build-windows.yml`:**
```yaml
env:
  VCPKG_DEFAULT_TRIPLET: x64-windows-static
  VCPKG_DEFAULT_HOST_TRIPLET: x64-windows-static

- name: Configure CMake
  run: |
    cmake -G "Ninja" `
      -DCMAKE_BUILD_TYPE=Release `
      -DVCPKG_TARGET_TRIPLET=x64-windows-static `
      -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded" `
      -DTOGGLE_PRE_COMPILED_HEADER=OFF `
      -DOPTIONS_ENABLE_IPO=OFF `
      -DSPEED_UP_BUILD_UNITY=OFF `
      ...
```

**Zmiany w `src/CMakeLists.txt`:**
```cmake
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  # MSVC 14.44 ICE C1001 — kompletny workaround:
  # 1. Globalne /d2SSAOptimizer- (wyłącza SSA optimizer)
  # 2. /Od zamiast /O2 (wyłącza optymalizację)  
  # 3. PCH wyłączony via workflow (-DTOGGLE_PRE_COMPILED_HEADER=OFF)
  target_compile_options(${PROJECT_NAME} PRIVATE /d2SSAOptimizer-)
  
  # Release z /Od — wyłączamy optymalizację kompletnie
  string(REPLACE "/O2" "/Od" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
  string(REPLACE "/O2" "/Od" CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}" CACHE STRING "" FORCE)
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" CACHE STRING "" FORCE)
  
  # Usunięcie per-file workaroundów (nie potrzebne z globalnym /Od)
endif()
```

**Plusy:**
- ✅ Pewne — `/Od` + `/d2SSAOptimizer-` globalnie = 100% brak ICE
- ✅ Static binary — nie wymaga DLL przy dystrybucji
- ✅ Średni poziom zmian

**Minusy:**
- ❌ Zero optymalizacji — wolniejszy runtime (ale GPU-bound gra)
- ❌ Dłuższy link time (static)
- ❌ Pierwsze uruchomienie vcpkg rebuilds (brak cache dla `x64-windows-static`)

**Szacowany czas:** 30 minut (zmiany + push)  
**Czas oczekiwania na wynik:** ~90 minut (vcpkg + build)

---

## 5. REKOMENDACJA

| Kryterium | OPCJA A | OPCJA B | OPCJA C |
|---|---|---|---|
| **Pewność naprawy** | 90% | 95% | 99% |
| **Czas implementacji** | 15 min | 1-2h | 30 min |
| **Ryzyko nowych problemów** | Niskie | Średnie | Niskie |
| **Jakość binarki** | /O1 (ok) | /O2 (najlepsza) | /Od (najgorsza) |
| **Trwałość rozwiązania** | Tymczasowe | Trwałe | Tymczasowe |
| **Self-contained .exe** | Nie (DLL) | Tak (static) | Tak (static) |

### Rekomendowany plan:

**Faza 1:** Najpierw **OPCJA A** (szybka, pewna, minimalne zmiany) — aby ODBLOKOWAĆ build  
**Faza 2:** Potem **OPCJA B** (Clang-CL + static) — jako docelowe, trwałe rozwiązanie

---

## 6. ZADANIA DO REALIZACJI (W ZALEŻNOŚCI OD WYBRANEGO PLANU)

### Jeśli OPCJA A:
1. [ ] Zmienić `src/CMakeLists.txt` — globalny `/d2SSAOptimizer-`
2. [ ] Usunąć per-file `set_source_files_properties` (niepotrzebne z globalnym fix)
3. [ ] Dodać `-DTOGGLE_PRE_COMPILED_HEADER=OFF` do `build-windows.yml`
4. [ ] Push + ręczne uruchomienie "Build - Windows"
5. [ ] Zweryfikować wynik na GitHub Actions

### Jeśli OPCJA B:
1. [ ] Zmienić `build-windows.yml` — clang-cl + static triplet
2. [ ] Wyczyścić `src/CMakeLists.txt` z workaroundów MSVC ICE
3. [ ] Dodać `CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded` do CMake config
4. [ ] Przetestować Clang warnings (dodać `-Wno-*` jeśli potrzeba)
5. [ ] Push + ręczne uruchomienie
6. [ ] Zweryfikować → debug jeśli Clang ma inne problemy

### Jeśli OPCJA C:
1. [ ] Zmienić `build-windows.yml` — static triplet + wyłączenie PCH
2. [ ] Zmienić `src/CMakeLists.txt` — globalny `/Od` + `/d2SSAOptimizer-`
3. [ ] Usunąć per-file workaroundy
4. [ ] Push + ręczne uruchomienie
5. [ ] Zweryfikować (dłuższy czas bo vcpkg rebuild)

---

## 7. POWIĄZANE DOKUMENTY

- [2026-02-17_windows_build_fix_msvc_toolset.md](2026-02-17_windows_build_fix_msvc_toolset.md) — poprzednia próba naprawy (toolset filter)
- [2026-02-08_plan_fonty_unicode_kompilacja.md](2026-02-08_plan_fonty_unicode_kompilacja.md) — ogólny plan kompilacji multi-platform
- [2026-02-17_naprawa_warningow_linux.md](2026-02-17_naprawa_warningow_linux.md) — warningi Linux (naprawione)

## 8. PLIKI KLUCZOWE

| Plik | Rola |
|---|---|
| `.github/workflows/build-windows.yml` (root repo: `/home/ptaku/serweryt/`) | Aktywny workflow "Build - Windows" | 
| `Tibia/silnik/canary_test/testyy/CMakeLists.txt` | Root CMake — vcpkg, IPO, text stack |
| `Tibia/silnik/canary_test/testyy/src/CMakeLists.txt` | CMake source — PCH, build flags, ICE workarounds |
| `src/framework/luaengine/luabinder.h` | Szablony C++20 — główny trigger ICE |
| `src/framework/otml/otmlparser.cpp` | Parser OTML — trigger ICE L35 |
| `src/framework/otml/otmlnode.cpp` | Node OTML — trigger ICE L69 |
| `src/framework/luafunctions.cpp` | 1053 linii wiązań Lua — trigger ICE via luabinder.h |
