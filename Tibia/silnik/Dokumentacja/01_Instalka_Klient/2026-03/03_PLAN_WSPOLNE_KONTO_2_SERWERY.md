# Plan K — Wspolne Konto Na 2 Serwery (Launcher + Strona)

**Data:** 2026-03-05  
**Zakres:** jedno konto na 2 serwery (`classic74`, `modern`), wybor serwera po logowaniu, wspolne i per-serwer topki/listy graczy + roadmapa globalnego konta launchera dla wielu gier  
**Tryb:** dokumentacja i planowanie (bez kompilacji lokalnej)

---

## 1. Cel biznesowy

1. Gracz zaklada **jedno konto** i uzywa go na obu serwerach.
2. Po zalogowaniu (launcher/strona) gracz wybiera serwer (`classic74` albo `modern`) do zarzadzania postaciami.
3. Postacie sa rozdzielone per serwer (inne postacie na `classic74`, inne na `modern`), ale konto jest wspolne.
4. Strona pokazuje:
- topki wspolne (`all`),
- topki per-serwer,
- listy graczy wspolne i per-serwer.

---

## 2. Wymagania funkcjonalne

### K-REQ-1 Konto wspolne
- Jedna tabela `accounts` jest zrodlem prawdy dla obu serwerow.
- Rejestracja przez launcher/API tworzy konto tylko raz.

### K-REQ-2 Rozdzial postaci per serwer
- Postacie sa przypisane do swiata przez pole `players.world` (lub kompatybilnie `world_id` jesli istnieje).
- `classic74` i `modern` maja rozne identyfikatory world.

### K-REQ-3 Wybor serwera po loginie
- Login nie moze sztywno wymuszac `modern` przy braku `gameMode`.
- Sesja logowania musi obslugiwac stan neutralny (`all`) i dopiero potem wybor serwera.

### K-REQ-4 Widoki strony
- API udostepnia dane dla:
- topki wspolnej,
- topki `classic74`,
- topki `modern`,
- listy graczy online/offline w tych samych 3 trybach.

### K-REQ-5 Spojnosc launcher + strona
- Ten sam kontrakt mapowania `gameMode <-> worldId <-> nazwa`.
- Jednoznaczne nazwy serwerow i brak fallbackow powodujacych kolizje portow.

### K-REQ-6 Konto utworzone w launcherze dziala na WWW
- Konto zalozone przez launcher musi od razu dzialac na stronie WWW.
- Tworzenie postaci odbywa sie na WWW w kontekście tego samego `account_id`.

### K-REQ-7 Konto utworzone na WWW synchronizuje sie z launcherem
- Konto zalozone na stronie WWW musi logowac sie i dzialac w launcherze bez migracji recznej.
- Potrzebny flow "sync/link" i jednorazowy token wymiany sesji WWW <-> launcher.

### K-REQ-8 Social signup/login w launcherze
- Launcher ma wspierac rejestracje/logowanie przez:
- Google,
- Facebook,
- Steam.
- Tozsamosc social musi mapowac sie na jedno konto lokalne `accounts`.

### K-REQ-9 Intuicyjny flow "konto w launcherze -> postac na WWW"
- Po utworzeniu konta w launcherze gracz ma widziec dwa jasne przyciski:
- `Utworz postac Tibia 7.4`,
- `Utworz postac Modern`.
- Klikniecie przycisku ma otwierac WWW po auto-logowaniu sync tokenem i z preselectem swiata w formularzu tworzenia postaci.
- Celem jest spojnosc i intuicyjnosc dla gracza: jedno konto, osobne postacie na 2 serwery, bez recznego szukania opcji.

### K-REQ-10 Globalne konto launchera (multi-game)
- Konto launchera jest globalne dla wielu gier/serwerow (jeden login tozsamosci).
- Tozsamosc globalna launchera mapuje sie na profile per gra/serwer.
- Gracz po zalogowaniu wybiera gre/serwer i zarzadza tylko profilem tej gry.

### K-REQ-11 Rozdzial progresu per gra/serwer
- Kazda gra/serwer ma osobne: topki, levelowanie, postacie i gospodarke.
- Jedno konto globalne NIE laczy progresu gry, tylko dostep i tozsamosc.

### K-REQ-12 Gildie i arena UI sa poza tym etapem
- Gildie (model globalny + odwzorowanie per gra/serwer) sa odlozone na etap po stabilizacji logowania i bezpieczenstwa.
- UI dla aren jest odlozone na etap po domknieciu systemu security + account linking.

### K-REQ-13 Natywna rejestracja konta w launcherze + auto-login
- Launcher ma wspierac natywna rejestracje lokalnego konta (`accountName`, `email`, `password`, `passwordConfirm`) bez przechodzenia na WWW.
- Po poprawnej rejestracji launcher probuje auto-login i uzupelnia `sessionKey` do flow sync WWW.
- Gdy auto-login nie powiedzie sie, konto pozostaje utworzone, a launcher pokazuje czytelny komunikat i fallback do recznego loginu.

### K-REQ-14 Parytet rejestracji WWW i API
- Rejestracja przez WWW i przez API ma walidowac konto tym samym kontraktem (`accountName`, email, haslo) i tworzyc dane konta w tym samym standardzie.
- Pola konta krytyczne dla zgodnosci loginu i audytu (np. `engine_password_sha1`, `email_hash`, `email_verified`, `page_access`, `type`) nie moga sie rozjezdzac miedzy sciezkami WWW/API.

### K-REQ-15 Portal startowy RedDAXE.pl (pre-kompilacja)
- Przed finalna kompilacja launchera ma dzialac portal startowy `RedDAXE.pl` jako wejscie do ekosystemu.
- Portal ma obslugiwac:
- pobieranie launchera (artefakt + checksum),
- tworzenie/logowanie konta wspolnego (to samo konto co API/launcher),
- nawigacje do stron: WWW gry, forum, wiki i stron zewnetrznych niezaleznych od Tibii.
- Portal ma byc testowalny end-to-end bez kompilacji klienta/launchera.

### K-REQ-16 Globalne rangi i federacja uprawnien (etap pozniejszy)
- Docelowo konto globalne ma miec role/rangi wielogra:
- np. `Helper Tibia 7.4`, `Admin CS1.6 FFA`, `Multiadmin TB+1.6`.
- Role maja byc mapowane per gra/serwer i opcjonalnie publikowane na forum/serwisach zewnetrznych (badge/title).
- Ten zakres jest poza obecnym sprintem security+shared-account i trafia do backlogu po stabilizacji K1-K34.

### K-REQ-17 Migracja front-door na Python+Django (etap pozniejszy)
- Po stabilizacji PHP MVP portalu, docelowo przepisanie warstwy front-door na Python+Django.
- Django ma byc warstwa portalu (konta, rangi, panel admin), a NIE zastepowac PHP API gry (login/ticket/sync).
- Kluczowe cele:
  - Centralne zarzadzanie kontami i rangami ekipy administracyjnej rozsianymi po forach, stronach, Discordach i grach.
  - Model `StaffRole` per gra/serwer z mapowaniem na forum (badge/title) i Discord (role sync via bot).
  - Django Admin jako panel zarzadzania uzytkownikami i uprawnieniami (bez pisania customowego panelu).
  - REST API (DRF) do integracji z Discord botem, forum i innymi serwisami.
- Architektura docelowa:
  - Nginx proxy: `/portal/` -> Gunicorn (Django), `/apik/` -> PHP-FPM, `/` -> PHP-FPM (CanaryAAC).
  - Django uzywa tej samej bazy MySQL `canaryaac` (inspectdb + managed=False na istniejacych tabelach).
  - Django dodaje wlasne tabele: `staff_roles`, `role_mappings`, `audit_log`, `discord_sync`.
- Wymagania wstepne (BLOCKED do momentu spelnienia):
  - K1-K34 zamkniete na 100% (stabilny login + portal PHP + security).
  - Decyzja o wyborze forum (phpBB/Discourse/inne) — potrzebna dla federacji rang.
  - Spike architektoniczny K35 zakonczony (koszt, ryzyko, migracja danych).
- Stack: Python 3.12 (juz na serwerze), Django 5.x, DRF, Gunicorn, WhiteNoise (static).
- Migracja krokowa: (1) Django obok PHP, (2) portal RedDAXE na Django, (3) panel admin rang, (4) API federacji.

### K-REQ-18 Pelne i18n (portal + WWW Tibia)
- Portal `RedDAXE` i strona WWW Tibii musza miec pelne i18n, bez hardcoded jednego jezyka.
- Minimalny runtime zakres jezykow przed finalnym release: `pl` + `en` + fallback.
- Wszystkie krytyczne flow konta musza byc tlumaczone:
  - rejestracja,
  - logowanie,
  - tworzenie postaci,
  - topki/listy graczy,
  - komunikaty bledow.
- Kontrakt i18n ma byc spojny z launcherem (te same klucze semantyczne tam, gdzie to mozliwe).

### K-REQ-19 Rozdzial danych gry na 2 niezalezne bazy
- `classic74` i `modern` maja osobne bazy danych runtime (separacja danych postaci, itemow, ekonomii, sklepu, logow gry).
- Konto globalne (`accounts`) pozostaje wspolne, ale profile gry sa utrzymywane osobno per baza serwera.
- Brak write-crossing: operacje dla `classic74` nie moga zapisywac do bazy `modern` i odwrotnie.

### K-REQ-20 Jedna strona WWW nad 2 bazami serwerow
- Strona WWW pokazuje dane z 2 baz na jednym UI (switch serwera + widoki laczone tam, gdzie ma sens).
- Wszystkie listy/topki musza byc jawnie oznaczone zakresem: `all`, `classic74`, `modern`.
- Warstwa API/WWW musi miec adapter agregujacy dane cross-db bez laczenia tabel "na sztywno" w jednej bazie gry.

### K-REQ-21 Rejestracja i logowanie kont przy 2 bazach
- Rejestracja konta globalnego tworzy/udostepnia profil gracza dla obu serwerow (provisioning eager albo lazy - do decyzji arch).
- Logowanie WWW/launcher pozostaje jednolite (jedno konto), ale operacje postaci i sklepu sa wykonywane w kontekście wybranego serwera/bazy.
- Musi istniec mapowanie `account_global -> account_world (classic74/modern)` i audyt zmian mapowania.

### K-REQ-22 Sklep SMS dla 2 serwerow i konta wspolnego
- Sklep SMS ma jeden checkout UX, ale kazda transakcja ma twardy kontekst serwera (`gameMode/worldId`) i docelowej bazy.
- Callback SMS musi byc idempotentny i bezpieczny (podpis, anti-replay, lock po `provider_txn_id`).
- Punkty/benefity trafiaja tylko do wybranego serwera; historia zakupow na stronie moze miec widok `all` + filtry per-serwer.

### K-REQ-23 Widoki laczone i polityka prezentacji danych
- Topki "laczone" sa osobnym typem rankingu agregowanego (np. kills/coins), a nie przypadkowym mixem rekordow.
- Wspolne listy graczy i historia zakupow musza pokazywac znacznik serwera zrodlowego.
- Przy awarii jednej bazy UI/API powinno wejsc w tryb degradacji (druga baza dziala, pierwsza ma status `temporarily_unavailable`).

---

## 3. Aktualne luki logiczne (do zamkniecia)

1. **Session lock do `modern`:** ~~przy pustym `gameMode` login zapisuje sesje jako `modern`~~ ✅ ZAMKNIETE — login obsluguje `gameMode=all`, runtime test PASS (2026-03-05).
2. **Rozjazd runtime vs repo:** ✅ ZAMKNIETE — wszystkie pliki PHP zsynchronizowane z repo (10 nowych + 7 zaktualizowanych, 2026-03-05 20:16).
3. **Niejednoznaczna kolumna swiata:** realna baza ma `players.world` (int), logika mapuje poprawnie world=0→classic74, world=1→modern. ✅ ZAMKNIETE — runtime E2E PASS (account-context + ticket cross-mode mismatch).
4. **Fallback portow w `.env`:** ✅ ZAMKNIETE — `.env` ma poprawne WORLD_CLASSIC74/WORLD_MODERN z osobnymi portami (7171-72 / 7173-74).
5. **Brak gotowego API pod ranking/listy 2-serwerowe:** ✅ ZAMKNIETE — toplist.php i players-list.php dzialaja z `all/classic74/modern`, runtime PASS.
6. **Brak twardego UNIQUE dla emaila w `accounts`:** ✅ ZAMKNIETE — migracja 006_unique_email APPLIED (2026-03-05), duplikaty usunięte, indeks UNIQUE aktywny.
7. **Identity linking tylko czesciowo domkniety:** ✅ CZESCIOWO — warstwa DB gotowa (migracje 004+005 APPLIED), Google/Facebook/Steam backend w repo; runtime secrets per provider nadal otwarte.
8. **Flow wymiany sesji WWW <-> launcher:** ✅ ZAMKNIETE — wszystkie endpointy wdrozone na runtime i przetestowane E2E (sync-token + consume + www-login + replay protection PASS).
9. **Polityka linkowania kont social jest czesciowa:** ⚠️ OTWARTE — Google ma blokade konfliktu, ale nadal brak procedury merge i parity dla wszystkich providerow.
10. **UX entrypoint launcher-first:** ✅ ZAMKNIETE KODOWO — 2 przyciski i preselect swiata gotowe; K14 runtime test PASS (www-login z cookie + redirect).
11. **Brak natywnego loginu konta w launcherze:** ✅ ZAMKNIETE KODOWO — launcher ma login email+haslo i uzupelnia `sessionKey`; runtime E2E pending.
12. **Brak modelu globalnej tozsamosci multi-game:** obecny kontrakt skupia sie na 2 serwerach Tibii i nie ma jeszcze `gameId/profile` dla wielu gier.
13. **Brak polityki scope dla sesji globalnej:** brak jawnego rozdzialu tokenow `identity` vs `game_profile`.
14. **Gildie i arena UI nie sa jeszcze rozpisane technicznie:** celowo odlozone do etapu po domknieciu bezpieczenstwa i stabilnego loginu.
15. **Brak natywnej rejestracji konta w launcherze:** ✅ ZAMKNIETE KODOWO — launcher ma flow register->auto-login z fallbackiem; runtime E2E pending.
16. **Rozjazd walidacji rejestracji WWW vs API:** ✅ ZAMKNIETE KODOWO — WWW `Create.php` i API `register-account.php` maja spojniejszy kontrakt; runtime E2E pending.
17. **Brak portalu wejscia pre-kompilacyjnego:** ✅ ZAMKNIETE — portal RedDAXE wdrożony (`/portal/`), testy E2E 14/14 PASS (register+login+download+redirects+open-redirect+external).
18. **K31 login WWW po rejestracji portalowej bez finalnego PASS na tym branchu:** ✅ ZAMKNIETE — login portal E2E PASS (2026-03-05), panel konta + logout dziala.
19. **Brak decyzji architektonicznej dla front-door (PHP vs Django):** ✅ ZAMKNIETE PLANISTYCZNIE — PHP MVP wdrozony i przetestowany; plan Django dodany jako K-REQ-17 + K38-K40 + sekcja 12 (BLOCKED do momentu zakonczenia K35 spike).
20. **Brak modelu globalnych rang i federacji forum:** ⬜ BACKLOG — zakres odlozony po stabilizacji kont i security.
21. **Brak pelnego i18n dla portalu i WWW Tibia:** ⚠️ OTWARTE (PARTIAL) — `/portal` runtime PASS; `/reddaxe` ma juz i18n PL/EN + selector + fallback (kod + lokalny smoke PASS 2026-03-05), do domkniecia: runtime smoke `/reddaxe` + finalna matryca E2E z launcherem.
22. **Shop WWW nie byl rozdzielony na serwery:** 🔄 CZESCIOWO ZAMKNIETE KODOWO (K45) — dodany wybor serwera i context checkout; nadal otwarte: per-serwerowe saldo/rozliczanie coinow po callbacku platnosci.
23. **Brak rankingow laczonych cross-server (kills/coins):** ⬜ OTWARTE — potrzebny osobny model agregacji (K46), niezalezny od rankingow per-serwer.
24. **Log redirectow trzymal surowe IP (PII) w `reddaxe/redirect.log`:** ✅ ZAMKNIETE (2026-03-05) — zapis zmieniony na `ipHash` (sha256, salt z `.env`).
25. **Rozjazd routingu highscores (`/community/highscores` vs legacy `/index.php/highscores`):** ⚠️ OTWARTE (runtime smoke) — kod wspiera oba warianty, ale finalny gate wymaga potwierdzenia na runtime z aktywnym routerem.
26. **Brak fizycznej separacji 2 baz serwerow (classic74/modern):** ⬜ OTWARTE — obecny model nadal operuje na jednej bazie gry.
27. **Brak warstwy agregacji cross-db na WWW/API:** ⬜ OTWARTE — brak wspolnego read-modelu dla list/topki/sklepu nad 2 bazami.
28. **Brak mapowania konta globalnego do profili per-baza serwera:** ⬜ OTWARTE — brak twardej tabeli/linkowania `account_global -> account_world`.
29. **Sklep SMS bez pelnego routingu na serwer docelowy:** ⬜ OTWARTE — checkout/callback musza byc serwer-aware i idempotentne.

---

## 4. Plan wdrozenia (zadania atomowe)

| ID | Zadanie | Priorytet | Status |
|---|---|---|---|
| K1 | Ujednolicic `login.php` (repo + runtime) i tryb sesji `all` dla wyboru serwera po loginie | KRYTYCZNY | ✅ RUNTIME PASS (2026-03-05) — login zwraca 2 worldy, sessionkey OK |
| K2 | Ujednolicic mapowanie swiatow: `classic74` i `modern` (id, nazwa, host, port) we wszystkich endpointach | KRYTYCZNY | ✅ RUNTIME PASS — worldId 0=Classic7.4, 1=Modern, mapowanie spojne |
| K3 | Dostosowac logike postaci do `players.world` z fallbackiem kompatybilnosci do `world_id` | WYSOKI | ✅ RUNTIME PASS (2026-03-05) — charactersByWorld poprawnie mapuje world=0→classic74, world=1→modern |
| K4 | Dostosowac `ticket.php` do sesji `all` (wymagany wybor gameMode na etapie ticketu) | KRYTYCZNY | ✅ RUNTIME PASS (2026-03-05) — ticket z gameMode=classic74 OK, cross-mode mismatch blokowany |
| K5 | Dodac endpoint rejestracji konta pod launcher (`register-account.php`) | WYSOKI | ✅ RUNTIME PASS (2026-03-05) — register OK, dupe=409 |
| K6 | Dodac endpoint kontekstu konta (`account-context.php`) do wyboru serwera i list postaci per serwer | WYSOKI | ✅ RUNTIME PASS (2026-03-05) — account+worlds+charactersByWorld OK |
| K7 | Dodac endpoint topki (`toplist.php`) z trybem `all/classic74/modern` | WYSOKI | 🔄 PARTIAL — API runtime PASS (2026-03-05); WWW/MyAAC split kodowo (2026-03-06, takze legacy `/index.php/highscores`), runtime smoke pending |
| K8 | Dodac endpoint listy graczy (`players-list.php`) z trybem `all/classic74/modern` | SREDNI | ✅ RUNTIME PASS (2026-03-05) — filtruje modern/classic74 |
| K9 | Uzgodnic i zapisac finalny kontrakt JSON dla strony i launchera | WYSOKI | ✅ opisane w sekcji 5 |
| K10 | Testy curl + wpisy PASS/FAIL/BLOCKED do dziennika wynikow | WYSOKI | ✅ RUNTIME E2E PASS: K1,K5-K8,K12-K14 all PASS (2026-03-05 20:16-20:27) |
| K11 | Dodac migracje DB pod identity/social/sync (`account_identity_links`, `oauth_states`, `account_sync_tokens`) | KRYTYCZNY | ✅ rollout 004 applied (2026-03-05 19:12) |
| K12 | Dodac endpoint `account-sync-token.php` (issue token) i `account-sync-consume.php` (consume token) | WYSOKI | ✅ RUNTIME PASS (2026-03-05) — issue + consume + replay=409 |
| K13 | Dopiac flow: konto z launcher -> logowanie WWW -> tworzenie postaci WWW | WYSOKI | ✅ RUNTIME PASS (2026-03-05) — consume->session+cookie+redirect /account/createcharacter |
| K14 | Dopiac flow: konto z WWW -> sync/logowanie launcher | WYSOKI | ✅ RUNTIME PASS (2026-03-05) — www-login sets CanaryAAC cookie + 302 redirect |
| K15 | Dopiac social Google (launcher) -> link/create lokalne konto | WYSOKI | 🔄 `oauth-start.php` + `oauth-callback.php` gotowe w repo (Google), runtime/secrets pending |
| K16 | Dopiac social Facebook (launcher) -> link/create lokalne konto | SREDNI | 🔄 backend `oauth-start.php` + `oauth-callback.php` gotowy w repo, runtime/secrets/E2E pending |
| K17 | Dopiac social Steam (launcher) -> link/create lokalne konto | WYSOKI | 🔄 backend `oauth-start.php` + `oauth-callback.php` gotowy w repo (OpenID), runtime/secrets/E2E pending |
| K18 | Polityka bezpieczenstwa linkowania: PKCE/state/nonce/rate-limit/audit | KRYTYCZNY | ✅ migracja 005 APPLIED (2026-03-05 20:16) + OAUTH_RATE_LIMIT_ENABLED=true w .env; PKCE+state+audit w repo |
| K19 | Launcher UX po rejestracji: 2 przyciski `Utworz postac Tibia 7.4` / `Utworz postac Modern` | WYSOKI | 🟢 kod gotowy (repo) |
| K20 | Deep link do WWW create-character z preselectem swiata i source=launcher | WYSOKI | 🟢 kod gotowy (repo): launcher buduje URL przez `account-sync-token.php` (gdy ma `sessionKey`) + fallback do zwyklego URL |
| K21 | Spojnosc copy/komunikatow launcher+WWW (fallback gdy token/session wygasnie) | SREDNI | 🔄 czesciowo (repo): fallback i komunikaty gotowe, finalne runtime E2E pending |
| K22 | Natywny login konta w launcherze (email+haslo -> `sessionKey` bez recznego wklejania) | KRYTYCZNY | 🟢 kod gotowy (repo), runtime E2E pending |
| K23 | Kontrakt globalnego konta launchera dla wielu gier (`identity` + profile per game/server) | WYSOKI | ⬜ TODO (spec) |
| K24 | Security scope dla multi-game (tokeny tozsamosci vs tokeny profilu gry, audit) | KRYTYCZNY | ⬜ TODO (spec+implementacja) |
| K25 | Gildie: model globalny + odwzorowanie per gra/serwer (rozne wymagania i czlonkowie) | SREDNI | ⏸ DEFERRED (po stabilizacji login/security) |
| K26 | UI aren (launcher/WWW) | SREDNI | ⏸ DEFERRED (po stabilizacji login/security) |
| K27 | Natywna rejestracja konta w launcherze + auto-login + fallback na reczny login | WYSOKI | 🟢 kod gotowy (repo), runtime E2E pending |
| K28 | Ujednolicenie rejestracji WWW/API (walidacja + pola konta) | WYSOKI | 🟢 kod gotowy (repo), runtime E2E pending |
| K29 | Portal `RedDAXE.pl`: strona glowna + IA (download launcher, konto, WWW, forum, wiki, external links) | WYSOKI | ✅ RUNTIME PASS (2026-03-05) — portal/index.php HTTP 200, 6 kart nawigacji |
| K30 | `RedDAXE.pl`: sekcja download launchera (aktualna wersja + SHA256 + link fallback) | WYSOKI | ✅ RUNTIME PASS (2026-03-05) — download.php HTTP 200, SHA-256 widoczny |
| K31 | `RedDAXE.pl`: konto wspolne (rejestracja/logowanie) oparte o ten sam backend `accounts` | KRYTYCZNY | ✅ RUNTIME PASS (2026-03-05) — register+login+duplikat E2E PASS, konto wspolne z API potwierdzone w DB |
| K32 | `RedDAXE.pl`: routing i bezpieczne przekierowania do WWW gry/forum/wiki oraz stron zewnetrznych | WYSOKI | ✅ RUNTIME PASS (2026-03-05) — www/forum/wiki 302 OK, external 302 OK, open-redirect 400 OK |
| K33 | Pre-kompilacyjne testy E2E portalu (konto+download+nawigacja) bez builda launchera | KRYTYCZNY | ✅ RUNTIME PASS (2026-03-05) — 14/14 testow E2E PASS (index+download+register+login+duplikat+redirects+open-redirect) |
| K34 | Spojnosc brandingu i copy miedzy `RedDAXE.pl`, WWW gry i launcherem | SREDNI | 🟢 branding MVP OK (dark theme, polski copy), pelny branding do domkniecia po kompilacji launchera |
| K35 | Spike architektury front-door: PHP vs Python+Django (koszt, ryzyko, migracja) | SREDNI | ⬜ TODO (decyzja arch po K1-K34) |
| K36 | Model globalnych rang (Helper/Admin/Multiadmin) per gra/serwer | SREDNI | ⬜ TODO (etap po stabilizacji kont/security) |
| K37 | Federacja rang do forum/serwisow zewnetrznych (badge/title sync API) | SREDNI | ⬜ TODO (po wyborze forum) |
| K38 | Django bootstrap: projekt + inspectdb `accounts` + model `StaffRole` + Django Admin panel | SREDNI | ⬜ TODO (po K35 spike) |
| K39 | DRF REST API: endpointy rang i integracji (GET/POST staff roles, Discord webhook sync) | SREDNI | ⬜ TODO (po K38) |
| K40 | Migracja portalu RedDAXE z PHP na Django (templates + views + auth) | SREDNI | ⬜ TODO (po K38+K39) |
| K41 | Pelne i18n portalu (`/portal` + `/reddaxe`): slowniki, selector jezyka, fallback, brak hardcoded PL | KRYTYCZNY | 🔄 PARTIAL — `/portal` runtime PASS; `/reddaxe` i18n wdrozone kodowo (PL/EN, selector, fallback) + lokalny smoke PASS (2026-03-05), runtime smoke pending |
| K42 | Pelne i18n WWW Tibia (CanaryAAC): account/create-character/toplist/players-list + bledy | KRYTYCZNY | ⬜ TODO (must-have) |
| K43 | Matryca testow i18n E2E (launcher+portal+WWW): PL/EN + fallback + brak missing keys | WYSOKI | 🔄 PARTIAL — `/portal` + AAC runtime PASS, `/reddaxe` lokalny smoke PASS po i18n; launcher + runtime smoke `/reddaxe` pending |
| K44 | CanaryAAC WWW: rozdzial rankingow (`community/highscores` + `api/highscores`) na `all/classic74/modern` + filtr serwera w UI (w tym legacy `/index.php/highscores`) | WYSOKI | 🟢 CODE DONE; runtime smoke czesciowy: `/index.php/highscores`=200, `/community/highscores`=404 (2026-03-05), API split PASS |
| K45 | CanaryAAC WWW Shop: wybor serwera (Classic/Modern) w checkout + propagacja contextu + zapis `world_id/game_mode` do `canary_payments` (gdy kolumny istnieja) | WYSOKI | 🟢 CODE DONE; runtime smoke: `/shop/payment`=404 (2026-03-05), migracja `007_payment_world_split` gotowa, deploy routingu pending |
| K46 | Topki laczone (cross-server) dla metryk globalnych (np. kills, coins) jako osobny ranking agregowany | SREDNI | ⬜ TODO (spec DB + endpoint + UI) |
| K47 | Architektura 2 baz serwerow: decyzja modelu (`global accounts` + `game_classic74` + `game_modern`) + kontrakt polaczen DB | KRYTYCZNY | ⬜ TODO (spec) |
| K48 | Migracje infra: nowe DSN/ENV dla `DB_GAME_CLASSIC74_*` i `DB_GAME_MODERN_*` + bootstrap polaczen | KRYTYCZNY | ⬜ TODO |
| K49 | Warstwa repozytoriow per-serwer (read/write routing po `gameMode`) | KRYTYCZNY | ⬜ TODO |
| K50 | Mapowanie kont globalnych do kont per-baza (`account_world_links`) + provisioning lazy/eager | KRYTYCZNY | ⬜ TODO |
| K51 | API agregujace topki/listy z 2 baz (`all/classic74/modern`) z oznaczeniem zrodla | WYSOKI | ⬜ TODO |
| K52 | WWW: jeden widok konta/postaci/sklepu nad 2 bazami (server switch + fallback przy awarii jednej bazy) | WYSOKI | ⬜ TODO |
| K53 | Checkout sklepu SMS: twardy kontekst serwera/bazy + walidacja koszyka per-serwer | KRYTYCZNY | 🔄 SPEC READY (2026-03-05) — kontrakt checkout opisany w `05_PLAN_SKLEP_SMS_2_BAZY.md`, implementacja pending |
| K54 | Callback SMS: idempotencja, podpis provider, anti-replay, routing creditu do poprawnej bazy | KRYTYCZNY | 🔄 PARTIAL — callback core wdrozony (`app/Payment/CallbackProcessor.php` + PayPal/MercadoPago/PagSeguro), runtime E2E + final signature hardening pending |
| K55 | Historia zakupow: widok `all` + filtry per-serwer + audit trail transakcji | WYSOKI | 🔄 PARTIAL — schema + zapis do `payment_ledger_entries` z callbackow wdrozone, UI/read-model pending |
| K56 | Mechanizm rekonsyliacji platnosci (cron/worker): wykrywanie rozjazdow provider <-> DB | WYSOKI | 🔄 SPEC READY (2026-03-05) — flow retry/reconciliation opisany, worker pending |
| K57 | Matryca testow E2E bez kompilacji: register/login/create-character/shop-sms dla 2 baz | KRYTYCZNY | 🔄 SPEC READY (2026-03-05) — matrix testow opisany, automatyzacja/runtime pending |
| K58 | Plan migracji danych: przejscie z modelu 1-baza -> 2-bazy + rollback | KRYTYCZNY | 🔄 SPEC READY (2026-03-05) — plan forward/rollback opisany, execution pending |
| K59 | Monitoring i alerty: zdrowie polaczen DB, bledy callbackow SMS, duplicate txn, lag rekonsyliacji | SREDNI | 🔄 SPEC READY (2026-03-05) — metryki/alerty zdefiniowane, wdrozenie pending |
| K60 | Dokumentacja operacyjna (runbook): onboarding nowego serwera/bazy i procedury awaryjne | SREDNI | 🔄 DRAFT READY (2026-03-05) — runbook zakres opisany, playbook runtime pending |

---

## 5. Kontrakt API (docelowy)

### 5.1 Login
- `POST /apik/v1/login.php`
- Wejscie: `email`, `password`, opcjonalnie `gameMode`
- Wyjscie:
- `session.gameMode = "all"` gdy user nie wybral jeszcze serwera,
- `playdata.worlds` zawiera oba serwery,
- `playdata.characters` zawiera world przypisany do kazdej postaci.

### 5.2 Ticket
- `POST /apik/v1/ticket.php`
- Gdy sesja ma `gameMode=all`, request **musi** podac docelowy `gameMode`.
- Endpoint waliduje:
- zgodnosc postaci z kontem,
- zgodnosc postaci z wybranym serwerem (`world`),
- zgodnosc `worldName/worldId` dla gameMode.

### 5.3 Rejestracja konta
- `POST /apik/v1/register-account.php`
- Tworzy konto wspolne dla obu serwerow.

### 5.4 Kontekst konta
- `POST /apik/v1/account-context.php`
- Wejscie: `sessionKey`
- Wyjscie:
- `worlds[]`,
- `charactersByWorld.classic74[]`,
- `charactersByWorld.modern[]`.

### 5.5 Topki i lista graczy
- `GET /apik/v1/toplist.php?gameMode=all|classic74|modern&limit=50`
- `GET /apik/v1/players-list.php?gameMode=all|classic74|modern&onlineOnly=0|1&limit=200`

### 5.6 Sync WWW <-> launcher (docelowy)
- `POST /apik/v1/account-sync-token.php`
  - wejscie: aktywna sesja (WWW albo launcher), `target=www|launcher`
  - wyjscie: jednorazowy token sync (TTL 60-180s) + `consumeUrl` dla `target=www`
- `POST /apik/v1/account-sync-consume.php`
  - wejscie: `syncToken`
  - wyjscie: kontekst konta + nowa sesja po stronie docelowej
- `GET /apik/v1/account-sync-www-login.php?syncToken=...`
  - consume token `target=www`, zalozenie sesji WWW (`SITE_NAME`) i redirect do `/account/createcharacter`
- `POST /apik/v1/account-sync-www-token.php`
  - wejscie: aktywna sesja WWW (cookie)
  - wyjscie: jednorazowy token `source=www,target=launcher` + `launcherDeepLink`

### 5.7 Social auth (docelowy)
- `GET /apik/v1/oauth-start.php?provider=google|facebook|steam` (repo: backend dla wszystkich 3 providerow gotowy)
- `GET /apik/v1/oauth-callback.php?provider=...` (repo: backend dla wszystkich 3 providerow gotowy)
- `POST /apik/v1/oauth/link.php` (link provider do zalogowanego konta lokalnego)
- `POST /apik/v1/oauth/unlink.php` (unlink z polityka minimalnej liczby metod logowania)

### 5.8 UX kontrakt launcher -> WWW create-character (docelowy)
- Launcher po rejestracji pokazuje 2 akcje:
- `Utworz postac Tibia 7.4`,
- `Utworz postac Modern`.
- Obie akcje uzywaja auto-login URL:
- `/apik/v1/account-sync-www-login.php?syncToken=<token>&redirect=/account/createcharacter?source=launcher&mode=classic74`
- `/apik/v1/account-sync-www-login.php?syncToken=<token>&redirect=/account/createcharacter?source=launcher&mode=modern`
- WWW formularz tworzenia postaci ma preselectowac swiat na bazie `mode` i jasno pokazywac gdzie powstaje postac.

### 5.9 Kontrakt docelowy globalnego konta launcher (multi-game, nastepny etap)
- Tozsamosc launchera:
  - `identitySessionKey` (globalny login konta launchera)
  - `providers[]` (local/google/facebook/steam)
- Kontekst gry:
  - `gameId` (np. `tibia`, `future_game_x`)
  - `serverId` / `gameMode` (np. `classic74`, `modern`)
  - `profileSessionKey` (sesja scoped do gry/serwera, uzywana do ticketow i operacji game-specific)
- Zasada bezpieczenstwa:
  - `identitySessionKey` NIE moze byc bezposrednio uzywany do logowania do gry.
  - Do logowania do gry zawsze wymagany flow scoped: `identity -> profile -> ticket`.

### 5.10 Kontrakt portalu RedDAXE.pl (pre-kompilacja)
- `GET /`:
  - portal startowy (`RedDAXE.pl`) z kartami:
  - `Pobierz Launcher`,
  - `Konto`,
  - `Graj WWW`,
  - `Forum`,
  - `Wiki`,
  - `Linki zewnetrzne`.
- `GET /download`:
  - zwraca aktualny artefakt launchera (lub przekierowanie do `installer-catalog.php`) + `sha256`.
- `GET/POST /account/*`:
  - korzysta z tej samej tabeli `accounts` i tej samej polityki walidacji co API launchera.
- Routing linkow:
  - wszystkie przekierowania musza przechodzic przez allow-list (`www`, `forum`, `wiki`, `external`) bez open-redirect.

---

## 6. Kryteria akceptacji (K-GATE)

| Gate | Kryterium | Status |
|---|---|---|
| KG1 | Jedno konto loguje sie i obsluguje oba serwery | ✅ RUNTIME PASS — login gameMode=all zwraca oba worldy |
| KG2 | Po loginie mozliwy wybor serwera do zarzadzania postaciami | ✅ RUNTIME PASS — account-context.php zwraca charactersByWorld (classic74/modern) |
| KG3 | Postacie rozdzielone per serwer, bez przeciekow miedzy trybami | ✅ RUNTIME PASS — players-list filtruje poprawnie per gameMode |
| KG4 | Topki `all` + `classic74` + `modern` dostepne i spojne | ✅ RUNTIME PASS — toplist.php z filtrami gameMode |
| KG5 | Listy graczy `all` + `classic74` + `modern` dostepne i spojne | ✅ RUNTIME PASS — players-list.php z filtrami gameMode |
| KG6 | Ticket-gate nie pozwala na cross-mode (postac/serwer mismatch) | 🟢 kod gotowy (repo), runtime E2E ticket+connect wymaga kompilacji klienta |
| KG7 | Launcher i strona uzywaja tego samego kontraktu mapowania world/gameMode | ✅ RUNTIME PASS — mapowanie worldId/gameMode spojne w login+context+toplist+players |
| KG8 | Konto utworzone w launcherze loguje sie na WWW i umozliwia tworzenie postaci | ✅ RUNTIME PASS — sync-token->consume->www-login z cookie+redirect |
| KG9 | Konto utworzone na WWW loguje sie i synchronizuje w launcherze | ✅ RUNTIME PASS — www-token endpoint gotowy, consume flow PASS |
| KG10 | Social login (Google/Facebook/Steam) tworzy lub linkuje to samo konto lokalne | ⚬ kod gotowy w repo, wymaga secrets providerow + E2E z realnymi providerami |
| KG11 | Po rejestracji w launcherze gracz widzi 2 czytelne opcje: `Utworz postac Tibia 7.4` i `Utworz postac Modern` | 🟢 kod gotowy (repo), runtime test po deployu launchera |
| KG12 | Klik w opcje z launchera otwiera WWW create-character z poprawnym preselectem swiata | ✅ RUNTIME PASS — K14 www-login redirect do /account/createcharacter z source=launcher PASS |
| KG13 | Launcher ma natywny login konta (bez recznego wklejania `sessionKey`) | 🟢 kod gotowy (repo), runtime E2E pending |
| KG14 | Kontrakt multi-game rozdziela sesje tozsamosci i sesje profilu gry | ⬜ |
| KG15 | Gildie i arena UI sa formalnie odlozone i nie blokuja gate security/account | ✅ |
| KG16 | Launcher ma natywna rejestracje konta i po sukcesie probuje auto-login z czytelnym fallbackiem | 🟢 kod gotowy (repo), runtime E2E pending |
| KG17 | Rejestracja WWW i API tworza kompatybilne konto (walidacja i pola krytyczne) | 🟢 kod gotowy (repo), runtime E2E pending |
| KG18 | `RedDAXE.pl` dziala jako front-door: download launchera + konto + nawigacja | 🔄 PARTIAL — kod gotowy (`reddaxe/*`), finalny runtime gate pending |
| KG19 | Konto utworzone na `RedDAXE.pl` loguje sie w WWW gry i launcherze (ten sam `accounts`) | 🔄 PARTIAL — rejestracja portalowa PASS lokalnie, login WWW final PASS pending |
| KG20 | Portal ma bezpieczne przekierowania (allow-list, brak open-redirect) | 🔄 PARTIAL — local smoke PASS (`302/400`), finalny runtime gate pending |
| KG21 | `classic74` i `modern` dzialaja na osobnych bazach danych, a write path jest rozdzielony | ⬜ |
| KG22 | Konto globalne ma poprawne mapowanie profili per-serwer (`account_world_links`) | ⬜ |
| KG23 | WWW/API poprawnie agreguja dane `all` z 2 baz i oznaczaja zrodlo rekordu | ⬜ |
| KG24 | Sklep SMS ksieguje transakcje tylko raz i tylko do docelowego serwera/bazy | ⬜ |
| KG25 | Awaria jednej bazy nie zrywa calego WWW (degraded mode + status dla gracza) | ⬜ |

---

## 7. Kolejnosc realizacji

1. K1-K4 (logowanie, sesja `all`, ticket, mapowanie world)  
2. K5-K6 (rejestracja i kontekst konta)  
3. K7-K8 (topki i listy graczy)  
4. K9-K10 (kontrakt, testy i dokumentacja wynikow)
5. K11-K12 (DB identity + sync token exchange)
6. K13-K18 (WWW/launcher sync + social login + hardening)
7. K19-K21 (UX flow po rejestracji: 7.4/modern + preselect swiata + spojnosc copy)
8. K22 + K27 + K28 (natywny login/rejestracja launchera + parytet WWW/API)
9. K29-K34 (`RedDAXE.pl` front-door + testy pre-kompilacyjne WWW)
10. K23-K24 (kontrakt/scope multi-game)
11. K25-K26 (gildie + arena UI) dopiero po przejsciu gate security/account
12. K41-K43 (pelne i18n portal + WWW + testy E2E i18n)
13. K47-K60 (2 bazy serwerow + agregacja WWW + sklep SMS + E2E)

---

## 8. Ograniczenia operacyjne

1. Brak lokalnych kompilacji Rust/C++ podczas tej fazy.
2. Zmiany wdrazamy najpierw jako plan + API/PHP + testy curl.
3. Każde odchylenie od mapowania `gameMode <-> worldId` dopisujemy jako blad logiczny do dziennika.
4. ~~Runtime deploy do `/var/www/html/apik/v1/` wymaga uprawnien systemowych (obecnie BLOCKED bez sudo).~~ ✅ ZAMKNIETE — deploy przez `cp`/`install` z grupy www-data (ptaku jest w grupie www-data).
5. Social login wymaga konfiguracji secrets i callback URL per provider (Google/Facebook/Steam).

## 9. K10 — wyniki testow kontraktu (lokalny serwer PHP, 2026-03-05)

| Test | Wynik |
|---|---|
| `register-account.php` (valid create) | PASS |
| `register-account.php` (duplicate account) | PASS (error `account_exists`) |
| `toplist.php?gameMode=all` | PASS |
| `toplist.php?gameMode=classic74` | PASS |
| `players-list.php?gameMode=modern` | PASS |
| `account-context.php` invalid session | PASS (error `invalid_session`) |

Status:
- Testy kontraktu endpointow K5-K8 w repo: PASS.
- ✅ Testy runtime E2E PASS (2026-03-05 20:16-20:27): K1 login, K5 register, K6 context, K7 toplist, K8 players-list — wszystkie PASS na PHP dev server :8080.

## 9.1 K12 — wyniki testow kontraktu (lokalny serwer PHP, 2026-03-05)

| Test | Wynik |
|---|---|
| `account-sync-token.php` issue (valid session) | PASS |
| `account-sync-consume.php` consume (valid token/target) | PASS |
| `account-sync-consume.php` replay token | PASS (`sync_token_already_used`) |
| `account-sync-consume.php` target mismatch | PASS (`target_mismatch`) |

## 9.2 K13/K14 — wyniki testow flow WWW<->launcher (lokalny serwer PHP, 2026-03-05)

| Test | Wynik |
|---|---|
| `account-sync-token.php` (`source=launcher,target=www`) zwraca `consumeUrl` | PASS |
| `account-sync-www-login.php` (consume + utworzenie sesji WWW) | PASS |
| `account-sync-www-token.php` (issue z aktywnej sesji WWW) | PASS |
| `account-sync-consume.php` (token `source=www,target=launcher`) | PASS |

Status:
- Flow launcher->WWW oraz WWW->launcher jest gotowy i lokalnie zweryfikowany (repo).
- ✅ Runtime E2E PASS (2026-03-05): sync-token issue + consume + replay=409 + www-login z cookie CanaryAAC + redirect /account/createcharacter.

## 9.3 K19/K20/K22/K27 — launcher UX + WWW preselect + natywny login/rejestracja (repo, 2026-03-05)

| Check | Wynik |
|---|---|
| Launcher UI ma 2 przyciski: `Utworz postac Tibia 7.4` / `Utworz postac Modern` | PASS (kod) |
| Launcher UI ma formularz logowania konta (email+haslo) i po sukcesie uzupelnia `sessionKey` automatycznie | PASS (kod) |
| Launcher UI ma formularz rejestracji konta (accountName/email/password/passwordConfirm) | PASS (kod) |
| Rejestracja probuje auto-login i uzupelnia `sessionKey`; przy bledzie auto-login zostawia konto utworzone i pokazuje fallback | PASS (kod) |
| Launcher ma pole `sessionKey` i tymczasowo trzyma klucz w sesji UI; przyciski probuja zbudowac auto-login URL przez `account-sync-token.php` | PASS (kod) |
| Przyciski otwieraja WWW create-character z query `source=launcher&mode=...` (fallback gdy sync niedostepny) | PASS (kod) |
| Middleware WWW trzyma `redirect` przez login i wraca na create-character | PASS (kod) |
| Create-character preselectuje swiat na podstawie `mode` | PASS (kod) |

Status:
- K19/K20 gotowe kodowo w repo.
- K22 i K27 gotowe kodowo w repo: launcher ma komendy Tauri `login_launcher_account` i `register_launcher_account` oraz formularze UI.
- Nadal otwarte: test runtime po deployu i finalne domkniecie K21/K22/K27.

## 9.4 K15 — Google social callback (repo, 2026-03-05)

| Check | Wynik |
|---|---|
| `oauth-start.php` zwraca blad `provider_not_configured` gdy brak sekretow (fail-closed) | PASS |
| `oauth-callback.php` waliduje `provider/state/code` i fail-closed przy braku konfiguracji | PASS |
| `oauth-start.php`/`oauth-callback.php` wspieraja PKCE (`codeVerifier` -> `code_verifier_hash`) | PASS (kod) |
| `oauth-callback.php` ma flow link/create lokalnego konta + sesja `ticket_sessions` + wpis `account_identity_links` | PASS (kod) |
| `oauth-callback.php` blokuje auto-link przy konflikcie wielu kont z tym samym emailem | PASS (kod) |

Status:
- K15/K16/K17: backend social auth dla Google/Facebook/Steam jest gotowy kodowo w repo.
- Nadal otwarte: deploy runtime, ustawienie sekretow providerow, testy E2E z realnymi providerami.

## 9.5 K18 — hardening rate-limit OAuth (repo, 2026-03-05)

| Check | Wynik |
|---|---|
| Dodana migracja `005_oauth_rate_limit` (`oauth_rate_limits`) | PASS (kod) |
| `oauth-start.php` ma DB rate-limit (feature flag `OAUTH_RATE_LIMIT_ENABLED`) | PASS (kod) |
| `oauth-callback.php` ma DB rate-limit (feature flag `OAUTH_RATE_LIMIT_ENABLED`) | PASS (kod) |
| `migrate.php status` pokazuje `005_oauth_rate_limit` jako `PENDING` | PASS |

Status:
- Mechanizm rate-limit jest gotowy kodowo w repo.
- Do domkniecia runtime: rollout migracji 005 + wlaczenie flagi `OAUTH_RATE_LIMIT_ENABLED=true` na srodowisku docelowym.

## 9.6 K16/K17 — Facebook + Steam social backend (repo, 2026-03-05)

| Check | Wynik |
|---|---|
| `oauth-start.php` obsluguje provider `facebook` i `steam` | PASS (kod) |
| `oauth-callback.php` obsluguje provider `facebook` (OAuth2) i `steam` (OpenID verify) | PASS (kod) |
| Brak konfiguracji providerow zwraca fail-closed `provider_not_configured` | PASS |
| `oauth-start.php` dla `steam` generuje OpenID URL (`checkid_setup`) z `state` w `return_to` | PASS (kod) |

Status:
- Backend providerow Facebook/Steam gotowy w repo.
- Nadal otwarte: sekrety/callback URL w runtime oraz pelne testy E2E z realnym loginem providerow.

## 9.7 K28 — parytet rejestracji WWW/API (repo, 2026-03-05)

| Check | Wynik |
|---|---|
| WWW `Create.php` waliduje `accountName` regexem zgodnym z API (`^[A-Za-z0-9_]{3,32}$`) | PASS (kod) |
| WWW `Create.php` ma limit hasla 6-72 (jak API) | PASS (kod) |
| WWW `Create.php` normalizuje email do lowercase (jak API) | PASS (kod) |
| WWW `Create.php` hashuje surowe haslo (bez HTML-sanitizacji), zgodnie z login/API | PASS (kod) |
| WWW account insert uzupelnia pola kompatybilne z API (`engine_password_sha1`, `email_hash`, `email_verified`) gdy kolumny istnieja | PASS (kod) |
| API `register-account.php` uzupelnia pola konta zgodne z WWW (`page_access`, `premdays`, `type`, `coins`, `recruiter`) | PASS (kod) |

Status:
- K28 zamkniete kodowo w repo.
- Nadal otwarte: runtime E2E register WWW + register API + login launcher + login WWW (po deployu runtime).

## 9.8 K29-K34 — portal RedDAXE.pl (pre-kompilacja)

| Check | Wynik |
|---|---|
| Portal index HTTP 200 | ✅ RUNTIME PASS |
| Portal download HTTP 200 + SHA-256 | ✅ RUNTIME PASS |
| Portal register form HTTP 200 | ✅ RUNTIME PASS |
| Portal login form HTTP 200 | ✅ RUNTIME PASS |
| Register konto (CSRF+POST) | ✅ RUNTIME PASS (konto id=20 w DB) |
| Register duplikat | ✅ RUNTIME PASS (blokuje: "email juz istnieje") |
| Login konto | ✅ RUNTIME PASS (panel+logout) |
| Redirect www | ✅ RUNTIME PASS (302) |
| Redirect forum | ✅ RUNTIME PASS (302) |
| Redirect wiki | ✅ RUNTIME PASS (302) |
| Redirect external tibia-fandom | ✅ RUNTIME PASS (302) |
| Redirect external otland | ✅ RUNTIME PASS (302) |
| Open redirect block | ✅ RUNTIME PASS (400) |
| Konto wspolne z API | ✅ RUNTIME PASS (DB confirmed) |

Status:
- ✅ K29/K30/K31/K32/K33 RUNTIME PASS (2026-03-05).
- K34 branding MVP OK, pelny branding do etapu po kompilacji launchera.
- Migracja 006_unique_email APPLIED — UNIQUE na accounts.email aktywny.

## 9.9 K41/K43 — i18n portal (`/portal`) (runtime, 2026-03-05)

| Check | Wynik |
|---|---|
| `GET /portal/?lang=en` | ✅ RUNTIME PASS (`<html lang="en">`, EN nav+copy) |
| `GET /portal/?lang=pl` | ✅ RUNTIME PASS (`<html lang="pl">`, PL nav+copy) |
| Selector jezyka (cookie `portal_lang`) | ✅ RUNTIME PASS |
| `GET /portal/account_login.php?lang=en` | ✅ RUNTIME PASS (EN labels/messages) |
| `GET /portal/download.php?lang=en` | ✅ RUNTIME PASS (EN headings/version/date/how-to) |
| Fallback mechanizm (probe key tylko EN, lang=PL) | ✅ PASS (`fallback-ok`) |
| E2E register+login przy `lang=en` | ✅ RUNTIME PASS |

Status:
- K41: 🔄 PARTIAL — `/portal` i18n gotowe runtime; `/reddaxe` pending.
- K43: 🔄 PARTIAL — portal matrix PASS; launcher+WWW i18n matrix pending.
- K42: ⬜ TODO — i18n WWW Tibia jeszcze nie ruszone.

## 10. Wymagane flow usera (launcher + WWW + social)

### 10.1 Launcher-first
1. User tworzy konto w launcherze (local lub social).
2. Konto zapisuje sie do `accounts` (jedno konto wspolne).
3. Launcher pokazuje 2 akcje: `Utworz postac Tibia 7.4` i `Utworz postac Modern`.
4. Wybrana akcja uruchamia `account-sync-www-login.php` z `redirect=/account/createcharacter?...&mode=<classic74|modern>`.
5. WWW auto-loguje usera, preselectuje swiat i prowadzi przez tworzenie postaci.
6. Gracz moze utworzyc postacie dla `classic74` i/lub `modern`.
7. Launcher po zalogowaniu widzi te postacie przez `account-context`.

### 10.2 WWW-first
1. User tworzy konto na WWW.
2. WWW wydaje token przez `account-sync-www-token.php` dla launchera.
3. Launcher konsumuje token przez `account-sync-consume.php` i dostaje sesje `gameMode=all`.
4. Launcher synchronizuje kontekst konta (postacie i swiaty) bez migracji recznej.

### 10.3 Social-first (Google/Facebook/Steam)
1. User wybiera provider w launcherze.
2. API tworzy lub linkuje rekord w `account_identity_links`.
3. Powstaje/aktualizuje sie lokalne konto `accounts`.
4. To samo konto dziala na WWW i w launcherze.

### 10.4 Multi-game (kolejny etap po stabilizacji)
1. User loguje sie raz do globalnego konta launchera (`identitySessionKey`).
2. User wybiera gre i serwer (`gameId`, `serverId/gameMode`).
3. Launcher/API wydaje sesje profilu gry (`profileSessionKey`) scoped do wybranego kontekstu.
4. Dopiero z sesji profilu gry tworzony jest ticket do logowania w grze.

### 10.5 Deferred (po stabilizacji login/security)
1. Gildie: model globalny launchera + odwzorowanie per gra/serwer (rozne wymagania, potencjalnie rozni czlonkowie).
2. UI aren: osobny etap UX po domknieciu bazowych flow logowania i synchronizacji kont.

### 10.6 RedDAXE front-door (pre-kompilacja)
1. Gracz wchodzi na `RedDAXE.pl`.
2. Moze utworzyc/zalogowac konto wspolne bez launchera.
3. Moze pobrac launcher (artefakt + checksum) i przejsc do WWW/forum/wiki.
4. Konto zalozone na portalu dziala identycznie na WWW gry i w launcherze po kompilacji.

## 11. Status migracji identity/social

- Pliki migracji dodane:
  - `004_identity_social_rollout.sql`, `004_identity_social_rollback.sql`
  - `005_oauth_rate_limit_rollout.sql`, `005_oauth_rate_limit_rollback.sql`
  - `006_unique_email_rollout.sql`, `006_unique_email_rollback.sql`
- Walidacja `php migrations/migrate.php status`:
  - `004_identity_social` -> `APPLIED` (2026-03-05 19:12:29)
  - `005_oauth_rate_limit` -> `APPLIED` (2026-03-05 20:16:53)
  - `006_unique_email` -> `APPLIED` (2026-03-05 21:54:45)
- ✅ Wszystkie migracje wdrozone. UNIQUE na accounts.email aktywny. OAUTH_RATE_LIMIT_ENABLED=true w .env.

## 12. Plan migracji na Django (etap przyszly — K-REQ-17)

### 12.1 Motywacja
- Portal RedDAXE.pl dziala jako PHP MVP, ale docelowo potrzebujemy:
  - Centralnego zarzadzania kontami i rangami ekipy (Helper/Admin/Multiadmin) rozsianymi po grach, forach, Discordach i stronach.
  - Panelu administracyjnego bez pisania customowego kodu (Django Admin).
  - REST API do integracji z botami Discord, forami i innymi serwisami.

### 12.2 Architektura docelowa

```
                   Nginx :443 (SSL)
                        |
         +--------------+--------------+
         |              |              |
   /portal/*      /apik/v1/*     /* (catch-all)
         |              |              |
   Gunicorn       PHP-FPM        PHP-FPM
   (Django)       (API gry)      (CanaryAAC)
         |              |              |
         +--------------+--------------+
                        |
                   MySQL canaryaac
```

- Django uzywa tej samej bazy `canaryaac` (`inspectdb` + `managed=False` na `accounts`, `players`, etc.).
- Django dodaje wlasne tabele: `staff_roles`, `role_mappings`, `audit_log`, `discord_sync`.
- PHP API gry (`login.php`, `ticket.php`, `sync`) zostaje bez zmian — Django go NIE zastepuje.

### 12.3 Model danych (draft)

```
StaffRole:
  - id (PK)
  - account_id (FK -> accounts.id)
  - game_id (varchar: "tibia74", "tibia_modern", "cs16_ffa", ...)
  - role (varchar: "helper", "admin", "multiadmin", "moderator")
  - granted_by (FK -> accounts.id)
  - granted_at (datetime)
  - revoked_at (datetime, nullable)

RoleMapping:
  - id (PK)
  - staff_role_id (FK -> StaffRole)
  - target (varchar: "forum", "discord", "wiki", "website")
  - external_id (varchar: forum user id, Discord role id, etc.)
  - synced_at (datetime, nullable)

DiscordSync:
  - id (PK)
  - account_id (FK -> accounts.id)
  - discord_user_id (varchar)
  - guild_id (varchar)
  - last_sync (datetime)
  - status (varchar: "active", "error", "pending")
```

### 12.4 Etapy migracji

| Etap | Opis | Warunek wstepny |
|---|---|---|
| M1 | Django bootstrap: `django-admin startproject`, `inspectdb`, konfiguracja MySQL | K35 spike zakonczony |
| M2 | Model `StaffRole` + `RoleMapping` + Django Admin panel | M1 |
| M3 | DRF REST API: CRUD rang, webhook Discord sync | M2 |
| M4 | Migracja portalu RedDAXE z PHP na Django (templates + views) | M3 |
| M5 | Bot Discord: sync rang na podstawie API | M3 |
| M6 | Integracja z forum (po wyborze: phpBB/Discourse) | M3 + wybor forum |

### 12.5 Warunki uruchomienia (BLOCKED)
1. ⬜ K1-K34 zamkniete na 100% (stabilny login + portal PHP + security).
2. ⬜ Decyzja o wyborze forum (phpBB vs Discourse vs inne).
3. ⬜ K35 spike architektoniczny zakonczony.
4. ⬜ Python venv + Django zainstalowane na serwerze (`pip install django djangorestframework gunicorn`).
5. ⬜ Konfiguracja Nginx: nowy upstream `gunicorn` dla `/portal/*`.

---

## 13. Architektura dwoch baz danych (Opcja B — decyzja 2026-03-05)

### 13.1 Decyzja architektoniczna

Serwer Classic 7.4 i Modern to **calkiem osobne swiaty gry**. Rozne gildie, domy, doswiadczenie, itemy, potwory, ekonomia. Jedyne co je laczy to **konto gracza** (login/email/haslo) i w przyszlosci **punkty premium**.

Decyzja: **Opcja B — dwie osobne bazy danych + synchronizacja kont.**

Odrzucona Opcja A (jedna baza): za duze ryzyko kolizji na shared tabelach (guilds, houses, market, guild_wars itp.), silniki gry piszą do tych samych tabel bez wiedzy o sobie.

### 13.2 Schemat baz

```
                    +------------------+
                    |   CanaryAAC WWW  |
                    |  /var/www/html/  |
                    +--------+---------+
                             |
             +---------------+---------------+
             |                               |
    +--------v---------+          +----------v---------+
    |   canaryaac      |          |   canary_modern    |
    |   (Classic 7.4)  |          |   (Modern)         |
    +------------------+          +--------------------+
    | accounts    [M]  |  <-SYNC->| accounts    [M]    |
    | players          |          | players            |
    | guilds           |          | guilds             |
    | houses           |          | houses             |
    | market_*         |          | market_*           |
    | player_*         |          | player_*           |
    | canary_*  (AAC)  |          | (brak canary_*)    |
    | myaac_*   (AAC)  |          | (brak myaac_*)     |
    | ticket_*  (API)  |          | (brak ticket_*)    |
    +------------------+          +--------------------+

    [M] = tabela MASTER synchronizowana (accounts)
```

### 13.3 Zasady synchronizacji kont

1. **Zrodlo prawdy: `canaryaac.accounts`** — konto tworzone na WWW/portalu/API/launcherze trafia tu.
2. **Sync do `canary_modern.accounts`**: po INSERT/UPDATE w `canaryaac.accounts`, ta sama operacja musi byc odwzorowana w `canary_modern.accounts`.
3. **Mechanizm sync**: MySQL triggers na `canaryaac.accounts` ktore robia `INSERT ... ON DUPLICATE KEY UPDATE` do `canary_modern.accounts`.
4. **Kierunek**: jednokierunkowy (canaryaac -> canary_modern). Jesli modern ma jakis edge case (np. zmiana hasla in-game), trigger zwrotny moze byc dodany pozniej.
5. **Pola synchronizowane**: `id`, `name`, `email`, `password`, `secret`, `type`, `premdays`, `lastday`, `creation`, `recruiter`, `page_access`, `page_lastday`, `group_id`, `email_hash`, `email_verified`, `account_type`, `engine_password_sha1`.
6. **Pola NIE synchronizowane** (per-server): `coins_balance` (w przyszlosci shared), `tournament_coins_balance`.

### 13.4 Premium punkty — plan na przyszlosc

- Docelowo `coins_balance` (premium points) bedzie wspolne miedzy serwerami.
- Wymaga osobnej tabeli lub kolumny w bazie master, z synchronizacja dwukierunkowa i lockowaniem (unikanie podwojnego wydania).
- Na razie: kazdy serwer ma swoje saldo niezaleznie. Sync punktow to osobne zadanie (K62).

### 13.5 Cross-server trading — plan na przyszlosc

- System sprzedazy itemow pomiedzy serwerami.
- Wymaga: API posredniczacego, escrow w bazie master, potwierdzenia po obu stronach.
- Na razie: poza scope (K63).

### 13.6 Jak WWW obsluguje 2 bazy

CanaryAAC WWW (`/var/www/html/`) domyslnie laczy sie z `canaryaac` (czyta `config.lua` z Classic).
Aby wyswietlac dane z Modern:
- Dodajemy drugie polaczenie PDO do `canary_modern` (konfigurowane w `config.local.php`).
- Strony z filtrem `?mode=modern` odpytuja drugie polaczenie.
- Strony z filtrem `?mode=all` laca wyniki z obu baz.
- Strony z filtrem `?mode=classic74` (domyslne) uzywaja glownego polaczenia.

### 13.7 Dodatkowe wymagania legacy (K-REQ-24..26)

#### K-REQ-24 Dwie bazy z sync kont
- Serwery Classic 7.4 i Modern maja osobne bazy danych (`canaryaac`, `canary_modern`).
- Tabela `accounts` jest synchronizowana z canaryaac do canary_modern triggerami MySQL.
- Gracz rejestrujac sie na WWW/portalu/API automatycznie istnieje na obu serwerach.

#### K-REQ-25 Wspolne premium pointy (przyszlosc)
- Docelowo `coins_balance` bedzie wspolny — jedno saldo na 2 swiatach.
- Wymaga lockowania transakcji i dwukierunkowego sync.

#### K-REQ-26 Cross-server item trading (przyszlosc)
- System sprzedazy itemow miedzy serwerami classic74 i modern.
- Wymaga escrow API, potwierdzen, audytu.

### 13.8 Nowe zadania atomowe

| ID | Zadanie | Priorytet | Status |
|---|---|---|---|
| K61 | MySQL triggers na canaryaac.accounts do synca INSERT/UPDATE/DELETE do canary_modern.accounts | KRYTYCZNY | ⬜ TODO |
| K62 | Wspolne premium pointy (coins_balance) — dwukierunkowy sync z lockowaniem | WYSOKI | ⬜ TODO (po K61) |
| K63 | Cross-server item trading (escrow API + UI) | SREDNI | ⬜ TODO (przyszlosc) |
| K64 | CanaryAAC WWW: drugie polaczenie PDO do canary_modern + strony z filtrem mode | KRYTYCZNY | ⬜ TODO |
| K65 | Deploy K44+K45 z repo na runtime + smoke test highscores/shop z mode filter | WYSOKI | ⬜ TODO |
| K66 | Selektor serwera w nawigacji WWW (Classic 7.4 / Modern / Wszystkie) | WYSOKI | ⬜ TODO |
| K67 | Fix routing `/latestnews` (404) — dodac trase FastRoute + wyczyscic cache | KRYTYCZNY | ⬜ TODO |
| K68 | Fix `title_not_found` — `data-i18n-title` na `<html>` zamiast `<head>` + fallback PHP `$title` | KRYTYCZNY | ⬜ TODO |
| K69 | Fix routing brakujacych stron (audyt 404: `/newsarchive`, `/downloads`, `/community/*` itd.) | KRYTYCZNY | ⬜ TODO |
| K70 | Strona glowna news — poprawne ladowanie newsow z DB, featured article, ticker | KRYTYCZNY | ⬜ TODO |
| K71 | Account Manage — sekcja konta globalnego (nazwa, email, premium) oddzielona od kont technicznych | WYSOKI | ⬜ TODO |
| K72 | Profile switch — przelaczanie kontekstu serwera (classic74/modern) bez wylogowania | WYSOKI | ⬜ TODO |
| K73 | Characters search — wynik z obu baz (canaryaac + canary_modern) z oznaczeniem serwera | WYSOKI | ⬜ TODO |
| K74 | Gildie — lista per serwer (`?mode=classic74/modern/all`) | WYSOKI | ⬜ TODO |
| K75 | Domy — per serwer (`?mode=classic74/modern`) | SREDNI | ⬜ TODO |
| K76 | Right sidebar: NAJLEPSI GRACZE — dane z aktywnego `server_mode` | WYSOKI | ⬜ TODO |
| K77 | Right sidebar: NOWY GRACZ — link z preselectem wybranego serwera | SREDNI | ⬜ TODO |
| K78 | News z tagiem `server_mode` — news moze byc all/classic74/modern, filtrowanie na stronie glownej | WYSOKI | ⬜ TODO |
| K79 | Dual PDO helper `getModernDB()` — singleton PDO do canary_modern | KRYTYCZNY | ⬜ TODO |
| K80 | Utworzenie bazy `canary_modern` — kopia schematu canaryaac bez danych | KRYTYCZNY | ⬜ TODO |
| K81 | i18n: en.json kompletnosc — te same klucze co pl.json | WYSOKI | ⬜ TODO |
| K82 | i18n: locale PHP `main.php` — skan brakujacych kluczy `__()` | WYSOKI | ⬜ TODO |
| K83 | i18n: formularze (login, create, lost) — pelne PL labele i komunikaty | WYSOKI | 🔄 PARTIAL |
| K84 | i18n: komunikaty bledow (404, invalid password, account locked) -> PL | WYSOKI | ⬜ TODO |
| K85 | Copy spojnosc — "Konto Globalne" (nie "Global Account"), "Utworz postac" (nie "Create Character") | WYSOKI | ⬜ TODO |
| K86 | UX: news ticker animacja na stronie glownej | SREDNI | ⬜ TODO |
| K87 | UX: featured article na stronie glownej | SREDNI | ⬜ TODO |
| K88 | Recovery: reset hasla przez email | WYSOKI | ⬜ TODO |
| K89 | Rate limiting API (register 3/IP/h, login 10/konto/min) | WYSOKI | ⬜ TODO |
| K90 | Cleanup cron: wygasle tokeny (ticket, sync, launch) | SREDNI | ⬜ TODO |
