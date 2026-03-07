# Podsumowanie Wykonanych Zadan z Ostatniego Tygodnia

**Data podsumowania:** 2026-03-06  
**Zakres przegladu:** prace opisane w dokumentacji od 2026-03-01 do 2026-03-06, ze szczegolnym dogladnym przegladem plikow `.md` utworzonych i aktualizowanych 2026-03-05 oraz 2026-03-06  
**Cel:** zebrac wykonane zadania dla projektu: serwer + launcher + instalka + konto globalne + RedDAXE + WWW + API + i18n.

## 1. Jak czytac ten dokument

1. Sekcja `WYKONANE` oznacza zadania, ktore w dokumentacji maja status `DONE`, `PASS`, `APPLIED`, `KOMPLETNY` albo opis konkretnej wdrozonej zmiany.
2. Sekcja `CZESCIOWO DOMKNIETE` oznacza rzeczy, gdzie kod/spec/runtime jest juz ruszony, ale dokumentacja sama wskazuje jeszcze pending deploy, smoke albo E2E.
3. To podsumowanie bazuje na aktywnych dokumentach z folderu `Dokumentacja/01_Instalka_Klient/2026-03`, na audytach runtime/UI oraz na najnowszym backlogu glownym projektu.

## 2. SCALONA LISTA PUNKTOWA — wykonane zadania

1. W kliencie OTClient wdrozono `CLIENT_LOCKED` jako blokade recznego dodawania i usuwania serwerow przez gracza.
2. Dodano model `GameModes` dla `classic74` i `modern`.
3. Dodano ekran wyboru trybu gry przed logowaniem.
4. Ukryto reczne pola hosta, portu i protokolu w flow gracza.
5. Zablokowano reczna modyfikacje `ServerList.add()` i `ServerList.remove()`.
6. Dodano wymuszanie trybu gry w login flow klienta.
7. Wdrozone zostaly feature flagi ograniczen dla imitacji 7.4.
8. Po stronie serwera dodano `ticket_validator.cpp/.h` i integracje ticket-gate z Canary.
9. Dodano nowe klucze konfiguracji ticket-gate w serwerze i plikach konfiguracyjnych.
10. Wdrozone zostaly blokady 7.4 dla rune-on-creature hotkey, Quick Loot, Market, Prey, Wheel of Destiny, Smart Equip i Bestiary.
11. Dodano rate-limit ruchu dla wariantu 7.4.
12. Po stronie API dodano endpoint `ticket.php` i tabele `ticket_nonces` oraz `ticket_sessions`.
13. Klient Lua i C++ dostal obsluge flow `login -> ticket -> connect`.
14. Wdrozone zostalo filtrowanie swiatow po `gameMode` w `login.php`.
15. Dodano walidacje `worldName`, `worldId`, `gameMode` i `launchToken` w krytycznych flow.
16. Wprowadzono hard-fail TLS po stronie klienta.
17. Usunieto fallback HTTP po niepowodzeniu HTTPS.
18. Usunieto fallback HTTP dla Emscripten.
19. Usunieto logowanie wrazliwych danych z request/response.
20. Naprawiono komunikaty i martwy kod wokol `loginHttpJson`.
21. Naprawiono krytyczne guardy i rozjazdy w `protocolgame.cpp` po audycie Copilot + Claude.
22. Naprawiono bledne guardy D2, D3, D4 i D5 oraz dodano brakujace blokady we wlasciwych parserach.
23. Naprawiono fail-open w `launcher-token.php` dla nieznanej `manifestVersion`.
24. Dodano walidacje `manifest_version` przy konsumpcji tokena logowania.
25. Dodano twarde sprawdzanie `worldId` po stronie `ticket_validator.cpp`.
26. Naprawiono parsowanie hosta z URL ticket request dla konfiguracji z portem.
27. Ujednolicono schemat `launcher_config.json` z oczekiwaniami `launcher.py`.
28. W launcherze Rust zaimplementowano klienta API do wersjonowania, manifestu, launch tokena i pobierania plikow.
29. Dodano `file_index` do lokalnego skanowania plikow i hashy SHA-256.
30. Dodano `planner` do deterministycznego planu aktualizacji.
31. Dodano `patcher` ze stagingiem, backupem, rollbackiem i recovery.
32. Dodano `process_runner` do uruchamiania klienta przez `OTC_LAUNCH_TOKEN`.
33. Dodano `serverlist_sync` do generowania list serwerow w Lua/JSON.
34. Dodano moduł `repair` z diagnostyka instalacji.
35. Utworzono `launcher-cli` i domknieto flow `check -> update -> hash -> token -> launch`.
36. Dodano komendy CLI `run`, `update`, `repair`, `status`, `check` i `hash`.
37. Dodano testy kontraktowe API i testy integracyjne `launcher-core`.
38. Rozszerzono CI launchera i dodano workflow `build-launcher.yml`.
39. Utworzono aplikacje `launcher-tauri` z komendami Tauri i ekranami UI dla statusu, aktualizacji, gry, naprawy, ustawien i download center.
40. Dodano progress update UI, retry UX, eksport logow i przelaczanie kanalow `stable/test/dev`.
41. Dodano `LauncherConfig` z walidacja, ladowaniem z pliku i auto-discovery.
42. Dodano klienta `installer-catalog` oraz Download Center w Tauri UI.
43. Dodano walidacje checksum i polityke podpisow artefaktow.
44. Dodano crate `launcher-helper` i flow self-update z verify, stage, restart i rollback.
45. Dodano workflow `release-launcher.yml` oraz generowanie `checksums.txt` i `installer-catalog.json`.
46. W instalce/OTClient naprawiono krytyczny mismatch `protocol 1420` vs assets `1412`.
47. Dodano `DEV_MODE` przez `OTC_DEV_MODE=1` i rozdzielono tryb deweloperski od trybu gracza.
48. Naprawiono parsowanie `httpLoginUrl` niezaleznie od `CLIENT_LOCKED`.
49. Naprawiono pokazywanie wyboru `GameMode` takze w DEV mode.
50. Naprawiono wymuszanie wyboru trybu w `doLogin`.
51. Zmieniono fallback `clientVersion` z `1420` na `1412`.
52. Dodano skrypty `start_dev.sh`, `start_dev.bat`, `start_player.bat` oraz `.env.dev`.
53. Udokumentowano architekture `DEV` vs `GRACZ` dla klienta i launchera.
54. Po stronie DB wykonano backup trzech baz: `canaryaac`, `canary` i `canary_modern`.
55. Potwierdzono i poprawiono triggery sync kont `acc_sync_ai`, `acc_sync_au`, `acc_sync_ad` oraz analogiczne dla `modern`.
56. Naprawiono historyczny rozjazd kont w `canary.accounts` i wykonano initial sync brakujacych kont.
57. Potwierdzono sync `canary_modern.accounts` z master baza.
58. Wykonano audyt schematow `accounts` w trzech bazach.
59. Potwierdzono PASS dla testow INSERT/UPDATE/DELETE sync kont miedzy bazami.
60. Potwierdzono istnienie i zgodnosc 73/73 tabel engine DB po stronie `canary_modern` wedlug checklisty dnia kompilacji.
61. Ujednolicono `serverName` dla obu swiatow na `Canary Classic 7.4` i `Canary Modern`.
62. Przygotowano model jednego binary i dwoch configow dla obu serwerow oraz symlink binary dla `canary_modern`.
63. Potwierdzono symlinki datapack/data dla wariantu modern.
64. Dodano `start_both_servers.sh` do startu obu serwerow wraz z logami i kontrola portow.
65. Zweryfikowano `server-status.php`, aby raportowal oba serwery i poprawne porty.
66. Potwierdzono spojny `ticketSecret` w `.env`, `canary_test/config.lua` i `canary_modern/config.lua`.
67. W API naprawiono env: `ENGINE_DB_NAME=canary` i dodano `ENGINE_MODERN_DB_*`.
68. Ustawiono `MULTI_WORLD=true` w runtime i w szablonach repo.
69. Dodano helper dual-engine w `common.php`.
70. Zweryfikowano i poprawiono `login.php`, aby filtrowal postacie i swiaty per `mode`.
71. Zweryfikowano `account-context.php`, aby zwracal `charactersByWorld` i liczniki per swiat.
72. Zweryfikowano `ticket.php`, aby zwracal `403` przy `world mismatch`.
73. Potwierdzono PASS dla testow API `all/classic74/modern`.
74. Ujednolicono login i sesje `gameMode=all` dla jednego konta na dwa serwery.
75. Utrwalono spojne mapowanie `gameMode <-> worldId <-> worldName`.
76. Dodano endpoint `register-account.php` dla konta globalnego.
77. Dodano endpoint `account-context.php` dla wyboru serwera i list postaci per swiat.
78. Dodano endpointy `account-sync-token.php`, `account-sync-consume.php`, `account-sync-www-login.php` i `account-sync-www-token.php`.
79. Potwierdzono runtime PASS dla flow launcher -> WWW i WWW -> launcher z jednorazowym tokenem i blokada replay.
80. Zastosowano migracje `004_identity_social`, `005_oauth_rate_limit` i `006_unique_email`.
81. Wlaczono `OAUTH_RATE_LIMIT_ENABLED=true` i dodano rate-limit dla flow OAuth.
82. Backend social auth dla Google, Facebook i Steam zostal przygotowany i zweryfikowany kodowo fail-closed.
83. Potwierdzono PASS dla rejestracji kont z launchera, RedDAXE i WWW do wspolnego modelu konta globalnego.
84. Potwierdzono uzupelnianie `engine_password_sha1` przy rejestracji oraz poprawki MyAAC dla create/change password/lost password.
85. Potwierdzono PASS dla tworzenia postaci Classic i Modern z poprawnym routingiem `world=0/1`.
86. Wdrozono portal `RedDAXE.pl` jako front-door systemu.
87. Dodano landing, download, rejestracje, logowanie i bezpieczne redirecty oparte o allow-list.
88. W RedDAXE przepieto `account-create.php` i `account-login.php` na wspolny backend API oraz sesje WWW.
89. Naprawiono w RedDAXE rozjazd `token` vs `launchToken` oraz lokalny problem TLS self-signed dla `127.0.0.1`.
90. Wdrozono logowanie redirectow z `ipHash` zamiast surowego IP.
91. Potwierdzono runtime PASS `14/14` dla testow E2E portalu RedDAXE.
92. Potwierdzono, ze konto utworzone na portalu dziala w tym samym backendzie `accounts` co API i WWW.
93. Dodano `installer-catalog.php` dla artefaktow launchera.
94. Wdrozono i18n portalu `/portal` z detekcja jezyka, selektorem i fallbackiem.
95. Potwierdzono runtime PASS `13/13` dla i18n portalu `/portal`.
96. W WWW Tibia wdrozono grupowanie postaci per serwer w `account/manage`.
97. W tworzeniu postaci wdrozono wymuszony wybor serwera i zapis `world`/`world_id` z fallbackiem `world/world_id`.
98. Wdrozono SSO `sync-login` z launchera do WWW.
99. Wdrozono dual-server `online` z trybami `all/classic74/modern` i licznikami.
100. Wdrozono dual-server `highscores` z podzialem per serwer wedlug checklist i planu WWW.
101. Wdrozono rozdzielenie `rules` per serwer.
102. Wdrozono strone `Downloads` z CTA do launchera.
103. Naprawiono canonical HTTPS, aby runtime nie emitowal `http://127.0.0.1/*`.
104. Przepisano menu `tibiacom` z plain EN na wpisy oparte o `data-i18n`.
105. Wykonano audyt kluczy `data-i18n` i domknieto pierwszy pakiet brakow `I18N-01`.
106. Wdrozono pelne PL dla nawigacji oraz tlumaczone naglowki generowane przez `headline.php`.
107. Dodano przelacznik jezyka PL/EN z synchronizacja cookie i `?lang`.
108. Wykonano i18n hardening dla `online`, `highscores`, `account.login`, `account.management` i czesci `news`.
109. Wykonano runtime sync krytycznych plikow WWW/i18n do runtime oraz cache-busting dla `i18n.js`.
110. Naprawiono uszkodzony locale pack `pt_br`, ktory emitowal surowe linie do HTML.
111. Wdrozono poprawki anti-clipping dla legacy `tibiacom`, submenu i prawej kolumny.
112. Dodano standard wprowadzania zmian UI `tibiacom`.
113. Dodano mape source-of-truth dla assetow i geometrii UI.
114. Dodano plan pracy agentow dla WWW Tibia.
115. Dla paczki gracza potwierdzono brak sekretow, kluczy i plikow prywatnych wedlug gate `G9`.
116. Dodano runbook supportu instalki z klasyfikacja incydentow `LCH_*`, procedura support, escalation matrix i definition of ready.
117. Dodano checklistę publikacji paczki gracza z warunkami `GO/NO-GO`, rollback readiness i smoke po publikacji.
118. Dodano checklistę monitoringu pierwszych 24h po publikacji z progami alarmowymi dla błędów instalka/launcher.
119. Dodano mapę kodów błędów instalki `LCH_*` z akcjami dla gracza i supportu.
120. W dzienniku buildów GHA potwierdzono PASS kompilacji Canary Linux po naprawie blokerów RSA/OpenSSL.
121. W audycie ticket-gate naprawiono workflow GHA tak, aby buildy uruchamiały się także dla branch `feature/ticket-gate`.
122. W audycie ticket-gate naprawiono migrację SQL `ticket_gate_migration.sql`, aby używała timestampów zgodnych z runtime PHP/C++.
123. W audycie ticket-gate naprawiono błąd `login.php` z użyciem `$worlds` przed definicją.
124. W audycie ticket-gate naprawiono brakujące `execute()` w `launcher-token.php`.
125. W audycie `protocolgame.cpp` potwierdzono parytet 18/18 guardów Classic 7.4 między `canary_test` i referencyjnym `canary`.
126. W starszym planie wykonawczym Rust/Tauri odnotowano domknięcie Sprintu 5 i kompletność projektu launcherowego na poziomie planu wykonawczego.
127. Dodano mape dokumentacji i zasade `source of truth` w planie bezpieczenstwa.
128. Dodano audyt dokumentacji i blockerow przed kompilacja.
129. Naprawiono uszkodzony fragment dokumentu `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md`.
130. Dodano master backlog calego systemu i doprecyzowano go o model instalek dev/klient, konto globalne, i18n WWW oraz katalog serwerow z API.
131. Dodano master plan WWW Tibia ze statusami DONE/PARTIAL/TODO.
132. Dodano master checkliste dnia kompilacji, ktora scala potwierdzone bloki DB, API, serwerowe, WWW i launcherowe.

## 3. WYKONANE — fundament security, tryby gry i ticket-gate

### Klient OTClient i UX trybow gry

1. Wdrozone `CLIENT_LOCKED` i `GameModes` w `init.lua`.
2. Dodany ekran wyboru trybu gry (`gameModePanel`).
3. Dodana logika wyboru trybu w `entergame.lua`.
4. Zablokowane `ServerList.add/remove` po stronie klienta.
5. Ukryte pola serwera/portu/protokolu dla gracza.
6. Dodane feature flags dla blokady hotkey runes.
7. Naprawione obejscia ServerList i placeholderow po review.
8. Linux build serwera/klienta przeszedl na GHA.

### Quick security wins w kliencie

1. Wprowadzony hard-fail TLS po stronie klienta.
2. Usuniety HTTP fallback po niepowodzeniu HTTPS.
3. Usuniety fallback HTTP dla Emscripten.
4. Usuniete logowanie wrazliwych danych z request/response.
5. Poprawione mylace komunikaty o HTTP login.
6. Usuniete dead code i pozostale problemy wokol `loginHttpJson`.

### API HTTP ticket-gate

1. Dodano `gameMode` i `launchToken` do `login.php`.
2. Wdrozone filtrowanie worldow wg `gameMode`.
3. Dodany nowy endpoint `ticket.php`.
4. Dodane tabele `ticket_nonces` i `ticket_sessions` w MySQL.
5. Dodany request do `ticket.php` po stronie klienta Lua.
6. Dodana obsluga `requestTicket()` po stronie klienta C++.
7. Przeprowadzony smoke flow `login -> ticket -> connect`.

### Serwer Canary i feature flags 7.4

1. Dodany `ticket_validator.cpp/.h`.
2. Zintegrowany ticket-gate z `protocolgame.cpp`.
3. Dodane klucze konfiguracyjne w `configmanager.cpp` i `config_enums.hpp`.
4. Zmienione `config.lua` i `config.lua.dist` pod ticket-gate.
5. Dodany nonce store.
6. Linux build Canary PASS na GHA.
7. Dodany `GameMode` enum i pole w `Player`.
8. Wdrozone blokady 7.4: rune-on-creature hotkey, Quick Loot, Market, Prey, Wheel of Destiny, Smart Equip, Bestiary.
9. Dodany rate-limit ruchu dla 7.4.

### Audyty i fixy end-to-end/security

W dokumentacji z tego tygodnia jako wykonane oznaczono szeroki pakiet napraw `FIX1..FIX65`, w tym:

1. Poprawienie guardow i integracji ticket-gate w C++.
2. Fail-closed przy bledach configu ticket-gate.
3. Walidacje `worldName`, `worldId`, `gameMode`, `launchToken`, `manifest_versions`.
4. Naprawy `entergame.lua`, `httplogin.cpp`, `ticket.php`, `login.php`, `launcher.py`, `deploy_api.sh`.
5. Konfiguracje TLS/SSL, `cacert.pem`, canonical HTTPS i deploy API do runtime.
6. Obsluge argon2/bcrypt i porzadki w `.env`, `.env.example`, `.gitignore`, `common.php`.

## 4. WYKONANE — launcher Rust/Tauri

### Sprint 2 — launcher-core i launcher-api

1. Opisany kontrakt `installer-catalog.php`.
2. W pelni zaimplementowany `launcher-api` z:
   - `check_launcher_version()`
   - `fetch_manifest()`
   - `request_launch_token()`
   - pobieraniem plikow z retry.
3. Dodany `file_index` do skanowania lokalnych plikow i hashy SHA-256.
4. Dodany `planner` do budowania deterministycznego planu aktualizacji.
5. Dodany `patcher` ze stagingiem, backupem, rollbackiem i recovery.
6. Dodany `process_runner` do uruchamiania klienta przez env `OTC_LAUNCH_TOKEN`.
7. Dodany `serverlist_sync` do generowania listy serwerow w Lua/JSON.
8. Dodany `repair` z diagnostyka instalacji.

### Sprint 2 — domkniecie

1. Utworzona aplikacja `launcher-cli`.
2. Dodany pelny flow CLI: `check -> update -> hash -> token -> launch`.
3. Dodane komendy CLI: `run`, `update`, `repair`, `status`, `check`, `hash`.
4. Dodane testy kontraktowe API.
5. Dodane testy integracyjne `launcher-core`.
6. Sprint 2 w dokumentacji jest oznaczony jako w pelni ukonczony.

### Sprint 3 — CI, DTO i Tauri UI

1. Rozszerzona macierz CI dla Windows/Linux.
2. Dodany workflow `build-launcher.yml`.
3. Dodana warstwa DTO statusow dla Tauri.
4. Dodany dokument `thin-frontend-security.md`.
5. Utworzona aplikacja `launcher-tauri`.
6. Dodane 8 komend Tauri, potem rozbudowane do 12.
7. Zaimplementowane ekrany UI:
   - Status
   - Aktualizacja
   - Start gry
   - Bledy i diagnostyka
   - Naprawa
   - Ustawienia
   - Download Center
   - Self-update.
8. Dodany progress update UI, retry UX i eksport logow.
9. Dodana obsluga channel switch `stable/test/dev`.
10. Sprint 3 w dokumentacji jest oznaczony jako kompletny.

### Sprint 4 — instalka, self-update i release workflows

1. Opisany model `installer/launcher/client`.
2. Dodany `LauncherConfig` z walidacja, ladowaniem z pliku i auto-discovery.
3. Dodany model i klient `installer-catalog`.
4. Dodany Download Center w Tauri UI.
5. Dodana walidacja checksum artefaktow.
6. Dodana polityka podpisow artefaktow.
7. Dodany crate `launcher-helper` do self-update.
8. Dodane self-update: check version, download, verify, stage, restart i rollback.
9. Dodany workflow `release-launcher.yml`.
10. Dodane generowanie `checksums.txt`, `installer-catalog.json` i smoke check po release.
11. Sprint 4 jest oznaczony jako kompletny do commita.

## 5. WYKONANE — instalka, klient i rozdzial DEV vs GRACZ

1. Przejrzane i przygotowane workflow paczki gracza `build-client-package.yml`.
2. Przygotowane deploy i generowanie kluczy Ed25519 dla paczki klienta.
3. Rozpisany model artefaktow: serwer, instalka testowa, paczka gracza, launcher CLI, launcher Tauri.
4. Naprawiony krytyczny mismatch `protocol 1420` vs assets `1412`.
5. Dodany `DEV_MODE` przez `OTC_DEV_MODE=1`.
6. Rozdzielone zachowanie `CLIENT_LOCKED` dla trybu deweloperskiego i gracza.
7. Naprawione parsowanie `httpLoginUrl` niezaleznie od `CLIENT_LOCKED`.
8. Naprawione pokazywanie wyboru trybu w DEV mode.
9. Naprawione wymuszanie wyboru `gameMode` w login flow.
10. Naprawione fallbacki `clientVersion` z `1420` na `1412`.
11. Dodane skrypty `start_dev.sh`, `start_dev.bat`, `start_player.bat`.
12. Dodany `.env.dev` jako szablon dla trybu deweloperskiego.
13. Udokumentowana architektura `DEV` vs `GRACZ` dla klienta i launchera.

## 6. WYKONANE — konto globalne, dwa serwery i integracja runtime

Na podstawie checklisty i planu wspolnego konta jako wykonane albo runtime PASS opisano:

1. Ujednolicenie loginu i sesji `gameMode=all`.
2. Spojne mapowanie `gameMode <-> worldId <-> worldName`.
3. Rozdzial postaci per serwer w `charactersByWorld`.
4. Ticket flow dla sesji `all` z blokada mismatch.
5. Rejestracja konta z launchera przez API.
6. Endpoint `account-context` dla wyboru serwera i postaci per serwer.
7. Listy graczy `all/classic74/modern`.
8. Testy i wpisy PASS/FAIL do dziennika wynikow.
9. Migracja DB `004_identity_social` zastosowana.
10. Sync WWW <-> launcher przez jednorazowy token issue/consume.
11. Flow `konto zalozone w launcherze -> tworzenie postaci na WWW`.
12. Flow `konto zalozone na WWW -> synchronizacja z launcherem`.
13. Hardening social/sync z migracja `005`, PKCE, state, audit i rate-limit.
14. Kod gotowy dla UX `Utworz postac Tibia 7.4/Modern` i auto-login WWW z launchera.

## 7. WYKONANE — portal RedDAXE i warstwa WWW/API

### RedDAXE

1. Portal `RedDAXE.pl` dziala runtime.
2. Download launchera + checksum + fallback link dziala runtime.
3. Rejestracja i logowanie konta wspolnego przez RedDAXE dzialaja runtime.
4. Routing i bezpieczne przekierowania do WWW/forum/wiki/external dzialaja runtime.
5. Testy pre-kompilacyjne E2E portalu przeszly `14/14 PASS`.
6. Branding MVP portalu jest opisany jako gotowy na tym etapie.

### API/PHP/konfiguracja

1. Sprawdzona spojnosci `.env` i portow 7172/7174.
2. Sprawdzone `generate_manifest.php`.
3. Potwierdzony routing `login.php` classic -> 7172, modern -> 7174.
4. Naprawiony `launcher_config.json` o `language` i produkcyjny `apiBaseUrl`.
5. Sprawdzone `init.lua`, `config.lua`, `config.lua.dist` pod worldId, porty i blokady.
6. Naprawione runtime i repo env: `ENGINE_DB_NAME=canary` oraz dodane `ENGINE_MODERN_DB_*`.
7. Ustawione `MULTI_WORLD=true` w runtime i template repo.
8. Dodany helper dual-engine w `common.php` (`getEnginePdo`, `getBothEnginePdos`).
9. Zweryfikowany i poprawiony `login.php`, aby filtrowal postacie i swiaty per `mode`.
10. Zweryfikowany `account-context.php`, aby zwracal `charactersByWorld` i liczniki per swiat.
11. Zweryfikowany `ticket.php`, aby zwracal `403` przy `world mismatch`.
12. Checklista API ma wpisane PASS dla testow `login all/classic74/modern`.

## 8. WYKONANE — WWW Tibia i i18n/UI

### Tibiacom / account UI / sidebar

1. Usuniete problematyczne grafiki-fonty i czarne pola w starym loginboxie.
2. Wdrozone tekstowe etykiety i18n zamiast czesci grafik-fontow.
3. Wdrozony nowy sidebar logowania `GlobalLoginSidebar`.
4. Dodane klucze i18n PL/EN dla nowego sidebara.
5. Wdrozone przelaczniki profilu globalnego `all/classic74/modern` w sidebarze.
6. Dodane natywne buttony tibiacom dla sidebara.
7. Wprowadzony anti-overlap sidebar/menu i pierwszy guard na clipping highscores.
8. Dodana geometria sidebar/menu oparta o rzeczywiste rozmiary grafik, nie offsety "na oko".
9. W `account/manage` wdrozone grupowanie postaci per serwer (`Classic 7.4` / `Modern`).
10. W `create character` wdrozony wymuszony wybor serwera i zapis `world`/`world_id`.
11. Wdrozone SSO `sync-login` z launchera do WWW.
12. Wdrozone zakladki/tryby `online` dla `all/classic74/modern` z licznikami i summary.
13. Wdrozone rozdzielenie `rules` per serwer.
14. Wdrozone `Downloads` jako czysta strona z CTA do launchera.

### Dokumentacja i standardy UI/I18N

1. Dodany standard wprowadzania zmian UI tibiacom.
2. Dodana mapa source-of-truth dla assetow i geometrii.
3. Dodane snapshoty pomiarowe grafik i komendy referencyjne.
4. Dodany plan pracy agentow dla WWW Tibia.
5. Dodane reguly handoffu i `Definition of Done` dla prac WWW.

### WWW i18n / routing / canonical HTTPS

1. Wykonany fix canonical HTTPS, aby runtime nie emitowal `http://127.0.0.1/*`.
2. Rozdzial rankingow i list API na `all/classic74/modern` zostal wdrozony kodowo.
3. I18n portalu `/portal` ma runtime PASS.
4. I18n `/reddaxe` zostalo wdrozone kodowo z PL/EN, selectorem i fallbackiem.
5. W WWW Tibia wykonano czesc prac i18n, w tym tlumaczenia etykiet na stronach postaci i poprawki highscores.
6. Przepisane menu `tibiacom` z plain EN na wpisy z kluczami `data-i18n="nav.*"`.
7. Wykonany audyt kluczy `data-i18n` vs `pl.json/en.json` i domkniety pierwszy pakiet brakow (`I18N-01`).
8. Wdrozone pelne PL dla nawigacji oraz tlumaczone naglowki generowane przez `headline.php`.
9. Dodany przelacznik jezyka PL/EN z zapisem `locale`, synchronizacja cookie + `?lang` i fallbackiem na `pl`.
10. Wykonane i18n hardening dla `online`, `highscores`, `account.login`, `account.management` i czesci `news`.
11. Wykonany runtime sync krytycznych plikow WWW/i18n do `/var/www/html` oraz cache-busting dla `i18n.js`.
12. Naprawiony incydent z uszkodzonym locale packiem `pt_br`, ktory emitowal surowe linie do HTML stopki.
13. Wdrozone kolejne poprawki anti-clipping dla legacy `tibiacom` i prawej kolumny pod dluzsze polskie stringi.

## 9. WYKONANE — dokumentacja, audyty i organizacja pracy

1. Zaktualizowany dziennik i plan przed kompilacja.
2. Dodane wersje do kompilacji i procedura testu po kompilacji.
3. Wykonany audyt dokumentacji i brakow z 2026-03-06.
4. Dodana mapa aktywnych dokumentow vs historycznych.
5. Dodany osobny audyt brakow dokumentacyjnych i blockerow.
6. Naprawiony uszkodzony fragment `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md`.
7. Dodany master backlog calego systemu.
8. Doprecyzowany master backlog o model instalek dev/klient, konto globalne vs konta techniczne, i18n WWW i katalog serwerow sterowany z API.
9. Dodany master plan WWW Tibia z rozpisanym statusem DONE/PARTIAL/TODO dla zadan wieloserwerowych i i18n.
10. Dodana master checklista dnia kompilacji, ktora potwierdza wykonane bloki DB, API, serwerowe i WWW.
11. W audycie prac Copilot + Claude potwierdzono i domknieto kolejne krytyczne fixy guardow 7.4, ticketow i launchera.

## 10. WYKONANE — sesje WWW Tibia 2026-03-06 wieczór / 2026-03-07

### Batch 1 — Highscores i Account poprawki (sesja 2026-03-06 wieczór)

133. Naprawiono klikalne nazwy postaci w highscores — linki do profilu postaci z obu baz (classic + modern).
134. Naprawiono wyświetlanie outfit image w kolumnie highscores — <img> generowane przez PHP z poprawnym src.
135. Dodano pełny selektor serwera (All / Classic 7.4 / Modern) w highscores — dropdown z przełączaniem `?mode=`.
136. Wdrożono i18n strony tworzenia postaci — labele, komunikaty walidacji, opcje serwera w PL/EN.
137. Wdrożono i18n logów konta (Account Logs) — wszystkie labele i nazwy typów zdarzeń w PL/EN.
138. Naprawiono tytuł vocation w highscores — nazwy vocacji przetłumaczone PL/EN przez `__()`.

### Batch 2 — Highscores fixy krytyczne i Create Character i18n (sesja 2026-03-07)

139. **Highscores title mode label** — tytuł highscores pokazuje teraz prawidłowe "Classic 7.4" lub "Modern" zamiast zawsze "Canary Classic 7.4" z `config.lua`. Dodano `$modeLabel` obliczany z `match($mode)`.
140. **Character creation success message i18n** — komunikat sukcesu po utworzeniu postaci przetłumaczony na PL/EN z placeholderami `$NAME$` i `$SERVER$`. Serwer odczytywany z sesji `global_profile_mode`.
141. **Vocation filter English slugs** — naprawiono 404 przy filtrze vocacji (np. "Czarnoksiężnik") w highscores. Router `:string` regex nie obsługuje UTF-8 — rozwiązano przez canonical English slugs (`none/sorcerer/druid/paladin/knight`) w URL-ach z fallbackiem na polskie nazwy z configa w PHP.
142. **Highscores column alignment** — naprawiono wyrównanie kolumn tabeli highscores: Name=auto, World=15%, Level=12%, Points=15%, Outfit=64px + `white-space: nowrap`.
143. **Pagination/mode URL slugs** — naprawiono linki paginacji (`$linkPreviousPage`, `$linkNextPage`), `$baseLink` i `$modes` array — wszystkie teraz używają English vocation slugs zamiast raw `$vocation` (który mógł być po polsku → 404).
144. **Twig syntax fix** — naprawiono `%>` → `%}` w sidebar skills box `{% for %}` loop (highscores.html.twig:125).
145. Deploy i weryfikacja: curl test 200 OK dla all vocations (none/sorcerer/druid/paladin/knight) × all modes (all/classic74/modern).

### Zmienione pliki (Batch 1+2)

- `system/pages/highscores.php` — $modeLabel, $vocationSlugs, $slugToVocationId, $vocationUrlPart, dual vocation matching
- `system/templates/highscores.html.twig` — title uses modeLabel, vocation URLs use English slugs, column widths, Twig syntax fix
- `system/src/CreateCharacter.php` — success message i18n z __() + $NAME$/$SERVER$ placeholders
- `system/locale/pl/main.php` — create_char_success_title, create_char_success_description
- `system/locale/en/main.php` — create_char_success_title, create_char_success_description

## 11. CZESCIOWO DOMKNIETE — ruszone, ale jeszcze nie final PASS

Te obszary maja juz wykonana czesc pracy, ale dokumentacja sama oznacza je jako `PARTIAL`, `runtime pending`, `code done` albo `TODO` w ostatnim kroku:

1. Windows build dla czesci faz klient/serwer.
2. Integracyjny test feature flags po stronie serwera (`D11`).
3. Hosting plikow klienta (`E13`).
4. Topki wspolne + per-serwer po stronie WWW runtime smoke.
5. Natywny login i rejestracja konta w launcherze — kod gotowy, runtime E2E pending.
6. Social login provider secrets i callback URLs — backend gotowy, runtime providerow pending.
7. Pelne i18n WWW Tibia i matryca E2E i18n dla launcher/portal/WWW.
8. Deploy i smoke `/reddaxe` na runtime po ostatnich zmianach i18n.
9. `community/highscores` i `shop/payment` po stronie runtime WWW.
10. Dual-db sync kont i dalsze kroki 2-bazowe.
11. Finalna tabela `repo / runtime / E2E / owner`.

## 12. Bilans ogolny po tygodniu

Na podstawie dokumentacji z ostatniego tygodnia realnie wykonano:

1. Fundament security ticket-gate od klienta przez API po serwer.
2. Pelny launcher Rust: core, CLI, Tauri UI, helper self-update, CI i release workflows.
3. Rozdzielenie trybu `DEV` i `GRACZ` w instalce/kliencie.
4. Runtime konto globalne + dwa serwery dla kluczowych flow API/WWW/launcher sync.
5. Dzialajacy portal RedDAXE z downloadem, logowaniem i routingiem.
6. Duzy pakiet porzadkow w WWW Tibia, i18n oraz standardach pracy nad UI.
7. Mocne uporzadkowanie dokumentacji i backlogu projektu.

## 13. Zrodla podsumowania

Glowne dokumenty z ktorych zebrano wykonane prace:

1. `Dokumentacja/01_Instalka_Klient/2026-03/00_START_PRACY_CHECKLISTA.md`
2. `Dokumentacja/01_Instalka_Klient/2026-03/01_DZIENNIK_PRAC.md`
3. `Dokumentacja/01_Instalka_Klient/2026-03/plan_zabezpieczenia_klienta_i_serwera.md`
4. `Dokumentacja/01_Instalka_Klient/2026-03/03_PLAN_WSPOLNE_KONTO_2_SERWERY.md`
5. `Dokumentacja/01_Instalka_Klient/2026-03/04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md`
6. `Dokumentacja/01_Instalka_Klient/2026-03/05_PLAN_SKLEP_SMS_2_BAZY.md`
7. `Dokumentacja/01_Instalka_Klient/2026-03/06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md`
8. `Dokumentacja/01_Instalka_Klient/2026-03/07_PLAN_JUTRO_DZIEN_KOMPILACJI.md`
9. `Dokumentacja/01_Instalka_Klient/2026-03/08_PLAN_INSTALKA_JUTRO_DETALE.md`
10. `Dokumentacja/01_Instalka_Klient/2026-03/09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md`
11. `Dokumentacja/01_Instalka_Klient/2026-03/10_AUDYT_DOKUMENTACJI_I_BRAKOW_2026-03-06.md`
12. `Dokumentacja/01_Instalka_Klient/2026-03/10_PLAN_SERWER_CANARY_74_VS_MODERN.md`
13. `Dokumentacja/01_Instalka_Klient/2026-03/11_PLAN_BAZY_DANYCH_SYNC_TRIGGERY.md`
14. `Dokumentacja/01_Instalka_Klient/2026-03/12_PLAN_API_ENDPOINTY_POPRAWKI.md`
15. `Dokumentacja/01_Instalka_Klient/2026-03/13_PLAN_KONTO_GLOBALNE_UNIFIED.md`
16. `Dokumentacja/01_Instalka_Klient/2026-03/14_PLAN_LAUNCHER_TAURI_RUST.md`
17. `Dokumentacja/01_Instalka_Klient/2026-03/15_PLAN_INSTALKA_KLIENT_PACZKA.md`
18. `Dokumentacja/01_Instalka_Klient/2026-03/16_PLAN_WWW_REDDAXE_I18N.md`
19. `Dokumentacja/01_Instalka_Klient/2026-03/17_MASTER_CHECKLIST_KOMPILACJA.md`
20. `Dokumentacja/01_Instalka_Klient/2026-03/24_PLAN_WWW_TIBI_MASTER_ZADANIA.md`
21. `Dokumentacja/01_Instalka_Klient/2026-03/2026-03-03_launcher_sprint2.md`
22. `Dokumentacja/01_Instalka_Klient/2026-03/2026-03-03_launcher_sprint2_uzupelnienie.md`
23. `Dokumentacja/01_Instalka_Klient/2026-03/2026-03-03_launcher_sprint3_ci_dto.md`
24. `Dokumentacja/01_Instalka_Klient/2026-03/2026-03-03_launcher_sprint3_tauri_ui.md`
25. `Dokumentacja/01_Instalka_Klient/2026-03/2026-03-03_launcher_sprint4_installer_selfupdate.md`
26. `Dokumentacja/01_Instalka_Klient/2026-03/2026-03-05_PLAN_PRZED_KOMPILACJA.md`
27. `Dokumentacja/01_Instalka_Klient/2026-03/2026-03-06_naprawa_instalki_dev_gracz.md`
28. `Dokumentacja/01_Instalka_Klient/2026-03/03_AUDYT_PRAC_COPILOT_CLAUDE.md`
29. `Dokumentacja/01_Instalka_Klient/2026-03/18_RUNBOOK_SUPPORT_INSTALKA_TOP_PROBLEMY.md`
30. `Dokumentacja/01_Instalka_Klient/2026-03/19_CHECKLISTA_PUBLIKACJI_PACZKI_GRACZA.md`
31. `Dokumentacja/01_Instalka_Klient/2026-03/20_CHECKLISTA_MONITORING_24H_PO_PUBLIKACJI.md`
32. `Dokumentacja/01_Instalka_Klient/2026-03/21_MAPA_KODOW_BLEDOW_INSTALKI_SUPPORT_KB.md`
33. `Dokumentacja/01_Instalka_Klient/2026-03/02_DZIENNIK_BUILDOW_GHA.md`
34. `Dokumentacja/01_Instalka_Klient/2026-03/launcher+rust2_zadania.md`
35. `Dokumentacja/01_Instalka_Klient/2026-03/launcher+rust.md`
36. `Dokumentacja/01_Instalka_Klient/2026-03/audyt_ticket_gate_pelny.md`
37. `Dokumentacja/01_Instalka_Klient/2026-03/audyt_protocolgame_guard_fix.md`
38. `Dokumentacja/05_Ogolne_Projekt/2026-03/2026-03-06_master_backlog_caly_system.md`