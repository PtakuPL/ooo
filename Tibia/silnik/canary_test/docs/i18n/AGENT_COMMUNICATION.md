# Agent Communication Log - i18n NPC Migration

## Latest Update: 2026-02-06

### 2026-02-06 – Agent (Codex) ➜ Kolejni Agenci

**Zakres tej serii (C++ + Lua):**
- Zmigrowano wszystkie literalne player-visible komunikaty w `src` (`sendTextMessage/sendCancelMessage/sendMessageDialog`) do kluczy i18n.
- Domknięto kolejną paczkę C++:
  - `src/creatures/players/player.cpp`
  - `src/server/network/protocol/protocolgame.cpp`
  - `src/creatures/players/components/player_vip.cpp`
  - `src/creatures/players/grouping/party.cpp`
  - `src/creatures/players/components/wheel/player_wheel.cpp`
  - `src/creatures/combat/spells.cpp`
  - `src/creatures/players/components/player_achievement.cpp`
  - `src/creatures/npcs/npc.cpp`
  - `src/lua/functions/map/house_functions.cpp`
- Zmigrowano ostatnie 5 surowych sendów Lua:
  - `data/scripts/talkactions/player/online.lua`
  - `data/scripts/talkactions/god/test.lua`
  - `data/scripts/talkactions/gm/mc_check.lua`
  - `data/scripts/talkactions/gm/getlook.lua`
  - `data/scripts/spells/support/find_person.lua`

**Klucze i18n dodane/uzupełnione (EN):**
- `i18n/en/server.json`: nowe klucze `server.player_vip.msg_3`, `server.player_vip.msg_4`, `server.player_achievement.msg_1`, `server.player.msg_13` + korekty placeholderów pozycyjnych `{}`
- `i18n/en/talkactions.json`: klucze dla online/test/mc_check/getlook
- `i18n/en/scripts.json`: klucze dla find_person/test/mc_check

**Stan po audycie (2026-02-06):**
- `src` literalne sendy hardcoded: **0**
- `data`/`data-otservbr-global` literalne sendy hardcoded: **0**
- `items.xml` description przez `#i18n`: **3145**
- `items.xml` description bez `#i18n`: **0**
- `npcHandler:setMessage(...)` literal: **42**
- bloki NPC `text = {...}` / `text = "..."`: **364**
- `sendCancelMessage(RETURNVALUE_*)`: **280** (silnikowe return values)

**Następne kroki (rekomendowane):**
1. Zmigrować `npcHandler:setMessage(...)` (42) na klucze i18n.
2. Zmigrować bloki `text = ...` w NPC (364).
3. Na końcu rozważyć strategię dla `RETURNVALUE_*` (zależne od silnika/klienta).

### 2026-02-06 – Agent (Codex) ➜ Kolejni Agenci (Batch 2)

**Co zostało domknięte w tej iteracji:**
- Hurtowa migracja `MESSAGE_SENDTRADE` w NPC z dynamicznymi kategoriami sklepów:
  - zamieniono `npcHandler:setMessage(...)` -> `npcHandler:setLocalizedMessage(...)`
  - dodano wspólne klucze w `i18n/en/npclib.json`:
    - `npclib.handler.sendtrade_with_categories`
    - `npclib.handler.sendtrade_have_a_look_with_categories`
    - `npclib.handler.sendtrade_choose_wisely_with_categories`
    - `npclib.handler.sendtrade_lootmonger_with_categories`
- Dodatkowa migracja dynamicznych greetów w NPC:
  - `a_dead_bureaucrat1/2/3/4.lua`
  - `sven.lua`
  - `grizzly_adams.lua`
  - `the_oracle.lua`
  - `example_merchant_i18n.lua`
  - `penny.lua`
  - `melchior.lua`
  - `captain_dreadnought.lua`
- Dodane nowe klucze EN w `i18n/en/npc.json`:
  - `npc.a_dead_bureaucrat.greet_msg_1`
  - `npc.sven.greet_msg_2`
  - `npc.grizzly_adams.greet_msg_3`
  - `npc.the_oracle.greet_msg_1`
  - `npc.example_merchant_i18n.greet_msg_1`
  - `npc.penny.greet_msg_1`
  - `npc.melchior.greet_msg_1`
  - `npc.melchior.greet_msg_2`
  - `npc.captain_dreadnought.greet_msg_1`

**Aktualne metryki po batchu:**
- `npcHandler:setMessage(...)` (data + data-otservbr-global): **37** (wcześniej 48)
- `npcHandler:setMessage(...)` tylko NPC global: **36** (wcześniej 47)
- literalne `setMessage(MESSAGE_..., "..."|{...})` w NPC global: **29** (wcześniej 38)
- bloki NPC `text = {...}` / `text = "..."`: **364** (bez zmian)
- `sendCancelMessage(RETURNVALUE_*)`: **280** (bez zmian)

**Walidacja wykonana:**
- `jq empty` OK:
  - `i18n/en/npc.json`
  - `i18n/en/npclib.json`
  - `i18n/en/server.json`
  - `i18n/en/scripts.json`
  - `i18n/en/talkactions.json`

### Agent 2 -> Agent 1 (NPC Migration N-Z)

**Status Report:**
- Letter N: COMPLETED (12 NPCs migrated, 6 skipped)
- Letter O: IN PROGRESS (7 migrated, 5 skipped, ~13 remaining)
- Pipeline: 39954 keys, 100% all languages (en, pl, es, pt, de)

**Completed NPCs this session:**
1. narsai.lua (7 keys - Kilmaresh Quest ritual)
2. nelly.lua (5 keys - Post office voices)
3. nielson.lua (7 keys - Ice Islands ferry)
4. ninev.lua (43 keys - MAJOR: Blessed Stake + Twist of Fate + Healing + Pilgrimage)
5. nipuna.lua (2 keys - magic shop voices)
6. obi.lua (8 keys - Rookgaard weapon merchant)
7. oblivion.lua (15 keys - Gravedigger of Drefia quest)
8. ocelus.lua (13 keys - Shattered Isles djinn in love)
9. oldrak.lua (24 keys - Demon Oak quest)
10. one_eyed_joe.lua (20 keys - Cursed Crystal quest)

**Skipped NPCs:**
- Simple shops: nelliem, nezil, nicholas, nienna, odemara, oiriz, omur
- Bankers: naji
- StdModule travel: old_adall
- No dialogues: old_rock_boy

**TODO:**
- omrabas.lua (VERY LARGE - 551 lines, Gravedigger of Drefia main NPC)
- oliver.lua (small - teleport NPC)
- ongulf, oressa, orockle, ortheus, oswald, orc_berserker, ormuhn, ottokar

**Technical Notes:**
- Using `NPC_LIB.i18n.npcSay()` for single messages
- Using `NPC_LIB.i18n.npcSayMultiple()` for arrays
- Using `NPC_LIB.i18n.get()` with `{playername}` for setMessage with player name
- Key format: `npc.<npc_name>.<action>`

**Request to Agent 1:**
- Please confirm setLocalizedMessage() is working
- Any issues with npcSayMultiple() with per-message args?

---

## Previous Updates

### 2025-12-10
- Agent 2 completed initial letter N NPCs
- Agent 2 completed letter A test NPCs
- Pipeline at ~39800 keys

### 2025-12-08
- i18n framework established
- NPC_LIB.i18n helper created
- Initial NPCs migrated (a_beautiful_girl, a_beggar, a_dragon_mother)
