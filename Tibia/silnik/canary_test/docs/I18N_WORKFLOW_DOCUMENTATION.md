# Dokumentacja Pracy i18n — Wielojęzyczność Canary OTS

> **Repozytorium:** PtakuPL/ooo  
> **Gałąź:** `feature/i18n-multilanguage`  
> **Ostatni commit:** `bdad8af98` (2026-02-06)  
> **Katalog projektu:** `/home/ptaku/serweryt/Tibia/silnik/canary_test`

---

## Spis treści

1. [Architektura systemu i18n](#1-architektura-systemu-i18n)
2. [API i18n — jak tłumaczyć tekst](#2-api-i18n--jak-tłumaczyć-tekst)
3. [Struktura plików JSON](#3-struktura-plików-json)
4. [Metodologia pracy — krok po kroku](#4-metodologia-pracy--krok-po-kroku)
5. [Wzorce migracji — Lua](#5-wzorce-migracji--lua)
6. [Wzorce migracji — C++](#6-wzorce-migracji--c)
7. [Wzorce migracji — NPC](#7-wzorce-migracji--npc)
8. [Weryfikacja zmian](#8-weryfikacja-zmian)
9. [Synchronizacja JSON do 55 języków](#9-synchronizacja-json-do-55-języków)
10. [Aktualny stan migracji — metryki](#10-aktualny-stan-migracji--metryki)
11. [Pliki NIE zmigrowane — pełna lista](#11-pliki-nie-zmigrowane--pełna-lista)
12. [Plan do pełnej internacjonalizacji](#12-plan-do-pełnej-internacjonalizacji)
13. [Znane problemy i pułapki](#13-znane-problemy-i-pułapki)
14. [Komendy diagnostyczne](#14-komendy-diagnostyczne)
15. [Historia commitów](#15-historia-commitów)

---

## 1. Architektura systemu i18n

### Warstwy systemu

```
┌─────────────────────────────────────────────────────────────┐
│                    KLIENT (OTClient)                        │
│  Opcjonalnie: odbiera klucz i18n + tłumaczy po stronie    │
│  klienta (jeśli I18N_USE_LOCALIZED_TEXT_PROTOCOL = true)   │
└────────────────────┬────────────────────────────────────────┘
                     │ TCP/Protocol
┌────────────────────▼────────────────────────────────────────┐
│                    SERWER C++                                │
│                                                              │
│  i18n::Translator (singleton)                                │
│  ├── loadLocale("pl") — ładuje i18n/pl/*.json               │
│  ├── get(key, locale) — zwraca przetłumaczony tekst         │
│  ├── format(key, locale, args) — z podstawianiem {0},{1}    │
│  └── buildReverseTextMap() — odwrotne mapowanie tekst→klucz │
│                                                              │
│  Player::sendLocalizedTextMessage(msgClass, key, args)       │
│  ├── Pobiera locale gracza (player.locale)                   │
│  ├── Tłumaczy: g_translator().format(key, locale, args)     │
│  └── Wysyła przetłumaczony tekst do klienta                 │
│                                                              │
│  Player::sendLocalizedCancelMessage(key)                     │
│  Player::sendLocalizedMessageDialog(key, args)               │
└────────────────────┬────────────────────────────────────────┘
                     │ Lua bindings
┌────────────────────▼────────────────────────────────────────┐
│                    SERWER LUA                                │
│                                                              │
│  Bezpośrednie API:                                           │
│  ├── player:sendLocalizedTextMessage(MSG_TYPE, key, {args})  │
│  ├── player:sendLocalizedCancelMessage(key)                  │
│  ├── Translator.getTranslation(player, key)                  │
│  └── Game.broadcastLocalizedMessageLua(key, msgType, args)   │
│                                                              │
│  NPC API (data-otservbr-global/lib/npc/i18n.lua):            │
│  ├── NPC_LIB.i18n.npcSay(handler, npc, creature, key, args) │
│  ├── NPC_LIB.i18n.npcSayMultiple(handler, npc, c, keys)     │
│  ├── NPC_LIB.i18n.setLocalizedMessage(handler, MSG_ID, key)  │
│  ├── NPC_LIB.i18n.setLocalizedGreet(handler, key)            │
│  ├── NPC_LIB.i18n.setLocalizedFarewell(handler, key)         │
│  └── NPC_LIB.i18n.setLocalizedWalkaway(handler, key)         │
│                                                              │
│  NPC Handler (data/npclib/npc_system/npc_handler.lua):       │
│  ├── NpcHandler:setLocalizedMessage(id, key, options)        │
│  ├── NpcHandler:tryLocalizedMessage(id, player)              │
│  ├── NpcHandler:sayLocalized(key, npc, player, args)         │
│  └── 15 domyślnych localizedMessages w NpcHandler:new()      │
│                                                              │
│  Wrappery (data/libs/i18n_wrappers.lua):                     │
│  ├── NPC_LIB.i18n.npcSay() — fallback wrapper               │
│  ├── Item:setLocalizedDescription(key, player)               │
│  ├── Creature:sayLocalizedLua(key, talkType, player, args)   │
│  └── Game.broadcastLocalizedMessageLua(key, msgType, args)   │
└──────────────────────────────────────────────────────────────┘
```

### Kluczowe pliki infrastruktury

| Plik | Rola |
|------|------|
| `src/utils/i18n/translator.hpp/cpp` | C++ klasa Translator — ładowanie JSON, tłumaczenia, reverse lookup |
| `src/creatures/players/player.cpp:2345` | Implementacja `sendLocalizedTextMessage` — C++ |
| `data/libs/server_i18n.lua` | Stary system Lua (szkic) — `t(key, vars, player)`, `sendTextMessageEx()` |
| `data/libs/i18n_wrappers.lua` | NPC_LIB.i18n wrappery, Item/Creature/Game wrappery |
| `data-otservbr-global/lib/npc/i18n.lua` | NPC-specific i18n API: `npcSay`, `setLocalizedMessage`, etc. |
| `data/npclib/npc_system/npc_handler.lua` | NPC handler z `tryLocalizedMessage`, domyślne wiadomości |
| `data/npclib/npc_system/modules.lua` | Moduły NPC (promote, spell, bless, travel) — zlokalizowane |
| `i18n/en/*.json` | 36 plików JSON z kluczami EN (źródło prawdy) |
| `i18n/{lang}/*.json` | 54 katalogi językowe — kopie EN do tłumaczenia |

### Jak C++ przetwarza sendLocalizedTextMessage

```cpp
// src/creatures/players/player.cpp:2345
void Player::sendLocalizedTextMessage(MessageClasses mclass, const std::string &key, 
                                       std::vector<std::string> args) const {
    const std::string &activeLocale = locale.empty() ? fallback : locale;
    
    // Opcja 1: Wyślij klucz do klienta (client-side translation)
    if (I18N_USE_LOCALIZED_TEXT_PROTOCOL && (args.empty() || I18N_SEND_ARGS)) {
        client->sendLocalizedTextMessage(LocalizedTextMessage(mclass, fallbackText, key, args));
        return;
    }
    
    // Opcja 2: Przetłumacz server-side i wyślij gotowy tekst
    sendTextMessage(mclass, g_translator().format(key, activeLocale, args));
}
```

### Jak JSON klucze działają

```json
// i18n/en/scripts.json
{
  "misc.boss_lever.cooldown_wait": "You have to wait {0} to face {1} again!"
}

// i18n/pl/scripts.json  
{
  "misc.boss_lever.cooldown_wait": "Musisz poczekać {0} aby zmierzyć się z {1} ponownie!"
}
```

Argumenty `{0}`, `{1}`, `{2}` są podstawiane w runtime przez `Translator::format()`.

---

## 2. API i18n — jak tłumaczyć tekst

### Lua — główne funkcje

```lua
-- 1. Wiadomość tekstowa z kluczem i18n (NAJCZĘŚCIEJ UŻYWANE)
player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.soul_war.taints_reset")

-- 2. Z argumentami {0}, {1}, ...
player:sendLocalizedTextMessage(MESSAGE_FAILURE, "event.player.stamina_pz_recharge", {gain, delay})

-- 3. Cancel message
player:sendLocalizedCancelMessage("cpp.cancel.cannot_move_house")

-- 4. Pobierz przetłumaczony tekst (do dalszego przetworzenia)
local text = Translator.getTranslation(player, "scripts.find_fiend.monster_msg")

-- 5. NPC mówi do gracza
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oracle.greeting", {player:getName()})

-- 6. NPC — ustaw domyślną wiadomość powitalną
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.oracle.greet_msg_1")

-- 7. NPC handler mówi zlokalizowaną wiadomość
npcHandler:sayLocalized("npclib.modules.bless_success", npc, player, {})

-- 8. Broadcast do wszystkich graczy
Game.broadcastLocalizedMessageLua("globalevents.shutdown.msg_1", MESSAGE_STATUS_WARNING, {minutes})
```

### C++ — główne funkcje

```cpp
// 1. Podstawowa wiadomość z kluczem
player->sendLocalizedTextMessage(MESSAGE_FAILURE, "cpp.cancel.cannot_move_house");

// 2. Z argumentami
player->sendLocalizedTextMessage(MESSAGE_TRADE, "server.game.msg_3", {itemName, std::to_string(price)});

// 3. Cancel message z kluczem
player->sendLocalizedCancelMessage("cpp.cancel.no_pm_self");

// 4. Bezpośrednie tłumaczenie  
std::string text = i18n::g_translator().get("key", locale);
std::string formatted = i18n::g_translator().format("key", locale, args);
```

### Konwencje nazw kluczy

| Prefix | Użycie | Przykład |
|--------|--------|---------|
| `npc.{npc_name}.*` | Dialogi konkretnego NPC | `npc.oracle.greet_msg_1` |
| `npclib.handler.*` | Domyślne wiadomości NPC handler | `npclib.handler.greet` |
| `npclib.modules.*` | Moduły NPC (promote, travel, bless) | `npclib.modules.travel_level_req` |
| `quest.{quest_name}.*` | Wiadomości questowe | `quest.soul_war.taints_reset` |
| `quests.*` | Skrypty questowe (data-otservbr-global) | `quests.bigfoot_burden.teleported_out` |
| `scripts.*` | Skrypty LUA ogólne | `scripts.login.last_visit` |
| `misc.*` | Różne systemy (boss_lever, etc.) | `misc.boss_lever.cooldown_wait` |
| `event.*` | Eventy gracza | `event.player.stamina_pz_recharge` |
| `lib.*` | Biblioteki Lua | `lib.player.loyalty_bonus` |
| `system.*` | Systemy serwera | `system.reward_chest.loot_available` |
| `server.*` | Wiadomości serwerowe C++ | `server.game.msg_1` |
| `cpp.cancel.*` | Cancel messages C++ | `cpp.cancel.wrap_on_floor` |
| `gamestore.*` | Game Store | `gamestore.purchase.success` |

---

## 3. Struktura plików JSON

### Katalog `i18n/`

```
i18n/
├── en/                    ← ŹRÓDŁO PRAWDY (angielski)
│   ├── actions.json       (35 kluczy)
│   ├── books.json         (1,403 kluczy — książki/listy/scrolle)
│   ├── chatchannels.json  (16 kluczy)
│   ├── client.json        (242 klucze — OTClient)
│   ├── cpp.json           (16 kluczy — C++ cancel messages)
│   ├── creaturescripts.json (4 klucze)
│   ├── dataroot.json      (3 klucze)
│   ├── events.json        (14 kluczy)
│   ├── globalevents.json  (5 kluczy)
│   ├── items.json         (16,894 kluczy — Codex items descriptions)
│   ├── libs.json          (70 kluczy)
│   ├── messages.json      (11 kluczy)
│   ├── modules.json       (19 kluczy)
│   ├── monsters.json      (5,915 kluczy)
│   ├── movements.json     (2 klucze)
│   ├── npc.json           (7,257 kluczy — NPC dialogi)
│   ├── npclib.json        (75 kluczy — NPC handler/modules)
│   ├── quests.json        (505 kluczy)
│   ├── raids.json         (273 klucze)
│   ├── scripts.json       (1,232 klucze)
│   ├── server.json        (97 kluczy)
│   ├── spells.json        (1,534 klucze)
│   ├── startup.json       (23 klucze)
│   ├── talkactions.json   (177 kluczy)
│   └── ... (otclient_*, html, php — do klienta/narzędzi)
├── pl/                    ← Polski
├── pt/                    ← Portugalski (Brazylia)
├── es/                    ← Hiszpański
├── de/                    ← Niemiecki
├── ... (55 katalogów językowych łącznie)
└── reports/, status/      ← Katalogi raportów/statusów
```

**WAŻNE:** `i18n/en/` jest źródłem prawdy. Każdy nowy klucz MUSI być najpierw dodany do EN, potem zsynchronizowany do pozostałych języków.

### Łączna liczba kluczy: ~39,449 EN

---

## 4. Metodologia pracy — krok po kroku

### 4.1 Identyfikacja stringów do migracji

#### Krok 1: Znajdź plain `sendTextMessage` (nie-Localized)

```bash
# Lua: Szukaj sendTextMessage BEZ Localized
grep -rn 'sendTextMessage(' data/ data-otservbr-global/ --include="*.lua" | grep -v 'Localized'

# C++: Szukaj sendTextMessage z hardcoded stringami
grep -rn 'sendTextMessage\|sendCancelMessage' src/ --include="*.cpp" | grep -v 'Localized\|//\|void ' | grep '"'
```

#### Krok 2: Kategoryzuj wyniki

Każdy wynik klasyfikuj jako:

| Kategoria | Akcja | Przykład |
|-----------|-------|---------|
| **Player-facing, hardcoded string** | MIGRUJ | `sendTextMessage(MSG, "You have been blessed")` |
| **Pre-translated (Translator.get)** | POMIŃ | `sendTextMessage(MSG, Translator.getTranslation(...))` |
| **Pass-through variable** | POMIŃ | `sendTextMessage(MSG, message)` — message jest parametrem |
| **RETURNVALUE enum** | POMIŃ | `sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)` — C++ |
| **Admin/GM tool** | OPCJONALNIE | `sendTextMessage(MSG_ADMIN, ...)` — niski priorytet |
| **Framework wrapper** | POMIŃ | `functions.lua kickerPlayerRoomAfterMin()` — message parametr |
| **Look description** | SPECJALNIE | `sendTextMessage(MSG_LOOK, desc)` — C++/hybrid |
| **Logger/debug** | POMIŃ | Komunikaty do logów |

#### Krok 3: Czytaj dokładny kontekst

```bash
# Przed edycją ZAWSZE przeczytaj kontekst
read_file(filePath, startLine, endLine)

# Lub via terminal
sed -n '200,230p' data/libs/functions/boss_lever.lua
```

### 4.2 Migracja stringa

#### Schemat ogólny:

```
1. Przeczytaj plik (read_file lub sed) 
2. Wybierz klucz i18n (npc.*, quest.*, misc.*, etc.)
3. Zamień sendTextMessage → sendLocalizedTextMessage
4. Dodaj klucz do JSON EN
5. Zsynchronizuj do 55 języków
6. Zweryfikuj (grep, get_errors)
```

#### Wzorzec zamiany:

```lua
-- PRZED:
player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your taints have been reset.")

-- PO:
player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.soul_war.taints_reset")
```

```lua
-- PRZED (z argumentami):
local msg = string.format("You need %d players.", self.minPlayers)
creature:sendTextMessage(MESSAGE_EVENT_ADVANCE, msg)

-- PO:
creature:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "misc.boss_lever.min_players", {self.minPlayers})
```

### 4.3 Dodanie klucza do JSON

```python
# Użyj Python (inline) aby dodać klucze
import json
with open('i18n/en/scripts.json', 'r') as f:
    data = json.load(f)
data["misc.boss_lever.min_players"] = "You need {0} qualified players for this challenge."
with open('i18n/en/scripts.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
```

### 4.4 Edycja plików

Dwa podejścia:

1. **`replace_string_in_file`** — dla pojedynczych zamian. WYMAGA 3-5 linii kontekstu PRZED i PO.
2. **`multi_replace_string_in_file`** — dla wielu zamian naraz (efektywniejsze).

**UWAGA:** Skrypt Python z `string.replace()` ZAWODZI jeśli whitespace (taby vs spacje) nie pasuje idealnie. Używaj narzędzi VS Code (`replace_string_in_file`) lub `sed` z regex.

---

## 5. Wzorce migracji — Lua

### Wzorzec 1: Prosty string → klucz

```lua
-- PRZED:
player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have been blessed by the ...")

-- PO:
player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "npclib.modules.bless_success")
```

### Wzorzec 2: String z konkatenacją → klucz z args

```lua
-- PRZED:
local msg = "You earned " .. amount .. " points for the gnomes."
player:sendTextMessage(MESSAGE_EVENT_ADVANCE, msg)

-- PO:
player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.dangerous_depths.earned_points_gnomes", {amount})
```

JSON: `"quest.dangerous_depths.earned_points_gnomes": "You earned {0} points for the gnomes."`

### Wzorzec 3: Broken concat (BUG) → naprawiony klucz

```lua
-- PRZED (BUG!):
npcHandler:sayLocalized("misc.modules.say_10" .. parameters.level .. " before I can let you go there.", npc, player)
-- ^ To generuje klucz "misc.modules.say_10100 before I can let you go there." — BRAK tłumaczenia!

-- PO:
npcHandler:sayLocalized("npclib.modules.travel_level_req", npc, player, {parameters.level})
```

### Wzorzec 4: string.format → sendLocalizedTextMessage z args

```lua
-- PRZED:
local message = string.format("In protection zone. Recharging %i stamina every %i minutes.", gain, delay)
self:sendTextMessage(MESSAGE_FAILURE, message)

-- PO:
self:sendLocalizedTextMessage(MESSAGE_FAILURE, "event.player.stamina_pz_recharge", {gain, delay})
```

### Wzorzec 5: Dynamiczny tekst z Translator.getTranslation

Gdy tekst jest budowany dynamicznie (lista, pętla), użyj `Translator.getTranslation`:

```lua
-- PRZED:
local header = "Received blessings:"
-- ... pętla dodaje nazwy blessów ...
player:sendTextMessage(MESSAGE_EVENT_ADVANCE, result)

-- PO:
local header = Translator.getTranslation(player, "lib.blessing.received_header")
-- ... pętla dodaje nazwy blessów ...
player:sendTextMessage(MESSAGE_EVENT_ADVANCE, result)  -- OK, bo header jest przetłumaczony
```

### Wzorzec 6: Warunkowo różne wiadomości → osobne klucze

```lua
-- PRZED:
local resetMessage = "Your Goshnar's taints have been reset."
if not skipCheckTime then
    resetMessage = resetMessage .. " You didn't finish the quest in 14 days."
end
self:sendTextMessage(MESSAGE_EVENT_ADVANCE, resetMessage)

-- PO:
if skipCheckTime then
    self:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.soul_war.taints_reset")
else
    self:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.soul_war.taints_reset_timeout")
end
```

### Wzorzec 7: Funkcja zwraca string → zwraca klucz i18n

```lua
-- PRZED:
function addItems(npc, player)
    if player:getFreeCapacity() < totalWeight then
        return false, "You don't have enough weight."
    end
end
-- caller:
local success, message = addItems(npc, player)
if not success then
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
end

-- PO:
function addItems(npc, player)
    if player:getFreeCapacity() < totalWeight then
        return false, "npc.imbuement_assistant.not_enough_cap"  -- zwraca KLUCZ
    end
end
-- caller:
local success, message = addItems(npc, player)
if not success then
    player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, message)  -- klucz → auto-translate
end
```

---

## 6. Wzorce migracji — C++

### Zasada: C++ pliki edytuj RĘCZNIE

Użytkownik ustalił: "takie pliki lepiej edytować ręcznie" — C++ wymaga ostrożności.

### Wzorzec C++:

```cpp
// PRZED:
player->sendTextMessage(MESSAGE_FAILURE, "You cannot move this item.");

// PO:
player->sendLocalizedTextMessage(MESSAGE_FAILURE, "cpp.cancel.cannot_move_house");
```

### RETURNVALUE (sendCancelMessage z enum)

Te NIE wymagają migracji — C++ `sendCancelMessage(RETURNVALUE_*)` tłumaczy się automatycznie na stałe komunikaty w `Game::getReturnMessage()`. Stanowią ~160 wywołań w `game.cpp`.

### Aktualna statystyka C++:

- **147** `sendLocalizedTextMessage` — **ZROBIONE**
- **~327** plain `sendTextMessage/sendCancelMessage` — z czego:
  - **~160** to RETURNVALUE enum (automatyczne, nie migruj)
  - **~120** to `fmt::format` z dynamicznymi danymi (nazwy graczy, pozycje, etc.)
  - **~30** to deklaracje/void/nullptr/return
  - **0** hardcoded angielskich stringów do migracji

**C++ jest praktycznie w 100% zmigrowane** — pozostałe `sendTextMessage` to RETURNVALUE enum, dynamiczne dane, lub framework plumbing.

---

## 7. Wzorce migracji — NPC

### 7.1 NPC Handler domyślne wiadomości (AUTOMATYCZNE)

W `npc_handler.lua:125-141` zdefiniowaliśmy 15 domyślnych zlokalizowanych wiadomości:

```lua
obj.localizedMessages[MESSAGE_GREET] = "npclib.handler.greet"
obj.localizedMessages[MESSAGE_FAREWELL] = "npclib.handler.farewell"
obj.localizedMessages[MESSAGE_BUY] = "npclib.handler.buy"
-- ... itd. (15 wiadomości)
```

**Każdy NPC, który NIE wywołuje `setMessage()`, automatycznie używa tłumaczonych domyślnych wiadomości.**

### 7.2 NPC z własnym greet/farewell

```lua
-- Na dole pliku NPC:
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.oracle.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.oracle.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.oracle.walkaway_msg_1")
```

### 7.3 NPC mówi w dialogu

```lua
-- Prosty:
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oracle.say_1")

-- Z argumentami:
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oracle.level_info", {player:getLevel()})

-- Wiele wiadomości po kolei:
NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
    "npc.oracle.intro_1",
    "npc.oracle.intro_2",
    "npc.oracle.intro_3"
})
```

### 7.4 NPC modules (promote, travel, bless)

Moduły w `modules.lua` używają kluczy `npclib.modules.*`:

```lua
npcHandler:sayLocalized("npclib.modules.already_promoted", npc, player)
npcHandler:sayLocalized("npclib.modules.travel_level_req", npc, player, {parameters.level})
```

**Lista 17 kluczy modules** (były broken `misc.modules.say_*`):
- `npclib.modules.already_promoted`
- `npclib.modules.promote_no_money`
- `npclib.modules.promote_need_premium`
- `npclib.modules.spell_already_known`
- `npclib.modules.spell_cannot_learn`
- `npclib.modules.bless_already_have`
- `npclib.modules.bless_need_geomancer`
- `npclib.modules.bless_no_money`
- `npclib.modules.travel_need_premium`
- `npclib.modules.travel_level_req`
- `npclib.modules.travel_pz_locked`
- `npclib.modules.travel_no_money`
- `npclib.modules.travel_exhaustion`
- `npclib.modules.confirm_no_money`
- `npclib.modules.confirm_pz_locked`
- `npclib.modules.confirm_success`
- `npclib.modules.confirm_need_premium`

---

## 8. Weryfikacja zmian

### 8.1 Sprawdź, ile sendTextMessage zostało (Lua)

```bash
# Nie-Localized sendTextMessage w Lua
grep -rn 'sendTextMessage(' data/ data-otservbr-global/ --include="*.lua" | grep -v 'Localized' | wc -l

# Lista plików
grep -rn 'sendTextMessage(' data/ data-otservbr-global/ --include="*.lua" | grep -v 'Localized' | awk -F: '{print $1}' | sort -u
```

**Oczekiwany wynik (luty 2026):** 25-30 linii (wrappery, pre-translated, admin tools)

### 8.2 Sprawdź C++ 

```bash
# C++ z hardcoded stringami (powinno być 0)
grep -rn 'sendTextMessage\|sendCancelMessage' src/ --include="*.cpp" | grep -v 'Localized\|//\|void \|RETURNVALUE\|nullptr\|logger\|return\|retval\|registerMethod\|luaPlayer' | grep '"' | grep -iv 'register\|push'
```

### 8.3 Sprawdź czy klucz istnieje w JSON

```bash
# Szukaj klucza w EN JSON
grep 'misc.boss_lever.cooldown_wait' i18n/en/scripts.json

# Szukaj we WSZYSTKICH JSON
grep -rn 'misc.boss_lever' i18n/en/*.json
```

### 8.4 Sprawdź synchronizację między językami

```bash
python3 -c "
import json, glob
en_keys = set()
for f in glob.glob('i18n/en/*.json'):
    with open(f) as fh:
        en_keys.update(json.load(fh).keys())

for f in sorted(glob.glob('i18n/pl/*.json')):
    with open(f) as fh:
        pl_keys = set(json.load(fh).keys())
    missing = en_keys - pl_keys
    if missing:
        print(f'{f}: brakuje {len(missing)} kluczy')
"
```

### 8.5 Sprawdź broken key references (klucze użyte w kodzie ale brakujące w JSON)

```bash
# Wyodrębnij klucze z kodu Lua
grep -ohP '"(npc\.|quest\.|misc\.|event\.|lib\.|system\.|scripts\.|npclib\.)[a-zA-Z0-9_.]*"' data/ data-otservbr-global/ -r --include="*.lua" | tr -d '"' | sort -u > /tmp/used_keys.txt

# Wyodrębnij klucze z JSON EN
python3 -c "
import json, glob
keys = set()
for f in glob.glob('i18n/en/*.json'):
    with open(f) as fh:
        keys.update(json.load(fh).keys())
for k in sorted(keys):
    print(k)
" > /tmp/json_keys.txt

# Porównaj
comm -23 /tmp/used_keys.txt /tmp/json_keys.txt | head -20
```

### 8.6 Sprawdź duplikaty kluczy

```bash
python3 -c "
import json, glob
all_keys = {}
for f in sorted(glob.glob('i18n/en/*.json')):
    with open(f) as fh:
        data = json.load(fh)
    for k in data:
        if k in all_keys:
            print(f'DUPLIKAT: {k} w {f} i {all_keys[k]}')
        else:
            all_keys[k] = f
print(f'Unikalne klucze: {len(all_keys)}')
"
```

### 8.7 Sprawdź błędy kompilacji po edycji

```bash
# Użyj narzędzia get_errors w VS Code
get_errors()


```

---

## 9. Synchronizacja JSON do 55 języków

### Skrypt synchronizacji (uruchamiany PO każdej edycji EN JSON)

```python
import json, os, glob

en_dir = 'i18n/en'
base_dir = 'i18n'

lang_dirs = [d for d in os.listdir(base_dir) 
             if os.path.isdir(os.path.join(base_dir, d)) and d != 'en']

total_added = 0
for en_file in sorted(glob.glob(os.path.join(en_dir, '*.json'))):
    filename = os.path.basename(en_file)
    
    with open(en_file, 'r') as f:
        en_data = json.load(f)
    
    for lang in sorted(lang_dirs):
        lang_file = os.path.join(base_dir, lang, filename)
        
        if os.path.exists(lang_file):
            with open(lang_file, 'r') as f:
                lang_data = json.load(f)
        else:
            lang_data = {}
        
        added = 0
        for key, value in en_data.items():
            if key not in lang_data:
                lang_data[key] = value  # EN fallback
                added += 1
        
        if added > 0:
            os.makedirs(os.path.dirname(lang_file), exist_ok=True)
            with open(lang_file, 'w') as f:
                json.dump(lang_data, f, indent=2, ensure_ascii=False)
                f.write('\n')
            total_added += added

print(f'Total keys synced: {total_added}')
```

**WAŻNE:** Ten skrypt dodaje brakujące klucze z wartościami EN jako fallback. Nie nadpisuje istniejących tłumaczeń.

---

## 10. Aktualny stan migracji — metryki

### Lua

| Metryka | Wartość |
|---------|---------|
| `sendLocalizedTextMessage` / `sendLocalizedCancelMessage` | **1,407** wywołań |
| `NPC_LIB.i18n.*` | **8,638** wywołań |
| `Translator.getTranslation` | **53** wywołania |
| Plain `sendTextMessage` (nie-Localized) | **~26** (wrappery + pre-translated) |
| **Procent migracji Lua** | **~99.7%** |

### C++

| Metryka | Wartość |
|---------|---------|
| `sendLocalizedTextMessage` / `sendLocalizedCancelMessage` | **147** wywołań |
| Plain `sendTextMessage` z RETURNVALUE enum | **~160** (nie wymagają migracji) |
| Plain `sendTextMessage` z dynamicznymi danymi | **~120** (framework plumbing) |
| Hardcoded angielskie stringi | **0** |
| **Procent migracji C++** | **100%** (stringów player-facing) |

### NPC

| Metryka | Wartość |
|---------|---------|
| NPC z zlokalizowanymi dialogami | **~580+** z ~600 |
| Klucze `npc.json` | **7,257** |
| Klucze `npclib.json` | **75** (handler + modules) |
| Domyślne messages handler | **15** (auto-translate) |
| **Procent migracji NPC** | **~99%** |

### JSON

| Metryka | Wartość |
|---------|---------|
| Pliki JSON EN | **36** plików |
| Łączne klucze EN | **39,449** |
| Katalogi językowe | **55** |
| Największe pliki | items.json (16,894), npc.json (7,257), monsters.json (5,915) |

---

## 11. Pliki NIE zmigrowane — pełna lista

### 11.1 Lua — plain sendTextMessage (25 plików, ~26 linii)

#### A) Wrappery frameworkowe (NIE MIGRUJ — to infrastruktura)

| Plik | Linia | Typ | Powód pominięcia |
|------|-------|-----|------------------|
| `data/libs/server_i18n.lua:57` | `player:sendTextMessage(msgType, t(key, vars, player))` | Framework | Implementacja `sendTextMessageEx` — sam tłumaczy |
| `data/libs/compat/compat.lua:786` | `p:sendTextMessage(type, text, ...)` | Framework | Kompatybilność wsteczna |
| `data/libs/functions/player.lua:48` | `sendTextMessage(MESSAGE_FAILURE, message)` | Framework | Wrapper `sendCancelMessage` — message z `Game.getReturnMessage()` |
| `data/libs/functions/game.lua:40` | `player:sendTextMessage(messageType, message)` | Framework | Pass-through wrapper |
| `data/libs/functions/functions.lua:591,617` | `player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)` | Framework | `kickerPlayerRoomAfterMin` — message jest parametrem |
| `data/libs/systems/zones.lua:39,42` | `Zone:sendTextMessage(...)` | Framework | Variadic pass-through |
| `data/libs/systems/encounters.lua:254,258` | `player:sendTextMessage(...)` | Framework | Variadic pass-through |
| `data/libs/functions/party.lua:2,7` | `sendTextMessage(MESSAGE_LOOT, text)` | Framework | Loot text — generowany dynamicznie |

#### B) Pre-translated (ALREADY DONE — using Translator)

| Plik | Powód pominięcia |
|------|------------------|
| `data/scripts/creaturescripts/player/offline_training.lua:55` | Używa `Translator.getTranslation` — tekst jest pre-translated |
| `data/scripts/creaturescripts/player/login.lua:23` | Używa `Translator.getTranslation` — loginStr pre-translated |
| `data/scripts/spells/support/find_person.lua:76` | Używa `Translator.getTranslation` — msgText pre-translated |
| `data/scripts/spells/support/find_fiend.lua:109` | Używa `Translator.getTranslation` — message pre-translated |

#### C) Look descriptions (SPECJALNY PRZYPADEK — raczej C++ side)

| Plik | Powód |
|------|-------|
| `data/scripts/eventcallbacks/player/on_look.lua:138` | `descriptionText` — przetworzony przez cały pipeline look |
| `data/scripts/eventcallbacks/player/on_look_in_trade.lua:5` | `item:getDescription()` — z C++ |
| `data/events/scripts/player.lua:236` | `description` — look description z C++ |
| `data/events/scripts/player.lua:316` | `Game.getReturnMessage(RETURNVALUE_*)` — enum, nie string |

#### D) Blessing list (CZĘŚCIOWO)

| Plik | Linia | Status |
|------|-------|--------|
| `data/libs/systems/blessing.lua:220` | `player:sendTextMessage(MESSAGE_EVENT_ADVANCE, result)` | Header przetłumaczony, ale nazwy blessów (*Wisdom of Solitude* etc.) — z danych gry |

#### E) Soul war mechanics (CZĘŚCIOWO)

| Plik | Linia | Status |
|------|-------|--------|
| `data-otservbr-global/scripts/quests/soul_war/soul_war_mechanics.lua:186` | `player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)` | Szablony przetłumaczone via `Translator.getTranslation`, ale nazwy apparitions z danych gry |

### 11.2 GM/GOD Tools — 8 niezmigrowanych linii

| Plik | Linia | Tekst | Priorytet |
|------|-------|-------|-----------|
| `data/scripts/talkactions/gm/getlook.lua:19` | `'<look type="..." />'` | XML do klienta — TECHNICZNY, nie migruj |
| `data/scripts/talkactions/gm/mc_check.lua:32` | `MESSAGE_ADMINISTRATOR, message .. "."` | Admin tool — niski priorytet |
| `data/scripts/talkactions/gm/broadcast.lua:8` | `MESSAGE_ADMINISTRATOR, text` | Pass-through — gracz podaje tekst |
| `data/scripts/talkactions/god/create_summon.lua:15` | `sendCancelMessage(RETURNVALUE_NOTENOUGHROOM)` | RETURNVALUE — auto |
| `data/scripts/talkactions/god/raids.lua:24` | `Game.getReturnMessage(returnValue)` | ReturnValue — auto |
| `data/scripts/talkactions/god/start_raid.lua:14` | `Game.getReturnMessage(returnValue)` | ReturnValue — auto |
| `data/scripts/talkactions/god/manage_tutor.lua:75` | `--targetPlayer:sendTextMessage(...)` | ZAKOMENTOWANE |
| `data/scripts/talkactions/god/test.lua:78` | `"You " .. playerMessage` | GOD test tool — niski priorytet |

**Status GM/GOD:** 335 `sendLocalized` vs 8 plain — **97.7% zmigrowane**

### 11.3 Online player list

| Plik | Status |
|------|--------|
| `data/scripts/talkactions/player/online.lua:44` | Dynamiczna lista graczy online — nazwy to dane, nie tłumaczenia |

### 11.4 Pliki JSON z 0 kluczy (puste — do uzupełnienia)

- `i18n/en/errors.json` (0 kluczy)
- `i18n/en/mounts.json` (0 kluczy)
- `i18n/en/ui.json` (0 kluczy)
- `i18n/en/world.json` (0 kluczy)
- `i18n/en/otclient_mods.json` (0 kluczy)
- `i18n/en/otclient_src.json` (0 kluczy)
- `i18n/en/otclient_tools.json` (0 kluczy)

### 11.5 C++ RETURNVALUE messages

~160 `sendCancelMessage(RETURNVALUE_*)` w `game.cpp` — te komunikaty są mapowane przez `Game::getReturnMessage()` w C++ do stałych angielskich tekstów. Aby je przetłumaczyć:

1. Zmienić `Game::getReturnMessage()` aby zwracał klucz i18n
2. Lub zmienić `Player::sendCancelMessage()` aby tłumaczyło przed wysłaniem

To jest **duża zmiana C++** — nie jest jeszcze zrobiona.

---

## 12. Plan do pełnej internacjonalizacji

### Faza 1: ZROBIONE ✅

- [x] Infrastruktura C++ Translator (JSON loader, format, reverse lookup)
- [x] Player::sendLocalizedTextMessage w C++
- [x] Lua bindings (sendLocalizedTextMessage, sendLocalizedCancelMessage)
- [x] NPC i18n system (NPC_LIB.i18n.*, npcHandler, modules)
- [x] Migracja ~1,407 Lua sendLocalizedTextMessage
- [x] Migracja ~8,638 NPC_LIB.i18n
- [x] Migracja C++ game.cpp, player.cpp, etc.
- [x] 39,449 kluczy EN, 55 języków zsynchronizowanych
- [x] Książki/scrolle (1,403 klucze)
- [x] Raidy XML (273 klucze)
- [x] Gamestore (91 kluczy)
- [x] Items descriptions (16,894 klucze — Codex agent)
- [x] Monsters (5,915 kluczy)
- [x] NPC handler domyślne wiadomości (15 kluczy auto)
- [x] Modules.lua bugfix (17 broken keys)

### Faza 2: DO ZROBIENIA — Serwer

| Zadanie | Priorytet | Szacowany nakład |
|---------|-----------|-----------------|
| **C++ RETURNVALUE messages** (~160 w game.cpp) | WYSOKI | Zmiana `Game::getReturnMessage()` lub `sendCancelMessage()` |
| **C++ ReturnValue enum → klucze i18n** | WYSOKI | ~160 słownik enum→klucz |
| **Item getDescription()** — C++ look system | WYSOKI | Duża zmiana — opisy itemów generowane dynamicznie |
| **Blessing nazwy** (Wisdom of Solitude, etc.) | ŚREDNI | Dane gry, nie teksty |
| **Spell nazwy/opisy** | ŚREDNI | spells.json ma 1,534 klucze, ale nazwy zaklęć z C++ |
| **Mount/Outfit nazwy** | NISKI | Dane z C++ ItemType/MonsterType |

### Faza 3: DO ZROBIENIA — Klient (OTClient)

| Zadanie | Priorytet |
|---------|-----------|
| **OTClient moduły** — `otclient_modules.json` (1,987 kluczy) | WYSOKI |
| **OTClient data** — `otclient_data.json` (72 klucze) | ŚREDNI |
| **Strona HTML/PHP** — `html.json` (1,495), `php.json` (59) | NISKI |
| **UI klienta** — `ui.json` (0 kluczy — pusty!) | WYSOKI |
| **Protokół klient-serwer** — I18N_USE_LOCALIZED_TEXT_PROTOCOL | ŚREDNI |

### Faza 4: DO ZROBIENIA — Tłumaczenia

| Zadanie | Priorytet |
|---------|-----------|
| **Przetłumaczenie PL** — podmiany wartości w `i18n/pl/*.json` | WYSOKI |
| **Przetłumaczenie PT-BR** — duża społeczność Tibia | WYSOKI |
| **Przetłumaczenie ES** | ŚREDNI |
| **Reszta języków** — community crowdsourcing | NISKI |

### Faza 5: Codex Agent branches (DO MERGE)

Codex agent pracuje na oddzielnych branchach:
- `copilot/add-i18n-migrations`
- `copilot/add-i18n-support-for-tibi`
- `copilot/check-i18n-keys-implementation`
- `copilot/create-full-en-lua-file`

**Te branchy NIE są jeszcze zmergowane** do `feature/i18n-multilanguage`. Trzeba:
1. `git fetch --all`
2. Przejrzeć PR-y Codex
3. Zmergować (rozwiązując konflikty JSON)

---

## 13. Znane problemy i pułapki

### 13.1 Python migration script ZAWODZI na whitespace

Problem: `string.replace()` w Python wymaga dokładnego dopasowania whitespace. Pliki Lua mogą mieć taby lub spacje — Python string literals mogą nie pasować.

**Rozwiązanie:** Używaj `replace_string_in_file` z VS Code lub `sed` z regex.

### 13.2 Broken concat w kluczu i18n

```lua
-- BUG: klucz + tekst = śmieci
npcHandler:sayLocalized("misc.modules.say_10" .. parameters.level .. " before I can let you go there.", npc, player)
-- Generuje klucz: "misc.modules.say_10100 before I can let you go there."
-- Taki klucz NIGDY nie istnieje w JSON!
```

**Jak znaleźć:** `grep -rn 'sayLocalized\|sendLocalizedTextMessage' data/ --include="*.lua" | grep '\.\.'`

### 13.3 Brakujący parametr `npc` w sayLocalized

```lua
-- BUG: brak npc
npcHandler:sayLocalized("key", player)  -- ŹLEEE

-- POPRAWNIE:
npcHandler:sayLocalized("key", npc, player)
```

### 13.4 setMessage() czyści localized

```lua
-- npc_handler.lua:417-418
-- setMessage() CZYŚCI localizedMessages[id]
function NpcHandler:setMessage(id, msg)
    self.messages[id] = msg
    self.localizedMessages[id] = nil  -- <-- UWAGA!
end
```

Jeśli NPC wywołuje `setMessage(MESSAGE_GREET, "Hi!")`, to domyślna zlokalizowana wiadomość `npclib.handler.greet` **przestaje działać** dla tego NPC. To jest **zamierzone** — setMessage = override.

### 13.5 Klucze z `msg_1`, `msg_2` naming

Wiele kluczy ma nazwy `npc.oracle.msg_1`, `lib.player.msg_2` — to wynik automatycznego workera. **Lepiej** używać opisowych nazw jak `npc.oracle.level_check`, ale zmiana WYMAGA aktualizacji OBIE strony (kod + JSON).

### 13.6 JSON encoding

Używaj `json.dump(..., ensure_ascii=False)` aby zachować znaki Unicode (polskie, chińskie, etc.).

---

## 14. Komendy diagnostyczne

### Szybki audit

```bash
# Ile sendTextMessage zostało (Lua)?
grep -rn 'sendTextMessage(' data/ data-otservbr-global/ --include="*.lua" | grep -v 'Localized' | wc -l

# Ile sendLocalizedTextMessage (Lua)?
grep -rn 'sendLocalizedTextMessage\|sendLocalizedCancelMessage' data/ data-otservbr-global/ --include="*.lua" | wc -l

# Ile NPC_LIB.i18n?
grep -rn 'NPC_LIB.i18n' data/ data-otservbr-global/ --include="*.lua" | wc -l

# Klucze EN total?
python3 -c "import json,glob; print(sum(len(json.load(open(f))) for f in glob.glob('i18n/en/*.json')))"

# Klucze per plik?
python3 -c "
import json,glob
for f in sorted(glob.glob('i18n/en/*.json')):
    print(f'{f}: {len(json.load(open(f)))} keys')
"
```

### Git status

```bash
# Ostatni commit
git log --oneline -1

# Zmiany nie-zatwierdzone
git status --short

# Porównanie z master
git log --oneline master..feature/i18n-multilanguage | grep -v 'I18N status\|guardian\|Auto-sync' | wc -l
```

### Sync check

```bash
# Sprawdź czy wszystkie języki mają te same klucze co EN
python3 -c "
import json,glob,os
en_keys = {}
for f in glob.glob('i18n/en/*.json'):
    with open(f) as fh:
        en_keys[os.path.basename(f)] = set(json.load(fh).keys())

for lang_dir in sorted(glob.glob('i18n/*/')):
    lang = os.path.basename(lang_dir.rstrip('/'))
    if lang in ('en','reports','status'): continue
    total_missing = 0
    for filename, keys in en_keys.items():
        lang_file = os.path.join(lang_dir, filename)
        if os.path.exists(lang_file):
            with open(lang_file) as fh:
                lang_keys = set(json.load(fh).keys())
            missing = len(keys - lang_keys)
            total_missing += missing
    if total_missing > 0:
        print(f'{lang}: brakuje {total_missing} kluczy')
"
```

---

## 15. Historia commitów

Główne commity (bez auto-sync/guardian):

| Commit | Opis |
|--------|------|
| `fcf96fcec` | 🌍 feat(i18n): Add multilanguage support — infrastruktura |
| `adc901c4c` | books/letters/scrolls migration — 1,403 klucze |
| `3fdc5d7ff` | Migrate remaining Lua libs/systems |
| `f26207a2e` | Migrate ALL remaining Lua hardcoded strings |
| `c35556f41` | on_look, wall_mirror, foods, dolls, potions, globalevents |
| `fdec35a96` | Quest scripts P1+P2 — 100 edits, 81 keys |
| `2c04da790` | Core quest systems P3+P4 — 377 edits |
| `74f6781f4` | P5 — say/doCreatureSay/config tables, 358 edits |
| `091b540d1` | P6 final batch — find_person, offline_training, login, etc. |
| `f5718c4b3` | Raids XML (126 keys) + gamestore (91 keys) |
| `5b62971e8` | Dawnport vocation trials, data-canary |
| `9b014f5dc` | NPC cranky_lizard_crone + bertram |
| `e25b8be85` | Fix corrupted JSON + documentation |
| `bdad8af98` | **CURRENT** — Complete Lua migration + NPC handler defaults + modules fix |

---

## Notatki dla nowego okna czatu

1. **Gałąź:** `feature/i18n-multilanguage` — ZAWSZE pracuj na tej gałęzi
2. **Katalog:** `/home/ptaku/serweryt/Tibia/silnik/canary_test`
3. **Język komunikacji:** Polski
4. **C++ pliki:** Edytuj ręcznie (instrukcja użytkownika)
5. **Codex agent:** Pracuje równolegle na osobnych branchach — jeszcze nie zmergowane
6. **Główne API:** `player:sendLocalizedTextMessage(MSG, key, {args})`
7. **NPC API:** `NPC_LIB.i18n.npcSay(handler, npc, creature, key, args)`
8. **JSON sync:** Po każdej edycji EN — uruchom skrypt sync do 55 języków
9. **Weryfikacja:** Zawsze `grep -v Localized` po zmianach, sprawdź JSON klucze
