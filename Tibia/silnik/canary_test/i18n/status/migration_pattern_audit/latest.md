# Migration Pattern Audit

- Generated: `2026-02-24T22:23:42.674774Z`
- Scope: `server`
- Files scanned: **5736**
- Total hits: **17744**
- Supported hits: **16971**
- Unsupported hits: **773**

## Pattern Summary

| Pattern | Family | Supported | Hits | Recommendation |
|---|---|---|---:|---|
| `xml_items_name_desc_literal` | `xml_visible` | yes | 16693 | covered (resync to i18n/en/items.json, range-aware) |
| `xml_visible_attrs_literal` | `xml_visible` | no | 548 | define xml-to-i18n migration policy per domain (items/monsters/ui xml) |
| `npc_voices_text` | `npc_dialogue` | yes | 257 | covered |
| `cpp_runtime_text_calls` | `cpp_runtime` | no | 101 | add dedicated C++ migrator (wrapper i18n::get / key registry) before auto-migration |
| `lua_say_concat_or_dynamic` | `lua_say` | no | 66 | extend generic i18n_migrate_lua_say.py for concat/table/dynamic outside NPC stage4 |
| `otclient_tr_dynamic` | `otclient_tr` | no | 42 | manual review: dynamic tr() source cannot be key-generated safely |
| `lua_sendtext_concat_or_dynamic` | `lua_sendtext` | no | 13 | extend i18n_migrate_lua_sendtext.py for concat/variable sources |
| `lua_sendtext_string_format` | `lua_sendtext` | yes | 10 | covered |
| `lua_sendtext_literal` | `lua_sendtext` | yes | 5 | covered |
| `lua_say_literal` | `lua_say` | yes | 4 | covered |
| `lua_broadcast_dynamic` | `lua_broadcast` | no | 3 | extend i18n_migrate_lua_broadcast.py for concat/variables |
| `lua_say_string_format` | `lua_say` | yes | 1 | covered |
| `npc_stdmodule_text` | `npc_dialogue` | yes | 1 | covered |
| `lua_broadcast_literal_or_format` | `lua_broadcast` | yes | 0 | covered |
| `npc_greet_farewell_text` | `npc_dialogue` | yes | 0 | covered |
| `otclient_tr_literal` | `otclient_tr` | yes | 0 | covered |
| `otui_other_visible_attrs_literal` | `otclient_otui` | yes | 0 | covered |
| `otui_text_literal` | `otclient_otui` | yes | 0 | covered |

## Unsupported Samples

| Pattern | File | Line | Snippet |
|---|---|---:|---|
| `cpp_runtime_text_calls` | `src/canary_server.cpp` | 296 | return compiler = fmt::format("Clang++ {}.{}.{}", __clang_major__, __clang_minor__, __clang_patchlevel__); |
| `cpp_runtime_text_calls` | `src/canary_server.cpp` | 298 | return compiler = fmt::format("Microsoft Visual Studio {}", _MSC_VER); |
| `cpp_runtime_text_calls` | `src/canary_server.cpp` | 300 | return compiler = fmt::format("G++ {}.{}.{}", __GNUC__, __GNUC_MINOR__, __GNUC_PATCHLEVEL__); |
| `cpp_runtime_text_calls` | `src/canary_server.cpp` | 425 | throw FailedToInitializeCanary(fmt::format("Cannot load: {}", moduleName)); |
| `cpp_runtime_text_calls` | `src/creatures/creature.cpp` | 716 | lootMessage = fmt::format("{} ({})", lootMessage, suffix); |
| `cpp_runtime_text_calls` | `src/creatures/creature.cpp` | 1224 | TextMessage message(MESSAGE_EXPERIENCE_OTHERS, fmt::format("{} gained {} experience point{}.", ucfirst(getNameDescription()), gainExp, (gainExp != 1 ? "s" : "") |
| `cpp_runtime_text_calls` | `src/creatures/players/components/player_cyclopedia.cpp` | 64 | std::string cause = fmt::format("Died at Level {}", result->getNumber<uint32_t>("level")); |
| `cpp_runtime_text_calls` | `src/creatures/players/components/player_cyclopedia.cpp` | 67 | cause.append(fmt::format(" by{}", formatWithArticle(killed_by))); |
| `cpp_runtime_text_calls` | `src/creatures/players/components/player_cyclopedia.cpp` | 126 | entries.emplace_back(fmt::format("Killed {}.", name), result->getNumber<uint32_t>("time"), status); |
| `cpp_runtime_text_calls` | `src/creatures/players/components/wheel/player_wheel.cpp` | 1845 | const auto query = fmt::format("{}, {}", m_player.getGUID(), g_database().escapeBlob(attributes, static_cast<uint32_t>(attributesSize))); |
| `cpp_runtime_text_calls` | `src/creatures/players/components/wheel/player_wheel.cpp` | 3871 | return fmt::format("[PlayerWheelGem] uuid: {}, locked: {}, affinity: {}, quality: {}, basicModifier1: {}, basicModifier2: {}, supremeModifier: {}", uuid, locked |
| `cpp_runtime_text_calls` | `src/creatures/players/player.cpp` | 213 | ? fmt::format("cpp.title.name_{}_female", titleData.m_id) |
| `cpp_runtime_text_calls` | `src/creatures/players/player.cpp` | 214 | : fmt::format("cpp.title.name_{}", titleData.m_id); |
| `cpp_runtime_text_calls` | `src/creatures/players/player.cpp` | 224 | const std::string key = fmt::format("cpp.vocation.desc_id_{}", vocation->getId()); |
| `cpp_runtime_text_calls` | `src/creatures/players/player.cpp` | 2445 | const auto key = fmt::format("item.{}.name", itemType.id); |
| `cpp_runtime_text_calls` | `src/creatures/players/player.cpp` | 2452 | const auto legacyKey = fmt::format("items.{}.name", itemType.id); |
| `cpp_runtime_text_calls` | `src/creatures/players/player.cpp` | 3547 | expString = expString + tr.format("cpp.player.exp_animus_bonus", loc, {fmt::format("{:.1f}", (animusMasteryMultiplier - 1) * 100)}); |
| `cpp_runtime_text_calls` | `src/creatures/players/player.cpp` | 5421 | damage.exString = fmt::format("(hazard -{}%)", stage / 100.); |
| `cpp_runtime_text_calls` | `src/creatures/players/player.cpp` | 7801 | fmt::format("{:.2f}", oldPercentToNextLevel), |
| `cpp_runtime_text_calls` | `src/creatures/players/player.cpp` | 7804 | fmt::format("{:.2f}", newPercentToNextLevel), |
| `cpp_runtime_text_calls` | `src/creatures/players/player.cpp` | 9304 | const std::string blessKey = fmt::format("cpp.player.blessing_name_{}", blessId); |
| `cpp_runtime_text_calls` | `src/database/database.cpp` | 79 | std::string formattedDate = fmt::format("{:%Y-%m-%d}", *std::localtime(&now_c)); |
| `cpp_runtime_text_calls` | `src/database/database.cpp` | 80 | std::string formattedTime = fmt::format("{:%H-%M-%S}", *std::localtime(&now_c)); |
| `cpp_runtime_text_calls` | `src/database/database.cpp` | 83 | std::string backupDir = fmt::format("database_backup/{}/", formattedDate); |
| `cpp_runtime_text_calls` | `src/database/database.cpp` | 85 | std::string backupFileName = fmt::format("{}backup_{}.sql", backupDir, formattedTime); |
| `cpp_runtime_text_calls` | `src/game/game.cpp` | 724 | throw std::ios_base::failure(fmt::format("Failed to create custom map directory {}", customMapPath.string())); |
| `cpp_runtime_text_calls` | `src/game/game.cpp` | 7495 | std::string attackMsg = fmt::format("{} attack", damage.critical ? "critical " : " "); |
| `cpp_runtime_text_calls` | `src/game/game.cpp` | 8828 | query += fmt::format(", @ourRow := IF(`id` = {}, @row - 1, @ourRow) AS `rw`", playerGUID); |
| `cpp_runtime_text_calls` | `src/game/game.cpp` | 8850 | query += fmt::format("`rn` > {} AND `rn` <= {}", startPage, endPage); |
| `cpp_runtime_text_calls` | `src/game/zones/zone.hpp` | 45 | return fmt::format("Area(from: {}, to: {})", from.toString(), to.toString()); |
| `cpp_runtime_text_calls` | `src/io/functions/iologindata_load_player.cpp` | 250 | player->addBlessing(static_cast<uint8_t>(i), static_cast<uint8_t>(result->getNumber<uint16_t>(fmt::format("blessings{}", i)))); |
| `cpp_runtime_text_calls` | `src/io/io_bosstiary.cpp` | 96 | query += fmt::format("`raceid` = '{}'", bossId); |
| `cpp_runtime_text_calls` | `src/io/iobestiary.cpp` | 31 | charmDamage.exString += fmt::format("({} charm)", asLowerCaseString(charm->name)); |
| `cpp_runtime_text_calls` | `src/io/iobestiary.cpp` | 132 | charmDamage.exString += fmt::format("({} charm)", asLowerCaseString(charm->name)); |
| `cpp_runtime_text_calls` | `src/io/iomap.cpp` | 143 | throw IOMapException(fmt::format("[x:{}, y:{}, z:{}] Could not create house id: {}", x, y, z, tile->houseId)); |
| `cpp_runtime_text_calls` | `src/io/iomap.cpp` | 193 | throw IOMapException(fmt::format("[x:{}, y:{}, z:{}] Failed to load item {}, Node Type.", x, y, z, id)); |
| `cpp_runtime_text_calls` | `src/io/iomap.cpp` | 214 | throw IOMapException(fmt::format("[x:{}, y:{}, z:{}] Invalid zone id.", x, y, z)); |
| `cpp_runtime_text_calls` | `src/io/iomap.cpp` | 221 | throw IOMapException(fmt::format("[x:{}, y:{}, z:{}] Could not read item/zone node.", x, y, z)); |
| `cpp_runtime_text_calls` | `src/io/iomap.cpp` | 225 | throw IOMapException(fmt::format("[x:{}, y:{}, z:{}] Could not end node.", x, y, z)); |
| `cpp_runtime_text_calls` | `src/io/iomap.cpp` | 230 | throw IOMapException(fmt::format("[x:{}, y:{}, z:{}] Could not end node.", x, y, z)); |
| `cpp_runtime_text_calls` | `src/items/containers/container.cpp` | 256 | descriptions.push_back(fmt::format("{{{}\|{}}}", item->getID(), item->getNameDescription())); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 1434 | attackDescription = fmt::format("{} {}", it.abilities->elementDamage, getCombatName(it.abilities->elementType)); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 1482 | ss << fmt::format("{} {:+}%", getCombatName(indexToCombatType(i)), it.abilities->absorbPercent[i]); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 1629 | ss << fmt::format("{} {:+}%", getCombatName(indexToCombatType(i)), it.abilities->fieldAbsorbPercent[i]); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 1852 | attackDescription = fmt::format("{} {}", it.abilities->elementDamage, getCombatName(it.abilities->elementType)); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 1895 | ss << fmt::format("{} {:+}%", getCombatName(indexToCombatType(i)), it.abilities->absorbPercent[i]); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 2027 | ss << fmt::format("{} {:+}%", getCombatName(indexToCombatType(i)), it.abilities->fieldAbsorbPercent[i]); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 2200 | s << fmt::format("{} {} {:02}:{:02}h", baseImbuement->name, imbuementInfo.imbuement->getName(), hours, minutes % 60); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 2298 | effectDescription = fmt::format(" ({})", tr.format("cpp.look.tier_onslaught", locStr, {fmt::format("{:.2f}", item->getFatalChance())})); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 2302 | effectDescription = fmt::format(" ({})", tr.format("cpp.look.tier_momentum", locStr, {fmt::format("{:.2f}", item->getMomentumChance())})); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 2305 | effectDescription = fmt::format(" ({})", tr.format("cpp.look.tier_ruse", locStr, {fmt::format("{:.2f}", item->getDodgeChance())})); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 2308 | effectDescription = fmt::format(" ({})", tr.format("cpp.look.tier_transcendence", locStr, {fmt::format("{:.2f}", item->getTranscendenceChance())})); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 2311 | effectDescription = fmt::format(" ({})", tr.format("cpp.look.tier_amplification", locStr, {fmt::format("{:.2f}", item->getAmplificationChance())})); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 2532 | itemDescription << fmt::format("{} {:+}%", getCombatName(indexToCombatType(i)), itemType.abilities->absorbPercent[i]); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 2578 | itemDescription << fmt::format("{}{} {:+}%", getCombatName(indexToCombatType(i)), tr.get("cpp.look.field", locStr), itemType.abilities->fieldAbsorbPercent[i]); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 2838 | s << fmt::format("{} {:+}%", getCombatName(indexToCombatType(i)), it.abilities->absorbPercent[i]); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 2884 | s << fmt::format("{}{} {:+}%", getCombatName(indexToCombatType(i)), tr.get("cpp.look.field", locStr), it.abilities->fieldAbsorbPercent[i]); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 3125 | s << fmt::format("{} {:+}%", getCombatName(indexToCombatType(i)), it.abilities->absorbPercent[i]); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 3171 | s << fmt::format("{}{} {:+}%", getCombatName(indexToCombatType(i)), tr.get("cpp.look.field", locStr), it.abilities->fieldAbsorbPercent[i]); |
| `cpp_runtime_text_calls` | `src/items/item.cpp` | 3243 | s << fmt::format(" ({})", tr.format("cpp.look.key_fmt", locStr, {fmt::format("{:04}", item ? item->getAttribute<uint16_t>(ItemAttribute_t::ACTIONID) : 0)})); |
| `cpp_runtime_text_calls` | `src/items/items.cpp` | 111 | return fmt::format("{} -> {}", augmentSpellNameCapitalized, augmentName); |
| `cpp_runtime_text_calls` | `src/items/items.cpp` | 113 | return fmt::format("{} -> {}{}s {}", augmentSpellNameCapitalized, signal, augmentInfo->value / 1000, augmentName); |
| `cpp_runtime_text_calls` | `src/items/items.cpp` | 116 | return fmt::format("{} -> {:+}% {} {}", augmentSpellNameCapitalized, augmentInfo->value, augmentName, spell->getGroup() == SPELLGROUP_HEALING ? "healing" : "dam |
| `cpp_runtime_text_calls` | `src/items/items.cpp` | 119 | return fmt::format("{} -> {:+}% {}", augmentSpellNameCapitalized, augmentInfo->value, augmentName); |
| `cpp_runtime_text_calls` | `src/kv/kv_sql.cpp` | 80 | update.addRow(fmt::format("{}, {}, {}", db.escapeString(key), value.getTimestamp(), db.escapeString(data))); |
| `cpp_runtime_text_calls` | `src/lua/creature/raids.cpp` | 340 | g_webhook().sendMessage(fmt::format(":space_invader: {}", webhookMessage.empty() ? message : webhookMessage)); |
| `cpp_runtime_text_calls` | `src/lua/functions/core/game/game_functions.cpp` | 157 | lua_pushstring(L, fmt::format("The monster with name {} already registered", alternateName).c_str()); |
| `cpp_runtime_text_calls` | `src/lua/functions/core/game/global_functions.cpp` | 777 | Lua::reportErrorFunc(fmt::format("{} - Player", Lua::getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND))); |
| `cpp_runtime_text_calls` | `src/lua/functions/core/game/global_functions.cpp` | 784 | Lua::reportErrorFunc(fmt::format("{} - TargetPlayer", Lua::getErrorDesc(LUA_ERROR_PLAYER_NOT_FOUND))); |
| `cpp_runtime_text_calls` | `src/lua/functions/creatures/monster/monster_spell_functions.cpp` | 203 | Lua::reportErrorFunc(fmt::format("trying to register condition type none for monster: {}", spell->name)); |
| `cpp_runtime_text_calls` | `src/lua/functions/events/event_callback_functions.cpp` | 91 | Lua::reportErrorFunc(fmt::format("EventCallback is duplicated for event with name: {}", callback->getName())); |
| `cpp_runtime_text_calls` | `src/lua/functions/events/talk_action_functions.cpp` | 91 | const auto string = fmt::format("Invalid group type string value {} for group type for script: {}", strValue, Lua::getScriptEnv()->getScriptInterface()->getLoad |
| `cpp_runtime_text_calls` | `src/lua/functions/events/talk_action_functions.cpp` | 97 | const auto string = fmt::format("Expected number or string value for group type for script: {}", Lua::getScriptEnv()->getScriptInterface()->getLoadingScriptName |
| `cpp_runtime_text_calls` | `src/lua/functions/events/talk_action_functions.cpp` | 123 | const auto string = fmt::format("TalkAction with name {} does't have groupType", talkactionSharedPtr->getWords()); |
| `cpp_runtime_text_calls` | `src/lua/functions/items/container_functions.cpp` | 190 | Lua::reportErrorFunc(fmt::format("Cannot add item to container, error code: '{}'", getReturnMessage(ret))); |
| `cpp_runtime_text_calls` | `src/lua/functions/lua_functions_loader.cpp` | 395 | reportErrorFunc(fmt::format("Format error, {}", e.what())); |
| `cpp_runtime_text_calls` | `src/map/mapcache.cpp` | 278 | throw IOMapException(fmt::format("[x:{}, y:{}, z:{}] Could not read item node.", x, y, z)); |
| `cpp_runtime_text_calls` | `src/map/mapcache.cpp` | 287 | throw IOMapException(fmt::format("[x:{}, y:{}, z:{}] Failed to load item.", x, y, z)); |
| `cpp_runtime_text_calls` | `src/map/mapcache.cpp` | 293 | throw IOMapException(fmt::format("[x:{}, y:{}, z:{}] Could not end node.", x, y, z)); |
| `cpp_runtime_text_calls` | `src/server/network/protocol/protocolgame.cpp` | 105 | return tr.get(fmt::format("cpp.title.name_{}_female", title.m_id), locale); |
