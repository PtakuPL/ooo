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

### 2026-02-06 – Agent (Codex) ➜ Kolejni Agenci (Batch 3)

**Zakres tej iteracji:**
- Kolejna redukcja `npcHandler:setMessage(...)` przez migrację przypadków single-message do `setLocalizedMessage(...)`.
- Zmienione NPC:
  - `corym_worker_01.lua`
  - `corym_worker_02.lua`
  - `corym_worker_03.lua`
  - `corym_worker_04.lua`
  - `corym_worker_05.lua`
  - `corym_slave.lua`
  - `corym_butler.lua`
  - `corym_footman.lua`
  - `corym_servant.lua` (częściowo: 3 jedno-liniowe greety; 1 blok multi-message zostawiony)
  - `eustacio.lua`
  - `charos.lua`
  - `testserver_assistant.lua`
  - `garamond.lua`
  - `plunderpurse.lua`
  - `ser_tybald.lua`
  - `flora.lua`

**Nowe/uzupełnione klucze EN (`i18n/en/npc.json`):**
- `npc.corym_worker_01.greet_msg_2`
- `npc.corym_worker_02.greet_msg_2`
- `npc.corym_worker_03.greet_msg_2`
- `npc.corym_worker_04.farewell_msg_1`
- `npc.corym_worker_04.greet_msg_1`
- `npc.corym_worker_04.greet_msg_2`
- `npc.corym_worker_05.greet_msg_2`
- `npc.corym_slave.greet_msg_2`
- `npc.corym_butler.greet_msg_2`
- `npc.corym_footman.greet_msg_2`
- `npc.corym_servant.greet_msg_2`
- `npc.corym_servant.greet_msg_3`
- `npc.corym_servant.greet_msg_4`
- `npc.eustacio.greet_msg_2`
- `npc.charos.greet_msg_1`
- `npc.testserver_assistant.greet_msg_1`
- `npc.garamond.greet_msg_1`
- `npc.ser_tybald.greet_msg_1`
- `npc.flora.greet_msg_1`

**Stan po batchu 3:**
- `npcHandler:setMessage(...)` (data + data-otservbr-global): **19** (było **37**)
- `npcHandler:setMessage(...)` tylko NPC global: **18** (było **36**)
- literalne `setMessage(MESSAGE_..., "..."|{...})` w NPC global: **16** (było **29**)
- bloki NPC `text = {...}` / `text = "..."`: **364** (bez zmian)
- `sendCancelMessage(RETURNVALUE_*)`: **283**

**Co zostało (priorytet):**
1. Pozostałe `setMessage` w NPC to głównie multi-message i/lub dynamiczne warianty:
   - `corym_servant`, `corym_ratter`, `quandons_ghost`, `jack`, `zlak`, `mr._west`, `klom_stonecutter`, `vascalir`, `the_empress`, `jamesfrancis`, `al_dee`, `edala`, `emael`, `arkulius`
2. Dwa celowe przypadki `setMessage(..., "")`:
   - `flora.lua`
   - `a_starving_dog.lua`

### 2026-02-06 – Agent (Codex) ➜ Kolejni Agenci (Batch 4)

**Zakres tej iteracji:**
- Dalsza redukcja `setMessage(...)` o kolejne przypadki single-message i dynamiczne greetingi:
  - `edala.lua` (mapa greetów przeniesiona na klucze)
  - `arkulius.lua` (random greet przeniesiony na klucze)
  - plus wcześniejsza partia z Batch 3 domknięta walidacją.

**Nowe klucze EN dodane (`i18n/en/npc.json`):**
- `npc.arkulius.greet_msg_1`
- `npc.arkulius.greet_msg_2`
- `npc.arkulius.greet_msg_3`
- `npc.edala.greet_msg_2`
- `npc.edala.greet_msg_3`
- `npc.edala.greet_msg_4`
- `npc.edala.greet_msg_5`
- `npc.edala.greet_msg_6`
- `npc.edala.greet_msg_7`
- `npc.edala.greet_msg_8`

**Stan po batchu 4:**
- `npcHandler:setMessage(...)` (data + data-otservbr-global): **19**
- `npcHandler:setMessage(...)` tylko NPC global: **16** (było **18**)
- literalne `setMessage(MESSAGE_..., "..."|{...})` w NPC global: **16**
- bloki NPC `text = {...}` / `text = "..."`: **364** (bez zmian)

**Pozostałe przypadki `setMessage` (16 linii):**
- Głównie wielolinijkowe sekwencje greet:
  - `al_dee.lua`, `quandons_ghost.lua`, `corym_servant.lua`, `jack.lua`, `vascalir.lua`, `emael.lua`, `jamesfrancis.lua`, `klom_stonecutter.lua`, `zlak.lua`, `mr._west.lua`, `corym_ratter.lua`, `the_empress.lua`
- Celowe puste walkaway:
  - `flora.lua`
  - `a_starving_dog.lua`

### 2026-02-06 – Agent (Codex) ➜ Kolejni Agenci (Batch 5)

**Zakres tej iteracji:**
- Domknięcie migracji `npcHandler:setMessage(...)` w `data-otservbr-global/npc` (zostało zredukowane do zera).
- Przeniesienie ostatnich greetingów tabelarycznych do `NPC_LIB.i18n.npcSayMultiple(...)` + `return false` w callbackach.
- Ujednolicenie pustych walkaway (`""`) do kluczy i18n.
- Uzupełnienie brakujących kluczy EN dla dotkniętych plików (nie tylko nowe greety, ale też wcześniejsze brakujące `say_*`).

**Zmodyfikowane pliki NPC:**
- `data-otservbr-global/npc/al_dee.lua`
- `data-otservbr-global/npc/quandons_ghost.lua`
- `data-otservbr-global/npc/emael.lua`
- `data-otservbr-global/npc/klom_stonecutter.lua`
- `data-otservbr-global/npc/mr._west.lua`
- `data-otservbr-global/npc/zlak.lua`
- `data-otservbr-global/npc/vascalir.lua`
- `data-otservbr-global/npc/the_empress.lua`
- `data-otservbr-global/npc/flora.lua`
- `data-otservbr-global/npc/a_starving_dog.lua`

**Nowe/uzupełnione klucze EN (`i18n/en/npc.json`):**
- Greet/walkaway:
  - `npc.al_dee.greet_msg_1..2`
  - `npc.quandons_ghost.greet_msg_2..4`
  - `npc.emael.greet_msg_1..2`, `npc.emael.farewell_msg_1`, `npc.emael.walkaway_msg_1`
  - `npc.klom_stonecutter.greet_msg_1..2`
  - `npc.mr._west.greet_msg_1..4`
  - `npc.the_empress.greet_msg_2..8`
  - `npc.vascalir.greet_msg_27..30`
  - `npc.zlak.greet_msg_1..2`
  - `npc.flora.walkaway_msg_1`
  - `npc.a_starving_dog.walkaway_msg_1`
- Braki historyczne uzupełnione dla tych samych NPC:
  - `npc.a_starving_dog.say_1`
  - `npc.flora.say_1..3`
  - `npc.emael.say_1..6`
  - `npc.mr._west.say_1..2`
  - `npc.vascalir.say_1..8`
  - `npc.zlak.multi_1..12`
  - `npc.klom_stonecutter.stdmod_1`, `npc.klom_stonecutter.multi_1..10`, `npc.klom_stonecutter.say_5..18`

**Stan po batchu 5:**
- `npcHandler:setMessage(...)` (data + data-otservbr-global): **1** (pozostał tylko helper fallback w `lib/npc/i18n.lua`)
- `npcHandler:setMessage(...)` tylko NPC global: **0**
- literalne `setMessage(MESSAGE_..., "..."|{...})` w NPC global: **0**
- bloki NPC `text = {...}` / `text = "..."`: **364** (bez zmian)
- `sendCancelMessage(RETURNVALUE_*)`: **283** (bez zmian)

**Walidacja:**
- `jq empty i18n/en/npc.json` OK
- Brak brakujących kluczy `npc.*` dla wszystkich plików dotkniętych w Batch 5

### 2026-02-06 – Agent (Codex) ➜ Kolejni Agenci (Batch 6, C++)

**Zakres tej iteracji:**
- Integracja równoległych zmian C++ wykonanych przez innych agentów (Copilot/Claude) w warstwie i18n look-description.
- Domknięcie mapowania kluczy `cpp.look.*` wymaganych przez `item.cpp`/`game.cpp`.

**Pliki C++ objęte integracją:**
- `src/items/item.cpp`
  - i18n dla fragmentów opisu przedmiotów (`imbuements`, `classification_tier`, duration/attributes/weight i inne `cpp.look.*`).
  - Lokalizacja przekazywana jako `std::string_view`, a do `translator.get/format` normalizowana do `std::string` (`locStr`), aby nie łapać konwersji niejawnych.
- `src/items/item.hpp`
  - sygnatury helperów opisu rozszerzone o `std::string_view locale`.
- `src/game/game.cpp`
  - `playerLookInShop` używa `cpp.look.you_see` + `Item::getDescription(..., locale)`.
  - locale dla `translator.get` podane jako `std::string` (`playerLocale`).

**Pliki i18n:**
- `i18n/en/cpp.json`
  - zawiera klucze używane przez nową ścieżkę C++ (w tym `cpp.look.classification_tier`).

**Walidacja:**
- `jq empty i18n/en/cpp.json` OK
- brak brakujących kluczy `cpp.*` używanych bezpośrednio przez:
  - `src/items/item.cpp`
  - `src/game/game.cpp`
  - wynik: `missing_cpp_keys=0`

**Znane ograniczenie środowiska (lokalny build):**
- pełna kompilacja lokalnie zablokowana przez brak toolchain/deps:
  - brak `/home/ptaku/vcpkg/scripts/buildsystems/vcpkg.cmake`
  - brak `CURLConfig.cmake`/`curl-config.cmake`
- To jest blokada środowiskowa, nie logiczna regresja kodu i18n.

### 2026-02-06 – Agent (Codex) ➜ Kolejni Agenci (Batch 7, Raids integration)

**Zakres tej iteracji:**
- Integracja i18n raid announce z webhookiem, aby webhook nie dostawał surowych kluczy `raids.*`.

**Zmiany:**
- `src/lua/creature/raids.cpp`
  - `AnnounceEvent::executeEvent()`:
    - do graczy nadal idzie `sendLocalizedTextMessage(messageType, message)` (per-locale),
    - do webhooka idzie tekst EN przez `i18n::g_translator().get(message, "en")`.
  - dodany include: `utils/i18n/translator.hpp`.

**Stan raidów (po audycie):**
- `data-otservbr-global/raids/**/*.xml`:
  - `message="raids.*"`: **126/126**
  - komunikaty literalne (nie-key): **0**
- `i18n/en/raids.json`:
  - brak brakujących kluczy względem XML: **0**

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
