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

## 2. Prywatne składniki BS::thread_pool (KRYTYCZNY)

### Opis
Lokalna kopia pliku `BS_thread_pool.hpp` zawierała niepoprawne deklaracje `friend class`. Deklaracja `friend class thread_pool;` wewnątrz namespace `BS::this_thread` powinna używać pełnej kwalifikacji: `friend class BS::thread_pool;`.

### Błąd kompilacji
```
error: 'BS::this_thread::optional_index BS::this_thread::thread_info_index::index' is private within this context
  909 |         this_thread::get_index.index = idx;
      |                                ^~~~~

error: 'BS::this_thread::optional_pool BS::this_thread::thread_info_pool::pool' is private within this context
  910 |         this_thread::get_pool.pool = this;
      |                               ^~~~
```

### Pliki do naprawy
| Plik | Linia | Problem | Status |
|------|-------|---------|--------|
| `src/framework/util/BS_thread_pool.hpp` | 106 | `friend class thread_pool;` powinno być `friend class BS::thread_pool;` | ✅ Naprawione |
| `src/framework/util/BS_thread_pool.hpp` | 131 | `friend class thread_pool;` powinno być `friend class BS::thread_pool;` | ✅ Naprawione |

### Rozwiązanie
Zmiana deklaracji friend class z niepełnej kwalifikacji na pełną kwalifikację namespace:

```cpp
// PRZED (linia 106)
class thread_info_index
{
    friend class thread_pool;

// PO
class thread_info_index
{
    friend class BS::thread_pool;

// PRZED (linia 131)
class thread_info_pool
{
    friend class thread_pool;

// PO
class thread_info_pool
{
    friend class BS::thread_pool;
```

### Przyczyna
Klasy `thread_info_index` i `thread_info_pool` są zdefiniowane wewnątrz namespace `BS::this_thread`, podczas gdy klasa `thread_pool` jest w namespace `BS`. Bez pełnej kwalifikacji kompilator szuka `thread_pool` w bieżącym namespace `BS::this_thread` zamiast w `BS`.

### Status
✅ **NAPRAWIONE** - Zmieniono `friend class thread_pool;` na `friend class BS::thread_pool;` w obu klasach

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

#### Opcja A: W CMakeLists.txt (ZASTOSOWANE)
```cmake
if(MSVC)
  target_compile_definitions(${PROJECT_NAME}
          PRIVATE
          NTDDI_VERSION=0x0A000000  # Windows 10
          _WIN32_WINNT=0x0A00       # Windows 10
          WINVER=0x0A00             # Windows 10
  )
endif()
```

#### Opcja B: W vcpkg triplet
```
set(VCPKG_CMAKE_SYSTEM_VERSION 10)
```

### Status
✅ **NAPRAWIONE - zmieniono z Windows Vista (0x0600) na Windows 10 (0x0A00)**

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

### build-ubuntu.yml (Linux)
| Problem | Status |
|---------|--------|
| BS::thread_pool API (submit → submit_task) | ✅ Naprawione |
| BS::thread_pool friend class declarations | ✅ Naprawione |
| Kompilacja | ⏳ Oczekuje na weryfikację |

### build-linux.yml
| Problem | Status |
|---------|--------|
| BS::thread_pool API | ✅ Naprawione |
| BS::thread_pool friend class declarations | ✅ Naprawione |
| Kompilacja | ⏳ Oczekuje na zatwierdzenie workflow |

### build-windows.yml
| Problem | Status |
|---------|--------|
| BS::thread_pool API | ✅ Naprawione |
| BS::thread_pool friend class declarations | ✅ Naprawione |
| Windows SDK | ✅ Naprawione (Windows 10 - 0x0A00) |
| Kompilacja | ⏳ Oczekuje na zatwierdzenie workflow |

### build-windows-solution.yml
| Problem | Status |
|---------|--------|
| BS::thread_pool API | ✅ Naprawione |
| BS::thread_pool friend class declarations | ✅ Naprawione |
| Windows SDK | ✅ Naprawione (Windows 10 - 0x0A00) |
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
| 2025-12-04 | `64d7a16` | Dodano dokumentację błędów (bledyw.md) |
| 2025-12-04 | TBD | Naprawiono Windows SDK (Vista → Windows 10) |
| 2025-12-04 | TBD | Naprawiono friend class declarations w BS_thread_pool.hpp |

---

## Linki

- [BS::thread_pool GitHub](https://github.com/bshoshany/thread-pool)
- [Dokumentacja vcpkg](https://github.com/microsoft/vcpkg)
- [CMake Windows SDK](https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_VERSION.html)
