# PRE_MIGRATION TODO: documentation

- Generated: `2026-02-15T17:11:59.686693Z`
- Files scanned: **942**
- Files with hits: **934**
- Hits: **12230**

| File | Line | Pattern | Text |
|---|---:|---|---|
| `data-canary/migrations/README.md` | 3 | `docs.paragraph` | This document provides an overview of the current database migration system for the project. The migration process has been streamlined to ensure that all migration scripts are automatically applied in order, making it easier to maintain database updates. |
| `data-canary/migrations/README.md` | 7 | `docs.paragraph` | The migration system is designed to apply updates to the database schema or data whenever a new server version is started. Migration scripts are stored in the `migrations` directory, and the system will automatically apply any scripts that have not yet been executed. |
| `data-canary/migrations/README.md` | 12 | `docs.bullet` | The system first retrieves the current version of the database using `getDatabaseVersion()`. |
| `data-canary/migrations/README.md` | 13 | `docs.bullet` | This version is used to determine which migration scripts need to be executed. |
| `data-canary/migrations/README.md` | 16 | `docs.bullet` | All migration scripts are stored in the `migrations` directory. |
| `data-canary/migrations/README.md` | 17 | `docs.bullet` | Each migration script is named using a numerical pattern, such as `1.lua`, `2.lua`, etc. |
| `data-canary/migrations/README.md` | 18 | `docs.bullet` | The naming convention helps determine the order in which scripts should be applied. |
| `data-canary/migrations/README.md` | 21 | `docs.bullet` | The migration system iterates through the migration directory and applies each migration script that has a version greater than the current database version. |
| `data-canary/migrations/README.md` | 22 | `docs.bullet` | Only scripts that have not been applied are executed. |
| `data-canary/migrations/README.md` | 23 | `docs.bullet` | The Lua state (`lua_State* L`) is initialized to run each script. |
| `data-canary/migrations/README.md` | 26 | `docs.bullet` | After each migration script is successfully applied, the system updates the database version to reflect the applied change. |
| `data-canary/migrations/README.md` | 27 | `docs.bullet` | This ensures that the script is not re-applied on subsequent server startups. |
| `data-canary/migrations/README.md` | 31 | `docs.paragraph` | Below is an example of what a migration script might look like. Note that no return value is required, as all migration files are applied based on the current database version. |
| `data-otservbr-global/migrations/README.md` | 3 | `docs.paragraph` | This document provides an overview of the current database migration system for the project. The migration process has been streamlined to ensure that all migration scripts are automatically applied in order, making it easier to maintain database updates. |
| `data-otservbr-global/migrations/README.md` | 7 | `docs.paragraph` | The migration system is designed to apply updates to the database schema or data whenever a new server version is started. Migration scripts are stored in the `migrations` directory, and the system will automatically apply any scripts that have not yet been executed. |
| `data-otservbr-global/migrations/README.md` | 12 | `docs.bullet` | The system first retrieves the current version of the database using `getDatabaseVersion()`. |
| `data-otservbr-global/migrations/README.md` | 13 | `docs.bullet` | This version is used to determine which migration scripts need to be executed. |
| `data-otservbr-global/migrations/README.md` | 16 | `docs.bullet` | All migration scripts are stored in the `migrations` directory. |
| `data-otservbr-global/migrations/README.md` | 17 | `docs.bullet` | Each migration script is named using a numerical pattern, such as `1.lua`, `2.lua`, etc. |
| `data-otservbr-global/migrations/README.md` | 18 | `docs.bullet` | The naming convention helps determine the order in which scripts should be applied. |
| `data-otservbr-global/migrations/README.md` | 21 | `docs.bullet` | The migration system iterates through the migration directory and applies each migration script that has a version greater than the current database version. |
| `data-otservbr-global/migrations/README.md` | 22 | `docs.bullet` | Only scripts that have not been applied are executed. |
| `data-otservbr-global/migrations/README.md` | 23 | `docs.bullet` | The Lua state (`lua_State* L`) is initialized to run each script. |
| `data-otservbr-global/migrations/README.md` | 26 | `docs.bullet` | After each migration script is successfully applied, the system updates the database version to reflect the applied change. |
| `data-otservbr-global/migrations/README.md` | 27 | `docs.bullet` | This ensures that the script is not re-applied on subsequent server startups. |
| `data-otservbr-global/migrations/README.md` | 31 | `docs.paragraph` | Below is an example of what a migration script might look like. Note that no return value is required, as all migration files are applied based on the current database version. |
| `data-otservbr-global/startup/README.md` | 1 | `docs.paragraph` | Reserved action/unique for tables: |
| `data-otservbr-global/startup/README.md` | 4 | `docs.paragraph` | The defined range is from 1000/1999 |
| `data-otservbr-global/startup/README.md` | 5 | `docs.paragraph` | Since the three numbers after 1 determine the level |
| `data-otservbr-global/startup/README.md` | 10 | `docs.paragraph` | Chest (action) = 5000/12000 |
| `data-otservbr-global/startup/README.md` | 11 | `docs.paragraph` | Chest (unique) = 5000/12000 |
| `data-otservbr-global/startup/README.md` | 12 | `docs.paragraph` | Chests custom (action) 12001/15000 |
| `data-otservbr-global/startup/README.md` | 13 | `docs.paragraph` | Chests custom (unique) 12001/15000 |
| `data-otservbr-global/startup/README.md` | 14 | `docs.paragraph` | Reward keys = 5000/6000 |
| `data-otservbr-global/startup/README.md` | 16 | `docs.paragraph` | TeleportItem (action) = 15001/20000 (this is teleport items, not magic forcefield) |
| `data-otservbr-global/startup/README.md` | 17 | `docs.paragraph` | TeleportItem (unique) = 15001/20000 (this is teleport items, not magic forcefield) |
| `data-otservbr-global/startup/README.md` | 19 | `docs.paragraph` | Corpse (action)= 20000/25000 |
| `data-otservbr-global/startup/README.md` | 20 | `docs.paragraph` | Corpse (unique) = 20000/22000 |
| `data-otservbr-global/startup/README.md` | 22 | `docs.paragraph` | DoorStorage (action) = It is not defined, because it uses storages as action |
| `data-otservbr-global/startup/README.md` | 23 | `docs.paragraph` | DoorStorage (unique) = 22001/25000 |
| `data-otservbr-global/startup/README.md` | 25 | `docs.paragraph` | Tile (action) = 25001/29000 |
| `data-otservbr-global/startup/README.md` | 26 | `docs.paragraph` | Tile (unique) = 25001/29000 |
| `data-otservbr-global/startup/README.md` | 27 | `docs.paragraph` | Tile remove/create item (action) = 29001/30000 |
| `data-otservbr-global/startup/README.md` | 28 | `docs.paragraph` | Tile remove/create item (unique) = 29001/30000 |
| `data-otservbr-global/startup/README.md` | 30 | `docs.paragraph` | Lever (action) = 30001/35000 |
| `data-otservbr-global/startup/README.md` | 31 | `docs.paragraph` | Lever (unique) = 30001/35000 |
| `data-otservbr-global/startup/README.md` | 33 | `docs.paragraph` | Teleport (action) = 35001/40000 (this is magic forcefield items) |
| `data-otservbr-global/startup/README.md` | 34 | `docs.paragraph` | Teleport (unique) = 35001/40000 (this is magic forcefield items) |
| `data-otservbr-global/startup/README.md` | 36 | `docs.paragraph` | Item (action) = 40001/42000 |
| `data-otservbr-global/startup/README.md` | 37 | `docs.paragraph` | Item (unique) = 40001/42000 |
| `data-otservbr-global/startup/README.md` | 39 | `docs.paragraph` | This folder was created exclusively for tables and functions that are loaded at startup or that cannot be reloaded, thus maintaining greater organization in the files. |
| `data-otservbr-global/startup/README.md` | 42 | `docs.paragraph` | Use actionID only if you need to create a function that is called multiple times in different locations. |
| `data-otservbr-global/startup/README.md` | 43 | `docs.paragraph` | The action is also used as storage, "x" storage is added in the player, |
| `data-otservbr-global/world/quest/cults_of_tibia/misguided/README.md` | 4 | `docs.paragraph` | In the Cults of Tibia Quest in The Misguided Cult, their hunting ground is deceptive showing richness all around as the quest progress the player can see what is the true reality. |
| `data-otservbr-global/world/quest/cults_of_tibia/misguided/README.md` | 13 | `docs.paragraph` | The hunting ground is beautiful with marble walls and gold around the floor. |
| `data-otservbr-global/world/quest/cults_of_tibia/misguided/README.md` | 20 | `docs.paragraph` | The illusion is gone, the hunting ground is dirt with multiple leaves, dirt ground and walls made of wood. |
| `data-otservbr-global/world/quest/ferumbras_ascendant/README.md` | 4 | `docs.paragraph` | Used to reset to their original view after being corrupted during the puzzle. |
| `data-otservbr-global/world/quest/soul_war/ebb_and_flow/README.md` | 3 | `docs.paragraph` | Ebb and Flow hunting grounds inside the Soul War Quest, have an interesting behavior the map changes every 2 minutes, the main part of the hunt is on the official map and in this folder, we have two different maps |
| `data-otservbr-global/world/quest/soul_war/ebb_and_flow/README.md` | 11 | `docs.paragraph` | The empty version is where the hunting grounds are available. |
| `data-otservbr-global/world/quest/soul_war/ebb_and_flow/README.md` | 19 | `docs.paragraph` | The inundate map where the hunting grounds are unavailable and everyone on the hunting ground will be teleported to the entrance |
| `data-otservbr-global/world/world_changes/full_moon/README.md` | 3 | `docs.paragraph` | During this World Change that usually happens between 12, 13 and 14 of each month it is possible to challenge the Boss Feroxa during the Grimvale quest. |
| `data-otservbr-global/world/world_changes/full_moon/README.md` | 6 | `docs.paragraph` | During the boss fight, the arena will change as the battle progress. |
| `data/modules/scripts/gamestore/readme.md` | 11 | `docs.paragraph` | GameStore.Categories = { |
| `data/modules/scripts/gamestore/readme.md` | 20 | `docs.paragraph` | GameStore.Categories = { |
| `data/modules/scripts/gamestore/readme.md` | 28 | `docs.paragraph` | GameStore.Categories = { |
| `data/modules/scripts/gamestore/readme.md` | 37 | `docs.paragraph` | GameStore.Categories = { |
| `data/modules/scripts/gamestore/readme.md` | 49 | `docs.paragraph` | GameStore.Categories = { |
| `data/modules/scripts/gamestore/readme.md` | 59 | `docs.table_cell` | Method |
| `data/modules/scripts/gamestore/readme.md` | 59 | `docs.table_cell` | Usage |
| `data/modules/scripts/gamestore/readme.md` | 61 | `docs.table_cell` | name* |
| `data/modules/scripts/gamestore/readme.md` | 61 | `docs.table_cell` | the category name |
| `data/modules/scripts/gamestore/readme.md` | 62 | `docs.table_cell` | description |
| `data/modules/scripts/gamestore/readme.md` | 62 | `docs.table_cell` | the category description |
| `data/modules/scripts/gamestore/readme.md` | 63 | `docs.table_cell` | state |
| `data/modules/scripts/gamestore/readme.md` | 63 | `docs.table_cell` | the category highlight state |
| `data/modules/scripts/gamestore/readme.md` | 64 | `docs.table_cell` | icons* |
| `data/modules/scripts/gamestore/readme.md` | 64 | `docs.table_cell` | the icons for the category |
| `data/modules/scripts/gamestore/readme.md` | 65 | `docs.table_cell` | offers(*) |
| `data/modules/scripts/gamestore/readme.md` | 65 | `docs.table_cell` | the category offers |
| `data/modules/scripts/gamestore/readme.md` | 79 | `docs.table_cell` | Method |
| `data/modules/scripts/gamestore/readme.md` | 79 | `docs.table_cell` | Usage |
| `data/modules/scripts/gamestore/readme.md` | 81 | `docs.table_cell` | name* |
| `data/modules/scripts/gamestore/readme.md` | 81 | `docs.table_cell` | the offer name |
| `data/modules/scripts/gamestore/readme.md` | 82 | `docs.table_cell` | description |
| `data/modules/scripts/gamestore/readme.md` | 82 | `docs.table_cell` | the offer descrioption |
| `data/modules/scripts/gamestore/readme.md` | 83 | `docs.table_cell` | the id of the choosed type ( itemId or mountId or outfitLookType, ....) |
| `data/modules/scripts/gamestore/readme.md` | 83 | `docs.table_cell` | thingId* |
| `data/modules/scripts/gamestore/readme.md` | 84 | `docs.table_cell` | the type of the offer, item or mount or outfit or ... |
| `data/modules/scripts/gamestore/readme.md` | 84 | `docs.table_cell` | type* |
| `data/modules/scripts/gamestore/readme.md` | 85 | `docs.table_cell` | price* |
| `data/modules/scripts/gamestore/readme.md` | 85 | `docs.table_cell` | the offer price |
| `data/modules/scripts/gamestore/readme.md` | 86 | `docs.table_cell` | state |
| `data/modules/scripts/gamestore/readme.md` | 86 | `docs.table_cell` | the offer highlight state |
| `data/modules/scripts/gamestore/readme.md` | 87 | `docs.table_cell` | icons* |
| `data/modules/scripts/gamestore/readme.md` | 87 | `docs.table_cell` | the icons for the category |
| `data/modules/scripts/gamestore/readme.md` | 88 | `docs.table_cell` | disabled |
| `data/modules/scripts/gamestore/readme.md` | 88 | `docs.table_cell` | dynamically disable the offer |
| `data/modules/scripts/gamestore/readme.md` | 89 | `docs.table_cell` | disabledReason |
| `data/modules/scripts/gamestore/readme.md` | 89 | `docs.table_cell` | reason for being disabled ( use when disabled is true ) |
| `data/modules/scripts/gamestore/readme.md` | 111 | `docs.table_cell` | OfferTypes |
| `data/modules/scripts/gamestore/readme.md` | 113 | `docs.table_cell` | `OFFER_TYPE_ITEM` |
| `data/modules/scripts/gamestore/readme.md` | 114 | `docs.table_cell` | `OFFER_TYPE_OUTFIT` |
| `data/modules/scripts/gamestore/readme.md` | 115 | `docs.table_cell` | `OFFER_TYPE_OUTFIT_ADDON` |
| `data/modules/scripts/gamestore/readme.md` | 116 | `docs.table_cell` | `OFFER_TYPE_MOUNT` |
| `data/modules/scripts/gamestore/readme.md` | 117 | `docs.table_cell` | `OFFER_TYPE_NAMECHANGE` |
| `data/modules/scripts/gamestore/readme.md` | 118 | `docs.table_cell` | `OFFER_TYPE_SEXCHANGE` |
| `data/modules/scripts/gamestore/readme.md` | 119 | `docs.table_cell` | `OFFER_TYPE_PROMOTION` |
| `data/scripts/eventcallbacks/README.md` | 3 | `docs.paragraph` | The `EventCallback` system is a way to dynamically bind C++ functions to be triggered by specific events within the game. It's an elegant and flexible way to add custom behavior to various parts of your application. |
| `data/scripts/eventcallbacks/README.md` | 7 | `docs.paragraph` | Event callbacks are available for several categories of game entities, such as `Creature`, `Player`, `Party`, and `Monster`. |
| `data/scripts/eventcallbacks/README.md` | 11 | `docs.bullet` | `(bool)`: The function should return a boolean value (`true` or `false`). The return value can affect the program flow on the C++ side. For example, if the function returns `false`, the execution of the associated function on the C++ side is immediately stopped. |
| `data/scripts/eventcallbacks/README.md` | 12 | `docs.bullet` | `(void)`: The function does not return any value. It just performs an action and then terminates. |
| `data/scripts/eventcallbacks/README.md` | 16 | `docs.bullet` | `(bool)` `creatureOnChangeOutfit` |
| `data/scripts/eventcallbacks/README.md` | 17 | `docs.bullet` | `(ReturnValue)` `creatureOnAreaCombat` |
| `data/scripts/eventcallbacks/README.md` | 18 | `docs.bullet` | `(ReturnValue)` `creatureOnTargetCombat` |
| `data/scripts/eventcallbacks/README.md` | 19 | `docs.bullet` | `(void)` `creatureOnDrainHealth` |
| `data/scripts/eventcallbacks/README.md` | 20 | `docs.bullet` | `(void)` `creatureOnCombat` |
| `data/scripts/eventcallbacks/README.md` | 21 | `docs.bullet` | `(bool)` `partyOnJoin` |
| `data/scripts/eventcallbacks/README.md` | 22 | `docs.bullet` | `(bool)` `partyOnLeave` |
| `data/scripts/eventcallbacks/README.md` | 23 | `docs.bullet` | `(bool)` `partyOnDisband` |
| `data/scripts/eventcallbacks/README.md` | 24 | `docs.bullet` | `(void)` `partyOnShareExperience` |
| `data/scripts/eventcallbacks/README.md` | 25 | `docs.bullet` | `(bool)` `playerOnBrowseField` |
| `data/scripts/eventcallbacks/README.md` | 26 | `docs.bullet` | `(void)` `playerOnLook` |
| `data/scripts/eventcallbacks/README.md` | 27 | `docs.bullet` | `(void)` `playerOnLookInBattleList` |
| `data/scripts/eventcallbacks/README.md` | 28 | `docs.bullet` | `(void)` `playerOnLookInTrade` |
| `data/scripts/eventcallbacks/README.md` | 29 | `docs.bullet` | `(bool)` `playerOnLookInShop` |
| `data/scripts/eventcallbacks/README.md` | 30 | `docs.bullet` | `(bool)` `playerOnMoveItem` |
| `data/scripts/eventcallbacks/README.md` | 31 | `docs.bullet` | `(void)` `playerOnItemMoved` |
| `data/scripts/eventcallbacks/README.md` | 32 | `docs.bullet` | `(void)` `playerOnChangeZone` |
| `data/scripts/eventcallbacks/README.md` | 33 | `docs.bullet` | `(void)` `playerOnChangeHazard` |
| `data/scripts/eventcallbacks/README.md` | 34 | `docs.bullet` | `(bool)` `playerOnMoveCreature` |
| `data/scripts/eventcallbacks/README.md` | 35 | `docs.bullet` | `(void)` `playerOnReportRuleViolation` |
| `data/scripts/eventcallbacks/README.md` | 36 | `docs.bullet` | `(void)` `playerOnReportBug` |
| `data/scripts/eventcallbacks/README.md` | 37 | `docs.bullet` | `(bool)` `playerOnTurn` |
| `data/scripts/eventcallbacks/README.md` | 38 | `docs.bullet` | `(bool)` `playerOnTradeRequest` |
| `data/scripts/eventcallbacks/README.md` | 39 | `docs.bullet` | `(bool)` `playerOnTradeAccept` |
| `data/scripts/eventcallbacks/README.md` | 40 | `docs.bullet` | `(void)` `playerOnGainExperience` |
| `data/scripts/eventcallbacks/README.md` | 41 | `docs.bullet` | `(void)` `playerOnLoseExperience` |
| `data/scripts/eventcallbacks/README.md` | 42 | `docs.bullet` | `(void)` `playerOnGainSkillTries` |
| `data/scripts/eventcallbacks/README.md` | 43 | `docs.bullet` | `(void)` `playerOnRemoveCount` |
| `data/scripts/eventcallbacks/README.md` | 44 | `docs.bullet` | `(void)` `playerOnRequestQuestLog` |
| `data/scripts/eventcallbacks/README.md` | 45 | `docs.bullet` | `(void)` `playerOnRequestQuestLine` |
| `data/scripts/eventcallbacks/README.md` | 46 | `docs.bullet` | `(void)` `playerOnStorageUpdate` |
| `data/scripts/eventcallbacks/README.md` | 47 | `docs.bullet` | `(void)` `playerOnCombat` |
| `data/scripts/eventcallbacks/README.md` | 48 | `docs.bullet` | `(void)` `playerOnInventoryUpdate` |
| `data/scripts/eventcallbacks/README.md` | 49 | `docs.bullet` | `(bool)` `playerOnRotateItem` |
| `data/scripts/eventcallbacks/README.md` | 50 | `docs.bullet` | `(void)` `playerOnWalk` |
| `data/scripts/eventcallbacks/README.md` | 51 | `docs.bullet` | `(void)` `monsterOnDropLoot` |
| `data/scripts/eventcallbacks/README.md` | 52 | `docs.bullet` | `(void)` `monsterPostDropLoot` |
| `data/scripts/eventcallbacks/README.md` | 56 | `docs.paragraph` | To use the `EventCallback` system, you first need to create an instance of `EventCallback`, then define the functions you want to trigger on specific events. Once done, register your callback to make it active. |
| `data/scripts/eventcallbacks/README.md` | 58 | `docs.paragraph` | Below are examples for each category of game entities: |
| `data/scripts/eventcallbacks/README.md` | 111 | `docs.paragraph` | Some event callbacks are expected to return a boolean value. The return value plays a crucial role in determining the flow of the program on the C++ side. |
| `data/scripts/eventcallbacks/README.md` | 113 | `docs.paragraph` | If the callback returns `false`, the execution of the associated function on the C++ side is stopped immediately. This allows you to use Lua scripting to introduce custom conditions for the execution of C++ functions. |
| `data/scripts/eventcallbacks/README.md` | 115 | `docs.paragraph` | Here is an example of a boolean event callback: |
| `data/scripts/eventcallbacks/README.md` | 135 | `docs.paragraph` | Some event callbacks are expected to return a enum value, in this case, the enum ReturnValue. If the return is different of RETURNVALUE_NOERROR, it will stop the execution of the next callbacks. |
| `data/scripts/eventcallbacks/README.md` | 137 | `docs.paragraph` | Here is an example of a ReturnValue event callback: |
| `data/scripts/eventcallbacks/README.md` | 160 | `docs.paragraph` | You can define multiple callbacks for the same event type. This allows you to encapsulate different behaviors in separate callbacks, making your code more modular and easier to manage. |
| `data/scripts/eventcallbacks/README.md` | 162 | `docs.paragraph` | It also allows you to use the same callback in different parts of your Lua scripts. All the registered callbacks for a specific event are triggered when that event occurs. |
| `data/scripts/eventcallbacks/README.md` | 164 | `docs.paragraph` | Here is an example of defining multiple callbacks for the creatureOnAreaCombat event: |
| `docs/AI_AGENT_INTEGRATION.md` | 9 | `docs.paragraph` | System i18n został zaprojektowany z myślą o współpracy z AI agentami: |
| `docs/AI_AGENT_INTEGRATION.md` | 67 | `docs.bullet` | LIVE musi zawsze zawierać: `phase`, `stage`, `category`, `file`, `message`, `progress`, `eta_seconds`. |
| `docs/AI_AGENT_INTEGRATION.md` | 68 | `docs.bullet` | AI nie ma zgadywać na podstawie logów — status ma być jednoznaczny. |
| `docs/AI_AGENT_INTEGRATION.md` | 70 | `docs.paragraph` | Kanoniczny plan statusów: `docs/i18n/STATUS_AND_DASHBOARD_PLAN.md` |
| `docs/AI_AGENT_INTEGRATION.md` | 82 | `docs.table_cell` | sort) <(jq -r 'keys[]' i18n/pl/npc.json |
| `docs/AI_AGENT_INTEGRATION.md` | 87 | `docs.paragraph` | Gdy znajdziesz problem: |
| `docs/AI_AGENT_INTEGRATION.md` | 189 | `docs.bullet` | [ ] Sprawdź poprawność wszystkich plików JSON |
| `docs/AI_AGENT_INTEGRATION.md` | 190 | `docs.bullet` | [ ] Zweryfikuj składnię Lua w zmodyfikowanych plikach |
| `docs/AI_AGENT_INTEGRATION.md` | 191 | `docs.bullet` | [ ] Znajdź brakujące tłumaczenia |
| `docs/AI_AGENT_INTEGRATION.md` | 194 | `docs.bullet` | [ ] Przejrzyj ostatnio dodane klucze |
| `docs/AI_AGENT_INTEGRATION.md` | 195 | `docs.bullet` | [ ] Sprawdź spójność tłumaczeń |
| `docs/AI_AGENT_INTEGRATION.md` | 196 | `docs.bullet` | [ ] Zidentyfikuj literówki |
| `docs/AI_AGENT_INTEGRATION.md` | 199 | `docs.bullet` | [ ] Zaproponuj lepsze tłumaczenia |
| `docs/AI_AGENT_INTEGRATION.md` | 200 | `docs.bullet` | [ ] Zgłoś problematyczne wzorce |
| `docs/AI_AGENT_INTEGRATION.md` | 201 | `docs.bullet` | [ ] Zoptymalizuj klucze i18n |
| `docs/AI_AGENT_INTEGRATION.md` | 202 | `docs.bullet` | [ ] Weryfikuj stabilność compact mappingu (append-only) i brak kolizji |
| `docs/AI_AGENT_INTEGRATION.md` | 218 | `docs.paragraph` | Błędne tłumaczenie / literówka / brakujący klucz |
| `docs/AI_AGENT_INTEGRATION.md` | 251 | `docs.paragraph` | UWAGA: docelowo szczegóły kategorii są w `i18n/status/categories/{category}.json`. |
| `docs/AI_AGENT_INTEGRATION.md` | 269 | `docs.paragraph` | Docelowo worker utrzymuje dzienny plik agregacyjny: |
| `docs/AI_AGENT_INTEGRATION.md` | 270 | `docs.bullet` | `i18n/status/daily/YYYY-MM-DD.json` |
| `docs/AI_AGENT_INTEGRATION.md` | 273 | `docs.bullet` | `i18n/status/ops.jsonl` (zdarzenia) + `i18n/status/errors.jsonl` (błędy) |
| `docs/AI_AGENT_INTEGRATION.md` | 288 | `docs.table_cell` | select(.value == "") |
| `docs/AI_AGENT_INTEGRATION.md` | 301 | `docs.bullet` | **Worker log:** `work_i18n_live.log` |
| `docs/AI_AGENT_INTEGRATION.md` | 302 | `docs.bullet` | **Guardian log:** `/tmp/i18n_guardian.log` |
| `docs/AI_AGENT_INTEGRATION.md` | 304 | `docs.bullet` | **Status page:** `I18N_STATUS.md` |
| `docs/CI_FIXES_2025-12-12.md` | 5 | `docs.paragraph` | Po 2 tygodniach walki z kompilacją, udało się naprawić większość workflow! Ta dokumentacja zawiera wszystkie poprawki wprowadzone w tej sesji. |
| `docs/CI_FIXES_2025-12-12.md` | 20 | `docs.bullet` | Dodano `DEFAULT_LOCALE,` do enum w `config_enums.hpp` (między `DEFAULT_DESPAWNRANGE` a `DEFAULT_PRIORITY`) |
| `docs/CI_FIXES_2025-12-12.md` | 21 | `docs.bullet` | Dodano `loadStringConfig(L, DEFAULT_LOCALE, "defaultLocale", "en");` w `configmanager.cpp` |
| `docs/CI_FIXES_2025-12-12.md` | 121 | `docs.paragraph` | W tej sesji zatrzymano: |
| `docs/CI_FIXES_2025-12-12.md` | 122 | `docs.bullet` | `i18n_guardian.sh` - proces strażnika i18n |
| `docs/CI_FIXES_2025-12-12.md` | 123 | `docs.bullet` | 6x `i18n_worker_simple.sh --continuous 5 10` - procesy workerów |
| `docs/CI_FIXES_2025-12-12.md` | 124 | `docs.bullet` | Wyczyszczono crontab (usunięto guardian i status_pusher) |
| `docs/CI_FIXES_2025-12-12.md` | 132 | `docs.table_cell` | `90832e7e9` |
| `docs/CI_FIXES_2025-12-12.md` | 133 | `docs.table_cell` | `5ae4f7a50` |
| `docs/CI_FIXES_2025-12-12.md` | 134 | `docs.table_cell` | `ac07b4dac` |
| `docs/CI_FIXES_2025-12-12.md` | 135 | `docs.table_cell` | `54468b8a1` |
| `docs/CI_FIXES_2025-12-12.md` | 136 | `docs.table_cell` | `3b5be6e08` |
| `docs/CI_FIXES_2025-12-12.md` | 138 | `docs.table_cell` | `a265b30ab` |
| `docs/CI_FIXES_2025-12-12.md` | 144 | `docs.table_cell` | Workflow |
| `docs/CI_FIXES_2025-12-12.md` | 146 | `docs.table_cell` | **Canary - Build Linux** |
| `docs/CI_FIXES_2025-12-12.md` | 146 | `docs.table_cell` | Poprawione błędy GCC14 |
| `docs/CI_FIXES_2025-12-12.md` | 147 | `docs.table_cell` | **Analysis - SonarCloud (Android)** |
| `docs/CI_FIXES_2025-12-12.md` | 147 | `docs.table_cell` | Wszystkie zależności warunkowe |
| `docs/CI_FIXES_2025-12-12.md` | 148 | `docs.table_cell` | **Analysis - SonarCloud (Linux)** |
| `docs/CI_FIXES_2025-12-12.md` | 149 | `docs.table_cell` | **Analysis - SonarCloud (Windows)** |
| `docs/CI_FIXES_2025-12-12.md` | 150 | `docs.table_cell` | **Windows Build** |
| `docs/CI_FIXES_2025-12-12.md` | 150 | `docs.table_cell` | Build #4305 - 13.12.2025 |
| `docs/CI_FIXES_2025-12-12.md` | 185 | `docs.bullet` | `NotoSans-Regular.ttf` - główny font (obsługuje polskie znaki) |
| `docs/CI_FIXES_2025-12-12.md` | 186 | `docs.bullet` | `NotoSans-Bold.ttf` - bold |
| `docs/CI_FIXES_2025-12-12.md` | 187 | `docs.bullet` | `NotoSansSC-Regular.ttf` - fallback dla CJK |
| `docs/CI_FIXES_2025-12-12.md` | 188 | `docs.bullet` | `NotoNaskhArabic-Regular.ttf` - fallback dla arabskiego |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 3 | `docs.paragraph` | Data aktualizacji: 2025 |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 16 | `docs.bullet` | Dodano `#include <framework/text/Utf8.h>` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 17 | `docs.bullet` | Dodano helpery `unicodeToUpper()`, `unicodeToLower()` z mapowaniami dla: |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 18 | `docs.bullet` | Polskich znaków: ąćęłńóśźż ↔ ĄĆĘŁŃÓŚŹŻ |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 19 | `docs.bullet` | Niemieckich: äöüß ↔ ÄÖÜß |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 20 | `docs.bullet` | Czeskich/Słowackich: čďěňřšťůýž ↔ ČĎĚŇŘŠŤŮÝŽ |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 21 | `docs.bullet` | Przepisano wszystkie trzy funkcje aby konwertować UTF-8 → UTF-32, aplikować konwersję per-codepoint, konwertować z powrotem |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 28 | `docs.bullet` | `src/framework/graphics/bitmapfont.h` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 29 | `docs.bullet` | `src/framework/graphics/bitmapfont.cpp` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 30 | `docs.bullet` | `src/framework/ui/uiwidgettext.cpp` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 35 | `docs.bullet` | Dodano nową metodę `BitmapFont::drawColoredText()`: |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 36 | `docs.bullet` | Konwertuje pozycje bajtowe z `textColors` na pozycje codepointów |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 37 | `docs.bullet` | Dzieli tekst na segmenty kolorowe |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 38 | `docs.bullet` | Renderuje każdy segment osobno z odpowiednim kolorem |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 39 | `docs.bullet` | Zaktualizowano `UIWidget::drawText()` żeby używać `drawColoredText()` gdy są kolory |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 50 | `docs.bullet` | `onStyleApply`: `m_text.length()` → `m_text32.size()` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 51 | `docs.bullet` | `onFocusChange`: `m_text.length()` → `m_text32.size()` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 52 | `docs.bullet` | `onDoubleClick`: `m_text.length()` → `m_text32.size()` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 53 | `docs.bullet` | `drawSelf`: `textLength = m_text.length()` → `textLength = m_text32.size()` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 103 | `docs.table_cell` | `getDrawTextCoords()` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 104 | `docs.table_cell` | `fillTextCoords()` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 105 | `docs.table_cell` | `fillTextColorCoords()` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 106 | `docs.table_cell` | `calculateGlyphsPositions()` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 114 | `docs.bullet` | `drawText()`: TTF branch z `BitmapFont::drawText()`/`drawColoredText()` |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 115 | `docs.bullet` | `updateText()`: TTF branch z `calculateTextRectSize()` która obsługuje TTF |
| `docs/FAZA_2_WYMAGANE_NAPRAWY.md` | 121 | `docs.paragraph` | Wszystkie powyższe naprawy zostały zaimplementowane. Projekt gotowy do kompilacji i testów. |
| `docs/I18N_CHECKLIST_SERVER.md` | 3 | `docs.paragraph` | Szybka lista kontrolna dla wdrażania/weryfikacji wielojęzyczności po stronie serwera. |
| `docs/I18N_CHECKLIST_SERVER.md` | 6 | `docs.bullet` | [ ] Locale dostępne w jednym z katalogów (kolejność): `<DATA_DIRECTORY>/i18n` (dataPackDirectory), `data/i18n`, repo `i18n/`. |
| `docs/I18N_CHECKLIST_SERVER.md` | 7 | `docs.bullet` | [ ] Każdy locale ma spójny układ plików (np. `items.json`, `player.json`, `system.json`, `game.json`, `npcs.json`, `quests.json`). |
| `docs/I18N_CHECKLIST_SERVER.md` | 8 | `docs.bullet` | [ ] `i18n/en/*.json` traktowany jako baza; inne locale synchronizowane względem EN. |
| `docs/I18N_CHECKLIST_SERVER.md` | 11 | `docs.bullet` | [ ] Lista `supportedLocales()` w `src/utils/i18n/translator.cpp` zawiera wszystkie języki wymagane przez klienta (rozszerzona do 50+); w razie dodania nowego języka dodaj katalog i wpis na listę. |
| `docs/I18N_CHECKLIST_SERVER.md` | 12 | `docs.bullet` | [ ] Dodając nowy język, upewnij się, że katalog istnieje i ma minimalny zestaw kluczy bazowych. |
| `docs/I18N_CHECKLIST_SERVER.md` | 15 | `docs.bullet` | [ ] Kolumna `players.locale` istnieje, domyślnie `'en'`; indeks/constraint zgodny z listą języków. |
| `docs/I18N_CHECKLIST_SERVER.md` | 16 | `docs.bullet` | [ ] `config.lua` ma `serverDefaultLocale` (fallback) oraz poprawnie ustawione `dataPackDirectory` (jeśli używane paczki danych). |
| `docs/I18N_CHECKLIST_SERVER.md` | 17 | `docs.bullet` | [ ] Serwer zawsze wysyła/oczekuje UTF-8 w komunikatach do klienta. |
| `docs/I18N_CHECKLIST_SERVER.md` | 20 | `docs.bullet` | [ ] `python tools/export_items_translations.py --locale en --locale <lang>` (items z XML → JSON, uzupełnia klucze). |
| `docs/I18N_CHECKLIST_SERVER.md` | 21 | `docs.bullet` | [ ] `python tools/i18n_extract_messages.py --roots data-otservbr-global src --out build/i18n/messages.json` (zbiera klucze z Lua/C++). |
| `docs/I18N_CHECKLIST_SERVER.md` | 22 | `docs.bullet` | [ ] `python tools/i18n_sync_messages.py --locale <lang> --filename system.json` (synchronizuje bazę EN z ekstraktem do docelowego języka). |
| `docs/I18N_CHECKLIST_SERVER.md` | 23 | `docs.bullet` | [ ] `python tools/i18n_report.py --locales <lang> --csv-dir i18n/reports` (raport pokrycia, status brakujących wpisów). |
| `docs/I18N_CHECKLIST_SERVER.md` | 24 | `docs.bullet` | [ ] `python tools/i18n_pipeline.py --locales pl es pt de` (pełny przepływ extract ➜ sync ➜ items ➜ report, aktualizuje `i18n/reports/` dla QA). |
| `docs/I18N_CHECKLIST_SERVER.md` | 28 | `docs.bullet` | [ ] Locale gracza jest ustawiane/przekazywane (np. z configu klienta lub pola konta) i używane jako pierwszy wybór; fallback do `fallbackLocale` gdy brak klucza. |
| `docs/I18N_CHECKLIST_SERVER.md` | 29 | `docs.bullet` | [ ] Przy formatowaniu tekstu używać placeholderów zgodnych z `fmt` (`{}`), a liczba argumentów odpowiada liczbie placeholderów. |
| `docs/I18N_CHECKLIST_SERVER.md` | 30 | `docs.bullet` | [ ] Do okien dialogowych używać `Player::sendLocalizedMessageDialog` (zastępuje `sendMessageDialog`) dla zgodności z locale gracza. |
| `docs/I18N_CHECKLIST_SERVER.md` | 33 | `docs.bullet` | [ ] Przepuść skrypt(y) raportujące, usuń brakujące klucze lub zaakceptuj fallback. |
| `docs/I18N_CHECKLIST_SERVER.md` | 34 | `docs.bullet` | [ ] Ręczny smoke test: logowanie gracza z locale EN i innym (np. PL), weryfikacja nazw przedmiotów/NPC/system messages. |
| `docs/I18N_CHECKLIST_SERVER.md` | 35 | `docs.bullet` | [ ] Sprawdź logi: brak ostrzeżeń "Missing translation"/"Failed to format translation" po starcie serwera. |
| `docs/I18N_CHECKLIST_SERVER.md` | 38 | `docs.bullet` | Agent (ten PR): dodane testy jednostkowe translatora (`tests/unit/i18n/translator_test.cpp`) oraz checklisty/wytyczne i18n. |
| `docs/I18N_CHECKLIST_SERVER.md` | 39 | `docs.bullet` | Inny agent: pełna internacjonalizacja danych (przedmioty/NPC/questy) i synchronizacja JSON względem EN. |
| `docs/I18N_CHECKLIST_SERVER.md` | 42 | `docs.bullet` | Dodanie nowego locale wymaga: katalogu w `i18n/<lang>`, wpisu w `supportedLocaleList`, danych w DB (jeśli walidujesz), oraz aktualizacji paczek danych (jeśli używane). |
| `docs/I18N_CHECKLIST_SERVER.md` | 43 | `docs.bullet` | Struktury JSON mogą być zagnieżdżone; w runtime dostępne przez kropki (np. `player.condition.poisoned`). |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 17 | `docs.bullet` | Mutex contention przy wielu graczach (200+ × 50 języków) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 18 | `docs.bullet` | Wymaga kompilacji całego serwera C++ z nowymi funkcjami |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 19 | `docs.bullet` | Większe obciążenie CPU/RAM na serwerze |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 20 | `docs.bullet` | Dłuższe pakiety sieciowe (pełne teksty) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 29 | `docs.table_cell` | Obciążenie serwera |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 30 | `docs.table_cell` | Bandwidth |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 31 | `docs.table_cell` | Pamięć serwera |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 32 | `docs.table_cell` | Kompilacja |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 33 | `docs.table_cell` | Skalowalność |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 34 | `docs.table_cell` | Hotfix tłumaczeń |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 39 | `docs.paragraph` | SERWER (canary_test/src/): |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 83 | `docs.bullet` | [ ] **SERWER: Analiza** `sendTextMessage()` w `protocolgame.cpp` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 85 | `docs.bullet` | [ ] **SERWER: Test** kompatybilności wstecznej (stary klient działa) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 86 | `docs.bullet` | [ ] **KLIENT: Analiza** `parseTextMessage()` w `protocolgame.cpp` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 89 | `docs.bullet` | [ ] **KLIENT: Fallback** gdy brak tłumaczenia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 90 | `docs.bullet` | [ ] **TEST: End-to-end** - serwer → klient → wyświetlenie |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 98 | `docs.paragraph` | Worker automatycznie zarządza kategoriami które nie zwracają wyników: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 100 | `docs.table_cell` | Seria zer |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 102 | `docs.table_cell` | Pierwsza próba bez wyników |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 103 | `docs.table_cell` | Druga próba |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 104 | `docs.table_cell` | Trzecia próba |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 105 | `docs.table_cell` | Czwarta próba |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 106 | `docs.table_cell` | Maksymalny czas skip |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 110 | `docs.paragraph` | Kategorie pomijane przez 24h są automatycznie resetowane: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 133 | `docs.table_cell` | `update_category_state(cat, count)` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 134 | `docs.table_cell` | `read_category_state()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 135 | `docs.table_cell` | `should_skip_category(cat, state)` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 146 | `docs.paragraph` | Gdy worker nie ma kategorii do przetwarzania (wszystkie w backoff), przechodzi w |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 212 | `docs.table_cell` | Parametr |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 214 | `docs.table_cell` | Kluczy na cykl |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 214 | `docs.table_cell` | `TRANSLATION_BATCH_SIZE` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 215 | `docs.table_cell` | Prefix dla nieprzetłumaczonych |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 215 | `docs.table_cell` | `UNTRANSLATED_PREFIX` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 216 | `docs.table_cell` | Migracja ma wyższy priorytet |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 216 | `docs.table_cell` | `TRANSLATION_PRIORITY` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 246 | `docs.paragraph` | Po ukończeniu Etapu 1, Etap 2 będzie automatycznie tłumaczył teksty z `[EN]` na docelowy język. |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 254 | `docs.table_cell` | Plik JSON |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 256 | `docs.table_cell` | Dialogi NPC |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 257 | `docs.table_cell` | Głosy potworów |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 258 | `docs.table_cell` | Nazwy przedmiotów |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 259 | `docs.table_cell` | Wiadomości questów |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 260 | `docs.table_cell` | Nazwy zaklęć |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 261 | `docs.table_cell` | Szablony Twig |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 262 | `docs.table_cell` | Wiadomości rajdów |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 263 | `docs.table_cell` | Stringi C++ |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 264 | `docs.table_cell` | **TOTAL** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 268 | `docs.table_cell` | Kategoria |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 268 | `docs.table_cell` | Priorytet |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 271 | `docs.table_cell` | Twig bez trans() |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 271 | `docs.table_cell` | 🟡 ŚREDNI |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 272 | `docs.table_cell` | PHP bez __() |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 272 | `docs.table_cell` | 🟡 ŚREDNI |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 273 | `docs.table_cell` | 🟡 ŚREDNI |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 274 | `docs.table_cell` | Items (pozostałe) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 274 | `docs.table_cell` | W trakcie |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 284 | `docs.table_cell` | **Progresywny backoff** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 284 | `docs.table_cell` | ✅ ZAIMPLEMENTOWANO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 285 | `docs.table_cell` | **consecutive_zeros** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 285 | `docs.table_cell` | ✅ ZAIMPLEMENTOWANO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 286 | `docs.table_cell` | **total_processed** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 286 | `docs.table_cell` | ✅ ZAIMPLEMENTOWANO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 287 | `docs.table_cell` | **Auto-reset 24h** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 287 | `docs.table_cell` | ✅ ZAIMPLEMENTOWANO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 288 | `docs.table_cell` | **Batch zwiększony** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 288 | `docs.table_cell` | ✅ ZAIMPLEMENTOWANO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 289 | `docs.table_cell` | **Pattern scripts** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 289 | `docs.table_cell` | ✅ NAPRAWIONO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 294 | `docs.table_cell` | keywordHandler |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 295 | `docs.table_cell` | +15 kluczy (dragonling_wave, devovorga_curse...) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 296 | `docs.table_cell` | +300+ kluczy (batch=15) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 297 | `docs.table_cell` | 9,810 → 11,400+ (+1,590 kluczy) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 303 | `docs.table_cell` | **Problem zidentyfikowany** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 303 | `docs.table_cell` | ✅ ZDIAGNOZOWANO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 304 | `docs.table_cell` | **Przyczyna** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 304 | `docs.table_cell` | ✅ ZNALEZIONO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 305 | `docs.table_cell` | **Rozwiązanie 1** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 305 | `docs.table_cell` | ✅ ZAIMPLEMENTOWANO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 306 | `docs.table_cell` | **Rozwiązanie 2** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 306 | `docs.table_cell` | ✅ ZAIMPLEMENTOWANO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 307 | `docs.table_cell` | **Rozwiązanie 3** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 307 | `docs.table_cell` | ✅ ZAIMPLEMENTOWANO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 308 | `docs.table_cell` | **Skip mechanizm** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 308 | `docs.table_cell` | ✅ DZIAŁA |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 309 | `docs.table_cell` | **Nowe kategorie** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 309 | `docs.table_cell` | ✅ DODANO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 310 | `docs.table_cell` | **Wynik** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 310 | `docs.table_cell` | ✅ SUKCES |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 313 | `docs.table_cell` | Początek |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 315 | `docs.table_cell` | Total kluczy |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 317 | `docs.table_cell` | Cykli workera |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 320 | `docs.bullet` | `.i18n_category_state.json` - stan kategorii z `skip_until` i `last_processed` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 321 | `docs.bullet` | `update_category_state()` - funkcja bash zapisująca wynik do JSON |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 322 | `docs.bullet` | CATEGORIES dict w Pythonie - dodane priorytety 18-20 dla nowych kategorii |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 337 | `docs.table_cell` | Kategoria |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 339 | `docs.table_cell` | count=1, wszystko zmigrowane |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 340 | `docs.table_cell` | count=0, 92 pliki już przetworzone |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 341 | `docs.table_cell` | count=0, pattern nie pasuje |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 341 | `docs.table_cell` | monsters |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 342 | `docs.table_cell` | count=0, brak danych XML |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 343 | `docs.table_cell` | count=0, brak danych |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 344 | `docs.table_cell` | 🔄 AKTYWNY |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 352 | `docs.table_cell` | **sendTextMessage analiza** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 352 | `docs.table_cell` | ✅ ZBADANO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 356 | `docs.table_cell` | **Twig templates** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 356 | `docs.table_cell` | ✅ ZBADANO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 357 | `docs.table_cell` | **messages.json** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 357 | `docs.table_cell` | ✅ ZROBIONO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 364 | `docs.table_cell` | Callback sprzedaży - JEDEN pattern! |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 364 | `docs.table_cell` | `"Sold %ix %s for %i gold."` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 365 | `docs.table_cell` | Inne unikalne teksty |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 365 | `docs.table_cell` | Różne wiadomości systemowe |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 375 | `docs.table_cell` | **RAZEM** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 381 | `docs.table_cell` | Pliki .twig |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 382 | `docs.table_cell` | Z `trans()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 383 | `docs.table_cell` | Bez tłumaczenia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 384 | `docs.table_cell` | Najczęstsze teksty |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 392 | `docs.table_cell` | **Faza 2 hardcode** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 393 | `docs.table_cell` | **Faza 3 hardcode** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 394 | `docs.table_cell` | **Guard analiza** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 395 | `docs.table_cell` | **Worker targets** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 407 | `docs.table_cell` | **NPC arrays** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 407 | `docs.table_cell` | ✅ +81 kluczy |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 408 | `docs.table_cell` | **NPC voices** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 408 | `docs.table_cell` | ✅ +604 kluczy |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 409 | `docs.table_cell` | **Monster voices** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 409 | `docs.table_cell` | ✅ +4,098 kluczy |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 410 | `docs.table_cell` | **Scripts deep scan** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 410 | `docs.table_cell` | ✅ +290 kluczy |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 411 | `docs.table_cell` | **I18N_STATUS.md** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 412 | `docs.table_cell` | **Worker keys** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 420 | `docs.table_cell` | **RAZEM** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 428 | `docs.table_cell` | **17 kategorii** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 429 | `docs.table_cell` | **worker_commands.txt** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 430 | `docs.table_cell` | **Komendy** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 431 | `docs.table_cell` | **PHP kategoria** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 432 | `docs.table_cell` | **C++ kategoria** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 433 | `docs.table_cell` | **OTClient** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 434 | `docs.table_cell` | **update_github_status** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 437 | `docs.bullet` | 4375 kluczy wyciągniętych |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 438 | `docs.bullet` | 17 kategorii obsługiwanych |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 439 | `docs.bullet` | 26 plików NPC zmigrowanych z transformacją Lua |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 440 | `docs.bullet` | Nowe pliki: `php.json` (8 kluczy), `cpp.json` (15 kluczy) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 446 | `docs.table_cell` | **Multi-category dispatcher** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 447 | `docs.table_cell` | **13 kategorii** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 448 | `docs.table_cell` | **Priorytetyzacja** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 460 | `docs.table_cell` | Plik JSON |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 460 | `docs.table_cell` | Status w I18N_STATUS.md |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 466 | `docs.table_cell` | ❌ BRAK w szczegółach |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 475 | `docs.table_cell` | Kategoria |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 479 | `docs.table_cell` | Ekstrakcja z szablonów Twig |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 485 | `docs.table_cell` | consecutive_zeros |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 486 | `docs.table_cell` | total_processed |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 487 | `docs.table_cell` | skip_until |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 488 | `docs.table_cell` | last_processed |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 531 | `docs.table_cell` | Kategoria |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 531 | `docs.table_cell` | Przetworzono |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 535 | `docs.table_cell` | monsters |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 542 | `docs.paragraph` | TARGETS = {"items": 40000, ...} |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 552 | `docs.table_cell` | Priorytet |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 552 | `docs.table_cell` | Trudność |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 554 | `docs.table_cell` | 1. Dynamiczna lista |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 555 | `docs.table_cell` | 2. Integracja state |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 556 | `docs.table_cell` | 3. Worker Activity |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 557 | `docs.table_cell` | 4. Auto TARGETS |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 567 | `docs.table_cell` | **Tryb TRANSLATION pomijany w background** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 567 | `docs.table_cell` | ❌ DO NAPRAWY |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 568 | `docs.table_cell` | **Brak automatycznego przejścia do dokumentacji** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 568 | `docs.table_cell` | ❌ DO NAPRAWY |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 569 | `docs.table_cell` | **Pliki z konkatenacjami pomijane bez logu** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 569 | `docs.table_cell` | ⚠️ CZĘŚCIOWO |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 575 | `docs.table_cell` | **npcHandler:say z tablicami** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 575 | `docs.table_cell` | ❌ DO ROZBUDOWY |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 576 | `docs.table_cell` | **voices pattern** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 576 | `docs.table_cell` | ❌ WYMAGA C++ |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 577 | `docs.table_cell` | **Brak raportu końcowego** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 577 | `docs.table_cell` | ❌ DO DODANIA |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 581 | `docs.table_cell` | Rozwiązanie |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 583 | `docs.table_cell` | **Bug stage_5 kasujący JSON** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 584 | `docs.table_cell` | **addGreetKeyword/addFarewellKeyword** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 589 | `docs.table_cell` | Co zrobiono |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 591 | `docs.table_cell` | **Worker v3.0 - 17 kategorii** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 592 | `docs.table_cell` | **worker_commands.txt** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 593 | `docs.table_cell` | **Kategoria PHP (html_copy)** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 594 | `docs.table_cell` | **Kategoria HTML/Twig** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 595 | `docs.table_cell` | **Kategoria C++ (src)** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 596 | `docs.table_cell` | **Kategoria Client (testyy)** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 597 | `docs.table_cell` | **Naprawiono update_github_status** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 598 | `docs.table_cell` | **Naprawiono parsing opcji --continuous** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 599 | `docs.table_cell` | **Statystyki: 4375 kluczy** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 605 | `docs.table_cell` | **Zombie procesy** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 605 | `docs.table_cell` | ⚠️ KOSMETYCZNE |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 606 | `docs.table_cell` | **Duplikaty kluczy w JSON** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 606 | `docs.table_cell` | ❌ DO WALIDACJI |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 645 | `docs.bullet` | Definicja w NPC: `npcConfig.voices = { interval=N, chance=N, { text = "...", yell = true/false }, ... }` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 646 | `docs.bullet` | Przetwarzanie Lua: `data/scripts/lib/register_npc_type.lua` → `registerNpcType.voices()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 647 | `docs.bullet` | Przetwarzanie C++: `src/lua/functions/creatures/npc/npc_type_functions.cpp` → `luaNpcTypeAddVoice()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 648 | `docs.bullet` | Odtwarzanie C++: `src/creatures/npcs/npc.cpp` linii 635-644 → `g_game().internalCreatureSay()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 652 | `docs.paragraph` | Tekst jest wysyłany jednocześnie do wielu graczy |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 731 | `docs.bullet` | Modyfikacje C++: 2-4 godziny (voiceBlock_t, npc_type_functions, npc.cpp) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 732 | `docs.bullet` | Modyfikacje Lua: 30 min (register_npc_type.lua) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 733 | `docs.bullet` | Transformacja worker: 1-2 godziny (nowy etap stage_4_voices) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 734 | `docs.bullet` | Testowanie: 1-2 godziny |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 740 | `docs.bullet` | `keywordHandler:addAliasKeyword({"alias"}, callback)` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 743 | `docs.bullet` | Definicja: `data/npclib/npc_system/keyword_handler.lua` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 758 | `docs.table_cell` | `npc.json` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 759 | `docs.table_cell` | `monsters.json` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 760 | `docs.table_cell` | `scripts.json` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 761 | `docs.table_cell` | `messages.json` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 762 | `docs.table_cell` | `cpp.json` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 763 | `docs.table_cell` | `php.json` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 764 | `docs.table_cell` | `startup.json` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 773 | `docs.table_cell` | Tłumaczy? |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 775 | `docs.table_cell` | Zwykły tekst |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 775 | `docs.table_cell` | `player:sendTextMessage(type, text)` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 798 | `docs.table_cell` | Komponent |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 801 | `docs.table_cell` | **Translator C++** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 801 | `docs.table_cell` | Ładowanie JSON, tłumaczenie |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 803 | `docs.table_cell` | **Player implementation** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 803 | `docs.table_cell` | Wysyłanie do klienta |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 804 | `docs.table_cell` | **server_i18n.lua** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 804 | `docs.table_cell` | Alternatywny system (nieużywany) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 851 | `docs.table_cell` | Kategoria |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 851 | `docs.table_cell` | Priorytet |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 853 | `docs.table_cell` | sendTextMessage `"Sold..."` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 853 | `docs.table_cell` | 🔴 WYSOKI (1 sed!) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 855 | `docs.table_cell` | Twig bez trans() |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 856 | `docs.table_cell` | Inne sendTextMessage |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 856 | `docs.table_cell` | 🟡 ŚREDNI |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 880 | `docs.bullet` | ✅ `i18n_worker_simple.sh` - **Worker v3.0** Multi-Mode (17 kategorii!) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 881 | `docs.bullet` | ✅ `worker_commands.txt` - **Sterowanie przez GitHub** (z telefonu!) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 882 | `docs.bullet` | ✅ `i18n_guardian.sh` - Guardian restartujący workera + auto-push |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 883 | `docs.bullet` | ✅ 53 katalogi językowe w `i18n/` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 884 | `docs.bullet` | ✅ Pliki JSON z kluczami (npc.json, scripts.json, monsters.json, php.json, cpp.json, etc.) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 885 | `docs.bullet` | ✅ Cron job dla Guardian |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 886 | `docs.bullet` | ✅ **StdModule.say** - 297/297 plików zmigrowanych (100%) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 887 | `docs.bullet` | ✅ **npcHandler:say("...", npc, creature)** - ~150 plików zmigrowanych |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 888 | `docs.bullet` | ✅ **addGreetKeyword/addFarewellKeyword** - 43/43 plików zmigrowanych (78 kluczy) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 890 | `docs.bullet` | ✅ **4375 kluczy** we wszystkich plikach JSON |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 893 | `docs.table_cell` | Kategoria |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 895 | `docs.table_cell` | data-otservbr-global/npc |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 895 | `docs.table_cell` | 🔄 Aktywna |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 896 | `docs.table_cell` | `scripts` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 896 | `docs.table_cell` | 🔄 Aktywna |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 897 | `docs.table_cell` | `monsters` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 897 | `docs.table_cell` | 🔄 Aktywna |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 898 | `docs.table_cell` | data-otservbr-global/raids |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 899 | `docs.table_cell` | data-otservbr-global/world |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 900 | `docs.table_cell` | `spells` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 901 | `docs.table_cell` | data/items |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 902 | `docs.table_cell` | data/libs |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 903 | `docs.table_cell` | `events` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 904 | `docs.table_cell` | `chatchannels` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 905 | `docs.table_cell` | `modules` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 906 | `docs.table_cell` | `startup` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 906 | `docs.table_cell` | 🔄 Aktywna |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 907 | `docs.table_cell` | `npclib` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 908 | `docs.table_cell` | html_copy/ |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 909 | `docs.table_cell` | html_copy/ |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 911 | `docs.table_cell` | `client` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 925 | `docs.bullet` | ✅ **Krytyczny bug stage_5**: `data = {}` przy błędzie kasowało JSON → zmieniono na `exit(1)` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 926 | `docs.bullet` | ✅ **Regex greet/farewell**: Nie łapał formatu z callbackiem `}, function(player)` → naprawiono |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 927 | `docs.bullet` | ✅ **update_github_status**: Nie liczył nowych kategorii → naprawiono |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 930 | `docs.bullet` | ❌ **voices** - ~300+ plików, wymaga modyfikacji C++ (broadcast → per-player) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 931 | `docs.bullet` | ✅ **npcHandler:say({...})** - tablice tekstów (22 z 24 plików przetworzonych - 265 nowych kluczy) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 932 | `docs.bullet` | ❌ **Automatyczne tłumaczenia** - tryb TRANSLATION wymaga interaktywnego terminala |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 933 | `docs.bullet` | ❌ **Scripts z wieloliniowymi sendTextMessage** - regex nie łapie multi-line |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 934 | `docs.bullet` | ❌ **Scripts ze zmiennymi** - `sendTextMessage(type, info.msgs[2])` - pominąć lub oznaczyć |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 937 | `docs.table_cell` | Wymaga C++ |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 939 | `docs.table_cell` | `voices = {{ text = }}` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 939 | `docs.table_cell` | 🔶 ŚREDNIA |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 940 | `docs.table_cell` | `npcHandler:say({array})` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 940 | `docs.table_cell` | ✅ **95% GOTOWE** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 941 | `docs.table_cell` | `player:sendTextMessage()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 941 | `docs.table_cell` | 🟡 ŚREDNIA |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 942 | `docs.table_cell` | `scripts - zmienne` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 942 | `docs.table_cell` | 🔴 WYSOKA |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 943 | `docs.table_cell` | `keywordHandler:add*Keyword` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 943 | `docs.table_cell` | ❌ DO ANALIZY |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 947 | `docs.table_cell` | Co zrobiono |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 949 | `docs.table_cell` | **npcHandler:say({...}) konwersja** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 950 | `docs.table_cell` | **Nowy skrypt Python** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 954 | `docs.bullet` | `lynda.lua` - dynamiczne wartości (imiona graczy w ceremonii ślubnej) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 955 | `docs.bullet` | `inigo.lua` - używa zmiennych (`hints[i]`) zamiast stringów |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 958 | `docs.paragraph` | Wiele plików scripts używa: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 971 | `docs.table_cell` | Z tekstami |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 973 | `docs.table_cell` | **npc/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 973 | `docs.table_cell` | 🔄 Częściowo |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 974 | `docs.table_cell` | **scripts/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 974 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 975 | `docs.table_cell` | **monster/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 975 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 976 | `docs.table_cell` | **startup/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 976 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 977 | `docs.table_cell` | **lib/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 977 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 978 | `docs.table_cell` | **migrations/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 978 | `docs.table_cell` | ✅ Nie wymaga |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 984 | `docs.table_cell` | `StdModule.say(text=)` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 985 | `docs.table_cell` | `npcHandler:say("text")` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 985 | `docs.table_cell` | ✅ v2.1 DONE |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 986 | `docs.table_cell` | `npcHandler:say({array})` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 986 | `docs.table_cell` | 🟡 ŚREDNI |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 987 | `docs.table_cell` | `player:sendTextMessage()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 987 | `docs.table_cell` | 🔴 WYSOKI |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 988 | `docs.table_cell` | `voices = {{ text = }}` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 988 | `docs.table_cell` | 🟡 ŚREDNI |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 989 | `docs.table_cell` | `keywordHandler:add*Keyword` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 989 | `docs.table_cell` | 🟡 ŚREDNI |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 993 | `docs.table_cell` | Typ pliku |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 993 | `docs.table_cell` | Z tekstami |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 995 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 996 | `docs.table_cell` | **HTML** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 996 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 997 | `docs.table_cell` | **JavaScript** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 997 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 998 | `docs.table_cell` | **Twig templates** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 998 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1002 | `docs.table_cell` | Z tekstami |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1004 | `docs.table_cell` | **scripts/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1004 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1005 | `docs.table_cell` | **libs/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1005 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1006 | `docs.table_cell` | **modules/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1006 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1007 | `docs.table_cell` | **chatchannels/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1007 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1008 | `docs.table_cell` | **npclib/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1008 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1009 | `docs.table_cell` | **events/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1009 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1013 | `docs.table_cell` | Z stringami |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1015 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1016 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1020 | `docs.table_cell` | Z tekstami |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1022 | `docs.table_cell` | **monster/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1022 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1023 | `docs.table_cell` | **scripts/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1023 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1024 | `docs.table_cell` | **npc/** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1024 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1028 | `docs.table_cell` | Z tekstami |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1030 | `docs.table_cell` | **Lua/OTUI/OTMOD** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1030 | `docs.table_cell` | ❌ Do zrobienia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1039 | `docs.bullet` | Format: `npcHandler:say("text", npc, creature)` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1040 | `docs.bullet` | Zamiana na: `npcHandler:sayI18n("key", npc, creature)` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1041 | `docs.bullet` | Klucze: `npc.{nazwa}.say_{N}` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1044 | `docs.bullet` | Format: `player:sendTextMessage(TYPE, "text")` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1045 | `docs.bullet` | Zamiana na: `player:sendTextMessageI18n(TYPE, "key")` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1046 | `docs.bullet` | Klucze: `system.{nazwa}.msg_{N}` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1051 | `docs.bullet` | `player:sendTextMessage()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1052 | `docs.bullet` | `creature:say()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1053 | `docs.bullet` | `Game.broadcastMessage()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1054 | `docs.bullet` | Klucze: `scripts.{kategoria}.{nazwa}.msg_{N}` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1059 | `docs.bullet` | `player->sendTextMessage()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1060 | `docs.bullet` | `fmt::format()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1061 | `docs.bullet` | Wymaga: Raportu + ręcznej implementacji |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1062 | `docs.bullet` | Klucze: `cpp.{moduł}.{funkcja}.msg_{N}` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1067 | `docs.bullet` | `echo "text"` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1068 | `docs.bullet` | `$lang['key']` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1069 | `docs.bullet` | Klucze: `web.{strona}.{sekcja}.msg_{N}` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1072 | `docs.bullet` | `{{ 'text' }}` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1073 | `docs.bullet` | Klucze: `web.tpl.{nazwa}.msg_{N}` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1079 | `docs.bullet` | `.otui` files |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1080 | `docs.bullet` | Klucze: `client.{moduł}.{element}` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1086 | `docs.table_cell` | Kategoria |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1086 | `docs.table_cell` | Szacunkowa ilość tekstów |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1088 | `docs.table_cell` | NPC (pozostałe) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1088 | `docs.table_cell` | 🔴 WYSOKI |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1089 | `docs.table_cell` | Scripts Lua |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1089 | `docs.table_cell` | 🟡 ŚREDNI |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1090 | `docs.table_cell` | C++ Server |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1090 | `docs.table_cell` | 🟡 ŚREDNI |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1091 | `docs.table_cell` | PHP Website |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1092 | `docs.table_cell` | Twig Templates |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1093 | `docs.table_cell` | OTClient |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1094 | `docs.table_cell` | **RAZEM** |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1099 | `docs.bullet` | ✅ ~~Worker przetwarza tylko `StdModule.say`~~ - NAPRAWIONE v2.1 |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1100 | `docs.bullet` | ✅ ~~Brak obsługi `npcHandler:say()`~~ - DODANE v2.1 |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1101 | `docs.bullet` | ❌ Brak obsługi `npcHandler:say({tablica})` z wieloma tekstami |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1102 | `docs.bullet` | ❌ Brak obsługi `player:sendTextMessage()` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1103 | `docs.bullet` | ❌ Brak obsługi `voices` i `keywordHandler` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1104 | `docs.bullet` | ❌ Brak parsera PHP/C++/Twig |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1105 | `docs.bullet` | ❌ **Brak automatycznego tłumaczenia** (tryb TRANSLATION wymaga interaktywnego terminala) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1106 | `docs.bullet` | ❌ **Brak automatycznego przejścia** z MIGRATION → TRANSLATION → DOCUMENTATION |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1107 | `docs.bullet` | ❌ Brak walidacji poprawności kodu po modyfikacji |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1108 | `docs.bullet` | ❌ Brak rollback w przypadku błędów |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1122 | `docs.bullet` | Podział plików na partie (batches) po 50-100 plików |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1123 | `docs.bullet` | Uruchomienie N procesów równoległych (np. 4) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1124 | `docs.bullet` | Każdy proces przetwarza swoją partię |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1125 | `docs.bullet` | Synchronizacja wyników do wspólnego pliku JSON |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1126 | `docs.bullet` | Mutex/lock na plikach JSON podczas zapisu |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1130 | `docs.bullet` | 4x szybsze przetwarzanie |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1131 | `docs.bullet` | Lepsze wykorzystanie CPU |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1143 | `docs.bullet` | Przechowywanie hash MD5/SHA256 każdego przetworzonego pliku |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1144 | `docs.bullet` | Plik: .i18n_file_hashes.json |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1145 | `docs.bullet` | Przy każdym cyklu: porównanie hashy |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1146 | `docs.bullet` | Przetwarzanie tylko plików ze zmienionym hashem |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1147 | `docs.bullet` | Obsługa nowych plików (brak hashu = nowy) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1148 | `docs.bullet` | Obsługa usuniętych plików (hash bez pliku = usuń klucze) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1172 | `docs.bullet` | Co 100 plików: zapis checkpoint do .i18n_checkpoint.json |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1173 | `docs.bullet` | Checkpoint zawiera: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1174 | `docs.bullet` | Lista przetworzonych plików |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1175 | `docs.bullet` | Aktualny katalog |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1176 | `docs.bullet` | Liczniki statystyk |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1178 | `docs.bullet` | Przy starcie: sprawdź czy jest checkpoint |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1179 | `docs.bullet` | Jeśli tak: zapytaj o resume lub fresh start |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1180 | `docs.bullet` | Po zakończeniu pełnego cyklu: usuń checkpoint |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1193 | `docs.bullet` | Poziomy logów: DEBUG, INFO, WARN, ERROR, FATAL |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1194 | `docs.bullet` | Rotacja logów (max 10 plików, max 10MB każdy) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1195 | `docs.bullet` | Osobne logi dla różnych komponentów: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1196 | `docs.bullet` | worker.log - główny worker |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1197 | `docs.bullet` | guardian.log - guardian |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1198 | `docs.bullet` | git.log - operacje git |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1199 | `docs.bullet` | errors.log - tylko błędy |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1200 | `docs.bullet` | Format: [TIMESTAMP] [LEVEL] [COMPONENT] Message |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1201 | `docs.bullet` | Opcja: wysyłanie krytycznych błędów na Discord/Telegram |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1216 | `docs.bullet` | Skanowanie plików .cpp i .hpp w src/ |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1217 | `docs.bullet` | Wykrywanie wzorców: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1218 | `docs.bullet` | player->sendTextMessage(MESSAGE_*, "text") |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1219 | `docs.bullet` | fmt::format("text {}", var) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1220 | `docs.bullet` | std::string msg = "text" |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1221 | `docs.bullet` | #define MSG_* "text" |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1222 | `docs.bullet` | Generowanie kluczy: cpp.filename.line_number lub cpp.filename.function.msg_N |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1223 | `docs.bullet` | Tworzenie pliku mapowania: cpp_strings_map.json |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1224 | `docs.bullet` | NIE modyfikowanie kodu C++ automatycznie (tylko raport) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1249 | `docs.bullet` | Skanowanie plików .php |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1250 | `docs.bullet` | Wykrywanie wzorców: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1251 | `docs.bullet` | echo "text" |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1252 | `docs.bullet` | print "text" |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1253 | `docs.bullet` | $msg = "text" |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1254 | `docs.bullet` | define('CONST', 'text') |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1255 | `docs.bullet` | $_['key'] = 'text' |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1256 | `docs.bullet` | Ignorowanie: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1257 | `docs.bullet` | SQL queries |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1258 | `docs.bullet` | Ścieżki plików |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1259 | `docs.bullet` | Zmienne techniczne |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1260 | `docs.bullet` | Generowanie: php.filename.msg_N |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1273 | `docs.bullet` | Skanowanie .html, .tpl, .twig |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1274 | `docs.bullet` | Wykrywanie: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1275 | `docs.bullet` | Tekst między tagami HTML |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1276 | `docs.bullet` | Atrybuty: title="", alt="", placeholder="" |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1277 | `docs.bullet` | Tekst w JavaScript inline |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1278 | `docs.bullet` | Ignorowanie: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1279 | `docs.bullet` | Tagi techniczne |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1280 | `docs.bullet` | Zmienne szablonów |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1281 | `docs.bullet` | Komentarze |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1294 | `docs.bullet` | Skanowanie data/XML/*.xml |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1295 | `docs.bullet` | Wykrywanie atrybutów z tekstem: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1296 | `docs.bullet` | name="..." |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1297 | `docs.bullet` | description="..." |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1298 | `docs.bullet` | text="..." |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1299 | `docs.bullet` | Mapowanie do kluczy: xml.items.item_1234.name |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1312 | `docs.bullet` | Konfiguracja w YAML/JSON: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1317 | `docs.bullet` | regex: 'sendTextMessage\([^,]+,\s*"([^"]+)"' |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1322 | `docs.bullet` | Dynamiczne ładowanie reguł |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1323 | `docs.bullet` | Łatwe dodawanie nowych typów plików |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1338 | `docs.bullet` | Integracja z API tłumaczeń: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1339 | `docs.bullet` | Google Translate API (płatne, wysokiej jakości) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1340 | `docs.bullet` | DeepL API (płatne, bardzo wysokiej jakości) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1341 | `docs.bullet` | LibreTranslate (darmowe, self-hosted) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1342 | `docs.bullet` | Lingva Translate (darmowe) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1343 | `docs.bullet` | Kolejkowanie tłumaczeń (rate limiting) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1344 | `docs.bullet` | Cache tłumaczeń (nie tłumacz tego samego 2x) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1345 | `docs.bullet` | Priorytetyzacja języków (najpierw PL, DE, ES, PT) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1346 | `docs.bullet` | Fallback: jeśli API niedostępne, oznacz jako [NEEDS_TRANSLATION] |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1352 | `docs.paragraph` | TRANSLATION_API=deepl |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1354 | `docs.paragraph` | TRANSLATION_RATE_LIMIT=100 |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1355 | `docs.paragraph` | PRIORITY_LANGUAGES=pl,de,es,pt,fr |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1368 | `docs.bullet` | Baza danych podobnych fraz |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1369 | `docs.bullet` | Przy nowym stringu: szukaj podobnych (fuzzy match) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1370 | `docs.bullet` | Jeśli podobieństwo > 80%: zaproponuj istniejące tłumaczenie |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1371 | `docs.bullet` | Uczenie się z poprawek użytkowników |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1372 | `docs.bullet` | Export/import pamięci (TMX format) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1399 | `docs.bullet` | Plik: i18n/glossary.json |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1400 | `docs.bullet` | Definicje terminów gry: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1401 | `docs.bullet` | "experience points" -> "punkty doświadczenia" (PL) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1402 | `docs.bullet` | "mana" -> "mana" (nie tłumaczymy) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1403 | `docs.bullet` | "hitpoints" -> "punkty życia" |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1404 | `docs.bullet` | Wymuszanie użycia terminów z glosariusza |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1405 | `docs.bullet` | Walidacja: czy tłumaczenie używa właściwych terminów |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1418 | `docs.bullet` | Sprawdzanie czy tłumaczenie zawiera te same zmienne co oryginał: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1419 | `docs.bullet` | %s, %d, %f (printf) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1420 | `docs.bullet` | {0}, {1}, {name} (format strings) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1421 | `docs.bullet` | {{variable}} (Lua) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1422 | `docs.bullet` | Sprawdzanie długości (czy nie za długie dla UI) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1423 | `docs.bullet` | Sprawdzanie znaków specjalnych |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1424 | `docs.bullet` | Raport błędów walidacji |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1429 | `docs.paragraph` | ERROR: pl/npc.json key "npc.john.greeting" |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1447 | `docs.bullet` | Po każdej modyfikacji pliku Lua: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1448 | `docs.bullet` | luac -p filename.lua (sprawdzenie składni) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1449 | `docs.bullet` | Jeśli błąd: rollback do backup, dodaj do excluded |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1450 | `docs.bullet` | Batch testing wszystkich plików co noc |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1451 | `docs.bullet` | Raport błędów składni |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1464 | `docs.bullet` | Uruchomienie serwera w trybie testowym |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1465 | `docs.bullet` | Timeout 30 sekund |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1466 | `docs.bullet` | Sprawdzenie czy: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1467 | `docs.bullet` | Serwer się uruchomił |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1468 | `docs.bullet` | Załadował wszystkie NPC |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1469 | `docs.bullet` | Załadował wszystkie skrypty |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1470 | `docs.bullet` | Brak błędów w logach |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1471 | `docs.bullet` | Jeśli błąd: identyfikacja problematycznego pliku |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1484 | `docs.bullet` | Testy w Lua: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1485 | `docs.bullet` | Test ładowania plików JSON |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1486 | `docs.bullet` | Test funkcji translate(key, lang) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1487 | `docs.bullet` | Test fallback do EN |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1488 | `docs.bullet` | Test zmiennych w stringach |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1489 | `docs.bullet` | Test brakujących kluczy |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1490 | `docs.bullet` | Integracja z CI/CD |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1503 | `docs.bullet` | Snapshot aktualnego stanu (baseline) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1504 | `docs.bullet` | Po zmianach: porównanie z baseline |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1505 | `docs.bullet` | Wykrywanie: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1506 | `docs.bullet` | Usunięte klucze (mogą być używane!) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1507 | `docs.bullet` | Zmienione klucze (czy zamierzone?) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1508 | `docs.bullet` | Nowe klucze bez tłumaczeń |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1509 | `docs.bullet` | Raport różnic |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1524 | `docs.bullet` | Klasa I18nLoader: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1525 | `docs.bullet` | loadTranslations(lang) - ładuje JSON dla języka |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1526 | `docs.bullet` | translate(key, lang) - zwraca tłumaczenie |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1527 | `docs.bullet` | translateFormat(key, lang, args...) - z formatowaniem |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1528 | `docs.bullet` | Cache w pamięci |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1529 | `docs.bullet` | Hot-reload bez restartu serwera |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1530 | `docs.bullet` | Fallback: key -> EN -> zwróć klucz |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1543 | `docs.bullet` | Nowa kolumna w bazie: players.language VARCHAR(5) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1544 | `docs.bullet` | Komenda: /language pl |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1545 | `docs.bullet` | Automatyczne wykrywanie z IP (GeoIP) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1546 | `docs.bullet` | Domyślny język serwera w config.lua |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1559 | `docs.bullet` | GET /api/i18n/{lang} - wszystkie tłumaczenia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1560 | `docs.bullet` | GET /api/i18n/{lang}/{category} - kategoria (npc, items) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1561 | `docs.bullet` | Cache HTTP (ETag, Last-Modified) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1562 | `docs.bullet` | Kompresja gzip |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1563 | `docs.bullet` | Wersjonowanie (?v=1.2.3) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1576 | `docs.bullet` | I18n.translate(key, lang, params) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1577 | `docs.bullet` | I18n.translateForPlayer(player, key, params) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1578 | `docs.bullet` | I18n.setPlayerLanguage(player, lang) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1579 | `docs.bullet` | I18n.getAvailableLanguages() |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1580 | `docs.bullet` | I18n.reload() - przeładowanie bez restartu |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1595 | `docs.bullet` | Dashboard: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1596 | `docs.bullet` | Statystyki (ile przetłumaczono, ile brakuje) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1597 | `docs.bullet` | Wykresy postępu |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1598 | `docs.bullet` | Ostatnie zmiany |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1599 | `docs.bullet` | Lista kluczy: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1600 | `docs.bullet` | Filtrowanie po kategorii, języku, statusie |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1601 | `docs.bullet` | Wyszukiwanie |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1602 | `docs.bullet` | Sortowanie |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1603 | `docs.bullet` | Edytor tłumaczeń: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1604 | `docs.bullet` | Oryginał (EN) obok tłumaczenia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1605 | `docs.bullet` | Podpowiedzi z Translation Memory |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1606 | `docs.bullet` | Walidacja w czasie rzeczywistym |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1607 | `docs.bullet` | Historia zmian: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1608 | `docs.bullet` | Kto, kiedy, co zmienił |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1609 | `docs.bullet` | Możliwość przywrócenia poprzedniej wersji |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1621 | `docs.bullet` | Admin: pełen dostęp |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1622 | `docs.bullet` | Translator: edycja przypisanych języków |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1623 | `docs.bullet` | Reviewer: zatwierdzanie tłumaczeń |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1624 | `docs.bullet` | Viewer: tylko odczyt |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1627 | `docs.bullet` | Przypisanie języków do użytkownika |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1628 | `docs.bullet` | Wymaganie review przed publikacją |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1629 | `docs.bullet` | Blokowanie kluczy (system only) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1643 | `docs.bullet` | JSON (natywny) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1644 | `docs.bullet` | CSV (dla Excel) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1645 | `docs.bullet` | XLIFF (standard lokalizacji) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1646 | `docs.bullet` | PO/POT (gettext) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1647 | `docs.bullet` | TMX (Translation Memory Exchange) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1650 | `docs.bullet` | Export wybranych języków/kategorii |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1651 | `docs.bullet` | Import z walidacją |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1652 | `docs.bullet` | Merge z istniejącymi danymi |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1653 | `docs.bullet` | Raport konfliktów |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1664 | `docs.bullet` | Powiadomienia email/Discord: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1665 | `docs.bullet` | Nowe klucze do tłumaczenia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1666 | `docs.bullet` | Tłumaczenie wymaga review |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1667 | `docs.bullet` | Błędy walidacji |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1669 | `docs.bullet` | DRAFT -> TRANSLATED -> REVIEWED -> PUBLISHED |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1670 | `docs.bullet` | Automatyczne przypisanie do tłumacza |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1671 | `docs.bullet` | Deadline tracking |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1687 | `docs.bullet` | Push do i18n/ |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1688 | `docs.bullet` | Pull Request z zmianami tłumaczeń |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1689 | `docs.bullet` | Scheduled (codziennie o 3:00) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1693 | `docs.bullet` | Sprawdź składnię JSON |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1694 | `docs.bullet` | Sprawdź zmienne w tłumaczeniach |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1695 | `docs.bullet` | Sprawdź duplikaty kluczy |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1698 | `docs.bullet` | Testy jednostkowe |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1699 | `docs.bullet` | Test ładowania na serwerze |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1702 | `docs.bullet` | Generowanie statystyk |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1703 | `docs.bullet` | Update README badges |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1706 | `docs.bullet` | Sync do serwera produkcyjnego |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1707 | `docs.bullet` | Invalidacja cache |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1721 | `docs.bullet` | json-lint: sprawdź składnię JSON |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1722 | `docs.bullet` | i18n-validate: sprawdź zmienne |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1723 | `docs.bullet` | i18n-no-empty: brak pustych tłumaczeń |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1724 | `docs.bullet` | i18n-keys-sorted: klucze posortowane alfabetycznie |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1737 | `docs.bullet` | Przy każdym release: |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1738 | `docs.bullet` | Lista nowych kluczy |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1739 | `docs.bullet` | Lista zmienionych tłumaczeń |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1740 | `docs.bullet` | Statystyki pokrycia na język |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1741 | `docs.bullet` | Format Markdown |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1742 | `docs.bullet` | Automatyczny commit do CHANGELOG_I18N.md |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1756 | `docs.bullet` | Liczba kluczy (total, per language) |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1757 | `docs.bullet` | Procent pokrycia |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1758 | `docs.bullet` | Błędy walidacji |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1759 | `docs.bullet` | Czas przetwarzania workera |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1761 | `docs.paragraph` | Alerty (Discord/Telegram/Email): |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1762 | `docs.bullet` | Worker nie działa > 5 min |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1763 | `docs.bullet` | Błąd składni w JSON |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1764 | `docs.bullet` | Pokrycie spadło poniżej 80% |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1765 | `docs.bullet` | Nowe klucze bez tłumaczeń > 100 |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1774 | `docs.table_cell` | Estymacja |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1776 | `docs.table_cell` | `i18n_incremental_worker.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1777 | `docs.table_cell` | `i18n_lua_syntax_test.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1778 | `docs.table_cell` | `i18n_validator.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1779 | `docs.table_cell` | `i18n_rollback.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1783 | `docs.table_cell` | Estymacja |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1785 | `docs.table_cell` | `i18n_cpp_parser.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1786 | `docs.table_cell` | `i18n_php_parser.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1787 | `docs.table_cell` | `i18n_auto_translator.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1788 | `docs.table_cell` | `i18n_translation_memory.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1789 | `docs.table_cell` | `i18n_glossary_manager.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1793 | `docs.table_cell` | Estymacja |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1795 | `docs.table_cell` | `i18n_parallel_worker.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1796 | `docs.table_cell` | `i18n_checkpoint_manager.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1797 | `docs.table_cell` | `i18n_logger.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1798 | `docs.table_cell` | `i18n_server_test.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1799 | `docs.table_cell` | `i18n_import_export.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1803 | `docs.table_cell` | Estymacja |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1805 | `docs.table_cell` | `i18n_template_parser.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1806 | `docs.table_cell` | `i18n_xml_parser.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1807 | `docs.table_cell` | `i18n_universal_parser.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1808 | `docs.table_cell` | `i18n_regression_test.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1809 | `docs.table_cell` | `i18n_release_notes.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1810 | `docs.table_cell` | `i18n_monitoring.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1817 | `docs.bullet` | [ ] `i18n_incremental_worker.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1818 | `docs.bullet` | [ ] `i18n_lua_syntax_test.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1819 | `docs.bullet` | [ ] `i18n_validator.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1820 | `docs.bullet` | [ ] `i18n_rollback.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1821 | `docs.bullet` | [ ] Testy obecnego systemu |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1824 | `docs.bullet` | [ ] `i18n_cpp_parser.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1825 | `docs.bullet` | [ ] `i18n_php_parser.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1826 | `docs.bullet` | [ ] Dokumentacja wyekstrahowanych stringów C++/PHP |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1827 | `docs.bullet` | [ ] Plan integracji z kodem źródłowym |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1830 | `docs.bullet` | [ ] `i18n_auto_translator.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1831 | `docs.bullet` | [ ] `i18n_translation_memory.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1832 | `docs.bullet` | [ ] `i18n_glossary_manager.sh` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1833 | `docs.bullet` | [ ] Tłumaczenie PL, DE, ES, PT |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1836 | `docs.bullet` | [ ] `src/i18n/i18n_loader.cpp` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1837 | `docs.bullet` | [ ] `src/i18n/player_language.cpp` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1838 | `docs.bullet` | [ ] `data/libs/i18n.lua` |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1839 | `docs.bullet` | [ ] Testy na serwerze testowym |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1842 | `docs.bullet` | [ ] Web UI podstawowy |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1843 | `docs.bullet` | [ ] System ról |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1844 | `docs.bullet` | [ ] Import/Export |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1847 | `docs.bullet` | [ ] GitHub Actions |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1848 | `docs.bullet` | [ ] Pre-commit hooks |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1849 | `docs.bullet` | [ ] Monitoring i alerty |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1850 | `docs.bullet` | [ ] Dokumentacja końcowa |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1858 | `docs.table_cell` | Pokrycie EN |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1859 | `docs.table_cell` | Pokrycie PL |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1860 | `docs.table_cell` | Pokrycie pozostałe |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1861 | `docs.table_cell` | Czas przetwarzania 1 pliku |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1862 | `docs.table_cell` | Błędy składni po modyfikacji |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1863 | `docs.table_cell` | Uptime workera |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1864 | `docs.table_cell` | Czas do tłumaczenia nowego klucza |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1871 | `docs.bullet` | **jq** - przetwarzanie JSON w bash |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1872 | `docs.bullet` | **yq** - przetwarzanie YAML |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1873 | `docs.bullet` | **GNU parallel** - równoległe przetwarzanie |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1874 | `docs.bullet` | **SQLite** - lokalna baza dla Translation Memory |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1875 | `docs.bullet` | **Redis** - cache dla API tłumaczeń |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1876 | `docs.bullet` | **Docker** - izolacja środowiska testowego |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1886 | `docs.bullet` | Stare pliki Lua muszą działać bez i18n |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1887 | `docs.bullet` | Fallback do hardcoded stringów |
| `docs/I18N_DEVELOPMENT_ROADMAP.md` | 1888 | `docs.bullet` | Graceful degradation przy braku tłumaczenia |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 4 | `docs.paragraph` | Domknąć przepływ locale klient |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 5 | `docs.bullet` | był odbierany przez serwer, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 6 | `docs.bullet` | był stosowany przez logikę i18n po stronie serwera, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 7 | `docs.bullet` | był zapisywany i odtwarzany po relogu/restarcie. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 10 | `docs.paragraph` | Zmiany objęły 9 plików kodu/migracji + 1 zmianę nazwy pliku skryptu (z aktywacją). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 20 | `docs.bullet` | Dodano deklaracje: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 21 | `docs.bullet` | `luaPlayerGetLocale(lua_State* L)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 22 | `docs.bullet` | `luaPlayerSetLocale(lua_State* L)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 25 | `docs.paragraph` | Skrypty Lua muszą mieć oficjalne API do odczytu i ustawienia locale gracza. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 33 | `docs.bullet` | Zarejestrowano metody Lua: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 34 | `docs.bullet` | `Player:getLocale()` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 35 | `docs.bullet` | `Player:setLocale(locale)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 36 | `docs.bullet` | Dodano implementacje obu metod: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 37 | `docs.bullet` | `getLocale` zwraca aktualne locale gracza. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 38 | `docs.bullet` | `setLocale` przekazuje wartość do `Player::setLocale(...)` (z normalizacją po stronie C++). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 41 | `docs.paragraph` | Bez tego skrypt od extended opcode nie mógł ustawić locale na obiekcie `Player`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 51 | `docs.bullet` | W `loadPlayerBasicInfo(...)` dodano: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 52 | `docs.bullet` | `player->setLocale(result->getString("locale"));` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 55 | `docs.paragraph` | Po zalogowaniu gracz ma odzyskać locale z bazy, a nie zawsze startować z domyślnego. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 63 | `docs.bullet` | W `savePlayerFirst(...)` dodano zapis kolumny: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 64 | `docs.bullet` | `` `locale` = db.escapeString(player->getLocale()) `` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 67 | `docs.paragraph` | Zmiana języka musi być trwała między sesjami. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 75 | `docs.bullet` | Zmieniono seed `db_version` z `52` na `53`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 76 | `docs.bullet` | W tabeli `players` dodano kolumnę: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 77 | `docs.bullet` | ``locale VARCHAR(5) NOT NULL DEFAULT 'en'`` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 80 | `docs.paragraph` | Nowe instalacje muszą mieć od razu poprawny schemat pod locale. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 88 | `docs.bullet` | Dodano migrację: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 89 | `docs.bullet` | `ALTER TABLE players ADD COLUMN locale VARCHAR(5) NOT NULL DEFAULT 'en' AFTER pronoun` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 92 | `docs.paragraph` | Istniejące bazy (produkcyjne/testowe) muszą dostać nową kolumnę bez ręcznych zmian SQL. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 102 | `docs.bullet` | Plik z prefiksem `#` był wyłączony przez loader skryptów. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 103 | `docs.bullet` | Przeniesiono go do aktywnej nazwy. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 104 | `docs.bullet` | Zmieniono logikę: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 105 | `docs.bullet` | obsługa tylko `opcode == 1` (locale), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 106 | `docs.bullet` | sanitizacja locale (`lower`, usunięcie niedozwolonych znaków, limit 5), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 107 | `docs.bullet` | ustawienie locale przez `player:setLocale(locale)`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 110 | `docs.paragraph` | Serwer musi faktycznie przyjmować locale wysyłane przez klienta i zapisywać je w obiekcie gracza. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 118 | `docs.bullet` | W `onLogin` dodano: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 119 | `docs.bullet` | `player:registerEvent("ExtendedOpcode")` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 122 | `docs.paragraph` | Event `onExtendedOpcode` działa tylko dla gracza z zarejestrowanym eventem. Bez tego pakiet z klienta nie byłby obsłużony. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 133 | `docs.paragraph` | Wynik: locale jest sesyjne i trwałe (persistowane). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 138 | `docs.bullet` | Zweryfikowano diff i spójność ścieżek. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 139 | `docs.bullet` | Nie udało się wykonać kompilacji w tym środowisku (brak `ninja` i poprawnego `VCPKG_ROOT` dla presetów CMake). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 140 | `docs.bullet` | Nie było dostępnego `luac` do lokalnej walidacji składni Lua. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 143 | `docs.paragraph` | Po deployu należy uruchomić serwer tak, by wykonała się migracja `53` (dodanie `players.locale`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 149 | `docs.paragraph` | W kolejnym kroku dopięto stabilność pełnej i18n dla wariantów locale i case |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 155 | `docs.bullet` | Dodano API: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 156 | `docs.bullet` | `Translator::normalizeLocale(std::string locale)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 159 | `docs.paragraph` | Ujednolicenie locale do postaci kanonicznej serwera. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 167 | `docs.bullet` | Dodano canonical mapping locale (w tym aliasy i warianty): |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 168 | `docs.bullet` | `zh_tw`, `zh-TW`, `zh_hant` -> `zh_TW` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 169 | `docs.bullet` | `zh_cn` -> `zh` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 170 | `docs.bullet` | `fil` -> `tl` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 171 | `docs.bullet` | `pt_BR` -> `pt` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 172 | `docs.bullet` | Zaktualizowano listę wspieranych locale: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 173 | `docs.bullet` | dodano `zh_TW` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 174 | `docs.bullet` | zastąpiono `fil` przez `tl` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 175 | `docs.bullet` | `format`, `plural`, `loadLocale`, `isLocaleLoaded`, `setFallbackLocale` korzystają z normalizacji. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 178 | `docs.paragraph` | Naprawa krytycznego przypadku, gdzie `zh_TW` traciło poprawną postać i fallbackowało do EN. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 186 | `docs.bullet` | `Player::setLocale(...)` przełączono na `Translator::normalizeLocale(...)` z fallbackiem do `defaultLocale`/`en`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 189 | `docs.paragraph` | Odrzucenie nieprawidłowych locale i spójna kanonizacja przed zapisem do `players.locale`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 197 | `docs.bullet` | W `parseExtendedOpcode(...)` dodano natywną obsługę opcode `1` (locale): |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 198 | `docs.bullet` | `player->setLocale(buffer)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 201 | `docs.paragraph` | Locale działa nawet gdy event Lua nie zostanie zarejestrowany; mechanizm jest odporny i niezależny od datapacka. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 209 | `docs.bullet` | Dodano `player:registerEvent("ExtendedOpcode")`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 212 | `docs.paragraph` | Zachowanie kompatybilności dla logiki Lua extended opcode po stronie datapacka. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 217 | `docs.bullet` | `tests/unit/utils/locale_normalization_test.cpp` (nowy) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 218 | `docs.bullet` | `tests/unit/utils/CMakeLists.txt` (aktualizacja) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 221 | `docs.bullet` | Dodano testy jednostkowe normalizacji locale (m.in. `zh_TW`, `fil/tl`, `pt_BR`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 224 | `docs.paragraph` | Regresyjna ochrona krytycznej ścieżki i18n. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 235 | `docs.bullet` | `cpp.forge.history_fusion` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 236 | `docs.bullet` | `cpp.forge.history_transfer` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 237 | `docs.bullet` | `cpp.forge.unknown` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 238 | `docs.bullet` | `cpp.forge.convergence_suffix` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 239 | `docs.bullet` | `cpp.forge.tier_plus_one` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 240 | `docs.bullet` | `cpp.forge.unchanged` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 241 | `docs.bullet` | Opisy kosztów w historii forge korzystają z pluralizacji (`tr.plural`) zamiast twardych suffixów: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 242 | `docs.bullet` | `cpp.forge.cores_*` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 243 | `docs.bullet` | `cpp.forge.dust_*` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 244 | `docs.bullet` | W `forgeTransferItemTier(...)` zapisano do historii realne koszty z konfiguracji: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 245 | `docs.bullet` | `history.dustCost` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 246 | `docs.bullet` | `history.coresCost` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 249 | `docs.bullet` | bazowy tekst punktów EXP (`cpp.player.exp_points_*`) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 250 | `docs.bullet` | bonus VIP (`cpp.player.exp_vip_bonus`) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 251 | `docs.bullet` | bonus animus mastery (`cpp.player.exp_animus_bonus`) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 252 | `docs.bullet` | strata EXP (`cpp.player.exp_lost_points_*`) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 253 | `docs.bullet` | znacznik hazardu przez klucz `cpp.game.hazard_tag` (bez hardcoded `" (Hazard)"`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 254 | `docs.bullet` | Komunikaty stash przepięto na pluralizację: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 255 | `docs.bullet` | `cpp.player.stowed_objects_*` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 256 | `docs.bullet` | `cpp.player.moved_objects_*` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 259 | `docs.bullet` | Przygotowanie pełnego pipeline tłumaczeń z EN na wszystkie języki (bez fragmentów EN ukrytych w C++). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 260 | `docs.bullet` | Lepsza jakość językowa dla pluralizacji (różne reguły per locale). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 261 | `docs.bullet` | Zgodność historii forge z rzeczywistymi kosztami serwera (konfiguracja, bez stałych na sztywno). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 269 | `docs.bullet` | Dodano nowe klucze bazowe EN dla wszystkich powyższych ścieżek C++: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 270 | `docs.bullet` | sekcja `cpp.forge.*` (szablony historii, pluralizacja kosztów, fallback unknown), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 271 | `docs.bullet` | sekcja `cpp.player.*` (EXP/plural/suffixy), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 272 | `docs.bullet` | sekcja `cpp.player.*` (pluralizacja stash). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 275 | `docs.paragraph` | EN staje się pełnym źródłem dla masowego tłumaczenia na pozostałe locale. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 280 | `docs.bullet` | Sprawdzono poprawność składni JSON: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 281 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 282 | `docs.bullet` | Wykonano ręczną inspekcję diff i powiązań kluczy i18n w C++. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 283 | `docs.bullet` | Testów nie uruchamiano zgodnie z decyzją projektową (uruchomienie dopiero na GitHub Actions po większym zakresie migracji i18n). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 290 | `docs.bullet` | `src/creatures/players/grouping/party.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 291 | `docs.bullet` | `src/creatures/players/grouping/party.hpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 294 | `docs.bullet` | Dodano helper broadcastu lokalizowanego: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 295 | `docs.bullet` | `Party::broadcastPartyLocalizedMessage(...)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 298 | `docs.bullet` | join/leave/new leader (`cpp.party.member_joined`, `cpp.party.member_left`, `cpp.party.new_leader`) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 299 | `docs.bullet` | invite/revoke (`cpp.party.invited_*`, `cpp.party.invitation_revoked_*`) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 300 | `docs.bullet` | statusy shared exp (`cpp.party.shared_exp_*`) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 304 | `docs.bullet` | Usunięcie twardych EN z krytycznej ścieżki komunikacji party. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 305 | `docs.bullet` | Poprawna internacjonalizacja broadcastów (wcześniej jedna angielska wiadomość dla wszystkich członków, teraz per-locale). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 313 | `docs.bullet` | Dodano nowe klucze bazowe EN dla komunikatów party: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 314 | `docs.bullet` | `cpp.party.member_joined` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 315 | `docs.bullet` | `cpp.party.member_left` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 316 | `docs.bullet` | `cpp.party.new_leader` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 317 | `docs.bullet` | `cpp.party.invited_member` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 318 | `docs.bullet` | `cpp.party.invited_member_with_hint` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 319 | `docs.bullet` | `cpp.party.invited_you` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 320 | `docs.bullet` | `cpp.party.invitation_revoked_by_leader` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 321 | `docs.bullet` | `cpp.party.invitation_revoked_for` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 322 | `docs.bullet` | `cpp.party.shared_exp_active*` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 323 | `docs.bullet` | `cpp.party.shared_exp_error` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 326 | `docs.paragraph` | Kolejny moduł C++ ma komplet EN jako źródło do tłumaczeń na wszystkie języki. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 331 | `docs.bullet` | Sprawdzono komplet nowych kluczy `cpp.party.*` używanych w `party.cpp` względem `i18n/en/cpp.json`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 332 | `docs.bullet` | Ponownie zweryfikowano poprawność składni `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 333 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 334 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem: dopiero GitHub Actions po szerszej migracji i18n). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 341 | `docs.bullet` | `src/creatures/interactions/chat.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 342 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 343 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 346 | `docs.bullet` | `chat.cpp`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 348 | `docs.bullet` | `cpp.chat.private_invite_received` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 349 | `docs.bullet` | `cpp.chat.private_invited_confirm` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 350 | `docs.bullet` | `cpp.chat.private_excluded_confirm` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 352 | `docs.bullet` | `game.cpp`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 354 | `docs.bullet` | `cpp.game.trade_move_closer` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 355 | `docs.bullet` | `cpp.game.trade_wants_to_trade` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 356 | `docs.bullet` | Komunikaty są formatowane per-locale odbiorcy. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 357 | `docs.bullet` | `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 358 | `docs.bullet` | Dodano bazowe klucze EN dla nowych ścieżek `cpp.chat.*` i `cpp.game.trade_*`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 361 | `docs.bullet` | Usunięcie kolejnych twardych tekstów EN z C++. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 362 | `docs.bullet` | Ujednolicenie ścieżki tłumaczeń dla chat/trade przed masowym tłumaczeniem na wszystkie języki. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 367 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 368 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 369 | `docs.bullet` | Sprawdzono powiązanie użyć kluczy w C++ z wpisami w `i18n/en/cpp.json`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 370 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 377 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 378 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 382 | `docs.bullet` | `cpp.game.unwrap_house_description` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 384 | `docs.bullet` | `cpp.game.store_item_description` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 385 | `docs.bullet` | Dodano brakujący klucz EN: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 386 | `docs.bullet` | `cpp.game.unwrap_house_description` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 389 | `docs.bullet` | Kolejne usunięcie twardych EN z C++. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 390 | `docs.bullet` | Spójny mechanizm opisu przedmiotów wrap/store, gotowy do tłumaczeń na wszystkie języki. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 395 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 396 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 397 | `docs.bullet` | Potwierdzono brak hardcoded wersji tych opisów w `game.cpp` (zastąpione kluczami i18n). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 398 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 405 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 406 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 409 | `docs.bullet` | Dodano klucz i18n dla błędu nieprawidłowego przedmiotu na market: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 410 | `docs.bullet` | `cpp.game.market_item_not_correct` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 411 | `docs.bullet` | W `game.cpp` usunięto porównania logiczne oparte o surowy tekst EN: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 412 | `docs.bullet` | zamiast `"The item you tried to market is not correct. Check the item again."` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 413 | `docs.bullet` | używany jest marker-klucz `marketInvalidItemMessageKey`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 414 | `docs.bullet` | Przy błędach `removeOfferItems(...)` dodano natychmiastową wysyłkę lokalizowanego komunikatu do gracza: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 415 | `docs.bullet` | create offer (`server.game.msg_24` fallback), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 416 | `docs.bullet` | accept offer (`server.game.msg_27` fallback). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 417 | `docs.bullet` | Zachowano logi techniczne (offerStatus) dla diagnostyki serwera. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 420 | `docs.bullet` | Eliminacja kruchej logiki zależnej od dokładnego EN stringa. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 421 | `docs.bullet` | Lepsza przygotowalność pod tłumaczenia (logika oparta o klucz, nie literal). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 422 | `docs.bullet` | Stabilniejsze zachowanie przy dalszym rozwoju i18n. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 427 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 428 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 429 | `docs.bullet` | Sprawdzono użycia: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 430 | `docs.bullet` | `marketInvalidItemMessageKey` w `game.cpp`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 431 | `docs.bullet` | obecność `cpp.game.market_item_not_correct` w `i18n/en/cpp.json`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 432 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 439 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 442 | `docs.bullet` | W gałęzi `manaLoss` funkcji `Game::combatChangeMana(...)` usunięto hardcoded EN komunikaty składane przez `std::stringstream`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 443 | `docs.bullet` | Podłączono istniejące klucze i18n `cpp.combat.mana_*`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 444 | `docs.bullet` | `cpp.combat.mana_attacker` / `cpp.combat.mana_attacker_crit` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 445 | `docs.bullet` | `cpp.combat.mana_target_none` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 446 | `docs.bullet` | `cpp.combat.mana_target_self` / `cpp.combat.mana_target_self_crit` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 447 | `docs.bullet` | `cpp.combat.mana_target_by` / `cpp.combat.mana_target_by_crit` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 448 | `docs.bullet` | `cpp.combat.mana_spectator_none` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 449 | `docs.bullet` | `cpp.combat.mana_spectator_self` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 450 | `docs.bullet` | `cpp.combat.mana_spectator_by` / `cpp.combat.mana_spectator_by_crit` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 451 | `docs.bullet` | Dodano cache komunikatu spectatorów per-locale: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 452 | `docs.bullet` | `std::unordered_map<std::string, std::string> spectatorManaCache` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 453 | `docs.bullet` | dzięki temu formatowanie tekstu dla spectatorów wykonuje się raz na język, nie raz na gracza. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 456 | `docs.bullet` | Domknięcie kolejnej często wykonywanej ścieżki combat pod i18n. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 457 | `docs.bullet` | Usunięcie twardych EN z runtime C++. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 458 | `docs.bullet` | Lepsza wydajność formatowania komunikatów (cache per locale), ważna przy dużej liczbie spectatorów. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 463 | `docs.bullet` | Zweryfikowano, że hardcoded EN frazy utraty many nie występują już w tym bloku `combatChangeMana`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 464 | `docs.bullet` | Sprawdzono składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 465 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 466 | `docs.bullet` | Sprawdzono `git diff --check` dla `src/game/game.cpp` (brak problemów whitespace). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 467 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem: testy dopiero po większym domknięciu migracji i18n). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 474 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 475 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 478 | `docs.bullet` | W `Game::playerQuickLootCorpse(...)` usunięto składanie komunikatów z fragmentów: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 479 | `docs.bullet` | `cpp.game.you_looted` / `cpp.game.could_not_loot` + hardcoded `" gold."` / `"1 item."` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 480 | `docs.bullet` | Zastąpiono je pełnymi kluczami i18n (całe zdania): |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 481 | `docs.bullet` | `cpp.game.quick_loot_success_gold` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 482 | `docs.bullet` | `cpp.game.quick_loot_success_one_item` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 483 | `docs.bullet` | `cpp.game.quick_loot_fail_gold` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 484 | `docs.bullet` | `cpp.game.quick_loot_fail_one_item` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 485 | `docs.bullet` | Dodano powyższe klucze bazowe EN do `i18n/en/cpp.json`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 488 | `docs.bullet` | Pełne zdania per klucz dają poprawny szyk i fleksję w innych językach (bez narzucania angielskiej kolejności przez konkatenację). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 489 | `docs.bullet` | Kolejne usunięcie hardcoded EN z runtime C++. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 494 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 495 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 496 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 497 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 498 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 499 | `docs.bullet` | Potwierdzono użycia nowych kluczy `cpp.game.quick_loot_*` w `game.cpp`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 500 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 507 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 508 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 511 | `docs.bullet` | `ProtocolGame::sendCyclopediaCharacterInspection()`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 512 | `docs.bullet` | dodano locale-aware tłumaczenie etykiet i opisów: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 513 | `docs.bullet` | `Character Title`, `Level`, `Vocation`, `Loyalty Title`, `Married to`, `Outfit`, `unknown` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 514 | `docs.bullet` | przepięto tytuł aktywnego Prey na klucz formatowany: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 515 | `docs.bullet` | `cpp.protocol.active_prey_label` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 516 | `docs.bullet` | usunięto hardcoded składanie EN dla opisu bonusu Prey: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 517 | `docs.bullet` | `Improved Damage/Defense/Experience/Loot` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 518 | `docs.bullet` | fallback `Unknown creature` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 519 | `docs.bullet` | opis Prey jest teraz budowany jako pełny klucz: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 520 | `docs.bullet` | `cpp.protocol.active_prey_desc` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 521 | `docs.bullet` | `ProtocolGame::sendContainer()`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 522 | `docs.bullet` | przepięto nazwę kontenera browse field: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 523 | `docs.bullet` | `cpp.protocol.browse_field` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 524 | `docs.bullet` | `ProtocolGame::sendOutfitWindow()`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 525 | `docs.bullet` | przepięto nazwy support outfitów: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 526 | `docs.bullet` | `cpp.protocol.support_outfit_gamemaster` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 527 | `docs.bullet` | `cpp.protocol.support_outfit_customer_support` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 528 | `docs.bullet` | `cpp.protocol.support_outfit_community_manager` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 529 | `docs.bullet` | `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 530 | `docs.bullet` | dodano komplet kluczy `cpp.protocol.*` dla powyższych ekranów i opisów. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 533 | `docs.bullet` | Kolejne usunięcie hardcoded EN z warstwy serwer->klient dla interfejsów Cyclopedii i okien. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 534 | `docs.bullet` | Lepsza gotowość do masowego tłumaczenia (pełne klucze zamiast fragmentów zdań). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 535 | `docs.bullet` | Spójna lokalizacja na bazie locale gracza. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 540 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 541 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 542 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 543 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 544 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 545 | `docs.bullet` | Potwierdzono, że docelowe hardcoded etykiety EN w zmienionych sekcjach `protocolgame.cpp` zostały zastąpione kluczami i18n. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 546 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem: dopiero GitHub Actions po większej migracji i18n). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 553 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 554 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 557 | `docs.bullet` | W `ProtocolGame::sendRestingStatus(...)` usunięto hardcoded EN: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 558 | `docs.bullet` | `Resting Area (no active bonus)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 559 | `docs.bullet` | `Active Resting Area Bonuses: ...` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 560 | `docs.bullet` | nazwy bonusów regeneracji (HP/Mana/Stamina/Soul, w tym warianty double). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 561 | `docs.bullet` | Komunikaty są teraz pobierane z `cpp.protocol.*` per locale gracza. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 562 | `docs.bullet` | Dodano klucze: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 563 | `docs.bullet` | `cpp.protocol.resting_no_bonus` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 564 | `docs.bullet` | `cpp.protocol.resting_active_bonuses` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 565 | `docs.bullet` | `cpp.protocol.resting_hp_regen` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 566 | `docs.bullet` | `cpp.protocol.resting_hp_regen_double` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 567 | `docs.bullet` | `cpp.protocol.resting_mana_regen` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 568 | `docs.bullet` | `cpp.protocol.resting_mana_regen_double` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 569 | `docs.bullet` | `cpp.protocol.resting_stamina_regen` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 570 | `docs.bullet` | `cpp.protocol.resting_soul_regen` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 571 | `docs.bullet` | Sposób budowania listy bonusów pozostał semantycznie zgodny (separator `",\ "`), ale finalny komunikat jest składany przez klucz formatowany. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 574 | `docs.bullet` | Kolejny ekran klienta wysyłany przez protokół jest gotowy pod wielojęzyczność. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 575 | `docs.bullet` | Usunięcie EN z runtime C++ i ujednolicenie mechanizmu tłumaczeń. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 580 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 581 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 582 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 583 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 584 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 585 | `docs.bullet` | Potwierdzono użycia nowych kluczy `cpp.protocol.resting_*` w `sendRestingStatus`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 586 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 593 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 594 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 597 | `docs.bullet` | W `ProtocolGame::sendHighscores(...)` usunięto hardcoded etykietę `"(all)"` dla filtra vocation. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 599 | `docs.bullet` | `cpp.protocol.vocation_all` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 600 | `docs.bullet` | Dodano klucz bazowy EN: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 601 | `docs.bullet` | `cpp.protocol.vocation_all` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 604 | `docs.bullet` | Domknięcie kolejnej drobnej etykiety UI w protokole pod pełne i18n. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 605 | `docs.bullet` | Utrzymanie spójności: brak twardych EN w filtrach highscores. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 610 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 611 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 612 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 613 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 614 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 615 | `docs.bullet` | Potwierdzono użycie `cpp.protocol.vocation_all` w `sendHighscores`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 616 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 623 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 624 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 625 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 628 | `docs.bullet` | `ProtocolGame::sendPodiumDetails(...)`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 629 | `docs.bullet` | usunięto hardcoded `"Tentugly"` z odpowiedzi protokołu, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 630 | `docs.bullet` | podmieniono na klucz i18n per locale gracza: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 631 | `docs.bullet` | `cpp.protocol.tentugly_name`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 632 | `docs.bullet` | `Game::playerSetShowOffSocket(...)` (nazwa podium-itemu): |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 633 | `docs.bullet` | usunięto hardcoded `"Tentugly"` przy nadawaniu nazwy itemu, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 634 | `docs.bullet` | podmieniono na klucz EN (stały, globalny atrybut itemu): |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 635 | `docs.bullet` | `cpp.game.tentugly_name` z locale `"en"`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 636 | `docs.bullet` | Dodano klucze bazowe EN: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 637 | `docs.bullet` | `cpp.protocol.tentugly_name` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 638 | `docs.bullet` | `cpp.game.tentugly_name` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 641 | `docs.bullet` | Domknięcie ostatniego jawnego hardcoded `msg.addString("...")` w `protocolgame.cpp`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 642 | `docs.bullet` | Utrzymanie spójności i18n także dla specjalnego wyjątku bossa podium. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 643 | `docs.bullet` | Zachowanie bezpieczeństwa semantycznego: globalna nazwa itemu nadal oparta o EN (niezależnie od locale gracza, który wykonał akcję). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 648 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 649 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 650 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 651 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 652 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 653 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 654 | `docs.bullet` | Potwierdzono, że hardcoded `"Tentugly"` został usunięty z obu miejsc i zastąpiony kluczami i18n. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 655 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 662 | `docs.bullet` | `src/game/game.hpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 663 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 664 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 667 | `docs.bullet` | `Game::offlineTrainingWindow`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 668 | `docs.bullet` | tytuł i treść modala ustawiono jako klucze i18n (zamiast EN literal): |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 669 | `docs.bullet` | `cpp.game.offline_training_title` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 670 | `docs.bullet` | `cpp.game.offline_training_message` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 671 | `docs.bullet` | `Game::Game()`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 672 | `docs.bullet` | wybory treningu i przyciski modala zapisano jako klucze: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 673 | `docs.bullet` | `cpp.game.offline_training_choice_*` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 674 | `docs.bullet` | `cpp.game.offline_training_button_*` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 675 | `docs.bullet` | `Game::sendOfflineTrainingDialog(...)`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 676 | `docs.bullet` | dodano budowę zlokalizowanej kopii modala per locale gracza, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 677 | `docs.bullet` | tłumaczone są: `title`, `message`, `buttons`, `choices` przed wysyłką. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 678 | `docs.bullet` | `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 679 | `docs.bullet` | dodano komplet kluczy EN dla offline training modala. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 682 | `docs.bullet` | Offline training window jest teraz gotowy pod pełne tłumaczenia (bez hardcoded EN w C++). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 683 | `docs.bullet` | Lokalizacja odbywa się per gracz przy wysyłce modala, więc działa poprawnie dla wielu języków jednocześnie. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 688 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 689 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 690 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 691 | `docs.bullet` | `src/game/game.hpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 692 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 693 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 694 | `docs.bullet` | Potwierdzono, że hardcoded EN z offline training modala zostały zastąpione kluczami i18n. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 695 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 702 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 703 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 704 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 707 | `docs.bullet` | `Game::m_highscoreCategories`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 708 | `docs.bullet` | nazwy kategorii (EN literal) zostały zastąpione kluczami `cpp.game.highscore_category_*`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 709 | `docs.bullet` | `ProtocolGame::sendHighscores(...)`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 710 | `docs.bullet` | wysyłka nazwy kategorii do klienta została przepięta na tłumaczenie per locale: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 711 | `docs.bullet` | `tr.get(category.m_name, locale)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 712 | `docs.bullet` | `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 713 | `docs.bullet` | dodano klucze EN dla kategorii highscores: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 714 | `docs.bullet` | experience, fist, club, sword, axe, distance, shielding, fishing, magic level. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 717 | `docs.bullet` | Kategorie highscores są teraz gotowe do tłumaczeń wielojęzycznych. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 718 | `docs.bullet` | Usunięto kolejne hardcoded EN z danych UI wysyłanych przez protokół. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 723 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 724 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 725 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 726 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 727 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 728 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 729 | `docs.bullet` | Potwierdzono, że `sendHighscores` wysyła lokalizowaną nazwę kategorii zamiast surowego EN. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 730 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 737 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 738 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 741 | `docs.bullet` | `ProtocolGame::sendCyclopediaCharacterBadges()`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 742 | `docs.bullet` | dodano tłumaczenie nazw badge per locale gracza, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 743 | `docs.bullet` | mapowanie odbywa się po `badge.m_id` -> `cpp.badge.name_<id>`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 744 | `docs.bullet` | dla nieznanego `id` zachowano fallback do `badge.m_name` (bez zmian danych runtime). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 745 | `docs.bullet` | `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 746 | `docs.bullet` | dodano klucze EN `cpp.badge.name_1..21`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 749 | `docs.bullet` | UI Cyclopedii (badges) jest gotowy pod tłumaczenia, bez zmiany nazw przechowywanych w KV i logice odblokowań. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 750 | `docs.bullet` | Minimalizacja ryzyka regresji: wewnętrzne identyfikatory/nazwy badge pozostają kompatybilne. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 755 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 756 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 757 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 758 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 759 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 760 | `docs.bullet` | Potwierdzono, że wysyłka badge do klienta korzysta z kluczy `cpp.badge.name_*`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 761 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 768 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 769 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 772 | `docs.bullet` | `ProtocolGame::sendCyclopediaCharacterTitles()`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 773 | `docs.bullet` | dodano locale-aware tłumaczenie nazw i opisów tytułów dla ID `1..20`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 774 | `docs.bullet` | użyte klucze: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 775 | `docs.bullet` | `cpp.title.name_<id>` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 776 | `docs.bullet` | `cpp.title.desc_<id>` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 777 | `docs.bullet` | dla pozostałych ID zachowano fallback do istniejących wartości runtime (`title.m_*`), bez zmian logiki odblokowań/KV. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 778 | `docs.bullet` | `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 779 | `docs.bullet` | dodano klucze EN dla tytułów `1..20` (name + desc). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 782 | `docs.bullet` | UI Cyclopedii (titles) zaczyna być migrowany do i18n bez ryzykownej jednorazowej zmiany wszystkich 90+ wpisów. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 783 | `docs.bullet` | Podejście etapowe umożliwia dalszą migrację kolejnych pakietów ID bez regresji kompatybilności danych. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 788 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 789 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 790 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 791 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 792 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 793 | `docs.bullet` | Potwierdzono, że `sendCyclopediaCharacterTitles` używa kluczy i18n dla zakresu `1..20` i fallback dla pozostałych wpisów. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 794 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 801 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 802 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 805 | `docs.bullet` | Rozszerzono lokalizację w `ProtocolGame::sendCyclopediaCharacterTitles()` z zakresu `1..20` do `1..40`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 806 | `docs.bullet` | Dodano obsługę wariantów żeńskich dla tytułów z osobnymi nazwami: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 807 | `docs.bullet` | ID `32` (`Princess Charming`) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 808 | `docs.bullet` | ID `35` (`Blood Moon Huntress`) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 809 | `docs.bullet` | Dla tytułów `1..40` pobierane są klucze: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 810 | `docs.bullet` | `cpp.title.name_<id>` (oraz `*_female` dla wybranych) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 811 | `docs.bullet` | `cpp.title.desc_<id>` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 812 | `docs.bullet` | Dla pozostałych ID zachowany fallback do danych runtime. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 813 | `docs.bullet` | `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 814 | `docs.bullet` | dodano klucze EN `cpp.title.name_21..40`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 815 | `docs.bullet` | dodano `cpp.title.name_32_female`, `cpp.title.name_35_female`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 816 | `docs.bullet` | dodano klucze EN `cpp.title.desc_21..40`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 819 | `docs.bullet` | Kolejna duża paczka Cyclopedia Titles jest gotowa do tłumaczeń wielojęzycznych. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 820 | `docs.bullet` | Zachowano kompatybilność danych i bezpieczny etapowy rollout (fallback dla niezmigrowanych ID). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 825 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 826 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 827 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 828 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 829 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 830 | `docs.bullet` | Potwierdzono użycie kluczy `cpp.title.*` dla zakresu `1..40` w `sendCyclopediaCharacterTitles`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 831 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 838 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 839 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 842 | `docs.bullet` | Rozszerzono zakres lokalizacji tytułów w `sendCyclopediaCharacterTitles()` do `1..60`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 843 | `docs.bullet` | Dodano warianty żeńskie dla tytułów z osobnymi nazwami w tej paczce: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 845 | `docs.bullet` | Dla zakresu `1..60` wysyłane są klucze: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 846 | `docs.bullet` | `cpp.title.name_<id>` (+ `*_female` dla wskazanych ID) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 847 | `docs.bullet` | `cpp.title.desc_<id>` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 848 | `docs.bullet` | Dla pozostałych ID nadal działa fallback do danych runtime. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 849 | `docs.bullet` | `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 850 | `docs.bullet` | dodano klucze EN `cpp.title.name_41..60`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 851 | `docs.bullet` | dodano klucze EN `cpp.title.desc_41..60`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 852 | `docs.bullet` | dodano klucze EN `*_female` dla wymaganych ID. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 855 | `docs.bullet` | Migracja Cyclopedia Titles postępuje etapowo i bezpiecznie (bez zmian w KV). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 856 | `docs.bullet` | Kolejna duża część tekstów gracza jest gotowa pod wielojęzyczne tłumaczenia. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 861 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 862 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 863 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 864 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 865 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 866 | `docs.bullet` | Potwierdzono użycie kluczy `cpp.title.*` dla zakresu `1..60` oraz wariantów `*_female`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 867 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 874 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 875 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 878 | `docs.bullet` | Rozszerzono zakres lokalizacji tytułów w `sendCyclopediaCharacterTitles()` z `1..60` do pełnego `1..93`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 879 | `docs.bullet` | Dodano warianty żeńskie dla tytułów z osobnymi nazwami w tej paczce: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 880 | `docs.bullet` | `70` (`Aspiring Huntswoman`) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 881 | `docs.bullet` | `90` (`Queen of Demon`) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 882 | `docs.bullet` | Dla zakresu `1..93` wysyłane są klucze: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 883 | `docs.bullet` | `cpp.title.name_<id>` (+ `*_female` dla wskazanych ID) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 884 | `docs.bullet` | `cpp.title.desc_<id>` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 885 | `docs.bullet` | `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 886 | `docs.bullet` | dodano klucze EN `cpp.title.name_61..93`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 887 | `docs.bullet` | dodano klucze EN `cpp.title.desc_61..93`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 888 | `docs.bullet` | dodano klucze EN `cpp.title.name_70_female` i `cpp.title.name_90_female`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 891 | `docs.bullet` | Cyclopedia Titles ma teraz pełne pokrycie kluczami i18n dla wszystkich istniejących ID (`1..93`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 892 | `docs.bullet` | Zostawiono fallback dla potencjalnych przyszłych/niestandardowych wpisów spoza tego zakresu, więc migracja pozostaje bezpieczna operacyjnie. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 897 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 898 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 899 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 900 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 901 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 902 | `docs.bullet` | Potwierdzono użycie kluczy `cpp.title.*` dla pełnego zakresu `1..93` wraz z wariantami `*_female`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 903 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 910 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 913 | `docs.bullet` | Dodano wspólne helpery i18n dla tytułów: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 914 | `docs.bullet` | `hasFemaleTitleVariant(...)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 915 | `docs.bullet` | `getLocalizedTitleName(...)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 916 | `docs.bullet` | `getLocalizedTitleDescription(...)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 917 | `docs.bullet` | `getLocalizedCurrentTitleName(...)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 918 | `docs.bullet` | `sendCyclopediaCharacterBaseInformation()`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 919 | `docs.bullet` | bieżący tytuł postaci (`character title`) jest teraz tłumaczony per locale, zamiast surowego `getCurrentTitleName()`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 920 | `docs.bullet` | `sendCyclopediaCharacterInspection()`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 921 | `docs.bullet` | sekcja `Player title` została przepięta na ten sam helper lokalizujący. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 922 | `docs.bullet` | `sendCyclopediaCharacterTitles()`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 923 | `docs.bullet` | uproszczono pętlę: nazwa i opis tytułu pobierane są przez wspólne helpery (bez duplikacji logiki warunków). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 926 | `docs.bullet` | Usunięto niespójność: wcześniej lista tytułów mogła być tłumaczona, ale bieżący wybrany tytuł nadal potrafił wyświetlać EN. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 927 | `docs.bullet` | Jedna ścieżka lokalizacji tytułów upraszcza utrzymanie i zmniejsza ryzyko regresji przy kolejnych etapach i18n. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 932 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 933 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 934 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 935 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 936 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 937 | `docs.bullet` | Potwierdzono, że w `src/server/network/protocol/protocolgame.cpp` nie ma już wywołań `getCurrentTitleName()`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 938 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 945 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 946 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 949 | `docs.bullet` | Dodano helper `getLocalizedVocationName(vocationId, fallbackName, locale)`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 950 | `docs.bullet` | buduje klucz `cpp.vocation.id_<id>`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 951 | `docs.bullet` | przy braku tłumaczenia zachowuje fallback do oryginalnej nazwy z danych vocacji. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 952 | `docs.bullet` | Przepięto wysyłkę nazw vocacji na helper w: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 953 | `docs.bullet` | `sendHighscores(...)` (lista filtrów vocacji), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 954 | `docs.bullet` | `sendCyclopediaCharacterBaseInformation()`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 955 | `docs.bullet` | `sendCyclopediaCharacterInspection()` (sekcja `Vocation`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 956 | `docs.bullet` | `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 957 | `docs.bullet` | dodano bazowe klucze EN: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 958 | `docs.bullet` | `cpp.vocation.id_0..8` (None, Sorcerer, Druid, Paladin, Knight, Master Sorcerer, Elder Druid, Royal Paladin, Elite Knight). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 961 | `docs.bullet` | Nazwy vocacji są teraz gotowe do tłumaczeń per locale bez naruszania kompatybilności z custom vocacjami. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 962 | `docs.bullet` | Fallback minimalizuje ryzyko regresji na serwerach z rozszerzonym `vocations.xml`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 967 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 968 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 969 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 970 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 971 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 972 | `docs.bullet` | Potwierdzono użycie `getLocalizedVocationName(...)` we wszystkich trzech docelowych miejscach w `protocolgame.cpp`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 973 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 980 | `docs.bullet` | `src/creatures/players/player.hpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 981 | `docs.bullet` | `src/creatures/players/player.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 982 | `docs.bullet` | `src/lua/functions/creatures/creature_functions.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 983 | `docs.bullet` | `data/scripts/eventcallbacks/player/on_look.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 984 | `docs.bullet` | `data/events/scripts/player.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 985 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 989 | `docs.bullet` | dodano metodę `getDescriptionLocalized(int32_t lookDistance, const std::string &viewerLocale)`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 990 | `docs.bullet` | `getDescription(...)` pozostawiono jako fallback EN (`return getDescriptionLocalized(..., "en")`), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 991 | `docs.bullet` | logika opisu gracza (`look`) została przepięta na klucze i18n `cpp.player.look.*`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 992 | `docs.bullet` | lokalizowany jest też bieżący tytuł postaci (z użyciem `cpp.title.name_*` + `*_female`) oraz opis vocacji (`cpp.vocation.desc_id_*`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 994 | `docs.bullet` | rozszerzono `creature:getDescription(...)` do wariantu: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 995 | `docs.bullet` | `creature:getDescription(distance[, viewerPlayer])`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 996 | `docs.bullet` | jeśli `viewerPlayer` podano i oglądany obiekt jest graczem, używane jest `getDescriptionLocalized(..., viewerLocale)`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 997 | `docs.bullet` | Skrypty look: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 998 | `docs.bullet` | `data/scripts/eventcallbacks/player/on_look.lua`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 999 | `docs.bullet` | `inspectedThing:getDescription(lookDistance, player)`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1000 | `docs.bullet` | `data/events/scripts/player.lua` (legacy hook): |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1001 | `docs.bullet` | `creature:getDescription(distance, self)`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1002 | `docs.bullet` | `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1003 | `docs.bullet` | dodano komplet kluczy EN `cpp.player.look.*` dla zdań opisu gracza (self/other, party, guild, loyalty, VIP), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1004 | `docs.bullet` | dodano `cpp.vocation.desc_id_0..8` (opisowe formy vocacji, np. `a knight`, `an elder druid`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1007 | `docs.bullet` | Opis gracza (`look`) jest teraz budowany pod locale oglądającego zamiast stałego EN. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1008 | `docs.bullet` | Ten etap domyka ważną lukę i18n między C++ (opis gracza) a Lua eventami `on_look`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1013 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1014 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1015 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1016 | `docs.bullet` | `src/creatures/players/player.hpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1017 | `docs.bullet` | `src/creatures/players/player.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1018 | `docs.bullet` | `src/lua/functions/creatures/creature_functions.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1019 | `docs.bullet` | `data/scripts/eventcallbacks/player/on_look.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1020 | `docs.bullet` | `data/events/scripts/player.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1021 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1022 | `docs.bullet` | Potwierdzono użycie: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1023 | `docs.bullet` | `Player::getDescriptionLocalized(...)` w bridge Lua, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1024 | `docs.bullet` | `creature:getDescription(distance, player)` w głównym `on_look` callbacku. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1025 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1032 | `docs.bullet` | `data/events/scripts/player.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1035 | `docs.bullet` | `Player:onLookInBattleList(...)` został przepięty na istniejące tłumaczenia `scripts.on_look.*`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1036 | `docs.bullet` | prefix opisu (`see_prefix`), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1037 | `docs.bullet` | opis familiara (`familiar_master`), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1038 | `docs.bullet` | dane administracyjne (`admin_player_health`, `admin_player_health_mana`, `admin_player_id`, `admin_monster_id`, `admin_npc_id`, `admin_speed`, `admin_ip`), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1039 | `docs.bullet` | pozycja (`position_coords`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1040 | `docs.bullet` | Utrzymano przekazywanie viewer locale przez: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1041 | `docs.bullet` | `creature:getDescription(distance, self)`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1044 | `docs.bullet` | Legacy ścieżka `onLookInBattleList` nie miesza już hardcoded EN z systemem i18n. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1045 | `docs.bullet` | Zmniejszono rozjazd między nowym callbackiem `data/scripts/eventcallbacks/player/on_look.lua` a starszym eventem. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1050 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1051 | `docs.bullet` | `data/events/scripts/player.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1052 | `docs.bullet` | oraz wcześniej dotkniętych plików i18n/C++/Lua z tej serii. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1053 | `docs.bullet` | Potwierdzono, że funkcja `Player:onLookInBattleList` używa kluczy `scripts.on_look.*` zamiast literalnych EN. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1054 | `docs.bullet` | Lokalny parser `luac` nie był dostępny w środowisku (`SKIP_LUAC`), więc wykonano walidację przez przegląd diffa i spójność kluczy. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1055 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1062 | `docs.bullet` | `src/creatures/players/player.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1063 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1066 | `docs.bullet` | `Player::getBlessingsName()`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1067 | `docs.bullet` | nazwy blessów nie są już budowane wyłącznie z `magic_enum` po EN, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1068 | `docs.bullet` | dodano tłumaczenie nazw przez klucze: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1069 | `docs.bullet` | `cpp.player.blessing_name_1..8` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1070 | `docs.bullet` | dodano i18n dla składania listy: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1071 | `docs.bullet` | `cpp.player.list_delimiter` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1072 | `docs.bullet` | `cpp.player.list_and` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1073 | `docs.bullet` | `cpp.player.list_end` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1074 | `docs.bullet` | przy braku klucza działa fallback do wcześniejszego zachowania (tekst z enum/EN). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1075 | `docs.bullet` | `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1076 | `docs.bullet` | dodano komplet kluczy EN dla nazw blessów oraz łączników listy. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1079 | `docs.bullet` | Komunikaty gracza korzystające z `getBlessingsName()` (`death`/`blessing` flow) są gotowe do tłumaczeń wielojęzycznych. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1080 | `docs.bullet` | Usunięto kolejne EN-only fragmenty sklejane w C++ (`and`, separator listy, nazwy blessów). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1085 | `docs.bullet` | Zweryfikowano składnię `i18n/en/cpp.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1086 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1087 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1088 | `docs.bullet` | `src/creatures/players/player.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1089 | `docs.bullet` | `i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1090 | `docs.bullet` | oraz aktualnego pakietu zmian (`data/events/scripts/player.lua`, dokumentacja). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1091 | `docs.bullet` | Potwierdzono użycie kluczy: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1092 | `docs.bullet` | `cpp.player.blessing_name_*` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1093 | `docs.bullet` | `cpp.player.list_delimiter` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1094 | `docs.bullet` | `cpp.player.list_and` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1095 | `docs.bullet` | `cpp.player.list_end` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1096 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1103 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1106 | `docs.bullet` | W `ProtocolGame::sendCyclopediaCharacterStoreSummary()`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1107 | `docs.bullet` | dodano pobranie locale gracza (`player->getLocale()` z fallbackiem `en`), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1108 | `docs.bullet` | zastąpiono wysyłanie nazw blessingów z `magic_enum` (EN-only) na: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1109 | `docs.bullet` | `getLocalizedBlessingName(bless, locale)`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1110 | `docs.bullet` | `getLocalizedBlessingName(...)` wykorzystuje klucze: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1111 | `docs.bullet` | `cpp.player.blessing_name_1..8` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1112 | `docs.bullet` | i fallback do poprzedniej nazwy EN, jeśli tłumaczenie nie istnieje. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1115 | `docs.bullet` | Cyclopedia Store Summary wysyła teraz nazwy blessingów zgodne z locale gracza. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1116 | `docs.bullet` | Domknięto niedokończoną wcześniej migrację tej ścieżki protokołu do i18n. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1121 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1122 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1123 | `docs.bullet` | Potwierdzono użycie `getLocalizedBlessingName(...)` w pętli blessingów w `sendCyclopediaCharacterStoreSummary()`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1124 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1131 | `docs.bullet` | `src/creatures/players/player.hpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1132 | `docs.bullet` | `src/creatures/players/player.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1133 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1134 | `docs.bullet` | `data/libs/functions/player.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1135 | `docs.bullet` | `i18n/en/libs.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1139 | `docs.bullet` | dodano metodę: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1140 | `docs.bullet` | `getLoyaltyTitleLocalized(std::string_view locale) const` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1141 | `docs.bullet` | metoda rozpoznaje klucze loyalty (`lib.player.loyalty_title_*`) i tłumaczy je przez `Translator` pod locale odbiorcy; |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1142 | `docs.bullet` | przy braku tłumaczenia lub dla legacy literalu zachowuje fallback do oryginalnego tekstu. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1143 | `docs.bullet` | `Player::getDescriptionLocalized(...)`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1144 | `docs.bullet` | zamiast surowego `loyaltyTitle` używa teraz `getLoyaltyTitleLocalized(viewerLocale)`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1145 | `docs.bullet` | dzięki temu opis `look` pokazuje loyalty title w języku oglądającego. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1146 | `docs.bullet` | `protocolgame.cpp`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1147 | `docs.bullet` | w `sendCyclopediaCharacterInspection()` loyalty title jest wysyłany przez `player->getLoyaltyTitleLocalized(locale)`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1148 | `docs.bullet` | w `sendCyclopediaCharacterBadges()` pole loyalty title również używa wersji zlokalizowanej. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1149 | `docs.bullet` | `data/libs/functions/player.lua`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1150 | `docs.bullet` | system lojalności przestał wpisywać EN literal do `setLoyaltyTitle(...)`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1151 | `docs.bullet` | teraz zapisuje stabilny klucz i18n (`lib.player.loyalty_title_1..11`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1152 | `docs.bullet` | `i18n/en/libs.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1153 | `docs.bullet` | dodano klucze EN: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1154 | `docs.bullet` | `lib.player.loyalty_title_1..11`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1157 | `docs.bullet` | Usunięto EN-only źródło loyalty title w runtime. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1158 | `docs.bullet` | Loyalty title stał się tłumaczalnym identyfikatorem, a nie „zamrożonym” tekstem. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1159 | `docs.bullet` | Opisy i Cyclopedia mogą prezentować ten sam tytuł poprawnie per locale odbiorcy. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1164 | `docs.bullet` | Zweryfikowano składnię JSON: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1165 | `docs.bullet` | `python3 -m json.tool i18n/en/libs.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1166 | `docs.bullet` | `python3 -m json.tool i18n/en/cpp.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1167 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1168 | `docs.bullet` | `src/creatures/players/player.hpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1169 | `docs.bullet` | `src/creatures/players/player.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1170 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1171 | `docs.bullet` | `data/libs/functions/player.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1172 | `docs.bullet` | `i18n/en/libs.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1173 | `docs.bullet` | Potwierdzono użycie nowych kluczy i metody: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1174 | `docs.bullet` | `lib.player.loyalty_title_*` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1175 | `docs.bullet` | `Player::getLoyaltyTitleLocalized(...)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1176 | `docs.bullet` | Lokalny parser Lua nie był dostępny (`SKIP_LUA_PARSE`), więc walidację Lua wykonano przez diff + spójność kluczy. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1177 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1184 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1185 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1188 | `docs.bullet` | `protocolgame.cpp`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1189 | `docs.bullet` | dodano helper `getLocalizedLoyaltyTitle(const std::string&, const std::string&)`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1190 | `docs.bullet` | `sendHighscores(...)` nie wysyła już loyalty title „as-is”, tylko: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1191 | `docs.bullet` | `getLocalizedLoyaltyTitle(character.loyaltyTitle, locale)`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1192 | `docs.bullet` | jeśli wartość jest kluczem (`lib.player.loyalty_title_*`), jest tłumaczona na locale odbiorcy; |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1194 | `docs.bullet` | `game.cpp` (`Game::processHighscoreResults(...)`): |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1195 | `docs.bullet` | usunięto TODO z pustym loyalty title, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1196 | `docs.bullet` | dodano jednorazową mapę `GUID -> loyaltyTitle` budowaną z aktualnie online graczy, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1197 | `docs.bullet` | przy budowie `HighscoreCharacter` loyalty title jest uzupełniany z tej mapy (bez ładowania offline postaci). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1200 | `docs.bullet` | Highscore jest spójny z nowym modelem i18n loyalty title. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1201 | `docs.bullet` | Eliminujemy EN-only prezentację tam, gdzie loyalty title jest dostępny. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1202 | `docs.bullet` | Rozwiązanie jest lekkie wydajnościowo: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1203 | `docs.bullet` | brak dodatkowych zapytań DB, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1204 | `docs.bullet` | brak kosztownego `loadPlayerById` dla każdej pozycji highscore, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1205 | `docs.bullet` | lookup O(1) po lokalnej mapie zamiast powtarzanych skanów. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1210 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1211 | `docs.bullet` | `src/game/game.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1212 | `docs.bullet` | `src/server/network/protocol/protocolgame.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1213 | `docs.bullet` | `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1214 | `docs.bullet` | Potwierdzono użycie: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1215 | `docs.bullet` | `getLocalizedLoyaltyTitle(...)` w `sendHighscores(...)`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1216 | `docs.bullet` | mapy `onlineLoyaltyTitleByGuid` w `Game::processHighscoreResults(...)`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1217 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1224 | `docs.bullet` | `data/libs/functions/player.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1225 | `docs.bullet` | `i18n/en/libs.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1228 | `docs.bullet` | `Player:showInfoModal(...)`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1229 | `docs.bullet` | domyślny tekst przycisku nie jest już hardcoded (`"Close"`), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1231 | `docs.bullet` | `lib.player.modal_button_close` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1232 | `docs.bullet` | `Player:showConfirmationModal(...)`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1234 | `docs.bullet` | `lib.player.modal_button_yes` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1235 | `docs.bullet` | `lib.player.modal_button_no` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1236 | `docs.bullet` | Dodano bezpieczny helper Lua: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1237 | `docs.bullet` | `getTranslationOrFallback(player, key, fallback)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1238 | `docs.bullet` | pobiera tłumaczenie z `Translator.getTranslation(...)` i robi fallback, gdy klucz/translator niedostępny. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1239 | `docs.bullet` | Usunięto martwy hardcoded fragment EN: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1240 | `docs.bullet` | `baseMessage = "You have found a ..."` w `Player:canGetReward(...)` (zmienna nieużywana). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1241 | `docs.bullet` | `i18n/en/libs.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1242 | `docs.bullet` | dodano klucze EN: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1243 | `docs.bullet` | `lib.player.modal_button_close` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1244 | `docs.bullet` | `lib.player.modal_button_yes` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1245 | `docs.bullet` | `lib.player.modal_button_no` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1248 | `docs.bullet` | Kolejne teksty UI po stronie Lua są gotowe pod wielojęzyczność. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1249 | `docs.bullet` | Usunięto twarde EN ze wspólnych helperów modalnych, które są używane w wielu miejscach. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1254 | `docs.bullet` | Zweryfikowano JSON: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1255 | `docs.bullet` | `python3 -m json.tool i18n/en/libs.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1256 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1257 | `docs.bullet` | `data/libs/functions/player.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1258 | `docs.bullet` | `i18n/en/libs.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1259 | `docs.bullet` | Potwierdzono użycia nowych kluczy: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1260 | `docs.bullet` | `lib.player.modal_button_close` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1261 | `docs.bullet` | `lib.player.modal_button_yes` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1262 | `docs.bullet` | `lib.player.modal_button_no` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1263 | `docs.bullet` | Lokalny parser Lua niedostępny (`SKIP_LUA_PARSE`), więc walidację Lua wykonano przez diff + spójność kluczy. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1264 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1269 | `docs.bullet` | Zgodnie z decyzją: odkładamy na później temat |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1270 | `docs.bullet` | pełnego uzupełnienia loyalty title dla **offline** wpisów highscore. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1271 | `docs.bullet` | Aktualny stan: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1272 | `docs.bullet` | loyalty title w highscore działa dla online postaci i jest lokalizowany per-locale odbiorcy. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1273 | `docs.bullet` | Plan na później: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1274 | `docs.bullet` | dodać źródło loyalty title dla offline wpisów bez nadmiernego kosztu (np. precomputing/lekki cache/rozszerzenie query). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1281 | `docs.bullet` | `data/libs/functions/functions.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1282 | `docs.bullet` | `data-otservbr-global/scripts/quests/cults_of_tibia/actions_bosses_levers.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1283 | `docs.bullet` | `i18n/en/quests.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1286 | `docs.bullet` | Rozszerzono helper `kickerPlayerRoomAfterMin(...)` o opcjonalne parametry: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1287 | `docs.bullet` | `messageI18nKey` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1288 | `docs.bullet` | `messageI18nArgs` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1289 | `docs.bullet` | Dodano wewnętrzną obsługę wysyłki: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1291 | `docs.bullet` | w przeciwnym razie zachowany dotychczasowy fallback do `sendTextMessage(...)`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1292 | `docs.bullet` | W `actions_bosses_levers.lua`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1293 | `docs.bullet` | zastąpiono 7 hardcoded wywołań EN komunikatu timeoutu boss-room zmiennymi: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1294 | `docs.bullet` | `timeoutKickMessage` (fallback tekstu), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1295 | `docs.bullet` | `timeoutKickMessageKey` (`quests.cults_of_tibia.boss_room_timeout_kick`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1296 | `docs.bullet` | W `i18n/en/quests.json` dodano klucz: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1297 | `docs.bullet` | `quests.cults_of_tibia.boss_room_timeout_kick`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1300 | `docs.bullet` | Najwyższy priorytet z listy questowej: usunięcie powtarzanego EN-only komunikatu z krytycznego flow quest boss-room. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1301 | `docs.bullet` | Zachowana pełna kompatybilność wstecz: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1302 | `docs.bullet` | stare wywołania helpera bez klucza i18n nadal działają. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1309 | `docs.bullet` | `src/items/item.hpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1310 | `docs.bullet` | `src/items/item.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1311 | `docs.bullet` | `src/lua/functions/items/item_functions.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1312 | `docs.bullet` | `src/creatures/players/player.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1313 | `docs.bullet` | `tools/i18n_pipeline.py` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1316 | `docs.bullet` | Dodano API C++: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1317 | `docs.bullet` | `Item::getNameLocalized(std::string_view locale) const` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1318 | `docs.bullet` | tłumaczy nazwę przez `item.<id>.name` (z fallback do tekstu bazowego), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1319 | `docs.bullet` | obsługuje też legacy namespace `items.<id>.name` dla kompatybilności. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1320 | `docs.bullet` | Lua `item:getName()` rozszerzone do: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1321 | `docs.bullet` | `item:getName([player\|string locale])` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1322 | `docs.bullet` | dzięki temu skrypty mogą pobierać nazwę itemu w locale odbiorcy bez ręcznych obejść. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1323 | `docs.bullet` | Poprawiono key namespace w stash: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1324 | `docs.bullet` | `Player::getLocalizedItemName(...)` używa teraz `item.<id>.name`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1325 | `docs.bullet` | pozostawiono fallback do `items.<id>.name` (legacy). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1326 | `docs.bullet` | Pipeline i18n (`tools/i18n_pipeline.py`) rozszerzony o etap eksportu klienta OTC: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1327 | `docs.bullet` | wywołuje `tools/json_to_lua_locales.py --all`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1328 | `docs.bullet` | nowa konfiguracja: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1329 | `docs.bullet` | `--client-locales-dir` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1330 | `docs.bullet` | `--skip-client-export` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1331 | `docs.bullet` | `--client-compact-keys` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1332 | `docs.bullet` | to domyka temat „czy `otclient_modules.json` jest brane do paczki klienta” na poziomie pipeline. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1335 | `docs.bullet` | Usunięto blokadę z listy Copilot dla itemów: brak locale-aware `Item::getName()` dostępnego dla warstwy skryptowej. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1336 | `docs.bullet` | Uspójniono nazewnictwo kluczy itemów (`item.*`) i zachowano bezpieczny fallback. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1337 | `docs.bullet` | Zabezpieczono workflow klienta OTC przed pomijaniem kategorii JSON (w tym `otclient_modules.json`) podczas eksportu locale. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1342 | `docs.bullet` | Zweryfikowano JSON: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1343 | `docs.bullet` | `python3 -m json.tool i18n/en/quests.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1344 | `docs.bullet` | Zweryfikowano składnię Pythona: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1345 | `docs.bullet` | `python3 -m py_compile tools/i18n_pipeline.py` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1346 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1347 | `docs.bullet` | `data/libs/functions/functions.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1348 | `docs.bullet` | `data-otservbr-global/scripts/quests/cults_of_tibia/actions_bosses_levers.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1349 | `docs.bullet` | `i18n/en/quests.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1350 | `docs.bullet` | `src/items/item.hpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1351 | `docs.bullet` | `src/items/item.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1352 | `docs.bullet` | `src/lua/functions/items/item_functions.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1353 | `docs.bullet` | `src/creatures/players/player.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1354 | `docs.bullet` | `tools/i18n_pipeline.py` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1355 | `docs.bullet` | Potwierdzono, że w `cults_of_tibia` wszystkie 7 wywołań timeoutu używa już klucza: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1356 | `docs.bullet` | `quests.cults_of_tibia.boss_room_timeout_kick` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1357 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1364 | `docs.bullet` | `data/libs/systems/encounters.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1367 | `docs.bullet` | Dodano nową metodę runtime: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1370 | `docs.bullet` | Dodano nowy builder stage: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1371 | `docs.bullet` | `Encounter:addLocalizedBroadcast(key, fallbackMessage, args, type)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1372 | `docs.bullet` | analogiczny do `addBroadcast(...)`, ale pod i18n. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1373 | `docs.bullet` | Zachowano pełną kompatybilność: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1374 | `docs.bullet` | istniejące `Encounter:addBroadcast(...)` i `Encounter:broadcast(...)` działają bez zmian. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1377 | `docs.bullet` | Encounter stage był jedną z dróg, która naturalnie omijała i18n i trzymała EN literal. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1378 | `docs.bullet` | Nowa metoda pozwala migrować questy etapami, bez masowego refaktoru istniejących raidów/encounterów. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1385 | `docs.bullet` | `data-otservbr-global/scripts/quests/feaster_of_souls/actions_portal_brain_head.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1386 | `docs.bullet` | `data-otservbr-global/scripts/quests/primal_ordeal_quest/magma_bubble_fight.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1387 | `docs.bullet` | `data-otservbr-global/scripts/quests/soul_war/moveevent-soul_war_entrances.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1388 | `docs.bullet` | `i18n/en/scripts.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1391 | `docs.bullet` | `actions_portal_brain_head.lua`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1392 | `docs.bullet` | wejściowy broadcast encounter przepięty na: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1393 | `docs.bullet` | `encounter:addLocalizedBroadcast("scripts.actions_portal_brain_head.msg_5", ...)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1394 | `docs.bullet` | `magma_bubble_fight.lua`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1395 | `docs.bullet` | 3 broadcasty EN (`entered volcano`, `volcano vibrates`, `take its revenge`) przepięte na `addLocalizedBroadcast(...)` z kluczami: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1396 | `docs.bullet` | `scripts.magma_bubble_fight.msg_2` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1397 | `docs.bullet` | `scripts.magma_bubble_fight.msg_3` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1398 | `docs.bullet` | `scripts.magma_bubble_fight.msg_4` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1399 | `docs.bullet` | `moveevent-soul_war_entrances.lua`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1400 | `docs.bullet` | usunięto sklejanie tekstu z kluczem i liczbą (anti-pattern), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1401 | `docs.bullet` | `msg_4` i `msg_5` teraz idą przez args do lokalizacji: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1402 | `docs.bullet` | `scripts.moveevent-soul_war_entrances.msg_4` + `{ text }` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1403 | `docs.bullet` | `scripts.moveevent-soul_war_entrances.msg_5` + `{ killCount, "20" }` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1404 | `docs.bullet` | `i18n/en/scripts.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1406 | `docs.bullet` | `scripts.actions_portal_brain_head.msg_5` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1407 | `docs.bullet` | `scripts.magma_bubble_fight.msg_2` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1408 | `docs.bullet` | `scripts.magma_bubble_fight.msg_3` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1409 | `docs.bullet` | `scripts.magma_bubble_fight.msg_4` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1410 | `docs.bullet` | poprawiono format klucza: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1411 | `docs.bullet` | `scripts.moveevent-soul_war_entrances.msg_5` (drugi placeholder `{1}` zamiast hardcoded `20`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1414 | `docs.bullet` | Usunięto kolejne realne EN-only komunikaty gracza w questach (nie nazwy potworów/ID techniczne). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1415 | `docs.bullet` | Naprawiono ścieżkę soul war, gdzie klucz i18n był wcześniej de facto obchodzony przez konkatenację. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1420 | `docs.bullet` | Zweryfikowano JSON: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1421 | `docs.bullet` | `python3 -m json.tool i18n/en/scripts.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1422 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1423 | `docs.bullet` | `data/libs/systems/encounters.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1424 | `docs.bullet` | `data-otservbr-global/scripts/quests/feaster_of_souls/actions_portal_brain_head.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1425 | `docs.bullet` | `data-otservbr-global/scripts/quests/primal_ordeal_quest/magma_bubble_fight.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1426 | `docs.bullet` | `data-otservbr-global/scripts/quests/soul_war/moveevent-soul_war_entrances.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1427 | `docs.bullet` | `i18n/en/scripts.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1429 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1436 | `docs.bullet` | Porównano źródło i18n modułów OTC: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1437 | `docs.bullet` | `i18n/en/otclient_modules.json` (1,987 kluczy) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1438 | `docs.bullet` | Ze stanem aktualnego artefaktu klientowego: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1439 | `docs.bullet` | `testyy/data/locales/game_i18n_en.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1442 | `docs.bullet` | Aktualny `game_i18n_en.lua` jest krótki (177 linii) i **nie zawiera** kluczy z `otclient_modules.json`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1443 | `docs.bullet` | To oznacza, że artefakt klientowy jest niezsynchronizowany / historyczny (nieprzegenerowany pełnym eksporterem). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1446 | `docs.bullet` | W poprzednim etapie rozszerzono `tools/i18n_pipeline.py` o krok: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1447 | `docs.bullet` | `tools/json_to_lua_locales.py --all` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1448 | `docs.bullet` | Dzięki temu przy uruchomieniu pipeline klucze z `otclient_modules.json` będą trafiać do paczek `game_i18n_<lang>.lua`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1451 | `docs.bullet` | Domknięcie punktu „czy instalka/pack bierze `otclient_modules.json`” na poziomie procesu build/export. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1452 | `docs.bullet` | Eliminacja cichego rozjazdu między serwerowym `i18n/*.json` a klientowym bundle locale. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1459 | `docs.bullet` | `src/items/item.hpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1460 | `docs.bullet` | `src/items/item.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1461 | `docs.bullet` | `src/lua/functions/items/item_type_functions.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1464 | `docs.bullet` | `Item::getNameDescription(...)`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1465 | `docs.bullet` | rozszerzono sygnaturę o `std::string_view locale` (domyślnie pusty), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1466 | `docs.bullet` | `Item::getDescription(..., locale)` przekazuje locale dalej do `getNameDescription(...)`, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1467 | `docs.bullet` | nazwa itemu w opisie/look korzysta teraz z lokalizacji (`item.<id>.name`) przez `resolveItemTypeName(...)` / `getNameLocalized(...)`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1468 | `docs.bullet` | `ItemType:getName(...)` w Lua: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1469 | `docs.bullet` | rozszerzono do wariantu: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1470 | `docs.bullet` | `itemType:getName([player\|string locale])` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1471 | `docs.bullet` | dodano tłumaczenie po kluczu `item.<id>.name` z fallbackiem do `items.<id>.name` i finalnie do bazowej nazwy. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1474 | `docs.bullet` | To domyka praktyczną część punktu „brak implementacji locale dla `Item::getName()`”: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1475 | `docs.bullet` | nie tylko `Item:getName(...)`, ale też opis/look itemu i `ItemType:getName(...)` w skryptach respektują locale. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1476 | `docs.bullet` | Ułatwia dalszą migrację questów i UI, gdzie często operuje się na `ItemType` zamiast instancji `Item`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1481 | `docs.bullet` | Sprawdzono `git diff --check` dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1482 | `docs.bullet` | `src/items/item.hpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1483 | `docs.bullet` | `src/items/item.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1484 | `docs.bullet` | `src/lua/functions/items/item_type_functions.cpp` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1485 | `docs.bullet` | oraz batcha questowego (`encounters.lua`, questy, `i18n/en/scripts.json`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1486 | `docs.bullet` | Zweryfikowano JSON: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1487 | `docs.bullet` | `python3 -m json.tool i18n/en/scripts.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1488 | `docs.bullet` | Potwierdzono użycia: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1489 | `docs.bullet` | `Encounter:addLocalizedBroadcast(...)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1490 | `docs.bullet` | `Item::getNameDescription(..., locale)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1491 | `docs.bullet` | `itemType:getName([player\|string locale])` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1492 | `docs.bullet` | Testów nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1499 | `docs.bullet` | `data/libs/functions/quests.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1502 | `docs.bullet` | Rozszerzono runtime questloga o obsługę dynamicznych opisów misji (`description = function(player) ...`) przez klucz: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1503 | `docs.bullet` | `questlog.quest_<questId>.mission_<missionId>.description_dynamic` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1504 | `docs.bullet` | Dodano helpery: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1505 | `docs.bullet` | `getQuestlogMissionDynamicDescription(...)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1506 | `docs.bullet` | `evaluateDynamicDescription(...)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1507 | `docs.bullet` | `evaluateDynamicDescription(...)`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1508 | `docs.bullet` | tymczasowo przechwytuje `string.format(...)` podczas wykonania funkcji opisu, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1509 | `docs.bullet` | zbiera template i argumenty, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1510 | `docs.bullet` | po tłumaczeniu template formatuje wynik już w locale gracza, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1511 | `docs.bullet` | przy problemie (brak klucza / błąd formatowania) zachowuje fallback do dotychczasowego tekstu. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1512 | `docs.bullet` | Dodano bezpieczny fallback unpack: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1513 | `docs.bullet` | `UNPACK_ARGS = table.unpack or unpack` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1514 | `docs.bullet` | Drobna stabilizacja: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1515 | `docs.bullet` | `resolveQuestlogMarker(...)` zwraca pusty string dla `nil` (zamiast potencjalnego `"nil"`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1518 | `docs.bullet` | Domknięcie luki po statycznych stringach questloga: opisy dynamiczne (z licznikami `%d/%s`) też przechodzą przez i18n. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1519 | `docs.bullet` | Zachowanie kompatybilności i bezpiecznego fallbacku bez zmiany logiki questów. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1526 | `docs.bullet` | `tools/export_questlog_translations.py` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1527 | `docs.bullet` | `i18n/en/questlog.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1530 | `docs.bullet` | Rozszerzono ekstraktor questloga o wykrywanie i eksport dynamicznych templatek z funkcji opisów: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1531 | `docs.bullet` | `string.format("...", ...)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1532 | `docs.bullet` | `( "..." ):format(...)` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1533 | `docs.bullet` | Dodano metrykę `dynamic_descriptions` w statystykach eksportu. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1534 | `docs.bullet` | Przegenerowano EN pack questloga: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1535 | `docs.bullet` | łącznie `1,918` kluczy, |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1536 | `docs.bullet` | w tym `21` kluczy `description_dynamic`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1539 | `docs.bullet` | `quests`: 50 |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1540 | `docs.bullet` | `mission names`: 452 |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1541 | `docs.bullet` | `descriptions` (statyczne): 31 |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1542 | `docs.bullet` | `descriptions` (dynamic templates): 21 |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1543 | `docs.bullet` | `states`: 1363 |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1546 | `docs.bullet` | Questlog EN staje się kompletnym źródłem tłumaczeń dla nazw, stanów i opisów (w tym dynamicznych). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1547 | `docs.bullet` | Ułatwia osobny projekt tłumaczeń 54 locale z fallbackiem EN. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1554 | `docs.bullet` | `tools/i18n_pipeline.py` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1557 | `docs.bullet` | Rozszerzono pipeline o etap eksportu questloga: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1558 | `docs.bullet` | `tools/export_questlog_translations.py --locale en ...` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1559 | `docs.bullet` | Dodano flagę: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1560 | `docs.bullet` | `--skip-questlog` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1561 | `docs.bullet` | Zaktualizowano opis pipeline (`extract -> sync -> items -> questlog -> client-export -> report`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1564 | `docs.bullet` | Automatyczna synchronizacja `questlog.json` przy standardowym runie pipeline. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1565 | `docs.bullet` | Eliminacja ryzyka, że nowe/zmienione wpisy w `lib/core/quests.lua` nie trafią do i18n EN. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1570 | `docs.bullet` | `python3 -m py_compile tools/export_questlog_translations.py tools/i18n_pipeline.py` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1571 | `docs.bullet` | `python3 -m json.tool i18n/en/questlog.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1572 | `docs.bullet` | `git diff --check` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1573 | `docs.bullet` | Kontrola liczników w `i18n/en/questlog.json`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1574 | `docs.bullet` | `keys: 1918` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1575 | `docs.bullet` | `quests: 50` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1576 | `docs.bullet` | `mission_names: 452` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1577 | `docs.bullet` | `description: 31` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1578 | `docs.bullet` | `description_dynamic: 21` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1579 | `docs.bullet` | `states: 1363` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1580 | `docs.bullet` | Testów runtime/CI nie uruchamiano (zgodnie z ustaleniem: testy dopiero na GitHub Actions po pełnym domknięciu i18n). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1587 | `docs.bullet` | Audyt kluczy używanych przez runtime localized API w Lua: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1589 | `docs.bullet` | `sendLocalizedMessage` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1590 | `docs.bullet` | `sendLocalizedCancelMessage` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1592 | `docs.bullet` | `addLocalizedBroadcast` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1594 | `docs.bullet` | Wykryto `39` kluczy z legacy placeholderami printf (`%s/%d/%i/%f`) w EN, które są formatowane przez `fmt::vformat` (wymaga `{0}`, `{1}`, ...). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1597 | `docs.bullet` | Hurtowo przekonwertowano placeholdery dla tych kluczy we wszystkich locale JSON: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1598 | `docs.bullet` | `%s/%d/%i/%f` -> `{0}`, `{1}`, ... (kolejność zgodna z wystąpieniem w tekście) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1599 | `docs.bullet` | Zakres plików: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1600 | `docs.bullet` | `i18n/*/quests.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1601 | `docs.bullet` | `i18n/*/scripts.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1603 | `docs.bullet` | usunięto niespójność formatowania między treścią kluczy i runtime formatterem C++. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1606 | `docs.bullet` | Bez tej konwersji część komunikatów localized API wyświetlała surowe `%s`/`%d` zamiast podstawionych argumentów. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1607 | `docs.bullet` | To była blokada jakościowa dla pełnej i18n w questach/skryptach runtime. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1614 | `docs.bullet` | `i18n/*/scripts.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1617 | `docs.bullet` | Dodano brakujący klucz: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1618 | `docs.bullet` | `misc.blessing.msg_1`: `You have received Adventurer's Blessing, which applies up to level {0}!` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1619 | `docs.bullet` | Klucz został dopisany do wszystkich locale `scripts.json` jako fallback EN. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1623 | `docs.bullet` | Eliminacja ostrzeżeń "Missing translation" dla tego komunikatu. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1630 | `docs.bullet` | `data-otservbr-global/scripts/actions/valuables/random_items.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1631 | `docs.bullet` | `i18n/en/scripts.json` (wartość klucza po konwersji placeholderów) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1634 | `docs.bullet` | W `random_items.lua` uproszczono i ustabilizowano budowę argumentu dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1635 | `docs.bullet` | `scripts.random_items.found_in_bag` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1636 | `docs.bullet` | Zamiast składania inline z ryzykiem zbędnych spacji: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1637 | `docs.bullet` | wyliczane jest `itemLabel` (liczba + plural lub article + singular). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1638 | `docs.bullet` | Klucz EN po konwersji placeholderów używa teraz: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1639 | `docs.bullet` | `You found {0} in the bag.` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1642 | `docs.bullet` | Czytelniejszy i bezpieczniejszy runtime (brak artefaktów typu podwójne spacje przy pustym article). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1643 | `docs.bullet` | Spójność z formatterem `fmt`. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1648 | `docs.bullet` | Audyt localized API: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1649 | `docs.bullet` | `used keys: 2101` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1650 | `docs.bullet` | `printf placeholders in used keys: 0` (po konwersji) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1651 | `docs.bullet` | `missing_en: 179` (stan niepogorszony; dotyczy innych obszarów backlogu) |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1652 | `docs.bullet` | Kontrola JSON: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1653 | `docs.bullet` | parsowanie wszystkich `i18n/**/*.json` (bez `.bak/.corrupted`) -> `bad_json_count: 0` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1654 | `docs.bullet` | Kontrola przykładowych kluczy: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1655 | `docs.bullet` | `misc.blessing.msg_1` istnieje i używa `{0}` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1656 | `docs.bullet` | `scripts.random_items.found_in_bag` używa `{0}` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1657 | `docs.bullet` | `scripts.die.rolled` używa `{0}`, `{1}` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1658 | `docs.bullet` | Kontrola whitespace: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1659 | `docs.bullet` | `git diff --check` bez błędów. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1660 | `docs.bullet` | Testów runtime/CI nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1667 | `docs.bullet` | `i18n/en/npclib.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1668 | `docs.bullet` | `i18n/en/libs.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1669 | `docs.bullet` | `i18n/en/scripts.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1672 | `docs.bullet` | Odtworzono i dopisano brakujące teksty EN dla wszystkich kluczy używanych przez runtime localized API, które wcześniej nie miały wpisu w EN. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1673 | `docs.bullet` | Źródło tekstów: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1675 | `docs.bullet` | Zakres dopisanych kluczy: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1676 | `docs.bullet` | `misc.bank_system.say_1..67` -> `npclib.json` (67 kluczy), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1677 | `docs.bullet` | `misc.compat.msg_1`, `misc.daily_reward.msg_1`, `misc.daily_reward.msg_2`, `misc.functions.msg_1`, `misc.hireling.msg_1` -> `libs.json` (5 kluczy), |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1678 | `docs.bullet` | brakujące `scripts.*` używane przez localized API -> `scripts.json` (105 kluczy). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1679 | `docs.bullet` | Naprawiono placeholder dla: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1680 | `docs.bullet` | `misc.bank_system.say_54`: `%d` -> `{0}` (zgodność z formatterem runtime). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1684 | `docs.bullet` | Po tym etapie EN jest kompletnym fallbackiem dla aktualnie używanych kluczy localized API. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1691 | `docs.bullet` | `data/npclib/npc_system/bank_system.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1694 | `docs.bullet` | Poprawiono wywołanie: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1699 | `docs.bullet` | Klucz `misc.bank_system.say_54` zawiera parametr kwoty (`{0}`), więc brak argumentu powodowałby tekst bez podstawionej wartości. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1700 | `docs.bullet` | Zmiana przywraca pełny komunikat potwierdzenia wypłaty z konta gildii. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1705 | `docs.bullet` | Audyt użyć localized API w Lua: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1706 | `docs.bullet` | `used_unique: 1498` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1707 | `docs.bullet` | `missing_en: 0` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1708 | `docs.bullet` | Potwierdzenie obecności przykładowych wcześniej brakujących kluczy: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1709 | `docs.bullet` | `scripts.afk.msg_1..3` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1710 | `docs.bullet` | `scripts.banana_chocolate_shake.msg_2` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1711 | `docs.bullet` | `scripts.reload.msg_2` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1712 | `docs.bullet` | `scripts.vip.msg_1` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1713 | `docs.bullet` | `misc.bank_system.say_1..67` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1714 | `docs.bullet` | Testów runtime/CI nie uruchamiano (zgodnie z ustaleniem: testy na GitHub Actions po pełnym domknięciu i18n). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1721 | `docs.bullet` | `testyy/data/locales/game_i18n_en.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1722 | `docs.bullet` | `testyy/data/locales/game_i18n_en_compact.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1723 | `docs.bullet` | `i18n/keymap.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1724 | `docs.bullet` | `i18n/keymap_rev.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1725 | `docs.bullet` | `i18n/keymap_meta.json` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1728 | `docs.bullet` | Wykonano realny eksport klientowy EN (nie tylko konfiguracja pipeline): |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1729 | `docs.bullet` | `generate_game_i18n(..., compact_keys=False)` -> `game_i18n_en.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1730 | `docs.bullet` | `generate_game_i18n(..., compact_keys=True)` -> `game_i18n_en_compact.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1731 | `docs.bullet` | Eksport zebrał klucze ze wszystkich kategorii `i18n/en/*.json` (w tym wcześniej problematyczne `otclient_modules.json`). |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1732 | `docs.bullet` | Przy eksporcie compact zaktualizowano mapowania `keymap*` o nowe klucze dodane w tym etapie. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1735 | `docs.bullet` | `game_i18n_en.lua`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1736 | `docs.bullet` | `Total translations: 52317` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1737 | `docs.bullet` | zawiera sekcję `otclient_modules` z `1987` kluczami. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1738 | `docs.bullet` | `game_i18n_en_compact.lua`: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1739 | `docs.bullet` | `Total translations: 52317` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1740 | `docs.bullet` | Rozmiar plików po regeneracji: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1741 | `docs.bullet` | `game_i18n_en.lua`: `52456` linii |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1742 | `docs.bullet` | `game_i18n_en_compact.lua`: `52373` linii |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1745 | `docs.bullet` | Domknięcie luki „czy instalka/OTC czyta `otclient_modules.json`” nie tylko na poziomie kodu pipeline, ale też na poziomie realnie wygenerowanego artefaktu klienta. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1751 | `docs.bullet` | Potwierdzono obecność kluczy `otclient_modules.*` w: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1752 | `docs.bullet` | `testyy/data/locales/game_i18n_en.lua` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1753 | `docs.bullet` | Potwierdzono obecność świeżo dopisanych kluczy runtime: |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1754 | `docs.bullet` | `misc.bank_system.say_54` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1755 | `docs.bullet` | `scripts.banana_chocolate_shake.msg_2` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1756 | `docs.bullet` | `scripts.vip.msg_1` |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1757 | `docs.bullet` | Potwierdzono wpisy compact w `i18n/keymap.json` i `i18n/keymap_rev.json` dla nowych kluczy. |
| `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` | 1758 | `docs.bullet` | Testów runtime/CI nie uruchamiano (zgodnie z ustaleniem projektowym). |
| `docs/I18N_PL_ROADMAP.md` | 4 | `docs.bullet` | Uruchom migrację `53` (`data-otservbr-global/migrations/53.lua`) lub równoważne polecenia SQL (`ALTER TABLE players ADD COLUMN locale ...`). |
| `docs/I18N_PL_ROADMAP.md` | 5 | `docs.bullet` | Ustaw `serverDefaultLocale = "pl"` w `config.lua`, zrestartuj serwer i potwierdź w logach, że ładowane są odpowiednie katalogi `i18n`. |
| `docs/I18N_PL_ROADMAP.md` | 8 | `docs.bullet` | Rozszerz `ProtocolLogin/ProtocolGame`, by klient zgłaszał kod języka już podczas logowania (np. `pl`, `en`). |
| `docs/I18N_PL_ROADMAP.md` | 9 | `docs.bullet` | Dostosuj pakiety tak, aby serwer mógł wysyłać zlokalizowane klucze/teksty oraz fallback do EN, jeśli tłumaczenie nie istnieje. |
| `docs/I18N_PL_ROADMAP.md` | 10 | `docs.bullet` | Po stronie klienta (testyy) ustaw przekazywanie `locale` przy logowaniu. |
| `docs/I18N_PL_ROADMAP.md` | 13 | `docs.bullet` | Sukcesywnie zamieniaj hardkodowane teksty (NPC, questy, system) na klucze w `i18n/<locale>/*.json`. |
| `docs/I18N_PL_ROADMAP.md` | 14 | `docs.bullet` | Priorytet: NPC/dialogi → questy → komunikaty systemowe → wiadomości walki. |
| `docs/I18N_PL_ROADMAP.md` | 15 | `docs.bullet` | Uzupełniaj `pl/*.json`, pilnuj, by `en/*.json` zawierał pełny zestaw bazowy. |
| `docs/I18N_PL_ROADMAP.md` | 18 | `docs.bullet` | Rozbuduj pipeline wokół `tools/export_items_translations.py` o narzędzia raportujące pokrycie i generujące CSV/arkusze dla tłumaczy. |
| `docs/I18N_PL_ROADMAP.md` | 19 | `docs.bullet` | Automatyzuj eksport tekstów (np. z Lua/C++) i przygotuj zestawy danych dla tłumaczy w formatach przyjaznych CAT/arkuszom. |
| `docs/I18N_PL_ROADMAP.md` | 20 | `docs.bullet` | Utrzymuj statystyki (ile kluczy ma tłumaczenie, ile czeka na uzupełnienie). |
| `docs/I18N_PL_ROADMAP.md` | 21 | `docs.bullet` | Skrypt `python tools/i18n_pipeline.py --locales pl [inne]` odpala kompletną sekwencję (extract ➜ sync ➜ items ➜ report) i zapisuje CSV w `i18n/reports`. Uruchamiaj go po każdej większej zmianie danych przed przekazaniem paczki drugiemu agentowi. |
| `docs/I18N_PL_ROADMAP.md` | 24 | `docs.bullet` | Przygotuj smoke-test NPC/komunikatów dla różnych `locale` i włącz go do CI. |
| `docs/I18N_PL_ROADMAP.md` | 25 | `docs.bullet` | W workflow (np. `analysis-sonarcloud-android.yml`) dodaj krok weryfikujący, że nowe klucze mają wpisy w EN oraz że nie znikają obowiązkowe tłumaczenia PL. |
| `docs/I18N_PL_ROADMAP.md` | 31 | `docs.paragraph` | Jeśli w `canary` znajdują się nowsze lokalizacje lub narzędzia, |
| `docs/I18N_PL_ROADMAP.md` | 32 | `docs.bullet` | `silnik/canary_test/data-otservbr-global/scripts/quests/bigfoot_burden/*` oraz odpowiadające `i18n/*/player.json` zawierają te same klucze, co wersja serwerowa, |
| `docs/I18N_PL_ROADMAP.md` | 33 | `docs.bullet` | nowe biblioteki (np. `lib/npc/i18n.lua`) istnieją w `canary_test` i są wczytywane przez `lib/lib.lua`. |
| `docs/I18N_PL_ROADMAP.md` | 35 | `docs.bullet` | **Prey / Task Hunting** – komunikaty o wygaśnięciu bonusa zostały przeniesione na klucze `player.prey.*` (`src/io/ioprey.cpp:255`, tłumaczenia w `i18n/en\|pl/player.json`). Kolejny agent może kontynuować w tym module od funkcji `parsePreyAction` (komunikaty `sendMessageDialog` wymagają helpera). |
| `docs/I18N_PL_ROADMAP.md` | 36 | `docs.bullet` | **Testy tłumacza** – `tests/unit/i18n/translator_test.cpp` ma nowy przypadek pokrywający flatten tablic (`ui.dialog[1]`) i obsługę błędów formatowania. Przy dodawaniu nowych funkcji w `Translator` dopisuj regresję w tym pliku. |
| `docs/I18N_PL_ROADMAP.md` | 37 | `docs.bullet` | **Tooling krok 4** – komplet kroków (extract ➜ sync ➜ items ➜ report) opisany jest w `testyy/docs/ci-cd/I18N_BUILD_CHECKLIST.md:13`; uruchamiaj ten pipeline po każdej większej refaktoryzacji tekstów, aby drugi agent miał świeże `system.json` i CSV. |
| `docs/I18N_PL_ROADMAP.md` | 38 | `docs.bullet` | **Dialogi Prey/Task** – dodano `Player::sendLocalizedMessageDialog` oraz klucze `player.prey.dialog.*` / `player.task.dialog.*`, dzięki czemu całe `IOPrey::parsePreyAction` i `parseTaskHuntingAction` są przetłumaczone (`src/io/ioprey.cpp:300`). Helper został też użyty w logice skrytki (`player.stash.dialog.*`), więc kolejne moduły mogą go podłączać przy okazji. |
| `docs/I18N_PL_ROADMAP.md` | 39 | `docs.bullet` | **Lista locale** – `Translator::supportedLocales()` została rozszerzona do pełnego zestawu 50+ języków klienta; test regresyjny dodany w `tests/unit/i18n/translator_test.cpp` (sprawdza m.in. pl/zh/ar/ca). |
| `docs/I18N_PL_ROADMAP.md` | 40 | `docs.bullet` | **Quick loot summary** – `Game::playerQuickLootCorpse` korzysta teraz z kluczy `game.loot.summary.*` (EN/PL w `i18n/*/game.json`). Drugi agent może dzięki temu uzupełnić tłumaczenia kolejnych języków tylko na podstawie JSON/CSV, bez zmian w C++. Następny kandydat do lokalizacji (dla agenta 2) to komunikaty login/premium w `data-otservbr-global/scripts/creaturescripts/others/login.lua`. |
| `docs/I18N_PL_ROADMAP.md` | 41 | `docs.bullet` | **Pipeline ownership** – Agent 1 (serwer C++) utrzymuje logikę i klucze, agent 2 uruchamia `python tools/i18n_pipeline.py --locales pl de` po zmianach w danych i dostarcza świeże `i18n/reports/*.csv` razem z PR. W razie konfliktu w JSONach bazowych, uzgadniamy kolejność w tym pliku. |
| `docs/I18N_PL_ROADMAP.md` | 44 | `docs.bullet` | Quick loot: zlokalizowano komunikaty „No loot” oraz ostrzeżenia o ciężarze/pełnym kontenerze w `src/game/game.cpp` z kluczami `game.loot.*` (EN/PL dodane do `i18n/*/system.json`). |
| `docs/I18N_PL_ROADMAP.md` | 46 | `docs.bullet` | Do rozważenia kolejne kroki: wyniesienie pozostałych tekstów quick loot (złożone podsumowanie) na klucze; objęcie `game.cpp` sekcji trade/loot zgodnie z tabelą priorytetów. |
| `docs/I18N_PL_ROADMAP.md` | 49 | `docs.bullet` | [x] Wynieść podsumowanie quick loot w `game.cpp` na klucze i18n (skrócone warianty z parametrami zamiast łańcucha `ss <<`). |
| `docs/I18N_PL_ROADMAP.md` | 50 | `docs.bullet` | [x] Uruchomić pipeline extract→report dla kolejnych języków (es/pt/de) i dostarczyć CSV w `i18n/reports/` dla tłumaczy. |
| `docs/I18N_PL_ROADMAP.md` | 51 | `docs.bullet` | [x] Rozpocząć lokalizację komunikatów z sekcji “System loot / status” w `game.cpp:3036-3069` i “Login/premium flow” w `scripts/creaturescripts/others/login.lua` zgodnie z priorytetami (pierwszy moduł: login). |
| `docs/I18N_PL_ROADMAP.md` | 52 | `docs.bullet` | [ ] Bigfoot – **teleporty i zadania**: doprowadzić `movements_warzone_*`, `movements_gnomebase_teleport.lua` i `movements_task_*` do 100% i18n (nowe klucze `quests.bigfoot_burden.warzone_*`, `quests.bigfoot_burden.task_*`). |
| `docs/I18N_PL_ROADMAP.md` | 53 | `docs.bullet` | [ ] **Helper NPC i migracja**: stworzyć `lib/npc/i18n.lua`, dołączyć go w `lib/lib.lua` i przenieść przynajmniej 5 NPC (`a_*`) na nowe klucze `npc.<name>.*`. |
| `docs/I18N_PL_ROADMAP.md` | 54 | `docs.bullet` | [ ] **C++ systemy**: po Lua przejść do `src/game/game.cpp` (trade/market) oraz `player.cpp` (stash/task dialogi) – wszystkie `sendTextMessage` → lokalizowane klucze. |
| `docs/I18N_PL_ROADMAP.md` | 55 | `docs.bullet` | [ ] **CI + tooling**: krok `python tools/i18n_pipeline.py --locales pl es pt de` w workflowu serwera i klienta + smoke-test locale (doc: `docs/I18N_TESTS_SERVER.md`). |
| `docs/I18N_PL_ROADMAP.md` | 58 | `docs.bullet` | Quick loot summary w `game.cpp` w pełni na kluczach `game.loot.summary.*` (EN/PL w `i18n/*/system.json`), ostrzeżenia `game.loot.too_heavy/container_full` już używane. |
| `docs/I18N_PL_ROADMAP.md` | 60 | `docs.bullet` | Lokale es/pt/de zainicjowane kopiami EN (`items.json`, `player.json`, `system.json`, `game.json`); pipeline (`python tools/i18n_pipeline.py --locales pl es pt de`) przechodzi i generuje świeże CSV w `i18n/reports/{pl,es,pt,de}.csv`. |
| `docs/I18N_PL_ROADMAP.md` | 61 | `docs.bullet` | Naprawiono `tools/i18n_pipeline.py` (błędne wcięcia w parserze argumentów) i uruchomiono pełny przebieg extract ➜ sync ➜ items ➜ report, dzięki czemu drugi agent może odpalać jedno polecenie po każdej zmianie danych. |
| `docs/I18N_PL_ROADMAP.md` | 62 | `docs.bullet` | Posprzątano JSON `i18n/pl/system.json` (wcześniej zdublowane wpisy `game.loot.summary.*` łamały parser). |
| `docs/I18N_PL_ROADMAP.md` | 63 | `docs.bullet` | `data-otservbr-global/scripts/creaturescripts/others/dawnport.lua` korzysta z nowych kluczy `player.dawnport.*`; EN/PL dodane do `i18n/*/player.json`. Trzeba dopisać tłumaczenia w pozostałych locale po stronie agenta 2. |
| `docs/I18N_PL_ROADMAP.md` | 64 | `docs.bullet` | `data-otservbr-global/scripts/creaturescripts/others/rookgaard_advance.lua` wysyła teraz `player.rookgaard.ready` – również wymaga uzupełnienia tłumaczeń w es/pt/de. |
| `docs/I18N_PL_ROADMAP.md` | 65 | `docs.bullet` | `playerUseHotkey` (loot pojedynczego ciała) w `src/game/game.cpp` korzysta z kluczy `game.loot.pickup.*`, `game.loot.pickup_failed.*`, `game.loot.corpses_many`, `game.loot.gold_pouch_only`, `game.loot.container_not_held`. Wszystkie dodałem do `i18n/en\|pl/game.json`; proszę zsynchronizować inne języki. |
| `docs/I18N_PL_ROADMAP.md` | 66 | `docs.bullet` | `data-otservbr-global/lib/quests/svargrond_arena.lua` wysyła teraz `quests.svargrond_arena.time_out`. EN/PL uzupełnione w `i18n/*/player.json`; pozostałe języki do zsynchronizowania przez agenta 2. |
| `docs/I18N_PL_ROADMAP.md` | 69 | `docs.bullet` | **Odpowiedź:** Pipeline został naprawiony i działa dla `pl es pt de` (log z ostatniego przebiegu znajduje się w historii terminala). CSV w `i18n/reports/*.csv` są świeże i zsynchronizowane z najnowszym `system.json`. |
| `docs/I18N_PL_ROADMAP.md` | 70 | `docs.bullet` | **Nowe pytanie:** Czy możesz uzupełnić tłumaczenia `player.login.*` w świeżo utworzonych locale (es/pt/de) i – jeśli masz chwilę – dodać krok uruchamiający `python tools/i18n_pipeline.py --locales pl es pt de` do swojego workflow/CI? Dzięki temu unikniemy ręcznych raportów przy kolejnych PR. |
| `docs/I18N_PL_ROADMAP.md` | 71 | `docs.bullet` | **Aktualnie w toku:** Lokalizuję moduły Dawnport (creaturescripts). Jeśli przejmiesz kolejne pliki z folderu `creaturescripts/others`, daj znać w tej sekcji, żebyśmy się nie dublowali. |
| `docs/I18N_PL_ROADMAP.md` | 72 | `docs.bullet` | **Kolejna prośba:** Po zakończeniu mini-sprintu 1 dopisz tłumaczenia `player.dawnport.*` oraz `player.rookgaard.ready` do `es/pt/de` i uruchom pipeline – dzięki temu QA dostanie kompletne CSV dla nowych modułów. |
| `docs/I18N_PL_ROADMAP.md` | 80 | `docs.bullet` | `player.login.premium_expired` (ES/PT/DE) |
| `docs/I18N_PL_ROADMAP.md` | 81 | `docs.bullet` | `player.login.house_lost` (ES/PT/DE) – już były przetłumaczone |
| `docs/I18N_PL_ROADMAP.md` | 82 | `docs.bullet` | `player.login.house_items_inbox` (ES/PT/DE) – już były przetłumaczone |
| `docs/I18N_PL_ROADMAP.md` | 85 | `docs.bullet` | poisoned, drowning, paralyzed, drunk, hexed, rooted, feared, cursed, freezing, dazzled, bleeding |
| `docs/I18N_PL_ROADMAP.md` | 86 | `docs.bullet` | + player.status.cleanse |
| `docs/I18N_PL_ROADMAP.md` | 89 | `docs.bullet` | Wszystkie dialogi prey slot, bonus reset, cards missing itp. |
| `docs/I18N_PL_ROADMAP.md` | 90 | `docs.bullet` | Wszystkie dialogi task hunting (unlock, reroll, reward itp.) |
| `docs/I18N_PL_ROADMAP.md` | 93 | `docs.bullet` | stash.retrieved, stash.dialog.capacity_none/partial, stash.dialog.space_none/partial |
| `docs/I18N_PL_ROADMAP.md` | 96 | `docs.bullet` | level8, level20, magic_limit, skill_limit |
| `docs/I18N_PL_ROADMAP.md` | 101 | `docs.bullet` | Wszystkie warianty podsumowania lootu (gold, items, partial itp.) |
| `docs/I18N_PL_ROADMAP.md` | 104 | `docs.bullet` | withdraw_limit, not_possible, move_closer, item_busy, item_limit, item_untradeable, request |
| `docs/I18N_PL_ROADMAP.md` | 107 | `docs.bullet` | **pl:** 39564/39564 (100%), brak brakujących, 39487 identycznych z EN (głównie items) |
| `docs/I18N_PL_ROADMAP.md` | 108 | `docs.bullet` | **es:** 39564/39564 (100%), brak brakujących, 39487 identycznych z EN |
| `docs/I18N_PL_ROADMAP.md` | 109 | `docs.bullet` | **pt:** 39564/39564 (100%), brak brakujących, 39487 identycznych z EN |
| `docs/I18N_PL_ROADMAP.md` | 110 | `docs.bullet` | **de:** 39564/39564 (100%), brak brakujących, 39487 identycznych z EN |
| `docs/I18N_PL_ROADMAP.md` | 112 | `docs.paragraph` | CSV zaktualizowane w `i18n/reports/{pl,es,pt,de}.csv`. |
| `docs/I18N_PL_ROADMAP.md` | 120 | `docs.bullet` | Folder `creaturescripts/others` jest w pełni zlokalizowany (login.lua, dawnport.lua, rookgaard_advance.lua). |
| `docs/I18N_PL_ROADMAP.md` | 121 | `docs.bullet` | Następny krok: quest Soul War (`lib/quests/soul_war.lua`) – 7 komunikatów do wyciągnięcia na klucze `quests.soul_war.*`. |
| `docs/I18N_PL_ROADMAP.md` | 122 | `docs.bullet` | Alternatywnie: lokalizacja kolejnych sekcji w `game.cpp` (trade dialogs, loot warnings). |
| `docs/I18N_PL_ROADMAP.md` | 123 | `docs.bullet` | **W repo jest 715 plików Lua z `sendTextMessage`** – warto ustalić priorytety przed masową migracją. |
| `docs/I18N_PL_ROADMAP.md` | 136 | `docs.paragraph` | Widzę, że agent 1 zadeklarował Soul War, ale już go wykonałem! Oto co zrobiłem: |
| `docs/I18N_PL_ROADMAP.md` | 139 | `docs.bullet` | `quests.soul_war.taint_gained` – "You have gained the {0}." |
| `docs/I18N_PL_ROADMAP.md` | 140 | `docs.bullet` | `quests.soul_war.taints_reset` – "Your Goshnar's taints have been reset." |
| `docs/I18N_PL_ROADMAP.md` | 141 | `docs.bullet` | `quests.soul_war.taints_reset_timeout` – z dopiskiem o 14 dniach |
| `docs/I18N_PL_ROADMAP.md` | 142 | `docs.bullet` | `quests.soul_war.dread_start` – poziom grozy 5 |
| `docs/I18N_PL_ROADMAP.md` | 143 | `docs.bullet` | `quests.soul_war.dread_unbearable` – poziom grozy 15 |
| `docs/I18N_PL_ROADMAP.md` | 144 | `docs.bullet` | `quests.soul_war.dread_tear_apart` – poziom grozy 24 |
| `docs/I18N_PL_ROADMAP.md` | 145 | `docs.bullet` | `quests.soul_war.dread_killing` – poziom grozy 30 |
| `docs/I18N_PL_ROADMAP.md` | 146 | `docs.bullet` | `quests.soul_war.dread_lethal` – poziom grozy 36 |
| `docs/I18N_PL_ROADMAP.md` | 153 | `docs.bullet` | `game.loot.none`, `game.loot.too_heavy`, `game.loot.container_full` |
| `docs/I18N_PL_ROADMAP.md` | 154 | `docs.bullet` | `game.loot.pickup.gold`, `game.loot.pickup.item` |
| `docs/I18N_PL_ROADMAP.md` | 155 | `docs.bullet` | `game.loot.pickup_failed.gold`, `game.loot.pickup_failed.item` |
| `docs/I18N_PL_ROADMAP.md` | 156 | `docs.bullet` | `game.loot.corpses_many`, `game.loot.gold_pouch_only`, `game.loot.container_not_held` |
| `docs/I18N_PL_ROADMAP.md` | 159 | `docs.bullet` | **39582 kluczy** w każdym locale |
| `docs/I18N_PL_ROADMAP.md` | 160 | `docs.bullet` | **100% pokrycia** dla pl/es/pt/de |
| `docs/I18N_PL_ROADMAP.md` | 161 | `docs.bullet` | **0 literalnych `sendTextMessage`** w `soul_war.lua` ✨ |
| `docs/I18N_PL_ROADMAP.md` | 167 | `docs.paragraph` | Skoro Soul War jest gotowy, oto co możesz wziąć: |
| `docs/I18N_PL_ROADMAP.md` | 175 | `docs.bullet` | Tłumaczyć kolejne questy po wyodrębnieniu kluczy przez agenta 1 |
| `docs/I18N_PL_ROADMAP.md` | 176 | `docs.bullet` | Przygotować helper `i18nNpcMessage` dla mini-sprintu 4 |
| `docs/I18N_PL_ROADMAP.md` | 177 | `docs.bullet` | Dodać krok pipeline do CI/workflow |
| `docs/I18N_PL_ROADMAP.md` | 178 | `docs.bullet` | Uzupełniać tłumaczenia dla nowych kluczy ES/PT/DE |
| `docs/I18N_PL_ROADMAP.md` | 186 | `docs.bullet` | ✅ Wypełniono `player.login.*`, `player.condition.*`, `player.prey.*`, `player.task.*`, `player.stash.*`, `player.dawnport.*`, `player.rookgaard.*` w es/pt/de. |
| `docs/I18N_PL_ROADMAP.md` | 187 | `docs.bullet` | ✅ Pipeline działa, CSV w `i18n/reports/` zsynchronizowane (100% pokrycia dla wszystkich 4 języków). |

_Truncated: showing 2000 of 12230 entries._
