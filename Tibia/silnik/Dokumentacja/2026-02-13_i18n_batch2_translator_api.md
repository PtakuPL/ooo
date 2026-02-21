# i18n Batch 2: Translator API + migracja skryptów
**Data:** 2026-02-13  
**Branch:** `feature/i18n-multilanguage`  
**Commit:** `c258a4469`

## Podsumowanie

Sesja kontynuowała migrację i18n. Główne osiągnięcia:

### 1. Nowe API: Player:getTranslation + Translator global

**Problem:** `Translator.getTranslation(player, key)` był wywoływany w ~30 miejscach (gamestore, on_look, blessing, player.lua), ale `Translator` nigdy nie był zdefiniowany — ani w C++, ani w Lua. Powodowałoby to "attempt to index nil value" crash.

**Rozwiązanie:**
- **C++** (`player_functions.hpp/cpp`): Dodano `Player:getTranslation(key, args?)` — pobiera locale gracza, wywołuje `i18n::g_translator().get()` lub `.format()`.
- **Lua** (`i18n_wrappers.lua`): Dodano globalny `Translator = {}` z metodami:
  - `Translator.getTranslation(player, key, args)` → deleguje do `player:getTranslation()`
  - `Translator.getFormattedTranslation(player, key, ...)` → string.format style

### 2. Zmigrowane pliki

| Plik | Zmiana | Klucze |
|------|--------|--------|
| `world_board.lua` | 3× `sendTextMessage` → `sendLocalizedTextMessage` | `scripts.world_board.msg_1/2/3` |
| `spellbook.lua` | 2 nagłówki → `Translator.getTranslation` (server-side dla showTextDialog) | `scripts.spellbook.header_level/mlevel` |
| `offline_training_book.lua` | Cały tekst → `Translator.getTranslation` | `scripts.offline_training_book.info` |
| `cassino.lua` | 11× `npc:say` → `npc:sayLocalized` | `npc.cassino.rolled/won/lost` |
| `lizard_tunnel_guard.lua` | 1× `player:say` → `player:sayLocalized` | `npc.lizard_tunnel_guard.spotted` |

### 3. Naprawione broken concat patterns (5 szt.)

Concat anti-pattern: `"key" .. variable .. " text."` generował nieprawidłowy klucz i18n.

| Plik | Opis | Nowy klucz |
|------|------|------------|
| `concoctions.lua:140` | worn off msg | `misc.concoctions.msg_1` z `{0}` |
| `concoctions.lua:183` | cooldown msg | `misc.concoctions.msg_2` z `{0}`, `{1}` |
| `concoctions.lua:194` | activation msg | `misc.concoctions.msg_3` z `{0}`, `{1}`, `{2}` |
| `blessing.lua:232` | adventurer level msg | `misc.blessing.msg_1` z `{0}` |
| `lever.lua:206` | boss cooldown msg | `misc.lever.msg_1` z `{0}`, `{1}` |

### 4. Klucze JSON i sync

- **+14 nowych kluczy** (10 scripts.json + 4 npc.json)
- **756 klucz-locale wpisów** zsynchronizowanych do 54 lokali
- **Weryfikacja:** 100% spójność — scripts.json: 2050 kluczy, npc.json: 13769 kluczy, identycznie w 55 lokalach
- **Regeneracja compact locale:** 2,895,225 tłumaczeń (wzrost z 2,892,537)

### 5. Statystyki commitu

- **184 plików** zmienionych
- **551,871 insertions / 544,214 deletions**
- 10 plików Lua/C++ + 110 locale JSON + 55 compact Lua + docs

## Znane ograniczenia (low priority)

- `bed.cpp:294` "Nobody is sleeping there." — brak Player* w kontekście
- `item.cpp:146` "Unwrap it..." — brak Player* w kontekście
- Monster onomatopoeia (Hrrr, Fchhh) — stylistycznie lepiej niertłumaczalne

## Następne kroki

- Weryfikacja kompilacji C++ z nowym `Player:getTranslation`
- Testy runtime Translator API w gamestore/on_look
- Dalsza migracja hardcoded stringów (gold_highscore, spy — GM-only, niski priorytet)
