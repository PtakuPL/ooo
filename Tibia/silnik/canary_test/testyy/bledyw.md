# Błędy Workflow CI - Dokumentacja i Rozwiązania

## Przegląd

Ten dokument zawiera listę wszystkich błędów występujących w workflow CI oraz instrukcje ich naprawy.

---

## 1. Błąd API BS::thread_pool (KRYTYCZNY)

### Opis
Biblioteka `BS::thread_pool` zmieniła API. Metoda `submit()` została zastąpiona przez `submit_task()`.

### Błąd kompilacji
```
error: 'class BS::thread_pool' has no member named 'submit'
```

### Pliki do naprawy
| Plik | Linia | Status |
|------|-------|--------|
| `src/framework/core/modulemanager.cpp` | 224 | ✅ Naprawiony |
| `src/client/map.cpp` | 1115 | ✅ Naprawiony |
| `src/client/mapview.cpp` | 406 | ✅ Naprawiony |
| `src/client/thingtype.cpp` | 684 | ✅ Naprawiony |
| `src/framework/core/graphicalapplication.cpp` | 183, 200, 330 | ✅ Naprawiony |
| `src/framework/graphics/framebuffer.cpp` | 201 | ✅ Naprawiony |
| `src/framework/sound/soundmanager.cpp` | 273, 288, 300 | ✅ Naprawiony |
| `src/framework/net/httplogin.cpp` | 104, 145 | ✅ Naprawiony |

### Rozwiązanie
Zamiana `g_asyncDispatcher.submit()` na `g_asyncDispatcher.submit_task()`:

```cpp
// PRZED
m_streamFiles[streamSource] = g_asyncDispatcher.submit([=]() -> SoundFilePtr { ... });

// PO
m_streamFiles[streamSource] = g_asyncDispatcher.submit_task([=]() -> SoundFilePtr { ... });
```

### Status
✅ **NAPRAWIONE w commicie `f5a2703`**

---

## 2. Prywatne składniki BS::thread_pool

### Opis
Kod próbuje uzyskać dostęp do prywatnych składników klasy `thread_info_index`.

### Błąd kompilacji
```
error: 'BS::this_thread::optional_index BS::this_thread::thread_info_index::index' is private
```

### Rozwiązanie
Użyj publicznych akcesorów zamiast bezpośredniego dostępu:
```cpp
// PRZED
thread_info_index.index = value;

// PO - użyj właściwych metod publicznych
// Sprawdź dokumentację BS_thread_pool.hpp dla prawidłowych akcesorów
```

### Status
⚠️ **Może wymagać naprawy jeśli kod używa prywatnych składników**

---

## 3. Wersja Windows SDK

### Opis
Niektóre funkcje wymagają nowszej wersji Windows SDK (Windows 10).

### Błąd kompilacji
```
error C2039: 'from_chars' : is not a member of 'std'
warning: The Windows SDK version is lower than required
```

### Rozwiązanie

#### Opcja A: W CMakeLists.txt
```cmake
if(WIN32)
    add_compile_definitions(_WIN32_WINNT=0x0A00)  # Windows 10
endif()
```

#### Opcja B: W vcpkg triplet
```
set(VCPKG_CMAKE_SYSTEM_VERSION 10)
```

### Status
⚠️ **Do sprawdzenia w nowych buildach**

---

## 4. Błędy inicjalizacji referencji

### Opis
Referencje muszą być inicjalizowane przy deklaracji.

### Błąd kompilacji
```
error: declaration of reference variable 'mapThread' requires an initializer
```

### Rozwiązanie
Zamień referencje na zwykłe zmienne lub użyj `std::future`:

```cpp
// PRZED
auto& mapThread = g_asyncDispatcher.submit(...);

// PO
auto mapThread = g_asyncDispatcher.submit_task(...);
// LUB
std::future<void> mapThread = g_asyncDispatcher.submit_task(...);
```

### Status
✅ **Naprawione automatycznie wraz z poprawką API submit_task()**

---

## Podsumowanie Workflow

### build-linux.yml
| Problem | Status |
|---------|--------|
| BS::thread_pool API | ✅ Naprawione |
| Kompilacja | ⏳ Oczekuje na zatwierdzenie workflow |

### build-windows.yml
| Problem | Status |
|---------|--------|
| BS::thread_pool API | ✅ Naprawione |
| Windows SDK | ⚠️ Do weryfikacji |
| Kompilacja | ⏳ Oczekuje na zatwierdzenie workflow |

### build-windows-solution.yml
| Problem | Status |
|---------|--------|
| BS::thread_pool API | ✅ Naprawione |
| Windows SDK | ⚠️ Do weryfikacji |
| Kompilacja | ⏳ Oczekuje na zatwierdzenie workflow |

---

## Instrukcje dla ChatGPT/innych narzędzi AI

### Krok 1: Sprawdź aktualny stan błędów
```bash
# Przejdź do katalogu projektu
cd Tibia/silnik/canary_test/testyy

# Sprawdź czy wszystkie pliki używają submit_task()
grep -rn "g_asyncDispatcher\.submit(" src/ --include="*.cpp"
# Powinno zwrócić PUSTE wyniki jeśli wszystko naprawione

# Sprawdź czy pliki używają submit_task()
grep -rn "g_asyncDispatcher\.submit_task(" src/ --include="*.cpp"
# Powinno zwrócić 13 wyników
```

### Krok 2: Jeśli nadal są błędy submit()
```bash
# Zamień wszystkie wystąpienia
sed -i 's/g_asyncDispatcher\.submit(/g_asyncDispatcher.submit_task(/g' \
  src/framework/sound/soundmanager.cpp \
  src/framework/graphics/framebuffer.cpp \
  src/framework/core/modulemanager.cpp \
  src/framework/core/graphicalapplication.cpp \
  src/framework/net/httplogin.cpp \
  src/client/thingtype.cpp \
  src/client/map.cpp \
  src/client/mapview.cpp
```

### Krok 3: Weryfikacja lokalnego builda (Linux)
```bash
cmake -S . -B build/linux-release \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build/linux-release --parallel
```

### Krok 4: Weryfikacja lokalnego builda (Windows)
```bash
cmake -S . -B build \
  -G "Visual Studio 17 2022" -A x64

cmake --build build --config Release --parallel
```

---

## Historia zmian

| Data | Commit | Opis |
|------|--------|------|
| 2025-12-04 | `f5a2703` | Naprawiono API BS::thread_pool (submit → submit_task) |

---

## Linki

- [BS::thread_pool GitHub](https://github.com/bshoshany/thread-pool)
- [Dokumentacja vcpkg](https://github.com/microsoft/vcpkg)
- [CMake Windows SDK](https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_VERSION.html)
