# 2026-02-21: Analiza Linux/Windows CI po seriach poprawek

## 1. Zakres i stan

Data analizy: 2026-02-21.

Zakres:
- OTC Client build Linux (`Build - Linux (OTC Client)`)
- OTC Client build Windows (`Build - Windows`)
- commity naprawcze na `master`
- pelna lista bledow od 2026-02-20 (run-by-run) jest w:
  - `Dokumentacja/01_Instalka_Klient/2026-02/2026-02-21_lista_bledow_od_2026-02-20_linux_windows.md`

Stan na moment zapisu:
- Linux run `22256469195` (SHA `391a028489`) - in progress
- Linux run `22256435140` (SHA `5d5ca0659c`) - in progress
- Windows run `22256688321` (SHA `4ca838ab60`) - in progress (odpalony recznie)

## 2. Co ustalilismy (fakty z logow)

### Linux - os czasu i root-cause

1. Run `22255064700` (job `64384757688`, SHA `54aee17bf9`)
- Pierwszy twardy blad: brakujace bindy po splicie plikow Lua/C++.
- Objawy: `no matching function for call to push_luavalue(...)`, `luavalue_cast(...)`, `invalid use of incomplete type`, dostep do metod private (`Thing::lua_setMarked`, `Thing::lua_setHighlight`).
- Wniosek: regresja po refaktorze podzialu `luafunctions*`.

2. Runy `22255501545` i `22255503356` (SHA `4a8d4b90d7`)
- Pierwszy twardy blad: `fmt::type_is_unformattable_for<lzma_ret, char>`.
- Plik: `Tibia/silnik/canary_test/testyy/src/client/spriteappearances.cpp`.
- Wniosek: formatowanie typu `lzma_ret` bez jawnej konwersji.

3. Runy `22255967586` i `22255969710` (SHA `1264640963`)
- Pierwszy twardy blad: `fmt::type_is_unformattable_for<ThingCategory, char>`.
- Pliki: `thingtype.cpp`, `thingtypemanager.cpp`.
- Wniosek: kolejna klasa tego samego problemu - enum bez formattera/casta.

4. Run `22256067149` (SHA `cda0415f92`)
- Nadal ten sam blad `ThingCategory` (fixy FreeType nie adresowaly tego miejsca).

### Windows - os czasu i root-cause

Run `22255969728` (job `64386870164`, SHA `1264640963`):
- Krok `Configure CMake` padl, ale przyczyna pierwotna to `vcpkg install`.
- Pierwszy twardy blad: pobieranie `gtest` zwrocilo HTTP 502:
  - `https://github.com/google/googletest/archive/v1.17.0.tar.gz: failed: status code 502`
- Nastepne bledy CMake (`Ninja not set`, `C/CXX compiler not set`) sa wtornymi skutkami przerwanego `vcpkg install`.
- Wniosek: to byl incydent sieciowy/upstream, nie blad merytoryczny CMake ani C++.

## 3. Co zostalo poprawione (commit -> zmiana)

1. `4a8d4b90d` - `fix(client): restore lua bindings after luafunctions split`
- Przywrocenie brakujacych include/friend dla bindingow klienta Lua.
- Dotkniete pliki:
  - `src/client/luafunctions.cpp`
  - `src/client/luafunctions_entities.cpp`
  - `src/client/luafunctions_ui_client.cpp`
  - `src/client/thing.h`
- Uwaga operacyjna: commit zawieral tez staged pliki statusowe i18n.

2. `126464096` - `fix(linux): cast lzma_ret before fmt formatting`
- `spriteappearances.cpp`: jawny cast `lzma_ret` do typu liczbowego w komunikacie `fmt`.

3. `cda0415f9` - `chore(client): harden fmt logging for FreeType error codes`
- `TTFFont.cpp`: jawne casty kodow `FT_Error` w logowaniu.
- Dzialanie defensywne przeciw analogicznym problemom formattera.

4. `5d5ca0659` - `fix(linux): cast thing enums in fmt exception paths`
- `thingtype.cpp`: cast `ThingCategory` i `ThingAttr` w `Exception(...)`.
- `thingtypemanager.cpp`: cast `ThingCategory` w `Exception(...)`.

5. `391a02848` - `fix(fmt): provide enum format_as fallback for all fmt versions`
- `framework/pch.h`: globalny `format_as(E)` dla enumow bez warunku na wersje `FMT_VERSION`.
- Cel: nie latac pojedynczych miejsc, tylko domknac klase bledu systemowo.

## 4. Bledne zalozenia, ktore skorygowalismy

1. "Linux dalej pada na tym samym bledzie".
- Nie zawsze. Klasa bledu zmieniala sie etapami:
  - najpierw split Lua bindings,
  - potem `lzma_ret`/fmt,
  - potem `ThingCategory`/fmt.

2. "Windows padl na CMake".
- Formalnie tak, ale root-cause byl w `vcpkg` (HTTP 502 na source `gtest`).

3. "Naprawa 1 pliku wystarczy".
- Nie. Ten sam pattern formattera dotknal wielu miejsc, stad decyzja o globalnym fallbacku enumow w `pch.h`.

## 5. Ryzyka i rzeczy do dopiecia

1. Wysoka zmiennosc `master` (worker wrzuca kolejne commity) utrudnia jednoznaczne porownanie runow 1:1 do konkretnego fixa.
2. Windows nadal moze losowo failowac na etapie pobierania zaleznosci (`vcpkg` / GitHub source tarballs).
3. Dwa runy Linux z fixami enum (`5d5ca0659`, `391a02848`) byly jeszcze w toku na moment zapisu.

## 6. Zadania naprawcze (operacyjne)

### P0
1. Po zakonczeniu runow `22256435140` i `22256469195` zapisac pierwszy realny blad (jesli wystapi) i dopisac do tej osi czasu.
2. Po zakonczeniu runa `22256688321` potwierdzic czy Windows wszedl w faze kompilacji, czy zatrzymal sie ponownie na `vcpkg`.

### P1
1. Dodac retry dla kroku `Configure CMake` w `build-windows.yml` (tak jak Linux ma retry na transient vcpkg/network fail).
2. Rozwazyc prefetch/cache dla `gtest` source (zeby ograniczyc skutki 502 z GitHub source tarball).

### P2
1. Utrzymac zasade: kazdy nowy blad `fmt::type_is_unformattable_for<...>` traktowac jako sygnal klasy problemu, nie pojedynczego miejsca.
2. Przy commicie fixow buildowych unikac domieszania plikow statusowych workera (czystsza diagnostyka).

## 7. Run Windows odpalony po tej analizie

Na prosbe uruchomiono nowy build Windows:
- Run ID: `22256688321`
- Workflow: `Build - Windows`
- SHA: `4ca838ab60`
- Status przy zapisie: `in_progress`

## 8. Aktualizacja: nowy regres Linux po globalnym fallbacku enum/fmt

Po publikacji raportu wystapil nowy fail Linux:
- Run: `22256469195` (SHA `391a028489`)
- Objaw: `redefinition of ... format_as(E)` w `framework/pch.h`
- Efekt: build zatrzymuje sie bardzo wczesnie (okolo `[10/182]`), zamiast pozniejszego etapu.

Wdrozone dzialanie naprawcze:
- Commit: `0364a1c14` (`fix(fmt): guard enum format_as helper for legacy fmt only`)
- Pliki:
  - `canary_test/testyy/src/framework/pch.h`
  - `canary_test/src/pch.hpp`
- Zmiana:
  - helper `format_as(E)` ograniczony do legacy fmt:
    - `#if !defined(FMT_VERSION) || FMT_VERSION < 80000`
  - cel: brak kolizji z nowszymi wersjami `fmt`, ktore dostarczaja wlasne wsparcie enum `format_as`.

Run walidacyjny po fixie:
- `22257107432` (`Build - Linux (OTC Client)`, SHA `0364a1c14`)

## 9. Aktualizacja: Linux passed, Windows nadal w toku

Linux:
- run `22257107432` zakonczony `success` po fixie `0364a1c14`.
- build jest zielony, ale log nadal ma wysoki wolumen warningow.
- dominujacy warning: `-Wsign-compare` z `framework/luaengine/luabinder.h:83` (setki powtorzen przez instancjacje szablonow).

Windows:
- ostatni odpalony run: `22257127872` (`Build - Windows`, SHA `b5f0cffbf0b1e6411c7404ed49c7a381ebd1daa5`)
- status na `2026-02-21 13:21:29 UTC`: `in_progress`.

## 10. Aktualizacja 2026-02-21 18:30 UTC: Windows nadal fail (ten sam root-cause)

Potwierdzenie z najnowszego runa:
- run `22261152958`, job `64399602609`
- status: `failure`
- SHA: `25eec76812d206ce664d11ea9b3d085395b7977b`

Pierwsze bledy z logu build:
- `FAILED ... framework/luafunctions_graphics.cpp.obj`
- `luainterface.h(484) : fatal error C1001`
- `FAILED ... framework/luafunctions.cpp.obj`
- `luabinder.h(152) : fatal error C1001`
- `Access violation`, `ninja: build stopped`

Wniosek:
- To nie jest nowa klasa bledu, tylko kontynuacja globalnego `MSVC ICE C1001` w sciezce Lua binder/interface.
- Numer pliku kompilacji (`[10/183]`, `[30/183]`, itp.) nie jest stabilnym wskaznikiem postepu (kompilacja rownolegla ninja).

## 11. Stan roboczy zmian kodu (lokalnie, przed kolejnym push)

Przygotowane poprawki pod C1001 (do walidacji nowym runem po pushu):
- `canary_test/testyy/src/framework/luaengine/luabinder.h`
  - wyniesienie throw path poza lambdy/template-heavy sciezke
  - zamiana czesci lambd na prostsze funktory
- `canary_test/testyy/src/framework/luaengine/luainterface.h`
  - uproszczenie `castValue<T>()`
  - helper `throwLuaBadValueCast(...)`
- `canary_test/testyy/src/framework/luaengine/luainterface.cpp`
  - definicje helperow throw (`noinline` na MSVC)

Uwaga operacyjna:
- run `22261152958` byl na SHA `25eec768...` (commit statusowy workera), wiec nie mial gwarancji zawierac tych lokalnych zmian.

## 12. Aktualizacja 2026-02-21 20:45 UTC: nowy stan po commicie `b3225cdd`

Potwierdzone najnowsze runy na SHA `b3225cddb1fbe3aaaae058d56ef3476d42895bd1`:

- Linux: `22263021182` - `failure`
- Windows: `22263022244` - `failure`

### Linux: nowy root-cause (regresja kodu, nie infra)

Pierwszy realny blad (Debug i Release):
- `luainterface.h:497:23: error: no matching function for call to 'luavalue_cast(... std::string_view&)'`
- oraz wtornie:
  - `cannot bind non-const lvalue reference of type 'Color&' to an rvalue of type 'Color'`

Lokalizacja i przyczyna:
- `canary_test/testyy/src/framework/luaengine/luainterface.h` (`castValue<T>()`)
- po refaktorze pod MSVC zniknal dawny uklad `if constexpr (...) { ... } else { ... }`;
  dla `T=std::string_view` kompilator i tak instancjuje sciezke `luavalue_cast(index, value)`, co powoduje fail.

Wniosek:
- Linux nie jest juz zielony po tym commicie.
- To jest deterministyczna regresja kodu (nie transient CI/network).

### Windows: C1001 nadal aktywny, ale punkt awarii przesuniety

Pierwszy realny blad:
- `FAILED ... framework/luaengine/luainterface.cpp.obj`
- `luainterface.cpp(41) : fatal error C1001`
- potem: `Access violation`, `ninja: build stopped`

Porownanie do poprzedniego runa (`22261152958`):
- wczesniej: `luainterface.h(484)` + `luabinder.h(152)`
- teraz: `luainterface.cpp(41)` (helper throw path)

Wniosek:
- klasa bledu jest ta sama (`MSVC ICE C1001`), ale trigger przesunal sie do nowego helpera.
- workaround nie zamknal problemu, tylko zmienil miejsce crashu.

### Dodatkowe fakty techniczne (wplyw na skutecznosc napraw)

1. Runner `windows-2022` nadal ma tylko:
   - `14.44.35207`
   - `14.29.30133`
   Workflow poprawnie wybiera `14.44` (14.29 odpada przez `compiler.h`).

2. `luainterface.cpp` nie jest obecnie objety najmocniejsza grupa flag anty-ICE
   (`/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt /permissive-`, `SKIP_PRECOMPILE_HEADERS ON`)
   w `src/CMakeLists.txt`.

3. Mimo `-DCMake_MSVC_PARALLEL=OFF` w workflow, globalne `/MP` nadal jest ustawiane
   w `src/CMakeLists.txt` przez `target_compile_options(... /MP ...)`, wiec redukcja presji na MSVC
   jest tylko czesciowa.

### Priorytet po tej aktualizacji

P0:
1. Naprawic regresje Linux w `castValue<T>()` (przywrocic semantyke jak przed `b3225cdd` dla `std::string_view`).
2. Objac `luainterface.cpp` pelnym zestawem flag anty-ICE i wylaczeniem PCH per-file.
3. Uspojnic `/MP` tak, aby `CMake_MSVC_PARALLEL=OFF` faktycznie usuwal wieloprocesorowa kompilacje dla MSVC.

## 13. Aktualizacja 2026-02-21 21:05 UTC: naprawy wdrozone lokalnie (oczekuja na CI)

Wdrozone lokalnie poprawki kodu:

1. Linux regresja `castValue<T>()`:
- plik: `canary_test/testyy/src/framework/luaengine/luainterface.h`
- zmiana: przywrocony uklad `if constexpr (...) { ... } else { ... }`,
  tak aby dla `T=std::string_view` nie byla instancjowana sciezka `luavalue_cast(index, value)`.

2. Windows C1001 (nowy trigger w `luainterface.cpp`):
- plik: `canary_test/testyy/src/CMakeLists.txt`
- zmiana: `framework/luaengine/luainterface.cpp` dodany do grupy per-file flags:
  `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt /permissive-` + `SKIP_PRECOMPILE_HEADERS ON`.

3. Realne sterowanie `/MP` z workflow:
- plik: `canary_test/testyy/src/CMakeLists.txt`
- zmiana: usuniete globalne, bezwarunkowe `/MP`; teraz `/MP` jest ustawiane tylko gdy `CMake_MSVC_PARALLEL` jest wlaczone.

Status:
- zmiany sa przygotowane do walidacji przez nowe runy:
  - `Build - Linux (OTC Client)`
  - `Build - Windows`

## 14. Aktualizacja 2026-02-21 21:43 UTC: Windows run `22264154855` nadal fail

Nowy potwierdzony run:
- workflow: `Build - Windows`
- run: `22264154855`
- job: `64407063012`
- SHA: `f704b476d16a769c282170e13eac2d03ae021855`
- start: `2026-02-21T20:52:36Z`
- koniec: `2026-02-21T21:43:10Z`
- status: `failure`

Fakty z metadanych/adnotacji joba:
1. `Configure CMake` zakonczyl sie `success` (czyli to nie jest fail na etapie vcpkg/CMake).
2. Pierwszy twardy blad w kroku `Build`:
   - `Tibia/silnik/canary_test/testyy/src/framework/luaengine/luainterface.cpp:41`
   - komunikat: `Internal compiler error.`
3. W tym runie adnotacje NIE pokazuja juz `luabinder.h` ani `luainterface.h` jako miejsca awarii.

Wniosek:
- to nadal `WIN-01` (MSVC ICE C1001), ale trigger pozostaje skupiony na TU `luainterface.cpp`.
- w porownaniu z runem `22261152958`:
  - bylo: `luainterface.h(484)` + `luabinder.h(152)`
  - jest: `luainterface.cpp(41)`

## 15. Dalsza stabilizacja pod kolejny run CI (kod lokalny)

Po analizie runa `22264154855` przygotowano dodatkowe odchudzenie sciezki Lua:

1. `canary_test/testyy/src/framework/luaengine/luathrowhelpers.cpp` (nowy plik):
- wydzielenie definicji:
  - `throwLuaBadValueCast(...)`
  - `luabinder::throwLuaNilMemberCall()`
- cel: usuniecie throw-helperow z TU `luainterface.cpp`.

2. `canary_test/testyy/src/framework/luaengine/luainterface.cpp`:
- usuniete definicje helperow throw.
- dodane:
  - `#pragma optimize("", off)` / `on` (MSVC, bez clang-cl) dla calego TU.

3. `canary_test/testyy/src/framework/luaengine/luainterface.h`:
- `castValue<T>()`:
  - `std::is_same_v<std::remove_cvref_t<T>, std::string_view>`
  - cel: domkniecie wariantow cv/ref dla `std::string_view`.

4. `canary_test/testyy/src/framework/luaengine/luavaluecasts.h/.cpp`:
- dodany overload:
  - `bool luavalue_cast(int index, std::string_view& str);`
- cel: fallback dla sciezek, gdzie kompilator i tak probuje instancjowac `luavalue_cast` dla `std::string_view`.

5. `canary_test/testyy/src/CMakeLists.txt`:
- dodany `framework/luaengine/luathrowhelpers.cpp` do:
  - listy `SOURCE_FILES`
  - grupy plikow objetych per-file anti-ICE flags.

Uwaga operacyjna:
- zgodnie z decyzja projektowa walidacja tylko przez GitHub Actions (bez lokalnej kompilacji).
