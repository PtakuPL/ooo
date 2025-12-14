# Migracja fontów OTClient na Unicode (TTF)

## Data: 14 grudnia 2025
## Status: W TRAKCIE - Problem z ładowaniem TTF

---

## AKTUALNY PROBLEM

**Font TTF `noto-12` nie ładuje się!**

```
ERROR: Lua exception: C++ exception
ERROR: Unable to load module 'client_styles': LUA ERROR: C++ exception
ERROR: font 'noto-12' not found
```

### Fakty potwierdzone:
- ✅ Klient DZIAŁA z fontami bitmapowymi (CP1250) - bez polskich znaków
- ✅ Pliki TTF istnieją w `/data/fonts/ttf/NotoSans-Regular.ttf`
- ✅ Plik `noto-12.otfont` jest poprawnie skonfigurowany
- ❌ FreeType NIE może załadować pliku TTF
- ❌ Błąd: `TTF load failed: /fonts/ttf/NotoSans-Regular.ttf`

### Hipotezy do sprawdzenia:
1. **Ścieżka** - `g_resources.getRealPath()` może zwracać nieprawidłową ścieżkę
2. **Format pliku** - może plik TTF jest uszkodzony lub niezgodny
3. **Uprawnienia** - FreeType może nie mieć dostępu do pliku
4. **Kolejność ładowania** - fonty mogą być ładowane przed inicjalizacją zasobów

### Plan naprawy (kolejność):
1. ~~Zmiana ścieżki z `/fonts/ttf/...` na `fonts/ttf/...`~~ - NIE POMOGŁO
2. Dodać logowanie do TTFFont::load() żeby zobaczyć rzeczywistą ścieżkę
3. Sprawdzić czy `mono-12` (też TTF) w ogóle działa
4. Sprawdzić kod `g_resources.getRealPath()` 
5. Może użyć bezwzględnej ścieżki Windows w pliku .otfont

---

## Oryginalny Problem

OTClient nie wyświetlał poprawnie polskich znaków (ą, ć, ę, ł, ń, ó, ś, ź, ż). Zamiast tego wyświetlały się zniekształcone znaki, np. "ZapamÄ" zamiast "Zapamiętaj".

### Przyczyna problemu

1. **Fonty bitmapowe** - klient używał fontów bitmapowych (verdana-11px-*, cipsoftFont, terminus-*, small-9px) które były zakodowane w CP1250/CP1252
2. **Kodowanie UTF-8** - pliki tłumaczeń (pl.lua) były zapisane w UTF-8
3. **Niezgodność kodowań** - tekst UTF-8 był renderowany przez fonty oczekujące CP1250, co powodowało zniekształcenia

## Rozwiązanie

Migracja wszystkich fontów bitmapowych na fonty TTF (TrueType) obsługujące pełne Unicode.

### Wybrano font: NotoSans-Regular.ttf

- **Pełna obsługa Unicode** - polskie, japońskie, chińskie, koreańskie i inne znaki
- **Profesjonalny wygląd** - font od Google, czytelny i nowoczesny
- **Różne warianty** - dostępne w katalogu `/fonts/ttf/`

## Wykonane zmiany

### 1. Utworzenie nowych definicji fontów TTF

#### `/data/fonts/noto-12.otfont`
```
Font
  name: noto-12
  type: ttf
  source: /fonts/ttf/NotoSans-Regular.ttf
  size: 12
  default: true
```

#### `/data/fonts/noto-12-underline.otfont`
```
Font
  name: noto-12-underline
  type: ttf
  source: /fonts/ttf/NotoSans-Regular.ttf
  size: 12
  underline: true
```

### 2. Zamiana fontów w plikach stylów (data/styles/*.otui)

| Stary font | Nowy font |
|------------|-----------|
| verdana-11px-antialised | noto-12 |
| verdana-11px-monochrome | noto-12 |
| verdana-11px-monochrome-underline | noto-12-underline |
| verdana-11px-rounded | noto-12 |
| verdana-10px-antialiased | noto-12 |
| verdana-10px | noto-12 |
| verdana-bold-8px-antialiased | noto-12 |
| small-9px | noto-12 |
| terminus-10px | noto-12 |
| terminus-14px-bold | noto-12 |
| sans-bold-16px | noto-12 |
| cipsoftFont | noto-12 |

### 3. Zaktualizowane pliki stylów

- `10-buttons.otui`
- `10-checkboxes.otui`
- `10-comboboxes.otui`
- `10-items.otui`
- `10-labels.otui`
- `10-progressbars.otui`
- `10-scrollbars.otui`
- `10-textedits.otui`
- `10-windows.otui`
- `20-popupmenus.otui`
- `20-tabbars.otui`
- `20-tables.otui`
- `20-topmenu.otui`
- `30-messageboxes.otui`
- `30-miniwindow.otui`
- `40-outfitwindow.otui`

### 4. Zaktualizowane moduły (modules/)

- `client_entergame/entergame.otui`
- `client_entergame/characterlist.otui`
- `client_entergame/createAccount.otui`
- `client_options/styles/controls/keybinds.otui`
- `client_options/styles/controls/preset.otui`
- `client_options/styles/controls/key_edit.otui`
- `client_terminal/terminal.otui`
- `game_store/game_store.otui`
- `game_store/style/ui.otui`
- `game_store/style/transferpoints.otui`
- `game_store/style/changename.otui`
- `game_prey/prey.otui`
- `game_shop/giftcoins.otui`
- `game_quickloot/quickloot.otui`
- `game_cyclopedia/game_cyclopedia.otui`
- `game_cyclopedia/tab/bestiary/bestiary.otui`
- `game_rewardwall/styles/pickreward.otui`

### 5. Ustawienie domyślnego fontu

Usunięto `default: true` z `verdana-11px-antialised.otfont` i dodano do `noto-12.otfont`.

## Struktura katalogów fontów

```
data/fonts/
├── ttf/                              # Fonty TrueType
│   ├── NotoSans-Regular.ttf          # Główny font Unicode
│   ├── NotoSans-Bold.ttf
│   ├── NotoSansJP-Regular.otf        # Japoński
│   ├── NotoSansKR-Regular.otf        # Koreański
│   ├── NotoSansSC-Regular.ttf        # Chiński uproszczony
│   ├── NotoSansTC-Regular.otf        # Chiński tradycyjny
│   └── ... (inne warianty)
├── noto-12.otfont                    # Definicja głównego fontu
├── noto-12-underline.otfont          # Wersja z podkreśleniem
├── verdana-11px-*.otfont             # Stare fonty bitmapowe (zachowane dla kompatybilności)
└── *.png                             # Tekstury fontów bitmapowych
```

## Komendy użyte do migracji

```bash
# Zamiana fontów verdana na noto-12 we wszystkich plikach .otui
find . -name "*.otui" -type f -exec sed -i \
  -e 's/font: verdana-11px-antialised/font: noto-12/g' \
  -e 's/font: verdana-11px-monochrome-underline/font: noto-12-underline/g' \
  -e 's/font: verdana-11px-monochrome/font: noto-12/g' \
  -e 's/font: verdana-11px-rounded/font: noto-12/g' \
  -e 's/font: verdana-10px-antialiased/font: noto-12/g' \
  -e 's/font: verdana-10px/font: noto-12/g' \
  -e 's/font: verdana-bold-8px-antialiased/font: noto-12/g' \
  -e 's/font: small-9px/font: noto-12/g' \
  -e 's/font: terminus-10px/font: noto-12/g' \
  -e 's/font: terminus-14px-bold/font: noto-12/g' \
  -e 's/font: sans-bold-16px/font: noto-12/g' \
  -e 's/font: cipsoftFont/font: noto-12/g' \
  -e 's/font: "verdana-11px-rounded"/font: noto-12/g' \
  {} \;
```

## Wymagania systemowe

OTClient musi być skompilowany z obsługą:
- **FreeType** - renderowanie fontów TTF
- **HarfBuzz** - shaping tekstu (dla języków złożonych jak arabski, hindi)

## Przyszłe ulepszenia (TODO)

### System dynamicznego przeładowywania fontów

Aby obsługiwać różne języki bez restartowania klienta:

1. **Konfiguracja fontów per język** w `data/i18n/locales.json`:
```json
{
  "pl": {
    "font": "noto-12",
    "fallbackFonts": ["NotoSans-Regular.ttf"]
  },
  "ja": {
    "font": "noto-jp-12",
    "fallbackFonts": ["NotoSansJP-Regular.otf", "NotoSans-Regular.ttf"]
  }
}
```

2. **Funkcja Lua do przeładowania fontów**:
```lua
function reloadFontsForLocale(localeName)
  g_fonts.clearFonts()
  -- Załaduj fonty dla danego języka
  local fontConfig = g_i18n.getFontConfig(localeName)
  for _, font in pairs(fontConfig.fonts) do
    g_fonts.importFont(font)
  end
  g_ui.reloadStyles()
end
```

3. **Automatyczne przeładowanie przy zmianie języka**:
```lua
function onLocaleChanged(newLocale)
  reloadFontsForLocale(newLocale)
  -- Opcjonalnie: restart UI
  g_modules.reloadModules()
end
```

## Testowanie

1. Uruchom OTClient
2. Sprawdź okno "Enter Game" - powinny być widoczne polskie znaki:
   - "Zapamiętaj hasło" (nie "ZapamÄ...")
   - "Loguj automatycznie"
   - "Włącz logowanie HTTP"
3. Zmień język na polski w opcjach
4. Sprawdź wszystkie okna dialogowe

## Znane problemy

1. **Rozmiar fontu** - noto-12 może mieć nieco inny rozmiar niż oryginalne fonty bitmapowe, co może wymagać dostosowania layoutu niektórych okien
2. **Wydajność** - fonty TTF mogą być wolniejsze niż bitmapowe na bardzo starym sprzęcie

## Autor

Dokumentacja utworzona: 14 grudnia 2025
