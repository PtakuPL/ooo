# I18N Build Checklist (all platforms)

Cel: zapewnić, że kompilacje z pełną internacjonalizacją (UTF-8, 53 locale, TTF + HarfBuzz + FriBidi) przechodzą na Windows/Linux/Android/WASM oraz w analizie SonarCloud.

## Globalne wymagania
- [ ] Kodowanie: kompilator w UTF-8 (MSVC: `/utf-8`; GCC/Clang: domyślnie, opcjonalnie `-finput-charset=utf-8`/`-fexec-charset=utf-8`).
- [ ] Zależności: FreeType, HarfBuzz, FriBidi, zlib, png, icu (jeśli używane), BS_thread_pool w wersji zgodnej z API `thread_pool`.
- [ ] CMake opcje: `-DOTC_ENABLE_TTF=ON`, `-DOTC_ENABLE_HARFBUZZ=ON`, `-DOTC_ENABLE_FRIBIDI=ON` (dla Android/WASM można je wyłączać tylko świadomie, gdy biblioteki niedostępne).
- [ ] Fonty: dostęp do bazowego TTF (np. Noto Sans) oraz ewentualnych fallbacków CJK/Emoji, ścieżki w zasobach klienta poprawne.
- [ ] Locale: `data/locales/*.lua` zawiera 53 języki; `neededtranslations.lua` zgodne z aktualnym zestawem kluczy.
- [ ] CI cache: katalog `~/.cfamily` oraz `~/.sonar/cache` nie jest uszkodzony (cache miss nie blokuje builda).

## Operacyjny pipeline I18N (krok 4 ➜ krok 3)

1. **Ekstrakcja komunikatów**  
   ```bash
   cd /workspaces/ooo
   python Tibia/silnik/canary/tools/i18n_extract_messages.py --roots Tibia/silnik/canary/data-otservbr-global Tibia/silnik/canary/src --out build/i18n/messages.json
   ```  
   Plik `build/i18n/messages.json` jest jedynym źródłem prawdy dla nowych kluczy systemowych/NPC.

2. **Synchronizacja katalogów systemowych**  
   ```bash
   python Tibia/silnik/canary/tools/i18n_sync_messages.py --locale pl --filename system.json
   ```  
   Aktualizuje `i18n/en/system.json` (baza) oraz `i18n/pl/system.json` (prefill EN → PL). Dzięki temu tłumacze widzą pełną listę ~2.5k komunikatów zanim zaczniemy krok 3.

3. **Nazwy przedmiotów**  
   ```bash
   python Tibia/silnik/canary/tools/export_items_translations.py --locale en --locale pl
   ```  
   Utrzymuje `i18n/*/items.json` zgodne z `data/items/items.xml`.

4. **Raporty/CSV**  
   ```bash
   python Tibia/silnik/canary/tools/i18n_report.py --locales pl --csv-dir Tibia/silnik/canary/i18n/reports
   ```  
   Wygenerowany CSV (`key,en,pl,status`) trafia do tłumaczy; procent pokrycia raportowany jest w logu. Plik służy jako wejście do kroku 3 (hurtowe tłumaczenia PL).

## Windows (MSVC)
- [ ] Toolchain: VS 2022, vcpkg z baseline, który zawiera `abseil@20250814.1`, `angle@chromium_7258#2`, `asio@1.32.0` (lub dopasowane wersje portów).
- [ ] Flagi: `/utf-8`, `/permissive-`, `/std:c++20`, `/Zc:__cplusplus`, `/EHsc`.
- [ ] Asyncdispatcher: pliki `asyncdispatcher.h/.cpp` z kompletnymi include'ami standardowymi (`<thread>`, `<algorithm>`, `<cstdint>`) i spójną deklaracją/definicją `BS::thread_pool`.
- [ ] CMake: `-DVCPKG_TARGET_TRIPLET=x64-windows-static` lub odpowiedni, `-DSPEED_UP_BUILD_UNITY=OFF` jeśli unity koliduje z HarfBuzz/FriBidi.
- [ ] Build: `cmake --build build --config Release --parallel` przechodzi; brak błędów linkera dotyczących HarfBuzz/FriBidi/FreeType.

## Linux (Ubuntu)
- [ ] Kompilator: GCC 14 lub Clang 18+, zgodny z C++20.
- [ ] Pakiety systemowe: dev dla X11/OpenGL/FreeType/HarfBuzz/FriBidi; lub pełny manifest vcpkg.
- [ ] Build: `cmake -G Ninja -S . -B build ...` + `cmake --build build` przechodzi; brak ostrzeżeń związanych z UTF-8.

## Android
- [ ] NDK r23c, CMake Ninja.
- [ ] CMake generuje `build-android/compile_commands.json` z opcjami kompatybilnymi (bez unity, jeśli koliduje z analizą).
- [ ] Opcje i18n: można wyłączyć `OTC_ENABLE_TTF/HARFBUZZ/FRIBIDI` tylko gdy biblioteki są niedostępne na urządzeniu; w analizie SonarCloud wystarczy poprawne `compile_commands.json`.
- [ ] Build/analiza: kroki SonarCloud pomijane, jeśli w projekcie SC włączone Automatic Analysis (`SONARCLOUD_AUTOMATIC_ANALYSIS=true`).

## Browser (Emscripten/WASM)
- [ ] EMSDK w środowisku; `FindLua` używa standardowego modułu (projektowa `cmake/` usunięta z `CMAKE_MODULE_PATH` na czas `find_package`).
- [ ] CMake: `-DVCPKG_TARGET_TRIPLET=wasm32-emscripten`, `-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake`.
- [ ] Opcje: HarfBuzz/FriBidi/FreeType muszą być wspierane w toolchainie; w razie braku można czasowo wyłączyć, ale odnotować w wynikach.

## SonarCloud (C/C++ Analysis)
- [ ] Automatic Analysis: jeśli włączone w projekcie SC, ustawić repo variable `SONARCLOUD_AUTOMATIC_ANALYSIS=true` aby workflow pominął skaner CI.
- [ ] Tokeny: `secrets.SONARCLOUDTOKEN` ustawione w repo; `GITHUB_TOKEN` dostępny domyślnie.
- [ ] Dane wejściowe: `-Dsonar.cfamily.compile-commands=build-android/compile_commands.json` (Android) lub analogiczne dla innych platform, zgodne ze zbudowanym drzewem.

## Walidacja i testy
- [ ] Krótki smoke test renderowania tekstu (ASCII + RTL + CJK) na każdej platformie (headless lub minimalny run), brak crashy.
- [ ] Sprawdzenie, że `TTFFont`/`TextShaper` działają z wybranym fontem (logi bez brakujących glifów dla podstawowych tekstów UI).
- [ ] Przejście workflow: `build-windows`, `build-ubuntu`, `build-browser`, `build-android`, `analysis-sonarcloud-*` zakończone sukcesem.

## Notatki operacyjne
- Aktualizacje baseline vcpkg muszą być zsynchronizowane między wszystkimi workflow (Windows/Ubuntu/Android/WASM), aby uniknąć rozjechania wersji portów.
- W razie awarii kompilacji HarfBuzz/FriBidi na platformach mobilnych/wasm, dokumentuj tymczasowe wyłączenie flag i zaplanuj przywrócenie.
- Pamiętaj o czyszczeniu cache CMake/Ninja przy zmianie toolchaina lub baseline (np. `rm -rf build*`).
