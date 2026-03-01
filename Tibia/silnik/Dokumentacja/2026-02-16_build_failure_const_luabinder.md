# 🔴 BUILD FAILURE: `const` na `getLocaleTag()` — Pełna analiza i plan naprawy

**Data incydentu:** 2026-02-16  
**Platforma:** Windows (GitHub Actions, Clang-CL 19, Ninja)  
**Build ID:** 22052901549  
**Status:** ❌ FAILED — 1 error, 0 warnings naszego kodu  
**Priorytet:** KRYTYCZNY — blokuje release instalki Windows  

---

## 📋 TL;DR (Podsumowanie dla właściciela)

Build Windows padł z powodu **jednego słowa: `const`** w deklaracji metody `getLocaleTag()`.
System bindowania C++ → Lua (`luabinder.h`) **nie obsługuje metod `const`** — w ogóle.
Poprawna wersja jest na lokalnych plikach (WSL i Windows), ale na GitHubie jest stara wersja z `const`.
Wystarczy wypchnąć lokalne pliki na GitHub i ponownie odpalić build.

---

## 🔍 DOKŁADNA ANALIZA — Co się stało krok po kroku

### Chronologia zdarzeń

| Czas | Zdarzenie |
|------|-----------|
| 15 lut ~06:30 | Zidentyfikowano 5 root causes problemów z renderingiem i18n |
| 15 lut ~06:35 | Naprawiono pliki C++ na Windows source: fontmanager.h/cpp, TTFFont.h/cpp, TextShaper.h/cpp, luafunctions.cpp, locales.lua |
| 15 lut ~06:40 | Skopiowano pliki z Windows na WSL (cp) — **ALE przy kopiowaniu fontmanager.h/cpp na WSL poprzez edycję Copilota, wersja z `const` znalazła się w commitowanym pliku** |
| 15 lut ~06:45 | Push commit `4b4725a15` na master — zawierał `getLocaleTag() const` ← **BUG** |
| 15 lut ~06:50 | Push commit `b9f579f1b` — strip [EN] prefixes z 52 plików |
| 15 lut ~06:55 | Odpalony build Windows via `gh workflow run` |
| 15 lut ~07:45 | Build FAILED po 51 minutach — 1 error w luafunctions.cpp:442 |
| 16 lut ~21:17 | Guardian (i18n auto-worker Cykl #1, commit `861e1264b`) **przypadkowo naprawił const** na lokalnym repo, usuwając `const` z fontmanager.h i .cpp |
| 16 lut ~teraz | Lokalne repo poprawione, ale 25 commitów guardiana NIE jest wypchniętych na GitHub |

### Źródło problemu: Rozbieżność wersji plików

```
┌─────────────────────────────┐
│ Windows source (poprawne)   │  getLocaleTag();          ← BEZ const ✅
│ /mnt/c/.../testyy — kopia/  │
└──────────────┬──────────────┘
               │ Edytowano bezpośrednio Copilotem
               │ (wersja z const wylądowała w commicie)
               ▼
┌─────────────────────────────┐
│ Commit 4b4725a15 na GitHub  │  getLocaleTag() const;    ← Z CONST ❌
│ (remote master)             │
└──────────────┬──────────────┘
               │ Guardian Cykl#1 naprawił
               ▼
┌─────────────────────────────┐
│ Lokalne WSL HEAD            │  getLocaleTag();          ← BEZ const ✅
│ /home/ptaku/.../testyy/     │  (po commit 861e1264b)
└─────────────────────────────┘
```

**Problem:** Commit `4b4725a15` wypchniięty na GitHub zawierał `const`, ale lokalne pliki (zarówno Windows source jak i WSL po poprawce) go nie mają. GitHub Actions buduje z tego co jest na remote master — czyli z `const`.

---

## 🔧 DOKŁADNY BŁĄD KOMPILACJI

### Komunikat z build loga (krok [35/176])

```
FAILED: src/CMakeFiles/otclient.dir/framework/luafunctions.cpp.obj

D:\a\ooo\ooo\...\luainterface.h(418,58): error: no matching function for call to 'bind_singleton_mem_fun'
  418 |     registerClassStaticFunction(className, functionName, luabinder::bind_singleton_mem_fun(function, instance));

D:\a\ooo\ooo\...\luafunctions.cpp(442,11): note: in instantiation of function template specialization
    'LuaInterface::bindSingletonFunction<FontManager, std::basic_string<char> () const>'
    requested here
  442 |     g_lua.bindSingletonFunction("g_fonts", "getLocaleTag", &FontManager::getLocaleTag, &g_fonts);

D:\a\ooo\ooo\...\luabinder.h(215,20): note: candidate template ignored:
    could not match 'Ret (Args...)' against 'std::basic_string<char> () const'
  215 |     LuaCppFunction bind_singleton_mem_fun(Ret(FC::* f)(Args...), C* instance)

1 error generated.
ninja: build stopped: subcommand failed.
```

### Wyjaśnienie po polsku

Kompilator próbuje dopasować sygnaturę `std::string () const` (metoda const) do szablonu 
`Ret(FC::* f)(Args...)` (metoda NIE-const). Szablon akceptuje TYLKO `Ret(FC::* f)(Args...)`, 
a nie `Ret(FC::* f)(Args...) const` — dlatego mówi "could not match".

---

## 🏗️ OGRANICZENIE SYSTEMU LUA BINDERA — BRAK OBSŁUGI `const`

### Lokalizacja: `src/framework/luaengine/luabinder.h`

W CAŁYM pliku luabinder.h (237 linii) **nie istnieje żaden overload dla metod `const`**.

#### Funkcje które TYLKO akceptują metody nie-const:

| Linia | Funkcja | Sygnatura szablonu | Akceptuje const? |
|-------|---------|-------------------|-----------------|
| 168 | `make_mem_func` (Ret) | `Ret(C::* f)(Args...)` | ❌ NIE |
| 178 | `make_mem_func` (void) | `void(C::* f)(Args...)` | ❌ NIE |
| 190 | `make_mem_func_singleton` (Ret) | `Ret(C::* f)(Args...)` | ❌ NIE |
| 196 | `make_mem_func_singleton` (void) | `void(C::* f)(Args...)` | ❌ NIE |
| 204 | `bind_mem_fun` | `Ret(FC::* f)(Args...)` | ❌ NIE |
| 215 | `bind_singleton_mem_fun` | `Ret(FC::* f)(Args...)` | ❌ NIE |

#### Co to oznacza w praktyce

**ZASADA: Żadna metoda C++ bindowana do Lua nie może mieć `const`.**

To jest celowa decyzja architektury OTClient Redemption. Wszystkie istniejące metody 
bindowane do Lua są **nie-const**:

```cpp
// Przykłady z application.h — WSZYSTKIE nie-const:
std::string getName()      { return m_appName; }     // nie ma "const"!
bool isRunning()           { return m_running; }     // nie ma "const"!
std::string getVersion()   { return m_appVersion; }  // nie ma "const"!

// Przykłady z platform.h:
int getProcessId();        // nie ma "const"!
std::string getCPUName();  // nie ma "const"!
```

---

## 📝 PEŁNA LISTA NASZYCH ZMIAN C++ I ICH STATUS CONST

### Commit `4b4725a15` — Nasze modyfikacje

| Plik | Metoda | Const na GitHub? | Const lokalnie? | Bindowana do Lua? | Problem? |
|------|--------|-----------------|-----------------|-------------------|----------|
| fontmanager.h:38 | `clearGlyphCaches()` | void, nie-const | void, nie-const | TAK (linia 440) | ✅ OK |
| fontmanager.h:41 | `setLocaleTag(const std::string&)` | void, nie-const | void, nie-const | TAK (linia 441) | ✅ OK |
| fontmanager.h:42 | **`getLocaleTag()`** | **const** ❌ | **nie-const** ✅ | TAK (linia 442) | **❌ PROBLEM** |
| TTFFont.h:135 | `clearCache()` | void, nie-const | void, nie-const | NIE (pośrednio) | ✅ OK |
| TextShaper.h:37 | `clearCache()` | static void | static void | NIE (statyczna) | ✅ OK |
| luafunctions.cpp:440-442 | Bindings | identyczne | identyczne | — | ✅ OK |
| locales.lua | Lua safe checks | identyczne | identyczne | — | ✅ OK |

### Podsumowanie: Tylko 1 problem = `fontmanager.h:42` i `fontmanager.cpp:57`

**UWAGA o `const` w parametrach vs `const` po nawiasie:**
- `void setLocaleTag(const std::string& tag)` — `const` w parametrze = OK, nie wpływa na sygnaturę metody
- `std::string getLocaleTag() const` — `const` po nawiasie = PROBLEM, zmienia sygnaturę metody na `Ret(C::* f)(Args...) const`

---

## 🛠️ OPCJE NAPRAWY

### Opcja 1: Push lokalnych plików na GitHub (REKOMENDOWANA)
**Czas:** ~5 minut  
**Ryzyko:** Niskie  
**Opis:** Lokalne repo (WSL) ma 25 niepushed commitów guardiana, w tym commit `861e1264b` który już naprawił const. Wystarczy:
```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test/testyy
git push origin master
```
Potem ponownie odpalić build:
```bash
gh workflow run 211701257 --repo PtakuPL/ooo --ref master
```

### Opcja 2: Dedykowany commit naprawczy (jeśli nie chcemy pushować wszystkich 25 commitów)
**Czas:** ~10 minut  
**Ryzyko:** Niskie  
**Opis:** Jeśli nie chcemy pushować 25 commitów guardiana, można:
1. Cherry-pick TYLKO commita `861e1264b` z poprawką const
2. Lub ręcznie edytować fontmanager.h i fontmanager.cpp na masterze

### Opcja 3: Dodać overload `const` do luabinder.h (NIE REKOMENDOWANA)
**Czas:** ~30 minut + ryzyko  
**Ryzyko:** Średnie — modyfikujemy fundamentalny plik silnika  
**Opis:** Dodać 3 nowe overloady do luabinder.h:
```cpp
// const overload for make_mem_func_singleton (Ret)
template<typename Ret, typename C, typename... Args>
std::function<Ret(const Args&...)> make_mem_func_singleton(Ret(C::* f)(Args...) const, C* instance)
{
    auto mf = std::mem_fn(f);
    return [=](Args... args) mutable -> Ret { return mf(instance, args...); };
}

// const overload for bind_singleton_mem_fun
template<typename C, typename Ret, class FC, typename... Args>
LuaCppFunction bind_singleton_mem_fun(Ret(FC::* f)(Args...) const, C* instance)
{
    using Tuple = std::tuple<typename stdext::remove_const_ref<Args>::type...>;
    assert(instance);
    auto lambda = make_mem_func_singleton<Ret, FC>(f, static_cast<FC*>(instance));
    return bind_fun_specializer<typename stdext::remove_const_ref<Ret>::type,
        decltype(lambda),
        Tuple>(lambda);
}
```
**DLACZEGO NIE REKOMENDOWANE:** To łamie konwencję całego projektu. Lepiej trzymać się zasady "żadnych `const` w Lua-boundowych metodach" — jest prostsza i spójna z 100+ istniejącymi bindingami.

---

## ⚠️ ZASADY NA PRZYSZŁOŚĆ — Jak unikać tego problemu

### Zasada 1: NIGDY nie dodawaj `const` do metod bindowanych do Lua

```cpp
// ❌ ŹLE — nie skompiluje się z Lua binder:
std::string getLocaleTag() const;

// ✅ DOBRZE — zgodne z luabinder.h:
std::string getLocaleTag();
```

Dotyczy KAŻDEJ metody, na której wołamy:
- `g_lua.bindSingletonFunction(...)`
- `g_lua.bindClassMemberFunction(...)`

### Zasada 2: Sprawdzaj `const` PRZED pushem

```bash
# Szybki check — szukaj const na naszych nowych metodach:
grep -n ') const' src/framework/graphics/fontmanager.h
grep -n ') const' src/framework/graphics/fontmanager.cpp

# Porównaj z luafunctions.cpp — czy każda bindowana metoda NIE ma const:
grep 'bindSingletonFunction.*g_fonts' src/framework/luafunctions.cpp
```

### Zasada 3: Zawsze kopiuj Z KANONICZNYCH ŹRÓDEŁ

Kanoniczne źródło plików C++:
- **Windows source:** `/mnt/c/Gry/Tibia/otland/otclient/testyy — kopia/src/`
- **Lokalne WSL:** `/home/ptaku/serweryt/Tibia/silnik/canary_test/testyy/src/`

Przy pushowaniu zmian na GitHub:
1. Najpierw upewnij się, że WSL i Windows source są zsynchronizowane
2. Sprawdź `git diff` przed commitem
3. Szukaj `const` na nowych metodach

### Zasada 4: Po pushu — obserwuj build

```bash
# Odpal build:
gh workflow run 211701257 --repo PtakuPL/ooo --ref master

# Sprawdź status:
gh run list --workflow=build-windows.yml --repo PtakuPL/ooo -L 3

# Jeśli fail — pobierz log:
gh run view <RUN_ID> --log-failed --repo PtakuPL/ooo
```

---

## 📊 INNE BŁĘDY W BUILD LOGU (WARNINGI — NIE BLOKUJĄCE)

### Protobuf: 90+ warningów `[-Winvalid-offsetof]`
- **Pliki:** `sounds.pb.cc`, `staticdata.pb.cc`, `appearances.pb.cc`
- **Opis:** `offsetof()` na non-standard-layout types — normalne dla protobuf, NIE powoduje błędów
- **Akcja:** IGNOROWAĆ — to jest upstream protobuf, nie nasz kod

### Clang-CL: warningi `/MP` unused
- **Opis:** `/MP` (multiprocessor compilation) jest flagą MSVC, Clang-CL ją ignoruje
- **Akcja:** IGNOROWAĆ — jest w CMakeLists.txt projektu, usuwanie może zepsuć MSVC build

### u8path deprecation warning
- **Plik:** `resourcemanager.cpp:724`
- **Opis:** `std::filesystem::u8path()` jest deprecated w C++20
- **Akcja:** Opcjonalnie naprawić w przyszłości — nie blokuje

---

## 📁 PLIKI KLUCZOWE — Mapa referencji

| Plik | Lokalizacja WSL | Rola |
|------|-----------------|------|
| luabinder.h | `src/framework/luaengine/luabinder.h` | System bindowania C++ → Lua. **OGRANICZENIE: brak const overload** |
| luainterface.h | `src/framework/luaengine/luainterface.h:418` | `bindSingletonFunction()` — wywołuje `bind_singleton_mem_fun()` |
| luafunctions.cpp | `src/framework/luafunctions.cpp:440-442` | Nasze nowe bindingi: clearGlyphCaches, setLocaleTag, getLocaleTag |
| fontmanager.h | `src/framework/graphics/fontmanager.h:38-42` | Deklaracje nowych metod — **tu był `const` na getLocaleTag** |
| fontmanager.cpp | `src/framework/graphics/fontmanager.cpp:44-59` | Implementacje — **tu był `const` na getLocaleTag** |
| TTFFont.h/cpp | `src/framework/text/TTFFont.h:135`, `.cpp:196` | `clearCache()` — nie-const, nie bindowana bezpośrednio |
| TextShaper.h/cpp | `src/framework/text/TextShaper.h:37`, `.cpp:46` | `clearCache()` — static, nie bindowana |
| locales.lua | `modules/client_locales/locales.lua` | Safe-check dla `clearGlyphCaches()` i `setLocaleTag()` |

---

## ✅ AKTUALNY STATUS PLIKÓW (sprawdzony 2026-02-16)

| Lokalizacja | fontmanager.h getLocaleTag | fontmanager.cpp getLocaleTag | Status |
|-------------|---------------------------|------------------------------|--------|
| Windows source (`/mnt/c/...`) | `std::string getLocaleTag();` | `std::string FontManager::getLocaleTag() {` | ✅ BEZ const |
| WSL lokalne (HEAD) | `std::string getLocaleTag();` | `std::string FontManager::getLocaleTag() {` | ✅ BEZ const |
| Git commit `861e1264b` | poprawione z `const` na nie-const | poprawione z `const` na nie-const | ✅ Naprawione |
| **GitHub remote master** | `std::string getLocaleTag() const;` | `std::string FontManager::getLocaleTag() const {` | **❌ Z CONST** |

### Co trzeba zrobić:
1. **Wypchnąć lokalne commity na GitHub** (`git push origin master`) — commit `861e1264b` zawiera poprawkę
2. **Odpalić build ponownie** (`gh workflow run`)
3. **Zweryfikować** że build przejdzie

---

## 🔮 POTENCJALNE PRZYSZŁE PROBLEMY (checklist dla nowych metod C++)

Jeśli w przyszłości dodajemy NOWĄ metodę do klasy i chcemy ją bindować do Lua:

- [ ] Metoda NIE ma `const` po nawiasie → `void foo();` a nie `void foo() const;`
- [ ] Metoda NIE jest `static` (dla singleton binding — static wymaga `bindClassStaticFunction`)
- [ ] Parametr `const` w argumentach jest OK → `void foo(const std::string& s);` ✅
- [ ] Sprawdziłem `luafunctions.cpp` czy binding jest dodany poprawnie
- [ ] Sprawdziłem `git diff` przed pushem — brak niechcianych `const`
- [ ] Po pushu sprawdziłem build status na GitHub Actions

---

*Dokument stworzony: 2026-02-16. Autor: Copilot + Ptaku.*  
*Powiązane dokumenty:*
- `2026-02-08_plan_fonty_unicode_kompilacja.md` — plan prac nad fontami Unicode
- `2026-02-09_ci_build_fixes.md` — poprzednie naprawy buildu CI (MSVC ICE, Android, WASM)
