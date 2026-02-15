# PRE_MIGRATION TODO: server

- Generated: `2026-02-15T19:44:26.909936Z`
- Files scanned: **437**
- Files with hits: **32**
- Hits: **109**

| File | Line | Pattern | Text |
|---|---:|---|---|
| `src/account/account_repository_db.cpp` | 26 | `cpp.fmt::format` | SELECT `id`, `type`, `premdays`, `lastday`, `creation`, `premdays_purchased`, 0 AS `expires` FROM `accounts` WHERE `id` = {} |
| `src/account/account_repository_db.cpp` | 32 | `cpp.fmt::format` | SELECT `id`, `type`, `premdays`, `lastday`, `creation`, `premdays_purchased`, 0 AS `expires` FROM `accounts` WHERE `{}` = {} |
| `src/account/account_repository_db.cpp` | 69 | `cpp.fmt::format` | SELECT `id` FROM `players` WHERE `account_id` = {} AND `name` = {} |
| `src/account/account_repository_db.cpp` | 79 | `cpp.fmt::format` | SELECT `password` FROM `accounts` WHERE `id` = {} |
| `src/account/account_repository_db.cpp` | 170 | `cpp.fmt::format` | SELECT `name`, `deletion` FROM `players` WHERE `account_id` = {} ORDER BY `name` ASC |
| `src/canary_server.cpp` | 296 | `cpp.fmt::format` | Clang++ {}.{}.{} |
| `src/canary_server.cpp` | 298 | `cpp.fmt::format` | Microsoft Visual Studio {} |
| `src/canary_server.cpp` | 300 | `cpp.fmt::format` | G++ {}.{}.{} |
| `src/canary_server.cpp` | 425 | `cpp.fmt::format` | Cannot load: {} |
| `src/creatures/creature.cpp` | 1224 | `cpp.fmt::format` | {} gained {} experience point{}. |
| `src/creatures/players/components/player_badge.cpp` | 134 | `cpp.fmt::format` | SELECT name, level, vocation FROM players WHERE name IN ({}) |
| `src/creatures/players/components/player_cyclopedia.cpp` | 29 | `cpp.fmt::format` | SELECT COUNT(*) as `count` FROM `player_hirelings` WHERE `player_id` = {} |
| `src/creatures/players/components/player_cyclopedia.cpp` | 39 | `cpp.fmt::format` | SELECT `time`, `level`, `killed_by`, `mostdamage_by`, (select count(*) FROM `player_deaths` WHERE `player_id` = {}) as `entries` FROM `player_deaths` WHERE `player_id` = {} AND `time` >= UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 30 DAY)) ORDER BY `time` DESC LIMIT {}, {} |
| `src/creatures/players/components/player_cyclopedia.cpp` | 64 | `cpp.fmt::format` | Died at Level {} |
| `src/creatures/players/components/player_cyclopedia.cpp` | 67 | `cpp.fmt::format` | by{} |
| `src/creatures/players/components/player_cyclopedia.cpp` | 89 | `cpp.fmt::format` | SELECT `d`.`time`, `d`.`killed_by`, `d`.`mostdamage_by`, `d`.`unjustified`, `d`.`mostdamage_unjustified`, `p`.`name`, (select count(*) FROM `player_deaths` WHERE ((`killed_by` = {} AND `is_player` = 1) OR (`mostdamage_by` = {} AND `mostdamage_is_player` = 1))) as `entries` FROM `player_deaths` AS `d` INNER JOIN `players` AS `p` ON `d`.`player_id` = `p`.`id` WHERE ((`d`.`killed_by` = {} AND `d`.`is_player` = 1) OR (`d`.`mostdamage_by` = {} AND `d`.`mostdamage_is_player` = 1)) AND `time` >= UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 70 DAY)) ORDER BY `time` DESC LIMIT {}, {} |
| `src/creatures/players/components/player_cyclopedia.cpp` | 126 | `cpp.fmt::format` | Killed {}. |
| `src/creatures/players/components/wheel/player_wheel.cpp` | 1808 | `cpp.fmt::format` | SELECT `slot` FROM `player_wheeldata` WHERE `player_id` = {} |
| `src/creatures/players/components/wheel/player_wheel.cpp` | 3871 | `cpp.fmt::format` | [PlayerWheelGem] uuid: {}, locked: {}, affinity: {}, quality: {}, basicModifier1: {}, basicModifier2: {}, supremeModifier: {} |
| `src/creatures/players/player.cpp` | 213 | `cpp.fmt::format` | cpp.title.name_{}_female |
| `src/creatures/players/player.cpp` | 214 | `cpp.fmt::format` | cpp.title.name_{} |
| `src/creatures/players/player.cpp` | 224 | `cpp.fmt::format` | cpp.vocation.desc_id_{} |
| `src/creatures/players/player.cpp` | 2445 | `cpp.fmt::format` | item.{}.name |
| `src/creatures/players/player.cpp` | 2452 | `cpp.fmt::format` | items.{}.name |
| `src/creatures/players/player.cpp` | 3547 | `cpp.fmt::format` | {:.1f} |
| `src/creatures/players/player.cpp` | 5421 | `cpp.fmt::format` | (hazard -{}%) |
| `src/creatures/players/player.cpp` | 7801 | `cpp.fmt::format` | {:.2f} |
| `src/creatures/players/player.cpp` | 7804 | `cpp.fmt::format` | {:.2f} |
| `src/creatures/players/player.cpp` | 9304 | `cpp.fmt::format` | cpp.player.blessing_name_{} |
| `src/database/database.cpp` | 79 | `cpp.fmt::format` | {:%Y-%m-%d} |
| `src/database/database.cpp` | 80 | `cpp.fmt::format` | {:%H-%M-%S} |
| `src/database/database.cpp` | 83 | `cpp.fmt::format` | database_backup/{}/ |
| `src/database/database.cpp` | 85 | `cpp.fmt::format` | {}backup_{}.sql |
| `src/game/game.cpp` | 724 | `cpp.fmt::format` | Failed to create custom map directory {} |
| `src/game/game.cpp` | 7495 | `cpp.fmt::format` | {} attack |
| `src/game/game.cpp` | 8815 | `cpp.fmt::format` | (@ourRow DIV {0}) + 1 AS `page` FROM ( |
| `src/game/game.cpp` | 8817 | `cpp.fmt::format` | {} AS `page` FROM ( |
| `src/game/game.cpp` | 8828 | `cpp.fmt::format` | , @ourRow := IF(`id` = {}, @row - 1, @ourRow) AS `rw` |
| `src/game/game.cpp` | 8850 | `cpp.fmt::format` | `rn` > {} AND `rn` <= {} |
| `src/game/zones/zone.hpp` | 45 | `cpp.fmt::format` | Area(from: {}, to: {}) |
| `src/io/functions/iologindata_load_player.cpp` | 250 | `cpp.fmt::format` | blessings{} |
| `src/io/functions/iologindata_load_player.cpp` | 543 | `cpp.fmt::format` | SELECT pid, sid, itemtype, count, attributes FROM player_items WHERE player_id = {} ORDER BY sid DESC |
| `src/io/functions/iologindata_load_player.cpp` | 660 | `cpp.fmt::format` | SELECT pid, sid, itemtype, count, attributes FROM player_depotitems WHERE player_id = {} ORDER BY sid DESC |
| `src/io/functions/iologindata_load_player.cpp` | 706 | `cpp.fmt::format` | SELECT pid, sid, itemtype, count, attributes FROM player_inboxitems WHERE player_id = {} ORDER BY sid DESC |
| `src/io/functions/iologindata_load_player.cpp` | 774 | `cpp.fmt::format` | SELECT `player_id` FROM `account_viplist` WHERE `account_id` = {} |
| `src/io/functions/iologindata_load_player.cpp` | 781 | `cpp.fmt::format` | SELECT `id`, `name`, `customizable` FROM `account_vipgroups` WHERE `account_id` = {} |
| `src/io/functions/iologindata_load_player.cpp` | 792 | `cpp.fmt::format` | SELECT `player_id`, `vipgroup_id` FROM `account_vipgrouplist` WHERE `account_id` = {} |
| `src/io/io_bosstiary.cpp` | 25 | `cpp.fmt::format` | SELECT `date`, `boostname`, `raceid` FROM `boosted_boss` |
| `src/io/io_bosstiary.cpp` | 96 | `cpp.fmt::format` | `raceid` = '{}' |
| `src/io/iobestiary.cpp` | 31 | `cpp.fmt::format` | ({} charm) |
| `src/io/iobestiary.cpp` | 132 | `cpp.fmt::format` | ({} charm) |
| `src/io/iologindata.cpp` | 359 | `cpp.fmt::format` | SELECT `player_id`, (SELECT `name` FROM `players` WHERE `id` = `player_id`) AS `name`, `description`, `icon`, `notify` FROM `account_viplist` WHERE `account_id` = {} |
| `src/io/iologindata.cpp` | 379 | `cpp.fmt::format` | INSERT INTO `account_viplist` (`account_id`, `player_id`, `description`, `icon`, `notify`) VALUES ({}, {}, {}, {}, {}) |
| `src/io/iologindata.cpp` | 386 | `cpp.fmt::format` | UPDATE `account_viplist` SET `description` = {}, `icon` = {}, `notify` = {} WHERE `account_id` = {} AND `player_id` = {} |
| `src/io/iologindata.cpp` | 393 | `cpp.fmt::format` | DELETE FROM `account_viplist` WHERE `account_id` = {} AND `player_id` = {} |
| `src/io/iologindata.cpp` | 398 | `cpp.fmt::format` | SELECT `id`, `name`, `customizable` FROM `account_vipgroups` WHERE `account_id` = {} |
| `src/io/iologindata.cpp` | 417 | `cpp.fmt::format` | INSERT INTO `account_vipgroups` (`id`, `account_id`, `name`, `customizable`) VALUES ({}, {}, {}, {}) |
| `src/io/iologindata.cpp` | 424 | `cpp.fmt::format` | UPDATE `account_vipgroups` SET `name` = {}, `customizable` = {} WHERE `id` = {} AND `account_id` = {} |
| `src/io/iologindata.cpp` | 431 | `cpp.fmt::format` | DELETE FROM `account_vipgroups` WHERE `id` = {} AND `account_id` = {} |
| `src/io/iologindata.cpp` | 436 | `cpp.fmt::format` | INSERT INTO `account_vipgrouplist` (`account_id`, `player_id`, `vipgroup_id`) VALUES ({}, {}, {}) |
| `src/io/iologindata.cpp` | 443 | `cpp.fmt::format` | DELETE FROM `account_vipgrouplist` WHERE `account_id` = {} AND `player_id` = {} |
| `src/io/iomap.cpp` | 143 | `cpp.fmt::format` | [x:{}, y:{}, z:{}] Could not create house id: {} |
| `src/io/iomap.cpp` | 193 | `cpp.fmt::format` | [x:{}, y:{}, z:{}] Failed to load item {}, Node Type. |
| `src/io/iomap.cpp` | 214 | `cpp.fmt::format` | [x:{}, y:{}, z:{}] Invalid zone id. |
| `src/io/iomap.cpp` | 221 | `cpp.fmt::format` | [x:{}, y:{}, z:{}] Could not read item/zone node. |
| `src/io/iomap.cpp` | 225 | `cpp.fmt::format` | [x:{}, y:{}, z:{}] Could not end node. |
| `src/io/iomap.cpp` | 230 | `cpp.fmt::format` | [x:{}, y:{}, z:{}] Could not end node. |
| `src/io/iomapserialize.cpp` | 440 | `cpp.fmt::format` | DELETE FROM `house_lists` WHERE `version` < {} |
| `src/items/functions/item/item_parse.cpp` | 135 | `cpp.fmt::format` | A bag with {} slots where you can hold your loots. |
| `src/items/item.cpp` | 2200 | `cpp.fmt::format` | {} {} {:02}:{:02}h |
| `src/items/item.cpp` | 2298 | `cpp.fmt::format` | {:.2f} |
| `src/items/item.cpp` | 2302 | `cpp.fmt::format` | {:.2f} |
| `src/items/item.cpp` | 2305 | `cpp.fmt::format` | {:.2f} |
| `src/items/item.cpp` | 2308 | `cpp.fmt::format` | {:.2f} |
| `src/items/item.cpp` | 2311 | `cpp.fmt::format` | {:.2f} |
| `src/items/items.cpp` | 113 | `cpp.fmt::format` | {} -> {}{}s {} |
| `src/items/tile.cpp` | 723 | `cpp.fmt::format` | You can only have {} character{} from your account outside of a protection zone. |
| `src/kv/kv_sql.cpp` | 22 | `cpp.fmt::format` | SELECT `key_name`, `timestamp`, `value` FROM `kv_store` WHERE `key_name` = {} |
| `src/kv/kv_sql.cpp` | 48 | `cpp.fmt::format` | SELECT `key_name` FROM `kv_store` WHERE `key_name` LIKE {} |
| `src/kv/kv_sql.cpp` | 76 | `cpp.fmt::format` | DELETE FROM `kv_store` WHERE `key_name` = {} |
| `src/lua/creature/raids.cpp` | 340 | `cpp.fmt::format` | :space_invader: {} |
| `src/lua/functions/core/game/global_functions.cpp` | 777 | `cpp.fmt::format` | {} - Player |
| `src/lua/functions/core/game/global_functions.cpp` | 784 | `cpp.fmt::format` | {} - TargetPlayer |
| `src/lua/functions/creatures/monster/monster_spell_functions.cpp` | 203 | `cpp.fmt::format` | trying to register condition type none for monster: {} |
| `src/lua/functions/events/event_callback_functions.cpp` | 91 | `cpp.fmt::format` | EventCallback is duplicated for event with name: {} |
| `src/lua/functions/events/talk_action_functions.cpp` | 91 | `cpp.fmt::format` | Invalid group type string value {} for group type for script: {} |
| `src/lua/functions/events/talk_action_functions.cpp` | 97 | `cpp.fmt::format` | Expected number or string value for group type for script: {} |
| `src/lua/functions/events/talk_action_functions.cpp` | 123 | `cpp.fmt::format` | TalkAction with name {} does't have groupType |
| `src/lua/functions/items/container_functions.cpp` | 190 | `cpp.fmt::format` | Cannot add item to container, error code: '{}' |
| `src/lua/functions/lua_functions_loader.cpp` | 395 | `cpp.fmt::format` | Format error, {} |
| `src/map/mapcache.cpp` | 278 | `cpp.fmt::format` | [x:{}, y:{}, z:{}] Could not read item node. |
| `src/map/mapcache.cpp` | 287 | `cpp.fmt::format` | [x:{}, y:{}, z:{}] Failed to load item. |
| `src/map/mapcache.cpp` | 293 | `cpp.fmt::format` | [x:{}, y:{}, z:{}] Could not end node. |
| `src/server/network/protocol/protocolgame.cpp` | 105 | `cpp.fmt::format` | cpp.title.name_{}_female |
| `src/server/network/protocol/protocolgame.cpp` | 107 | `cpp.fmt::format` | cpp.title.name_{} |
| `src/server/network/protocol/protocolgame.cpp` | 139 | `cpp.fmt::format` | cpp.vocation.id_{} |
| `src/server/network/protocol/protocolgame.cpp` | 149 | `cpp.fmt::format` | cpp.player.blessing_name_{} |
| `src/server/network/protocol/protocolgame.cpp` | 1550 | `cpp.fmt::format` | 0x{:02x} |
| `src/server/network/protocol/protocolgame.cpp` | 4260 | `cpp.fmt::format` | {}:{:02}h |
| `src/server/network/protocol/protocolgame.cpp` | 6598 | `cpp.fmt::format` | {:.2f} |
| `src/server/network/protocol/protocolgame.cpp` | 6601 | `cpp.fmt::format` | {:.2f} |
| `src/server/network/protocol/protocolgame.cpp` | 6604 | `cpp.fmt::format` | {:.2f} |
| `src/server/network/protocol/protocolgame.cpp` | 6607 | `cpp.fmt::format` | {:.2f} |
| `src/server/network/protocol/protocolgame.cpp` | 6610 | `cpp.fmt::format` | {:.2f} |
| `src/utils/pugicast.hpp` | 41 | `cpp.fmt::format` | [{}] Invalid argument {} |
| `src/utils/pugicast.hpp` | 46 | `cpp.fmt::format` | [{}] Result out of range: {} |
| `src/utils/tools.cpp` | 460 | `cpp.fmt::format` | {:%d/%m/%Y %H:%M:%S} |
| `src/utils/tools.cpp` | 469 | `cpp.fmt::format` | {:%Y-%m-%d %X} |
| `src/utils/tools.cpp` | 478 | `cpp.fmt::format` | {:%H:%M:%S} |
