# data-otservbr-global/lib/quests/soul_war.lua

**Kind:** Library Lua script  
**Size:** 63459 bytes | **Lines:** 1580  
**Tags:** `action`, `addon`, `ban`, `boss`, `callback`, `combat`, `condition`, `config`, `creature`, `door`, `effect`, `event`, `global`, `item`, `lever`, `library`, `load`, `loot`, `lua`, `map`, `monster`, `mount`, `outfit`, `player`, `position`, `quest`, `raid`, `register`, `reward`, `spell`, `storage`, `teleport`, `tile`, `war`

## Opis funkcjonalny

Library Lua script — Library Lua script | 49 symbols | 1580 lines

## Symbole

| Nazwa | Typ | Linia |
|---|---|---|
| `RegisterSoulWarBossesLevers` | lua_function | L816 |
| `CreateGoshnarsGreedMonster` | lua_function | L912 |
| `RemoveSoulCageAndBuffMalice` | lua_function | L929 |
| `SpawnSoulCage` | lua_function | L945 |
| `shuffle` | lua_function | L956 |
| `createConnectedGroup` | lua_function | L963 |
| `generatePositionsInRange` | lua_function | L1000 |
| `revertTilesAndApplyDamage` | lua_function | L1021 |
| `Monster:createSoulWarWhiteTiles` | lua_function | L1060 |
| `MonsterType:calculateBagYouDesireChance` | lua_function | L1100 |
| `Monster:onThinkMegalomaniaWhiteTiles` | lua_function | L1147 |
| `Player:getTaintNameByNumber` | lua_function | L1164 |
| `Player:addNextTaint` | lua_function | L1175 |
| `Player:setTaintIcon` | lua_function | L1187 |
| `Player:resetTaintConditions` | lua_function | L1194 |
| `Player:getTaintLevel` | lua_function | L1200 |
| `Player:resetTaints` | lua_function | L1212 |
| `Monster:tryTeleportToPlayer` | lua_function | L1236 |
| `Monster:getSoulWarKV` | lua_function | L1295 |
| `Monster:getHatredDamageMultiplier` | lua_function | L1299 |
| `Monster:increaseHatredDamageMultiplier` | lua_function | L1303 |
| `Monster:resetHatredDamageMultiplier` | lua_function | L1308 |
| `Position:increaseNecromaticMegalomaniaStrength` | lua_function | L1312 |
| `Monster:onThinkGoshnarTormentCounter` | lua_function | L1346 |
| `Monster:increaseAspectOfPowerDeathCount` | lua_function | L1396 |
| `Monster:goshnarsDefenseIncrease` | lua_function | L1419 |
| `Monster:removeGoshnarsMegalomaniaMonsters` | lua_function | L1438 |
| `Player:getSoulWarZoneMonster` | lua_function | L1453 |
| `Creature:isInBoatSpot` | lua_function | L1466 |
| `Player:soulWarQuestKV` | lua_function | L1483 |
| `Player:getGoshnarSymbolTormentCounter` | lua_function | L1487 |
| `Player:increaseGoshnarSymbolTormentCounter` | lua_function | L1492 |
| `Player:removeGoshnarSymbolTormentCounter` | lua_function | L1504 |
| `Player:resetGoshnarSymbolTormentCounter` | lua_function | L1515 |
| `Player:furiousCraterKV` | lua_function | L1521 |
| `Player:pulsatingEnergyKV` | lua_function | L1525 |
| `Zone:getRandomPlayer` | lua_function | L1529 |
| `delayedCastSpell` | lua_function | L1541 |
| `Creature:applyZoneEffect` | lua_function | L1554 |
| `soulWarTaints` | lua_variable | L896 |
| `toRevertPositions` | lua_variable | L1010 |
| `tileItemIds` | lua_variable | L1012 |
| `intervalBetweenExecutions` | lua_variable | L1141 |
| `accumulatedTime` | lua_variable | L1143 |
| `desiredInterval` | lua_variable | L1144 |
| `bossSayInterval` | lua_variable | L1145 |
| `lastExecutionTime` | lua_variable | L1327 |
| `damageTable` | lua_variable | L1330 |
| `conditionOutfit` | lua_variable | L1539 |
