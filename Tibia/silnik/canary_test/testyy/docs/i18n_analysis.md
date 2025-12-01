# Analiza plików wymagających wielojęzyczności (i18n)

## Podsumowanie

| Komponent | Pliki do modyfikacji | Trudność |
|-----------|---------------------|----------|
| Klient - pliki .otui | ~50 plików | Łatwa |
| Klient - pliki .lua | ~40 plików | Średnia |
| Serwer - pliki .cpp | ~20 plików | Trudna |
| **Razem** | **~110 plików** | |

---

## KLIENT (testyy - OTClient)

### ✅ System tłumaczeń już działa
Klient używa funkcji `tr()` do tłumaczeń. Pliki tłumaczeń znajdują się w:
- `data/locales/` - pliki `.lua` dla każdego języka

### Obecne języki:
1. ✅ Polski (pl.lua)
2. ✅ Angielski (en.lua) - domyślny
3. ✅ Niemiecki (de.lua)
4. ✅ Hiszpański (es.lua)
5. ✅ Portugalski (pt.lua)
6. ✅ Szwedzki (sv.lua)
7. ✅ Rosyjski (ru.lua) - NOWY
8. ✅ Rumuński (ro.lua) - NOWY
9. ✅ Japoński (ja.lua) - NOWY
10. ✅ Serbski (sr.lua) - NOWY
11. ✅ Koreański (ko.lua) - NOWY

### Pliki OTUI do sprawdzenia (mogą zawierać hardcoded tekst)

#### Moduły gry (game_*)
```
modules/game_battle/battle.otui
modules/game_rewardwall/styles/style.otui
modules/game_rewardwall/styles/pickreward.otui
modules/game_quickloot/quickloot.otui
modules/game_stash/game_stash.otui
modules/game_cyclopedia/tab/boss_slots/boss_slots.otui
modules/game_cyclopedia/tab/house/house.otui
modules/game_cyclopedia/tab/map/map.otui
modules/game_cyclopedia/tab/character/character.otui
modules/game_cyclopedia/tab/bestiary/bestiary.otui
modules/game_cyclopedia/tab/charms/charms.otui
modules/game_cyclopedia/tab/items/items.otui
modules/game_cyclopedia/tab/bosstiary/bosstiary.otui
modules/game_cyclopedia/game_cyclopedia.otui
modules/game_spelllist/spelllist.otui
modules/game_npctrade/npctrade.otui
modules/game_console/channelswindow.otui
modules/game_console/console.otui
modules/game_mainpanel/option_control_buttons.otui
modules/game_hotkeys/hotkeys_manager.otui
modules/game_questlog/styles/game_questlog.otui
modules/game_viplist/addgroup.otui
modules/game_viplist/viplist.otui
modules/game_viplist/addvip.otui
modules/game_viplist/editvip.otui
modules/game_ruleviolation/ruleviolation.otui
modules/game_highscore/game_highscore.otui
modules/game_actionbar/edit_hotkey.otui
modules/game_actionbar/assign_object.otui
modules/game_actionbar/assign_text.otui
modules/game_actionbar/assign_spell.otui
modules/game_interface/gameinterface.otui
modules/game_imbuing/imbuing.otui
modules/game_bugreport/bugreport.otui
modules/game_healthcircle/option_healthcircle.otui
modules/game_playertrade/tradewindow.otui
modules/game_imbuementtracker/imbuementtracker.otui
modules/game_inventory/inventory.otui
modules/game_market/market.otui
modules/game_tasks/tasks.otui
modules/game_screenshot/game_screenshot.otui
modules/game_prey/prey.otui
modules/game_textwindow/textwindow.otui
modules/game_unjustifiedpoints/unjustifiedpoints.otui
modules/game_shop/gift.otui
modules/game_shop/game_shop.otui
modules/game_playerdeath/deathwindow.otui
```

#### Moduły klienta (client_*)
```
modules/client_entergame/characterlist.otui
modules/client_entergame/waitinglist.otui
modules/client_entergame/createAccount.otui
modules/client_entergame/entergame.otui
modules/client_options/options.otui
modules/client_debug_info/debug_info.otui
modules/client_terminal/terminal.otui
modules/client_bottommenu/bottommenu.otui
modules/client_bottommenu/calendar.otui
modules/client_serverlist/serverlist.otui
modules/client_serverlist/addserver.otui
modules/client_locales/locales.otui
```

#### Moduły UI/Core
```
modules/updater/updater.otui
```

### Pliki Lua wymagające przeglądu

Pliki z potencjalnymi hardcoded tekstami (używają setText, MessageBox, itp.):

```lua
-- Core UI
modules/corelib/ui/uimessagebox.lua      -- PRIORYTET: zawiera 'Ok', 'Cancel'
modules/corelib/ui/uiinputbox.lua
modules/corelib/ui/uipopupmenu.lua
modules/corelib/ui/tooltip.lua

-- Moduły gry
modules/game_cyclopedia/*.lua            -- Dużo tekstów
modules/game_spelllist/spelllist.lua
modules/game_npctrade/npctrade.lua
modules/game_market/*.lua
modules/game_skills/skills.lua
modules/game_shop/game_shop.lua

-- Moduły klienta
modules/client_entergame/*.lua
modules/client_options/*.lua
```

---

## SERWER (Canary - C++)

### ⚠️ Wymaga dużych zmian

Serwer nie ma systemu wielojęzyczności. Wszystkie wiadomości są hardcoded w C++.

### Pliki C++ z wiadomościami do graczy (~88 wiadomości)

```cpp
src/game/game.cpp                        -- ~40 wiadomości
src/creatures/players/player.cpp         -- ~20 wiadomości
src/creatures/combat/spells.cpp          -- ~10 wiadomości
src/creatures/players/grouping/party.cpp -- kilka wiadomości
src/creatures/npcs/npc.cpp
src/map/house/house.cpp
src/io/ioprey.cpp
src/io/iobestiary.cpp
```

### Przykłady hardcoded wiadomości:

```cpp
player->sendTextMessage(MESSAGE_FAILURE, "You are feared.");
player->sendTextMessage(MESSAGE_FAILURE, "Sorry, not possible.");
player->sendTextMessage(MESSAGE_TRADE, "This item is already being traded.");
player->sendTextMessage(MESSAGE_TRADE, "You can not trade more than 100 items.");
```

### Proponowane rozwiązanie dla serwera:

1. Utworzyć plik `data/languages/` z JSON/XML dla każdego języka
2. Dodać klasę `LanguageManager` do wczytywania tłumaczeń
3. Przechowywać preferowany język gracza w bazie danych
4. Zmienić `sendTextMessage("text")` na `sendTextMessage(lang->get("message_id"))`

---

## Plan działania

### Etap 1: Klient - pliki OTUI (Łatwy)
- [ ] Zamienić `text: "..."` na `!text: tr('...')` w plikach .otui
- [ ] Dodać brakujące tłumaczenia do plików locale

### Etap 2: Klient - pliki Lua (Średni)
- [ ] Zamienić hardcoded stringi na `tr('...')`
- [ ] Szczególnie w uimessagebox.lua

### Etap 3: Serwer (Trudny)
- [ ] Zaprojektować system i18n dla serwera
- [ ] Zaimplementować LanguageManager
- [ ] Stopniowo zamieniać hardcoded wiadomości

---

## Narzędzia pomocnicze

### Skrypt do znajdowania hardcoded tekstów w OTUI:
```bash
grep -rn "text:.*[A-Z]" modules/ --include="*.otui" | grep -v "tr("
```

### Skrypt do znajdowania hardcoded tekstów w Lua:
```bash
grep -rn "'[A-Z][a-z].*'" modules/ --include="*.lua" | grep -v "tr("
```

### Skrypt do zliczania wiadomości w C++:
```bash
grep -rn "sendTextMessage.*\"" src/ --include="*.cpp" | wc -l
```
