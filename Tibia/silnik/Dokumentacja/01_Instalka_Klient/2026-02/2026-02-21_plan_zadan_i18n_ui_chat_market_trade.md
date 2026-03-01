# Plan zadań: i18n, chat, market/trade, skróty UI
**Data**: 2026-02-21  
**Status**: Plan roboczy do realizacji (P0/P1/P2)  
**Zakres**: OTClient + Canary (sync języków, input Unicode, UI klienta)

---

## 1. Zgłoszone problemy (z sesji testowej)
1. Przycisk `Czatuj dalej` jest ucięty i powinien rozszerzać się w lewo.
2. Nie można wpisywać polskich znaków (`ć`, `ł` itd.) w chacie; prawdopodobnie to samo dotyczy cyrylicy.
3. Po zmianie języka (np. PL -> ES) część tekstów nie zmienia się (np. nazwy stworów).
4. Po restarcie klienta i ponownym połączeniu część komunikatów systemowych pozostaje po hiszpańsku.
5. Potrzebna odpowiedź architektoniczna: czy UI market/trade jest po stronie serwera czy klienta.
6. Potrzebna odpowiedź architektoniczna: czy w prawym panelu skrótów można dodać nowe opcje (np. Areny) z serwera.
7. Potrzebna ocena wykonalności: NPC imitujący normalnego gracza do testów (areny/systemy).
8. Ryzyko ogólne: auto-dopasowanie pól tekstowych/przycisków do długości tłumaczeń jest niepełne i pomija część ekranów.

---

## 2. Odpowiedzi architektoniczne (krótkie)
1. **Wymiary przycisków/UI**: głównie po stronie klienta (OTUI/Lua/C++ UI), nie serwera.
2. **Trade/market UI**: okna są budowane po stronie klienta; serwer dostarcza dane pakietami/opcode.
3. **Prawy panel skrótów**: konfiguracja i dodawanie przycisków są po stronie klienta.
4. **Nowe UI “tylko z serwera”**: bez wsparcia w kliencie serwer nie utworzy dowolnego nowego okna; serwer może tylko wysłać dane/zdarzenie, które klient musi obsłużyć.

---

## 3. Potwierdzenia w kodzie (referencje)
1. Ucięty przycisk czatu: stały rozmiar `size: 64 18` w `canary_test/testyy/modules/game_console/console.otui:351`.
2. Pole tekstowe chatu jest zakotwiczone do `toggleChat.left`, więc zbyt mały przycisk zjada miejsce inputa: `canary_test/testyy/modules/game_console/console.otui:336`.
3. Polskie tłumaczenia mają dłuższe teksty (`Czatuj dalej`, `Czat wyłączony`) w `canary_test/i18n/pl/otclient_modules.json:555` i `canary_test/i18n/pl/otclient_modules.json:556`.
4. Windows input filtruje `WM_CHAR` do zakresu `32..255`, co odcina Unicode >255: `canary_test/testyy/src/framework/platform/win32window.cpp:624`.
5. Synchronizacja locale z klienta: `sendExtendedOpcode` + `onGameStart` w `canary_test/testyy/modules/client_locales/locales.lua:11` i `canary_test/testyy/modules/client_locales/locales.lua:60`.
6. Serwer odbiera locale w extended opcode: `canary_test/src/server/network/protocol/protocolgame.cpp:9161`.
7. Locale gracza jest ładowane/zapisywane do DB: `canary_test/src/io/functions/iologindata_load_player.cpp:143` i `canary_test/src/io/functions/iologindata_save_player.cpp:227`.
8. UI trade/market po stronie klienta:
   - `canary_test/testyy/modules/game_playertrade/playertrade.lua:3`
   - `canary_test/testyy/modules/game_npctrade/npctrade.lua:43`
   - `canary_test/testyy/modules/game_market/market.lua:1097`
9. Serwer wysyła dane market/trade (warstwa protokołu):
   - `canary_test/src/server/network/protocol/protocolgame.cpp:5515`
   - `canary_test/src/server/network/protocol/protocolgame.cpp:5614`
   - `canary_test/src/server/network/protocol/protocolgame.cpp:6289`
   - `canary_test/src/server/network/protocol/protocolgame.cpp:6680`
10. Prawy panel skrótów i API przycisków w kliencie:
   - `canary_test/testyy/modules/client_topmenu/topmenu.lua:461`
   - `canary_test/testyy/modules/game_mainpanel/mainpanel.lua:235`
11. NPC w silniku nie jest bytem bojowym jak gracz/monster (np. `isAttackable() == false`):
   - `canary_test/src/creatures/npcs/npc.cpp:138`
   - porównawczo system walki potworów: `canary_test/src/creatures/monsters/monster.hpp:109`

---

## 4. Backlog naprawczy

## P0 (blokery UX i i18n)
1. **Unicode input na Windows (chat, formularze)**
   - Zakres: usunąć ograniczenie `WM_CHAR` do `<=255`, poprawnie obsłużyć znaki spoza Latin-1.
   - Dodatkowo: testy ręczne dla PL (`ąćęłńóśźż`) i RU (cyrylica).
   - Kryterium akceptacji: znaki zapisują się i wysyłają poprawnie w chat/nick/inputach.

2. **Rozciąganie przycisku `toggleChat` i ochrona pola input**
   - Zakres: usunąć stały sztywny layout dla tłumaczeń, dodać auto-resize/min-width i poprawne anchory.
   - Kryterium akceptacji: brak ucinania tekstu dla PL/ES/RU przy standardowej szerokości okna.

## P1 (spójność języka i treści)
1. **Spójność locale po zmianie języka i po restarcie klienta**
   - Zakres: prześledzić kolejność: `setLocale` klienta -> wysyłka opcode -> DB load/save -> pierwsze wiadomości systemowe.
   - Dodać logi diagnostyczne locale przy loginie i przy wysyłce kluczowych komunikatów systemowych.
   - Kryterium akceptacji: po restarcie wszystkie komunikaty systemowe są w aktualnym locale gracza.

2. **Niepełne tłumaczenia nazw stworów/itemów i fallbacki**
   - Zakres: audyt brakujących kluczy i fallbacków w ścieżkach tłumaczenia nazw creature/item.
   - Kryterium akceptacji: po zmianie locale nazwy istotnych encji zmieniają się spójnie (lub mają jawny, kontrolowany fallback).

3. **Opis w sklepie/markecie (tokens typu `storeinbox`, `vocationlevelcheck`)**
   - Zakres: przejrzeć mapowanie opisu oferty i źródła danych opisu, wyeliminować surowe tokeny techniczne w UI.
   - Kryterium akceptacji: panel opisu pokazuje tekst użytkowy, bez artefaktów technicznych.

## P2 (rozszerzenia funkcjonalne)
1. **Przycisk „Areny” w prawym panelu skrótów**
   - Wniosek: implementacja po stronie klienta (moduł + rejestracja przycisku), serwer może jedynie sterować danymi/akcją.
   - Zadanie: dodać moduł i kontrakt opcode/packet dla otwierania/stanu aren.

2. **Model „server-driven UI” (kontrolowane okna od serwera)**
   - Zakres: zaprojektować bezpieczny kontrakt danych (typ okna, payload, akcje), ale render nadal po stronie klienta.
   - Cel: raporty, areny, panele sezonowe bez każdorazowego przepisywania logiki serwera.

3. **„NPC imitujący gracza” do testów**
   - Opcja rekomendowana: testowy byt oparty o potwora/sztuczną logikę zamiast klasycznego NPC handlowego.
   - Alternatywa: headless test-client/bot logujący się jak zwykły gracz.
   - Kryterium decyzji: koszt utrzymania, realizm PvP/PvE, pokrycie scenariuszy arenowych.

---

## 5. Plan realizacji (kolejność)
1. P0.1 Unicode input Windows.
2. P0.2 Chat button auto-resize.
3. P1.1 Diagnostyka i naprawa kolejności locale przy login/restart.
4. P1.2 Audyt braków tłumaczeń creature/item/system.
5. P1.3 Naprawa opisów sklepu/marketu.
6. P2.1 Przycisk Areny + kontrakt serwer-klient.
7. P2.2 Decyzja i prototyp „gracza testowego”.

---

## 6. Checklista testowa (DoD)
1. Windows: wpisywanie `zażółć gęślą jaźń` i przykładowej linii cyrylicą działa w chacie.
2. Przycisk `Czatuj dalej` nie jest ucięty na PL/ES/RU.
3. Po zmianie PL <-> ES i relogu teksty systemowe są spójne z bieżącym locale.
4. Nazwy stworów/itemów w kluczowych modułach (battle, tooltip, market/trade) są przetłumaczone lub mają kontrolowany fallback.
5. Opisy sklepu nie zawierają surowych tokenów technicznych.
6. Prototyp przycisku „Areny” działa i jest widoczny w prawym panelu skrótów.

---

## 7. Uwagi końcowe
1. Obecny zestaw błędów nie wskazuje na pojedynczy bug; to kombinacja: input Unicode (Windows), stały layout UI, i niespójna orkiestracja locale.
2. Te obszary powinny być domknięte wspólnym regresyjnym testem i18n dla klienta i serwera.
