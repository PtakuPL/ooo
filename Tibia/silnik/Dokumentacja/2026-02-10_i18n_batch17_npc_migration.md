# i18n Batch 17 — Migracja NPC config tables, quiz tables, random messages

**Data:** 2026-02-10
**Commit:** `5182776e0`
**Branch:** `feature/i18n-multilanguage`

## Podsumowanie

Zmigrowano 8 plików NPC i 5 plików scripts/lib. Łącznie dodano 73 nowe klucze i18n (60 NPC + 13 scripts).

## Zmigrowane pliki NPC

| Plik | Typ wzorca | Wywołania | Klucze |
|------|-----------|-----------|--------|
| razan.lua | config table (text → textKey) | 3 → 0 | 12 (ape_fur/fish_fins/chicken_wings/blue_cloth × 3) |
| shoddy_beggar.lua | ternary → if/else | 2 → 0 | 4 (no_money_pre/quest, thanks_pre/quest) |
| captain_haba_open_sea.lua | random messages table → keys table | 3 → 0 | 15 (straight/starboard/larboard × 5) |
| trisha.lua | config table (message → messageKey) | 3 → 0 | 12 (bones/turtle/spirit/claw × 3) |
| denominator.lua | quiz table (p → pKey) | 3 → 0 | 8 (quiz1 ×4 + quiz2 ×2 + quiz3 ×2) |
| woblin.lua | prosty say → npcSay | 3 → 0 | 3 (say_2/3/4) |
| gnomission.lua | prosty say → npcSay + bug fix | 3 → 0 | 1 (say_12, użyty 3×) |
| riddler.lua | prosty say → npcSay | 5 → 0 | 5 (say_9-13) |

## Zmigrowane pliki scripts/lib

| Plik | Zmiana | Klucze |
|------|--------|--------|
| inbox_command.lua | 2× `:say()` → `sendLocalizedTextMessage()` | 2 |
| bound_astral_power.lua | `creature:say()` → `sayLocalized()` | 1 |
| shargon_heal.lua | `creature:say()` → `sayLocalized()` | 1 |
| demon_oak_voices.lua | 7 voice lines → `sayLocalized()` | 7 |
| hireling.lua | `:say()` + lamp description → `sayLocalized()` + `i18nTranslate()` | 2 |

## Wzorce migracji

### Config table (razan, trisha)
```lua
-- PRZED:
config = { ["item"] = { text = { "string1", "string2", "string3" } } }
npcHandler:say(config[message].text[1], npc, creature)

-- PO:
config = { ["item"] = { textKey = { "npc.X.key1", "npc.X.key2", "npc.X.key3" } } }
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, config[message].textKey[1])
```

### Random messages (captain_haba)
```lua
-- PRZED:
randomMessages = { straight = { "MSG1", "MSG2" } }
npcHandler:say(randomMessages.straight[math.random(#...)], npc, creature)

-- PO:
randomMessageKeys = { straight = { "npc.X.straight_1", "npc.X.straight_2" } }
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, randomMessageKeys.straight[math.random(#...)])
```

### Ternary → if/else (shoddy_beggar)
```lua
-- PRZED:
npcHandler:say(condition and "textA" or "textB", npc, creature)

-- PO:
if condition then
    NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.X.keyA")
else
    NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.X.keyB")
end
```

## Znaleziony bug

**gnomission.lua** — oryginalne wywołania `npcHandler:say("text")` **nie miały argumentów `npc, creature`**. Naprawione przez migrację do `NPC_LIB.i18n.npcSay(npcHandler, npc, creature, key)`.

## Stan kluczy

| Plik JSON | Klucze |
|-----------|--------|
| npc.json | 7554 |
| scripts.json | 1448 |
| npclib.json | 80 |
| cpp.json | 463 |

**Zsynchronizowano:** 9582 kluczy do 54 języków

## Pozostałe `npcHandler:say()`: 118 wywołań

Następne cele: inigo.lua (37 stringów), grizzly_adams.lua (18 calls), hireling NPC (11), mr_morris.lua (10), bozo.lua (7), eruaran.lua (6), cranky_lizard_crone.lua (6), walter_jaeger.lua (dynamiczny).
