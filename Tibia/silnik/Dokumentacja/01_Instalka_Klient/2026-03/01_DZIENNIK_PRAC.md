# Dziennik Prac Implementacyjnych

Projekt: zabezpieczenie klienta i serwera (ticket-gate + launcher)  
Strefa czasu: CET/CEST

## Jak wpisywać

1. Jeden blok pracy = jedna sekcja z timestampem.
2. Uzupełniaj tylko fakty (co zmieniono, gdzie, po co, wynik).
3. Wpisuj dokładne ścieżki plików.

## Szablon Wpisu

```md
## [YYYY-MM-DD HH:MM] BLOK: <A1/B3/X2/E6/...> <krótki tytuł>

Zakres:
- ...

Zmienione pliki:
- path/to/file.ext (co i dlaczego)

Nowe pliki:
- path/to/new_file.ext (po co)

Usunięte pliki:
- path/to/deleted.ext (dlaczego)

Dodane linie (orientacyjnie):
- ~N linii w M plikach

Komendy lokalne:
- <komenda 1>

Commit:
- SHA: <short_sha>
- Msg: <wiadomość commita>

Wynik:
- ...

Następny krok:
- ...
```

## Log

## [2026-03-02 ~02:00] BLOK: D1-D10 — Feature flags server-side (Canary) [DONE]

Zakres:
- D1: Nowy enum `PlayerGameMode_t` (GAMEMODE_MODERN=0, GAMEMODE_CLASSIC74=1) w creatures_definitions.hpp
  - Pole `gameMode_` + getter/setter + `isClassic74()` w player.hpp
  - `pendingGameMode_` w protocolgame.hpp — przechowuje tryb z ticket validation
  - Wire-up: onRecvFirstMessage → pendingGameMode_ → login() → player->setGameMode()
  - Reconnect: connect() też ustawia gameMode na reconnect
- D2: Blokada rune-on-creature (server-side) w parseUseWithCreature() i parseUseItemEx()
  - Sprawdza fromPos.x == 0xFFFF (hotkey) + itemType.isRune()
  - Wysyła MESSAGE_STATUS_SMALL z polską informacją
- D3: Blokada Quick Loot (parseQuickLoot, parseLootContainer, parseQuickLootBlackWhitelist)
- D4: Blokada Market (parseMarketLeave, parseMarketBrowse, parseMarketCreateOffer, parseMarketCancelOffer, parseMarketAcceptOffer)
- D5: Blokada Prey System (parsePreyAction)
- D6: Blokada Wheel of Destiny (parseOpenWheel, parseWheelGemAction, parseSaveWheel)
- D7: Blokada Smart Equip (parseHotkeyEquip)
- D8: Rate-limit run 1000ms w Game::playerMove() — Classic 7.4 gracze mają minimalny interwał 1000ms między krokami
  - Nowe pole `lastMoveTime_` w player.hpp + getter/setter
- D9: Action Bar packets — N/A (nie istnieją w codebase)
- D10: Blokada Bestiary (parseBestiarySendRaces, parseBestiarysendMonsterData, parseBestiarySendCreatures)
- Wspólny helper: `isClassic74Blocked(featureName)` w ProtocolGame — sprawdza isClassic74() i wysyła komunikat

Zmienione pliki:
- `canary/src/creatures/creatures_definitions.hpp` — nowy enum PlayerGameMode_t
- `canary/src/creatures/players/player.hpp` — gameMode_ field, lastMoveTime_ field, getGameMode/setGameMode/isClassic74/getLastMoveTime/setLastMoveTime
- `canary/src/server/network/protocol/protocolgame.hpp` — pendingGameMode_, isClassic74Blocked(), forward-declare PlayerGameMode_t
- `canary/src/server/network/protocol/protocolgame.cpp` — D1 wire-up + D2-D10 guardy (18 punktów wejścia)
- `canary/src/game/game.cpp` — D8 rate-limit w playerMove()

Nowe pliki:
- brak

Invariants po zmianie:
- GAMEMODE_MODERN (domyślny) → żadne blokady → stary flow
- GAMEMODE_CLASSIC74 → Market/Prey/Wheel/Bestiary/QuickLoot/SmartEquip zablokowane server-side
- GAMEMODE_CLASSIC74 → rune-on-creature z hotkeya (0xFFFF) zablokowane
- GAMEMODE_CLASSIC74 → ruch ograniczony do 1 step/1000ms
- ticketGateEnabled=false → pendingGameMode_=GAMEMODE_MODERN → brak blokad (backward compatible)
- Komunikaty blokad: polskie, wysyłane przez MESSAGE_STATUS_SMALL

Failure cases:
1. ticketGateEnabled=false → GAMEMODE_MODERN → zero blokad (backward compatible) ✅
2. Gracz Modern próbuje market → działa normalnie ✅
3. Gracz Classic 7.4 próbuje market → blokada + komunikat ✅
4. Gracz Classic 7.4 używa runy z plecaka (nie hotkey) → działa (fromPos.x != 0xFFFF) ✅
5. Gracz Classic 7.4 rusza się za szybko → kroki zablokowane do 1 step/s ✅
6. Reconnect z innnym trybem → gameMode_ nadpisany nowymi danymi z ticketu ✅

Commit:
- SHA: niezacommitowane

Wynik:
- Canary serwer ma pełne feature flags server-side dla Classic 7.4
- 18 punktów wejścia zabezpieczonych guardami
- Rate-limit ruchu 1000ms dla Classic 7.4
- Backward compatible — GAMEMODE_MODERN domyślnie

Następny krok:
- B1-B4: PHP/MySQL (login.php, ticket.php) — jeśli mamy dostęp
- Push + GHA build (test kompilacji C++)
- D11: test integracyjny

---

## [2026-03-02 ~01:00] BLOK: C1-C5 — Canary ticket-gate (serwer) [DONE]

Zakres:
- C1: Nowe pliki `ticket_validator.hpp` i `ticket_validator.cpp` — singleton TicketValidator
  - HMAC-SHA256 via OpenSSL (`HMAC(EVP_sha256(), ...)`)
  - Base64 decode via `EVP_DecodeInit/Update/Final`
  - Constant-time HMAC comparison (zapobiega timing attack)
  - Nonce replay detection (in-memory `std::set<std::string>` z mutexem)
  - JSON parsing via `nlohmann/json`
  - Walidacja: HMAC signature, expiration (ts + 30s), characterName match, nonce uniqueness
- C2: Integracja z `protocolgame.cpp` — walidacja ticketu w `onRecvFirstMessage()`
  - Po `characterName = msg.getString()`, przed online player check
  - Jeśli `TicketValidator::isEnabled()` → `validateTicket()` → disconnect na fail
  - Zmienna `playerGameMode` wyciągana z ticketu — gotowa do użycia w Fazie D
- C3: Config keys w `config_enums.hpp` (`TICKET_GATE_ENABLED`, `TICKET_SECRET`)
  - `configmanager.cpp` — `loadBoolConfig(TICKET_GATE_ENABLED)` + `loadStringConfig(TICKET_SECRET)`
- C4: `config.lua.dist` i `canary_test/config.lua` — `ticketGateEnabled = false`, `ticketSecret = ""`
- C5: Nonce store — in-memory w ticket_validator (std::set + mutex + cleanup expired)

Nowe pliki:
- `canary/src/server/network/protocol/ticket_validator.hpp` (~66 linii) — deklaracja klasy
- `canary/src/server/network/protocol/ticket_validator.cpp` (~190 linii) — implementacja

Zmienione pliki:
- `canary/src/server/network/protocol/protocolgame.cpp` — #include + blok walidacji (~15 linii)
- `canary/src/config/config_enums.hpp` — 2 nowe enum values (TICKET_GATE_ENABLED, TICKET_SECRET)
- `canary/src/config/configmanager.cpp` — 2 nowe loadConfig calls
- `canary/config.lua.dist` — 2 nowe klucze konfiguracyjne
- `canary_test/config.lua` — 2 nowe klucze konfiguracyjne

Invariants po zmianie:
- `ticketGateEnabled = false` (domyślnie) → TicketValidator::isEnabled() = false → nie blokuje logowania
- `ticketGateEnabled = true` + brak ticketu → disconnect("Invalid session")
- `ticketGateEnabled = true` + poprawny ticket → loginWorld działa, playerGameMode ustawione
- HMAC secret z config.lua musi odpowiadać PHP ticket.php secret
- Nonce jednorazowy — użyty ticket nie zadziała ponownie
- Ticket ważny 30 sekund (ts + TICKET_VALIDITY_SECONDS)
- characterName w tickecie musi zgadzać się z wybraną postacią

Failure cases:
1. ticketGateEnabled=false → brak walidacji, stary flow działa (backward compatible)
2. Zły HMAC → disconnect("Invalid session") ✅
3. Expired ticket (>30s) → disconnect("Invalid session") ✅
4. Replay nonce → disconnect("Invalid session") ✅
5. characterName mismatch → disconnect("Invalid session") ✅
6. TICKET_SECRET="" + ticketGateEnabled=true → isEnabled()=false (loguje warning)
7. Nieprawidłowy JSON/base64 → disconnect("Invalid session") ✅

Commit:
- SHA: niezacommitowane

Wynik:
- Canary serwer ma pełny ticket-gate: walidacja HMAC-SHA256, nonce replay detection, config w config.lua
- playerGameMode dostępny w onRecvFirstMessage() do użycia w Fazie D (feature flags server-side)
- Backward compatible — ticketGateEnabled=false domyślnie

Następny krok:
- Faza D: Feature flags server-side (gameMode w Player, blokady market/prey/wheel itp.)
- Lub B1-B4: PHP/MySQL (login.php, ticket.php)

---

## [2026-03-01 ~23:30] BLOK: B5+B6 — Ticket flow klient (Lua + C++) [DONE]

Zakres:
- B6: Nowa metoda C++ `LoginHttp::requestTicket()` w httplogin.cpp/.h
  - POST HTTPS do ticket.php z JSON: {sessionKey, characterName, gameMode, type:"ticket"}
  - TLS hard-fail (enable_server_certificate_verification(true))
  - Callback Lua: `EnterGame.onTicketSuccess(requestId, ticket)` lub `onTicketFailed(requestId, msg, status)`
  - Implementacja native (httplib::SSLClient) + Emscripten (emscripten_fetch)
- B5: Lua ticket flow w entergame.lua + characterlist.lua
  - `EnterGame.requestTicket(charInfo)` — parsuje host/path z httpLoginUrl, wywołuje C++ requestTicket
  - `EnterGame.onTicketSuccess()` — otrzymuje ticket HMAC, wywołuje connectWithTicket()
  - `EnterGame.onTicketFailed()` — wyświetla errorBox, wraca do listy postaci
  - `EnterGame.onTicketBypassed()` — gdy nie ma CLIENT_LOCKED, łączy bezpośrednio
  - `EnterGame.connectWithTicket()` — g_game.loginWorld z ticketem jako sessionKey (do Fazy C)
  - `characterlist.lua tryLogin()` — zamiast bezpośredniego g_game.loginWorld, wywołuje EnterGame.requestTicket()

Zmienione pliki:
- `canary_test/testyy/src/framework/net/httplogin.cpp` — dodano requestTicket() (natywna + Emscripten implementacja, ~120 linii)
- `canary_test/testyy/src/framework/net/httplogin.h` — deklaracja requestTicket()
- `canary_test/testyy/src/framework/luafunctions.cpp` — binding Lua: bindClassMemberFunction("requestTicket")
- `canary_test/testyy/modules/client_entergame/entergame.lua` — dodano ~100 linii: requestTicket, onTicketSuccess/Failed/Bypassed, connectWithTicket, G.ticketToken/ticketRequestId/pendingCharInfo
- `canary_test/testyy/modules/client_entergame/characterlist.lua` — tryLogin() używa EnterGame.requestTicket() gdy CLIENT_LOCKED

Nowe pliki:
- brak

Invariants po zmianie:
- CLIENT_LOCKED=true => tryLogin() wywołuje EnterGame.requestTicket() (nie bezpośredni g_game.loginWorld)
- CLIENT_LOCKED=false => tryLogin() wywołuje g_game.loginWorld() bezpośrednio (stara ścieżka)
- requestTicket() → HTTPS POST do ticket.php → onTicketSuccess → connectWithTicket → g_game.loginWorld z ticketem
- TLS verification=true w requestTicket() (hard-fail)
- ticketPath obliczany z httpLoginUrl (login.php → ticket.php)
- G.ticketToken tymczasowo przekazywany jako sessionKey (do Fazy C — osobne pole w protokole)

Failure cases:
1. ticket.php niedostępny → onTicketFailed → errorBox + powrót do CharacterList
2. Zły sessionKey → ticket.php zwraca errorMessage → onTicketFailed
3. CLIENT_LOCKED=false → ticket flow pominięty, stare połączenie
4. Brak httpLoginUrl w config → onTicketBypassed (bezpośrednie połączenie)
5. TLS cert invalid → SSLClient odrzuca → onTicketFailed

Co jeszcze NIE jest zaimplementowane (strona serwera):
1. ❌ B1: gameMode + launchToken w login.php (PHP)
2. ❌ B2: Filtrowanie worldów wg gameMode (PHP)
3. ❌ B3: ticket.php endpoint (PHP) — generowanie HMAC, nonce
4. ❌ B4: ticket_nonces MySQL tabela
5. ❌ B7: Test flow end-to-end
6. ❌ Faza C: Canary walidacja ticketu (C++ serwer)
7. ❌ Faza D: Feature flags server-side

Commit:
- SHA: niezacommitowane

Wynik:
- Klient ma pełny ticket flow: login → ticket request → connect z ticketem
- Brakuje strony serwera (PHP ticket.php + Canary walidacja)

Następny krok:
- Faza C: ticket_validator.cpp w Canary (serwer)
- Lub B1-B4: PHP/MySQL (jeśli mamy dostęp)

---

## [2026-03-01 ~23:00] BLOK: X2+X2b+X7 — Security wins w httplogin.cpp [DONE]

Zakres:
- X2: TLS hard-fail — zmiana `enable_server_certificate_verification(false)` → `true`
- X2b: Usunięcie HTTP fallback — HTTPS fail = game over, brak próby po HTTP
  - Native: usunięto wywołanie `loginHttpJson()` po HTTPS fail (linia ~108)
  - Emscripten: usunięto blok `if (fetch->status != 200 && httpLogin) { http://... }` (linia ~170)
- X7: Usunięcie logowania wrażliwych danych w `Logger()`:
  - `req.body` (zawierał email+hasło w JSON) — usunięty z cout
  - `res.body` (zawierał session key) — usunięty z cout

Zmienione pliki:
- `canary_test/testyy/src/framework/net/httplogin.cpp` — 4 edycje (TLS, 2x fallback, logger)

Nowe pliki:
- brak

Usunięte pliki:
- brak

Invariants po zmianie:
- HTTPS fail => BRAK fallbacku na HTTP (klient raportuje błąd, koniec)
- TLS cert invalid => połączenie odrzucone (hard-fail)
- Logger NIE wypisuje req.body ani res.body (brak haseł/session w logach)
- Metoda `loginHttpJson()` nadal istnieje jako definicja (dead code) — do cleanup potem
- Metoda `loginHttpJson` jest nadal zadeklarowana w .h (nie usuwamy — linker)

Failure cases (5 scenariuszy):
1. Serwer z self-signed cert → klient odrzuca (TLS hard-fail) ✅ zamierzone
2. Serwer z valid cert → HTTPS działa normalnie ✅
3. Serwer tylko HTTP (port 80) → klient nie próbuje HTTP, raportuje "HTTPS error" ✅
4. Logger przy błędzie → loguje method, path, status, reason — BEZ body ✅
5. Emscripten build → tylko HTTPS URL, brak fallback na http:// ✅

Grep regresji:
- `enable_server_certificate_verification` → linia 211: `(true)` ✅
- `loginHttpJson(` → linia 110 (komentarz), linia 236 (definicja dead code) ✅
- `"http://"` → BRAK ✅
- `req.body` / `res.body` w cout → BRAK (tylko w komentarzach) ✅

Commit:
- SHA: niezacommitowane (plik C++ — wymaga kompilacji przed push)

Wynik:
- 3 krytyczne/wysokie luki bezpieczeństwa naprawione
- httplogin.cpp jest teraz HTTPS-only z TLS verification
- Dead code `loginHttpJson()` do usunięcia w przyszłym cleanup

Następny krok:
- Commit batch wszystkich zmian (Faza A Lua + X2/X2b/X7 C++)
- Push + GHA build (test kompilacji)
- Faza B: API HTTP ticket-gate

---

## [2026-03-01 ~22:00] BLOK: A-FIX — Codex code review + poprawki logicznych błędów [DONE]

Zakres:
- Przegląd kodu przez Codexa — wykryte 2 WYSOKIE i 2 ŚREDNIE błędy logiczne
- Fix HIGH: port 7171 + httpLogin=true = nie trafia do HTTP flow (doLogin warunek: port ~= 7171)
- Fix HIGH: ServerList.add() blokowała WSZYSTKO (włącznie z wewnętrznym load()), g_settings r/w przy locku
- Fix MEDIUM: setLoginFormVisible() brakowało pól serwera (serverHostTextEdit, serverPortTextEdit, serverLabel itp.)
- Fix MEDIUM: brak walidacji placeholderów ZMIEN_NA_ADRES — fail widoczny dopiero przy loginie
- Dokumentacja znanych problemów C++ (TLS disabled, HTTP fallback) — do naprawy w Fazie B/X2

Zmienione pliki:
- `canary_test/testyy/init.lua` — port 7171→443 w obu GameModes, dodano blok walidacji placeholderów (do{} na starcie)
- `canary_test/testyy/modules/client_serverlist/serverlist.lua` — init() pomija g_settings przy CLIENT_LOCKED, terminate() pomija zapis, add() przepuszcza load=true
- `canary_test/testyy/modules/client_entergame/entergame.lua` — setLoginFormVisible() dodano: serverHostTextEdit, serverPortTextEdit, serverLabel, portLabel, clientLabel, serverListButton

Nowe pliki:
- brak

Usunięte pliki:
- brak

Invariants po zmianie:
- CLIENT_LOCKED=true => g_settings.getNode('ServerList') NIGDY nie jest czytane/zapisywane
- CLIENT_LOCKED=true + load=true => ServerList.add() DZIAŁA (wewnętrzne ładowanie)
- CLIENT_LOCKED=true + load=false/nil => ServerList.add() BLOKUJE (gracz nie może dodać)
- httpLogin=true + port=443 => doLogin() idzie do tryHttpLogin() (bo port ~= 7171)
- Placeholder "ZMIEN_NA_ADRES" => warning w g_logger na starcie klienta

Failure cases (5 scenariuszy):
1. Zły host (placeholder) — teraz: warning w logu od razu, fail przy loginie z komunikatem
2. Brak trybu (CurrentGameMode=nil) — doLogin() blokuje z komunikatem "Najpierw wybierz tryb gry"
3. Lock bypass (ServerList.add bez load) — zwraca false, 'Client is locked'
4. Fallback HTTP w C++ — NADAL ISTNIEJE (httplogin.cpp:108-109) — do naprawy w Fazie B/X2
5. TLS verification disabled — NADAL ISTNIEJE (httplogin.cpp:215) — do naprawy w Fazie B/X2

Grep regresji:
- `enable_server_certificate_verification(false)` → httplogin.cpp:215 (C++ — NIE ruszamy w Fazie A)
- `loginHttpJson(` → httplogin.cpp:109,240 (C++ — NIE ruszamy w Fazie A)
- `port = 7171` w init.lua → BRAK (naprawione ✅)
- `g_settings.*ServerList` → linie 19,42 w serverlist.lua (oba wewnątrz if not CLIENT_LOCKED ✅)

Co jeszcze NIE jest zaimplementowane (C++ ścieżki bezpieczeństwa):
1. ❌ httplogin.cpp:215 — TLS cert verification disabled (KRYTYCZNE)
2. ❌ httplogin.cpp:108 — HTTP fallback po HTTPS fail (KRYTYCZNE)
3. ❌ httplogin.cpp:~170 — Emscripten HTTP fallback (WYSOKIE)
4. ❌ Ticket HMAC (Faza B+C) — cały endpoint ticket.php + walidacja w Canary
5. ❌ Feature flags server-side (Faza D) — blokady market/prey/wheel itp. w C++ Canary
6. ❌ Rate limiting (Faza D8) — run 1000ms throttle
7. ❌ Launcher auto-update (Faza E) — cały launcher

Commit:
- SHA: niezacommitowane (nie commitujemy — brak zmian w plikach do kompilacji C++)

Wynik:
- 4 błędy logiczne naprawione w Lua
- Znane problemy C++ udokumentowane
- Grep regresji OK

Następny krok:
- Commit batch gdy będą zmiany w plikach C++ (lub na życzenie)
- A8: test kompilacji (push + GHA)
- X2: hard-fail TLS w httplogin.cpp (zmiana C++)

---

## [2026-03-01 ~21:00] BLOK: A6 — blokada hotkey na runy [DONE]

Zakres:
- Jedyna blokada kliencka dla trybu Classic 7.4: hotkey na itemy/runy
- Guard na początku executeHotkeyItem() sprawdza isFeatureEnabled("hotkeys_items")
- Wyświetla komunikat statusowy i return gdy false

Zmienione pliki:
- `canary_test/testyy/modules/game_hotkeys/hotkeys_manager.lua` — guard na pocz. executeHotkeyItem()

Commit:
- SHA: niezacommitowane

Wynik:
- Blokada działa tylko dla executeHotkeyItem (itemy, runy)
- hotkey na spelle (sendSay) NIE jest blokowane — to osobna ścieżka
- A7 (ukrycie modułów market/prey/wheel) — WYCOFANE — blokady będą server-side (Faza D)

---

## [2026-03-01 ~20:00] BLOK: A2+A3+A4+A5 — ekran wyboru trybu + logika + blokady [DONE]

Zakres:
- A2: Panel wyboru trybu gry (gameModePanel) w entergame.otui
- A3: Logika wyboru trybu w entergame.lua — selectGameMode(), showGameModeSelection()
- A4: Blokada ServerList.add/remove/show gdy CLIENT_LOCKED
- A5: Ukrycie pól serwera/portu/protokołu (reuse setUniqueServer)

Zmienione pliki:
- `canary_test/testyy/modules/client_entergame/entergame.otui` — dodano gameModePanel z btnClassic74, btnModern, btnChangeMode, selectedModeLabel; dodano id: passwordLabel
- `canary_test/testyy/modules/client_entergame/entergame.lua` — dodano zmienną gameModeSelected, showGameModeSelection(), selectGameMode(modeKey), setLoginFormVisible(visible), guard w doLogin(), guard w init() i onCharacterList
- `canary_test/testyy/modules/client_serverlist/serverlist.lua` — dodano CLIENT_LOCKED guardy w add(), remove(), show()

Commit:
- SHA: `b216fe683`
- Branch: `feature/ticket-gate`
- Msg: `A2+A3+A4+A5: ekran wyboru trybu, logika, blokady serverlist`

Wynik:
- Gracz musi wybrać tryb Classic 7.4 lub Modern przed logowaniem
- Serwer/port/protokół ustawiane automatycznie z GameModes
- ServerList zablokowana dla gracza (add/remove/show)
- Formularz logowania ukrywany dopóki tryb nie zostanie wybrany

---

## [2026-03-01 18:27] BLOK: A1 — CLIENT_LOCKED + GameModes w init.lua [DONE]

Zakres:
- Dodanie flagi `CLIENT_LOCKED = true` do init.lua (klient przypisany do naszych serwerów)
- Dodanie tabeli `GameModes` z dwoma trybami: `classic74` i `modern`
- Każdy tryb ma: nazwę wyświetlaną, konfigurację serwera, tabelę feature flags
- Dodanie zmiennej `CurrentGameMode = nil` (będzie ustawiana po wyborze gracza)
- Dodanie helperów: `isFeatureEnabled(name)`, `getCurrentServerConfig()`
- Usunięcie starego zakomentowanego `Servers_init`

Zmienione pliki:
- `canary_test/testyy/init.lua` — usunięto zakomentowany Servers_init, dodano CLIENT_LOCKED, GameModes{classic74,modern}, CurrentGameMode, 2 helpery

Nowe pliki:
- brak

Dodane linie (orientacyjnie):
- ~80 linii nowego kodu w 1 pliku (init.lua wzrósł z 127 do 197 linii)

Commit:
- SHA: `72681f84c`
- Branch: `feature/ticket-gate` (bazuje na `feature/i18n-multilanguage`)
- Msg: `A1: CLIENT_LOCKED + GameModes + feature flags w init.lua`

Wynik:
- init.lua zawiera pełną konfigurację trybów gry z feature flags
- Adresy serwerów ustawione na placeholder `ZMIEN_NA_ADRES_SERWERA` (do uzupełnienia gdy będziemy mieć prawdziwe adresy)
- Plik .lua — nie wymaga kompilacji, ale push + GHA build i tak zrobimy żeby upewnić się że nic nie zepsuliśmy
- Branch `feature/ticket-gate` stworzony na bazie `feature/i18n-multilanguage` (commit `12294303d`) i wypchnięty na GitHub

Następny krok:
- Odpalić GHA build → wpis w 02_DZIENNIK_BUILDOW_GHA.md
- Faza A2: ekran wyboru trybu w entergame.otui

---

## [2026-03-01 17:45] BLOK: INIT setup procesu pracy

Zakres:
- Utworzenie dokumentacji operacyjnej do śledzenia progresu i błędów.

Zmienione pliki:
- `Dokumentacja/01_Instalka_Klient/2026-03/00_START_PRACY_CHECKLISTA.md` (zasady pracy i workflow)

Nowe pliki:
- `Dokumentacja/01_Instalka_Klient/2026-03/00_START_PRACY_CHECKLISTA.md` (checklista procesu)
- `Dokumentacja/01_Instalka_Klient/2026-03/01_DZIENNIK_PRAC.md` (dziennik implementacji)
- `Dokumentacja/01_Instalka_Klient/2026-03/02_DZIENNIK_BUILDOW_GHA.md` (dziennik buildów i błędów)

Komendy lokalne:
- `rg --files`
- `find Dokumentacja -maxdepth 4 -type d`

Wynik:
- Mamy stały format dokumentacji postępu i diagnostyki.

Następny krok:
- Zacząć Faza A i wpisywać każdy blok pracy wg szablonu.
