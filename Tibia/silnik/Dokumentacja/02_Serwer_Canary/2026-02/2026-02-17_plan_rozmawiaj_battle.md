# Plan: Opcja "Rozmawiaj" (Talk) w menu kontekstowym Battle

**Data:** 2026-02-17  
**Status:** PLAN (do implementacji)

## Cel
Dodanie 4. opcji "Rozmawiaj" (Talk) do menu kontekstowego pojawiającego się po kliknięciu PPM na NPC w oknie Battle. Obecnie dostępne opcje to: Atak, Podążaj, Skopiuj nazwę.

## Obecny przepływ (jak jest)
1. Gracz klika PPM na NPC w Battle window
2. `battle.lua:onBattleButtonMouseRelease()` (linia ~1016) wywołuje:
   ```lua
   modules.game_interface.createThingMenu(mousePosition, nil, nil, self.creature)
   ```
3. `gameinterface.lua:createThingMenu()` (linia 557) tworzy menu PopupMenu
4. Dla nie-gracza (NPC/potwory) dodaje opcje: Atak (Attack), Podążaj (Follow)
5. Na końcu dodaje opcję: Skopiuj nazwę (Copy name)

## Plan implementacji

### Krok 1: Modyfikacja `createThingMenu()` w `gameinterface.lua`

**Plik:** `testyy/modules/game_interface/gameinterface.lua`  
**Lokalizacja:** Po blokach Attack/Follow (linia ~728), PRZED separator + Copy name

Dodać warunek NPC i opcję "Rozmawiaj":
```lua
-- Po bloku Follow (linia ~728), dodać:
if creatureThing:isNpc() then
    menu:addOption(tr("Rozmawiaj"), function()
        -- Powiedz "hi" w lokalnym chacie - NPC usłyszy i odpowie
        g_game.talk("hi")
    end)
end
```

### Krok 2: Dodanie klucza tłumaczenia (i18n)

**Opcja A (prosta):** Bezpośrednio `tr("Rozmawiaj")` - działa z obecnym systemem tłumaczeń.

**Opcja B (formalna i18n):** Dodać klucz `"otclient_modules.gameinterface.tr_talk_npc"` do plików tłumaczeń:
- `i18n/en/otclient_modules.json`: `"otclient_modules.gameinterface.tr_talk_npc": "Talk"`
- `i18n/pl/otclient_modules.json`: `"otclient_modules.gameinterface.tr_talk_npc": "Rozmawiaj"`

### Krok 3: Testowanie

1. Uruchomić serwer + klienta
2. Podejść do NPC (np. Benjamin)
3. Otworzyć Battle window
4. Kliknąć PPM na NPC → powinno pojawić się menu z 4 opcjami:
   - Atak
   - Podążaj
   - **Rozmawiaj** (nowa)
   - Skopiuj nazwę
5. Kliknąć "Rozmawiaj" → postać powie "hi" → NPC odpowie → otworzy się zakładka NPC

## Szczegóły techniczne

### Wykrywanie NPC
- `creature:isNpc()` — dostępne w OTClient, zwraca `true` dla NPC
- Używane już w battle.lua: `creature:isNpc()` (linia 471)
- Używane w creatureinformation.lua: `creature:isNpc()` (linia 72)

### Inicjowanie rozmowy
- `g_game.talk("hi")` — wysyła wiadomość Say (lokalny chat)
- NPC słyszy grę w zasięgu `talkRange` (zazwyczaj 4 kratki)
- Serwer: `npcHandler:onSay()` → `npcHandler:greet()` → odpowiedź NPC
- Klient: NPC odpowiada via `TALKTYPE_PRIVATE_NP` → otwiera zakładkę NPC w konsoli

### Ograniczenia
- Gracz musi być w zasięgu rozmowy NPC (domyślnie 4 kratki)
- Jeśli gracz jest za daleko, NPC nie odpowie (tak samo jak pisanie "hi" ręcznie)

## Pliki do modyfikacji
1. `testyy/modules/game_interface/gameinterface.lua` — dodanie opcji menu
2. Opcjonalnie: pliki tłumaczeń `i18n/*/otclient_modules.json`

## Szacowany czas
~15 minut implementacji + testy

## Zależności
- Brak blokujących zależności
- Wymaga skopiowania zmienionego `gameinterface.lua` na klienta Windows
