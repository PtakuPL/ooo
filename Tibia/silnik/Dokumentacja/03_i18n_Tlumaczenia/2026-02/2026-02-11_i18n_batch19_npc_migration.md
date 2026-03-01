# i18n Batch 19 — Migracja NPC say() + C++ messages

**Data:** 2026-02-11  
**Commit:** `216299203`  
**Branch:** `feature/i18n-multilanguage`

## Podsumowanie

Batch 19 migrował `npcHandler:say()` w 21 plikach NPC, kilka wiadomości C++ oraz 2 skrypty Lua. Dodano 61 nowych kluczy i18n do `npc.json` (7650 → 7711), zsynchronizowano z 54 locale.

## Zmigrowane pliki NPC (21)

### Proste "..." → npc.common.ellipsis (6 plików)
- benjamin.lua, chrystal.lua, dove.lua, kroox.lua, liane.lua, lokur.lua
- Wszystkie miały `npcHandler:say("...", npc, creature)` → `NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.common.ellipsis")`
- Wspólny klucz `npc.common.ellipsis` zamiast osobnych per-NPC

### Proste single-say (5 plików)
- **albinius.lua**: `"ok."` → `npc.albinius.say_ok`
- **gnomerik.lua**: `"Stop it!..."` → `npc.gnomerik.say_stop`
- **costello.lua**: tekst o Fugio → `npc.costello.say_fugio`
- **elathriel.lua**: zakup klucza → `npc.elathriel.say_key`
- **emma.lua**: tekst dołączenia kobiety → `npc.emma.say_join_female`

### Naprawy bugów (2 pliki)
- **bertram.lua**: BUG — klucz i18n `"npc.bertram.key_response"` był wysyłany jako dosłowny tekst do `say()`. Naprawione przez użycie `npcSay()`.
- **duncan.lua**: BUG — brak argumentu `npc` w oryginalnym `say(text, creature)`. Naprawione przez migrację do `npcSay(npcHandler, npc, creature, key)`.

### Ternary/conditional (1 plik)
- **a_majestic_warwolf.lua**: ternary sex-based → `if/else` z 2 kluczami (`say_female`, `say_male`)

### Multi-string say (1 plik)
- **angus.lua**: `say("str1", "str2", npc, creature)` → `npcSayMultiple(... {key1, key2}, 4000)`

### Tabele konfiguracyjne (6 plików)
- **gnommander.lua**: 7-elementowa tabela `speech` → `speech_1` do `speech_7` + `npcSayMultiple`
- **gnome_trooper.lua**: 4-elementowa tabela `response` → `responseKeys` + `npcSay`
- **myra.lua**: 11-elementowa tabela `tasks` → `taskKeys` + `npcSay`
- **simon_the_beggar.lua**: 11-elementowa tabela `noResponse` → 4 unikalne klucze (`no_i_see`, `no_next_time`, `no_your_decision`, `no_ok`)
- **flickering_soul.lua**: dynamiczna konkatenacja listy bossów → `npcSay` z argumentami formatu (`shards_remaining` z `{1}`, `shards_all_done`)
- **gerimor.lua**: 7-mission cult config table (22 stringi) → `textKey`/`completeTextKey` + `npcSayMultiple`

## Zmiany C++
- **condition.cpp**: wiadomości regeneracji HP → `plural("cpp.combat.condition_healed", ...)`
- **npc.cpp, party.cpp, game.cpp, iobestiary.cpp, tile.cpp, house.cpp**: różne wiadomości i18n

## Skrypty Lua
- **mission12_into_fortress.lua**: migracja tekstów questowych
- **exercise_training_weapons.lua**: migracja tekstów ćwiczeń

## Statystyki
- **Pliki zmienione:** 87 (21 NPC + 6 C++ + 2 scripts + 55 i18n JSON + 3 inne)
- **Nowe klucze:** 61 (npc.json: 7650 → 7711)
- **Sync:** 54 locale × 61 kluczy = 3294 wpisów

## Pozostałe do migracji (npcHandler:say)
Po tym batchu pozostaje około 60-70 wywołań `npcHandler:say()` w ~12 plikach:
- **bozo.lua** (7 calls) — ogromna tabela konfiguracyjna (36 wpisów + 4 jesterOutfit = ~119 stringów)
- **tereban_functions.lua** (5 calls) — tabela konfiguracyjna (8 wpisów × 5 messages = ~43 stringy)
- **grizzly_adams.lua** (18 calls) — największy pozostały plik
- **hireling NPC** (11 calls)
- **mr_morris.lua** (10 calls)
- **seymour.lua** (5 calls) — keywordHandler (tylko player, bez npc/creature)
- **walter_jaeger.lua** (3 calls) — dynamiczny `getOfferString()`
- **lynda.lua** (2 calls) — częściowo zmigrowany
- **captain_dreadnought.lua** (2 calls) — częściowo zmigrowany
- **vascalir.lua** (1 call) — keywordHandler
- **ruprecht.lua** (1 call) — dynamiczna lista itemów

## Problemy i wnioski
1. **Duże tabele konfiguracyjne** (bozo, tereban) wymagają ~50-120 kluczy każda — odłożone na osobne batche
2. **keywordHandler callbacks** (seymour, vascalir) mają tylko `player` bez `npc/creature` — potrzebują innego podejścia
3. **Dynamiczne stringi** (walter_jaeger getOfferString, ruprecht item list concat) — trudne do zlokalizowania
4. Klucz **npc.common.ellipsis** zastosowany dla wspólnego tekstu "..." zamiast duplikacji per-NPC
