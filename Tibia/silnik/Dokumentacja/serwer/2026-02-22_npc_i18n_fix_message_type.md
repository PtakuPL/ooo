# Fix NPC i18n: MESSAGE_NPC_FROM + okno czatu NPC
**Data**: 2026-02-22  
**Status**: NAPRAWIONE  

---

## 1. Problem: NPC nie odpowiadał — "Message type is wrong"

### 1.1 Objawy
- Gracz mówi "hi" do NPC → brak odpowiedzi
- W logach serwera: `[error] [ProtocolGame::sendTextMessage] - Message type is wrong, missing or invalid for player with name Ptaku`
- Dodatkowy warning: `Failed to format translation '...' (locale 'pl'): argument not found`

### 1.2 Przyczyna
Stała `MESSAGE_NPC_FROM` była używana w 4 miejscach Lua, ale **nigdy nie została zdefiniowana**:
- Nie istniała w C++ enum `MessageClasses` (`utils_definitions.hpp`)
- Nie była zarejestrowana w `lua_enums.cpp`
- Nie miała fallbacka w żadnym pliku Lua

Pliki używające `MESSAGE_NPC_FROM`:
1. `data/npclib/npc_system/npc_handler.lua` linia 200 (tryLocalizedMessage)
2. `data/npclib/npc_system/npc_handler.lua` linia 794 (sayLocalized)
3. `data/npclib/npc_system/modules.lua` linia 87
4. `data/libs/i18n_wrappers.lua` linia 35

Ponieważ `MESSAGE_NPC_FROM` w Lua = `nil`, po konwersji na int dawało `0` = `MESSAGE_NONE`.
W `ProtocolGame::sendTextMessage()` (protocolgame.cpp:4854): `if (message.type == MESSAGE_NONE)` → error + return.

### 1.3 Fix (faza 1): Dodanie stałej Lua
**Plik**: `data/libs/i18n_wrappers.lua` (na początku pliku)
```lua
if MESSAGE_NPC_FROM == nil then
    MESSAGE_NPC_FROM = MESSAGE_TRADE  -- 32 = Green message in game window
end
```

**Plik**: `data/npclib/npc_system/npc_handler.lua` (na początku NPC const)
```lua
MESSAGE_NPC_FROM = MESSAGE_NPC_FROM or MESSAGE_TRADE
```

### 1.4 Fix (faza 1 poprawiona): Dodanie do C++ enum i rejestracji
**Plik**: `src/utils/utils_definitions.hpp` — dodano `MESSAGE_NPC_FROM = 36` do enum MessageClasses  
**Plik**: `src/lua/functions/core/game/lua_enums.cpp` — dodano `registerEnum(L, MESSAGE_NPC_FROM)`

---

## 2. Problem: Wiadomości NPC nie otwierały okna czatu

### 2.1 Objawy
Po fixie MESSAGE_NPC_FROM NPC odpowiadał, ale tekst pojawiał się tylko w konsoli (opcode 0xB4), a **okno czatu NPC się nie otwierało**.

### 2.2 Przyczyna
Metody i18n w NPC handler używały:
```lua
player:sendLocalizedTextMessage(MESSAGE_NPC_FROM, key, args)
```
To wywołuje C++ `Player::sendLocalizedTextMessage()` → `sendTextMessage()` → opcode `0xB4` (tekst w konsoli).

Natomiast normalna metoda `NpcHandler:say()` używa:
```lua
npc:say(text, TALKTYPE_PRIVATE_NP, false, player, npc:getPosition())
```
To wysyła opcode `0xAA` — **który otwiera okno czatu NPC** i wyświetla tekst na żółto nad postacią.

### 2.3 Analiza dwóch ścieżek protokołu

| Metoda | Opcode | Efekt w kliencie |
|--------|--------|------------------|
| `sendTextMessage(mclass, text)` | `0xB4` | Tekst w konsoli/oknie gry — NIE otwiera czatu NPC |
| `npc:say(text, TALKTYPE_PRIVATE_NP, ...)` | `0xAA` | Otwiera okno czatu NPC + żółty tekst nad postacią |

### 2.4 Fix: Server-side translation + npc:say()
**Podejście**: Zamiast wysyłać klucz i18n przez `sendLocalizedTextMessage`, przetłumaczyć tekst server-side przez `player:getTranslation(key, args)` (C++ `Translator::format()`), a potem wysłać przez standardowy `npc:say()`.

**Zmienione pliki**:

#### `data/npclib/npc_system/npc_handler.lua`
1. **`tryLocalizedMessage(id, player)`** → `tryLocalizedMessage(id, player, npc)`:
   - Dodano parametr `npc`
   - Zamieniono `player:sendLocalizedTextMessage(...)` na:
     ```lua
     local translated = player:getTranslation(entry.key, args)
     npc:say(translated, TALKTYPE_PRIVATE_NP, false, player, npc:getPosition())
     ```

2. **`sayLocalized(key, npc, player, args, ...)`**:
   - Zamieniono `player:sendLocalizedTextMessage(...)` na:
     ```lua
     local translated = targetPlayer:getTranslation(msgKey, msgArgs)
     npcEntity:say(translated, TALKTYPE_PRIVATE_NP, false, targetPlayer, npcEntity:getPosition())
     ```

3. **Wszystkie wywołania `tryLocalizedMessage`** zaktualizowane o parametr `npc`:
   - FAREWELL (linia ~474): `self:tryLocalizedMessage(MESSAGE_FAREWELL, player, npc)`
   - GREET (linia ~497): `self:tryLocalizedMessage(MESSAGE_GREET, player, npc)`
   - SENDTRADE (linia ~580): `self:tryLocalizedMessage(MESSAGE_SENDTRADE, player, npc)`
   - WALKAWAY* (linie ~658-663): `self:tryLocalizedMessage(MESSAGE_WALKAWAY_*, player, npc)`

#### `data/npclib/npc_system/modules.lua`
- Linia 87: Zamieniono `player:sendLocalizedTextMessage(MESSAGE_NPC_FROM, ...)` na:
  ```lua
  local translated = player:getTranslation(parameters.i18nKey, args)
  npc:say(translated, TALKTYPE_PRIVATE_NP, false, player, npc:getPosition())
  ```

#### `data/libs/i18n_wrappers.lua`
- Fallback `NPC_LIB.i18n.npcSay`: zamieniono na `player:getTranslation()` + `npc:say()`

---

## 3. Dostępne metody i18n w Lua (referencja)

| Metoda Lua | C++ źródło | Zastosowanie |
|------------|------------|--------------|
| `player:getTranslation(key, args)` | `PlayerFunctions::luaPlayerGetTranslation` | Zwraca przetłumaczony string wg locale gracza |
| `player:sendLocalizedTextMessage(type, key, args)` | `Player::sendLocalizedTextMessage` | Wysyła tekst do konsoli (opcode 0xB4) |
| `i18nTranslate(key, locale)` | `GlobalFunctions::luaI18nTranslate` | Globalna funkcja — zwraca tłumaczenie (bez args) |
| `player:getLocale()` | `PlayerFunctions::luaPlayerGetLocale` | Zwraca locale gracza (np. "pl") |
| `npc:say(text, TALKTYPE_PRIVATE_NP, false, player, pos)` | `Npc::luaSay` | **Prawidłowa metoda NPC mówienia** — otwiera czat NPC |
| `creature:sayLocalized(key, talktype, ...)` | `CreatureFunctions::luaCreatureSayLocalized` | I18N say z zachowaniem talktype |

## 4. Ważne wnioski

1. **NPC MUSI używać `npc:say()` z `TALKTYPE_PRIVATE_NP`** aby gracz widział okno czatu NPC
2. `sendLocalizedTextMessage` jest dobre dla wiadomości systemowych (party, trade, etc.) — NIE dla NPC dialogów
3. `player:getTranslation(key, args)` jest bridge między i18n systemem a normalnym NPC say flow
4. Błąd `"argument not found"` to `fmt::format_error` z `translator.cpp:253` — tłumaczenie ma placeholdery `{0}` ale brak argumentów (warning, nie blokuje)
