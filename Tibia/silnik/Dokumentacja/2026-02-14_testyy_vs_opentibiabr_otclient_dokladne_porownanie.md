# 2026-02-14 - Dokladne porownanie `testyy` vs oryginal `opentibiabr/otclient`

## 1) Zrodla porownania

1. Upstream (oryginal):
- repo: `https://github.com/opentibiabr/otclient`
- branch: `main`
- commit: `e49212552dde02bb9dbe23b56acc036785721a0a`
- commit date: `2026-02-06 21:58:34 -0300`

2. Lokalny klient:
- katalog: `Tibia/silnik/canary_test/testyy`
- stan roboczy porownany do upstream snapshot powyzej

3. Czas weryfikacji:
- `2026-02-14 22:41 UTC` - runy CI (GitHub Actions API)

## 2) Zakres i metoda

Porownanie wykonane dla obszarow istotnych dla buildow i i18n:
1. `.github/workflows`
2. `CMakeLists.txt`, `src/CMakeLists.txt`, `cmake/*`, `vcpkg.json`
3. `src/framework/otml/*`, `src/framework/luaengine/*`, `src/framework/stdext/cast.h`
4. `android/*`
5. `modules/client_locales/*`
6. `src/framework/text/*` i `data/fonts/*`

## 3) Bilans roznic (ilosciowo)

1. `.github/workflows`
- 13 plikow roznych: `A=3, D=9, M=1`

2. `src`
- 389 plikow roznych: `A=10, D=28, M=351`

3. `android`
- 8 plikow roznych: `A=1, D=2, M=5`

4. `cmake`
- 2 pliki rozne: `D=1, M=1`

5. `modules/client_locales`
- 5 plikow roznych: `A=2, M=3`

6. `data/fonts`
- 132 roznice: `A=41, D=79, R=12`

Wniosek:
- `testyy` jest daleko od upstream nie tylko w i18n, ale tez w core CMake/CI/framework.

## 4) Dokladne roznice w plikach krytycznych (build i awarie)

`ins/del` policzone z `git diff --no-index --numstat`.

1. `.github/workflows/build-windows.yml` - `M 54/135`
2. `.github/workflows/build-android.yml` - `A 120/0` (tylko w `testyy`)
3. `CMakeLists.txt` - `M 131/53`
4. `src/CMakeLists.txt` - `M 666/279`
5. `src/framework/otml/otmlparser.cpp` - `M 34/53`
6. `src/framework/otml/otmlnode.cpp` - `M 13/5`
7. `src/framework/stdext/cast.h` - `M 35/2`
8. `src/framework/luaengine/luainterface.h` - `M 9/13`
9. `src/framework/luaengine/luavaluecasts.cpp` - `M 6/6`
10. `modules/client_locales/locales.lua` - `M 218/167`
11. `android/build.gradle` - `M 2/2`
12. `android/app/build.gradle(.kts vs .gradle)` - `M 38/39`
13. `src/framework/text/TTFFont.cpp` - `A 659/0`
14. `src/framework/text/TextShaper.cpp` - `A 234/0`
15. `src/framework/text/LocaleShaping.cpp` - `A 403/0`
16. `src/framework/text/Utf8.h` - `A 183/0`
17. `src/stduuid/uuid.h` - `A 1/0`

## 5) Fakty techniczne kluczowe dla naprawy

### 5.1 Windows workflow (duza roznica wzgledem upstream)

Upstream (`.github/workflows/build-windows.yml`):
1. runner `windows-2022`
2. build przez `lukka/run-cmake` + preset
3. inny model cache/concurrency/checkout

`testyy`:
1. runner `windows-latest`
2. reczna konfiguracja CMake (`cmake -S . -B build ...`)
3. wlasny flow cache/vcpkg

Znaczenie:
- zmiana `windows-2022` -> `windows-latest` moze zmieniac toolset MSVC miedzy dniami.
- obecny blad to `C1001` (ICE), czyli bardzo wrazliwy na wersje kompilatora i flag.

### 5.2 Android: roznica, ktora tlumaczy `bad $-escape`

W Android branch `src/CMakeLists.txt` w `testyy` jest:
- `$<$<BOOL:${OTC_ENABLE_OPENSSL}>:${OPENSSL_LIBRARIES}>`

W upstream Android branch jest po prostu:
- `${OPENSSL_LIBRARIES}`

To jest krytyczne, bo:
1. `OPENSSL_LIBRARIES` na Android moze juz zawierac generator expression (`$<...>`).
2. Owiniecie tego kolejnym `$<$<BOOL:...>...>` daje zagniezdzone `$<...>`.
3. To moze wyciec do `build.ninja` jako surowe `$<1:...>` i dac blad:
- `bad $-escape (literal $ must be written as $$)`.

### 5.3 Windows C1001: roznica w TU `otml*`

`testyy` ma modyfikacje MSVC-workaround w:
1. `src/framework/otml/otmlparser.cpp`
2. `src/framework/otml/otmlnode.cpp`
3. `src/framework/stdext/cast.h`
4. `src/framework/luaengine/luainterface.h`

Awarie CI wskazuja nadal:
1. `otmlparser.cpp(47)` - `fatal error C1001`
2. `otmlnode.cpp(70)` - `fatal error C1001`

W upstream w tym samym czasie build Windows przechodzil:
1. run `21965917874` - success (`2026-02-12`)
2. run `21949521857` - success (`2026-02-12`)
3. run `21949010364` - success (`2026-02-12`)

### 5.4 Hipoteza ".cpp/.h niespojnosci"

`src/CMakeLists.txt`:
1. upstream: `176 .cpp` + `3 .h` (w SOURCE_FILES)
2. testyy: `173 .cpp`, `0 .h`, `0 .c`

Wniosek:
- aktualnie w `testyy` nie ma przypadkowego kompilowania `.h/.c` jako TU.
- problem nie wyglada na "brakuje .h/.cpp" w listach SOURCE_FILES.

### 5.5 Stduuid - dodatkowe ryzyko include shadowing

Tylko w `testyy` istnieje lokalny shim:
- `src/stduuid/uuid.h` z trescia `#include <uuid.h>`

Jednoczesnie kod uzywa:
- `#include <stduuid/uuid.h>` (`framework/util/crypt.h`)

Ryzyko:
- lokalny `src/stduuid/uuid.h` moze zaslaniac header z vcpkg `stduuid`.
- to nie jest obecny root-cause `C1001`, ale jest ryzykiem przenoszalnosci (szczegolnie Windows).

### 5.6 I18n i "wszystkie litery swiata"

Tylko w `testyy`:
1. nowy text stack:
- `src/framework/text/TTFFont.cpp`
- `src/framework/text/TextShaper.cpp`
- `src/framework/text/LocaleShaping.cpp`
- `src/framework/text/Utf8.h`
2. nowy target `otc_textstack` + opcje:
- `OTC_ENABLE_TTF`
- `OTC_ENABLE_HARFBUZZ`
- `OTC_ENABLE_FRIBIDI`
3. duzy pakiet Noto fontow i zmiany `modules/client_locales/*`.

Wniosek:
- HarfBuzz/FriBidi sa integralna czescia obecnego i18n i nie powinny byc "wylaczane w ciemno".

## 6) Plan naprawczy (zadania i podpunkty)

### Zadanie A - Android (priorytet 1)

1. Usunac zagniezdzone generator expressions dla OpenSSL w Android:
- zmienic:
  - `$<$<BOOL:${OTC_ENABLE_OPENSSL}>:${OPENSSL_LIBRARIES}>`
- na targety importowane:
  - `$<$<BOOL:${OTC_ENABLE_OPENSSL}>:OpenSSL::SSL>`
  - `$<$<BOOL:${OTC_ENABLE_OPENSSL}>:OpenSSL::Crypto>`

2. Nie mieszac w jednym miejscu:
- raw variable (`OPENSSL_LIBRARIES`) + imported targets (`OpenSSL::...`).

3. Zachowac diagnostyke `build.ninja` po failu:
- dump linii `LINK_LIBRARIES`
- bez `rg` (uzyc `grep`).

4. Kryterium zaliczenia:
- brak `bad $-escape`
- brak surowego `$<...>` w finalnym `build.ninja`.

### Zadanie B - Windows (priorytet 2)

1. Ustabilizowac srodowisko kompilatora:
- przypiac runner do `windows-2022` (zamiast `windows-latest`).
- opcjonalnie przypiac toolset MSVC (jesli runner nadal da 14.44 i powtarza ICE).

2. Zmniejszyc dryf od upstream w plikach awarii:
- etapowo przywrocic upstreamowe wersje:
  - `src/framework/otml/otmlparser.cpp`
  - `src/framework/otml/otmlnode.cpp`
- potem dokladac tylko minimalne patche (jesli nadal potrzebne).

3. Ograniczyc "MSVC hacks" do absolutnego minimum:
- `cast.h`, `luainterface.h` tylko gdy konieczne i potwierdzone testem.

4. Kryterium zaliczenia:
- `Build - Windows` bez `C1001` dla `otmlparser.cpp` i `otmlnode.cpp`.

### Zadanie C - Hygiene (priorytet 3)

1. Usunac/zmienic lokalny shim:
- `src/stduuid/uuid.h`
- tak, aby nie zaslanial `stduuid` z vcpkg.

2. Utrzymac i18n runtime:
- nie ruszac `otc_textstack` (TTF/HarfBuzz/FriBidi) w ciemno.
- ewentualne zmiany robic przez warunki CMake i testy.

### Zadanie D - Walidacja i dokumentacja po kazdym runie

1. Po kazdej probie zapisac:
- run ID
- SHA
- data UTC
- pierwszy blad
- decyzja na kolejny krok

2. Plik kanoniczny:
- `Dokumentacja/2026-02-14_windows_build_diff_i_plan_naprawczy.md`

## 7) Minimalna sekwencja wykonania (rekomendowana)

1. Najpierw Android (A1-A4), bo root-cause jest twardy i powtarzalny.
2. Potem Windows:
- pin runner (`windows-2022`)
- upstream sync `otml*`
- test `Build - Windows`.
3. Na koniec cleanup `stduuid` shim i finalny retest obu workflow.
