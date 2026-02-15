# 2026-02-14 - Build Windows/Android: roznice, aktualny stan i plan naprawczy

## 1) Snapshot (aktualizacja)

- Data aktualizacji: `2026-02-14 22:41 UTC`
- Repo: `PtakuPL/ooo`
- Branch: `feature/i18n-multilanguage`

Korekta baz:
1. "Oryginal" wskazany przez Ciebie to `Tibia/silnik/canary`.
2. `canary` nie zawiera kodu klienta OTClient (to repo serwera), wiec dla buildow Windows/Android klienta praktyczny baseline kodu to:
   - `Tibia/silnik/canary_test/oryginall/otclient`
3. Ten dokument porownuje runy CI klienta i pliki klienta/build z tej przestrzeni.

Ten dokument zbiera:
1. Dokladne roznice miedzy ostatnim udanym a ostatnim nieudanym buildem Windows.
2. To, co zostalo juz zrobione i co realnie weszlo do runow.
3. Najnowszy status Android (ten sam punkt awarii) z twardymi danymi z logu.
4. Plan naprawczy rozpisany na zadania i podpunkty.

Dodatkowe, pelne porownanie do upstream `opentibiabr/otclient`:
- `Dokumentacja/2026-02-14_testyy_vs_opentibiabr_otclient_dokladne_porownanie.md`

## 2) Windows - dokladne porownanie (ostatni success vs ostatni fail)

### 2.1 Porownywane runy

1. Ostatni udany `Build - Windows`
- Run ID: `21802468391`
- Data: `2026-02-08 17:40:52 UTC`
- SHA: `0a34ffb490b9a1b0b74256d69f87adf3c9394915`
- URL: https://github.com/PtakuPL/ooo/actions/runs/21802468391

2. Ostatni nieudany `Build - Windows`
- Run ID: `22024533938`
- Data: `2026-02-14 21:26:56 UTC`
- SHA: `d7e1747279e0f4ed86cea02872cda94e33e48afa`
- URL: https://github.com/PtakuPL/ooo/actions/runs/22024533938

### 2.2 Dokladna roznica workflow

Porownanie:
- `git diff --name-status 0a34ffb..d7e174 -- .github/workflows/build-windows.yml`

Wynik:
- Brak roznic (plik workflow Windows nie zmienil sie miedzy success a latest fail).

Wniosek:
- Awaria nie wynika z modyfikacji `build-windows.yml`.

### 2.3 Dokladne roznice plikow build-related (miedzy SHA success i fail)

Pliki istotne dla kompilacji klienta, ktore ulegly zmianie:
1. `.github/workflows/build-android.yml`
2. `.github/workflows/build-linux.yml`
3. `.github/workflows/build-wasm.yml`
4. `.github/workflows/analysis-sonarcloud-canary.yml`
5. `.github/workflows/analysis-sonarcloud-linux.yml`
6. `.github/workflows/analysis-sonarcloud-wasm.yml`
7. `Tibia/silnik/canary_test/testyy/src/CMakeLists.txt`
8. `Tibia/silnik/canary_test/testyy/src/framework/otml/otmlnode.cpp`
9. `Tibia/silnik/canary_test/testyy/src/framework/otml/otmlparser.cpp`
10. `Tibia/silnik/canary_test/testyy/src/framework/otml/otmlnode.h`
11. `Tibia/silnik/canary_test/testyy/src/framework/stdext/cast.h`
12. `Tibia/silnik/canary_test/testyy/src/framework/luaengine/luainterface.h`
13. `Tibia/silnik/canary_test/testyy/src/framework/luaengine/luavaluecasts.cpp`
14. `Tibia/silnik/canary_test/testyy/src/client/game.cpp`
15. `Tibia/silnik/canary_test/testyy/src/framework/stdext/string.cpp`

Uwaga:
- To lista z obszaru build/runtime klienta. W repo zaszlo rownolegle bardzo duzo zmian i18n, ale nie sa one bezposrednio zwiazane z awaria kompilacji C++.

### 2.4 Twarde dane z latest fail (`22024533938`)

Krok `Build`:
1. `otmlparser.cpp`
- `fatal error C1001` w `framework/otml/otmlparser.cpp(47)`
- `FAILED: ... otmlparser.cpp.obj`

2. `otmlnode.cpp`
- `fatal error C1001` w `framework/otml/otmlnode.cpp(70)`
- `FAILED: ... otmlnode.cpp.obj`

3. Koniec:
- `ninja: build stopped: subcommand failed.`
- `Access violation`
- exit code `1`

Dodatkowa obserwacja z poprzedniego runu (`22023736948`):
- byly ostrzezenia `D9025` (`/O1` nadpisane przez `/Od`, `/Ob2` przez `/Ob0`).

Stan po kolejnym commicie i runie (`22024533938`):
- `D9025` juz nie wystapil,
- ale `C1001` pozostal.

### 2.5 Nowy typ fail (2026-02-15) po workaroundzie `/std:c++17` dla OTML

Nowsze runy na branchu `feature/i18n-multilanguage` zaczely padac szybciej (zanim dojdzie do ewentualnego `C1001`),
poniewaz dla `framework/otml/otmlnode.cpp` i `framework/otml/otmlparser.cpp` wymuszono `/std:c++17`,
a te TU includuja `framework/global.h` / `framework/pch.h`, ktore uzywaja C++20 (m.in. `std::numbers` i `concept`).

Dotkniete runy:
- `22026595816` (SHA: `3a5f5d8fd1df2513679245065d5fc800bb6830ce`)
- `22026707920` (SHA: `013a5cea50d83cded49b6a52b3fb42478c77f44f`)

Symptomy (z adnotacji kompilatora):
- `std::numbers` nie istnieje -> wymagany `/std:c++20`
- `concept`/`requires` nie jest rozpoznawane
- bledy w `framework/const.h`, `framework/util/rect.h`, `framework/stdext/storage.h`

Wniosek:
- Workaround "OTML na C++17" jest niekompatybilny z reszta frameworka, bo naglowki sa C++20.
- Workaround musi zostac: (a) bez zmiany standardu, lub (b) OTML musi odciac zaleznosc od `global.h/pch.h` (znacznie wiekszy refactor).

## 3) Co juz zrobiono po stronie Windows (i co realnie weszlo do CI)

### 3.1 Potwierdzenie, ze run odpalil sie z nowymi zmianami

Ostatni fail Windows (`22024533938`) ma SHA:
- `d7e1747279e0f4ed86cea02872cda94e33e48afa`

To commit:
- `fix(msvc): disable Release optimization globally to avoid recurring C1001 ICE`

Czyli run rzeczywiscie byl juz na poprawkach.

### 3.2 Najwazniejsze zmiany zrobione dotad

1. W `Tibia/silnik/canary_test/testyy/src/CMakeLists.txt`:
- usuwanie `/O1` i `/Ob2` z `CMAKE_*_FLAGS_*` dla MSVC,
- globalne wymuszenie `/Od /Ob0 /Oy-` dla Release/RelWithDebInfo,
- utrzymanie per-file workaround dla:
  - `framework/luaengine/luavaluecasts.cpp`
  - `framework/otml/otmlnode.cpp`
  - `framework/otml/otmlparser.cpp`
  - `framework/ui/uiwidgetbasestyle.cpp`
- flagi per-file: `/Od /Ob0 /Oy- /d2SSAOptimizer-`
- `SKIP_PRECOMPILE_HEADERS ON` na tych TU.

2. W kodzie OTML i cast:
- odchudzenie/sciezki mniej template-heavy pod MSVC w obszarach `otml*`, `cast.h`, `luainterface.h`.

3. Audit UTF-8:
- poprawki bezpieczenstwa operacji znakowych (`game.cpp`, `stdext/string.cpp`) pod "wszystkie litery swiata".

## 4) Android - najnowszy fail i potwierdzona przyczyna techniczna

### 4.1 Ostatni fail Android

- Run ID: `22023855055`
- Data: `2026-02-14 20:34:25 UTC`
- SHA: `b69e05a733b2f1f9b22764fe648f63f435f73285`
- URL: https://github.com/PtakuPL/ooo/actions/runs/22023855055

Bledy:
1. `:app:buildCMakeRelWithDebInfo[arm64-v8a] FAILED`
2. `ninja: error: build.ninja:422: bad $-escape (literal $ must be written as $$)`

### 4.2 Co pokazaly nowe diagnostyki z workflow

W `app/.cxx/.../build.ninja`, linia `422` (`LINK_LIBRARIES`) zawiera:
- surowe `$<1:...libssl.a ... libcrypto.a -ldl -pthread>`

To znaczy:
- do wygenerowanego `build.ninja` przedostal sie nierozwiniety generator expression CMake (`$<...>`),
- Ninja traktuje to jako niepoprawny znak `$` i przerywa build.

Dodatkowa uwaga:
- diagnostyka "suspicious '$' tokens" probowala uzyc `rg`,
- na runnerze bash `rg` nie bylo dostepne (`line 14: rg: command not found`),
- ale kluczowy dump linii 422 i tak zostal zebrany.

### 4.3 Co juz zrobiono po stronie Android

Commit `b69e05a73`:
1. `.github/workflows/build-android.yml`
- czyszczenie `app/.cxx` i stale `build.ninja`,
- diagnostyka przy failu (dump fragmentu `build.ninja`).

2. `Tibia/silnik/canary_test/testyy/src/CMakeLists.txt`
- szerokie escaping `$` w `CMAKE_*FLAGS*`,
- przejscie z `add_definitions(-D\"VERSION=...\")` na `target_compile_definitions`.

Wynik:
- build dalej pada, ale mamy teraz twardy dowod gdzie i dlaczego (`$<1:...>` w `LINK_LIBRARIES`).

## 5) Wnioski techniczne na teraz

1. Windows:
- to nadal MSVC `cl.exe` ICE (`C1001`) w TU `otmlparser.cpp` i `otmlnode.cpp`,
- nie jest to problem roznicy workflow Windows,
- usuniecie kolizji `/O1` vs `/Od` poprawilo czystosc komendy, ale nie usunelo ICE.

2. Android:
- to nie jest problem Unicode/gradle resource text,
- glowna przyczyna to wyciek generator expression (`$<...>`) do `build.ninja`,
- najbardziej podejrzany obszar to linkowanie OpenSSL przez zmienne (`OPENSSL_LIBRARIES`) w sekcji Android CMake.

## 6) Plan naprawczy (zadania + podpunkty)

## Zadanie A - Android: usunac `$<...>` z `build.ninja` (priorytet 1)

1. Naprawa CMake linkowania OpenSSL w Android:
- w `target_link_libraries(... ANDROID ...)` wycofac linkowanie przez `${OPENSSL_LIBRARIES}`,
- uzyc targetow importowanych:
  - `$<$<BOOL:${OTC_ENABLE_OPENSSL}>:OpenSSL::SSL>`
  - `$<$<BOOL:${OTC_ENABLE_OPENSSL}>:OpenSSL::Crypto>`
- uniknac mieszania "raw variables + imported targets" dla tego samego dependency.

2. Dodac diagnostyke CMake przy konfiguracji:
- wypisac wartosci `OPENSSL_LIBRARIES`, `OPENSSL_LIBRARY`, `OPENSSL_CRYPTO_LIBRARY`,
- wypisac `INTERFACE_LINK_LIBRARIES` targetow `OpenSSL::SSL`/`OpenSSL::Crypto` (jesli istnieja),
- celem jest szybkie potwierdzenie, czy generator expression pochodzi z tych zmiennych.

3. Poprawic diagnostyke workflow:
- zastapic `rg` poleceniem dostepnym na runnerze (`grep -nE`),
- zachowac dump `nl -ba ... | sed -n '410,440p'`.

4. Walidacja:
- odpalic tylko `Build - Android`,
- warunek zaliczenia: brak `bad $-escape`, brak surowego `$<...>` w `LINK_LIBRARIES`.

## Zadanie B - Windows: domknac C1001 po usunieciu D9025 (priorytet 2)

1. Najpierw przywrocic spojnosc standardu C++:
- usunac wymuszenie `/std:c++17` na OTML TU (musi zostac C++20, bo includuje `global.h/pch.h`),
- zostawic per-file `SKIP_PRECOMPILE_HEADERS ON` oraz `/Od /Ob0 /Oy-` na tych TU.

2. Potwierdzenie bazowe po powyzszym:
- odpalic `Build - Windows` i sprawdzic, czy wraca `C1001` (oczekiwane, bo to pierwotny problem),
- jesli build przejdzie, zamykamy temat Windows.

3. Dalsza redukcja zlozonosci dwoch TU (jesli `C1001` wraca):
- uproscic kod w okolicach `otmlparser.cpp(47)` i `otmlnode.cpp(70)` oraz ich include-chain,
- ograniczyc sciezki wyjatkow i operacje template-heavy widoczne dla tych TU pod MSVC.

4. Iteracja CI:
- odpalac tylko `Build - Windows` po kazdej malej zmianie,
- zawsze analizowac pierwszy failing TU i tylko jego stabilizacje.

5. Plan awaryjny, jesli C1001 utrzyma sie mimo redukcji kodu:
- przypiac starszy, stabilny toolset MSVC w workflow Windows (tymczasowo),
- docelowo wrocic do biezacego toolsetu po domknieciu poprawki kodowej.

## Zadanie C - Dyscyplina dokumentacyjna po kazdym runie

1. Po kazdym runie dopisywac:
- Run ID
- SHA
- godzina UTC
- pierwszy blad
- decyzja co dalej

2. Ten plik jest kanonicznym logiem prac buildowych:
- `Dokumentacja/2026-02-14_windows_build_diff_i_plan_naprawczy.md`

## 7) Najblizsza sekwencja wykonania

1. Wdrozyc poprawke Android OpenSSL linking (zadanie A.1-A.3).
2. Odpalic `Build - Android` na tym commicie.
3. Po wyniku Android: kontynuowac iteracje Windows (`Build - Windows`).
4. Dopisac nowe runy i decyzje do tego dokumentu bez posilkowania sie pamiecia.
