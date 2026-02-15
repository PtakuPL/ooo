# 2026-02-15 testyy vs opentibiabr/otclient - Audit Batch 2 (bez sprawdzania buildów)

## Zakres i zasada
- Zakres: audyt plików źródłowych `Tibia/silnik/canary_test/testyy/src` względem oryginału `https://github.com/opentibiabr/otclient` (lokalny mirror: `/tmp/otclient_upstream`).
- Zasada operacyjna: **zero monitorowania buildów** (zgodnie z dyspozycją). Prace wyłącznie na różnicach kodu i korektach plików.

## Co zostało porównane
Porównanie plików różniących się od ostatniego stabilnego punktu prac (batch po i18n):
- `src/client/game.cpp`
- `src/framework/luaengine/luainterface.h`
- `src/framework/luaengine/luavaluecasts.cpp`
- `src/framework/otml/otmlnode.cpp`
- `src/framework/otml/otmlnode.h`
- `src/framework/otml/otmlparser.cpp`
- `src/framework/stdext/cast.h`
- `src/framework/stdext/string.cpp`
- `src/framework/ui/uiwidgetbasestyle.cpp`
- `src/CMakeLists.txt`

## Wykonane korekty (już zrobione)
1. `src/framework/otml/otmlnode.cpp`
- zamiana `std::ranges::find` -> `std::find`
- cel: ograniczenie ryzyka ICE MSVC na nowym toolsecie

2. `src/framework/otml/otmlnode.h`
- zamiana `starts_with/ends_with` na warunek oparty o `size/front/back`
- cel: usunięcie zależności od C++20 API w tym TU

3. `src/framework/otml/otmlparser.cpp`
- dodany helper `startsWith(std::string_view, std::string_view)`
- wszystkie `starts_with(...)` zamienione na helper
- warunek listy `[...]` zamieniony na `size/front/back`

4. `src/CMakeLists.txt`
- dla `otmlnode.cpp` i `otmlparser.cpp` ustawione per-file: `/Od /Ob0 /Oy- /std:c++17` + `SKIP_PRECOMPILE_HEADERS ON`
- usunięte wymuszanie `/d2SSAOptimizer-` z per-file flags

5. `src/framework/stdext/string.cpp`
- zamiana `starts_with` na `!empty() && front()==...`
- zamiana `std::ranges::find_if`/`std::views::reverse` na `std::find_if` + reverse iteratory
- zamiana `std::erase_if` na `erase(remove_if(...))`
- cel: uproszczenie ścieżek kompilatora w pliku po dużych zmianach i18n (Unicode)

6. `src/framework/ui/uiwidgetbasestyle.cpp`
- dodany helper `startsWith(std::string_view, std::string_view)`
- trzy użycia `starts_with(...)` zamienione na helper
- cel: analogiczne odchudzenie od C++20 API w pliku znajdującym się na liście TU z ręcznymi flagami MSVC

## Różnice względem oryginału, które na razie zostają (świadomie)
1. `src/framework/stdext/cast.h`
- lokalny workaround pod MSVC (`safe_cast/unsafe_cast` z uproszczoną ścieżką wyjątków na `_MSC_VER`)
- decyzja: zostawić do czasu pełnej stabilizacji CI na Windows

2. `src/framework/luaengine/luainterface.h`
- lokalny fallback dla `_MSC_VER` w `castValue` (bez `demangle_type<T>()` w ścieżce wyjątku)
- decyzja: zostawić (minimalizacja ryzyka ICE w template error-path)

3. `src/framework/luaengine/luavaluecasts.cpp`
- lokalna korekta bool->string (`true/false`) i kwalifikacja `Platform::Device`
- decyzja: zostawić (zgodność z lokalnymi deklaracjami)

4. `src/client/game.cpp` i `src/CMakeLists.txt`
- duże, celowe odchylenia funkcjonalne/projektowe od upstream
- decyzja: nie synchronizować 1:1; wykonywać tylko punktowe korekty stabilizacyjne

## Commity wykonane w tym ciągu prac
- `3a5f5d8fd` - `fix(msvc): avoid c++20 ICE in otml translation units`
- `013a5cea5` - `refactor(msvc): remove c++20-only helpers from stdext string utils`
- (w toku roboczym po tym audycie) zmiana `uiwidgetbasestyle.cpp` jak wyżej

## Plan następnych kroków (bez odpalania/monitorowania buildów)
1. Dokończyć batch 2
- zatwierdzić i wypchnąć zmianę `uiwidgetbasestyle.cpp`
- dopisać status tej zmiany do głównej dokumentacji i18n/build

2. Batch 3: audit kolejnych plików różniących się od upstream
- priorytet A: pliki z `framework/*` kompilowane na Windows i zawierające `starts_with`, `std::ranges`, `std::views`
- priorytet B: pliki z template-heavy error-path (`demangle_type`, `safe_cast`, `fmt::format` w throw)

3. Dopiero po zamknięciu kolejnych batchy kodowych
- pojedyncze odpalenie workflow Windows (bez aktywnego monitorowania co kilka minut)
- analiza dopiero finalnego logu

## Batch 3 - rozpoczęte i wykonane (kolejne pliki)
Wykonano kolejną serię korekt w plikach różniących się od upstream, bez dotykania logiki domenowej, tylko zamiana `starts_with/ends_with` na porównania kompatybilne z C++17:

1. `src/framework/graphics/bitmapfont.cpp`
- `src.starts_with("/")` -> kontrola `empty/front`
- `fbVal.starts_with("/")` -> kontrola `empty/front`

2. `src/framework/platform/win32platform.cpp`
- `process.ends_with(".exe")` -> `size/compare` suffix check

3. `src/framework/ui/uitextedit.cpp`
- `m_text.ends_with(" ")` -> `!empty && back() == ' '`

4. `src/framework/core/module.cpp`
- `path.ends_with('*')` i `path.ends_with('/')` -> `!empty && back()==...`

5. `src/framework/ui/uimanager.cpp`
- `sn.starts_with("UI")` -> `size/compare`

6. `src/framework/ui/uiwidget.cpp`
- `style->tag().starts_with("$")` -> `!empty && front() == '$'`

7. `src/framework/core/resourcemanager.cpp`
- dodane lokalne helpery `startsWith(...)` i `endsWith(...)`
- zamienione 4 użycia `starts_with/ends_with` (pakiety, resolvePath, isFileType)

### Efekt Batch 3
- W tej grupie plików usunięte wszystkie użycia `starts_with/ends_with`.
- Zachowana dotychczasowa logika funkcjonalna (zmiany tylko składniowo-kompatybilnościowe).

## Batch 4 - kolejne pliki różniące się od upstream
Dokończono usuwanie `starts_with/ends_with` w pozostałych plikach różniących się od upstream, które jeszcze je zawierały:

1. `src/framework/luaengine/luainterface.cpp`
- `key.starts_with("on")` -> `size/compare`
- `fileName.starts_with("/")` -> `empty/front`
- `buffer.starts_with("function")` -> `size/compare`

2. `src/client/creatures.cpp`
- `tmp.ends_with("/")` -> `empty/back`

3. `src/client/mapio.cpp`
- `fileName.ends_with(".otbm")` -> `size/compare` suffix check

### Status po Batch 4
- W plikach różniących się od oryginału `opentibiabr/otclient` nie ma już użyć `starts_with/ends_with`.
- Kolejny etap audytu: przegląd różnic pod `std::ranges` (tam gdzie różnimy się od upstream) i ocena, które miejsca warto podobnie odchudzić.
