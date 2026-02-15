# Redesign language picker + flagi + aktywacja języków

**Data:** 2026-02-15  
**Branch:** `serwer-7.4`  
**Commit:** `d57de1966` (w ramach guardian push)  
**Build CI:** `#22039818575` — in_progress (workflow_dispatch na serwer-7.4)

---

## Co zostało zrobione

### 1. Przeprojektowanie pickera języka (locales.otui)

**Stary układ:**
- Siatka (grid) z komórkami 96x128px
- Duże ikony flag 96x96, tekst pod flagą
- Maks 3 kolumny, automatyczna szerokość panelu
- Ciemne tło #000000, opacity 0.90

**Nowy układ:**
- Pionowa lista (verticalBox), spacing 4px
- Mała flaga 32x24px po lewej + nazwa języka po prawej (text-offset 48px)
- Stała szerokość panelu 220px, wyśrodkowany
- Ciemniejsze tło #111111, opacity 0.95
- Efekty hover (rozjaśnienie + obramówka #ffffff33) i pressed (#ffffff44)
- Języki posortowane alfabetycznie po `languageName`

**Zmienione pliki:**
- `modules/client_locales/locales.otui` — nowy styl `LocalesButton` + nowy layout panelu
- `modules/client_locales/locales.lua` — usunięta logika grid (getCellSize/getCellSpacing/setWidth), dodane sortowanie `table.sort`
- `modules/client_locales/locales1.lua` — taka sama zmiana jak w locales.lua (backup/alternatywna wersja)

### 2. Nowe flagi (256x256 PNG, RGBA)

Wygenerowane programowo (Python3, struct+zlib — czysty PNG bez zewnętrznych bibliotek):

| Plik | Kraj | Opis | Rozmiar |
|------|------|------|---------|
| `ja.png` | Japonia | Białe tło + czerwone koło (Hinomaru) | 1016 B |
| `ru.png` | Rosja | 3 pasy poziome: biały, niebieski, czerwony | 741 B |
| `fr.png` | Francja | 3 pasy pionowe: niebieski, biały, czerwony | 1261 B |

Lokalizacja: `data/images/flags/`

Istniejące flagi (nie zmienione): `en.png`, `pl.png`, `de.png`, `es.png`, `pt.png`, `sv.png`

### 3. Aktywowane języki

Przeniesione z `data/locales/disabled/` do `data/locales/`:

| Kod | Język | Charset |
|-----|-------|---------|
| de | Deutsch | cp1252 |
| es | Español | cp1252 |
| fr | Français | cp1252 |
| pt | Português | cp1252 |
| ru | Русский | cp1251 |

**Łącznie 8 aktywnych języków:** en, de, es, fr, ja, pl, pt, ru

Wcześniej aktywne (bez zmian): en, ja, pl

### 4. Transliteracja — moduł client_transliteration

(Szczegóły w osobnym dokumencie: `2026-02-15_transliteration_feature.md`)

Nowy moduł Lua — opcjonalna zamiana liter nie-łacińskich na łacińskie w czacie:
- 4 checkboxy w ustawieniach: Cyrillic, Greek, Arabic, Katakana
- Hook w `console.lua` → `onTalk()` przed renderowaniem tekstu
- Domyślnie wyłączone (opt-in)

**Pliki:**
- `modules/client_transliteration/transliteration.otmod` (nowy)
- `modules/client_transliteration/transliteration.lua` (nowy)
- `modules/client_options/data_options.lua` (4 nowe opcje)
- `modules/client_options/styles/interface/console.otui` (4 nowe checkboxy)
- `modules/game_console/console.lua` (2 hooki w onTalk)

---

## Struktura zmienionych plików (podsumowanie sesji)

```
testyy/
├── data/
│   ├── images/flags/
│   │   ├── ja.png          ← NOWY (flaga Japonii)
│   │   ├── ru.png          ← NOWY (flaga Rosji)
│   │   └── fr.png          ← NOWY (flaga Francji)
│   └── locales/
│       ├── de.lua          ← AKTYWOWANY (z disabled/)
│       ├── es.lua          ← AKTYWOWANY (z disabled/)
│       ├── fr.lua          ← AKTYWOWANY (z disabled/)
│       ├── pt.lua          ← AKTYWOWANY (z disabled/)
│       └── ru.lua          ← AKTYWOWANY (z disabled/)
├── modules/
│   ├── client_locales/
│   │   ├── locales.otui    ← ZMIENIONY (nowy layout)
│   │   ├── locales.lua     ← ZMIENIONY (sortowanie, verticalBox)
│   │   └── locales1.lua    ← ZMIENIONY (j.w.)
│   ├── client_transliteration/
│   │   ├── transliteration.otmod  ← NOWY
│   │   └── transliteration.lua    ← NOWY
│   ├── client_options/
│   │   ├── data_options.lua       ← ZMIENIONY (+4 opcje transliteracji)
│   │   └── styles/interface/console.otui  ← ZMIENIONY (+4 checkboxy)
│   └── game_console/
│       └── console.lua            ← ZMIENIONY (+hooki transliteracji)
```

---

## Build CI

- **Workflow:** `build-windows.yml` (ID: 211701257)
- **Run ID:** `22039818575`
- **Branch:** `serwer-7.4`
- **Trigger:** `workflow_dispatch`
- **Status:** in_progress (uruchomiony 2026-02-15)
- **Poprzednie buildy:** X (failed) — z powodu MSVC ICE C1001 (naprawione fix v4)

Uwaga: Zmiany w tej sesji to wyłącznie pliki Lua/OTUI/PNG — nie dotyczą kodu C++ 
ani CMakeLists.txt, więc nie powinny wpłynąć na kompilację C++.

---

## Problemy napotkane

1. **Terminal z skumulowanymi komendami** — `git commit` nie wykonał się za pierwszym razem, 
   bo terminal miał zaległe komendy z poprzednich sesji. Guardian automatycznie 
   przechwycił zmiany w swoim commicie `d57de1966`.

2. **Generacja flag PNG** — pierwsza wersja skryptu Python (z listami pikseli i struct.pack 
   w pętli) była za wolna dla 256x256 (timeout). Rozwiązanie: `bytearray()` z appendami.

3. **Charsets w locale files** — ru.lua ma `charset = "cp1251"`, pozostałe cp1252. 
   Nie zmieniane na UTF-8, bo system OTClient obsługuje konwersję charsetów.
