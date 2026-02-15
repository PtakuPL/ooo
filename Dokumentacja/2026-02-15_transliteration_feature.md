# Transliteracja pisma nie-łacińskiego na łacińskie — Feature

**Data:** 2026-02-15
**Branch:** `serwer-7.4`
**Commit:** `be63ab0ba`

## Co zostało zrobione

Dodano opcjonalną funkcję transliteracji (zamiany liter) w czacie — gracze mogą włączyć konwersję pisma cyrylickiego, greckiego, arabskiego i japońskiego katakana na alfabet łaciński.

**Ważne:** To NIE jest tłumaczenie tekstu. To zamiana samych liter/znaków, np.:
- Cyrylica: "Привет мир" → "Privet mir"
- Greka: "Γειά σου" → "Geia sou"
- Arabski: "مرحبا" → "mrhba"
- Katakana: "カタカナ" → "katakana"

## Pliki zmienione / utworzone

### Nowe pliki:
1. **`modules/client_transliteration/transliteration.otmod`** — definicja modułu OTClient
2. **`modules/client_transliteration/transliteration.lua`** — główna logika:
   - Tabele mapowania znaków (Cyrillic ~70 znaków, Greek ~50, Arabic ~40, Katakana ~50)
   - Dekoder UTF-8 (ręczny, codepoint po codepoint)
   - Funkcja `Transliteration.process(text)` — przetwarza tekst
   - Funkcja `Transliteration.isActive()` — sprawdza czy jakikolwiek skrypt jest włączony
   - Szybki test ASCII — jeśli tekst jest czysto ASCII, pomija przetwarzanie

### Zmodyfikowane pliki:
3. **`modules/client_options/data_options.lua`** — dodano 4 opcje boolean (domyślnie OFF):
   - `transliterateCyrillic = false`
   - `transliterateGreek = false`
   - `transliterateArabic = false`
   - `transliterateKatakana = false`

4. **`modules/client_options/styles/interface/console.otui`** — dodano 4 checkboxy w zakładce Console:
   - Transliterate Cyrillic to Latin
   - Transliterate Greek to Latin
   - Transliterate Arabic to Latin
   - Transliterate Katakana to Latin

5. **`modules/game_console/console.lua`** — hooki w funkcji `onTalk()`:
   - Przed `staticText:addMessage()` — transliteracja dymków mowy nad głową
   - Przed `applyMessagePrefixies()` — transliteracja tekstu w konsoli czatu
   - Bezpieczne odwołanie przez `modules.client_transliteration` (nie crash jeśli moduł nie załadowany)

## Architektura

```
Gracz pisze po rosyjsku "Привет"
       ↓
Serwer wysyła wiadomość UTF-8
       ↓
Klient: onTalk() w console.lua
       ↓
Sprawdzenie: modules.client_transliteration.Transliteration.isActive()?
       ↓ TAK (gracz włączył cyrylicę)
Transliteration.process("Привет") → "Privet"
       ↓
addText() / staticText:addMessage() z przetłumaczonym tekstem
```

## Jak gracz włącza/wyłącza

Ustawienia → zakładka Console → checkboxy na dole:
- ☐ Transliterate Cyrillic to Latin
- ☐ Transliterate Greek to Latin  
- ☐ Transliterate Arabic to Latin
- ☐ Transliterate Katakana to Latin

Domyślnie wszystkie OFF. Gracz włącza tylko te pisma które chce widzieć po łacińsku.

## Problemy / uwagi

- Tekst oryginalny jest bezpowrotnie zamieniony na wyświetlaczu — gracz nie widzi oryginału po włączeniu opcji
- Arabski jest uproszczony (brak kontekstowych form liter)
- Katakana bez obsługi Hiragana i Kanji (ideografy CJK nie da się sensownie transliterować)
- Moduł jest sandboxed — dostęp przez `modules.client_transliteration`
