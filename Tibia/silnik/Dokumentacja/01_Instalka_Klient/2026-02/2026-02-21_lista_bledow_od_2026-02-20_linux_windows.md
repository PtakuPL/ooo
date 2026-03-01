# 2026-02-21: Lista bledow CI od 2026-02-20 (Linux + Windows)

## Zakres i metoda

- Okres: od **2026-02-20 00:00 UTC** do **2026-02-21 12:40 UTC**.
- Repo: `PtakuPL/ooo`, branch `master`.
- Workflow:
  - `Build - Linux (OTC Client)`
  - `Build - Windows`
- Dane:
  - `gh run list --created ">=2026-02-20"`
  - `gh run view --json jobs`
  - `gh run view --log-failed`

Podsumowanie faili w badanym oknie:
- Linux: **31** failed runow.
- Windows: **11** failed runow.

## Aktualizacja po regresie (2026-02-21, po 12:45 UTC)

- Nowy fail Linux po "globalnym" fixie enum/fmt:
  - run `22256469195`
  - blad juz na wczesnym etapie kompilacji (`[10/182]`, `clock.cpp`)
  - root-cause: `redefinition of ... format_as(E)` z `framework/pch.h`

- Co zostalo zrobione, zeby to naprawic:
  - commit `0364a1c14` (`fix(fmt): guard enum format_as helper for legacy fmt only`)
  - zmiany:
    - `canary_test/testyy/src/framework/pch.h`
    - `canary_test/src/pch.hpp`
  - technika:
    - helper `format_as(E)` zostal ograniczony warunkiem:
      - `#if !defined(FMT_VERSION) || FMT_VERSION < 80000`
    - efekt: dla nowszych `fmt` (ktore juz maja wlasny enum `format_as`) nie dochodzi do redefinicji.
  - run z poprawka:
    - `22257107432` - <https://github.com/PtakuPL/ooo/actions/runs/22257107432>

## Aktualizacja: Linux po fixie jest zielony + warning backlog

- Potwierdzony sukces Linux po fixie:
  - run `22257107432`
  - status: `success`
  - SHA: `0364a1c14798316f6c66b6fcb30cceb7d803fdb6`

- Warningi z runa `22257107432` (zliczenie z logu):
  - lacznie linii z `warning:`: **778**
  - warningi kodu C++ (zrodla projektu): **775**
  - warning narzedziowy vcpkg (deprecation `x-gha`): **1**
  - warning linkera/libstdc++ (`-Wfree-nonheap-object`): **1**

- Rozklad warningow C++ (source):
  - `framework/luaengine/luabinder.h:83` - `-Wsign-compare` - **772** powtorzenia
  - `framework/otml/otmlnode.cpp:80` oraz `:96` - `-Wsign-compare` - **2**
  - `framework/otml/otmlemitter.cpp:85` - `-Wsign-compare` - **1**

- Dodatkowy warning linkera:
  - `/usr/include/c++/13/bits/shared_ptr_base.h:921` - `-Wfree-nonheap-object`
  - kontekst: `main.cpp:82` + globalny `Client g_client` (`client.cpp:37`)
  - to wyglada na ostrzezenie wynikajace z aliasowania/deletera `shared_ptr`, nie na pewny crash-time bug, ale wymaga przegladu semantyki ownership.

- Czy mozemy to poprawic:
  - tak; zdecydowana wiekszosc to jeden punkt `luabinder.h:83` i da sie to usunac lokalna zmiana typu/licznika.
  - po nim zostana 3 warningi `-Wsign-compare` w OTML i 1 warning ownership przy linku.

## Linux - lista bledow i sposob naprawy

### LNX-01: Regresja po split bindings Lua/C++
- Objawy:
  - `no matching function for call to push_luavalue(...)`
  - `no matching function for call to luavalue_cast(...)`
  - `invalid use of incomplete type`
  - private access: `Thing::lua_setMarked`, `Thing::lua_setHighlight`
- Runy:
  - `22255064700` - <https://github.com/PtakuPL/ooo/actions/runs/22255064700>
- Jak naprawiono:
  - commit `4a8d4b90d` (`fix(client): restore lua bindings after luafunctions split`)
  - przywrocenie brakujacych include i naprawa dostepu/friend dla bindingow.

### LNX-02: `fmt` nie formatuje `lzma_ret`
- Objaw:
  - `type_is_unformattable_for<lzma_ret, char>`
- Runy:
  - `22255501545` - <https://github.com/PtakuPL/ooo/actions/runs/22255501545>
  - `22255503356` - <https://github.com/PtakuPL/ooo/actions/runs/22255503356>
- Jak naprawiono:
  - commit `126464096` (`fix(linux): cast lzma_ret before fmt formatting`)
  - jawny cast kodu bledu do typu liczbowego przed `fmt`.

### LNX-03: `fmt` nie formatuje `ThingCategory`
- Objaw:
  - `type_is_unformattable_for<ThingCategory, char>`
- Runy:
  - `22255967586` - <https://github.com/PtakuPL/ooo/actions/runs/22255967586>
  - `22255969710` - <https://github.com/PtakuPL/ooo/actions/runs/22255969710>
  - `22256067149` - <https://github.com/PtakuPL/ooo/actions/runs/22256067149>
- Jak naprawiano:
  - commit `5d5ca0659` (`fix(linux): cast thing enums in fmt exception paths`) - fix punktowy.
  - commit `391a02848` - proba fixu globalnego (`format_as` dla enumow), ktora pozniej wywolala LNX-04.
- Status:
  - punktowy fix byl skuteczny dla tej klasy (pojawil sie sukces runu Linux na SHA `5d5ca0659`, run `22256435140`).

### LNX-04: Regresja po globalnym fallbacku `format_as`
- Objaw:
  - `redefinition of template ... format_as(E)` w `framework/pch.h:74`
- Run:
  - `22256469195` - <https://github.com/PtakuPL/ooo/actions/runs/22256469195>
- Przyczyna:
  - commit `391a02848` usunal stary guard wersji `fmt`, przez co `format_as` zderzyl sie z definicja dostepna w aktualnym `fmt`.
- Status i sposob naprawy:
  - fix wdrozony: commit `0364a1c14`.
  - zakres fixa:
    - `canary_test/testyy/src/framework/pch.h`
    - `canary_test/src/pch.hpp`
  - poprawne podejscie: warunek wersji/kompatybilnosci (`FMT_VERSION < 80000`) zamiast globalnego, bezwarunkowego fallbacku.
  - walidacja: uruchomiony run `22257107432` (status do potwierdzenia po zakonczeniu).

### LNX-99: Fail bez logu (brak tresci `--log-failed`)
- Technicznie widac tylko: step `Build` fail (Debug/Release), bez pierwszego bledu kompilatora.
- Runy:
  - `22254690620`, `22248887200`, `22248650860`, `22248602302`, `22248586599`, `22248053704`, `22248037405`, `22247871792`, `22247818915`, `22247799723`, `22246594550`, `22246581096`, `22246249117`, `22245780181`, `22245673448`, `22245431515`, `22245337754`, `22244614432`, `22244553249`, `22244520732`, `22244107040`, `22243654290`, `22243623290`, `22234048286`.

## Windows - lista bledow i sposob naprawy

### WIN-01: MSVC ICE C1001 (luainterface/luabinder)
- Objawy:
  - `luainterface.h(484) : fatal error C1001: Internal compiler error`
  - `luabinder.h(148) : fatal error C1001: Internal compiler error`
- Run:
  - `22255503360` - <https://github.com/PtakuPL/ooo/actions/runs/22255503360>
- Jak naprawiano:
  - strategia C++ workaroundow opisana w:
    - `Dokumentacja/01_Instalka_Klient/2026-02/Bledne_kompilacje_windows.md`
    - `Dokumentacja/01_Instalka_Klient/2026-02/plan_naprawczy_windows_build.md`
  - klucz: zmiany w kodzie C++ (problemowe templaty/bindingi), nie samo „ruszanie CMake/workflow”.

### WIN-02: `vcpkg` download fail (HTTP 502), pozornie „CMake fail”
- Objawy:
  - `googletest ... failed: status code 502`
  - `vcpkg_download_distfile.cmake ... Download failed, halting portfile`
- Run:
  - `22255969728` - <https://github.com/PtakuPL/ooo/actions/runs/22255969728>
- Jak naprawiano:
  - to blad infrastrukturalny/upstream (transient), nie merytoryczny blad C++.
  - podejscie naprawcze: retry kroku konfiguracji + mocniejszy cache/prefetch zaleznosci.

### WIN-03: Fail na kroku `Checkout repository`
- Runy:
  - `22248887187`, `22254370346`, `22254521382`
- Jak naprawiano:
  - brak zmian w kodzie C++; to problem procesu CI/infrastruktury (ponowne uruchomienie runa, stabilizacja checkout).

### WIN-99: Fail bez logu (step `Build`, ale brak tresci `--log-failed`)
- Runy:
  - `22234136342`, `22243721692`, `22244152617`, `22246245451`, `22248053706`, `22254586710`.
- Uwaga:
  - dla `22234136342` mamy historyczne potwierdzenie C1001 w starszej dokumentacji, ale w tym audycie CLI nie zwrocilo pelnego logu.

## Tabela krokow, na ktorych padaly runy (od 2026-02-20)

### Linux
- `Build` (Debug/Release): 31/31 runow fail.

### Windows
- `Build`: 7 runow fail.
- `Checkout repository`: 3 runy fail.
- `Configure CMake`: 1 run fail (root-cause: `vcpkg` HTTP 502).

## Korekta blednych zalozen

1. „Windows pada na CMake”:
   - nie zawsze; w runie `22255969728` root-cause to `vcpkg` + 502 na `googletest`.

2. „Jeden fix C++ zalatwia cala klase”:
   - nie; po `lzma_ret` pojawil sie analogiczny problem na `ThingCategory`.

3. „Globalny fallback `format_as` bez guardow jest bezpieczny”:
   - falsz; wywolal LNX-04 (redefinition).

4. „Brak logu = brak bledu”:
   - falsz; brak logu utrudnia diagnoze, ale metadata runu dalej pokazuje twardy fail kroku.

## Aktualizacja 2026-02-21 18:30 UTC (globalny obraz Windows)

Przeanalizowane najnowsze failed runy `Build - Windows`:
- `22255503360` (job `64385785574`)
- `22255969728` (job `64386870164`)
- `22256688321` (job `64388586003`)
- `22256763145` (job `64388767155`)
- `22257127872` (job `64389634544`)
- `22257729301` (job `64391080858`)
- dodatkowo najnowszy fail: `22261152958` (job `64399602609`)

### Windows: klasy bledow, czestotliwosc i status

1. `WIN-01` (krytyczny, globalny): MSVC ICE C1001 w OTClient Lua binding
- Powtarza sie w 5/6 analizowanych runow (oraz ponownie w `22261152958`).
- Staly wzorzec:
  - `FAILED ... framework/luafunctions_graphics.cpp.obj`
  - `luainterface.h(484) : fatal error C1001`
  - `FAILED ... framework/luafunctions.cpp.obj`
  - `luabinder.h(148/152) : fatal error C1001`
  - potem `Access violation`, `ninja: build stopped`.
- To jest glowny blocker Windows build.

2. `WIN-02` (incydentalny, infra): `vcpkg` download fail podczas configure
- Wykryty w runie `22255969728`.
- Objawy:
  - `Download failed, halting portfile`
  - `vcpkg install failed`
  - wtornie: `CMAKE_MAKE_PROGRAM is not set`, `CMAKE_C/CXX_COMPILER not set`.
- Klasa bledu niezalezna od C++ (transient/upstream).

3. `WIN-03` (niskie ryzyko, ale stale): `pathspec ... vcpkg ... did not match`
- Widoczne w wielu runach na kroku `Install vcpkg`.
- Nie jest bezposrednim root-cause ICE, ale wymaga cleanupu workflow.

### Korekta stanu prac

- Linux: zielony po fixach enum/fmt (`0364a1c14`) i pozniejszych poprawkach.
- Windows: nadal nieprzepuszczony przez globalny `C1001`.
- Nowszy run `22261152958` potwierdza, ze problem jest ten sam (nie nowy blad).

## Aktualizacja 2026-02-21 20:45 UTC (nowe runy po commicie `b3225cdd`)

Nowe runy:
- Linux: `22263021182` - <https://github.com/PtakuPL/ooo/actions/runs/22263021182>
- Windows: `22263022244` - <https://github.com/PtakuPL/ooo/actions/runs/22263022244>

### Linux: nowa regresja merytoryczna

Pierwszy realny blad:
- `luainterface.h:497:23: error: no matching function for call to 'luavalue_cast(int&, std::basic_string_view<char>&)'`
- w praktyce powtarza sie na wielu TU (`luafunctions_graphics.cpp`, `luafunctions_gfx_singletons.cpp`, `luafunctions.cpp`).

Wniosek:
- to nie jest infra i nie transient.
- regresja zostala wprowadzona refaktorem `castValue<T>()` (commit `b3225cdd`), gdzie dla `T=std::string_view`
  doszlo do zlej instancjacji sciezki `luavalue_cast`.

### Windows: C1001 nadal globalny, ale nowy trigger

Pierwszy realny blad:
- `FAILED ... framework/luaengine/luainterface.cpp.obj`
- `luainterface.cpp(41) : fatal error C1001`
- potem: `Access violation`, `ninja: build stopped`

Wniosek:
- nadal `WIN-01` (MSVC ICE C1001), ale po zmianach trigger przeniosl sie z `luainterface.h/luabinder.h` do `luainterface.cpp`.

### Dodatkowe obserwacje z logow

1. Toolset:
   - wybrane `14.44.35207` (dostepne: `14.44.35207`, `14.29.30133`).
   - to zgodne z workflow i ograniczeniami `compiler.h`.

2. `vcpkg`:
   - nadal pojawia sie ostrzezenie `pathspec ... vcpkg ... did not match`, ale krok `Install vcpkg` konczy sie sukcesem.
   - nie jest to root-cause tych dwoch runow.

### Dopisanie do listy klas bledow

#### LNX-05: Regresja po refaktorze `castValue<T>()` (string_view)
- Objaw:
  - `error: no matching function for call to luavalue_cast(... std::string_view&)`
- Run:
  - `22263021182`
- Przyczyna:
  - zmiana semantyki `castValue<T>()` po commicie `b3225cdd`.
- Status:
  - open (P0).

#### WIN-04: C1001 w `luainterface.cpp` po wyniesieniu throw helpera
- Objaw:
  - `luainterface.cpp(41) : fatal error C1001`
- Run:
  - `22263022244`
- Przyczyna:
  - ta sama klasa bugu MSVC, nowa lokalizacja triggera.
- Status:
  - open (P0), wymagane dalsze odchudzenie/scoping per-file flags.

## Aktualizacja 2026-02-21 21:05 UTC (status napraw lokalnych)

Wdrozone lokalnie (oczekuje na nowe runy CI):

1. Fix LNX-05:
- `luainterface.h`: przywrocony `else` w `castValue<T>()` dla poprawnej obslugi `std::string_view`.

2. Mitigacja WIN-04:
- `src/CMakeLists.txt`: `framework/luaengine/luainterface.cpp` dodany do grupy per-file anti-ICE flags
  (`/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt /permissive-`, `SKIP_PRECOMPILE_HEADERS ON`).

3. Korekta `/MP`:
- `src/CMakeLists.txt`: usuniete bezwarunkowe `/MP`; `/MP` zalezy teraz od `CMake_MSVC_PARALLEL`.

## Aktualizacja 2026-02-21 21:43 UTC (run `22264154855`)

Nowy fail Windows:
- run: `22264154855`
- job: `64407063012`
- SHA: `f704b476d16a769c282170e13eac2d03ae021855`
- status: `failure`

Adnotacje joba (GitHub API):
1. `Configure CMake` = `success`.
2. `Build` = `failure` z:
   - `Tibia/silnik/canary_test/testyy/src/framework/luaengine/luainterface.cpp:41`
   - `Internal compiler error.`

Wniosek:
- nadal klasa `WIN-01` (MSVC ICE C1001), ale w nowym runie trigger jest juz jednoznacznie na TU `luainterface.cpp`.
- to nie jest fail infrastrukturalny typu `vcpkg 502` ani fail checkout.

### Dopisanie do listy klas bledow

#### WIN-05: C1001 utrzymany na `luainterface.cpp` po rozszerzeniu anti-ICE
- Objaw:
  - `luainterface.cpp(41) : Internal compiler error`
- Run:
  - `22264154855`
- Status:
  - open (P0), wymagane dalsze odchudzenie TU i izolacja throw-helperow.
