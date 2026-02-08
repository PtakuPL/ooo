# i18n Batch 22-25 — Kompletna migracja NPC dialogów

**Data:** 2026-02-08  
**Branch:** `feature/i18n-multilanguage`  
**Commity:**
- `e615218b5` — batch 22: grizzly_adams (161 kluczy)
- `eff1414f9` — batch 23: bozo + seymour
- `90af36ae0` — batch 24: eliminacja WSZYSTKICH npcHandler:say() + naprawka 43 złamanych konkatenacji i18nKey + i18nArgs w modules.lua
- `ba7be9e49` — batch 25: konwersja text={} + odzyskanie 6276 brakujących kluczy JSON + pełna integralność

## Podsumowanie

Te 4 batche zakończyły pełną migrację systemu dialogów NPC do i18n. Po batchu 25 nie ma żadnych pozostałych wzorców do migracji.

## Stan końcowy

| Metryka | Wartość |
|---------|---------|
| Klucze w npc.json | **13,765** |
| Klucze w Lua | **13,765** |
| Brakujące klucze | **0** |
| Nadmiarowe klucze | **0** |
| Pozostałe `npcHandler:say()` | **0** |
| Pozostałe `text = ""` | **0** |
| Pozostałe `text = {}` | **0** |
| Zsynchronizowane locale | **54** (55 z EN) |

## Batch 22 — grizzly_adams.lua (commit e615218b5)

Największy NPC w systemie — 18 wywołań `npcHandler:say()`.

- Zmigrowano 18 wywołań say() → npcSay/npcSayMultiple
- Dodano 161 kluczy i18n (tabele konfiguracyjne z ponad 60 potworami)
- Wzorzec: config table `text = {"str1", "str2"}` → `textKey = {"npc.grizzly_adams.key1", "npc.grizzly_adams.key2"}`

## Batch 23 — bozo.lua + seymour.lua (commit eff1414f9)

### bozo.lua
- Ogromna tabela konfiguracyjna jokera (36 żartów + 4 outfit jokes)
- ~119 stringów w tabelach → klucze i18n
- say() → npcSay/npcSayMultiple

### seymour.lua
- keywordHandler callbacks (tylko `player` bez `npc/creature`)
- Wymagał refaktoringu — dodanie `local npc = NPC_LIB.getNpcFromHandler(npcHandler)` do odzyskania obiektu NPC
- 5 wywołań say() → npcSay

## Batch 24 — Finalna eliminacja say() (commit 90af36ae0)

### Ostatnie pliki z npcHandler:say()
- **vascalir.lua** — keywordHandler, 1 call
- **captain_dreadnought.lua** — 2 calls, częściowo zmigrowany wcześniej
- **emma.lua** — 1 call, sex-based text
- **gerimor.lua** — mission config table, 22 stringi
- Inne drobne pliki

### Naprawki 43 złamanych konkatenacji i18nKey
Worker autonomiczny (i18n_worker) tworzył klucze z konkatenacją:
```lua
-- PRZED (złamane):
i18nKey = "npc.name." .. "say_1"
-- PO (naprawione):
i18nKey = "npc.name.say_1"
```
Naprawione we wszystkich 43 przypadkach w ~15 plikach.

### modules.lua — wsparcie i18nArgs
W `data/npclib/npc_system/modules.lua` dodano obsługę `i18nArgs`:
- `StdModule.say` teraz odczytuje `parameters.i18nArgs`
- Niestandardowe argumenty (np. nazwa gracza) są prepended do args
- `TAG_TRAVELCOST` automatycznie dodawany na końcu
- Używa `player:sendLocalizedTextMessage(MESSAGE_NPC_FROM, key, args)`

## Batch 25 — Masowa konwersja text={} + odzyskanie 6276 kluczy (commit ba7be9e49)

### Konwersja text={}
- 177 bloków `text = { "str1", "str2", ... }` → `i18nKey = { "key1", "key2", ... }`
- 161 w pierwszym passie, 13 inline, 3 travel NPC (brodrosch, gurbasch, urks_the_mute)
- 45+ plików NPC zmodyfikowanych

### Odzyskanie 6276 brakujących kluczy JSON
Worker i18n migrował kod Lua (tworzył klucze i18n w plikach .lua) ale **nigdy nie dodawał odpowiadających wartości do npc.json**.

#### Technika odzyskiwania: diff-based extraction
1. `diff -U0` między oryginalnym canary a zmigrowanym plikiem test
2. Parsowanie hunków: usunięte linie = oryginalne teksty, dodane linie = klucze i18n
3. Zipowanie tekstów z kluczami, filtrowanie tylko brakujących

#### 3 passy odzyskiwania:
| Pass | Wzorce | Odzyskane | Pozostałe |
|------|--------|-----------|-----------|
| v1 | say("text"), setMessage(TYPE, "text"), text = "...", standalone "text," | 6,124 | 152 |
| v2 | Alignment fix (zbieranie WSZYSTKICH kluczy w hunku) | 0 | 152 (ten sam root cause) |
| v3 | Fix brace detection: `rs.startswith('}')` zamiast `'}' in rs` | 173 | 13 |

#### Krytyczny bug: Tibia markup `{keyword}` vs zamykanie tablicy
Tibia używa `{keyword}` w dialogach NPC (np. `"Even in {retirement} I sometimes..."`).
Stary kod sprawdzał `'}' in removed_line` co fałszywie zamykało state machine tablicy say.
**Fix:** zmiana na `removed_line.startswith('}')` — nawiasy `}` wewnątrz stringów są ignorowane.

#### Ręczna obsługa 13 ostatnich kluczy:
- **1 klucz angus.lua** — escaped quotes `\"` → naprawiony w Lua
- **12 kluczy example_merchant_i18n.lua** — nowy plik demo bez oryginału w canary, klucze dodane ręcznie

### Usunięcie 819 osieroconych kluczy
Klucze w JSON bez referencji w żadnym pliku Lua:
| Typ | Ilość |
|-----|-------|
| stdmod | 456 |
| kw (keyword) | 122 |
| mission | 110 |
| array | 81 |
| voice | 23 |
| greet | 14 |
| jester | 8 |
| keyword | 2 |
| multi | 2 |
| say | 1 |
| **RAZEM** | **819** |

### Naprawa spectulus.say_24
Jeden klucz używany w dwóch kontekstach:
- Linia 220: `say("")` (pusty/cichy) — usunięto wywołanie
- Linia 237: prawdziwy tekst — zachowano

### Synchronizacja 54 locale
Wszystkie 54 pliki locale zsynchronizowane do 13,765 kluczy każdy (puste wartości oczekujące tłumaczeń).

## Problemy napotkane

1. **Worker i18n nie dodawał kluczy do JSON** — tworzył klucze w Lua ale zapominał o JSON. Masowe odzyskanie wymagane.
2. **Tibia markup `{keyword}`** — fałszywie zamykał tablice w parserze diff. Fix: `startswith('}')`.
3. **Escaped quotes `\"`** — malformowały klucz angusa. Ręczna naprawa.
4. **Dual-context key** — spectulus.say_24 używany do pustego i prawdziwego tekstu. Usunięto pusty kontekst.
5. **Brak oryginału canary** — example_merchant_i18n.lua jest nowym plikiem demo, klucze dodane ręcznie z komentarzy.

## Ścieżka oryginałów canary
`/home/ptaku/serweryt/Tibia/silnik/canary/data-otservbr-global/npc/`

## Równolegle: prace Codexa (ten sam dzień 2026-02-08)

Codex w tym samym dniu wykonał dużą porcję migracji C++ i18n (opisane w `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md`):

1. **Locale sync pipeline** — klient→serwer→baza danych:
   - Lua API: `Player:getLocale()` / `Player:setLocale()`
   - Extended Opcode (opcode 1) w C++ i Lua
   - Migracja bazy: `ALTER TABLE players ADD COLUMN locale VARCHAR(5)` (migracja 53)
   - Load/save locale w `iologindata_load/save_player.cpp`
   - Aktywacja `extended_opcode.lua` (usunięcie prefiksu `#`)
   - Rejestracja eventu w `login.lua`

2. **Translator normalization** — `normalizeLocale()` z canonical mapping:
   - `zh_tw/zh-TW/zh_hant` → `zh_TW`, `zh_cn` → `zh`, `fil` → `tl`, `pt_BR` → `pt`
   - Testy jednostkowe w `tests/unit/utils/locale_normalization_test.cpp`

3. **C++ i18n — nowe bloki:**
   - **Forge history** (player.cpp): fusion/transfer/convergence/tier + pluralizacja kosztów (dust/cores)
   - **EXP messages** (player.cpp): bazowy exp, VIP bonus, animus bonus, exp lost + hazard tag
   - **Stash** (player.cpp): stowed/moved objects z pluralizacją
   - **Party** (party.cpp/hpp): join/leave/leader/invite/shared exp + `broadcastPartyLocalizedMessage()`
   - **Chat** (chat.cpp): private channel invite/exclude
   - **Trade** (game.cpp): move closer, wants to trade
   - **Store/wrap** (game.cpp): unwrap house description, store item description
   - **Market** (game.cpp): usunięcie porównań po EN stringu → marker-klucz
   - **combatChangeMana manaLoss** (game.cpp): pełne i18n z cache per-locale
   - **Quick loot** (game.cpp): pełne zdania zamiast sklejanych fragmentów

## Co dalej
Dialogi NPC w `data-otservbr-global/npc/` są **w pełni zmigrowane**. Pozostałe obszary i18n:
- Wiadomości C++ (RETURNVALUE, player messages, protocol messages)
- Skrypty poza npc/ (scripts/, lib/)
- items.xml nazwy przedmiotów
- Mapa OTBM teksty znaków
- Instalka (klient OTC) — moduły UI
