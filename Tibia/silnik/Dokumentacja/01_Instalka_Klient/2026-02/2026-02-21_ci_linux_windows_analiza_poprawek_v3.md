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
