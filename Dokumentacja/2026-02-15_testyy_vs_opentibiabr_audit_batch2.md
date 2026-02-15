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

## Batch 5 - redukcja `std::ranges` w plikach różniących się od upstream
Wykonane zmiany (semantycznie równoważne):

1. `src/framework/util/crypt.cpp`
- `std::ranges::transform` -> `std::transform` + jawne `std::toupper/std::tolower` (bezpieczny cast)

2. `src/framework/core/module.cpp`
- `std::ranges::find` -> `std::find`

3. `src/framework/core/garbagecollection.cpp`
- `std::erase_if` (mapa) -> pętla z `erase(it)`
- `std::erase_if` (wektor) -> `erase(remove_if(...))`

4. `src/client/uigraph.cpp`
- `std::ranges::minmax_element` -> `std::minmax_element(begin, end)`

5. `src/client/mapview.cpp`
- `std::ranges::find` -> `std::find`

6. `src/framework/ui/uiverticallayout.cpp`
- `std::ranges::reverse_view` -> iteracja po `rbegin()/rend()`

7. `src/framework/ui/uihorizontallayout.cpp`
- `std::ranges::reverse_view` -> iteracja po `rbegin()/rend()`

8. `src/framework/ui/uimanager.cpp`
- `std::ranges::find` -> `std::find`

9. `src/framework/net/protocol.cpp`
- `std::ranges::generate` -> `std::generate(begin, end, ...)`

10. `src/framework/graphics/shaderprogram.cpp`
- `std::ranges::find` -> `std::find`

11. `src/framework/core/modulemanager.cpp`
- `std::ranges::find` -> `std::find`

12. `src/client/tile.h`
- inline `std::ranges::find` -> `std::find`

13. `src/client/thingtype.h`
- `std::ranges::find_if` -> `std::find_if(begin, end, ...)`

14. `src/client/spriteappearances.cpp`
- `std::ranges::find_if` -> `std::find_if(begin, end, ...)`

15. `src/client/protocolcodes.cpp`
- `std::ranges::find_if` -> `std::find_if(begin, end, ...)`

## Batch 6 - domknięcie największego pliku
1. `src/client/attachableobject.cpp`
- `std::erase_if` -> `erase(remove_if(...))`
- `std::ranges::find` -> `std::find`

2. `src/client/map.cpp`
- `std::ranges::find` -> `std::find`
- `std::ranges::reverse` -> `std::reverse`

3. `src/client/tile.cpp`
- `std::ranges::find` -> `std::find`
- `std::ranges::reverse_view` -> pętle po `rbegin()/rend()`

4. `src/framework/core/resourcemanager.cpp`
- `std::ranges::find` -> `std::find`
- `std::ranges::reverse_view` -> pętle po `rbegin()/rend()`

5. `src/framework/ui/uiwidget.cpp`
- wszystkie użycia `std::ranges::find/rotate/reverse/reverse_view` zastąpione odpowiednikami `std::find/std::rotate/std::reverse` i iteracją po reverse iteratorach

### Stan po Batch 6
- W plikach różniących się od upstream (`testyy/src` vs `opentibiabr/otclient`) nie ma już użyć:
  - `starts_with`
  - `ends_with`
  - `std::ranges::...`
  - `std::views::...`
  - `std::erase_if`

## Batch 7 - zamiana `container.contains(...)` na `find != end`
Wykonane w plikach różniących się od upstream:

1. `src/client/map.cpp`
- `nodes.contains(...)` -> `nodes.find(...) == nodes.end()`
- `m_attachedObjectWidgetMap.contains(...)` -> `find(...) != end()`

2. `src/client/mapio.cpp`
- `m_waypoints.contains(...)` -> `find(...) == end()`

3. `src/client/minimap.h`
- `m_tileBlocks[pos.z].contains(...)` -> `find(...) != end()`

4. `src/framework/graphics/bitmapfont.cpp`
- `colorCoordsMap.contains(...)` -> `find(...) == end()`

5. `src/framework/graphics/drawpool.h`
- `m_parameters.contains(...)` -> `find(...) != end()`

6. `src/framework/input/mouse.cpp`
- `m_cursors.contains(...)` -> `find(...) != end()`

7. `src/framework/platform/win32window.cpp`
- `m_keyMap.contains(...)` -> `find(...) != end()`

8. `src/framework/proxy/proxy_client.cpp`
- `m_proxies.contains(...)` -> `find(...) == end()`

9. `src/framework/sound/soundmanager.cpp`
- `m_clientSoundFiles.contains(...)` -> `find(...) != end()`

10. `src/framework/stdext/storage.h`
- `m_data.contains(...)` -> `find(...) != end()`

11. `src/framework/ui/uianchorlayout.cpp`
- `m_anchorsGroups.contains(...)` -> `find(...) != end()`

12. `src/framework/ui/uitextedit.cpp`
- `colorCoordsMap.contains(...)` -> `find(...) == end()`

### Pozostałe `contains(...)` po Batch 7
Pozostawione świadomie (nie dotyczą `std::*::contains`):
- metody domenowe geometrii: `Rect::contains(...)` itd.
- `nlohmann::json::contains(...)` w `framework/net/httplogin.cpp`

## Batch 8 - dodatkowe zabezpieczenie template error-path (MSVC)
1. `src/framework/otml/otmlnode.h`
- w `OTMLNode::value<T>()` dodano gałąź `_MSC_VER`, która nie używa `stdext::demangle_type<T>()` w komunikacie wyjątku
- gałąź non-MSVC pozostaje bez zmian

Cel:
- redukcja złożoności template error-path w TU związanych z OTML na MSVC.
