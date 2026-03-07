# Fix systemu lokalizacji (i18n) — 2026-02-15

## Problem
Bug zgłoszony przez użytkownika: po wybraniu języka (rosyjski/polski) i kliknięciu "Zaloguj", język interfejsu przeskakiwał na japoński lub angielski.

## Analiza przyczyny (Root Cause)

### 1. Zanieczyszczenie tablic tłumaczeń przez `dofiles('/locales')`
Funkcja `installLocales()` wywoływała `dofiles('/locales')`, co ładowało **WSZYSTKIE** pliki `.lua` z katalogu `/locales/`:
- 3 pliki bazowe: `en.lua`, `ja.lua`, `pl.lua`
- 1 plik semantyczny (EN): `game_i18n_en.lua`
- 1 plik semantyczny (PL): `game_i18n_pl.lua` 
- **58 plików compact**: `game_i18n_*_compact.lua`

Pliki compact na końcu mergują tłumaczenia do `_G.locale`:
```lua
if locale and locale.translation then
  for key, value in pairs(gameTranslations) do
    locale.translation[key] = value
  end
end
```

Ale `_G.locale` wskazywał na **OSTATNI** załadowany plik bazowy:
- Pliki compact od `ar` do `ja` → mergowały do locale EN (bo `en.lua` ustawiał `_G.locale`)
- Pliki compact od `ka` do `pl` → mergowały do locale JA
- Pliki compact od `pt` do `zh` → mergowały do locale PL

**Efekt**: Każda locale miała tłumaczenia compact z INNEGO języka!

### 2. Złe ścieżki w `loadGameI18nForLocale()`
Funkcja używała ścieżek względnych:
```lua
pcall(dofile, 'game_i18n_' .. locale.name)
```
Ale `dofile()` w OTClient rozwiązuje ścieżki względne do katalogu ŹRÓDŁOWEGO pliku wywołującego (tu: `modules/client_locales/`), a NIE do `/locales/`. Wywołanie cicho failowało.

### 3. Klucze semantyczne (`otclient_modules.entergame.tr_14`)
162 pliki modułów używa nowych kluczy semantycznych (np. `tr("otclient_modules.entergame.tr_14")`). Ale te klucze istnieją TYLKO w `game_i18n_en.lua`. Inne locales nie miały tych tłumaczeń → `tr()` zwracał surowy klucz.

### 4. `__gameI18nLoaded` nie resetowane przy `reloadModules()`
Globalna flaga `_G.__gameI18nLoaded` przeżywała `g_modules.reloadModules()`, więc po przeładowaniu modułów (np. przy zmianie języka), game_i18n files NIE były ponownie ładowane dla nowych obiektów locale.

## Naprawy (commit `fe4d2d652`)

### Plik: `modules/client_locales/locales.lua`

1. **`installLocales()` — filtrowanie plików**
   - Zamiast `dofiles(directory)`, używa `g_resources.listDirectoryFiles(directory)` 
   - Pomija pliki zaczynające się od `game_i18n_` (te są ładowane per-locale)
   
2. **`loadGameI18nForLocale()` — ścieżki absolutne**
   - Zmienione z `dofile('game_i18n_XX')` na `dofile('/locales/game_i18n_XX')`
   - Teraz poprawnie ładuje pliki z katalogu `/locales/`

3. **`tr()` — fallback przez angielski**
   - Nowy mechanizm: jeśli klucz nie istnieje w bieżącej locale:
     1. Szuka klucza w EN locale → znajduje wartość angielską
     2. Szuka tej wartości angielskiej w bieżącej locale → znajduje tłumaczenie
   - Przykład: `tr("otclient_modules.entergame.tr_14")` z locale PL:
     - PL nie ma tego klucza
     - EN: `"otclient_modules.entergame.tr_14" = "Enter Game"`
     - PL: `"Enter Game" = "Wejdz do gry"` → zwraca `"Wejdz do gry"`

4. **`init()` — reset `__gameI18nLoaded`**
   - `_G.__gameI18nLoaded = {}` na początku `init()` 
   - Zapewnia ponowne ładowanie game_i18n po `reloadModules()`

5. **`applyFormat()` — helper**
   - Wyciągnięto logikę formatowania (brace-style `{}` + printf-style `%d`) do osobnej funkcji

## Status CI
- Build `22035222285` — FAILED (HTTP 502 przy pobieraniu `pugixml` — problem sieciowy GitHub, NIE błąd kodu)
- Nowy build uruchomiony po pushu `fe4d2d652`

## Uwagi
- `ru.lua` (rosyjski) jest w `data/locales/disabled/` — NIE jest aktywny
- Aby dodać rosyjski, trzeba przenieść `ru.lua` z `disabled/` do `/locales/`
- 40+ języków jest w `disabled/` — do decyzji które aktywować
