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
