# Audyt prac Copilot + Claude (tylko review, bez poprawek)

Data startu audytu: 2026-03-02  
Tryb pracy: tylko wykrywanie bledow i ryzyk, bez wdrazania fixow.

## Zasady tego pliku

1. Nie naprawiamy kodu w tym etapie.
2. Kazde znalezisko ma priorytet i status.
3. Statusy:
   - OPEN: blad potwierdzony, czeka na decyzje/fix
   - NEEDS_VERIFY: wymaga dodatkowej weryfikacji runtime/build
   - FALSE_POSITIVE: odrzucone po weryfikacji

## Znalezione problemy

### 2026-03-02 - Runda #1

1. [KRYTYCZNE] canary_test: uszkodzone wstrzykniecia guardow w `protocolgame.cpp`  
Status: ✅ FIXED (commit `dfe1a8784` — GUARD-FIX: guardy D2-D7 naprawione, zmienne poprawione, osierocony kod usunięty)  
Plik: `canary_test/src/server/network/protocol/protocolgame.cpp`  
Opis:
   - W wielu miejscach guardy D2-D10 sa wstawione w niepoprawnych blokach kodu.
   - Sa odwolania do niezdefiniowanych zmiennych lokalnych.
   - Co najmniej kilka fragmentow jest logicznie lub skladniowo niepoprawnych dla C++.
Dowody (linie orientacyjne):
   - `:1992`, `:1993`, `:2013`, `:1606`, `:2593`, `:3332`, `:3409`
Ryzyko:
   - Potencjalna niemoznosc kompilacji i/lub nieprzewidywalne zachowanie blokad Classic 7.4.

2. [KRYTYCZNE] D2 blokada run: bledne zmienne w parserach use-item  
Status: ✅ FIXED (commit `dfe1a8784` — D2: parseUseItem guard usunięty, parseUseItemEx `itemId`→`fromItemId`, parseUseWithCreature guard dodany)  
Plik: `canary_test/src/server/network/protocol/protocolgame.cpp`  
Opis:
   - `parseUseItem`: uzywa `fromPos` i `fromItemId`, ktore nie sa zdefiniowane.
   - `parseUseItemEx`: sprawdza rune przez `itemId`, ale parser czyta `fromItemId`.
Dowody:
   - `:1992`, `:1993`, `:2013`
Ryzyko:
   - Blokada run moze nie dzialac albo kod nie przejdzie builda.

3. [WYSOKIE] D5/D4 guardy poza docelowymi metodami  
Status: ✅ FIXED (commit `dfe1a8784` — D5: guard przeniesiony z pętli bestiary do parsePreyAction; D4: osierocony guard usunięty, dodany do parseMarketLeave)  
Plik: `canary_test/src/server/network/protocol/protocolgame.cpp`  
Opis:
   - Guard Prey pojawia sie w petli `parseBestiarySendCreatures` zamiast na wejsciu `parsePreyAction`.
   - Guard Market wystepuje jako "osierocony" kod poza metoda.
Dowody:
   - `:3332` (w petli bestiary), `:3409` (poza metoda)
Ryzyko:
   - Niepelna ochrona Classic 7.4 i trudne do przewidzenia side-effecty.

4. [WYSOKIE] Braki guardow Classic 7.4 na niektorych wejsciach  
Status: ✅ FIXED (commit `dfe1a8784` — dodane guardy: parseUseWithCreature, parseQuickLoot, parsePreyAction, parseMarketLeave)  
Plik: `canary_test/src/server/network/protocol/protocolgame.cpp`  
Opis:
   - Brak blokady na wejsciu `parseUseWithCreature`.
   - Brak blokady na wejsciu `parseQuickLoot`.
   - Brak blokady na wejsciu `parsePreyAction`.
   - Brak blokady w `parseMarketLeave`.
Dowody:
   - `parseUseWithCreature` okolice `:2026`
   - `parseQuickLoot` okolice `:2088`
   - `parsePreyAction` okolice `:3389`
   - `parseMarketLeave` okolice `:3466`
Ryzyko:
   - Klient Classic 7.4 moze obchodzic czesc ograniczen przez pakiety.

5. [WYSOKIE] `launcher-token.php`: mozliwy fail-open przy nieznanej `manifestVersion`  
Status: FIXED (FIX-AUD5: fail-closed + error_log gdy manifestVersion nie istnieje w DB)  
Plik: `canary_test/html_copy/apik/v1/launcher-token.php`  
Opis:
   - Dla podanej `manifestVersion` zapytanie, ktore nie znajduje wpisu w `manifest_versions`,
     nie jest twardo odrzucane w galezi `manifestVersion !== ''`.
Dowody:
   - Logika od `:109`, warunek `num_rows > 0` przy `:118`, brak `else` fail-closed do `:142`
Ryzyko:
   - Oslabiona walidacja integralnosci klienta.

6. [SREDNIE] Login token flow nie wykorzystuje `manifest_version` z rekordu tokena  
Status: ✅ FIXED (FIX-AUD6: SELECT pobiera manifest_version, walidacja vs REQUIRED_MANIFEST_VERSION z .env)  
Plik: `canary_test/html_copy/apik/v1/login.php`  
Opis:
   - Konsumpcja launch tokena pobiera `files_hash`, ale nie korzysta z `manifest_version`
     do walidacji zgodnej z rollout/grace.
Dowody:
   - SELECT i walidacja w okolicy `:169` i `:201`
Ryzyko:
   - Gorsza odpornosc na race condition podczas rolloutow wersji.

7. [SREDNIE] UI ServerList lock-mode: kluczowanie po samym `host`  
Status: OPEN  
Plik: `canary_test/testyy/modules/client_serverlist/serverlist.lua`  
Opis:
   - `servers[host] = ...` nadpisuje wpisy, gdy sa rozne serwery o tym samym hoscie.
Dowody:
   - `:26`
Ryzyko:
   - Utrata pozycji na liscie serwerow w lock-mode.

### 2026-03-02 - Runda #2

8. [WYSOKIE] D3 guardy sa przesuniete na niepoprawne parsery  
Status: ✅ FIXED (commit `dfe1a8784` — D3: guardy usunięte z parseUpdateContainer/parseLookAt, dodane do parseQuickLoot/parseLootContainer)  
Plik: `canary_test/src/server/network/protocol/protocolgame.cpp`  
Opis:
   - W `canary_test` guard "Quick Loot" zostal dodany do `parseUpdateContainer`.
   - W `canary_test` guard "Auto Loot" zostal dodany do `parseLookAt`.
   - Jednoczesnie brak/rozjazd guardow na parserach, gdzie sa w kodzie referencyjnym `canary/`.
Dowody:
   - `canary_test`: `:2045`, `:2074`
   - `canary`: `parseUpdateContainer` bez guarda (`:1946`), `parseLookAt` bez guarda (`:1968`)
Ryzyko:
   - Nadmiarowe blokowanie legalnych akcji i jednoczesnie niedostateczna blokada docelowych flow.

9. [WYSOKIE] Ticket request: parsowanie hosta moze zwrocic `host:port` jako host  
Status: FIXED (FIX-AUD9: regex [^/:] rozdziela host i port w entergame.lua)  
Pliki:
   - `canary_test/testyy/modules/client_entergame/entergame.lua`
   - `canary_test/testyy/src/framework/net/httplogin.cpp`
Opis:
   - `urlHost` jest wyciagany regexem `https?://([^/]+)`, co przy URL z portem zwraca np. `example.com:8443`.
   - Ten string jest przekazywany jako host do `httplib::SSLClient(host, port)`.
Dowody:
   - `entergame.lua:858`
   - `httplogin.cpp:293`
Ryzyko:
   - Ticket flow moze failowac dla konfiguracji API na niestandardowym porcie.

10. [SREDNIE] Ticket nie jest twardo zbindowany do konkretnego swiata po stronie Canary  
Status: ✅ FIXED (commit `dfe1a8784` — CFG-KEY: WORLD_ID w config + ticket_validator.cpp sprawdza worldId z payloadu vs config; ticket.php nadal waliduje worldName)  
Pliki:
   - `canary_test/html_copy/apik/v1/ticket.php`
   - `canary_test/src/server/network/protocol/ticket_validator.cpp`
Opis:
   - API waliduje `worldName` po mapie nazw, ale payload nie niesie twardego `worldId` i Canary traktuje worldName tylko informacyjnie.
   - Canary nie odrzuca ticketu przy world mismatch.
Dowody:
   - `ticket.php:121-129`, `ticket.php:156-160`
   - `ticket_validator.cpp:143-150`
Ryzyko:
   - W architekturze multi-world (zwlaszcza wiele worldow na tym samym gameMode) mozliwy rozjazd autoryzacji world-specific.

11. [SREDNIE] Replay protection nonce opiera sie tylko o pamiec procesu  
Status: OPEN  
Pliki:
   - `canary_test/src/server/network/protocol/ticket_validator.hpp`
   - `canary_test/src/server/network/protocol/ticket_validator.cpp`
   - `canary_test/html_copy/apik/v1/ticket.php`
Opis:
   - Uzyte nonce sa trzymane w `unordered_map` in-memory.
   - `ticket.php` zapisuje nonce do DB, ale Canary nie konsumuje nonce z DB podczas walidacji.
Dowody:
   - `ticket_validator.hpp:63-67`
   - `ticket_validator.cpp:123-131`
   - `ticket.php:174-179`
Ryzyko:
   - Po restarcie procesu lub przy wielu instancjach serwera ochrona replay nie jest globalnie spojna.

12. [SREDNIE] IP-binding launch tokena nadal opiera sie o `REMOTE_ADDR` bez trusted proxy policy  
Status: OPEN  
Pliki:
   - `canary_test/html_copy/apik/v1/launcher-token.php`
   - `canary_test/html_copy/apik/v1/login.php`
Opis:
   - Wydawanie i konsumpcja tokena bazuja na `REMOTE_ADDR`.
   - Brak produkcyjnej obslugi trusted proxy moze oslabic lub zlamac IP-binding za reverse proxy/CDN.
Dowody:
   - `launcher-token.php:36-39`
   - `login.php:162`
Ryzyko:
   - False reject albo brak realnego zwiazania tokena z klientem w topologii proxy.

### 2026-03-02 - Runda #3

13. [WYSOKIE] `launcher-token.php`: walidacja hashy nie jest jednoznaczna per kanal  
Status: FIXED (FIX-AUD13: query uwzglednia channel z requesta, grace period tez filtruje po channel)  
Pliki:
   - `canary_test/html_copy/apik/v1/launcher-token.php`
   - `canary_test/html_copy/apik/v1/schema_launcher.sql`
Opis:
   - Zapytanie po `manifestVersion` szuka tylko po `version`, bez `channel`.
   - Fallback/grace jest hardcoded do `channel='stable'`.
   - Schema ma unikalnosc `(version, channel)`, wiec sama `version` nie identyfikuje manifestu.
Dowody:
   - `launcher-token.php:111-113`, `launcher-token.php:124`, `launcher-token.php:146`
   - `schema_launcher.sql:30`
Ryzyko:
   - Przy wielu kanalach (np. `stable`/`beta`) mozliwa walidacja przeciwko zlemu manifestowi
     (false reject albo niezamierzona akceptacja).

14. [WYSOKIE] Niespojny format `launcher_config.json` miedzy dystrybucja a `launcher.py`  
Status: FIXED (FIX-AUD14: klucze zmienione na apiBaseUrl/filesBaseUrl/clientDir/clientExe/updateChannel)  
Pliki:
   - `canary_test/html_copy/launcher_config.json`
   - `canary_test/launcher/launcher.py`
   - `canary_test/deploy_api.sh`
Opis:
   - `launcher.py` wymaga kluczy `apiBaseUrl`, `filesBaseUrl`, `clientDir`, `clientExe`.
   - Dystrybuowany plik `html_copy/launcher_config.json` ma inny schemat (`apiUrl`, `clientFolder`, `clientExecutable`).
   - Skrypt deploy synchronizuje wlasnie ten niespojny plik.
Dowody:
   - `launcher.py:123-126`, `launcher.py:200`, `launcher.py:526-529`
   - `html_copy/launcher_config.json:2-13`
   - `deploy_api.sh:89-98`
Ryzyko:
   - Wysokie ryzyko runtime crash/KeyError launchera po podmianie configu z tej paczki.

15. [WYSOKIE] Ticket flow UI: mozliwy race/stale loadbox przy bledzie konfiguracji ticketu  
Status: FIXED (FIX-AUD15: loadBox tworzony PRZED requestTicket w characterlist.lua)  
Pliki:
   - `canary_test/testyy/modules/client_entergame/characterlist.lua`
   - `canary_test/testyy/modules/client_entergame/entergame.lua`
Opis:
   - `tryLogin()` najpierw wywoluje `EnterGame.requestTicket(charInfo)`, a dopiero potem tworzy `loadBox`.
   - Gdy `requestTicket()` failuje synchronicznie (np. zly URL/brak configu), `onTicketConfigError()`
     probuje niszczyc `loadBox`, ktory jeszcze nie istnieje; po powrocie `tryLogin()` i tak tworzy nowy `loadBox`.
Dowody:
   - `characterlist.lua:62-74`
   - `entergame.lua:849-855`, `entergame.lua:857-864`, `entergame.lua:955-970`
Ryzyko:
   - Zawieszony loader / niespojny UX i trudna diagnostyka bledu loginu.

16. [SREDNIE] `login.php`: niespojne mapowanie worldow gdy `gameMode` jest puste  
Status: OPEN  
Plik: `canary_test/html_copy/apik/v1/login.php`  
Opis:
   - Dla pustego `gameMode` endpoint zwraca 2 swiaty (classic+modern), ale kazdej postaci przypisuje `worldid=0`.
   - W praktyce klient mapuje wszystkie postacie na jeden swiat.
Dowody:
   - `login.php:69-74`, `login.php:232-237`, `login.php:257-258`
Ryzyko:
   - Stary/non-locked flow moze dzialac nieprzewidywalnie (zwlaszcza przy probie wejscia na Modern).

17. [SREDNIE] `ticket.php`: nieznany `gameMode` jest fail-open  
Status: FIXED (FIX-AUD17: fail-closed — sendError zamiast log warning)  
Plik: `canary_test/html_copy/apik/v1/ticket.php`  
Opis:
   - Dla nieznanego `gameMode` endpoint tylko loguje warning i pomija walidacje worlda.
   - Dla security endpointu powinno byc fail-closed.
Dowody:
   - `ticket.php:131-134`
Ryzyko:
   - Przy uszkodzonych danych sesji / dryfcie konfiguracji mozliwa akceptacja ticketu bez
     wymaganej walidacji world<->mode.

18. [SREDNIE] API ma fail-open fallback do twardych danych DB zamiast hard fail bez `.env`  
Status: FIXED (FIX-AUD18: requireDbConfig() w common.php + usuniety fallback ptaku/12345678 z login/ticket/launcher-token/generate_manifest)  
Pliki:
   - `canary_test/html_copy/apik/v1/login.php`
   - `canary_test/html_copy/apik/v1/ticket.php`
   - `canary_test/html_copy/apik/v1/launcher-token.php`
   - `canary_test/html_copy/apik/v1/generate_manifest.php`
Opis:
   - Brak `.env` nie zatrzymuje endpointow; kod probuje laczyc sie przez fallback user/pass.
   - Dla warstwy auth lepszy jest fail-closed z jednoznacznym komunikatem konfiguracyjnym.
Dowody:
   - `login.php:106-108`
   - `ticket.php:56-58`
   - `launcher-token.php:79-81`
   - `generate_manifest.php:153-155`
Ryzyko:
   - Trudniejsze wykrycie blednej konfiguracji i potencjalnie niezamierzone polaczenie z DB.

19. [SREDNIE] `deploy_api.sh` moze raportowac sukces mimo bledow kopiowania  
Status: FIXED (FIX-AUD19: zmienna ERRORS + sprawdzanie kodow wyjscia cp/mkdir + exit 1 przy bledach)  
Plik: `canary_test/deploy_api.sh`  
Opis:
   - Skrypt celowo nie uzywa `set -e`, ale jednoczesnie nie sprawdza kodow wyjscia po krytycznych `cp/mkdir`.
   - Dodatkowo kopiuje `${REPO_API}/.env`, ktory nie jest wersjonowany.
Dowody:
   - `deploy_api.sh:16-18`, `deploy_api.sh:36`, `deploy_api.sh:48`, `deploy_api.sh:57`, `deploy_api.sh:71`, `deploy_api.sh:81`, `deploy_api.sh:109`
Ryzyko:
   - "Green deploy" przy niepelnym wdrozeniu i dryf produkcji vs repo.

20. [SREDNIE] Konfiguracja ticket-gate w serwerze jest niepelna wzgledem planu (brak `worldId`/`ticketMaxAge`/`ticketClockTolerance`)  
Status: ✅ FIXED (commit `dfe1a8784` — CFG-KEY: dodano TICKET_MAX_AGE, TICKET_CLOCK_TOLERANCE, WORLD_ID do config_enums.hpp + configmanager.cpp + config.lua.dist; ticket_validator.cpp używa nowych kluczy)  
Pliki:
   - `canary_test/config.lua.dist`
   - `canary_test/src/config/configmanager.cpp`
   - `canary_test/src/config/config_enums.hpp`
Opis:
   - W canary_test zarejestrowano tylko `ticketGateEnabled` i `ticketSecret`.
   - Brak dedykowanych kluczy polityki serwera dla world binding i clock drift/age.
Dowody:
   - `config.lua.dist:465-470`
   - `configmanager.cpp:51`, `configmanager.cpp:68`
   - `config_enums.hpp:299-300`
Ryzyko:
   - Czesciowa utrata niezaleznej kontroli po stronie Canary i wieksze uzaleznienie od walidacji API.

## Weryfikacje wykonane w rundzie

1. PHP lint:
   - `login.php`, `ticket.php`, `launcher-token.php`, `common.php`, `update.php`, `launcher-version.php` -> OK
2. Lua parse:
   - `entergame.lua`, `characterlist.lua`, `serverlist.lua` -> OK
3. Python compile:
   - `launcher.py` -> OK
4. Build C++:
   - Konfiguracja CMake przerwana przez brak pakietu CURL w srodowisku lokalnym.
   - Status: NEEDS_VERIFY po instalacji zaleznosci build.
5. Diff referencyjny `canary/` vs `canary_test/` (ProtocolGame):
   - Potwierdzony rozjazd lokalizacji guardow D3/D4/D5/D7.
6. Przeglad flow ticket request:
   - Potwierdzone ryzyko parsowania hosta z portem (`entergame.lua` -> `httplib::SSLClient`).
7. Pelny przeglad plikow portu `98964825b` w `canary_test`:
   - API (`login.php`, `ticket.php`, `launcher-token.php`, `update.php`, `generate_manifest.php`, schemy SQL),
     launcher (`launcher.py`, `launcher_config.json`), klient Lua/C++ i konfiguracje deploy.
8. Kontrola spojnosci launcher config:
   - Potwierdzony rozjazd schematu miedzy `html_copy/launcher_config.json` a wymaganiami `launcher.py`.

## Kolejne kroki audytu (bez fixow)

1. Potwierdzic bledy C++ po uruchomieniu pelnej kompilacji z wymaganymi zaleznosciami.
2. Sprawdzic czy analogiczne problemy wystepuja tez w `canary/` czy tylko w `canary_test/`.
3. Dodawac kolejne rundy w tym pliku jako "2026-03-XX - Runda #N".
