# i18n: Naprawa krytycznych bugów Lua + brakujące klucze JSON

**Data:** 2026-02-12  
**Branch:** `feature/i18n-multilanguage`  
**Commit:** `03e7935fc`

---

## Podsumowanie

Sesja odkryła i naprawiła **krytyczny bug runtime** — 619 wywołań funkcji Lua (`sendLocalizedMessage` i `sendLocalizedCancelMessage`) które nie były zarejestrowane w C++ i spowodowałyby błędy "attempt to call a nil value" podczas gry. Dodatkowo dodano 3,093 brakujących kluczy JSON i naprawiono 4 anty-wzorce konkatenacji.

---

## 1. Krytyczny bug: niezarejestrowane funkcje Lua

### Problem
W C++ (`src/lua/functions/creatures/player/player_functions.cpp:218`) zarejestrowana jest **tylko** metoda `player:sendLocalizedTextMessage(type, key, args)`.

Tymczasem w skryptach quest (data-otservbr-global/scripts/) używane są:
- `player:sendLocalizedMessage(type, key, args)` — **549 wywołań**
- `player:sendLocalizedCancelMessage(key, args)` — **70 wywołań**

Żadna z tych funkcji nie istniała — ani w C++, ani jako alias Lua.

### Rozwiązanie
Dodano aliasy w `data/libs/i18n_wrappers.lua`:

```lua
function Player:sendLocalizedMessage(messageType, key, args)
    return self:sendLocalizedTextMessage(messageType, key, args or {})
end

function Player:sendLocalizedCancelMessage(key, args)
    return self:sendLocalizedTextMessage(MESSAGE_FAILURE, key, args or {})
end
```

Plik wczytywany jest przez `data/libs/libs.lua` (linia 23) przed skryptami questów.

---

## 2. Brakujące klucze JSON (EN)

### scripts.json: +512 kluczy
- 460 kluczy wyekstrahowanych z oryginalnego źródła canary (porównanie linia-po-linii z niezmodyfikowanym repozytorium)
- 52 klucze `player.*` (player.dawnport.*, player.login.*, player.rookgaard.*)

### quests.json: +104 klucze
- 98 kluczy `quests.*` z oryginalnego canary player.json
- 5 kluczy `quests.soul_war.msg_1` do `msg_5` (wiadomości Dread)
- 1 klucz `quests.svargrond_arena.msg_1` (timeout areny)

### server.json: +2,477 kluczy
- 2,441 kluczy z oryginalnego canary system.json
- 36 kluczy z oryginalnego canary game.json

### Łącznie: +3,093 kluczy EN

---

## 3. Naprawione anty-wzorce konkatenacji (4 pliki)

Problem: `sendLocalizedMessage(TYPE, "key" .. zmienna .. ".")` — produkuje nieprawidłowy klucz.

Poprawka: `sendLocalizedMessage(TYPE, "key", { zmienna })` z `{0}` w wartości JSON.

| Plik | Przed | Po |
|------|-------|-----|
| `action-reward_soul_war.lua:22` | `"key" .. name .. "."` | `"key", { name }` |
| `actions_sunFruit.lua:21` | `"key" .. getName() .. "s."` | `"key", { getName() }` |
| `movements_acessTeleports.lua:111` | `"key" .. bossName .. " again!"` | `"key", { bossName }` |
| `actions_containerRewards.lua:125` | `"key" .. getName() .. "."` | `"key", { getName() }` |

---

## 4. Synchronizacja do 54 lokalizacji

- 168,048 wpisów klucz-lokalizacja zsynchronizowano (EN fallback)
- Zweryfikowano: scripts.json, quests.json, server.json, libs.json — identyczne klucze we wszystkich 55 lokalizacjach

---

## 5. Statystyki końcowe

| Metryka | Wartość |
|---------|---------|
| Łączna liczba kluczy i18n | 50,201 |
| Brakujące klucze sendLocalizedMessage | 0 |
| Brakujące klucze sendLocalizedTextMessage | 0 |
| Brakujące klucze sendLocalizedCancelMessage | 0 |
| Zmodyfikowane pliki | 244 |
| Wstawienia | 179,571 linii |
| Usunięcia | 4,194 linii |

---

## 6. Znane problemy (pre-istniejące, nie z tej sesji)

- `monsters.json` — 32 lokalizacji ma 10,013 kluczy vs EN 5,915 (nadmiarowe klucze)
- `mounts.json`, `otclient_mods.json`, `otclient_src.json`, `otclient_tools.json`, `world.json` — puste pliki EN, brak w lokalizacjach
- `errors.json`, `ui.json` — brak w 2 lokalizacjach (reports, status)

---

## 7. Następne kroki

1. **Priorytet 2:** Weryfikacja OTC client — czy czyta `otclient_modules.json` (1,987 kluczy)
2. **Priorytet 3:** items.xml names — `Item::getName()` z locale
3. **Priorytet 4:** Tłumaczenia (osobny projekt)
4. Porządki: `monsters.json` nadmiarowe klucze w 32 lokalizacjach
