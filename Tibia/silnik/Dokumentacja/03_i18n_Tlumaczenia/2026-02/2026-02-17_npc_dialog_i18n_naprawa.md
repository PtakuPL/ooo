# Naprawa NPC Dialog i18n — sesja 2026-02-17

**Data:** 2026-02-17  
**Status:** Zrealizowane

## Podsumowanie
Naprawiono problemy z systemem dialogów NPC w połączeniu z systemem tłumaczeń i18n. Sesja obejmowała naprawę wyświetlania tagów językowych, zastępowania |PLAYERNAME|, nakładki niebieskiego tekstu (klikalnych słów kluczowych) oraz czyszczenie plików tłumaczeń.

## Problemy i rozwiązania

### 1. Tagi [EN]/[PL] widoczne w wiadomościach NPC
**Problem:** W oknie dialogowym NPC pojawiały się prefiksy `[EN]` i `[PL]` (np. `"[EN] Hello. How may I help you |PLAYERNAME|?"`). Tagi te były wstawione bezpośrednio w wartości tłumaczeń JSON przez skrypty i18n worker.

**Rozwiązanie:**
- Dodano globalną funkcję `stripI18nLanguageTags(text)` w `data/global.lua` — usuwa prefiks `[XX] ` z początku tekstu
- Zastosowano w 3 kluczowych miejscach:
  - `NpcHandler:tryLocalizedMessage()` w `npc_handler.lua`
  - `NPC_LIB.i18n.npcSay()` w `i18n.lua`
  - `NPC_LIB.i18n.npcSayMultiple()` w `i18n.lua` (oba ścieżki: natychmiastowa i opóźniona)
  - `NpcHandler:sayLocalized()` w `npc_handler.lua`
- Wyczyszczono pliki JSON tłumaczeń — usunięto tagi ze wszystkich 6 języków:
  - PL: 1448 tagów usunięto
  - DE: 13311, ES: 2304, FR: 13295, PT: 13292, RU: 12928
  - Backup plików: `npc.json.bak_before_tag_strip`

### 2. |PLAYERNAME| wyświetlane dosłownie w NPC_LIB.i18n.npcSay()
**Problem:** Funkcja `NPC_LIB.i18n.npcSay()` wywoływała `npc:say()` bezpośrednio, omijając `SayEvent` → `parseMessage()` pipeline. Dlatego tagi `|PLAYERNAME|` w tłumaczeniach NPC-specyficznych nie były zamieniane na nazwę gracza.

**Rozwiązanie:**
- Dodano `translatedMessage:gsub("|PLAYERNAME|", player:getName() or "")` w:
  - `NPC_LIB.i18n.npcSay()` — po `player:getTranslation()`
  - `NPC_LIB.i18n.npcSayMultiple()` — w obu ścieżkach (natychmiastowa i opóźniona)

**Uwaga:** Dla `tryLocalizedMessage()` ten problem nie występuje, bo ta funkcja przechodzi przez `self:say()` → `SayEvent` → `parseMessage()`, który już zamienia `|PLAYERNAME|`.

### 3. Nakładka niebieskiego tekstu źle wyrównana (UTF-8)
**Problem:** Tabela `letterWidth` w console.lua mapuje bajty 0-255 na szerokości pikseli fontu. Polskie znaki (ó, ż, ą) to wielobajtowe sekwencje UTF-8. Kod procesował każdy bajt osobno, dając błędne szerokości (np. "ó" = 0xC3+0xB3 → 9+5=14px zamiast ~7px). Powodowało to przesunięcie niebieskich klikanych słów kluczowych względem normalnego tekstu.

**Rozwiązanie (console.lua):**
- Zmieniono pętlę `for` na pętlę `while` z obsługą UTF-8:
  - Bajty kontynuacji UTF-8 (0x80-0xBF): pomijane (szerokość 0)
  - Bajty wiodące UTF-8 (0xC0+): pojedyncza szerokość 7px (średnia dla fontu verdana-11px)
  - Bajty ASCII (<0x80): oryginalny lookup z tabeli `letterWidth`
- Naprawiono oba pętle: fill przed słowem kluczowym i fill końcowy

### 4. Plan opcji "Rozmawiaj" w menu Battle
Utworzono szczegółowy plan implementacji nowej opcji w menu PPM na NPC w oknie Battle.
- Plik: `Dokumentacja/02_Serwer_Canary/2026-02/2026-02-17_plan_rozmawiaj_battle.md`
- Kluczowa zmiana: dodanie `if creatureThing:isNpc() then menu:addOption("Rozmawiaj", ...)` w `createThingMenu()` — `gameinterface.lua`
- Akcja: `g_game.talk("hi")` — NPC usłyszy i odpowie

## Zmodyfikowane pliki

### Serwer (wymaga restart serwera)
| Plik | Zmiana |
|------|--------|
| `data/global.lua` | Dodano `stripI18nLanguageTags()` |
| `data/npclib/npc_system/npc_handler.lua` | Strip tagów w `tryLocalizedMessage()` i `sayLocalized()` |
| `data-otservbr-global/lib/npc/i18n.lua` | Strip tagów + |PLAYERNAME| gsub w `npcSay()` i `npcSayMultiple()` |
| `i18n/pl/npc.json` | Usunięto 1448 tagów [EN]/[PL] |
| `i18n/de/npc.json` | Usunięto 13311 tagów |
| `i18n/es/npc.json` | Usunięto 2304 tagów |
| `i18n/fr/npc.json` | Usunięto 13295 tagów |
| `i18n/pt/npc.json` | Usunięto 13292 tagów |
| `i18n/ru/npc.json` | Usunięto 12928 tagów |

### Klient (wymaga skopiowanie na Windows + restart klienta)
| Plik | Zmiana |
|------|--------|
| `testyy/modules/game_console/console.lua` | UTF-8 aware phantom label overlay |

## Architektura systemu NPC i18n — pełny pipeline

```
1. NPC Lua → NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.name.key")
2. Gracz mówi "hi" → npcHandler:greet() → tryLocalizedMessage(MESSAGE_GREET, player, npc)
3. tryLocalizedMessage():
   a. player:getTranslation("npc.name.key", args) → C++ fmt::vformat()
   b. stripI18nLanguageTags() → usuwa [EN]/[PL] prefiks
   c. self:say(text, npc, player) → addEvent(SayEvent, delay, ...)
4. SayEvent() (npc.lua):
   a. parseMessage() → zamienia |PLAYERNAME|, |TAG_TIME| itp.
   b. npc:say(parsedText, TALKTYPE_PRIVATE_NP) → wysyła do klienta
5. Klient (console.lua):
   a. Odbiera NPC wiadomość jako MessageModes.NpcFrom
   b. getHighlightedText() → wyciąga {keyword} pozycje
   c. Tworzy phantom label overlay z niebieskimi słowami kluczowymi
   d. Klik na niebieski tekst → sendMessage(keyword, tab) → odpowiedź do NPC
```

## Pipeline alternatywny (NPC_LIB.i18n.npcSay)
```
1. NPC Lua → NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.key")
2. npcSay():
   a. player:getTranslation("npc.key") → tłumaczy tekst
   b. stripI18nLanguageTags() → usuwa [EN]/[PL]
   c. gsub("|PLAYERNAME|", player:getName()) → zamienia tag
   d. npc:say(text, TALKTYPE_PRIVATE_NP) → bezpośrednio do klienta
   ⚠ UWAGA: Pomija SayEvent/parseMessage — dlatego |PLAYERNAME| musi być
     zastąpiony ręcznie w punkcie (c)
```

## Znane ograniczenia
1. **Szerokość UTF-8 znaków**: Użyto stałej wartości 7px dla wszystkich wielobajtowych znaków Unicode — to przybliżenie. Idealne rozwiązanie wymagałoby pomiarów tekstu z silnika OTClienta
2. **{keyword} i fmt::vformat**: Gdy tłumaczenie zawiera zarówno `{0}` (arg) jak i `{keyword}` (klikalne), fmt::vformat zwraca surowy tekst (fallback) — {0} nie jest zamienione. Ale NPC-specyficzne tłumaczenia używają `|PLAYERNAME|` zamiast `{0}`, więc to nie jest problem w praktyce
3. **Kopiowanie na Windows**: Zmienione pliki klienta muszą być ręcznie skopiowane na Windows do `C:\Gry\Tibia\otland\otclient\testyy — kopia\modules\game_console\console.lua`

## Co dalej
- Implementacja opcji "Rozmawiaj" w Battle (plan gotowy)
- Weryfikacja klikania na niebieskie słowa kluczowe po skopiowaniu console.lua
- Test wyrównania nakładki z polskimi znakami
