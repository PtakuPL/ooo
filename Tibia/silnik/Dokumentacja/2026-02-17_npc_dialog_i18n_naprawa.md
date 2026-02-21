# Naprawa systemu dialogu NPC z i18n — 17.02.2026

## Kontekst prac
Po uruchomieniu serwera Canary i zalogowaniu się klientem OTClient Redemption 4.x testowaliśmy system NPC z internacjonalizacją (i18n). Znaleziono i naprawiono kilka krytycznych problemów.

## Wykonane prace

### 1. Błąd "There was a problem requesting your message"
**Problem:** Wiadomości NPC wyświetlały błąd systemowy zamiast tekstu.
**Przyczyna:** Stała `MESSAGE_NPC_FROM` używana w systemie i18n NPC nie istniała w C++ enum → `nil` → `0` = `MESSAGE_NONE` → `protocolgame.cpp:4854` zwracał błąd.
**Rozwiązanie:** Dodano `MESSAGE_NPC_FROM = MESSAGE_EVENT_ADVANCE or 19` do `data/global.lua`.

### 2. Wiadomości NPC pojawiają się na środku ekranu zamiast w oknie dialogu NPC
**Problem:** System i18n NPC używał `player:sendLocalizedTextMessage()` który wysyłał tekst jako wiadomość systemową (floating text na ekranie), zamiast przez okno dialogowe NPC.
**Przyczyna:** Funkcje `NpcHandler:sayLocalized`, `NpcHandler:tryLocalizedMessage`, `NPC_LIB.i18n.npcSay`, `NPC_LIB.i18n.npcSayMultiple` oraz `StdModule` (modules.lua) — wszystkie używały `sendLocalizedTextMessage` zamiast `npc:say(TALKTYPE_PRIVATE_NP)`.

**Rozwiązanie:** Zmieniono podejście we WSZYSTKICH funkcjach:
- `player:getTranslation(key, args)` → tłumaczy klucz po stronie serwera
- Przetłumaczony tekst przekazywany do `npc:say()` / `self:say()` / `SayEvent` z `TALKTYPE_PRIVATE_NP`

**Zmienione pliki:**
- `data/npclib/npc_system/npc_handler.lua` — `sayLocalized()`, `tryLocalizedMessage()` (+ dodany parametr `npc`)
- `data/npclib/npc_system/modules.lua` — `StdModule` z `i18nKey`
- `data-otservbr-global/lib/npc/i18n.lua` — `npcSay()`, `npcSayMultiple()`

### 3. PLAYERNAME wyświetla się dosłownie zamiast imienia gracza
**Problem:** NPC pisze "Greetings, {0}." zamiast "Greetings, Ptaku."
**Przyczyna:** Domyślne wpisy `localizedMessages` w `NpcHandler:new()` nie miały `args` z imieniem gracza. Tłumaczenia używają `{0}` jako placeholder, ale args były puste.
**Rozwiązanie:** Dodano `playerNameArgs` callback do `MESSAGE_GREET`, `MESSAGE_FAREWELL` i `MESSAGE_ALREADYFOCUSED`:
```lua
local playerNameArgs = function(player)
    if not player then return nil end
    return { player:getName() }
end
obj.localizedMessages[MESSAGE_GREET] = { key = "npclib.handler.greet", args = playerNameArgs }
```

### 4. Klikalne słowa kluczowe w oknie NPC nie działają
**Problem:** Niebieskie, klikalne słowa `{trade}`, `{sail}` itp. nie reagowały na kliknięcie.
**Przyczyna:** W `console.lua` (klient OTClient) zmienna `npcTab` w closure `label.onMouseRelease` była zawsze `nil` — lokalna z `init()` nie była widoczna w scope `addTabText`.
**Rozwiązanie:** Zmiana `sendMessage(label.highlightInfo[position], npcTab)` → `sendMessage(label.highlightInfo[position], tab)` w `testyy/modules/game_console/console.lua:1166`.

## Znalezione problemy (jeszcze do rozwiązania)

### A. Tagi językowe [EN]/[PL] w tłumaczeniach NPC
**Problem:** Wiadomości NPC pokazują `[EN]` lub `[PL]` na początku.
**Przyczyna:** Worker tłumaczeniowy (i18n_worker) wstawił tagi językowe `[EN]`/`[PL]` BEZPOŚREDNIO do plików JSON tłumaczeń. Np.: `"npc.benjamin.greet_msg_1": "[EN] Hello. How may I help you..."`. To nie jest bug kodu, ale złej jakości tłumaczenia.
**Plan naprawy:** Usunąć prefiksy `[EN]`/`[PL]` z plików tłumaczeń JSON.

### B. Tag |PLAYERNAME| w tłumaczeniach NPC-specific
**Problem:** Tłumaczenia NPC-specific (jak `npc.benjamin.greet_msg_1`) używają `|PLAYERNAME|` zamiast `{0}`. Funkcja `player:getTranslation()` nie rozpoznaje formatu `|PLAYERNAME|`.
**Przyczyna:** Oryginalny system NPC używał `|PLAYERNAME|` jako tag do zamiany w `npcHandler:parseMessage()`. Tłumaczenia NPC skopiowały ten format, ale `player:getTranslation()` (C++ `fmt::vformat`) wymaga formatu `{0}`.
**Plan naprawy:** 
- Opcja A: Zamienić `|PLAYERNAME|` → `{0}` w tłumaczeniach JSON (wymaga aktualizacji WSZYSTKICH języków)
- Opcja B: Po `player:getTranslation()` w Lua, wykonać `parseMessage()` z `TAG_PLAYERNAME` → imię gracza (bardziej kompatybilne)

### C. Mieszanie niebieskiego tekstu z normalnym (phantom label overlay)
**Problem:** Niebieskie słowa kluczowe nakładają się na normalny tekst lub są przesunięte.
**Przyczyna:** Tabela `letterWidth` w `console.lua` obsługuje tylko bajty 0-255 (Latin-1). Polskie znaki UTF-8 (ó, ż, ą, ś, ę, ć) to wielobajtowe sekwencje, co powoduje błędne obliczanie szerokości i pozycji phantom label overlay.
**Plan naprawy:** Zmienić algorytm phantom label na UTF-8 aware lub użyć innej metody pozycjonowania podświetlonych słów.

### D. Jakość tłumaczeń polskich
**Problem:** Niektóre tłumaczenia są garbled/niezrozumiałe, np. "Robić by poszukiwać jeden prze cię do Carlin dla 1" (Captain Bluebear).
**Przyczyna:** Automatyczne tłumaczenia maszynowe bez korekty.
**Plan naprawy:** Ręczna korekta tłumaczeń dla kluczowych NPC lub poprawa promptów workera tłumaczeniowego.

## Środowisko testowe
- Serwer: `/home/ptaku/serweryt/Tibia/silnik/canary_test/canary` — porty 7171/7172, IP 172.29.76.234
- Klient: OTClient Redemption 4.x na Windows, wersja 1412
- Baza danych: MariaDB, canaryaac
- Login: HTTP via port 80, email+hasło
