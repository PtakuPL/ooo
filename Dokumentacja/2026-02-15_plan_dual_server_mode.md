# Dual Server System — Serwery "Imitacja 7.4" + Serwery aktualne

> **Gałąź implementacji:** `serwer-7.4` (bazuje na `feature/i18n-multilanguage`)
> **Status:** Etapy 1–4 ✅ ZAIMPLEMENTOWANE | Etapy 5–6 wchłonięte w 1–4
> **Ostatnia aktualizacja:** 2026-02-15

---

## Cel
Rozbudowa istniejącego systemu `Servers_init` w OTClient o:
- **Kategorie serwerów** — każdy serwer ma swoją kategorię (np. `"current"`, `"retro74"`)
- **Wiele serwerów per kategoria** — np. 3 serwery aktualne + 2 serwery "imitacja 7.4"
- **Jeden protokół (1420) dla wszystkich** — różnica w bazie danych i zasadach gry po stronie serwera
- **Ograniczenia klienta per kategoria** — blokada WSZYSTKICH item hotkeys dla `"retro74"`
- **Twarda blokada w C++** — flaga `m_blockItemHotkeys` w skompilowanym kodzie (nie da się obejść edycją Lua)
- **Istniejący przycisk "Server List"** wyświetla listę serwerów po kliknięciu

## Kluczowe założenia

1. **Wszystko na protokole 1420** — imitacja 7.4 to ten sam silnik Canary, tylko inna konfiguracja serwera (inna baza, inne exhausty, SD od 15 lvl zamiast 60, itp.)
2. **Wiele serwerów** — np. `"Retro PvP"`, `"Retro Non-PvP"` (oba retro74) + `"Aldora"`, `"Bellona"`, `"Celesta"` (aktualne)
3. **Klient stosuje ograniczenia** na podstawie kategorii wybranego serwera (ale serwer RÓWNIEŻ musi je egzekwować)
4. **Istniejący UI** — przycisk `serverListButton` otwiera okno `ServerList` z listą
5. **Wymaga rekompilacji instalki** — zmiany w C++ (`game.h`, `luafunctions.cpp`) wymagają przebudowy klienta

---

## Architektura

### Rozbudowa `Servers_init` w `init.lua`

Dodanie pola `category` i `displayName` do każdego serwera:

```lua
Servers_init = {
    -- === Serwery aktualne (current) ===
    ["http://aldora.example.com/login.php"] = {
        displayName = "Aldora",
        category = "current",       -- kategoria: brak ograniczeń
        port = 80,
        protocol = 1420,
        httpLogin = true,
    },
    ["http://bellona.example.com/login.php"] = {
        displayName = "Bellona",
        category = "current",
        port = 80,
        protocol = 1420,
        httpLogin = true,
    },
    ["http://celesta.example.com/login.php"] = {
        displayName = "Celesta",
        category = "current",
        port = 80,
        protocol = 1420,
        httpLogin = true,
    },

    -- === Serwery retro 7.4 (retro74) ===
    ["http://retro-pvp.example.com/login.php"] = {
        displayName = "Retro PvP",
        category = "retro74",       -- kategoria: ograniczenia old-school
        port = 80,
        protocol = 1420,
        httpLogin = true,
    },
    ["http://retro-nonpvp.example.com/login.php"] = {
        displayName = "Retro Non-PvP",
        category = "retro74",
        port = 80,
        protocol = 1420,
        httpLogin = true,
    },
}
```

### Nowa tabela: `ServerCategories` (definicja ograniczeń per kategoria)

```lua
ServerCategories = {
    ["current"] = {
        label = "Serwery aktualne",
        restrictions = {},           -- brak ograniczeń
    },
    ["retro74"] = {
        label = "Serwery Retro 7.4",
        restrictions = {
            blockItemHotkeys = true,   -- blokada WSZYSTKICH przedmiotów na hotkeyach
            -- blockAutoAim = true,    -- przyszłe blokady...
        },
    },
}
```

### Globalne helpery (w `init.lua`)

```lua
-- Wywoływane po wybraniu serwera z listy
_G.activeServerCategory = nil      -- "current" / "retro74" / nil

function _G.isRestricted(restrictionName)
    if not _G.activeServerCategory then return false end
    local cat = ServerCategories and ServerCategories[_G.activeServerCategory]
    if not cat or not cat.restrictions then return false end
    return cat.restrictions[restrictionName] == true
end

function _G.getActiveCategory()
    return _G.activeServerCategory
end
```

---

## Etapy implementacji

### Etap 1: Konfiguracja — `init.lua`
**Zmiany:**
- Odkomentowanie / uzupełnienie `Servers_init` — dodanie pól `displayName` i `category`
- Dodanie tabeli `ServerCategories` z definicją ograniczeń
- Dodanie globalnych helperów: `_G.activeServerCategory`, `_G.isRestricted(name)`

### Etap 2: Rozbudowa ServerList — wyświetlanie nazw serwerów
**Pliki:** `modules/client_serverlist/serverlist.lua`, `serverlist.otui`

Aktualnie `ServerList` wyświetla `host:port (protocol)`. Po zmianach:

- **Widget** wyświetla `displayName` zamiast `host:port`
  - Np. `"Retro PvP"` zamiast `"http://retro-pvp.example.com/login.php:80"`
  - Pod spodem lub obok — kategoria: `"[Retro 7.4]"` / `"[Aktualny]"`

- `ServerList.add()` — nowy parametr `displayName`, `category`
- `ServerList.select()` — po wybraniu serwera ustawia `_G.activeServerCategory`
  ```lua
  function ServerList.select()
      local selected = ...
      local server = servers[selected:getId()]
      if server then
          _G.activeServerCategory = server.category or "current"
          EnterGame.setDefaultServer(...)
          ...
      end
  end
  ```

- Opcjonalnie: **grupowanie** serwerów w liście wg kategorii (nagłówki "Aktualne" / "Retro 7.4")

### Etap 3: Automatyczne ustawianie kategorii przy logowaniu
**Pliki:** `modules/client_entergame/entergame.lua`

- W `EnterGame.doLogin()` — po odczycie host/port, sprawdzenie kategorii:
  ```lua
  -- Znajdź kategorię wybranego serwera
  if Servers_init and Servers_init[G.host] then
      _G.activeServerCategory = Servers_init[G.host].category or "current"
  end
  ```

- W `EnterGame.setDefaultServer()` — ustawianie kategorii:
  ```lua
  function EnterGame.setDefaultServer(host, port, protocol)
      -- istniejący kod...
      -- NOWE: ustaw kategorię
      if Servers_init and Servers_init[host] then
          _G.activeServerCategory = Servers_init[host].category or "current"
      end
  end
  ```

- `serverInfoLabel` — wyświetlanie nazwy serwera i kategorii pod przyciskiemLogin:
  ```lua
  EnterGame.setServerInfo("Serwer: Retro PvP [Retro 7.4]")
  ```

### Etap 4: Blokada WSZYSTKICH przedmiotów na hotkeyach (retro74)
**Pliki:** `modules/game_hotkeys/hotkeys_manager.lua`

**Ważne:** Blokada dotyczy WSZYSTKICH przedmiotów, nie tylko run. Czary (tekst wpisywany
przez hotkey) i akcje pozostają dozwolone. Nie wymaga rekompilacji instalki — to czyste Lua.

System hotkeys ma 3 typy:
- **Tekst/czary** — hotkey wysyła tekst (`value` + `autoSend`) → DOZWOLONE
- **Przedmioty** — hotkey używa itemu (`itemId` + `useType`) → ZABLOKOWANE w retro74
- **Akcje** — hotkey wykonuje akcję (`action`) → DOZWOLONE

Blokada w **3 miejscach** (defense in depth):

#### 4a. Blokada przypisywania itemów — `startChooseItem()`
```lua
function startChooseItem()
    -- NOWE: Blokada przypisywania przedmiotów na retro74
    if _G.isRestricted('blockItemHotkeys') then
        modules.game_textmessage.displayFailureMessage(
            tr("Hotkey na przedmioty jest niedostępny na tym serwerze.")
        )
        return
    end

    if g_ui.isMouseGrabbed() then
        return
    end
    mouseGrabberWidget:grabMouse()
    g_mouse.pushCursor('target')
    hide()
end
```

#### 4b. Safety net — `onChooseItemMouseRelease()`
```lua
function onChooseItemMouseRelease(self, mousePosition, mouseButton)
    -- ...istniejący kod do znalezienia itemu...

    if item and currentHotkeyLabel then
        -- NOWE: Bezpiecznik — gdyby użytkownik obejdzie startChooseItem()
        if _G.isRestricted('blockItemHotkeys') then
            show()
            g_mouse.popCursor('target')
            self:ungrabMouse()
            return true
        end

        currentHotkeyLabel.itemId = item:getId()
        -- ...reszta kodu...
    end
    -- ...
end
```

#### 4c. Blokada wykonania — `executeHotkeyItem()`
```lua
function executeHotkeyItem(action, itemId, subType)
    -- NOWE: Blokada WSZYSTKICH item hotkeys na retro74
    if _G.isRestricted('blockItemHotkeys') then
        modules.game_textmessage.displayFailureMessage(
            tr("Użycie przedmiotów przez hotkey jest zablokowane na tym serwerze.")
        )
        return
    end

    -- reszta oryginalnego kodu (USE/USEONSELF/USEONTARGET/USEWITH)...
end
```

#### 4d. Ukrycie/zablokowanie przycisku "Select Object" w UI
```lua
-- W updateHotkeyForm() — zablokowanie przycisku "Select Object" gdy retro74
if _G.isRestricted('blockItemHotkeys') then
    selectObjectButton:disable()
    selectObjectButton:setTooltip(
        tr("Hotkey na przedmioty jest niedostępny na tym serwerze.")
    )
end
```

### Etap 5: Inicjalizacja kategorii przy starcie klienta
**Pliki:** `modules/client_entergame/entergame.lua`

W `EnterGame.init()`:
```lua
-- Odczytaj ostatnio wybrany serwer i ustaw jego kategorię
local savedHost = g_settings.get('host')
if savedHost and Servers_init and Servers_init[savedHost] then
    _G.activeServerCategory = Servers_init[savedHost].category or "current"
end
```

### Etap 6: Informacja dla użytkownika o ograniczeniach
**Pliki:** `entergame.lua` lub nowy moduł

Gdy użytkownik wybierze serwer retro74:
- `serverInfoLabel` pokazuje kategorię: `"[Retro 7.4]"` w kolorze np. złotym
- Opcjonalnie: krótki tooltip/komunikat o ograniczeniach po najechaniu

Gdy użytkownik jest w grze (po zalogowaniu):
- Komunikat w chacie systemowym: "Grasz na serwerze Retro 7.4. Hotkey na runy jest zablokowany."

---

## Zmodyfikowane pliki (faktyczna implementacja)

| Plik | Zmiana | Typ |
|------|--------|-----|
| `testyy/init.lua` | `ServerCategories`, `_G.isRestricted()`, `_G.getActiveCategoryLabel()`, `_G.setServerCategoryFromHost()` | Lua |
| `testyy/modules/client_serverlist/serverlist.lua` | `displayName` w liście, kategoria zamiast protokołu, ustawianie `activeServerCategory` | Lua |
| `testyy/modules/client_entergame/entergame.lua` | `doLogin()` + `setDefaultServer()` + `init()` → kategoria + C++ flaga | Lua |
| `testyy/modules/game_hotkeys/hotkeys_manager.lua` | 3-punktowa blokada item hotkeys + UI disable | Lua |
| `testyy/src/client/game.h` | `bool m_blockItemHotkeys{false}` + getter/setter | **C++** |
| `testyy/src/client/luafunctions.cpp` | Bindingi Lua: `setBlockItemHotkeys()`, `isBlockItemHotkeys()` | **C++** |

---

## Status implementacji

| Etap | Opis | Status |
|------|------|--------|
| 1 | Konfiguracja `ServerCategories` + helpery w `init.lua` | ✅ DONE |
| 2 | Rozbudowa ServerList — displayName + category label | ✅ DONE |
| 3 | Ustawianie kategorii przy logowaniu, wyborze serwera i starcie | ✅ DONE (wchłonął etap 5) |
| 4 | Blokada WSZYSTKICH item hotkeys (3 punkty + UI + C++ flaga) | ✅ DONE (wchłonął etap 6) |
| 5 | Inicjalizacja kategorii przy starcie | ✅ Wchłonięty w etap 3 |
| 6 | Info dla użytkownika (label, komunikat) | ✅ Wchłonięty w etap 4 |

### Co jeszcze trzeba zrobić

- [ ] Odkomentować `Servers_init` z prawdziwymi adresami serwerów (gdy będą gotowe)
- [ ] Always-online: klient działa TYLKO gdy serwer jest online (wymaga VPS/dedyk)
- [ ] Serwer egzekwuje ograniczenia po swojej stronie (exhausty, lvl na runy, cooldowny)
- [ ] Ewentualne ExtendedOpcode: serwer wysyła flagę kategorii do klienta po połączeniu

---

## Uwagi

- **Protokół zawsze 1420** — imitacja 7.4 to ten sam silnik Canary z inną konfiguracją serwerową (baza, skrypty, exhausty, limity lvl na runy itp.)
- **Wsteczna kompatybilność** — jeśli serwer nie ma `category`, domyślnie `"current"` (brak ograniczeń)
- **Serwer MUSI egzekwować ograniczenia** — klient to tylko pierwsza linia obrony; serwer Canary powinien RÓWNIEŻ blokować hotkey-use na runy w trybie retro74
- **WYMAGA rekompilacji** — zmiany w C++ (`game.h`, `luafunctions.cpp`) oznaczają że nowy build instalki jest konieczny. Zmiany Lua ładowane w runtime, ale C++ flaga jest skompilowana
- **Blokada ALL items, nie tylko run** — prostsze, pewniejsze, zgodne z duchem retro 7.4 (tam nie było item hotkeys w ogóle)
- **Jeden klient, wiele serwerów** — użytkownik klika "Server List", widzi serwery z etykietą kategorii, wybiera i loguje się
- **Dwuwarstwowa blokada** — Lua sprawdza `_G.isRestricted()` + C++ sprawdza `g_game.isBlockItemHotkeys()` → nawet jeśli ktoś edytuje Lua, C++ flaga nadal blokuje

---

## DECYZJA: Always-online + pełne zabezpieczenie

**Problem:** Pliki Lua to zwykły tekst — gracz może usunąć blokadę edytując hotkeys_manager.lua.

**Rozwiązanie (3 warstwy):**
1. **Lua** — `_G.isRestricted('blockItemHotkeys')` — blokada dla normalnych graczy ✅ DONE
2. **C++** — `g_game.isBlockItemHotkeys()` — twarda flaga w skompilowanym kodzie, trudna do obejścia (reverse engineering) ✅ DONE
3. **Always-online** — klient działa TYLKO gdy serwer jest online; serwer weryfikuje klienta ⏳ ODŁOŻONE (wymaga VPS/dedyk)

**Uzasadnienie odłożenia always-online:** Wymaga stabilnego serwera 24/7 (VPS lub dedyk). Bez tego klient nie uruchomi się offline. Wdrożenie gdy infrastruktura będzie gotowa.

---

## Praca na dwóch gałęziach

| Gałąź | Przeznaczenie |
|-------|---------------|
| `feature/i18n-multilanguage` | Główna gałąź — build Windows (CI), poprawki MSVC ICE, system lokalizacji |
| `serwer-7.4` | Dual server system — zmiany Lua + C++ opisane w tym dokumencie |

Zmiany w `serwer-7.4` bazują na `feature/i18n-multilanguage`. Gdy build Windows na i18n przejdzie CI, merge `serwer-7.4` ← `i18n` i przebudowa.

---

## Przyszłe rozszerzenia (poza obecnym zakresem)

1. **Blokada auto-aim** — action `USEONTARGET` wymaga ręcznego kliknięcia
2. **Inny skin/interface** dla retro — retro UI
3. **Ograniczenie okien** — np. brak Battle List w retro
4. **Filtrowanie listy serwerów** — ComboBox z kategorią nad listą serwerów
5. **Serwer wysyła kategorię** — ExtendedOpcode po połączeniu informuje klienta o ograniczeniach