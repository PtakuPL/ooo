# i18n — Migracja Lua skryptów (sesja 2026-02-06)
**Data:** 2026-02-06

## Podsumowanie sesji

Kontynuacja masowej migracji hardcoded angielskich tekstów do systemu i18n. 
Sesja obejmowała 6 commitów na branchu `feature/i18n-multilanguage`.

## Commity

| Commit | Opis | Pliki | Edycje |
|--------|------|-------|--------|
| c35556f41 | on_look, wall_mirror, foods, dolls, potions, globalevents | 118 | ~140 |
| fdec35a96 | Quest P1+P2 — sendCancelMessage + sendTextMessage | 49 | 100 |
| 2c04da790 | P3+P4 — core quest systems + config tables | 157+ | 377 |
| 74f6781f4 | P5 — say/doCreatureSay/config tables, mounts, fluids, holy_water | 146 | 358 |
| 091b540d1 | P6 — final batch, Translator, music_box, outfits, find_person/fiend | 71 | ~120 |

## Szczegóły migracji

### 1. Pliki z data/scripts/
- **on_look.lua** — 21 kluczy, Translator.getTranslation dla budowania opisu
- **wall_mirror.lua** — 11 komunikatów lustrzanych
- **foods.lua** — 120+ pozycji jedzenia, 14 unikalnych dźwięków
- **dolls.lua** — 70+ powiedzeń lalek, z obsługą %s dla imienia gracza
- **potions.lua** — 16 opisów mikstur i tekstów efektów
- **globalevents** — 5 broadcastów (server_save, online_record, save_interval)
- **find_person.lua** — 16 kluczy kierunków/odległości z Translator.getTranslation
- **find_fiend.lua** — 24 klucze (kierunki + poziomy trudności)
- **offline_training.lua** — 6 kluczy budowania tekstu treningowego
- **login.lua** — 2 komunikaty logowania
- **music_box.lua** — 18 komunikatów (9 oswojeń + 9 dźwięków)
- **usable_outfit_items.lua** — 11 tekstów pomarańczowych/białych
- **usable_mount_items.lua** — 4 komunikaty oswojenia wierzchowca
- **hireling_foods.lua** — 5 unikalnych dźwięków jedzenia
- **decay_to.lua** — 2 głosy
- **large_seashell.lua** — 3 komunikaty
- **voodoo_doll.lua** — 2 teksty
- **pot_of_blackjack.lua** — 2 komunikaty
- **die.lua** — 1 dynamiczny "%s rolled a %s."
- **rust_remover.lua** — 4 komunikaty zniszczenia
- **clay_lump.lua** — 1 dźwięk
- **on_look_in_trade.lua** — 1 prefiks "You see"

### 2. Questy (data-otservbr-global/scripts/)
- **P1** — 71 edycji sendCancelMessage → sendLocalizedCancelMessage, 31 plików
- **P2** — 29 edycji parameterized sendTextMessage, ~15 plików
- **P3** — core quest_system1.lua, quest_system2.lua, quest_reward_common.lua, register_actions.lua
- **P4** — ~333 edycji w config tables (cults_of_tibia, rookie_guard, dream_courts, threatened_dreams, lions_rock, demon_oak, secret_library, itp.)
- **P5** — mounts.lua (43 SUCCESS_MSG + 38 FAIL_MSG), fluids, holy_water, horestis_jars, pits_of_inferno/throne, svargrond_arena, thais_exhibition

### 3. Klucze JSON
| Plik | Klucze przed | Klucze po |
|------|-------------|-----------|
| scripts.json | 636 | **1104** |
| quests.json | 132 | **~400+** |
| globalevents.json | 0 | **5** |

## Co pozostało (Lua)

### Nie wymaga migracji:
- **59 sendCancelMessage(RETURNVALUE_*)** — tłumaczone przez silnik C++
- **Komendy admin/GM/God** — raids, test, getlook, mc_check, broadcast, inbox_command
- **Dynamiczna treść** — soul_war (złożona pętla), online (lista graczy), reward_chest (loot)

### Do przyszłej migracji:
- **dawnport_vocation_trial.lua** — 2 wywołania z nazwy wokacji (wymaga nazw wokacji w i18n)
- **items.xml** — 3,145 opisów przedmiotów
- **Mapa .otbm** — ~1,769 tekstów na znakach/przedmiotach
- **XML raidów** — 126 komunikatów
- **C++ source** — ~93 widoczne dla gracza + ~65 RETURNVALUE (ręczna edycja)
- **NPC (303 pliki)** — dialogi NPC
- **Gamestore** — 6 wywołań własnym protokołem (wymaga zmian klienta)
- **Daily reward** — ~36 tekstów

## Problemy napotkane
1. **Apostrofy w inline Python** — ucieczkowe znaki powodowały SyntaxError, rozwiązane pisaniem .py skryptu
2. **Kolejność argumentów sayLocalized C++** — args musi być OSTATNIM parametrem
3. **addEvent z broadcastLocalizedMessageLua** — wymaga opakowania w closure function
4. **Wzory P2 nie znalezione** — niektóre ścieżki/wzory nie pasowały, wymagały ręcznej weryfikacji
