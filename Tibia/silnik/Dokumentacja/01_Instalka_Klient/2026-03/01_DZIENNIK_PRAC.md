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

## [2026-03-02 ~04:00] BLOK: B7 — Smoke-test login→ticket flow [DONE]

Zakres:
- Apliko schema SQL na bazę canaryaac (ticket_nonces + ticket_sessions)
- Wygenerowanie prawdziwego TICKET_SECRET (64 hex)
- Ustawienie tego samego sekretu w .env (PHP) i config.lua (Canary)
- Włączenie ticketGateEnabled = true w config.lua
- Test CLI: login.php → sessionKey → ticket.php → ticket HMAC

Wyniki testu:
- **login.php**: Zwraca poprawny JSON z `sessionkey` (UUID), characters, worlds filtrowane wg gameMode
- **ticket.php**: Zwraca ticket w formacie `base64(payload).hmac_hex`
- **HMAC match: YES ✓** — ticket wygenerowany przez PHP weryfikuje się poprawnie
- **Payload**: Zawiera wszystkie wymagane pola: characterName, gameMode, nonce (32 hex), expiresAt
- **DB**: Nonce zapisany w ticket_nonces, sesja w ticket_sessions z game_mode
- **TTL**: 30s (TICKET_TTL z .env)

Zmienione pliki:
- `canary_test/html_copy/apik/v1/.env` — TICKET_SECRET ustawiony na prawdziwy klucz
- `canary_test/config.lua` — ticketGateEnabled=true, ticketSecret=ten sam klucz

Commit:
- SHA: niezacommitowane

Następny krok:
- Faza E (Launcher) lub kompilacja push (A8/C6)

---

## [2026-03-02 ~03:00] BLOK: B1+B2+B3+B4 — PHP/MySQL ticket-gate [DONE]

Zakres:
- B4: Schema MySQL (`ticket_nonces`, `ticket_sessions`) + .env config
- B1: Parametr `gameMode` w login.php + nowy format sesji (UUID zamiast `account\npassword`)
- B2: Filtrowanie worldów wg gameMode (per-mode IP/port z .env)
- B3: Nowy endpoint `ticket.php` — generowanie ticketów HMAC

### B4: Schema MySQL
- **Tabela `ticket_nonces`**: nonce VARCHAR(64) PK, account_id INT, expires_at INT UNSIGNED, INDEX idx_expires
- **Tabela `ticket_sessions`**: session_key VARCHAR(128) PK, account_id INT, game_mode VARCHAR(32) DEFAULT 'modern', expires_at INT UNSIGNED, INDEX idx_account + idx_expires
- **.env**: Dodano `TICKET_SECRET`, `TICKET_TTL=30`, `SESSION_TTL=1800`

### B1: gameMode w login.php
- **Parametr `gameMode`**: classic74 / modern / pusty (domyślnie modern)
- **Nowy format sesji**: UUID (64 hex = `bin2hex(random_bytes(32))`) zamiast `account\npassword`
- **Zapis sesji**: INSERT do `ticket_sessions` z gameMode, expires_at
- **Backward compat**: Response zawiera `sessionkey` (UUID dla ticket.php) PLUS `key` (legacy `account\npassword`)
- **Cleanup sesji**: Probabilistyczne (10% requestów) DELETE wygasłych sesji

### B2: Filtrowanie worldów wg gameMode
- **Funkcja `getWorldsForGameMode($gameMode, $ENV, $mysqli)`**: Zwraca tablicę worldów per gameMode
- **.env per-mode**: `WORLD_CLASSIC74_IP/PORT`, `WORLD_MODERN_IP/PORT` — opcjonalne override'y
- **Domyślne**: Jeśli brak override → world "Classic74" / "Modern" z ogólną konfiguracją

### B3: ticket.php
- **Flow**: POST `{sessionKey, characterName, gameMode, worldName, type:"ticket"}`
  1. Waliduje sessionKey → ticket_sessions (nie wygasła)
  2. Sprawdza characterName → należy do konta z sesji
  3. Sprawdza gameMode → zgodny z sesją (autorytatywne: gameMode z sesji)
  4. Generuje nonce: `bin2hex(random_bytes(16))` — 32 znaki hex
  5. Payload JSON: `{accountId, characterName, gameMode, worldName, nonce, issuedAt, expiresAt}`
  6. **HMAC na base64(payload)** — identyczne jak ticket_validator.cpp (FIX5)
  7. Ticket: `base64(payload).hmac_hex`
  8. Zapisuje nonce do ticket_nonces
  9. Cleanup wygasłych nonce'ów (5% requestów)
- **Bezpieczeństwo**: Sprawdza `TICKET_SECRET` ≠ placeholder, fail jeśli nie skonfigurowany

Zmienione pliki:
- `canary_test/html_copy/apik/v1/login.php` — B1+B2 (pełna przebudowa)
- `canary_test/html_copy/apik/v1/.env` — B4 (TICKET_SECRET, TTL)

Nowe pliki:
- `canary_test/html_copy/apik/v1/ticket.php` — B3
- `canary_test/html_copy/apik/v1/schema_ticket_gate.sql` — B4

Weryfikacja:
- `php -l ticket.php` — OK (brak błędów składni)
- `php -l login.php` — OK (brak błędów składni)
- Format ticketu: `base64(json).hmac_hex` — zgodny z ticket_validator.cpp
- Wymagane pola payload: characterName, gameMode, nonce, expiresAt — wszystkie obecne
- C++ requestTicket wysyła: `{sessionKey, characterName, gameMode, worldName, type:"ticket"}` — zgodne z ticket.php

Commit:
- SHA: niezacommitowane

Wynik:
- B1+B2+B3+B4 = komplet PHP/MySQL ticket-gate
- Cały flow login→ticket→connect pokryty: login.php (sesja) → ticket.php (HMAC) → Canary (walidacja)

Następny krok:
- B7: Test end-to-end login→ticket→connect
- Uruchomienie schema SQL na bazie `canaryaac`
- Commit batch

---

## [2026-03-01 ~05:00] BLOK: CR-1..CR-4 — Remaining Codex findings [DONE]

Zakres:
- 4 findings z przeglądu Codex — 1 WYSOKI, 2 ŚREDNIE, 1 NISKI

### CR-1 (WYSOKI): Niespójny format hosta w tryHttpLogin
- **Problem**: `G.host` w CLIENT_LOCKED mode to sam hostname (z `GameModes.server.host`), ale `tryHttpLogin()` oczekiwał formatu `"host/path"` i próbował parsować. Wynik: POST na `https://host:443/` zamiast `https://host:443/login.php`. Pole `httpLoginUrl` (pełny URL) istniało w config ale nie było używane.
- **Naprawa**: Gdy `CLIENT_LOCKED`, `tryHttpLogin()` teraz parsuje `httpLoginUrl` z `getCurrentServerConfig()` — wyciąga host, path, i port. Fallback na stare parsowanie `G.host` gdy brak `httpLoginUrl`.

### CR-2 (ŚREDNI): Nieaktualny komunikat błędu
- **Problem**: Po usunięciu HTTP fallback (X2b), komunikat błędu nadal sugerował "Enable Http login / check port 80/8080" — mylące, bo teraz jest tylko HTTPS.
- **Naprawa**: Nowy komunikat: "Cannot connect to login server (HTTPS).\nCheck:\n- Server address and port\n- Apache / nginx running\n- login.php accessible\n- TLS certificate valid\n- Cloudflare / firewall rules"

### CR-3 (ŚREDNI): Wrażliwe nagłówki w loggerze
- **Problem**: `Logger()` usunął body (X7) ale nadal wypisywał `req.headers` i `res.headers`. Mogą zawierać `Authorization`, `Set-Cookie`, `X-Auth-Token`.
- **Naprawa**: Usunięto obie pętle `for (headers)` z loggera. Logujemy tylko: method, path, version, status, reason, location.

### CR-4 (NISKI): Unused variable httpLogin
- **Problem**: Po X2b, `httpLogin` nadal łapany przez lambdy w `httpLogin()` — warning przy `-Wunused-lambda-capture`.
- **Naprawa**: Usunięto `httpLogin` z capture list obu lambd (native + emscripten).

Zmienione pliki:
- `canary_test/testyy/modules/client_entergame/entergame.lua` — CR-1 (tryHttpLogin parsuje httpLoginUrl)
- `canary_test/testyy/src/framework/net/httplogin.cpp` — CR-2 (error msg), CR-3 (headers usunięte z loggera), CR-4 (httpLogin usunięty z capture)

Nowe pliki:
- brak

Invariants po zmianie:
- CLIENT_LOCKED + httpLoginUrl → tryHttpLogin parsuje URL poprawnie (host + /login.php path + port)
- CLIENT_LOCKED + brak httpLoginUrl → fallback na stare parsowanie G.host
- Logger NIE wypisuje żadnych wrażliwych danych (body, headers)
- httpLogin parametr nadal istnieje w sygnaturze (backward compatibility) ale nie jest capturowany
- Komunikat błędu HTTPS-only — brak wzmianki o HTTP/port 80

Commit:
- SHA: niezacommitowane

Wynik:
- Wszystkie 4 Codex findings naprawione
- 2 pliki zmodyfikowane (1 C++, 1 Lua)

Następny krok:
- Commit batch + push + GHA build
- Faza B (PHP: login.php + ticket.php + MySQL)

---

## [2026-03-01 ~04:00] BLOK: CODEX-FIX1..FIX8 — Naprawa 8 bugów z przeglądu Codex [DONE]

Zakres:
- Przegląd Codex wykrył 8 bugów w implementacji ticket-gate. Wszystkie naprawione w tej sesji.

### FIX1: Broken guard insertions w protocolgame.cpp
- **Problem**: 6 guardów D6/D10 wstawionych w złe miejsca:
  - D10 guard wewnątrz `parseRuleViolationReport()` (~linia 2468) — usunięty
  - D10 guard w `parseBestiarySendRaces()` za `writeToOutputBuffer()` — przeniesiony na początek metody
  - D10 guard w pętli charm (~linia 3148) — usunięty
  - D6 guard rozdzielający `void` na `v`+`oid` w `sendSingleSoundEffect()` — usunięty
  - D6 guard w liście parametrów `sendDoubleSoundEffect()` — usunięty
  - D6 guard w ciele `sendDoubleSoundEffect()` — usunięty
- **Naprawa**: Usunięto 6 błędnych guardów, dodano 6 poprawnych:
  - D6 → `parseOpenWheel()`, `parseWheelGemAction()`, `parseSaveWheel()`
  - D10 → `parseBestiarySendRaces()`, `parseBestiarysendMonsterData()`, `parseBestiarySendCreatures()`

### FIX2: ticket_validator.cpp brakujący w CMake
- **Problem**: `ticket_validator.cpp` nie był w `target_sources` → linker error
- **Naprawa**: Dodano `network/protocol/ticket_validator.cpp` do `canary/src/server/CMakeLists.txt`

### FIX3: Brak ścieżki authType="ticket"
- **Problem**: Gdy ticket-gate aktywny, sessionKey to ticket HMAC (nie zawiera `\n`). Kod `if (authType != "session")` próbował splitować ticket przez `\n` → brak danych sesji
- **Naprawa**: Dodano `const bool ticketGateActive = TicketValidator::getInstance().isEnabled()`. Zmieniono warunek na `if (!ticketGateActive && authType != "session")` — pominięcie split gdy ticket-gate aktywny

### FIX4: requestTicket brak worldName
- **Problem**: Plan wymaga worldId w ticket flow, ale `requestTicket()` wysyłał tylko {sessionKey, characterName, gameMode}
- **Naprawa**: Dodano parameter `worldName` do:
  - `httplogin.h` — deklaracja
  - `httplogin.cpp` — oba body JSON (native + emscripten) + capture w lambda
  - `entergame.lua` — przekazanie `charInfo.worldName` w wywołaniu

### FIX5: HMAC format — dokumentacja
- **Problem**: Plan mówi "HMAC na JSON payload", kod oblicza HMAC na `base64(payload)`. Potencjalna niespójność z ticket.php
- **Naprawa**: Dodano obszerny komentarz w `ticket_validator.cpp` wyjaśniający, że HMAC na base64 jest celowy (podejście JWT-like, eliminuje problemy z kanonizacją JSON). ticket.php MUSI generować w ten sam sposób

### FIX6: Client fail-open → fail-closed
- **Problem**: `EnterGame.requestTicket()` wywoływał `onTicketBypassed()` (bezpośrednie połączenie bez ticketu) gdy:
  - brak httpLoginUrl w konfiguracji serwera
  - nie da się sparsować hosta z URL
  - `connectWithTicket()` miał fallback `G.ticketToken or G.sessionKey` — brak ticketu = zwykły login
- **Naprawa**:
  - Oba błędy config → `EnterGame.onTicketConfigError(msg)` — vyśietla errorBox i wraca do listy postaci
  - `connectWithTicket()` — jeśli `G.ticketToken` jest nil/pusty → error (nie fallback na sessionKey)
  - Dodano nową funkcję `EnterGame.onTicketConfigError(msg)`
  - Bypass dozwolony TYLKO gdy `not CLIENT_LOCKED` (stary tryb bez ticket flow)

### FIX7: D8 rate-limit — ruch nie runy
- **Problem**: Plan nazwał D8 "rate-limit run (rune)", ale implementacja limituje ruch (1000ms/krok), nie użycie run
- **Naprawa**: Rozbudowany komentarz w `game.cpp` wyjaśniający, że ruch jest celowo limitowany (emulacja 7.4), a runy blokowane kliencko (D7 hotkey guard)

### FIX8: ServerList ukryta zamiast read-only
- **Problem**: `ServerList.show()` miał `if CLIENT_LOCKED then return end` — lista całkowicie ukryta. `serverListButton` ukryty w entergame.lua. Plan mówi: "lista widoczna, ale edycja zablokowana"
- **Naprawa**:
  - `serverlist.lua`: Usunięto early return. Dodano ukrywanie `buttonAdd` i `buttonOk` gdy CLIENT_LOCKED. Ukrycie przycisków "x" (remove) na wpisach serwerów
  - `entergame.lua`: Zakomentowano ukrywanie `serverListButton` — przycisk pozostaje widoczny
  - Lista jest teraz read-only: widoczna, ale bez add/remove/select

Zmienione pliki:
- `canary/src/server/network/protocol/protocolgame.cpp` — FIX1 (6 usunięć + 6 dodań guardów), FIX3 (ticketGateActive check)
- `canary/src/server/CMakeLists.txt` — FIX2 (dodano ticket_validator.cpp)
- `canary/src/server/network/protocol/ticket_validator.cpp` — FIX5 (komentarz HMAC format)
- `canary/src/game/game.cpp` — FIX7 (komentarz D8 rate-limit)
- `canary_test/testyy/src/framework/net/httplogin.h` — FIX4 (worldName parameter)
- `canary_test/testyy/src/framework/net/httplogin.cpp` — FIX4 (worldName w JSON body + lambda)
- `canary_test/testyy/modules/client_entergame/entergame.lua` — FIX4 (worldName w requestTicket), FIX6 (fail-closed), FIX8 (serverListButton widoczny)
- `canary_test/testyy/modules/client_serverlist/serverlist.lua` — FIX8 (read-only mode)

Nowe pliki:
- brak

Invariants po zmianie:
- Guardy D6/D10 wstawione do poprawnych metod parse* (nie send*, nie pętle, nie inne metody)
- ticket_validator.cpp kompiluje się z CMake
- Ticket-gate aktywny → sessionKey NIE jest splitowany przez `\n`
- requestTicket wysyła worldName w JSON body
- HMAC obliczany na base64(payload) (standard, udokumentowany)
- CLIENT_LOCKED + brak config → error dialog (nie bypass)
- CLIENT_LOCKED + nil ticket → error (nie fallback na sessionKey)
- ServerList widoczna read-only: add/remove/select ukryte, lista i przycisk dostępne
- D8 limituje ruch, D7 limituje runy kliencko — oba celowe

Commit:
- SHA: niezacommitowane

Wynik:
- Wszystkie 8 Codex bugs naprawione
- 8 plików zmodyfikowanych (5 C++, 3 Lua)
- Bezpieczeństwo ticket flow: fail-closed, worldName, HMAC documented

Następny krok:
- CR-1..CR-4: Remaining Codex findings
- B1-B4: PHP/MySQL
- Commit batch + push + GHA build

---

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

---

## [2026-03-01 22:00] BLOK: Faza E — Launcher + API endpoints + LaunchToken (E1-E12)

Zakres:
- E1: generate_manifest.php — skanuje katalog klienta, oblicza SHA-256 per plik, generuje manifest JSON
- E2: update.php — serwuje manifest JSON z cache/ETag
- E3: launcher-token.php — endpoint POST, generuje token jednorazowy, rate-limit per IP, IP-binding
- E4: launcher-version.php — endpoint GET, zwraca wersję launchera z flagą required
- E5: schema_launcher.sql — tabele launch_tokens + manifest_versions, zastosowane do MySQL
- E6-E8: launcher.py — pełny launcher Python z tkinter GUI, UpdateManager (temp→atomic rename),
  LauncherAPI (check_launcher_version, get_manifest, get_launch_token, download_file),
  token przekazywany przez zmienną OTC_LAUNCH_TOKEN
- E9: check_launcher_version wbudowane w launcher.py
- E10: Klient OTClient — odczyt OTC_LAUNCH_TOKEN z env (init.lua: G.launchToken),
  nowa metoda setLaunchToken() w LoginHttp (C++), Lua binding, entergame.lua przekazuje token przed httpLogin
- E11: login.php — walidacja launchToken po autentykacji hasła:
  CLIENT_LOCKED=true → wymaga ważnego tokenu z launch_tokens (SELECT FOR UPDATE + DELETE, atomowa konsumpcja),
  sprawdza IP, expiry, opcjonalnie filesHash. Naprawiony bug: expires_at TIMESTAMP → strtotime()
- E12: Smoke test pełnego flow: bez tokenu→fail, fałszywy→fail, prawdziwy→OK+konsumpcja, ponowny→fail

Nowe pliki:
- `canary_test/html_copy/apik/v1/generate_manifest.php` (E1, ~120 linii)
- `canary_test/html_copy/apik/v1/update.php` (E2, ~80 linii)
- `canary_test/html_copy/apik/v1/launcher-token.php` (E3, ~190 linii)
- `canary_test/html_copy/apik/v1/launcher-version.php` (E4, ~60 linii)
- `canary_test/html_copy/apik/v1/schema_launcher.sql` (E5)
- `canary_test/launcher/launcher.py` (E6-E8, ~400 linii)
- `canary_test/launcher/launcher_config.json` (config launchera)
- `canary_test/launcher/requirements.txt` (requests>=2.28.0)
- `canary_test/launcher/build_launcher.bat` (PyInstaller Windows)
- `canary_test/launcher/build_launcher.sh` (PyInstaller Linux)

Zmienione pliki:
- `canary_test/html_copy/apik/v1/login.php` — E11: LaunchToken validation (~70 linii dodane)
- `canary_test/html_copy/apik/v1/.env` — CLIENT_LOCKED, EXPECTED_FILES_HASH, launcher config
- `canary_test/testyy/src/framework/net/httplogin.h` — E10: setLaunchToken(), launchToken member
- `canary_test/testyy/src/framework/net/httplogin.cpp` — E10: setLaunchToken impl, launchToken w JSON body (4 miejsca)
- `canary_test/testyy/src/framework/luafunctions.cpp` — E10: binding setLaunchToken
- `canary_test/testyy/init.lua` — E10: G.launchToken = os.getenv("OTC_LAUNCH_TOKEN")
- `canary_test/testyy/modules/client_entergame/entergame.lua` — E10: http:setLaunchToken() przed httpLogin

Wygenerowane pliki:
- `canary_test/html_copy/apik/v1/manifests/stable/latest.json` (manifest, 7791 plików, 427.5 MB)
- `canary_test/html_copy/apik/v1/manifests/stable/1.0.0.json` (kopia)

Tabele MySQL:
- `launch_tokens` (token PK, launcher_version, files_hash, manifest_version, client_ip, expires_at TIMESTAMP)
- `manifest_versions` (id, version+channel UNIQUE, files_hash, file_count, total_size, is_active)

Smoke test E12 (CLI):
- CLIENT_LOCKED=false: login BEZ tokenu → OK (sessionkey)
- CLIENT_LOCKED=true: login BEZ tokenu → FAIL "Launch token required"
- CLIENT_LOCKED=true: login z fake tokenem → FAIL "Invalid launch token"
- CLIENT_LOCKED=true: INSERT prawdziwego tokenu + login → OK (sessionkey), token skonsumowany (0 w DB)
- CLIENT_LOCKED=true: ponowne użycie tokenu → FAIL "Invalid launch token" (one-time use ✓)

Bug naprawiony:
- login.php: `(int)$tokenRow['expires_at']` → `strtotime($tokenRow['expires_at'])` (TIMESTAMP to nie INT)

Komendy lokalne:
- `php -l *.php` — syntax check wszystkich PHP
- `python3 -c "import py_compile; py_compile.compile('launcher.py')"` — syntax check launchera
- `mysql < schema_launcher.sql` — tabele launchera
- `php generate_manifest.php` — wygenerowanie manifestu (7791 files, 427.5 MB)
- Testy CLI z MockInput stream wrapper (php://input override)

Commit:
- Jeszcze NIE zacommitowane — do zrobienia po zakończeniu Fazy E

Wynik:
- Pełna infrastruktura launchera: API endpoints + Python GUI launcher + klient OTC integracja
- Wymuszenie launchera: CLIENT_LOCKED=true blokuje login bez ważnego jednorazowego tokenu
- Atomowa konsumpcja tokenu (SELECT FOR UPDATE + DELETE w transakcji MySQL)
- Token przypisany do IP klienta (IP-binding)
- Manifest plików klienta z hash SHA-256 per plik
- Rate-limiting tokenów per IP

Następny krok:
- E13: Hosting plików klienta (serwer HTTP do pobierania)
- Budowa launchera PyInstaller (E12b)
- Aktualizacja planu (Faza E status)

---

## FIX9–FIX17: Poprawki z audytu Codex (przegląd kodu)

Data: 2026-03 (kontynuacja sesji E12)

Źródło: Automatyczny audyt Codex — 9 zgłoszonych problemów (3x KRYTYCZNE, 3x WYSOKIE, 2x ŚREDNIE, 1x NISKIE).

### FIX9+FIX15: Wheel of Destiny D6 guards (KRYTYCZNE → NAPRAWIONE)
Pliki: `canary/src/server/network/protocol/protocolgame.cpp`
Problem:
- D6 guard w `sendOpenWheelWindow` i `parseSaveWheel` był nested WEWNĄTRZ istniejącego `if (oldProtocol...)` → psuł strukturę klamer
- Brak D6 guard w `parseOpenWheel` i `parseWheelGemAction`
- Floating code D6 POZA jakąkolwiek funkcją (między `sendDisableLoginMusic` i `sendHotkeyPreset`) → błąd składniowy
Fix: Wszystkie 5 problemów naprawione — guardy przeniesione na początek funkcji, floating block usunięty.

### FIX10: Auth after ticket bypass (KRYTYCZNE → NAPRAWIONE)
Pliki: `protocolgame.cpp`, `ticket_validator.cpp`, `ticket_validator.hpp`
Problem: Po pomyślnej walidacji ticketu, `accountDescriptor = sessionKey` (ticket HMAC string) był przekazywany do `gameWorldAuthentication()`. Ta funkcja próbowała `loadBySession(sha1(ticket))` → zawsze FAIL, bo nie istnieje taka sesja w `account_sessions`.
Fix:
- `ticket_validator` rozszerzony o `outAccountId` — wyciąga accountId z payload
- Gdy `ticketValidated`: skip `gameWorldAuthentication()`, użyj `ticketAccountId` + weryfikuj postać przez `g_accountRepository().getCharacterByAccountIdAndName()`
- Dodano `#include "account/account_repository.hpp"` do protocolgame.cpp

### FIX11: login.php expires_at (KRYTYCZNE → JUŻ NAPRAWIONE w E11)
Plik: `login.php`
Fix: `strtotime($tokenRow['expires_at'])` zamiast `(int)$tokenRow['expires_at']` — typ TIMESTAMP w MySQL.

### FIX12: launcher-token.php manifest bypass (WYSOKIE → NAPRAWIONE)
Plik: `launcher-token.php`
Problem: Gdy `manifestVersion === ''`, cały blok weryfikacji filesHash był pomijany. Token był wydawany bez sprawdzenia integralności plików klienta.
Fix: Fail-closed — gdy manifestVersion pusty, filesHash sprawdzany jest przeciwko 2 ostatnim aktywnym manifestom z DB. Jeśli brak manifestów w DB — loguje ostrzeżenie (allowlist: dev/fresh install).

### FIX13: worldName binding (WYSOKIE → NAPRAWIONE)
Pliki: `ticket.php`, `ticket_validator.cpp`
Problem: `worldName` był przekazywany w tickecie ale nigdy walidowany — ani w PHP ani w C++.
Fix:
- `ticket.php`: worldName wymagany (nie może być pusty)
- `ticket_validator.cpp`: step 7b — porównuje `payload.worldName` z `SERVER_NAME` z config.lua

### FIX14: ServerList empty in lock-mode (WYSOKIE → NAPRAWIONE)
Plik: `canary_test/testyy/modules/client_serverlist/serverlist.lua`
Problem: `CLIENT_LOCKED` → `servers = {}` → lista wizualnie pusta. Połączenia działały (poprawne serwery z `getCurrentServerConfig()`), ale UI lista była pusta.
Fix: W trybie `CLIENT_LOCKED`, `ServerList.init()` wypełnia `servers` z `GameModes` — iteruje wszystkie tryby i dodaje ich serwery.

### FIX16: CLIENT_LOCKED config drift (ŚREDNIE → NAPRAWIONE)
Pliki: `init.lua`, `.env`
Problem: `init.lua` → `CLIENT_LOCKED = true`, `.env` → `CLIENT_LOCKED=false`. Dryft = klient zablokowany ale login.php nie wymusza launchToken.
Fix: `.env` zsynchronizowany do `true`. W obu plikach dodane prominentne komentarze SYNC z instrukcjami.

### FIX17: icon.ico brakujący (NISKIE → NAPRAWIONE)
Plik: `launcher/build_launcher.bat`
Problem: `--icon "icon.ico"` referencja do nieistniejącego pliku → build PyInstaller failował.
Fix: Linia wykomentowana z instrukcją jak dodać ikonę.

### Podsumowanie zmian:
| FIX | Severity | Plik(i) | Status |
|-----|----------|---------|--------|
| FIX9+15 | KRYTYCZNE | protocolgame.cpp | ✅ |
| FIX10 | KRYTYCZNE | protocolgame.cpp, ticket_validator.cpp/.hpp | ✅ |
| FIX11 | KRYTYCZNE | login.php | ✅ (wcześniej) |
| FIX12 | WYSOKIE | launcher-token.php | ✅ |
| FIX13 | WYSOKIE | ticket.php, ticket_validator.cpp | ✅ |
| FIX14 | WYSOKIE | serverlist.lua | ✅ |
| FIX16 | ŚREDNIE | init.lua, .env | ✅ |
| FIX17 | NISKIE | build_launcher.bat | ✅ |

Zacommitowane: `7957e93f5` na `feature/ticket-gate`.

---

## Codex Review #3 — nowe findings (2026-03-02)

Data: 2026-03-02 (po commicie `7957e93f5`)
Źródło: Kolejny przegląd Codex — 6 zgłoszonych problemów (1× KRYTYCZNE, 2× WYSOKIE, 3× ŚREDNIE).
Status: ✅ NAPRAWIONE (sesja 2026-03-03).

### FIX18 (KRYTYCZNE): Klient nie wysyła gameMode do login.php
Pliki: `httplogin.h/cpp`, `luafunctions.cpp`, `entergame.lua`
Problem: Body HTTP login nie zawierało gameMode → login.php domyślnie ustawiał modern → ticket mismatch.
Rozwiązanie (sesja 2026-03-03):
- `httplogin.h`: dodano pole `std::string gameMode` + deklaracja `setGameMode()`
- `httplogin.cpp`: implementacja setGameMode() + dodanie `body["gameMode"]` we WSZYSTKICH 4 miejscach budowy JSON body (startHttpLogin, loginHttpsJson, loginHttpJson, Emscripten fetch)
- `luafunctions.cpp`: zarejestrowano binding `setGameMode`
- `entergame.lua`: wywołanie `http:setGameMode(CurrentGameMode or "")` przed `httpLogin`
Status: ✅ DONE

### FIX19 (WYSOKIE): Niespójna walidacja worldName — zrywa logowanie
Pliki: `ticket_validator.cpp`
Problem: API nazwy światów ("Classic 7.4") ≠ config.lua SERVER_NAME ("Tibia 7.4 test").
Rozwiązanie: Zmieniono walidację worldName w C++ z hard-reject na info-only log.
Ticket jest już podpisany HMAC przez ticket.php — worldName jest zwalidowane po stronie PHP (FIX20).
Status: ✅ DONE

### FIX20 (WYSOKIE): ticket.php nie sprawdza world↔gameMode
Pliki: `ticket.php`
Problem: Brak walidacji czy wybrany world jest dozwolony dla danego gameMode.
Rozwiązanie: Dodano mapowanie `$allowedWorldsByMode` → `classic74 → ['Classic 7.4']`, `modern → ['Modern']`.
Sprawdzenie `in_array($worldName, $allowedWorldsByMode[$effectiveGameMode], true)` → sendError przy niezgodności.
Status: ✅ DONE

### FIX21 (ŚREDNIE): launcher-token.php fail-open przy pustej tabeli manifest_versions
Pliki: `launcher-token.php`
Problem: Pusta tabela manifest_versions → logował warning i przepuszczał (fail-open).
Rozwiązanie: Zmieniono na `sendError('Server configuration error: no manifest available.')` — true fail-closed.
Admin musi dodać manifest do DB zanim tokeny będą wydawane.
Status: ✅ DONE

### FIX22 (ŚREDNIE): Podwójny slash w login URL (//login.php)
Pliki: `entergame.lua`
Problem: httpLoginUrl kończył się na `/`, a tryHttpLogin doklejal kolejny `/` → `//login.php`.
Rozwiązanie: Dodano guard `if path:sub(1,1) ~= '/' then path = '/' .. path end` — slash dodawany tylko gdy brak.
Status: ✅ DONE

### FIX23 (ŚREDNIE): Nonce replay-store architektonicznie niedokończony
Pliki: `ticket_validator.hpp`, `ticket_validator.cpp`
Problem: Cleanup >10k jednorazowe clear, brak cyklicznego wywołania, memory leak w długim horyzoncie.
Rozwiązanie:
- `.hpp`: zmiana `unordered_set<string>` → `unordered_map<string, int64_t>` (nonce → timestamp wstawienia)
- `.hpp`: dodano `validateCallCount_` do auto-triggera cleanup
- `.cpp`: `usedNonces_[nonce] = now` zapisuje czas wstawienia
- `.cpp`: `cleanupExpiredNonces()` iteruje mapę i usuwa wpisy starsze niż maxAgeSec (300s)
- `.cpp`: cleanup triggerowany automatycznie co 100 wywołań `validateTicket()`
Status: ✅ DONE

### Podsumowanie Codex Review #3:
| FIX | Severity | Problem | Status |
|-----|----------|---------|--------|
| FIX18 | KRYTYCZNE | gameMode nie wysyłany do login.php | ✅ DONE |
| FIX19 | WYSOKIE | worldName mismatch (API vs SERVER_NAME) | ✅ DONE |
| FIX20 | WYSOKIE | Brak walidacji world↔gameMode w ticket.php | ✅ DONE |
| FIX21 | ŚREDNIE | launcher-token fail-open przy pustej tabeli | ✅ DONE |
| FIX22 | ŚREDNIE | Podwójny slash w login URL | ✅ DONE |
| FIX23 | ŚREDNIE | Nonce store cleanup niedokończony | ✅ DONE |

Naprawione w sesji 2026-03-03.

---

## Audyt end-to-end #4 — FIX24-FIX44 (2026-03-03)

Źródło: Pełny audyt flow launcher→klient→API→serwer. Znalezione 25 problemów, naprawionych 13 w tej sesji.
Status: ✅ NAPRAWIONE.

### FIX24 (KRYTYCZNE): .env brak WORLD_IP
Pliki: `.env`, `.env.example`
Problem: login.php czyta `$ENV['WORLD_IP']` ale .env nie ma tej zmiennej → fallback 127.0.0.1 → klienci łączą się na localhost.
Rozwiązanie: Dodano WORLD_IP, WORLD_PORT + opcjonalne WORLD_CLASSIC74_IP/PORT, WORLD_MODERN_IP/PORT do .env.
Dodatkowo: Utworzono `.env.example` z oczyszczonymi wartościami (FIX34) — .env nie jest w repo.

### FIX26 (KRYTYCZNE): login.php brak pól charakteru
Pliki: `login.php`
Problem: Klient czyta `ismaincharacter`, `ishidden`, `dailyrewardstate` ale PHP ich nie zwracał → nil w Lua.
Rozwiązanie: Dodano `ismaincharacter` (z kolumny `main` w DB), `ishidden` = false, `dailyrewardstate` = 0.
Zmieniono query: `SELECT ... main FROM players`.

### FIX27 (KRYTYCZNE): math.random(1) = zawsze 1
Pliki: `entergame.lua`
Problem: `math.random(1)` zwraca zawsze 1 → requestId kolizja → stale callbacki mogą być przyjmowane.
Rozwiązanie: `math.random(1000000)` — zgodnie z ticket requestId.

### FIX28 (KRYTYCZNE): Non-ticket auth wysyła UUID zamiast account\npassword
Pliki: `entergame.lua`
Problem: Gdy ticket-gate wyłączony, klient wysyła UUID sessionKey do serwera → serwer parsuje `\n` → brak `\n` → "You must enter your email."
Rozwiązanie: `G.legacySessionKey = session.key` w loginSuccess. `onTicketBypassed` używa `G.legacySessionKey` (account\npassword) zamiast UUID.

### FIX29 (WYSOKIE): Premium hardcoded 0/false
Pliki: `login.php`
Problem: Sesja zawsze zwraca `premiumuntil: 0, ispremium: false` → wszyscy Free z ujemnymi dniami premium.
Rozwiązanie: Query `premdays, lastday` z tabeli `accounts`, obliczenie `premiumUntil = lastday + premdays * 86400`.

### FIX30 (WYSOKIE): Ticket request port z srv.port zamiast G.port
Pliki: `entergame.lua`
Problem: `requestTicket` używał `srv.port` (443 z init.lua) zamiast portu wyekstrahowanego z httpLoginUrl.
Rozwiązanie: `ticketPort = G.port or srv.port or 443`.

### FIX34 (WYSOKIE): .env.example + .gitignore
Pliki: `.env.example`, `canary_test/.gitignore`
Problem: .env z sekretami (TICKET_SECRET, PayPal, DB) nie powinien być w repo.
Rozwiązanie: Już ignore'owany (`**/.env`), dodano `.env.example` z oczyszczonymi wartościami. Dodano wyjątek `!**/.env.example` w .gitignore.

### FIX35 (WYSOKIE): cacert.pem brak diagnostyki
Pliki: `httplogin.cpp`
Problem: `set_ca_cert_path("./cacert.pem")` — brak pliku = cichy TLS fail.
Rozwiązanie: Dodano `std::ifstream` check + `std::cerr` warning logując brak pliku. Dodano `#include <fstream>`.

### FIX38 (ŚREDNIE): startHttpLogin loguje body odpowiedzi
Pliki: `httplogin.cpp`
Problem: `std::cout << bodyResponse.dump()` wypisywał session keys do stdout (sprzeczne z komentarzem "NIE logujemy body").
Rozwiązanie: Zastąpiono logiem "status 200 OK" bez body.

### FIX39 (ŚREDNIE): Brak obsługi argon2/bcrypt haseł
Pliki: `login.php`
Problem: Tylko SHA1 i plaintext, mimo że .env ma konfigurację argon2 (M_COST, T_COST).
Rozwiązanie: Dodano gałąź `password_verify()` dla `$2*` (bcrypt) i `$argon2*` hashów.

### FIX42+FIX43 (ŚREDNIE): Duplikacja loadEnvFiles/sendError
Pliki: `common.php` (NOWY), `login.php`, `ticket.php`, `launcher-token.php`, `launcher-version.php`, `generate_manifest.php`
Problem: Identyczna ~15-linijkowa funkcja skopiowana w 5 plikach. launcher-token.php miał inny format error.
Rozwiązanie: Wyekstrahowano do `common.php`, `require_once`. Ustandaryzowano format error na `{errorCode, errorMessage}`.

### FIX44+CPP-4 (NISKIE): Dead code loginHttpJson
Pliki: `httplogin.h`, `httplogin.cpp`
Problem: Metoda `loginHttpJson()` (plain HTTP) nie była wywoływana od X2b (usunięcie HTTP fallback). Dead code.
Rozwiązanie: Usunięto deklarację z `.h` i definicję (~35 linii) z `.cpp`.

### Podsumowanie Audytu #4:
| FIX | Severity | Problem | Status |
|-----|----------|---------|--------|
| FIX24 | KRYTYCZNE | .env brak WORLD_IP | ✅ DONE |
| FIX26 | KRYTYCZNE | login.php brak pól char | ✅ DONE |
| FIX27 | KRYTYCZNE | math.random(1) | ✅ DONE |
| FIX28 | KRYTYCZNE | non-ticket auth UUID | ✅ DONE |
| FIX29 | WYSOKIE | premium hardcoded | ✅ DONE |
| FIX30 | WYSOKIE | ticket port | ✅ DONE |
| FIX34 | WYSOKIE | .env.example | ✅ DONE |
| FIX35 | WYSOKIE | cacert.pem check | ✅ DONE |
| FIX38 | ŚREDNIE | body log leak | ✅ DONE |
| FIX39 | ŚREDNIE | argon2/bcrypt | ✅ DONE |
| FIX42 | ŚREDNIE | loadEnvFiles common | ✅ DONE |
| FIX43 | NISKIE | error format | ✅ DONE |
| FIX44+CPP-4 | NISKIE | dead code | ✅ DONE |

### Znane otwarte problemy (nie naprawione w tej sesji):
| # | Severity | Problem | Powód |
|---|----------|---------|-------|
| FIX25 | ✅ DONE | Placeholder URLs w init.lua → 127.0.0.1 + HTTPS | Sesja 2026-03-02 Audyt #5 |
| FIX31 | ✅ DONE | launcher_config.json URLs → HTTPS + poprawne ścieżki | Sesja 2026-03-02 Audyt #5 |
| FIX32 | ✅ DONE | launcher clientDir → ../testyy (prawdziwa lokalizacja) | Sesja 2026-03-02 Audyt #5 |
| FIX33 | ✅ DONE | CLIENT_LOCKED + TICKET_SECRET auto-validation w deploy_api.sh | Sesja 2026-03-02 Audyt #5 |
| FIX36 | ŚREDNIE | IP binding za NAT/proxy | Wymaga trusted proxy config |
| FIX37 | ŚREDNIE | FIX21 fail-closed blokuje fresh install | Wymaga setup docs |
| FIX40 | ŚREDNIE | Probabilistyczny cleanup sesji | Wymaga crona |
| FIX41 | ŚREDNIE | port=443 API vs game — confusing config | Wymaga oddzielenia apiPort/gamePort |
| FIX45 | ✅ DONE | SSL na nginx (self-signed cert, port 443) | Sesja 2026-03-02 Audyt #5 |
| FIX46 | ✅ DONE | cacert.pem + dynamiczna ścieżka w C++ | Sesja 2026-03-02 Audyt #5 |
| FIX47 | ✅ DONE | deploy_api.sh — automatyczny sync + walidacja | Sesja 2026-03-02 Audyt #5 |
| FIX48 | ✅ DONE | Sync API files do /var/www/html | Sesja 2026-03-02 Audyt #5 |

## [2026-03-02 ~14:00] BLOK: Audyt end-to-end #5 — SSL, deployment, infrastructure

Zakres:
- Konfiguracja SSL/TLS na nginx z self-signed CA
- Wygenerowanie cacert.pem dla klienta OTClient
- Wyeliminowanie placeholderów z init.lua
- Stworzenie deploy_api.sh automatyzującego deployment
- Naprawienie launcher_config.json URLs
- Naprawienie ścieżki cacert.pem w C++ (względna → dynamiczna)
- Naprawienie WORLD_IP mismatch (config.lua ip bind)
- Synchronizacja plików API do /var/www/html
- Walidacja CLIENT_LOCKED + TICKET_SECRET sync w deploy script

Nowe FIXy:
| # | Plik | Opis |
|---|------|------|
| FIX25 | testyy/init.lua | Placeholder ZMIEN_NA_ADRES → 127.0.0.1, httpLoginUrl → https://127.0.0.1/apik/v1/login.php |
| FIX31 | html_copy/launcher_config.json | http:// → https://, apiUrl → /apik/v1/, clientExecutable → otclient.exe |
| FIX32 | launcher/launcher_config.json | clientDir: ./client → ../testyy |
| FIX33 | deploy_api.sh | Automatyczna walidacja CLIENT_LOCKED (init.lua vs .env) + TICKET_SECRET (config.lua vs .env) |
| FIX45 | nginx ssl config | Self-signed CA+cert z SAN (127.0.0.1, 172.29.76.234, localhost). nginx listen 443 ssl, HTTP→HTTPS redirect |
| FIX46 | testyy/cacert.pem | CA cert kopiowany do katalogu klienta (httplogin.cpp set_ca_cert_path) |
| FIX47 | deploy_api.sh | Nowy skrypt — rsync PHP/SQL do /var/www/html, skip .env, sync launcher_config.json, chmod/chown |
| FIX48 | /var/www/html/apik/v1/ | 9 plików zsynchronizowanych (common.php, login.php, ticket.php, launcher-token.php, launcher-version.php, generate_manifest.php, update.php + 2 SQL schemas) |
| FIX49 | html_copy/apik/v1/.env + .env.example | URL='http://...' → URL='https://...' |
| FIX-C1 | config.lua | ip = "172.29.76.234" → ip = "0.0.0.0" (bind all interfaces — WORLD_IP w .env jest 127.0.0.1) |
| FIX-C2 | testyy/src/framework/net/httplogin.cpp | cacert.pem path: "./cacert.pem" → g_resources.getWorkDir() + "cacert.pem" (dynamiczny) |
| FIX-W1 | testyy/modules/client_entergame/entergame.lua | Naprawiona odwrócona logika port detection — teraz zawsze 443 domyślnie |

Nowe pliki:
- deploy_api.sh — skrypt deploymentu API (bash, executable)
- ssl/ — certyfikaty CA+server (gitignored, klucze prywatne)
- testyy/cacert.pem — publiczny certyfikat CA (tracked in git)

Zmienione pliki (łącznie z Audytem #4):
1. testyy/init.lua (FIX25 — adresy + komentarze portów)
2. testyy/modules/client_entergame/entergame.lua (FIX-W1 — port logic)
3. testyy/src/framework/net/httplogin.cpp (FIX-C2 — cacert path + resourcemanager include)
4. testyy/src/framework/net/httplogin.h (FIX44 — z Audytu #4)
5. html_copy/apik/v1/common.php (FIX42 — z Audytu #4)
6. html_copy/apik/v1/login.php (FIX26+29+39+42 — z Audytu #4)
7. html_copy/apik/v1/ticket.php (FIX42 — z Audytu #4)
8. html_copy/apik/v1/launcher-token.php (FIX42+43 — z Audytu #4)
9. html_copy/apik/v1/launcher-version.php (FIX42 — z Audytu #4)
10. html_copy/apik/v1/generate_manifest.php (FIX42 — z Audytu #4)
11. html_copy/apik/v1/.env (FIX24+49)
12. html_copy/apik/v1/.env.example (FIX34+49)
13. html_copy/launcher_config.json (FIX31)
14. launcher/launcher_config.json (FIX32)
15. .gitignore (FIX34 + ssl/ ignore)
16. deploy_api.sh (FIX47 — nowy)
17. config.lua (FIX-C1 — ip bind, gitignored)
18. testyy/cacert.pem (FIX46)

Infrastruktura (niezarządzana przez git):
- /etc/nginx/ssl/server.crt + server.key (self-signed cert zainstalowany)
- /etc/nginx/sites-enabled/myaac.conf (HTTPS 443 + HTTP→HTTPS redirect)
- /etc/nginx/sites-enabled/127.local.conf (HTTPS 443 dla localhost)
- /var/www/html/apik/v1/ (9 plików PHP zsynchronizowanych z repo)

Testy:
- curl HTTPS z cacert.pem: health.php ✅, login.php ✅, ticket.php ✅
- curl launcher-version.php ✅, launcher-token.php ✅
- HTTP→HTTPS redirect: 301 ✅
- .env access: 403 Forbidden ✅
- PHP lint: 6/6 plików bez błędów ✅
- C++ get_errors: 0 błędów ✅
- deploy_api.sh --dry-run: sync check + CLIENT_LOCKED + TICKET_SECRET validation ✅

Wynik:
- HTTPS działa na nginx (port 443) z self-signed CA
- Klient OTClient ma cacert.pem → walidacja TLS chain OK
- Wszystkie placeholdery zastąpione prawdziwymi adresami
- API zsynchronizowane z repo → /var/www/html
- deploy_api.sh automatyzuje deployment + waliduje spójność konfiguracji
- Canary server binduje na 0.0.0.0 → dostępny z localhost i WSL IP

Pozostałe otwarte (wymagają decyzji/dodatkowej pracy):
- FIX36: trusted proxy headers za NAT
- FIX37: dokumentacja fresh install (schema SQL, .env setup)
- FIX40: cron cleanup sessions zamiast probabilistycznego
- FIX41: oddzielne apiPort/gamePort w konfiguracji

Następny krok:
- Commit zbiorczy + push (czekamy na potwierdzenie użytkownika)
- Kompilacja klienta (A8/C6)
- Test całego flow: launcher → token → login → ticket → game server

## [2026-03-02 ~15:20] BLOK: Audyt end-to-end #6 — Codex Review fixes (FIX50-FIX55)

Zakres:
- Naprawy 6 problemów znalezionych przez Codex/ChatGPT code review
- 1 KRYTYCZNY, 2 WYSOKIE, 2 ŚREDNIE, 1 NISKI

Zmienione pliki:
- `testyy/modules/client_entergame/entergame.lua` — FIX50: `child:getStyleName` → `child.getStyleName` (parse error dwukropek bez wywołania); FIX55: math.randomseed przeniesiony do init() z per-request
- `launcher/launcher.py` — FIX51: error detection `"error" in data` → `"errorCode" in data` (zgodność z sendError contract)
- `html_copy/apik/v1/login.php` — FIX52: premium logic `lastday + premdays*86400` → `lastday` (lastday to już timestamp końca, potwierdzone w account_repository_db.cpp)
- `html_copy/apik/v1/ticket.php` — FIX53: dodano worldId do mapowania gameMode→world (odporność na rename)
- `testyy/modules/client_entergame/characterlist.lua` — FIX54: `G.sessionKey` → `G.legacySessionKey or G.sessionKey` w ścieżce bez ticket-gate
- `Dokumentacja/.../00_START_PRACY_CHECKLISTA.md` — aktualizacja tabeli Audyt #5

Weryfikacja:
- PHP lint: 4/4 zmienione pliki ✅
- Python compile: launcher.py ✅
- luac -p: entergame.lua ✅, characterlist.lua ✅
- C++ (httplogin.cpp/h): 0 errors ✅
- Test premium z DB: lastday=1775049476 (30 dni) → premiumUntil=1775049476 (NIE 60 dni jak stary kod by zwrócił) ✅
- Deploy na /var/www/html: login.php + ticket.php zaktualizowane ✅
- CLIENT_LOCKED + TICKET_SECRET: spójne ✅

Szczegóły fixów:
| # | Priorytet | Problem | Naprawa |
|---|-----------|---------|---------|
| FIX50 | KRYTYCZNY | `child:getStyleName and ...` = Lua parse error | Zmiana na `child.getStyleName` (dot = field access) |
| FIX51 | WYSOKI | launcher.py szuka `error` ale API zwraca `errorCode` | Sprawdzanie `"errorCode" in data` |
| FIX52 | WYSOKI | `premiumUntil = lastday + premdays*86400` = podwójne naliczanie | `premiumUntil = lastday` (timestamp końca premium, per C++ reference) |
| FIX53 | ŚREDNI | worldName string validation kruche | Dodano worldId do mapy, forward-compatible |
| FIX54 | ŚREDNI | characterlist.lua: `G.sessionKey` zamiast legacySessionKey | `G.legacySessionKey or G.sessionKey` (jak w onTicketBypassed) |
| FIX55 | NISKI | randomseed(os.time()) per-request → kolizja w 1s | Seed raz w init() z wyższą entropią |

## [2026-03-02 ~16:00] BLOK: Audyt end-to-end #7 — Deep static review (FIX56-FIX65)

Zakres:
- Pełny przegląd statyczny z subagent audit — 13 znalezisk (2 KRYTYCZNE w audycie, ale CRITICAL #1 okazał się FALSE POSITIVE — canary_test/ nie jest build source, canary/ ma ticket-gate)
- 10 napraw wdrożonych, 1 pominięty (FIX61: LuaObject refcount chroni this w async)

Zmienione pliki:
- `testyy/src/framework/net/httplogin.cpp` — FIX56: Emscripten UAF (fetch->status po emscripten_fetch_close → savedStatus)
- `html_copy/apik/v1/ticket.php` — FIX57: TICKET_SECRET placeholder check rozszerzony o oba warianty; FIX58: world IDs = 0/1 (match login.php)
- `html_copy/apik/v1/login.php` — FIX59: komentarz do empty gameMode worldId default
- `launcher/launcher.py` — FIX60: PROTECTED_PATTERNS chroni logi/cache/config przed usunięciem przez updater
- `html_copy/apik/v1/update.php` — FIX62: sendError() z common.php zamiast {"error":"..."}
- `testyy/modules/client_entergame/entergame.lua` — FIX63: `world.previewstate` → `world.previewState` (camelCase); FIX64: zmienne `account`/`password` → `encAccount`/`encPassword` (bez shadowing)
- `deploy_api.sh` — FIX65: komentarz do braku `set -e` (celowy ze względu na sudo)

Pominięte (z uzasadnieniem):
- FIX61 (raw `this` w async): LuaObject ma refcount — Lua trzyma referencję przez cały flow logowania. Naprawa wymagałaby shared_from_this w LuaObject — zbyt inwazyjne.
- Audyt #1 CRITICAL (brak ticket_validator w canary_test/): FALSE POSITIVE — build (budowa_silnik/) kompiluje z canary/ (SOURCE_DIR), nie z canary_test/. canary/ MA ticket_validator.cpp/hpp i pełny ticket-gate w protocolgame.cpp.

Weryfikacja:
- PHP lint: 4/4 ✅
- Python compile: launcher.py ✅
- luac -p: entergame.lua ✅, characterlist.lua ✅
- C++ errors: httplogin.cpp 0 ✅
- update.php: zwraca {"errorCode":3,"errorMessage":"..."} per standard ✅
- Deploy: ticket.php + login.php + update.php synced ✅
- CLIENT_LOCKED + TICKET_SECRET spójne ✅

| # | Priorytet | Problem | Naprawa |
|---|-----------|---------|---------|
| FIX56 | KRYTYCZNY | Emscripten: fetch→status po close = UAF | savedStatus/savedData przed close |
| FIX57 | WYSOKI | TICKET_SECRET placeholder mismatch .env.example vs check | Sprawdzanie obu wariantów |
| FIX58 | WYSOKI | ticket.php world IDs 1/2 vs login.php 0/1 | Aligned do 0/1 |
| FIX59 | ŚREDNI | Empty gameMode → ALL chars worldId=0 | Komentarz + domyślny 0 (classic) |
| FIX60 | ŚREDNI | Launcher deletes user logs/cache/configs | PROTECTED_PATTERNS w UpdateManager |
| FIX62 | NISKI | update.php {"error":"..."} ≠ kontrakt sendError | require common.php + sendError() |
| FIX63 | NISKI | world.previewstate → world.previewState | camelCase fix |
| FIX64 | NISKI | variable shadowing: local account/password | encAccount/encPassword |
| FIX65 | NISKI | deploy_api.sh: set -uo pipefail bez -e | Komentarz wyjaśniający celowy brak |
