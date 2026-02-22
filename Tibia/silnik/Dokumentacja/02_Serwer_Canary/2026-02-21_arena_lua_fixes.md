# Arena PvP - Naprawa błędów Lua (2026-02-21)

## Problem
Serwer Canary startował z wieloma błędami Lua w skryptach arena:
- `arena_security.lua` - 5x "Invalid EventCallback with name: {}"
- `arena_main.lua` - "invalid escape sequence near 'UPDATE'"
- `arena_on_death.lua` - "Invalid EventCallback with name: {}"
- `arena_security.lua` - "Wrong enum" (configKeys.ARENA_SYSTEM_ENABLED)

## Przyczyna
Skrypty arena używały nieistniejących typów EventCallback w Canary:
- `playerOnSpellCheck` - nie istnieje
- `playerOnItemUse` - nie istnieje  
- `playerOnPartyInvite` - nie istnieje
- `playerOnGainSkullTicks` - nie istnieje
- `playerOnLogout` - nie istnieje
- `playerOnDeath` - nie istnieje

Poprawne typy EventCallback (zdefiniowane w `callbacks_definitions.hpp`):
```
creatureOnChangeOutfit, creatureOnAreaCombat, creatureOnTargetCombat,
creatureOnDrainHealth, creatureOnCombat, partyOnJoin, partyOnLeave,
partyOnDisband, partyOnShareExperience, playerOnBrowseField, playerOnLook,
playerOnLookInBattleList, playerOnLookInTrade, playerOnLookInShop,
playerOnMoveItem, playerOnItemMoved, playerOnChangeZone, playerOnChangeHazard,
playerOnMoveCreature, playerOnReportRuleViolation, playerOnReportBug,
playerOnTurn, playerOnTradeRequest, playerOnTradeAccept,
playerOnGainExperience, playerOnLoseExperience, playerOnGainSkillTries,
playerOnRequestQuestLog, playerOnRequestQuestLine, playerOnStorageUpdate,
playerOnRemoveCount, playerOnCombat, playerOnInventoryUpdate,
playerOnRotateItem, playerOnWalk, playerOnThink, monsterOnDropLoot,
monsterPostDropLoot, zoneBeforeCreatureEnter, zoneBeforeCreatureLeave,
zoneAfterCreatureEnter, zoneAfterCreatureLeave, mapOnLoad
```

## Naprawy

### arena_security.lua
| Sekcja | Było | Jest |
|--------|------|------|
| Blokada spelli | `playerOnSpellCheck` (nie istnieje) | Usunięte, TODO na przyszłość |
| Blokada itemów | `playerOnItemUse` (nie istnieje) | `playerOnMoveItem` (blokuje przenoszenie zakazanych itemów) |
| Blokada party | `playerOnPartyInvite` (nie istnieje) | `partyOnJoin` (blokuje dołączanie do party w arenie) |
| AFK Tracker | `playerOnMoveCreature` ✓ | Bez zmian (działał) |
| AFK Combat | `creatureOnTargetCombat` ✓ | Bez zmian (działał) |
| Blokada skull | `playerOnGainSkullTicks` (nie istnieje) | Zamienione na `playerOnLoseExperience` (blokuje utratę exp) |
| Blokada logout | `playerOnLogout` (nie istnieje) | Usunięte (C++ obsługuje logout) |
| Config check | `configKeys.ARENA_SYSTEM_ENABLED` (nie istnieje) | `ArenaConfig.enabled` (Lua-side flag) |

### arena_main.lua
- SQL string: `\`` → `` ` `` (backtick nie wymaga escapowania w Lua)

### arena_on_death.lua
- `playerOnDeath` (nie istnieje) → `creatureOnDrainHealth` (przechwytuje obrażenia śmiertelne w arenie, uzdrawia gracza zamiast zabijać) + `playerOnLoseExperience` (zapobiega utracie doświadczenia)

### arena.lua (ArenaConfig)
- Dodano pole `enabled = false` jako domyślny wyłącznik systemu arena

## Wynik
- Serwer startuje z **zerem błędów arena** 
- Jedyny pozostały błąd: `bozo.lua:81` (niezwiązane z areną)
- Commit: `217d34066`
- Serwer wyświetla przy zamykaniu: `[Arena] Shutting down - 0 active matches`

## Do zrobienia w przyszłości
- Dodanie C++ EventCallback types: `playerOnSpellCheck`, `playerOnUseItem` dla pełnej blokady spelli i itemów w arenie
- Ustawienie `ArenaConfig.enabled = true` gdy system C++ ArenaSystem będzie gotowy
