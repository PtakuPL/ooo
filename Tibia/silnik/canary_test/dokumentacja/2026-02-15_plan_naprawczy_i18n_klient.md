# PLAN NAPRAWCZY — System i18n OTClient Redemption
**Data:** 2026-02-15  
**Status:** DO ZATWIERDZENIA  
**Uwaga:** Build Windows przeszedł pomyślnie! ✅

---

## PODSUMOWANIE PROBLEMU

Klient OTClient Redemption wyświetla **surowe klucze tłumaczeń** (np. `otclient_modules.entergame.tr_17`) zamiast przetłumaczonego tekstu. Wybór języka (language picker) nie otwiera się poprawnie. Mimo kilku wcześniejszych napraw (limit stałych LuaJIT, vararg, broken strings w de.lua) problem utrzymuje się.

### Co już naprawiono (2026-02-15):
- ✅ Odbudowa `game_i18n_*.lua` — z ~53k linii do ~5.8k (poniżej limitu 65k stałych LuaJIT)
- ✅ Zamiana `game_i18n_*_compact.lua` na puste stuby
- ✅ Poprawka vararg w `applyFormat()` — `local args = {...}` zamiast `select(idx, ...)`
- ✅ Poprawka 12 złamanych stringów wieloliniowych w `de.lua`
- ✅ Scalenie JSON-ów klienckich `<lang>_client_all.json` (53 języki × 2320 kluczy)
- ✅ Build Windows — kompilacja przeszła pomyślnie!

---

## DIAGNOZA — WYNIKI ANALIZY KODU

### Potwierdzony przepływ ładowania:
```
init() → installedLocales = {} → __gameI18nLoaded = {}
  → installLocales('/locales')
    → dofile('/locales/de.lua')  → installLocale(locale)  → loadGameI18nForLocale(locale)
    → dofile('/locales/en.lua')  → installLocale(locale)  → loadGameI18nForLocale(locale)
    → dofile('/locales/ja.lua')  → installLocale(locale)  → loadGameI18nForLocale(locale)
    → ... (es, fr, pl, pt, ru)
  → setLocale('ja')  ← z config.otml (locale: ja)
    → currentLocale = installedLocales['ja']
```

### Co zweryfikowano (pliki na dysku C:):
| Element | Status | Uwagi |
|---------|--------|-------|
| `locales.lua` — vararg fix | ✅ OK | `local args = {...}` na C: |
| `game_i18n_en.lua` — zawiera klucze | ✅ OK | 5828 tłumaczeń, klucz `otclient_modules.entergame.tr_17` istnieje |
| `game_i18n_ja.lua` — zawiera klucze | ✅ OK | 5823 tłumaczeń, klucz `otclient_modules.entergame.tr_17` istnieje |
| Struktura plików `game_i18n_*.lua` | ✅ OK | Nawiasy zbilansowane, brak BOM, brak CRLF, UTF-8 |
| `de.lua` — broken strings | ✅ OK | Naprawiono |
| `neededtranslations.lua` | ✅ OK | 890 linii, istnieje w katalogu modułu |
| `locales.otmod` | ✅ OK | sandboxed: true, scripts: [locales] |
| Pliki flag — `/images/flags/` | ⚠️ 9 flag | de, en, es, fr, ja, pl, pt, ru, sv |
| Bazowe locale (de,en,es,fr,ja,pl,pt,ru) | ✅ OK | 8 plików |
| Czcionka `noto-12` | ✅ OK | NotoSans + JP fallback istnieje |
| Config `locale: ja` | ℹ️ | Japoński ustawiony w config.otml |
| Ikona `/images/topbuttons/language.png` | ❌ BRAK | Topmenu odwołuje się do nieistniejącej ikony |
| `locales1.lua` | ⚠️ | Backup plik w katalogu modułu — do usunięcia |
| `disabled/` folder | ℹ️ | 55 dodatkowych lokali bez plików bazowych |

### Najbardziej prawdopodobna przyczyna problemu:
Analiza kodu C++ OTClient (`luainterface.cpp`) wykazała, że `dofile()` z poziomu sandboxed modułu ładuje plik w **globalnym środowisku Lua**, a nie w sandboxie modułu. Zmienna `_G.locale` ustawiana w sandboxie `loadGameI18nForLocale()` powinna propagować do globalnej tablicy przez `_G.__index`. Jednak **bez uruchomienia klienta i sprawdzenia logów konsoli nie da się potwierdzić, czy:**
1. `pcall(dofile, '/locales/game_i18n_en')` kończy się sukcesem czy błędem
2. Ile tłumaczeń faktycznie jest scalanych
3. Czy `currentLocale.translation` zawiera klucze `otclient_modules.*` po pełnej inicjalizacji

---

## PLAN NAPRAWCZY — 7 ZADAŃ

### ZADANIE 1: Diagnostyka — Dodać rozszerzony debug logging
**Priorytet:** KRYTYCZNY  
**Opis:** Dodać szczegółowe logowanie do `locales.lua`, aby widzieć dokładnie co się dzieje podczas ładowania.

**Podzadania:**
1. **1.1** — Dodać `pwarning()` na początku `init()` z komunikatem `[i18n-diag] init() called`
2. **1.2** — W `installLocales()`, logować każdy ładowany plik: `[i18n-diag] Loading locale file: <filename>`
3. **1.3** — W `installLocale()`, logować: `[i18n-diag] installLocale('xx') — translation count = <N>`
4. **1.4** — W `loadGameI18nForLocale()`, logować PRZED i PO pcall:
   - `[i18n-diag] loadGameI18n for 'xx': _G.locale.name = <name>, .translation exists = <bool>`
   - `[i18n-diag] pcall result: ok=<bool>, err=<msg>, translations before=<N> after=<M>`
5. **1.5** — W `setLocale()`, logować: `[i18n-diag] setLocale('xx') — total translations = <N>, sample key='otclient_modules.entergame.tr_17' = <value or nil>`
6. **1.6** — W `tr()`, gdy tłumaczenie NIE znalezione, logować PIERWSZY raz: `[i18n-diag] tr() miss: key='<key>', currentLocale='<name>', translation_count=<N>`

**Oczekiwany efekt:** Pełna widoczność w konsoli klienta — dokładnie widać gdzie przepływ się psuje.

---

### ZADANIE 2: Naprawić brakującą ikonę language button
**Priorytet:** WYSOKI  
**Opis:** Plik `/images/topbuttons/language.png` nie istnieje, ale `topmenu_language_button.otui` go referencja.

**Podzadania:**
1. **2.1** — Stworzyć ikonę `language.png` (26×26 px, styl matching inne ikony w topbuttons) — można użyć prostej ikony globu/tłumaczenia
2. **2.2** — Skopiować do `data/images/topbuttons/language.png` na C: i WSL
3. **2.3** — Zweryfikować: `topmenu_language_button.otui` odwołuje się do `icon-source: /images/topbuttons/language`

**Oczekiwany efekt:** Przycisk języka wyświetla się poprawnie w topmenu.

---

### ZADANIE 3: Rozwiązać redundancję dofile w plikach lokali bazowych
**Priorytet:** ŚREDNI (potencjalnie KRYTYCZNY)  
**Opis:** `en.lua` zawiera jawne `dofile('game_i18n_en')` i `dofile('game_i18n_en_compact')` PO wywołaniu `installLocale()`. Ale `installLocale` już wywołuje `loadGameI18nForLocale()` który ładuje te same pliki. To powoduje:
- Podwójne ładowanie (niepotrzebne)
- Potencjalny błąd jeśli `dofile` z relatywną ścieżką nie rozpatrzy prawidłowo

**Podzadania:**
1. **3.1** — **Usunąć** jawne `dofile('game_i18n_xx')` i `dofile('game_i18n_xx_compact')` z **en.lua** — `loadGameI18nForLocale` już to robi automatycznie
2. **3.2** — Sprawdzić **wszystkie** bazowe pliki lokali (de, es, fr, ja, pl, pt, ru) — usunąć redundantne `dofile` wywołania
3. **3.3** — Upewnić się, że `pl.lua` z dodatkową tablicą `add` nadal działa po usunięciu dofile (tablica `add` jest mergowana osobno, niezależnie od dofile)

**Oczekiwany efekt:** Jedno źródło ładowania game_i18n — przez `loadGameI18nForLocale()`.

---

### ZADANIE 4: Oczyścić katalog modułu z artefaktów
**Priorytet:** NISKI  
**Opis:** W katalogu `modules/client_locales/` znajdują się pliki artefaktów.

**Podzadania:**
1. **4.1** — Usunąć `locales1.lua` (kopia zapasowa, nie ładowana przez moduł)
2. **4.2** — Przenieść `locales_bridge_openLanguagePicker.lua` do folderu `disabled/` lub usunąć — funkcjonalność jest już zaimplementowana w `init()` przez export do `modules.client_locales`
3. **4.3** — Usunąć pliki `*.corrupted_backup`, `*.bak`, `*_upstream.lua` z `data/locales/`

**Oczekiwany efekt:** Czysty katalog modułu bez artefaktów.

---

### ZADANIE 5: Uzupełnić brakujące flagi i locale
**Priorytet:** NISKI  
**Opis:** Jest 9 flag ale 8 bazowych lokali. Szwedzka flaga (sv.png) istnieje ale brak `sv.lua`.

**Podzadania:**
1. **5.1** — Stworzyć minimalny `sv.lua` (kopia en.lua ze zmianą `name = "sv"`, `languageName = "Svenska"`) LUB usunąć `sv.png` jeśli szwedzki nie jest planowany
2. **5.2** — Rozważyć dodanie flag dla kluczowych języków (de, es, fr, ja, pl, pt, ru mają — brak flag dla 55 lokali w `disabled/`)

**Oczekiwany efekt:** Spójność między flagami a plikami lokali.

---

### ZADANIE 6: Pełny test diagnostyczny po naprawach
**Priorytet:** KRYTYCZNY (po wykonaniu zadań 1-3)  
**Opis:** Uruchomić klient na Windows, sprawdzić konsolę i zrzuty ekranu.

**Podzadania:**
1. **6.1** — Uruchomić klient z domyślnym locale (en) — zresetować `locale: false` w config.otml
2. **6.2** — Sprawdzić konsolę klienta (Ctrl+Shift+J lub terminal OTClient):
   - Szukać logów `[i18n-diag]` z Zadania 1
   - Szukać logów `[i18n] Failed to load` lub `0 translations merged`
   - Szukać logów WARNING/ERROR
3. **6.3** — Skopiować CAŁY log konsoli i wkleić tutaj
4. **6.4** — Sprawdzić czy tekst "Enter Game" / "Journey Onwards" wyświetla się po angielsku
5. **6.5** — Wcisnąć Ctrl+L — sprawdzić czy otwiera się picker języka
6. **6.6** — Zmienić język na polski — sprawdzić czy teksty się zmieniają
7. **6.7** — Sprawdzić topmenu — czy przycisk języka jest widoczny

**Oczekiwany efekt:** Albo system działa, albo mamy dokładne logi wskazujące na problem.

---

### ZADANIE 7: Dokumentacja wyników
**Priorytet:** ŚREDNI  
**Opis:** Udokumentować wyniki naprawy w folderze dokumentacji.

**Podzadania:**
1. **7.1** — Dopisać do dokumentacji, że **build Windows przeszedł pomyślnie** (data: 2026-02-15)
2. **7.2** — Zapisać wyniki diagnostyki (logi konsoli)
3. **7.3** — Zaktualizować status i18n — ile kluczy ładuje się, które języki działają
4. **7.4** — Udokumentować architekturę ładowania locales (przepływ: init → installLocales → installLocale → loadGameI18nForLocale → dofile game_i18n)

---

## KOLEJNOŚĆ WYKONANIA

```
FAZA 1 — Diagnostyka (Zadania 1 + 6.1–6.3)
  ↓ Analiza logów konsoli  
FAZA 2 — Naprawy celowane (Zadania 2 + 3, plus ewentualne poprawki wynikające z logów)
  ↓ Test ponowny (Zadanie 6.4–6.7)
FAZA 3 — Porządki (Zadanie 4 + 5)
  ↓ Test końcowy
FAZA 4 — Dokumentacja (Zadanie 7)
```

---

## RYZYKO I UWAGI

1. **Sandbox vs Global env** — Jeśli logi pokażą `pcall failed`, przyczyna może być w tym, że sandboxed moduł nie propaguje `_G.locale` do globalnego env. Rozwiązanie: zamienić `_G.locale = locale` na `rawset(_G, 'locale', locale)` albo użyć jawnego `getfenv(0)`.
2. **Stałe LuaJIT** — Obecne pliki game_i18n (~5.8k entries, ~11.6k stałych) są bezpieczne, ale dodawanie nowych tłumaczeń może zbliżyć do limitu.
3. **Kodowanie** — Wszystkie pliki są UTF-8 bez BOM, Unix line endings (LF). Nie zmieniać na CRLF!
4. **Ścieżki dofile** — OTClient rozwiązuje relatywne ścieżki przez `getCurrentSourcePath()` (katalog aktualnie wykonywanego pliku Lua). Absolutne ścieżki `/locales/...` przeszukują wszystkie search paths.

---

*Dokument wymaga zatwierdzenia przed rozpoczęciem prac.*
