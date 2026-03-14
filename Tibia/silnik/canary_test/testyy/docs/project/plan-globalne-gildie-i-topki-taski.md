# Taski wdrozeniowe - globalne gildie i globalne topki

Status: P0 w toku  
Data: 2026-03-09
Powiazany dokument bazowy: `plan-globalne-gildie-i-topki.md`

## 0. Snapshot wykonania na dzis

Stan prac `2026-03-09`:

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
- [x] Dodano migracje `011_global_guild_ownership_and_instance_leaders`.
- [x] Dodano dry-run backfill `backfill-global-guild-account-links.php`.
- [x] Odpalono realny rollout migracji `008/009/010/011` na testowym `GLOBAL_DB`.
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
- [x] Dodano CLI `global-guilds-mutation-guard.php`.
- [x] Dodano endpoint `global-guilds-archive-instance.php`.
- [x] Dodano backendowy prymityw `archive instance` dla registry.
- [x] Dodano CLI `global-guilds-archive-smoke.php`.
- [x] Dodano helpery `captureGuildSyncContext()` i `archiveDeletedGuild()` w `GlobalGuildRegistry`.
- [x] Podpieto `DisbandGuild` pod sync delete -> registry.
- [x] Podpieto adminowy delete gildii pod sync delete -> registry.
- [x] Podpieto legacy `delete_guild()` helper pod sync delete -> registry.
- [x] Dodano CLI `global-guilds-delete-helper-smoke.php`.
- [x] Przepieto adminowy `POST /admin/guilds/{id}` na `Guilds::updateGuild`.
- [x] Zablokowano adminowy `rename` gildii w backendzie i UI panelu admina.
- [x] Domknieto `global-guilds-mutation-guard.php` bez follow-upow dla znanych lokalnych pathow mutacji gildii.
- [x] Dodano CLI `global-guilds-rollout-readiness.php` do zbiorczego checku rolloutowego.
- [x] Dodano CLI `global-guilds-create-audit.php` do audytu webowych create pathow gildii.
- [x] Dodano CLI `global-guilds-owner-audit.php` do read-only inspekcji `global owner` vs `local leader`.
- [x] Dodano wewnetrzny endpoint `global-guilds-transfer-owner.php`.
- [x] Dodano wewnetrzny endpoint `global-guilds-assign-local-leader.php`.
- [x] Dodano backendowy bootstrap pierwszego `local leader` dla pustej instancji przy `create / attach`.
- [x] Dodano CLI `global-guilds-ownership-model-smoke.php`.
- [x] Rozszerzono `global-guilds-rollout-readiness.php` o opcjonalny `--with-ownership-smoke`.
- [x] Dodano backendowy widok `sync status per server`:
  - `global-guilds-sync-status.php`
  - `migrations/global-guilds-sync-status.php`
- [x] Dodano pierwszy read-only panel gildii ownera na `RedDaxe.pl`:
  - sekcja `guilds` w `account-manage.php`, widoczna tylko dla zalogowanego ownera z co najmniej jedna globalna gildia
  - helper `reddaxe_fetch_owned_global_guilds()`
  - lista instancji per serwer i lokalnych czlonkow dla Tibii
- [x] Dodano CTA `Zaloz gildie` na `RedDaxe.pl` dla zalogowanego konta bez wlasnej globalnej gildii.
- [x] Dodano dedykowany formularz `RedDAXE` `/reddaxe/guild-found.php` do zakladania globalnej gildii bez przejscia na strone Tibii.
- [x] Dopracowano formularz `RedDAXE` `/reddaxe/guild-found.php`, zeby po sukcesie rozroznial:
  - pierwszy globalny create,
  - attach / odtworzenie gildii ownera na kolejnym serwerze,
  - bootstrap pierwszego `local leader`,
- [x] Ograniczono przycisk przejscia do panelu gildii po sukcesie tylko do przypadkow, gdy zapis przeszedl przez globalne registry.
- [x] Dodano do panelu `RedDAXE` read-only stan delegacji `local leader` per instancja:
  - `assigned`,
  - `assignable`,
  - `bootstrap_pending`,
  - `no_members`,
- [x] Dodano podstawowa akcje ownera na `RedDAXE`: przypisanie / zmiana `local leader` z listy aktualnych czlonkow lokalnej gildii Tibii.
- [x] Dodano podstawowa akcje ownera na `RedDAXE`: `transfer owner` na inne konto globalne po e-mailu.
- [x] Backend waliduje juz, ze dla Tibii `local leader` musi nalezec do lokalnej gildii w poprawnym scope serwera.
- [x] Dodano do panelu `RedDAXE` bardziej szczegolowe dane read-only:
  - aktualny globalny owner,
  - `assigned by`,
  - `assigned at`,
- [x] Dopracowano komunikaty gracza w panelu `RedDAXE`:
  - usunieto surowe kody API z glownego komunikatu widocznego dla gracza,
  - dodano mapowanie bledow na `i18n`,
  - dodano opisy stanow `assigned / archived / unsupported`,
  - dodano i18n-hinty przy `transfer owner` i `local leader`,
- [x] Potwierdzono decyzje produktowa dla `RedDAXE`:
  - zadanie `1` (`transfer owner`) jest wdrozone,
  - zadanie `3` (szersze dane read-only) jest wdrozone,
  - zadanie `2` (`attach / odtworzenie`) nie jest dalej rozwijane w `RedDAXE` i zostaje po stronie fizycznego serwera / strony serwera,
- [x] Potwierdzono helper `RedDAXE` dla `transfer owner` realnym testem w kontekscie HTTPS.
- [x] Dodano podstawowe komunikaty `i18n` dla flow gildii.
- [x] Potwierdzono lokalny podglad i screenshot HTTPS widokow `RedDAXE` do review UI podczas dalszych etapow.
- [x] Dodano fallback `local-only`, gdy registry nie jest jeszcze wdrozone w DB.
- [x] Poprawiono regex walidacji nazw gildii / rank / nick w flow gildii.
- [x] Dodano podstawowe logowanie kontekstu partial-failure dla flow globalny <-> lokalny.
- [ ] Nie odpalono jeszcze migracji `008/009/010` na produkcyjnym `GLOBAL_DB`.
- [ ] Nie skonfigurowano jeszcze produkcyjnego klucza API dla nowych endpointow gildii.
- [ ] Nie potwierdzono jeszcze docelowej tabeli mapujacej `local_account_id -> global_account_id` po separacji `global_accounts`.
- [ ] Nie rozpoczeco jeszcze implementacji globalnych topek.

Wyniki testow DB z `2026-03-08`:

- [x] Potwierdzono, ze `GLOBAL_DB_NAME=global_accounts` jest juz osobna baza.
- [x] Potwierdzono, ze migracje `008`, `009`, `010`, `011` sa wdrozone na testowym `global_accounts`.
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
- [x] Potwierdzono `global-guilds-mutation-guard.php`:
  - oba pathy `create` ida przez registry,
  - `delete / disband / cleanup` sa podpiete do registry,
  - adminowy `rename` jest twardo zablokowany,
  - brak follow-upow dla znanych lokalnych pathow mutacji gildii.
- [x] Potwierdzono `global-guilds-archive-smoke.php`:
  - `reserve-or-attach` tworzy globalna gildie i instancje,
  - `archive instance` archiwizuje ostatnia instancje i ustawia `global_guilds.status=archived`,
  - inny owner nadal dostaje `409 guild_name_reserved`, wiec nazwa nie jest uwalniana automatycznie,
  - ten sam owner moze odtworzyc gildie przez `reattach`, a status wraca do `active`,
  - cleanup przywraca `global_guilds/global_guild_events` do zera.
- [x] Potwierdzono `global-guilds-create-audit.php`:
  - w repo WWW nie ma dodatkowych webowych pathow create poza `Found.php` i legacy `create.php`,
  - create routing idzie do `Found::insertFoundGuild`,
  - bezposredni create w silniku gry pozostaje osobnym otwartym taskiem.
- [x] Potwierdzono `global-guilds-owner-audit.php`:
  - delegowany `local leader` jest traktowany jako poprawny stan,
  - raportowane sa tylko braki registry / braki instancji,
  - na aktualnej bazie testowej przeskanowano `1` lokalna gildie i nie wykryto problemow registry.
- [x] Potwierdzono `global-guilds-delete-helper-smoke.php`:
  - `GlobalGuildRegistry::createGuild()` tworzy lokalna + globalna gildie,
  - realny `delete_guild()` usuwa lokalna gildie i archiwizuje globalna instancje,
  - `global_guilds.status` przechodzi do `archived`,
  - cleanup przywraca testowe rekordy globalne do zera.
- [x] Potwierdzono `global-guilds-ownership-model-smoke.php`:
  - delegowany `local leader` pozostaje zachowany po transferze ownera,
  - stary owner jest blokowany po transferze,
  - nowy owner moze wykonac `attach / reattach`,
  - cleanup przywraca testowe rekordy do zera.
- [x] Potwierdzono `global-guilds-rollout-readiness.php --with-auth-smoke --with-ownership-smoke` z wynikiem `ok=true`.
- [x] Potwierdzono `global-guilds-sync-status.php` / `migrations/global-guilds-sync-status.php` na testowym `GLOBAL_DB`.
- [x] Potwierdzono `global-guilds-smoke-test.php` dla bootstrapu `local leader` w helperze WWW.
- [x] Potwierdzono `global-guilds-auth-smoke.php` dla bootstrapu `local leader` w `reserve-or-attach`.
- [x] Potwierdzono read-only helper `RedDaxe.pl` na test DB:
  - dla ownera `6` zwraca `1` globalna gildie i `1` aktywna instancje,
  - instancja Tibii zwraca lokalnych czlonkow z `canaryaac`.

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
- [x] Zdefiniowac ownership globalny vs lokalny:
  - `global guild` ma dokladnie jednego `owner_global_account_id`
  - transfer ownera jest globalny i jawny
  - kazda instancja serwerowa moze miec innego `local leader`
  - `local leader` nie musi byc rowny `global owner`
  - `global owner` moze nigdy nie pojawic sie na danym serwerze
  - instancja moze czasowo nie miec jeszcze przypisanego lokalnego lidera
- [x] Zdefiniowac polityke bootstrapu `local leader`:
  - sam login na serwer nie tworzy gildii automatycznie
  - po poprawnym lokalnym flow zalozenia / konfiguracji gildii `global owner` moze zostac automatycznie pierwszym `local leader`
  - tylko gdy instancja jest pusta: brak czlonkow i brak lidera
  - bootstrap nie zmienia `owner_global_account_id`
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
- [ ] Odpalic migracje `011_global_guild_ownership_and_instance_leaders` na live `GLOBAL_DB`.
- [x] Dodac lub potwierdzic `_migrations` w `GLOBAL_DB` jako zrodlo prawdy dla rolloutow registry.

### B3. API

- [x] Dodac draft endpointu lookup po nazwie.
- [x] Dodac draft endpointu reserve / attach.
- [x] Dodac endpoint listy instancji gildii.
- [x] Dodac heartbeat / last_seen.
- [x] Dodac endpoint archive / archive-instance dla lokalnie usuwanej gildii.
- [x] Dodac report-only endpoint reconcile.
- [x] Dodac endpoint transferu globalnego ownera.
- [x] Dodac endpoint przypisania / wyczyszczenia `local leader`.
- [x] Dodac read-only endpoint / CLI `sync status per server`.
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
- [x] Utrzymac dwa rownoprawne entry pointy do pierwszego utworzenia globalnej gildii:
  - flow WWW `/community/guilds/found`
  - lokalny flow serwerowy
- [x] Dodac trzeci rownorzedny entry point:
  - formularz `RedDAXE` `/reddaxe/guild-found.php`
- [x] Potwierdzic, ze na WWW istnial drugi aktywny path zakladania gildii:
  - `app/Controller/Pages/Guilds/Found.php`
  - `system/pages/guilds/create.php`
- [x] Potwierdzic, ze w repo WWW nie ma dodatkowych create pathow poza:
  - `app/Controller/Pages/Guilds/Found.php`
  - `system/pages/guilds/create.php`
  - `GlobalGuildRegistry::createGuild`
- [ ] Potwierdzic, czy gildie moga powstawac tez bezposrednio w silniku lub innymi narzedziami poza WWW.
- [x] Potwierdzic, ze poza create flow istnieja lokalne pathy mutacji gildii poza registry:
  - admin rename / delete
  - web disband
  - legacy delete / cleanup
- [x] Podpiac lokalne flow delete / disband pod globalne registry:
  - `DisbandGuild`
  - `Admin/Guilds::deleteGuild`
  - `delete_guild()` helper
  - legacy `delete_guild.php`, `delete_by_admin.php`, `cleanup_guilds.php`
- [x] Domknac adminowy path `rename / update`:
  - `POST /admin/guilds/{id}` idzie do `Guilds::updateGuild`
  - `guild.name` pozostaje readonly
  - backend wymusza zachowanie kanonicznej nazwy
- [x] Dopic bootstrap `local leader` do flow tworzenia instancji gildii:
  - po poprawnym local create / attach
  - tylko dla pustej instancji bez czlonkow i bez lidera
  - postac ownera uzyta do zalozenia gildii staje sie pierwszym `local leader`
- [ ] Jesli gildie moga powstawac poza WWW, dodac hook / sync do silnika.
- [ ] Skonfigurowac mapowanie ownera z lokalnego konta na globalne przed docelowym rolloutem multi-game.

### B5. Polityki v1

- [x] Zablokowac rename globalny.
- [x] Nie uwalniac nazw automatycznie.
- [x] Dodac read-only tooling do sporow i wyjatkow:
  - `global-guilds-owner-audit.php`
  - `global-guilds-create-audit.php`
- [ ] Dodac write/admin tooling do sporow i wyjatkow:
  - [x] kontrolowany transfer `owner_global_account_id`
  - [x] przypisanie / zmiana `local leader` per serwer
  - [ ] reczne rozwiazywanie sporow ownership
- [x] Dodac polityke dla adminowego rename gildii:
  - wybrana i wdrozona opcja v1: twarda blokada rename
  - kontrolowany `rename + migracja registry` zostaje poza zakresem P0
- [x] Zaprojektowac i wdrozyc backendowy flow transferu globalnego ownera:
  - `1 global owner` na gildie
  - transfer tylko jawny, nie przez uboczna zmiane lokalnego lidera
- [x] Zaprojektowac i wdrozyc backendowy flow delegowania `local leader` per serwer:
  - lider moze byc rozny na kazdym serwerze
  - globalny owner moze nie miec postaci na tym serwerze
  - instancja moze byc czasowo bez lokalnego lidera
- [x] Dodac automatyczny bootstrap pierwszego `local leader`:
  - tylko dla pustej instancji
  - tylko po spelnieniu wymagan lokalnego serwera
  - bez automatycznego nadania na juz obsadzonej instancji
- [ ] Dodac UI ownera / admina do transferu i delegowania na frontach.
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
- [x] Dodac guard wykrywajacy lokalne pathy rename / delete poza registry.
- [x] Dodac test fail-closed:
  - `GLOBAL_DB_NAME` ustawione na osobna baze
  - brak mapowania ownera
  - brak zgody na create / attach
- [x] Dodac operacyjny test CLI:
  - `php migrate-global-guilds.php status`
  - `php global-guilds-db-preflight.php`
  - `php global-guilds-auth-smoke.php`
  - potwierdzenie blockerow przed rolloutem
- [x] Dodac zbiorczy readiness check CLI dla rolloutu:
  - `php global-guilds-rollout-readiness.php`
  - opcjonalnie `php global-guilds-rollout-readiness.php --with-auth-smoke`

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
- [x] Dodac widok sync status per server.
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

- [x] Minimalny panel gildii.
- [x] Lista czlonkow gildii z podzialem na serwery.
- [x] Widok instancji gildii na roznych serwerach.
- [x] Dedykowany formularz `RedDAXE` do zalozenia globalnej gildii bez przejscia na `WWW Tibia`.
- [x] Czytelne komunikaty sukcesu w formularzu:
  - pierwszy globalny create,
  - attach / odtworzenie na kolejnym serwerze,
  - bootstrap pierwszego `local leader`.
- [ ] Usunac pole lokalnego hasla z `RedDAXE` `/reddaxe/guild-found.php` i oprzec ten flow o aktywna sesje.
- [ ] Dodac do `RedDAXE` `/reddaxe/guild-found.php` zestaw ochronny:
  - `CSRF`
  - audit log
  - rate limit
  - `i18n` copy oparte o sesje zamiast hasla
- [ ] Dopic polityke kont social `Google / Facebook / Steam` dla akcji wrazliwych zgodnie z dokumentem:
  - `Dokumentacja/2026-03-09_plan_reddaxe_auth_akcji_wrazliwych_i_social.md`
- [x] Delegowanie / zmiana `local leader` per serwer przez `global owner`.
- [x] Pokazac stan bootstrapu lidera dla pustej instancji:
  - `leader unassigned`
  - `owner can bootstrap on first valid create`
- [x] Podstawowe operacje ownership:
  - transfer `global owner`
  - delegowanie `local leader`
- [ ] Dalsze operacje dostepowe / zarzadcze, jesli zostana dopuszczone produktowo.
- [ ] `attach / odtworzenie gildii` pozostaje poza zakresem `RedDAXE` i jest obslugiwane po stronie fizycznego serwera / strony serwera.

### E2. WWW Tibia

- [ ] Widok globalnych topek.
- [ ] Widok globalnej gildii.
- [ ] Widok topki gildii.
- [ ] Widok `all worlds` dla gildii Tibii.
- [ ] Glowne / maksymalne zarzadzanie gildia dla Tibii.
- [ ] Wyszukiwarka gildii / gracza.
- [ ] CTA do launchera i flow konta.
- [ ] Pokazac w flow zalozenia / odtworzenia gildii, ze owner po spelnieniu wymagan serwera stanie sie pierwszym `local leader`.

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
- [ ] Rozwinac minimalny panel gildii na `RedDaxe.pl` ponad aktualny read-only foundation dla zalogowanego ownera.
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
- [x] Przygotowac rollout runbook i readiness tooling dla produkcji.
- [ ] Dodac operacyjne logowanie i reconcile dla partial failures.
- [ ] Zdecydowac, czy tymczasowo akceptujemy zgodnosc `accounts.id` miedzy lokalna i globalna baza jako kontrakt przejsciowy.
- [x] Domknac aktywny WWW flow tworzenia kont, zeby nie rozjezdzal `GLOBAL_DB` i lokalnego `accounts`.
- [ ] Domknac analogiczny mirror `local + GLOBAL_DB` dla API / `RedDAXE` registration flow.

### Srednie

- [x] Domknac decyzje collation / normalizacji dla `guild_name_normalized`.
- [ ] Ujednolicic walidacje nazwy gildii z ewentualnym przyszlym hookiem serwerowym.
