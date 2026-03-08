# Taski wdrozeniowe - globalne gildie i globalne topki

Status: P0 w toku  
Data: 2026-03-08  
Powiazany dokument bazowy: `plan-globalne-gildie-i-topki.md`

## 0. Snapshot wykonania na dzis

Stan prac `2026-03-08`:

- [x] Przygotowano pierwszy draft migracji `global_guilds` i `global_guild_instances`.
- [x] Poprawiono draft migracji pod `owner_global_account_id`, scoped unique dla instancji gildii i binarne porownanie `guild_name_normalized`.
- [x] Przygotowano helper backendowy do rezerwacji / attachowania gildii.
- [x] Dodano draft resolvera ownera gildii:
  - shared DB => tymczasowy fallback do `accounts.id`
  - osobny `global_accounts` bez mapowania => fail-closed
- [x] Podpieto draft global guild registry pod flow zakladania gildii w `WWW Tibia`.
- [x] Podpieto legacy flow `system/pages/guilds/create.php` pod global guild registry.
- [x] Dodano draft endpointow API dla gildii:
  - lookup po nazwie
  - `reserve-or-attach`
- [x] Dodano endpoint listy instancji gildii.
- [x] Dodano endpoint heartbeat `last_seen_at` dla gildii / instancji.
- [x] Dodano draft repair migration `009_global_guild_registry_repair_and_events`.
- [x] Dodano draft audit/event logu `global_guild_events`.
- [x] Dodano report-only endpoint reconcile dla globalnych gildii.
- [x] Dodano dedykowany runner `migrate-global-guilds.php` dla migracji registry na `GLOBAL_DB`.
- [x] Dodano read-only preflight `global-guilds-db-preflight.php`.
- [x] Wykonano testy live DB dla `GLOBAL_DB` i lokalnego DB.
- [x] Dodano draft migracji `010_global_guild_account_links`.
- [x] Dodano dry-run backfill `backfill-global-guild-account-links.php`.
- [x] Odpalono realny rollout migracji `008/009/010` na testowym `GLOBAL_DB`.
- [x] Odpalono realny backfill `account_world_links` na testowym `GLOBAL_DB`.
- [x] Dopieto resolver ownera gildii do scoped `account_world_links` po `game_slug + game_mode`.
- [x] Podpieto aktywny WWW `createaccount` pod mirror `local + GLOBAL_DB`.
- [x] Dodano seed `account_games` dla nowego WWW create flow.
- [x] Dodano opcjonalny seed `account_world_links` dla nowego WWW create flow, jesli tabela istnieje.
- [x] Dodano transakcyjny seed `account_games` do `register-account-lib.php`.
- [x] Dodano powtarzalny CLI smoke test `global-guilds-smoke-test.php`.
- [x] Wykonano realne smoke testy zapisowe `reserve / conflict / attach / heartbeat / helper createGuild` z cleanupem danych testowych.
- [x] Naprawiono falszywy `heartbeat missing` przy `UPDATE` w tej samej sekundzie.
- [x] Dodano CLI `global-guilds-repair.php` z domyslnym `dry-run`.
- [x] Dodano CLI `global-guilds-routing-guard.php`.
- [x] Dodano CLI `global-guilds-race-test.php`.
- [x] Dodano CLI `global-guilds-fail-closed-smoke.php`.
- [x] Dodano CLI `global-guilds-legacy-create-smoke.php`.
- [x] Dodano CLI `global-guilds-validation-guard.php`.
- [x] Podjeto decyzje auth: endpointy gildii zostaja przy dedykowanym `GLOBAL_GUILDS_API_KEY`.
- [x] Uproszczono runtime auth endpointow gildii do `GLOBAL_GUILDS_API_KEY`.
- [x] Skonfigurowano testowy `GLOBAL_GUILDS_API_KEY` w aktualnym runtime.
- [x] Dodano CLI `global-guilds-auth-smoke.php`.
- [x] Dodano podstawowe komunikaty `i18n` dla flow gildii.
- [x] Dodano fallback `local-only`, gdy registry nie jest jeszcze wdrozone w DB.
- [x] Poprawiono regex walidacji nazw gildii / rank / nick w flow gildii.
- [x] Dodano podstawowe logowanie kontekstu partial-failure dla flow globalny <-> lokalny.
- [ ] Nie odpalono jeszcze migracji `008/009/010` na produkcyjnym `GLOBAL_DB`.
- [ ] Nie skonfigurowano jeszcze produkcyjnego klucza API dla nowych endpointow gildii.
- [ ] Nie potwierdzono jeszcze docelowej tabeli mapujacej `local_account_id -> global_account_id` po separacji `global_accounts`.
- [ ] Nie rozpoczeco jeszcze implementacji globalnych topek.

Wyniki testow DB z `2026-03-08`:

- [x] Potwierdzono, ze `GLOBAL_DB_NAME=global_accounts` jest juz osobna baza.
- [x] Potwierdzono, ze migracje `008`, `009`, `010` sa wdrozone na testowym `global_accounts`.
- [x] Potwierdzono, ze `global_accounts` ma juz `global_guilds`, `global_guild_instances`, `global_guild_events` i `account_world_links`.
- [x] Potwierdzono, ze `global_accounts.accounts` i `canaryaac.accounts` maja obecnie zgodnosc `41/41` po `id + email`.
- [x] Potwierdzono realny backfill `82` mapowan ownera dla `tibia/classic74+modern`.
- [x] Potwierdzono, ze `canaryaac.guilds` ma aktualnie `0` rekordow.
- [x] Potwierdzono, ze legacy `system/pages/account/create.php` tylko przekierowuje na `RedDAXE`.
- [x] Potwierdzono `preflight ok=true` bez blockerow i warningow po rolloutcie.
- [x] Potwierdzono zapisowe smoke testy i cleanup bazy do `global_guilds=0`, `global_guild_instances=0`, `global_guild_events=0`, `local_guilds=0`.
- [x] Potwierdzono `global-guilds-repair.php --limit=20` bez niespojnosci w `dry-run`.
- [x] Potwierdzono `global-guilds-routing-guard.php` dla obu webowych pathow.
- [x] Potwierdzono `global-guilds-race-test.php` dla rownoczesnej rezerwacji tej samej nazwy.
- [x] Potwierdzono `global-guilds-fail-closed-smoke.php` dla odseparowanego registry bez mapowania ownera.
- [x] Potwierdzono `global-guilds-legacy-create-smoke.php` dla starego flow `system/pages/guilds/create.php`:
  - aktualna konfiguracja testowa blokuje create i nie zapisuje nic do DB,
  - procesowy override `core.guild_need_premium=false` pozwala przejsc przez legacy path i zapisac `local guild + global guild + global instance`,
  - cleanup przywraca stan baz do zera.
- [x] Potwierdzono `global-guilds-validation-guard.php` dla parytetu walidacji nazw gildii miedzy `Validator::guildName()` i `globalGuildsIsValidName()`.
- [x] Potwierdzono `global-guilds-auth-smoke.php`:
  - brak klucza => `401 missing_api_key`,
  - bledny klucz => `403 invalid_api_key`,
  - poprawny klucz + brak gildii => `404 not_found`,
  - poprawny klucz => `reserve-or-attach`, `lookup`, `instances`, `heartbeat` przechodza po HTTPS i cleanup wraca do zera.

Wniosek:

- realizujemy teraz tylko `globalne gildie`,
- topki pozostaja poza zakresem biezacego etapu.

## 1. Priorytet ogolny

Kolejnosc:

1. wspolna tozsamosc gracza
2. global guild registry
3. synchronizacja danych serwer -> global backend
4. global leaderboards v1
5. UI launcher + strony per-gra + panel RedDaxe
6. i18n + operacyjne domkniecie systemu

## 2. Epic A - Tozsamosc i rejestry bazowe

### A1. Global account identity

- [ ] Potwierdzic, czy w aktualnym live `accounts.id` pelni role tymczasowego `global_account_id`.
- [x] Wykonac probe live DB dla zgodnosci `local accounts.id` vs `global accounts.id`.
- [ ] Zdecydowac, czy docelowa agregacja idzie po `global_account_id`, czy po `global_player_id`.
- [ ] Spisac jawne mapowanie `local_account_id -> global_account_id` przed separacja `global_accounts`.
- [x] Dodac resolver ownera gildii: lokalne konto WWW / serwer -> globalny owner ID.
- [ ] Potwierdzic docelowa tabele mapujaca ownera po separacji `global_accounts`:
  - `account_world_links`
  - albo inna tabela kontraktowa
- [x] Przygotowac draft tabeli `account_world_links`.
- [x] Przygotowac dry-run backfill dla `account_world_links`.
- [x] Zdecydowac i wdrozyc, ze aktywny WWW flow tworzenia kont ma byc mirrorowany `local + GLOBAL_DB`.
- [ ] Dopiacc pelny mirror `local + GLOBAL_DB` dla rejestracji API / `RedDAXE`.
- [x] Dopiacc przynajmniej `account_games` do rejestracji API / `register-account-lib.php`.
- [ ] Zdecydowac, co robimy przy przyszlym rozdzieleniu hostow DB:
  - dedykowany provisioning service
  - albo inny bezpieczny sync
- [ ] Dodac polityke `display_name`.
- [ ] Ustalic zachowanie przy zmianie nicku postaci.

### A2. Registry serwerow i gier

- [ ] Dodac `game_id`.
- [ ] Dodac `server_id`.
- [ ] Dodac `ruleset`.
- [ ] Dodac `cluster` lub `family`, jesli ma byc grupowanie serwerow.

### A3. Kontrakt i18n i frontow

- [ ] Ustalic, ze wszystkie teksty systemowe widoczne dla gracza ida przez `i18n`.
- [ ] Ustalic, ktore pola API sa danymi, a ktore mapuja sie na klucze `i18n`.
- [ ] Ustalic wspolny fallback jezykowy dla launchera, stron per-gra i `RedDaxe.pl`.
- [ ] Spisac wyjatki: nazwy gildii, nicki i inne tresci user-generated nie sa tlumaczone.

## 3. Epic B - Global guild registry

### B1. Kontrakt danych

- [x] Zdefiniowac `global_guild_id`.
- [x] Zdefiniowac `guild_name_normalized`.
- [x] Zdefiniowac statusy gildii.
- [x] Domknac kontrakt ownera gildii:
  - kolumna i API nazywaja sie `owner_global_account_id` / `ownerGlobalAccountId`
  - w shared DB fallbackiem jest obecne `accounts.id`
  - przy osobnym `global_accounts` wymagane jest jawne mapowanie
- [ ] Zdefiniowac ownership globalny vs lokalny.
- [x] Zapisac scope instancji gildii: `game_slug + game_mode + world_id + local_guild_id`.
- [x] Zapisac polityke collation dla `guild_name_normalized`.

### B2. Tabele i indeksy

- [x] Dodac draft tabel `global_guilds`.
- [x] Dodac draft tabel `global_guild_instances`.
- [x] Dodac unikalny indeks na `guild_name_normalized`.
- [x] Poprawic unikalnosc `local_guild_id`, zeby byla scoped serwerem / gra przed rolloutem.
- [x] Zdecydowac, czy `guild_name_normalized` ma miec collation binarne.
- [x] Dodac draft audit log rezerwacji.
- [x] Dodac transakcyjna ochrone przed race condition przy rownoczesnej rezerwacji nazwy.
- [x] Jesli draft migracji `008` zostal odpalony na jakimkolwiek innym srodowisku przed tym fixem, przygotowac repair migration zamiast nadpisywania rolloutu.
- [x] Odpalic migracje registry na test `GLOBAL_DB`.
- [x] Odpalic migracje `010_global_guild_account_links` na test `GLOBAL_DB`.
- [ ] Odpalic migracje registry na live `GLOBAL_DB`.
- [ ] Odpalic migracje `010_global_guild_account_links` na live `GLOBAL_DB`.
- [ ] Dodac lub potwierdzic `_migrations` w `GLOBAL_DB` jako zrodlo prawdy dla rolloutow registry.

### B3. API

- [x] Dodac draft endpointu lookup po nazwie.
- [x] Dodac draft endpointu reserve / attach.
- [x] Dodac endpoint listy instancji gildii.
- [x] Dodac heartbeat / last_seen.
- [x] Dodac report-only endpoint reconcile.
- [ ] Skonfigurowac produkcyjny klucz API dla endpointow gildii.
- [x] Zdecydowac model auth endpointow gildii: dedykowany `GLOBAL_GUILDS_API_KEY`.
- [x] Dodac tooling CLI do statusu i preflightu registry na `GLOBAL_DB`.
- [x] Dodac tooling CLI do dry-run backfillu owner mapping.
- [x] Dodac tooling CLI do zapisowych smoke testow registry i helpera WWW.
- [x] Zrobic smoke testy API / registry po rolloutcie migracji na bazie testowej.
- [ ] Zrobic smoke testy API po rolloutcie produkcyjnym.

### B4. Integracja z serwerem gry

- [x] Podpiac `WWW Tibia` pod global guild registry przy zakladaniu gildii.
- [x] Podpiac legacy `system/pages/guilds/create.php` pod global guild registry.
- [x] Jesli nazwa wolna, backend tworzy `global guild`.
- [x] Jesli nazwa nalezy do tego samego ownera, backend moze zrobic `attach`.
- [x] Jesli nazwa nalezy do kogos innego, backend blokuje tworzenie.
- [x] Potwierdzic, ze na WWW istnial drugi aktywny path zakladania gildii:
  - `app/Controller/Pages/Guilds/Found.php`
  - `system/pages/guilds/create.php`
- [ ] Potwierdzic, czy gildie moga powstawac tez bezposrednio w silniku lub innymi narzedziami poza WWW.
- [ ] Jesli gildie moga powstawac poza WWW, dodac hook / sync do silnika.
- [ ] Skonfigurowac mapowanie ownera z lokalnego konta na globalne przed docelowym rolloutem multi-game.

### B5. Polityki v1

- [ ] Zablokowac rename globalny.
- [ ] Nie uwalniac nazw automatycznie.
- [ ] Dodac reczne narzedzie admina do sporow i wyjatkow.
- [x] Dodac reconcile / repair flow dla niespojnosci miedzy lokalna gildia a `global_guild_instances`.
- [x] Dodac report-only reconcile do wykrywania niespojnosci.
- [x] Dodac logowanie partial-failure dla flow globalny -> lokalny -> attach.

### B6. Walidacja i bezpieczenstwo flow gildii

- [x] Dodac podstawowa walidacje nazwy gildii w nowym flow.
- [x] Poprawic regex `A-z` -> `A-Za-z` we wszystkich miejscach walidacji gildii.
- [x] Ujednolicic walidacje nazwy gildii miedzy WWW i API oraz dodac guard pilnujacy parytetu.
- [x] Dodac test konfliktu nazwy przy dwoch rownoczesnych probach rezerwacji.
- [x] Dodac test odtworzenia tej samej gildii przez tego samego ownera na innym swiecie.
- [x] Dodac test blokady dla innego ownera.
- [x] Dodac test `heartbeat` instancji gildii.
- [x] Dodac smoke test legacy path `system/pages/guilds/create.php`, zeby nie byl ponownie bypassem registry.
- [x] Potwierdzic zapisowo, ze legacy path nie zapisuje lokalnej gildii bez registry i po success path tworzy tez wpis globalny.
- [x] Dodac guard dla obu webowych pathow, ze dalej ida przez `GlobalGuildRegistry::createGuild`.
- [x] Dodac test fail-closed:
  - `GLOBAL_DB_NAME` ustawione na osobna baze
  - brak mapowania ownera
  - brak zgody na create / attach
- [x] Dodac operacyjny test CLI:
  - `php migrate-global-guilds.php status`
  - `php global-guilds-db-preflight.php`
  - `php global-guilds-auth-smoke.php`
  - potwierdzenie blockerow przed rolloutem

## 4. Epic C - Kanal synchronizacji

### C1. Model ingestu

- [ ] Wybrac model `snapshot` dla v1.
- [ ] Zdefiniowac format payloadu.
- [ ] Dodac `schema_version`.
- [ ] Dodac `idempotency_key`.

### C2. Bezpieczenstwo

- [ ] Dodac uwierzytelnianie serwer -> global backend.
- [ ] Dodac podpis requestu lub HMAC.
- [ ] Dodac rate limit i audit log.

### C3. Narzedzia operacyjne

- [ ] Dodac retry i dead-letter handling.
- [ ] Dodac widok sync status per server.
- [ ] Dodac reczne przeliczenie agregatow.
- [ ] Dodac plan backfillu danych historycznych.

## 5. Epic D - Global leaderboards v1

### D1. Definicje metryk

- [ ] Wybrac pierwsze metryki globalne:
- [ ] `players_killed`
- [ ] `deaths`
- [ ] `boss_kills`
- [ ] `quests_completed`
- [ ] `playtime`

### D2. Agregaty

- [ ] Dodac `leaderboard_metric_definitions`.
- [ ] Dodac `leaderboard_metric_snapshots`.
- [ ] Dodac `leaderboard_aggregates`.
- [ ] Dodac `leaderboard_seasons`.
- [ ] Dodac przeliczanie `sum`, `max`, `seasonal`.

### D3. Kwalifikacja i moderacja

- [ ] Dodac flagi `eligible_for_global_rankings`.
- [ ] Dodac mozliwosc wykluczenia serwera testowego.
- [ ] Dodac mozliwosc wykluczenia konta / gildii z rankingu.
- [ ] Dodac polityke korekt po rollbacku lub opoznionym syncu.

### D4. Podzial rankingow

- [ ] Dodac `global_total`.
- [ ] Dodac `global_per_ruleset`.
- [ ] Dodac `global_seasonal`.
- [ ] Odlozyc `weighted_score` do v2.

## 6. Epic E - UI strony i launchera

### E1. RedDaxe.pl

- [ ] Minimalny panel gildii.
- [ ] Lista czlonkow gildii z podzialem na serwery.
- [ ] Widok instancji gildii na roznych serwerach.
- [ ] Podstawowe operacje ownership / attach / zarzadzanie dostepem.

### E2. WWW Tibia

- [ ] Widok globalnych topek.
- [ ] Widok globalnej gildii.
- [ ] Widok topki gildii.
- [ ] Widok `all worlds` dla gildii Tibii.
- [ ] Glowne / maksymalne zarzadzanie gildia dla Tibii.
- [ ] Wyszukiwarka gildii / gracza.
- [ ] CTA do launchera i flow konta.

### E3. Inne strony per-gra

- [ ] Szablon publicznego widoku gildii dla gry.
- [ ] Szablon publicznych topek dla gry.
- [ ] Szablon topki gildii dla gry.
- [ ] Filtrowanie po `game_id` / `server_id`.

### E4. Launcher

- [ ] Widok podstawowych globalnych topek.
- [ ] Widok statusu nazwy gildii.
- [ ] Widok profilu gracza w ekosystemie.

## 7. Epic F - I18N, copy i testy frontowe

### F1. Standard i18n

- [ ] Obiac wszystkie nowe widoki systemem `i18n`.
- [ ] Zakazac hardkodowanych stringow user-visible w nowych ekranach.
- [ ] Utrzymac wspolne klucze i nazwy kategorii dla launchera, stron per-gra i panelu.
- [ ] Dodac fallback oraz test na brak mixed strings.

### F2. QA i smoke

- [ ] Dodac smoke dla `WWW Tibia`, stron per-gra i `RedDaxe.pl` pod ich docelowe widoki.
- [ ] Dodac matryce E2E dla PL / EN.
- [ ] Dodac testy pustych stanow, konfliktow nazw i bledow sync.

## 8. Epic G - Admin i operacje

### G1. Panel / tooling

- [ ] Dodac narzedzie do recznego locka nazwy gildii.
- [ ] Dodac narzedzie do rozwiazywania sporow ownership.
- [ ] Dodac narzedzie do wykluczania z globalnych rankingow.
- [ ] Dodac reczne przeliczenie agregatow i sezonow.

## 9. Faza wykonawcza P0 / P1 / P2

### P0

- [ ] Potwierdzic model `global_account_id` dla aktualnego live i dla separacji `global_accounts`.
- [x] Ustalic `guild_name_normalized`.
- [ ] Ustalic kontrakt `i18n` dla wszystkich tekstow widocznych dla gracza.
- [x] Dodac draft `global guild registry`.
- [x] Spiac tworzenie gildii na WWW z lookupiem globalnym.
- [x] Spiac oba aktywne webowe pathy tworzenia gildii z registry.
- [ ] Poprawic schema blockers przed rolloutem:
- [x] scoped unique dla `local_guild_id`
- [x] draft resolvera `ownerLocalAccountId -> ownerGlobalAccountId`
- [x] poprawa regex walidacji
- [x] repair migration `009`
- [x] tooling status / preflight dla `GLOBAL_DB`
- [x] draft `account_world_links` + dry-run backfill
- [ ] konfiguracja docelowego mapowania ownera po separacji `global_accounts`
- [x] odpalic migracje na bazie testowej
- [ ] odpalic migracje i config API na produkcji
- [ ] wykonac smoke testy P0

### P1

- [ ] Dodac sync snapshotow.
- [ ] Dodac pierwsze metryki globalne.
- [ ] Dodac podstawowe topki na `WWW Tibia` i stronach per-gra.
- [ ] Dodac minimalny panel gildii na `RedDaxe.pl`.
- [ ] Dodac glowny panel / widok `all worlds` gildii na `WWW Tibia`.
- [ ] Dodac smoke i18n dla nowych widokow.

### P2

- [ ] Dodac topki w launcherze.
- [ ] Dodac filtrowanie po rulesetach i sezonach.
- [ ] Dodac profile gildii i profili graczy.
- [ ] Dodac admin tooling i korekty operacyjne.

## 10. Blockery przed produkcja - tylko globalne gildie

### Krytyczne

- [ ] Skonfigurowac i zweryfikowac docelowe mapowanie ownera gildii dla osobnego `global_accounts`.
- [ ] Potwierdzic, czy jakiekolwiek srodowisko ma juz odpalona starsza wersje migracji `008`; jesli tak, przygotowac repair migration.
- [ ] Rollout registry wykonac dedykowanym runnerem do `GLOBAL_DB`, nie standardowym `migrate.php`.

### Wysokie

- [ ] Odpalic migracje na live DB i skonfigurowac `GLOBAL_GUILDS_API_KEY`.
- [ ] Dodac smoke testy scenariuszy:
  - owner zaklada gildie
  - inny owner dostaje konflikt
  - ten sam owner odtwarza gildie na innym swiecie
- [ ] Dodac operacyjne logowanie i reconcile dla partial failures.
- [ ] Zdecydowac, czy tymczasowo akceptujemy zgodnosc `accounts.id` miedzy lokalna i globalna baza jako kontrakt przejsciowy.
- [x] Domknac aktywny WWW flow tworzenia kont, zeby nie rozjezdzal `GLOBAL_DB` i lokalnego `accounts`.
- [ ] Domknac analogiczny mirror `local + GLOBAL_DB` dla API / `RedDAXE` registration flow.

### Srednie

- [x] Domknac decyzje collation / normalizacji dla `guild_name_normalized`.
- [ ] Ujednolicic walidacje nazwy gildii z ewentualnym przyszlym hookiem serwerowym.
