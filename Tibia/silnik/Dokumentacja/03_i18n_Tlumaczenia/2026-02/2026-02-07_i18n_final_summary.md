# Migracja i18n — Podsumowanie finalne (2026-02-07)

## Status: Migracja Lua/XML KOMPLETNA

Cała migracja skryptów Lua, plików XML raidów i systemu gamestore do systemu i18n jest zakończona.

## Statystyki

| Plik JSON | Klucze |
|-----------|--------|
| npc.json | 7,247 |
| items.json | 16,894 |
| monsters.json | 5,915 |
| otclient_modules.json | 1,987 |
| spells.json | 1,534 |
| html.json | 1,495 |
| books.json | 1,403 |
| scripts.json | 1,213 |
| quests.json | 504 |
| raids.json | 273 |
| client.json | 242 |
| talkactions.json | 177 |
| server.json | 71 |
| libs.json | 68 |
| php.json | 59 |
| npclib.json | 40 |
| actions.json | 35 |
| startup.json | 23 |
| modules.json | 19 |
| chatchannels.json | 16 |
| cpp.json | 16 |
| example_merchant.json | 14 |
| events.json | 13 |
| messages.json | 11 |
| globalevents.json | 5 |
| creaturescripts.json | 4 |
| dataroot.json | 3 |
| movements.json | 2 |
| **RAZEM** | **39,355** |

## Co zostało zrobione w tej sesji (07.02.2026)

### Raidy XML (commit f5718c4b3)
- Modyfikacja `AnnounceEvent::executeEvent()` w `src/lua/creature/raids.cpp`
  - Zmiana z `g_game().broadcastMessage()` na per-player `sendLocalizedTextMessage`
- 126 komunikatów announce w 63 plikach XML → klucze i18n
- 126 nowych kluczy w raids.json (razem 273)

### Gamestore kompletny (commit f5718c4b3)
- Hook auto-tłumaczenia w `sendStorePurchaseSuccessful()` i `sendStoreError()`
- P1: 26 edycji — DefaultDescriptions, transfer, ogólne błędy
- P2: 73 edycji — disabledReason (22x), purchase errors (20x), showInfoModal (7x), walidacja nazw hireling/postaci (15x), client10 errors (4x)
- Razem: 91 nowych kluczy gamestore

### Dawnport + pozostałe skrypty (commit 5b62971e8)
- Naprawienie błędnie zmigrowanego `dawnport_vocation_trial.lua` (12 kluczy — 4 wokacje × 3 kroki)
- `grave_danger_quest/movements_enter_tps.lua` — boss wait timer
- `blessing.lua` — "You already possess this blessing"
- `death.lua` — Guild war broadcast
- `data-canary/` — quests.lua (4x), fluids.lua (1x), canary.lua (1x)

### NPC migracja (commit 9b014f5dc)
- 695/1026 NPC z jawnymi dialogami — już zmigrowane (wcześniejsze sesje)
- 2 NPC z dialogami — cranky_lizard_crone, bertram — zmigrowane w tej sesji
- 332 "ciche" NPC — bez dialogów, korzystają z domyślnego NPC handlera

### Naprawki (commit tej sesji)
- chatchannels.json — naprawiony podwójny `}`
- spells.json — naprawiony podwójny `}`

## Co pozostaje do zrobienia

### items.xml — nazwy przedmiotów
- 16,894 kluczy już istnieje w items.json (wyekstrahowane wcześniej)
- Potrzeba mechanizmu C++ do tłumaczenia nazw na etapie wysyłania do klienta

### C++ source — player-visible strings
- ~100+ stringów w kodzie C++ (RETURNVALUE, statusy, komunikaty systemowe)
- Te wymagają ręcznej edycji każdego pliku C++ (jak sugerował użytkownik)
- Duża cześć to RETURNVALUE enum values — tłumaczone już w C++

### Gamestore store descriptions (5 stringów)
- ITEM_ATTRIBUTE_DESCRIPTION dla dekoracji i hireling lamp
- Wymagają C++ mechanizmu tłumaczenia na etapie on-look

### Domyślne NPC handler messages
- "Greetings, |PLAYERNAME|.", "Good bye." itd.
- Globalne fallbacki — można zlokalizować w NPC handler library

## Architektura i18n

- **55 języków** — każdy ma kopie wszystkich plików JSON
- **Klasa Translator** (C++) — ładuje JSON, tłumaczy per-player
- **Lua API**: `sendLocalizedTextMessage`, `sendLocalizedCancelMessage`, `sayLocalized`, `broadcastLocalizedMessageLua`
- **NPC lib**: `NPC_LIB.i18n.npcSay()`, `npcSayMultiple()`, `setLocalizedMessage()`
- **Gamestore hook**: auto-tłumaczenie w `sendStoreError/sendStorePurchaseSuccessful`
- **Raids C++**: per-player broadcast w `AnnounceEvent::executeEvent()`

## Commity tej sesji
1. `f5718c4b3` — raids XML + gamestore complete
2. `5b62971e8` — dawnport + data-canary + remaining scripts
3. `9b014f5dc` — NPC complete + JSON sync
