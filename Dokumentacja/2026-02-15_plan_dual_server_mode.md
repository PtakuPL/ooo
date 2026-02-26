# Plan: Dual Server System — Serwery "Imitacja 7.4" + Serwery aktualne

## Cel
Rozbudowa istniejącego systemu `Servers_init` w OTClient o:
- **Kategorie serwerów** — każdy serwer ma swoją kategorię (np. `"current"`, `"retro74"`)
- **Wiele serwerów per kategoria** — np. 3 serwery aktualne + 2 serwery "imitacja 7.4"
- **Jeden protokół (1420) dla wszystkich** — różnica w bazie danych i zasadach gry po stronie serwera
- **Ograniczenia klienta per kategoria** — np. blokada hotkeys na runy dla kategorii `"retro74"`
- **Istniejący przycisk "Server List"** wyświetla listę serwerów po kliknięciu

## Kluczowe założenia

1. **Wszystko na protokole 1420** — imitacja 7.4 to ten sam silnik Canary, tylko inna konfiguracja serwera (inna baza, inne exhausty, SD od 15 lvl zamiast 60, itp.)
2. **Wiele serwerów** — np. `"Retro PvP"`, `"Retro Non-PvP"` (oba retro74) + `"Aldora"`, `"Bellona"`, `"Celesta"` (aktualne)
3. **Klient stosuje ograniczenia** na podstawie kategorii wybranego serwera (ale serwer RÓWNIEŻ musi je egzekwować)
4. **Istniejący UI** — przycisk `serverListButton` otwiera okno `ServerList` z listą

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

## Przyszłe rozszerzenia (poza obecnym zakresem)

1. **Blokada auto-aim** — action `USEONTARGET` wymaga ręcznego kliknięcia
2. **Inny skin/interface** dla retro — retro UI
3. **Ograniczenie okien** — np. brak Battle List w retro
4. **Filtrowanie listy serwerów** — ComboBox z kategorią nad listą serwerów: "Wszystkie" / "Aktualne" / "Retro 7.4"
5. **Serwer wysyła kategorię** — zamiast klient→serwer, serwer informuje klienta o swoich ograniczeniach po połączeniu (ExtendedOpcode)

---

## Pliki do modyfikacji (podsumowanie)

| Plik | Zmiana |
|------|--------|
| `init.lua` | `Servers_init` + `displayName`/`category`, `ServerCategories`, helpery |
| `serverlist.lua` | Wyświetlanie `displayName`, ustawianie `activeServerCategory` przy select |
| `serverlist.otui` | Opcjonalnie: Label na kategorię w widgecie serwera |
| `entergame.lua` | `doLogin()`/`setDefaultServer()` → ustawianie kategorii, wyświetlanie info |
| `hotkeys_manager.lua` | Blokada `startChooseItem()`, `onChooseItemMouseRelease()`, `executeHotkeyItem()`, `updateHotkeyForm()` — ALL item hotkeys |

---

## Szacowany czas implementacji

| Etap | Opis | Złożoność |
|------|------|-----------|
| 1 | Konfiguracja `Servers_init` + `ServerCategories` + helpery | Łatwe (~15 min) |
| 2 | Rozbudowa ServerList — displayName + category | Średnie (~40 min) |
| 3 | Ustawianie kategorii przy logowaniu i wyborze serwera | Łatwe (~20 min) |
| 4 | Blokada WSZYSTKICH item hotkeys (3 punkty + UI) | Średnie (~30 min) |
| 5 | Inicjalizacja kategorii przy starcie | Łatwe (~10 min) |
| 6 | Info dla użytkownika (label, komunikat) | Łatwe (~15 min) |
| **RAZEM** | | **~2-2.5h** |

---

## Uwagi

- **Protokół zawsze 1420** — imitacja 7.4 to ten sam silnik Canary z inną konfiguracją serwerową (baza, skrypty, exhausty, limity lvl na runy itp.)
- **Wsteczna kompatybilność** — jeśli serwer nie ma `category`, domyślnie `"current"` (brak ograniczeń)
- **Serwer MUSI egzekwować ograniczenia** — klient to tylko pierwsza linia obrony. Serwer Canary powinien RÓWNIEŻ blokować hotkey-use na runy w trybie retro74, bo klient można modyfikować
- **Nie wymaga rekompilacji** — wszystkie zmiany to pliki Lua ładowane w runtime. Wystarczy podmienić pliki i zrestartować klienta
- **Blokada ALL items, nie tylko run** — prostsze, pewniejsze, i zgodne z duchem retro 7.4 (tam nie było item hotkeys w ogóle)
- **Jeden klient, wiele serwerów** — użytkownik klika przycisk "Server List", widzi wszystkie serwery pogrupowane wg kategorii, wybiera i loguje się





Masz 100% racji — to ważna obserwacja. Pliki Lua to zwykły tekst, każdy gracz może otworzyć hotkeys_manager.lua i usunąć blokadę w 10 sekund.

Opcje rozwiązania:

Podejście	Bezpieczeństwo	Wymaga rekompilacji?
1. Tylko Lua — obecny plan	Żadne. Każdy edytuje plik i obejdzie	Nie
2. C++ w kliencie — flaga w skompilowanym kodzie	Trudne do obejścia (reverse engineering)	Tak
3. Serwer egzekwuje — serwer Canary blokuje po swojej stronie	Pełne — klient nie ma znaczenia	Nie (klient), ale wymaga zmian na serwerze
Problem z opcją 3: Serwer nie jest w stanie odróżnić "gracz kliknął item ręcznie" od "gracz użył hotkeya" — oba wysyłają ten sam pakiet (UseItem, UseItemWith). Więc serwer nie może zablokować konkretnie hotkeys na itemy.

Realistyczne podejścia:

A) Hybryda: C++ w kliencie + serwer

Klient (C++): po połączeniu serwer wysyła flagę przez ExtendedOpcode → klient kompilowany blokuje item hotkeys
Serwer: egzekwuje inne ograniczenia retro (exhausty, lvl na runy, cooldowny) — to SĄ rozróżnialne
Wymaga: rekompilacji instalki + zmian na serwerze
B) Akceptacja "soft" blokady (Lua)

Blokada w Lua działa dla uczciwych graczy / standardowej instalki
Kto chce oszukać — i tak może użyć zmodyfikowanego klienta (OTClient jest open source, to dotyczy KAŻDEGO OTS-a)
Serwer egzekwuje to co MOŻE egzekwować (exhausty, cooldowny, lvl requirements)
De facto tak działają wszystkie OTS-y — klient to tylko UI
Moja rekomendacja: Podejście B (Lua + serwer-side exhausty/rules) jest pragmatyczne. Jeśli ktoś modyfikuje klienta żeby mieć item hotkeys na retro serwerze — serwer i tak wymusza exhausty i inne ograniczenia 7.4. Hotkey na SD nie da przewagi jeśli serwer wymusza 2s exhaust na runy i SD dopiero od 45 lvl.

Ale jeśli chcesz twardą blokadę not-bypassable w kliencie — to tak, wymaga rekompilacji (zmiany w C++).

Co wybierasz?