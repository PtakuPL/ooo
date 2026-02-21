# HANDOFF do nowego czatu (2026-02-21)

## 1) Aktualny stan projektu CI

- Linux build: **znowu fail** (nowa regresja po commicie `b3225cdd`).
- Windows build: **nadal fail** na globalnym `MSVC ICE C1001` (punkt awarii przesuniety).

Najnowsze potwierdzenie:
- Linux run: `22263021182` (SHA `b3225cddb1fbe3aaaae058d56ef3476d42895bd1`)
  - Link: <https://github.com/PtakuPL/ooo/actions/runs/22263021182>
  - Pierwszy blad:
    - `luainterface.h:497: error: no matching function for call to luavalue_cast(... std::string_view&)`
- Windows run: `22263022244` (ten sam SHA)
  - Link: <https://github.com/PtakuPL/ooo/actions/runs/22263022244/job/64404176077>
  - Pierwszy blad:
    - `luainterface.cpp(41) : fatal error C1001`
    - `FAILED ... framework/luaengine/luainterface.cpp.obj`
    - potem `Access violation`, `ninja: build stopped`.

## 2) Co juz ustalone (bez domyslow)

1. Windows: to nadal **ta sama klasa problemu** (`MSVC ICE C1001`), ale trigger przesunal sie do `luainterface.cpp`.
2. Linux: doszla nowa, merytoryczna regresja `castValue<T>()` dla `T=std::string_view`.
3. Incydenty `vcpkg` (HTTP 502 / pathspec) sa osobne i nie sa root-cause runow `22263021182` / `22263022244`.
4. Numer pliku kompilacji (`[10/183]`, `[40/183]`) nie jest miara postepu merytorycznego przez rownoleglosc `ninja`.

## 3) Co jest przygotowane lokalnie pod naprawe C1001

Zmiany lokalne (juz na commicie `b3225cdd`, wymagaja korekty):
- `canary_test/testyy/src/framework/luaengine/luabinder.h`
  - wyniesienie throw path poza template-heavy lambdy
  - uproszczenie binderow przez funktory zamiast czesci lambd
- `canary_test/testyy/src/framework/luaengine/luainterface.h`
  - uproszczone `castValue<T>()`
  - helper `throwLuaBadValueCast(...)`
- `canary_test/testyy/src/framework/luaengine/luainterface.cpp`
  - implementacje helperow (`noinline` na MSVC)

Wazne:
- Te zmiany sa juz przetestowane na CI i **nie wystarczyly**:
  - Linux fail: regresja `luavalue_cast(... string_view&)`
  - Windows fail: C1001 na `luainterface.cpp(41)`.

## 4) Co robimy dalej (kolejnosc)

1. Zmiany P0 sa juz wdrozone lokalnie:
   - fix `castValue<T>()` dla `std::string_view`,
   - `luainterface.cpp` dodany do per-file anti-ICE flags,
   - `/MP` uzaleznione od `CMake_MSVC_PARALLEL`.
2. Odpalic nowy `Build - Linux (OTC Client)` i `Build - Windows`.
3. Po zakonczeniu:
   - zawsze raportowac **pierwszy** realny blad (`fatal error`, `FAILED`, `##[error]`),
   - dopisac wynik do dokumentacji run-by-run.

## 5) Gotowa wiadomosc startowa do nowego czatu

Skopiuj i wklej:

```text
Kontynuujemy debug Windows CI.
Aktualne blockery:
1) Linux regresja po commicie b3225cdd:
   - run: https://github.com/PtakuPL/ooo/actions/runs/22263021182
   - pierwszy blad: luainterface.h:497 (luavalue_cast dla std::string_view)
2) Windows nadal MSVC ICE C1001:
   - run: https://github.com/PtakuPL/ooo/actions/runs/22263022244/job/64404176077
   - pierwszy blad: luainterface.cpp(41) C1001

Proszę:
1) odpal nowe Linux + Windows buildy na commicie z juz wdrozonymi fixami P0,
2) po wyniku podaj pierwszy realny blad z logu,
3) zaktualizuj dokumentacje run-by-run.

Dokumenty referencyjne:
- Dokumentacja/01_Instalka_Klient/2026-02/2026-02-21_lista_bledow_od_2026-02-20_linux_windows.md
- Dokumentacja/01_Instalka_Klient/2026-02/2026-02-21_ci_linux_windows_analiza_poprawek_v3.md
- Dokumentacja/01_Instalka_Klient/2026-02/2026-02-21_HANDOFF_NOWY_CZAT_WINDOWS_LINUX.md
```
