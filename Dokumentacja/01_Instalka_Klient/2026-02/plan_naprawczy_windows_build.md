# Plan Naprawczy: Windows Build - Instalka OTC Client

**Data:** 2026-02-20  
**Źródło:** Analiza logów CI + badanie ChatGPT (`badanie_chatgpt_kompilacja.md`)  
**Run ID:** 22203119029 (MSVC 14.44.35207 / VS 2022, windows-2022)

---

## Zebrane logi - podsumowanie błędów

Z ostatniego runu CI **Build - Windows** (run ID: `22203119029`, MSVC 14.44.35207 / VS 2022 17.14.x) wyodrębniono **3 kategorie błędów**:

| # | Kod błędu | Plik | Linia | Treść |
|---|-----------|------|-------|-------|
| 1 | **fatal error C1001** (ICE) | `luainterface.h` | 484 | Internal compiler error (p2\main.cpp:258) |
| 2 | **fatal error C1001** (ICE) | `luabinder.h` | 171 | Internal compiler error (p2\main.cpp:258) |
| 3 | **error C2139** | `luainterface.h` | 488 | `'UIWidget': an undefined class is not allowed as argument to '__is_base_of'` |
| 4 | **error C2139** | `luainterface.h` | 488 | `'OTMLNode': an undefined class is not allowed as argument to '__is_base_of'` |
| 5 | **error C2665** | `luainterface.h` | 488 | `'luavalue_cast': no overloaded function could convert all argument types` |
| 6 | **error C2665** | `luainterface.h` | 403 | `'push_luavalue': no overloaded function could convert all argument types` |

---

## Analiza głównej przyczyny

### Problem bazowy: Niekompletne typy przy `std::is_base_of`

Błędy **C2139** i **C2665** mają jedną wspólną przyczynę. W `luavaluecasts.h` (linia ~161-167) jest szablon:
```cpp
template<class T>
std::enable_if_t<std::is_base_of_v<LuaObject, T>, bool>
luavalue_cast(int index, std::shared_ptr<T>& ptr);
```

Kiedy MSVC rozwiązuje overloady (np. dla `std::shared_ptr<UIWidget>`), musi ewaluować `std::is_base_of_v<LuaObject, UIWidget>` - a to **wymaga pełnej definicji klasy**. MSVC używa intrinsica `__is_base_of`, który jest ścisły i odmawia pracy z forward-declared typami.

**Dlaczego działa na Linux (GCC/Clang):** GCC/Clang są bardziej liberalne z `is_base_of` na niekompletnych typach w kontekście SFINAE - mogą odroczyć ewaluację lub traktować to jako soft-fail.

**Konkretne ścieżki problemowe:**

1. **`luafunctions_gfx_singletons.cpp`** (linia 73) → includuje `uimanager.h` → ten include ciągnie `declarations.h` → **`UIWidget` jest tylko forward-declared** → binduje `UIManager::createWidget()` zwracającą `UIWidgetPtr` → template instantiation wymaga `is_base_of<LuaObject, UIWidget>` → **FAIL**

2. **`luafunctions.cpp`** (linia 267) → includuje `config.h` → ten include ciągnie `otml/declarations.h` → **`OTMLNode` jest tylko forward-declared** → binduje `Config::setNode(OTMLNodePtr)` → template instantiation wymaga `is_base_of<LuaObject, OTMLNode>` → **FAIL**

### Problem dodatkowy: ICE C1001

Internal Compiler Error na MSVC 14.44 w fazie code generation (`p2\main.cpp:258`). To **bug MSVC**, najprawdopodobniej wyzwalany przez:
- Głęboko zagnieżdżone template instantiation (variadic templates w `luabinder.h`)
- Interakcja z niekompletnymi typami, która wprawia kompilator w niespójny stan
- Znany problem toolsetu 14.44 z ciężkimi szablonami

Uwaga: W workflow komentarz mówi "skips 14.44 to avoid ICE" ale **faktycznie toolset 14.44 jest dalej używany** - filtr został usunięty w poprzedniej poprawce bo powodował fallback na zbyt starą wersję 14.29.

---

## Proponowane poprawki (4 kroki)

### Krok 1: Dodanie pełnych include'ów w plikach luafunctions (naprawia C2139 + C2665)

W **`luafunctions_gfx_singletons.cpp`** - dodać:
```cpp
#include <framework/ui/uiwidget.h>
```
To dostarczy pełną definicję `UIWidget` (dziedziczącą z `LuaObject`), co pozwoli MSVC ewaluować `is_base_of`.

W **`luafunctions.cpp`** - dodać:
```cpp
#include <framework/otml/otmlnode.h>
```
To dostarczy pełną definicję `OTMLNode` (uwaga: `OTMLNode` **nie** dziedziczy z `LuaObject`, ale MSVC i tak potrzebuje pełnego typu żeby ocenić SFINAE).

W **`luafunctions_graphics.cpp`** - sprawdzić czy nie ma analogicznego problemu (prawdopodobnie nie, bo nie binduje typów opartych na `shared_ptr<T>`).

### Krok 2: Obejście ICE C1001 za pomocą flagi `/d2ReducedOptimizeHugeFunctions` (jeśli ICE nie zniknie po Kroku 1)

Dodać w `CMakeLists.txt` dla MSVC:
```cmake
if(MSVC)
    add_compile_options(/d2ReducedOptimizeHugeFunctions)
endif()
```
Ta flaga mówi MSVC, żeby zmniejszył agresywność optymalizacji dla dużych funkcji (szablonów), co eliminuje wiele ICE.

Alternatywnie: dodać pragmę w `luabinder.h`:
```cpp
#ifdef _MSC_VER
#pragma optimize("", off)
// ... problematic template code ...
#pragma optimize("", on)
#endif
```

### Krok 3: Ulepszenie `luavaluecasts.h` - zabezpieczenie na przyszłość

Dodać `requires` / concept guard, który sprawdzi kompletność typu ZANIM spróbuje `is_base_of`:
```cpp
template<class T>
concept CompleteLuaObjectDerived = requires { sizeof(T); } && std::is_base_of_v<LuaObject, T>;

template<class T>
std::enable_if_t<CompleteLuaObjectDerived<typename T::element_type>, int>
push_luavalue(const T& obj);
```
Ale to jest bardziej inwazyjne - opcjonalnie, jeśli kroki 1-2 nie wystarczą.

### Krok 4: Korekta workflow CI (opcjonalnie)

Komentarz w workflow twierdzi że toolset 14.44 jest "skippowany", ale kod tego nie robi. Uaktualnić komentarz lub dodać mechanizm pinowania na znanej-dobrej wersji MSVC, np.:
```yaml
- name: Select MSVC toolset
  shell: pwsh  
  run: |
    # Pin to 14.43 if available, otherwise latest
    $root = "..."
    $toolsets = Get-ChildItem $root | Sort-Object -Descending
    $selected = $toolsets | Where-Object { $_.Name -lt "14.44" } | Select-Object -First 1
    if (-not $selected) { $selected = $toolsets[0] }
```

---

## Priorytet i kolejność

| Priorytet | Krok | Szansa na naprawę | Ryzyko | Czas |
|-----------|------|-------------------|--------|------|
| **1 (KRYTYCZNY)** | Krok 1: Dodanie include'ów | ~90% (naprawi C2139/C2665, prawdopodobnie też ICE) | minimalne | 5 min |
| **2 (JEŚLI POTRZEBNE)** | Krok 2: Flaga /d2ReducedOptimizeHugeFunctions | ~80% (naprawi ICE jeśli Krok 1 nie wystarczy) | niskie | 5 min |
| **3 (ZAPOBIEGAWCZY)** | Krok 3: Concept guard w luavaluecasts.h | zabezpieczenie na przyszłość | średnie (inwazyjne) | 30 min |
| **4 (OPCJONALNY)** | Krok 4: Korekta workflow MSVC toolset | porządkowanie CI | niskie | 10 min |

---

## Status realizacji

- [ ] Krok 1: Dodanie include'ów
- [ ] Krok 2: Flaga /d2ReducedOptimizeHugeFunctions (jeśli potrzebne)
- [ ] Krok 3: Concept guard (jeśli potrzebne)
- [ ] Krok 4: Korekta workflow (opcjonalnie)
