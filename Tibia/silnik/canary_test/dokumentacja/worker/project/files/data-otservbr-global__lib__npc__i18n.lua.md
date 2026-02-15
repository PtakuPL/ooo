# data-otservbr-global/lib/npc/i18n.lua

**Kind:** NPC Lua script  
**Size:** 3991 bytes | **Lines:** 154  
**Tags:** `creature`, `event`, `fallback`, `handler`, `i18n`, `i18n:i18n_call`, `key`, `library`, `lua`, `npc`, `player`, `trade`

## Opis funkcjonalny

NPC Lua script — NPC Lua script | 13 symbols | 15 i18n touchpoints | 154 lines

## Symbole

| Nazwa | Typ | Linia |
|---|---|---|
| `defaultPlayerNameArgs` | lua_function | L9 |
| `normalizeArgs` | lua_function | L18 |
| `NPC_LIB.i18n.sayLocalized` | lua_function | L30 |
| `NPC_LIB.i18n.ensureKeyExists` | lua_function | L39 |
| `NPC_LIB.i18n.npcSay` | lua_function | L49 |
| `resolveSequenceEntry` | lua_function | L63 |
| `NPC_LIB.i18n.setLocalizedMessage` | lua_function | L79 |
| `NPC_LIB.i18n.setLocalizedGreet` | lua_function | L96 |
| `NPC_LIB.i18n.setLocalizedFarewell` | lua_function | L102 |
| `NPC_LIB.i18n.setLocalizedWalkaway` | lua_function | L108 |
| `NPC_LIB.i18n.setLocalizedTradeMessage` | lua_function | L114 |
| `NPC_LIB.i18n.npcSayMultiple` | lua_function | L120 |
| `DEFAULT_MESSAGE_CLASS` | lua_variable | L7 |

## i18n Touchpoints

| Typ | Linia | Fragment |
|---|---|---|
| i18n_call | L30 | `function NPC_LIB.i18n.sayLocalized(player, key, args, messageClass)` |
| i18n_call | L39 | `function NPC_LIB.i18n.ensureKeyExists(key)` |
| i18n_call | L48 | `-- Usage: NPC_LIB.i18n.npcSay(npcHandler, npc, creature, key, args)` |
| i18n_call | L49 | `function NPC_LIB.i18n.npcSay(npcHandler, npc, creature, key, args)` |
| i18n_call | L79 | `function NPC_LIB.i18n.setLocalizedMessage(npcHandler, messageId, key, options)` |
| i18n_call | L96 | `function NPC_LIB.i18n.setLocalizedGreet(npcHandler, key, options)` |
| i18n_call | L99 | `return NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, key, options)` |
| i18n_call | L102 | `function NPC_LIB.i18n.setLocalizedFarewell(npcHandler, key, options)` |
| i18n_call | L105 | `return NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, key, options)` |
| i18n_call | L108 | `function NPC_LIB.i18n.setLocalizedWalkaway(npcHandler, key, options)` |
| i18n_call | L111 | `return NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, key, options)` |
| i18n_call | L114 | `function NPC_LIB.i18n.setLocalizedTradeMessage(npcHandler, key, options)` |
| i18n_call | L115 | `return NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, key, options)` |
| i18n_call | L119 | `-- Usage: NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, keys, delay)` |
| i18n_call | L120 | `function NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, keys, delay)` |
