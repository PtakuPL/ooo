# Audyt 2026-02-21: i18n layout, buttony/obramówki i kompilacje Linux/Windows

**Data audytu:** 2026-02-21  
**Zakres:** `Tibia/silnik/canary_test/testyy` + workflow CI w root repo (`/home/ptaku/serweryt/.github/workflows`)  
**Powód:** regresje i niejednoznaczny stan po serii zmian "AUTO_TRANSLATE" oraz prób naprawy Windows build.

---

## 1. Najważniejsze wnioski (TL;DR)

1. **Automatyczne dopasowanie UI do języka działa tylko częściowo.**  
   Mamy działające mechanizmy C++ (`auto-fit-parent`, `text-*-auto-resize`), ale "per-language overrides" z `i18n_layout.lua` są w praktyce nieaktywne.
2. **Globalne auto-resize wszystkich `Button`/`QtButton` zostało wycofane.**  
   Obecnie auto-resize działa tylko tam, gdzie ręcznie użyto `I18NButton` / `I18NQtButton`.
3. **Linux build nie "umarł" technicznie, tylko często się nie uruchamia automatycznie.**  
   Workflow Linux ma wąskie `paths:` (głównie `src/**`, CMake, vcpkg), więc zmiany w OTUI/Lua/i18n zwykle nie triggerują CI.
4. **Dokumentacja i workflow Windows są niespójne.**  
   W `build-windows.yml` jest aktualny wybór najnowszego MSVC, ale pozostał stary komentarz, że krok "pomija 14.44".
5. **Obramówki nie są głównym problemem i18n.**  
   `image-border` (9-slice) skaluje się z widgetem; problemem jest głównie szerokość/wysokość widgetów i brak pełnego mechanizmu per-język.

---

## 2. Co realnie zmieniono (oś czasu)

| Data | Commit | Zmiana | Status dziś |
|---|---|---|---|
| 2026-02-17 | `51fee2116` | Dodanie flag `auto-fit-parent` w `uiwidget.h` | ✅ aktywne |
| 2026-02-17 | `b61f24fc4` | Implementacja `autoFitParent()` + parser OTUI + zmiany `options.otui` | ✅ aktywne (potem poprawiane) |
| 2026-02-17 | `bb2e2eab9` | Globalna zmiana `Button`/`QtButton` na auto-resize | ❌ wycofane |
| 2026-02-17 | `618ab3512` | Korekta anchora `OptionsCategory.Button` | ✅ aktywne |
| 2026-02-19 | `dbd75db75` | Rewrite `autoFitParent()`, guard rekurencji, `FlagProp` -> `uint64_t` | ✅ aktywne |
| 2026-02-19 | `ee759abbc` | `OptionCheckBox`: `text-vertical-auto-resize` + `auto-fit-parent-height`; max size okna | ✅ aktywne |
| 2026-02-19 | `2f1188fb9` | Revert globalnego auto-resize `Button/QtButton`, dodanie `I18NButton/I18NQtButton`, podmiana wybranych przycisków | ✅ aktywne |
| 2026-02-21 | `94976c8be` | Dodanie modułu `i18n_layout.lua` | ✅ plik istnieje |
| 2026-02-21 | `fff02f81c`, `9e56d42d6` | Poprawki `i18n_layout.lua` + init/terminate w `locales.lua` | ✅ plik ładowany, ale bez pełnego efektu |

Uwaga: nie ma twardego znacznika "to zrobił Copilot/Claude" w metadanych commitów. Atrybucja opiera się na historii commitów i zawartości zmian.

---

## 3. Stan faktyczny mechanizmu i18n UI

### 3.1 Co działa

1. **C++ auto-fit parent działa i jest spięty z OTUI.**  
   Pliki:  
   - `canary_test/testyy/src/framework/ui/uiwidget.cpp`  
   - `canary_test/testyy/src/framework/ui/uiwidget.h`  
   - `canary_test/testyy/src/framework/ui/uiwidgetbasestyle.cpp`
2. **W `options.otui` dodano realne zabezpieczenia layoutu:**  
   `min-width`, `max-width`, `text-wrap`, `text-vertical-auto-resize`, `auto-fit-parent-*`.
3. **Powstały style dedykowane i18n:**  
   `I18NButton`, `I18NQtButton` w `canary_test/testyy/data/styles/10-buttons.otui`.

### 3.2 Co nie działa / jest niedokończone

1. **`i18nLayout.applyOverrides(...)` nie jest nigdzie wywoływane.**  
   Wyszukanie w repo zwraca tylko definicję:
   - `canary_test/testyy/modules/client_locales/i18n_layout.lua:113`
2. **Pliki `data/i18n_layout/*.lua` są tylko szablonami (komentarze, brak realnych override).**
3. **Auto-resize nie jest globalne.**  
   `Button` i `QtButton` wróciły do stałego `size: 106 23`:
   - `canary_test/testyy/data/styles/10-buttons.otui:1-5`
   - `canary_test/testyy/data/styles/10-buttons.otui:170-173`
4. **`I18NQtButton` użyto tylko punktowo (na dziś głównie Options/Help).**  
   To nie rozwiązuje całego UI.

### 3.3 Wniosek techniczny

Obecny stan to **hybryda**: część auto, część ręcznie, część planowana ale niepodłączona.  
To tłumaczy, dlaczego w niektórych miejscach język "się mieści", a w innych dalej ucina tekst.

---

## 4. Linux build: dlaczego wygląda jak "przestał działać"

### 4.1 Stan workflow Linux

Workflow Linux jest aktywny w root repo:
- `/home/ptaku/serweryt/.github/workflows/build-linux.yml`

Ma on trigger na `push`/`pull_request`, ale z ograniczeniem `paths:`:
- tylko `src/**`, CMake, `vcpkg.json`, sam plik workflow.

Przykładowo (linie 8-21):  
`Tibia/silnik/canary_test/testyy/src/**`, `CMakeLists.txt`, `CMakePresets.json`, `vcpkg.json`.

### 4.2 Skutek

Zmiany w:
- `modules/**/*.lua`
- `modules/**/*.otui`
- `data/styles/*.otui`
- `i18n/*.json`

**nie uruchamiają automatycznie build-linux**.

To daje efekt operacyjny: "Linux build stanął", mimo że workflow jest sprawny.

### 4.3 Dodatkowa pułapka

Windows workflow jest tylko `workflow_dispatch` (manual), więc równoległe monitorowanie Linux/Windows łatwo się rozjeżdża procesowo.

---

## 5. Windows build: fakty i niespójności

1. **Fakt:** `build-windows.yml` wybiera obecnie najnowszy MSVC toolset (`Select-Object -First 1`).  
2. **Błąd w komentarzu:** w tym samym pliku jest tekst, że krok "already skips 14.44", co jest nieprawdą po zmianie `51c003a0a`.  
3. **Dokumentacja jest częściowo historyczna i miesza stany "planowane/w toku/zrobione".**  
   Szczególnie dotyczy to dużego pliku:
   - `Dokumentacja/01_Instalka_Klient/2026-02/2026-02-17_i18n_ui_layout_auto_resize.md`

---

## 6. Błędne założenia, które generowały regresje

| Błędne założenie | Co jest prawdą | Efekt uboczny |
|---|---|---|
| "Globalne auto-resize przycisków już działa wszędzie" | Zostało wycofane, działa tylko `I18N*` w wybranych miejscach | Niejednolity UI między modułami |
| "Per-language overrides są automatycznie nakładane" | Moduł się ładuje, ale `applyOverrides` nie jest wywoływane | Brak realnego ręcznego sterowania layoutem per język |
| "Linux CI nie działa" | Działa, ale ma wąskie `paths:` | Brak buildów po zmianach Lua/OTUI/i18n |
| "Problem to obramówki per język" | Obramówka 9-slice skaluje się; problemem są limity rozmiaru i brak spójnej polityki layoutu | Próby naprawy nie trafiają w przyczynę |
| "Komentarze workflow odzwierciedlają kod" | Jeden komentarz jest nieaktualny | Błędne decyzje podczas debugowania CI |

---

## 7. Rekomendowane podejście (auto + ręczne per język)

### 7.1 Kierunek docelowy

**Podejście hybrydowe**:
1. **Auto-resize jako domyślne minimum** dla krytycznych kontrolek i kontenerów (`auto-fit-parent-*`, `text-wrap`, min/max).  
2. **Ręczne override per język** tylko dla ekranu/widgetu, gdzie auto nie daje stabilnego efektu.

To jest zgodne z Twoją sugestią ("ręcznie ustawiać wymiary zależnie od języka"), ale bez utraty skalowalności.

### 7.2 Konkretny mechanizm ręczny

Użyć istniejącego systemu:
- `canary_test/testyy/modules/client_locales/i18n_layout.lua`
- `canary_test/testyy/data/i18n_layout/<lang>.lua`

Ale trzeba:
1. Podpiąć wywołania `i18nLayout.applyOverrides(...)` przy tworzeniu okien/paneli.
2. Uzupełnić pliki `de/fr/ru/es` realnymi wartościami.

---

## 8. Zadania naprawcze (priorytety)

## P0 (blokery procesu)

1. **Podpiąć `applyOverrides` do realnego lifecycle UI.**  
   Cel: po `loadUI(...)` dla znanych paneli wywołać `i18nLayout.applyOverrides(root, modulePath, lang)`.
2. **Naprawić niespójny komentarz w Windows workflow (`build-windows.yml`).**  
   Usunąć tekst o "skipping 14.44", bo obecny kod tego nie robi.
3. **Dodać aktualizację docs statusu do Definition of Done zmian CI/UI.**  
   Każda zmiana workflow lub mechanizmu layout = obowiązkowa sekcja "stan faktyczny".

## P1 (stabilizacja jakości)

1. **Rozszerzyć `paths:` w `build-linux.yml` o zmiany UI/i18n klienta** (minimum: `modules/**`, `data/styles/**`, `data/i18n_layout/**`).  
2. **Wypełnić manualne override dla 4 języków o najdłuższych stringach** (np. de/fr/ru/pl) dla ekranów: Options, EnterGame, ServerList.  
3. **Uruchamiać `checkLayoutOverflow()` jako gate manualny po zmianach i18n UI** (doc + checklist release).

## P2 (utrzymanie)

1. **Stopniowo mapować przyciski z tłumaczeniami na `I18NButton/I18NQtButton`** tam, gdzie istnieją stałe szerokości i clipping.  
2. **Dodać tabelę "kto i kiedy zmienił strategię layoutu"** w jednej krótkiej dokumentacji statusowej, żeby unikać konfliktu notatek.

---

## 9. Kryteria ukończenia (Definition of Done)

1. Zmiana języka EN -> DE -> RU nie ucina tekstu w co najmniej: Options, Help, EnterGame.
2. Linux CI uruchamia się automatycznie po zmianie OTUI/Lua i przechodzi build.
3. Windows workflow + dokumentacja nie mają sprzecznych komentarzy/założeń.
4. W repo istnieje co najmniej 1 realny plik override (`data/i18n_layout/<lang>.lua`) z użytymi ustawieniami.

---

## 10. Co zostało zweryfikowane podczas audytu

1. Historia commitów i diffy plików: UI/i18n/workflow.
2. Aktualna zawartość:
   - `canary_test/testyy/data/styles/10-buttons.otui`
   - `canary_test/testyy/modules/client_locales/i18n_layout.lua`
   - `canary_test/testyy/modules/client_options/options.otui`
   - `/home/ptaku/serweryt/.github/workflows/build-linux.yml`
   - `/home/ptaku/serweryt/.github/workflows/build-windows.yml`
3. Dopasowanie dokumentacji do stanu kodu na dzień 2026-02-21.
