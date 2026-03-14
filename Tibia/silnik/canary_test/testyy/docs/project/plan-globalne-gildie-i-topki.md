# Plan globalnych gildii i globalnych topek

Status: P0 w toku  
Data: 2026-03-09
Zakres: launcher + WWW Tibia + strony per-gra + RedDaxe.pl + backend globalny + bazy serwerowe

## 0. Stan wdrozenia na dzis

Na dzien `2026-03-09` zostal przygotowany i przetestowany pierwszy techniczny fundament tylko dla `global guild registry`.

Zrobione w kodzie roboczym:

- draft migracji `global_guilds` i `global_guild_instances`,
- poprawiony draft migracji:
  - `owner_global_account_id`
  - scoped unique dla `game_slug + game_mode + world_id + local_guild_id`
  - `guild_name_normalized` na `utf8mb4_bin`,
- draft helpera backendowego do rezerwacji i attachowania globalnej gildii,
- draft resolvera ownera gildii:
  - shared DB => fallback do `accounts.id`
  - osobny `global_accounts` bez mapowania => fail-closed,
- podpiety flow zakladania gildii w `WWW Tibia`,
- podpiety takze legacy flow `system/pages/guilds/create.php`,
- dodane draft endpointy API:
  - lookup po nazwie
  - `reserve-or-attach`
- dodany endpoint listy instancji gildii,
- dodany endpoint heartbeat `last_seen_at`,
- dodany draft repair migration `009_global_guild_registry_repair_and_events`,
- dodany draft tabeli auditowej `global_guild_events`,
- dodany report-only endpoint reconcile dla globalnych gildii,
- dodany dedykowany runner `migrate-global-guilds.php` do rolloutow registry na `GLOBAL_DB`,
- dodany read-only preflight `global-guilds-db-preflight.php` do testow schematu i blockerow DB,
- dodany draft migracji `010_global_guild_account_links`,
- dodany dry-run backfill `backfill-global-guild-account-links.php`,
- wykonany realny rollout migracji `008/009/010/011` na testowej bazie `global_accounts` dnia `2026-03-08`,
- wykonany realny backfill `account_world_links` dnia `2026-03-08`,
- dopiety resolver ownera gildii do scoped `account_world_links` po `game_slug + game_mode`,
- aktywny WWW flow `app/Controller/Pages/Account/Create.php` zostal podpiety pod mirror `local accounts + GLOBAL_DB accounts`,
- nowy WWW create flow seeduje tez `account_games`, a jesli tabela istnieje rowniez `account_world_links`,
- `register-account-lib.php` seeduje teraz `account_games` przy globalnej rejestracji API,
- dodany powtarzalny CLI smoke test `global-guilds-smoke-test.php`,
- wykonane realne smoke testy zapisowe `reserve / conflict / attach / heartbeat / helper createGuild` z cleanupem danych testowych dnia `2026-03-08`,
- dodany CLI `global-guilds-repair.php` z domyslnym `dry-run` i opcjonalnym `--apply` do reconcile / repair niespojnosci registry,
- dodany CLI `global-guilds-routing-guard.php`, ktory pilnuje, ze oba webowe pathy tworzenia gildii nadal ida przez `GlobalGuildRegistry::createGuild`,
- dodany CLI `global-guilds-race-test.php` do testu rownoczesnej rezerwacji tej samej nazwy gildii,
- dodany CLI `global-guilds-fail-closed-smoke.php` do testu odseparowanego registry bez mapowania ownera,
- dodany CLI `global-guilds-legacy-create-smoke.php` do realnego smoke testu starego flow `system/pages/guilds/create.php`,
- dodany CLI `global-guilds-validation-guard.php` do pilnowania parytetu walidacji nazwy gildii miedzy `MyAAC\Validator` i API registry,
- podjeta decyzja auth dla endpointow gildii: dedykowany `GLOBAL_GUILDS_API_KEY`,
- `globalGuildsRequireAdmin()` zostal uproszczony do jednego modelu auth opartego o `GLOBAL_GUILDS_API_KEY`,
- skonfigurowany testowy `GLOBAL_GUILDS_API_KEY` w aktualnym runtime,
- dodany CLI `global-guilds-auth-smoke.php` do testu auth po HTTPS na lokalnych endpointach,
- dodany CLI `global-guilds-mutation-guard.php` do audytu lokalnych flow rename / delete, ktore moga ominac globalne registry,
- dodany endpoint `global-guilds-archive-instance.php`,
- dodany backendowy prymityw `archive instance` w registry,
- dodany CLI `global-guilds-archive-smoke.php` do testu `create -> archive -> reattach -> cleanup`,
- dodane helpery `captureGuildSyncContext()` i `archiveDeletedGuild()` w `GlobalGuildRegistry`,
- podpiety webowy `DisbandGuild` pod sync do registry,
- podpiety adminowy delete gildii pod sync do registry,
- podpiety legacy helper `delete_guild()` pod sync do registry,
- dodany CLI `global-guilds-delete-helper-smoke.php` do testu realnego `delete_guild()`,
- adminowy `POST /admin/guilds/{id}` zostal przepiety na `Guilds::updateGuild`,
- adminowy `rename` gildii zostal twardo zablokowany w backendzie i UI panelu admina,
- `global-guilds-mutation-guard.php` potwierdza teraz brak otwartych lokalnych pathow mutacji gildii poza registry,
- dodany CLI `global-guilds-rollout-readiness.php` do zbiorczego checku env + migracji + guardow + opcjonalnego auth smoke,
- dodany CLI `global-guilds-create-audit.php` do statycznego audytu webowych pathow tworzenia gildii w repo WWW,
- dodany CLI `global-guilds-owner-audit.php` do read-only inspekcji relacji `global owner` vs `local leader`,
- dodany endpoint `global-guilds-transfer-owner.php` do jawnego transferu `owner_global_account_id`,
- dodany endpoint `global-guilds-assign-local-leader.php` do delegowania `local leader` per scope serwera,
- dodana migracja `011_global_guild_ownership_and_instance_leaders` z polami `local leader` w `global_guild_instances`,
- dodany CLI `global-guilds-ownership-model-smoke.php` do testu `reserve -> assign local leader -> transfer owner -> reattach -> cleanup`,
- rozszerzony `global-guilds-rollout-readiness.php` o opcjonalny `--with-ownership-smoke`,
- dodany endpoint `global-guilds-sync-status.php` i CLI `migrations/global-guilds-sync-status.php` do operacyjnego widoku sync status per server,
- wdrozony backendowy bootstrap `local leader` dla pierwszego poprawnego `create / attach` pustej instancji gildii,
- `GlobalGuildRegistry::createGuild()` automatycznie przypisuje founder-a jako pierwszego `local leader`, jesli founder nalezy do konta ownera,
- `global-guilds-reserve-or-attach.php` obsluguje teraz opcjonalny bootstrap przez pola `bootstrapLocalLeaderPlayerId` i `bootstrapLocalLeaderPlayerName`,
- odpowiedz `reserve-or-attach` zwraca `localLeaderBootstrapState`,
- `RedDaxe.pl/account-manage.php` ma juz pierwszy read-only panel ownera, ale jest widoczny tylko dla zalogowanego ownera, ktory ma juz co najmniej jedna globalna gildie:
  - lista globalnych gildii ownera,
  - instancje gildii per serwer,
  - lokalni czlonkowie dla instancji Tibii,
- zalogowane konto bez globalnej gildii widzi na `RedDaxe.pl` tylko CTA `Zaloz gildie`, kierujace do dedykowanego formularza `RedDAXE` `/reddaxe/guild-found.php`,
- formularz `RedDAXE` `/reddaxe/guild-found.php` nie przekierowuje juz na strone Tibii i zostaje w warstwie `RedDAXE`,
- formularz `RedDAXE` pokazuje juz rozroznenie sukcesu:
  - pierwszy globalny create,
  - odtworzenie / attach tej samej gildii ownera na kolejnym serwerze,
  - bootstrap pierwszego `local leader`,
- po sukcesie `RedDAXE` pokazuje przycisk do panelu gildii tylko wtedy, gdy zapis zostal potwierdzony przez globalne registry,
- panel gildii `RedDAXE` pokazuje juz stan delegacji `local leader` per instancja:
  - `assigned`,
  - `assignable`,
  - `bootstrap_pending`,
  - `no_members`,
- owner globalnej gildii moze juz z `RedDAXE` przypisac lub zmienic `local leader` dla instancji Tibii, wybierajac go z aktualnych czlonkow lokalnej gildii,
- owner globalnej gildii moze juz z `RedDAXE` wykonac jawny `transfer owner` na inne konto globalne po e-mailu,
- panel `RedDAXE` pokazuje tez bardziej szczegolowe dane read-only:
  - aktualnego globalnego ownera,
  - kto przypisal `local leader`,
  - kiedy przypisano `local leader`,
- komunikaty panelu `RedDAXE` dla `transfer owner` i `local leader` zostaly dopracowane pod gracza:
  - panel nie pokazuje juz surowych kodow API jako glownego komunikatu,
  - bledy sa mapowane na teksty `i18n`,
  - doszly dodatkowe opisy stanow `assigned / archived / unsupported`,
  - doszly opisy konsekwencji przy `transfer owner` i walidacji przy `local leader`,
- decyzja produktowa na teraz jest taka, ze dla `RedDAXE` zadanie `1` i `3` sa juz wykonane:
  - `transfer owner` jest dostepny,
  - bardziej szczegolowe dane read-only sa widoczne w panelu,
- decyzja produktowa na teraz jest tez taka, ze zadanie `2` nie jest rozwijane w `RedDAXE`:
  - `attach / odtworzenie gildii` pozostaje po stronie fizycznego serwera / strony serwera,
  - ewentualne komunikaty sukcesu o istniejacej instancji sa tylko efektem aktualnego backendowego rozpoznania stanu, a nie sygnalem do dalszego rozwijania tego flow w `RedDAXE`,
- backend waliduje juz, ze dla Tibii `local leader` musi byc czlonkiem lokalnej gildii w poprawnym scope serwera,
- helper `RedDAXE` dla `transfer owner` zostal potwierdzony realnym testem w kontekscie HTTPS,
- dodane komunikaty `i18n` dla flow zakladania gildii,
- potwierdzony jest juz lokalny podglad i screenshot HTTPS widokow `RedDAXE`, co pozwala szybciej weryfikowac realny UI podczas kolejnych etapow,
- poprawione regex walidacji nazw gildii / nickow / rang w flow gildii,
- dodane logowanie kontekstu partial-failure dla flow globalny <-> lokalny,
- poprawiony bug `heartbeat`, ktory falszywie raportowal `missing`, gdy `UPDATE` trafial w ten sam scope i te sama sekunde,
- dodany fallback `local-only`, jesli registry nie jest jeszcze wdrozone w bazie.

Jeszcze niewdrozone operacyjnie:

- migracja nie zostala jeszcze odpalona na produkcyjnym `GLOBAL_DB`, ale jest juz wdrozona na testowym `global_accounts`,
- registry nie ma jeszcze rolloutu produkcyjnego,
- nowe endpointy gildii nie maja jeszcze rolloutu produkcyjnego configu, ale przeszly smoke testy na bazie testowej,
- model auth dla gildii jest juz zamkniety na dedykowanym `GLOBAL_GUILDS_API_KEY`, ale produkcyjny rollout klucza nadal czeka,
- nie potwierdzono jeszcze docelowej tabeli mapujacej `local_account_id -> global_account_id` po separacji `global_accounts`,
- standardowy runner `migrate.php` jest skierowany na `DB_NAME`, wiec nie nadaje sie do rolloutu registry w `GLOBAL_DB`,
- nadal trzeba dopiac pelny wspolny kontrakt dla rejestracji API / `RedDAXE`, bo `register-account-lib.php` seeduje juz `account_games`, ale nadal nie mirroruje lokalnego `accounts` jak WWW create flow,
- nie zaczeto jeszcze prac nad `global leaderboards`.

Wyniki testow DB z `2026-03-08`:

- `GLOBAL_DB_NAME` jest juz realnie odseparowane i wskazuje na `global_accounts`,
- migracje `008`, `009`, `010`, `011` zostaly realnie odpalone na testowym `global_accounts`,
- `global_accounts` ma juz `global_guilds`, `global_guild_instances`, `global_guild_events` oraz `account_world_links`,
- `global_accounts.accounts` i `canaryaac.accounts` maja obecnie zgodnosc `id + email` `41/41`, ale nie jest to jeszcze formalny kontrakt mapowania,
- `global_accounts.account_games` ma `82` wpisy, czyli po `41` kont w obu grach,
- realny backfill dla `account_world_links` wstawil `82` powiazania `same id + same email` dla scope `tibia + {classic74, modern}`,
- legacy `system/pages/account/create.php` nie jest juz drugim aktywnym local create path, bo od razu przekierowuje na `RedDAXE`,
- `global-guilds-db-preflight.php` zwraca teraz `ok=true`, bez blockerow i bez warningow,
- realny smoke test `global-guilds-smoke-test.php` przeszedl dla:
  - `reserve` nowej nazwy przez ownera A,
  - blokady tej samej nazwy dla ownera B,
  - `attach` tej samej globalnej gildii na drugim scope przez tego samego ownera,
  - `heartbeat` instancji,
  - pelnego helpera `GlobalGuildRegistry::createGuild`,
- `global-guilds-repair.php --limit=20` przeszedl w trybie `dry-run` i nie wykryl niespojnosci,
- `global-guilds-routing-guard.php` potwierdzil, ze oba webowe pathy gildii sa nadal podpiete pod registry,
- `global-guilds-race-test.php` potwierdzil, ze przy rownoczesnej probie tylko jeden owner wygrywa rezerwacje nazwy, a drugi dostaje `guild_name_reserved` z `HTTP 409`,
- `global-guilds-fail-closed-smoke.php` potwierdzil, ze przy odseparowanym registry bez `account_world_links` lokalna gildia nie jest tworzona, a globalne tabele pozostaja puste,
- `global-guilds-legacy-create-smoke.php` potwierdzil, ze legacy path `system/pages/guilds/create.php`:
  - na aktualnej konfiguracji testowej blokuje create dla konta bez premium i nie zapisuje nic lokalnie ani globalnie,
  - po bezpiecznym override `core.guild_need_premium=false` tylko wewnatrz procesu testowego tworzy jedna lokalna gildie i jedna globalna instancje,
  - po cleanupie przywraca stan `local/global = 0`,
- `global-guilds-validation-guard.php` potwierdzil parytet walidacji nazw gildii miedzy `Validator::guildName()` i `globalGuildsIsValidName()` dla zestawu przypadkow pozytywnych i negatywnych,
- `global-guilds-auth-smoke.php` potwierdzil kontrakt auth dla endpointow gildii:
  - `401 missing_api_key` bez naglowka,
  - `403 invalid_api_key` dla blednego klucza,
  - `404 not_found` dla poprawnego klucza i brakujacej gildii,
  - `201 created` dla `reserve-or-attach`,
  - `200` dla `lookup`, `instances` i `heartbeat`,
  - cleanup danych testowych przywrocil `global_guilds/global_guild_events` do zera po tescie,
- `global-guilds-mutation-guard.php` potwierdza juz zamkniecie wszystkich znanych lokalnych pathow mutacji gildii poza registry:
  - `create` pathy ida przez `GlobalGuildRegistry::createGuild`,
  - `delete / disband / cleanup` sa podpiete pod archive flow,
  - adminowy `rename` jest twardo zablokowany,
- `global-guilds-archive-smoke.php` potwierdzil nowy backend delete-flow:
  - `201 created` dla poczatkowego `reserve-or-attach`,
  - `200 archived` dla `archive instance`,
  - globalna gildia przechodzi do statusu `archived`, gdy nie ma juz aktywnych instancji,
  - obcy owner nadal dostaje `409 guild_name_reserved` po archiwizacji, wiec nazwa nie jest uwalniana automatycznie,
  - ten sam owner moze potem odtworzyc gildie przez `reattach`, a status wraca do `active`,
  - cleanup danych testowych przywraca stan do zera,
- `global-guilds-create-audit.php` potwierdzil, ze w repo WWW nie ma dodatkowych webowych pathow tworzenia gildii poza:
  - `app/Controller/Pages/Guilds/Found.php`,
  - `system/pages/guilds/create.php`,
  - `GlobalGuildRegistry::createGuild`,
- `global-guilds-owner-audit.php` po decyzji produktowej o rozdzieleniu `global owner` i `local leader`:
  - traktuje delegowanego lokalnego lidera jako poprawny stan,
  - raportuje tylko brak wpisu registry / brak instancji scope,
  - na aktualnej bazie testowej przeskanowal `1` lokalna gildie i nie wykryl problemow registry,
- `global-guilds-ownership-model-smoke.php` potwierdzil nowy model ownership:
  - `reserve-or-attach` tworzy gildie z `owner_global_account_id`,
  - delegowany `local leader` zostaje zapisany na instancji serwerowej,
  - jawny transfer ownera zmienia `owner_global_account_id` na `global_guilds` i `global_guild_instances`,
  - delegowany `local leader` pozostaje zachowany po transferze ownera,
  - stary owner dostaje `409 guild_name_reserved`,
  - nowy owner moze wykonac `reattach`,
  - cleanup danych testowych przywraca stan do zera,
- `global-guilds-rollout-readiness.php --with-auth-smoke --with-ownership-smoke` zwraca `ok=true` na bazie testowej po migracji `011`,
- `global-guilds-sync-status.php` i `migrations/global-guilds-sync-status.php` zwracaja zbiorczy status scope-ow `game_slug + game_mode + world_id`, w tym:
  - liczbe instancji,
  - stale `heartbeat`,
  - status delegacji `local leader`,
  - ostatni `last_seen_at`,
- `global-guilds-smoke-test.php` potwierdzil backendowy bootstrap `local leader` dla helpera WWW:
  - helper-created instancja dostaje founder-a jako pierwszego `local leader`,
  - zapis globalny zawiera `playerId`, `playerName` i `assignedByGlobalAccountId`,
- `global-guilds-auth-smoke.php` potwierdzil bootstrap `local leader` dla endpointu `reserve-or-attach`:
  - odpowiedz zwraca `localLeaderBootstrapState=assigned`,
  - `instances` zwraca juz przypisanego `localLeader`,
- helper `reddaxe_fetch_owned_global_guilds()` zostal sprawdzony realnie na test DB:
  - czyta `global_guilds` i `global_guild_instances` po `owner_global_account_id`,
  - dolacza lokalnych czlonkow z `canaryaac` dla instancji Tibii,
  - obecny testowy owner `6` zwraca `1` globalna gildie i `1` aktywna instancje,
- `global-guilds-delete-helper-smoke.php` potwierdzil, ze realny legacy helper `delete_guild()`:
  - usuwa lokalna gildie,
  - archiwizuje globalna instancje,
  - ustawia `global_guilds.status=archived`,
  - cleanup przywraca globalne rekordy testowe do zera,
- smoke test ujawnil i doprowadzil do poprawki blednego rozpoznawania `heartbeat instanceState`,
- po cleanupie danych testowych stan baz wrocil do:
  - `global_guilds = 0`
  - `global_guild_instances = 0`
  - `global_guild_events = 0`
  - `local guilds = 0`

Wniosek:

- etap `globalne gildie P0` jest rozpoczecy,
- etap `globalne gildie P0` ma juz wykonany rollout i zapisowe smoke testy na bazie testowej,
- etap `globalne gildie P0` ma juz takze zamkniety model auth na bazie testowej,
- oba webowe pathy tworzenia gildii sa juz potwierdzone testami: nowy helperowy i legacy,
- etap `globalne gildie P0` ma juz zsynchronizowane `create / delete / disband / cleanup` oraz twardo zablokowany adminowy `rename`,
- etap `globalne gildie P0` ma juz backendowy model ownership:
  - `1 global owner`,
  - jawny transfer ownera,
  - delegowany `local leader` per serwer,
- etap `RedDaxe.pl` ma juz pierwszy read-only foundation pod gildie ownera, ograniczony do zalogowanych kont z istniejaca globalna gildia,
- zalogowane konto bez gildii dostaje tylko CTA do rozpoczecia zalozenia gildii, bez pelnego panelu ownera,
- otwarte pozostaja glownie zadania rolloutowe dla produkcji i kolejne etapy frontendowe,
- etap `globalne topki` nadal pozostaje nieruszony,
- przed produkcja trzeba domknac kilka blockerow technicznych opisanych nizej.

## 1. Cel

Chcemy zbudowac dwa powiazane systemy:

1. `global guild registry`
2. `global leaderboards`

Oba systemy maja dzialac ponad wieloma grami / serwerami, ale bez przenoszenia calej logiki gry do jednej wspolnej bazy.

Zasada nadrzedna:

- baza globalna trzyma tylko dane lekkie, indeksujace i agregacyjne,
- bazy serwerowe pozostaja zrodlem prawdy dla logiki lokalnej,
- launcher, `WWW Tibia`, strony per-gra i `RedDaxe.pl` korzystaja z jednego backendu globalnego,
- UI strony w przyszlosci moze pobierac lub doszczegolawiac dane z baz serwerowych przez backend, a nie przez bezposredni dostep z frontu.

## 2. Zasady ogolne

### 2.1 Co jest globalne

Globalne maja byc tylko te elementy, ktore rzeczywiscie musza byc wspolne dla calej sieci serwerow:

- rezerwacja nazwy gildii,
- globalny identyfikator gildii,
- lista wystapien danej gildii na roznych serwerach,
- globalne liczniki i rankingi,
- globalny identyfikator gracza / konta potrzebny do agregacji.

### 2.2 Co zostaje lokalne per serwer

W bazach serwerowych pozostaje cala logika lokalna:

- wymagania do zalozenia gildii,
- sklad czlonkow gildii,
- rangi i uprawnienia w gildii,
- lokalne wojny, claimy i eventy,
- statystyki gameplayowe surowe,
- lokalne topki serwera.

To obejmuje tez listy czlonkow gildii.

Model dla frontow:

- `RedDaxe.pl` ma pokazywac listy czlonkow gildii, ale dane maja pochodzic z lokalnych systemow gildii serwerow,
- `WWW Tibia` ma pokazywac publiczne widoki gildii i topek dla Tibii,
- globalna baza nie ma byc miejscem do trzymania pelnego skladu gildii dla wszystkich serwerow, jesli nie ma takiej potrzeby biznesowej.

### 2.3 Wazna zasada produktowa

To, ze gildia jest globalnie zarezerwowana, nie oznacza, ze istnieje automatycznie na kazdym serwerze.

Model docelowy:

- nazwa gildii jest jedna dla calego ekosystemu,
- gildia moze miec wiele `local guild instance`,
- kazda instancja serwerowa musi byc utworzona zgodnie z wymaganiami tego serwera,
- czlonkowie dolaczaja osobno na kazdym serwerze,
- sklad i stan gildii moga byc rozne na kazdym serwerze.

### 2.4 I18N i teksty widoczne dla gracza

Wszystkie teksty systemowe widoczne dla gracza musza byc prowadzone przez `i18n`.

Dotyczy to:

- launchera,
- `WWW Tibia`,
- stron per-gra,
- `RedDaxe.pl`,
- komunikatow API renderowanych w UI,
- pustych stanow, bledow, tooltipow, filtrow, CTA i onboardingow,
- widokow globalnych gildii i globalnych topek.

To oznacza:

- nie dodajemy nowych hardkodowanych stringow user-visible,
- API powinno zwracac stabilne kody / pola danych, a warstwa UI mapuje je na klucze `i18n`,
- fallback jezykowy musi byc zdefiniowany i spojny dla launchera i WWW,
- teksty generowane przez system, np. "nazwa gildii jest zajeta", musza byc kluczami `i18n`.

Wyjatek:

- tresci tworzone przez graczy nie sa tlumaczone, np. nazwa gildii, nazwa postaci, opis user-generated.

### 2.5 Publiczne strony gry i osobny panel RedDaxe

Trzeba przygotowac dwa rozne typy frontow:

- publiczne strony per-gra:
  - `WWW Tibia`
  - kolejne strony stricte pod inne gry
- panel zarzadzania:
  - `RedDaxe.pl`

Rekomendacja produktowa:

- wszystkie fronty korzystaja z tych samych kontraktow backendowych,
- `RedDaxe.pl` nie jest miejscem do publicznych topek ani publicznych list gildii,
- `RedDaxe.pl` ma miec tylko minimalne zarzadzanie gildia i widok skladu gildii z podzialem na serwery,
- listy czlonkow gildii maja pozostac widoczne na `RedDaxe.pl`,
- pelne informacje publiczne o gildiach, topkach i topkach gildii maja byc pokazywane na stronach stricte pod dana gre,
- glowne i maksymalne zarzadzanie gildia dla Tibii ma byc na `WWW Tibia` / widoku `all worlds`, a nie na `RedDaxe.pl`,
- `WWW Tibia` jest wzorcem dla jednego takiego publicznego frontend-u gry,
- copy, i18n i nazwy statusow nie moga rozjezdzac sie miedzy panelami i stronami gry.

Twardy podzial odpowiedzialnosci:

- `RedDaxe.pl`:
  - panel kontowy / zarzadczy,
  - lista czlonkow gildii,
  - lista instancji gildii na roznych serwerach,
  - tylko minimalne zarzadzanie gildia i ownership.
- `WWW Tibia`:
  - publiczne widoki gildii,
  - publiczne listy gildii,
  - topki i topki gildii dla Tibii,
  - widok `all worlds` dla sieci Tibii,
  - glowne / maksymalne zarzadzanie gildia dla Tibii.

## 3. Wspolna tozsamosc gracza

Bez wspolnej tozsamosci nie da sie dobrze zrobic ani globalnych gildii, ani globalnych topek.

Potrzebujemy wspolnego identyfikatora:

- `global_account_id` albo `global_player_id`

Rekomendacja:

- agregacje globalne liczyc po `global_account_id`,
- postac / nick serwerowy traktowac jako reprezentacje lokalna,
- publicznie wyswietlac `display_name`, ale technicznie laczyc rekordy po globalnym ID.

Powod:

- ten sam gracz moze miec inne nicki na roznych serwerach,
- dwa rozne konta moga miec podobne lub identyczne nazwy postaci,
- bez globalnego ID topki beda mialy kolizje albo falszywe sumy.

## 4. Globalne gildie

## 4.1 Model

Potrzebujemy dwoch warstw:

1. `global guild`
2. `local guild instance`

`global guild`:

- rezerwuje nazwe w skali calej sieci,
- przechowuje minimalne dane indeksujace,
- moze byc polaczona z wieloma serwerami.

`local guild instance`:

- reprezentuje konkretna gildie na konkretnym serwerze,
- ma lokalnego lidera, lokalnych czlonkow i lokalny stan,
- jest tworzona tylko po spelnieniu regul danego serwera.

## 4.2 Regula rezerwacji nazwy

Jesli gildia zostanie utworzona na dowolnym serwerze, to:

- system normalizuje jej nazwe,
- tworzy wpis w bazie globalnej,
- od tego momentu tej samej nazwy nie da sie zalozyc jako nowej, niezaleznej gildii na zadnym innym serwerze.

Normalizacja nazwy powinna obejmowac:

- case-insensitive compare,
- trim spacji brzegowych,
- skladanie wielokrotnych spacji,
- ewentualne usuniecie znakow nieistotnych, jesli polityka nazw tak zdecyduje.

Potrzebne jest tez pole:

- `guild_name_normalized`

z unikalnym indeksem globalnym.

Do tego dochodzi wymog transakcyjnosci:

- rezerwacja nazwy musi byc atomowa,
- dwa serwery probujace zalozyc te sama gildie naraz nie moga wygrac jednoczesnie,
- backend globalny musi byc jedynym miejscem, ktore nadaje finalny `global_guild_id`.

## 4.3 Odtworzenie gildii na nowym serwerze

Jesli wlasciciel chce odtworzyc gildie na nowym serwerze:

1. musi zalogowac sie tym samym kontem globalnym,
2. musi spelnic wymagania tworzenia gildii na tym konkretnym serwerze,
3. system lokalny pyta backend globalny, czy nazwa jest:
   - wolna
   - nalezy do tej samej globalnej gildii
   - nalezy do kogos innego
4. jesli nazwa nalezy do tej samej globalnej gildii, serwer tworzy `local guild instance` podpieta pod istniejacy `global_guild_id`,
5. czlonkowie dolaczaja od nowa na tym serwerze.

To daje wlasnie model, ktory opisales:

- nazwa jest globalnie zarezerwowana,
- ale byt gildii na nowym serwerze nie powstaje automatycznie,
- serwer zachowuje swoje lokalne wymagania i proces dolaczania.

Dodatkowa zasada v1:

- samo pierwsze polaczenie postaci z serwerem nie tworzy jeszcze gildii automatycznie,
- jesli `global owner` wchodzi pierwszy raz na serwer, na ktorym ta globalna gildia nie ma jeszcze aktywnej lokalnej instancji albo instancja jest pusta:
  - brak czlonkow,
  - brak przypisanego `local leader`,
  - brak lokalnego konfliktu stanu,
- to po poprawnym przejsciu lokalnego flow zalozenia / konfiguracji gildii i po spelnieniu wymagan tego serwera:
  - powstaje `local guild instance`,
  - postac uzyta do tego flow dostaje automatycznie role `local leader`,
  - `global owner` nie musi byc wczesniej recznie delegowany jako lokalny lider na tym serwerze.

To jest tylko bootstrap pustej instancji.

Nie robimy automatycznego nadania lidera, jesli:

- na serwerze sa juz czlonkowie gildii,
- `local leader` jest juz przypisany,
- instancja jest w stanie posrednim wymagajacym recznej decyzji ownera / admina.

## 4.4 Dane globalne o gildii maja byc minimalne

Rekomendowany zakres globalny:

- `global_guild_id`
- `guild_name_original`
- `guild_name_normalized`
- `owner_global_account_id`
- `created_on_server_id`
- `created_at`
- `status`
- `last_seen_at`
- `primary_brand_game_id` lub `origin_game_id`

Opcjonalnie:

- `public_slug`
- `logo_asset_id`
- `visibility`

Nie trzymamy globalnie:

- pelnej listy czlonkow,
- rang i permissions,
- historii wojen,
- lokalnych invitation flow,
- lokalnego MOTD jako zrodla prawdy,
- wszystkich metryk lokalnych.

## 4.5 Statusy gildii

Minimalne statusy:

- `active`
- `archived`
- `locked`
- `deleted`

Rekomendacja:

- nie uwalniac nazwy gildii od razu po lokalnym usunieciu,
- miec polityke recznego zwolnienia lub bardzo dlugiego cooldownu,
- traktowac nazwe gildii jako dobro sieciowe, nie jako chwilowy rekord lokalny.

To chroni przed sytuacja:

- gildia znika na jednym serwerze,
- ktos inny od razu przejmuje te sama marke na innym serwerze.

## 4.6 Ownership i transfer

Model domenowy po decyzji produktowej:

- `owner_global_account_id` jest jeden dla calej `global guild`,
- ten owner jest jedynym kontem z prawem do globalnego claimu nazwy, attachowania nowych instancji i delegowania lokalnych liderow,
- `owner_global_account_id` moze sie zmienic tylko przez jawny transfer ownership,
- transfer ownership jest globalny, nie lokalny,
- na kazdym serwerze dana instancja gildii moze miec innego lokalnego lidera,
- lokalny lider nie musi byc rowny globalnemu ownerowi,
- globalny owner moze nigdy nie pojawic sie na danym serwerze jako postac,
- globalny owner moze wskazac lub zmienic lokalnego lidera dla konkretnego serwera w dowolnym momencie,
- instancja serwerowa moze czasowo nie miec jeszcze przypisanego lokalnego lidera.

Regula bootstrapu lokalnego lidera:

- jesli `global owner` sam odtwarza gildie na nowym serwerze i lokalna instancja jest jeszcze pusta, to jego postac zakladajaca / konfigurujaca gildie staje sie automatycznie pierwszym `local leader`,
- ta automatyka dziala tylko dla pustej instancji:
  - bez czlonkow,
  - bez przypisanego `local leader`,
  - po spelnieniu lokalnych warunkow zalozenia gildii,
- po takim bootstrapie dalsze zmiany `local leader` wracaja juz do zwyklego modelu delegowania,
- ten bootstrap nie zmienia `owner_global_account_id`; tworzy tylko pierwszego lidera dla konkretnego serwera.

Wniosek architektoniczny:

- `global owner` i `local leader` to dwa rozne byty domenowe,
- zmiana lokalnego lidera nie moze automatycznie zmieniac `owner_global_account_id`,
- audyty i tooling operacyjny musza rozrozniac:
  - brak / blad registry,
  - delegowanego lokalnego lidera,
  - jawny transfer global ownership.

Rekomendacja v1:

- globalny owner zostaje kontraktem twardym i pojedynczym,
- lokalni liderzy sa delegowani per serwer,
- automatyczny sync `local leader -> global owner` jest zabroniony,
- kontrolowany transfer `owner_global_account_id` robimy jako osobny flow administracyjny / ownerski, nie jako efekt uboczny lokalnych zmian.

Stan backendu po P0:

- `global_guild_instances` ma juz pola `local_leader_*`,
- backend ma wewnetrzne endpointy do:
  - jawnego transferu ownera,
  - przypisania / wyczyszczenia `local leader`,
- backend ma tez automatyczny bootstrap pierwszego `local leader` dla pustej instancji po poprawnym `create / attach`,
- rollout readiness i smoke testy pokrywaja juz takze ten model ownership.

## 4.7 Potwierdzone wnioski po pierwszej implementacji P0

Po pierwszym przejsciu implementacyjnym trzeba doprecyzowac kilka rzeczy:

### 4.7.1 `owner_global_account_id` jest kontraktem docelowym, ale mapowanie ownera nadal musi byc jawne przed separacja DB

To jest najwazniejsza uwaga do modelu.

Stan obecny implementacji:

- live helper `getGlobalDb()` jest jeszcze skonfigurowany tak, ze gdy `GLOBAL_DB_NAME` nie jest ustawione, korzysta z tej samej bazy co `DB_NAME`,
- draft registry i API uzywaja juz nazw `owner_global_account_id` / `ownerGlobalAccountId`,
- w shared DB `accounts.id` z `canaryaac` dziala jako tymczasowy identyfikator ownera w registry,
- jesli `GLOBAL_DB_NAME` wskazuje juz na osobna baze, a mapowanie ownera nie istnieje, helper ma fail-closed i nie pozwala zalozyc / attachowac gildii,
- to jest akceptowalne tylko jako stan przejsciowy, dopoki globalna baza kont nie zostanie odseparowana.

Ryzyko:

- po przejsciu na osobne `global_accounts` albo na pelne multi-game / multi-db ten skrot przestanie byc poprawny,
- wtedy trzeba miec jawne mapowanie `local_account_id -> global_account_id`,
- bez tego ten sam gracz moze nie moc odtworzyc swojej gildii na innym serwerze.

Wniosek:

- kontrakt ownera jest juz poprawiony na poziomie nazewnictwa i draft implementacji,
- nadal pozostaje `must-fix` operacyjne: trzeba wskazac i wdrozyc docelowa tabele mapujaca `local_account_id -> global_account_id` przed separacja globalnej bazy i przed rolloutem multi-game.

### 4.7.2 `local_guild_id` nie moze byc unikalny globalnie bez scope serwera / gry

To jest poprawna uwaga do schematu.

Jesli `global_guild_instances.local_guild_id` bedzie mial `UNIQUE` bez:

- `game_slug`
- `game_mode`
- `world_id`

to przy wielu bazach serwerowych dojdzie do kolizji ID.

Wniosek:

- draft migracji jest juz poprawiony,
- przed rolloutem trzeba tylko upewnic sie, ze zadne srodowisko nie odpalilo starej wersji `008`,
- docelowo instancja gildii jest identyfikowana przez scope serwera, a nie tylko przez samo `local_guild_id`.

### 4.7.3 Cross-DB atomowosc pozostaje ograniczona

Pierwsza implementacja P0 dziala w modelu:

1. rezerwacja globalna,
2. zapis lokalny,
3. attach instancji globalnej.

To nie jest jedna atomowa transakcja miedzy dwiema bazami.

Wniosek:

- w v1 trzeba to traktowac jako `eventual consistency`,
- draft implementacji ma juz podstawowe logowanie kontekstu partial-failure,
- nadal trzeba dodac:
  - smoke testy scenariuszy awarii,
  - narzedzie naprawcze / reconcile job.

To nie blokuje developmentu P0, ale blokuje bezpieczny rollout bez operacyjnego domkniecia.

### 4.7.4 Collation dla `guild_name_normalized` zostala przypieta w drafcie, ale rollout nadal jest przed nami

Aktualna polityka nazw gildii w kodzie waliduje nazwy praktycznie do ASCII.

Wniosek:

- dla draft migracji przyjeto `utf8mb4_bin` dla `guild_name_normalized`,
- przy obecnej polityce ASCII to rozwiazuje problem jednoznacznego porownania na poziomie DB,
- przed dopuszczeniem nazw Unicode nadal trzeba zdecydowac, czy wystarcza sama normalizacja backendowa, czy dochodzi transliteracja / dodatkowe reguly.

### 4.7.5 Regex walidacji musi uzywac `A-Za-z`, nie `A-z`

To jest potwierdzony blad walidacyjny.

Zakres `A-z` obejmuje dodatkowe znaki ASCII pomiedzy `Z` i `a`.

Wniosek:

- regex w flow gildii i walidatorach gildii zostal juz poprawiony,
- nadal trzeba pilnowac tej samej reguly, jesli dojdzie osobny hook serwerowy albo kolejne fronty.

### 4.7.6 Samo istnienie kodu nie oznacza wdrozenia

Na dzis:

- tabele registry jeszcze nie istnieja w live DB,
- implementacja jest gotowa roboczo,
- system nadal dziala praktycznie w trybie `local-only`.

Wniosek:

- dopoki migracja nie zostanie odpalona i nie przejda smoke testy, traktujemy ten etap jako `implementation in progress`, nie jako `done`.

## 4.8 Dodatkowe decyzje produktowo-techniczne dla gildii

Po pierwszym etapie implementacji doszly jeszcze decyzje, ktore trzeba zapisac:

### 4.8.1 Czy zakladanie gildii istnieje tylko przez WWW, czy tez bezposrednio w silniku

Po dalszej analizie wiemy juz, ze w WWW byly dwa aktywne pathy zakladania gildii:

- `app/Controller/Pages/Guilds/Found.php`
- `system/pages/guilds/create.php`

Oba webowe pathy sa juz podpiete pod `global guild registry`.

Jesli zakladanie gildii przechodzi tylko przez WWW, to P0 moze byc domkniete po stronie WWW + backend.

Jesli gildie moga powstawac tez:

- bezposrednio w grze,
- przez skrypty admina,
- przez inne panele,

to trzeba dodac drugi kanal synchronizacji lub hook do silnika.

Po audycie `2026-03-08` wiemy tez, ze nawet bez dodatkowego create path nadal istnieja lokalne flow mutacji gildii poza registry:

- rename w panelu admina,
- delete w panelu admina,
- disband z WWW,
- legacy delete / cleanup helpery.

To oznacza, ze P0 backendu gildii nie moze byc uzniete za zamkniete tylko na podstawie ochrony create flow.

Aktualizacja po domknieciu backendu:

- `delete` w panelu admina,
- `disband` z WWW,
- legacy `delete / cleanup`,

sa juz zsynchronizowane z registry, a adminowy `rename` jest swiadomie zablokowany w v1.

Nowy wynik audytu WWW:

- `global-guilds-create-audit.php` potwierdzil brak dodatkowych webowych pathow create poza dwoma juz znanymi flow,
- pytanie o bezposrednie tworzenie gildii przez sam silnik gry pozostaje osobnym taskiem poza zakresem tego repo WWW.

### 4.8.2 Potrzebny jest reconcile job dla gildii

Skoro nie mamy jednej transakcji cross-DB, to potrzebujemy narzedzia, ktore:

- znajdzie globalne rezerwacje bez aktywnej instancji,
- znajdzie lokalne gildie bez wpisu w `global_guild_instances`,
- pozwoli to naprawic automatycznie albo recznie.

Stan na dzis:

- report-only endpoint reconcile jest juz przygotowany,
- CLI `global-guilds-repair.php` jest juz przygotowany:
  - domyslnie `dry-run`
  - opcjonalnie `--apply` dla kontrolowanej naprawy
  - przetestowany na bazie testowej bez wykrytych niespojnosci.

### 4.8.3 Rollout musi miec kolejnosc operacyjna

Kolejnosc dla produkcji powinna byc jawnie ustalona:

1. poprawa schematu i walidacji,
2. dodanie configu API,
3. odpalanie migracji,
4. auth:
   - aktualny model: dedykowany `GLOBAL_GUILDS_API_KEY`
   - ewentualna migracja do wspolnego `admin_api_keys` nie jest blockerem P0
5. smoke testy owner / conflict / attach,
6. dopiero potem wlaczenie flow produkcyjnego.

Wazne doprecyzowanie po testach DB:

- rollout `008/009` musi isc dedykowanym runnerem do `GLOBAL_DB`,
- rollout mapowania ownera musi objac tez `010_global_guild_account_links`,
- przed rolloutem trzeba jawnie rozstrzygnac kontrakt ownera:
  - tymczasowy `same ids in local/global accounts`
  - albo docelowe `account_world_links`,
- dopiero po tym jest sens uruchamiac smoke testy produkcyjne.

Nowe narzedzie operacyjne:

- `global-guilds-rollout-readiness.php` zbiera w jednym miejscu:
  - status migracji,
  - `GLOBAL_GUILDS_API_KEY`,
  - `global-guilds-db-preflight.php`,
  - `global-guilds-mutation-guard.php`,
  - opcjonalnie `global-guilds-auth-smoke.php`.

Nowe narzedzia ownership / create:

- `global-guilds-create-audit.php`:
  - potwierdza create pathy w repo WWW,
  - nie obejmuje samego silnika gry,
- `global-guilds-owner-audit.php`:
  - pokazuje relacje `global owner` vs `local leader`,
  - traktuje delegowanego lokalnego lidera jako poprawny stan,
  - raportuje tylko realne problemy registry i brak instancji scope.

Dodatkowy wniosek z analizy kodu WWW:

- aktywny flow `app/Controller/Pages/Account/Create.php` jest juz zgrany z `GLOBAL_DB`,
- legacy `system/pages/account/create.php` tylko przekierowuje na `RedDAXE`, wiec nie tworzy lokalnego konta,
- `register-account-lib.php` ma juz transakcyjne dopiecie `account_games`,
- nadal trzeba osobno domknac mirror lokalnego `accounts` dla rejestracji API / `RedDAXE`, zeby wszystkie wejscia tworzenia kont byly spojne z owner mappingiem gildii.

Ograniczenie obecnego helpera:

- mirrorowanie WWW create flow zaklada, ze lokalny DB i `GLOBAL_DB` sa na tym samym serwerze i pod tymi samymi credentials,
- przy przyszlym rozdzieleniu hostow trzeba bedzie zrobic dedykowany provisioning flow zamiast cross-schema transaction.

## 5. Globalne topki

## 5.1 Model

Topki globalne nie powinny byc kopia lokalnych rankingow 1:1.

Potrzebujemy trzech poziomow:

1. `server leaderboard`
2. `global raw metrics`
3. `global aggregated leaderboard`

`server leaderboard`:

- zostaje w bazie danego serwera,
- sluzy lokalnej grze.

`global raw metrics`:

- to znormalizowane liczniki eksportowane z serwera do backendu globalnego,
- np. `players_killed`, `bosses_killed`, `deaths`, `quests_completed`.

`global aggregated leaderboard`:

- to rankingi liczone na bazie globalnych metryk,
- np. suma PvP kills ze wszystkich serwerow.

## 5.2 Przyklad z PvP kills

Jesli gracz:

- zabil `20` graczy na serwerze 7.4,
- zabil `30` graczy na serwerze modern,

to w topce globalnej moze miec:

- `global_players_killed = 50`

ale tylko wtedy, gdy obie wartosci sa przypisane do tego samego `global_account_id`.

## 5.3 Kategorie topek

Rekomendacja:

- nie robic jednej wielkiej topki "wszystko razem",
- tylko podzielic topki na logiczne typy.

Minimalne typy:

- `global_total`
- `global_seasonal`
- `global_per_ruleset`
- `global_per_game_family`
- `global_per_server_cluster`

Przyklady:

- globalna topka PvP wszystkich gier,
- globalna topka PvP tylko dla `7.4-like`,
- globalna topka PvE tylko dla `modern`,
- globalna topka sezonowa,
- globalna topka gildii.

## 5.4 Problem porownywalnosci

Nie wszystkie statystyki sa porownywalne miedzy serwerami.

Przyklad:

- `level 200` na jednym serwerze moze znaczyc cos innego niz `level 200` na innym,
- economy, exp rate i PvP rules moga byc skrajnie rozne.

Dlatego kazda topka musi miec jawnie opisany typ agregacji:

- `sum`
- `max`
- `weighted_score`
- `per_season`
- `per_ruleset`

Rekomendacja v1:

- zaczac od metryk prostych i porownywalnych:
  - `players_killed`
  - `deaths`
  - `boss_kills`
  - `quests_completed`
  - `playtime`
  - `achievements_count`

Odlozyc na pozniej:

- globalny level score,
- globalna wartosc eq,
- globalna ekonomia,
- rankingi wymagajace skomplikowanej normalizacji.

## 5.5 Zrodlo prawdy dla topek

Zrodlem prawdy dla surowych zdarzen sa bazy serwerowe.

Baza globalna nie powinna byc recznie edytowana przez strone ani launcher.

Model rekomendowany:

1. serwer zapisuje gameplay do swojej bazy,
2. worker lub API adapter eksportuje znormalizowane zdarzenia / snapshoty,
3. backend globalny aktualizuje tabele agregacyjne,
4. launcher i strony per-gra czytaja gotowe rankingi z backendu globalnego.

## 5.6 Snapshoty vs eventy

Sa dwa sensowne modele:

### Model A - snapshoty

Serwer co okres wysyla stan licznikow:

- prostszy do wdrozenia,
- latwiejszy do odbudowy po awarii,
- dobry do v1.

### Model B - eventy

Serwer wysyla kazde istotne zdarzenie:

- dokladniejszy,
- lepszy do historii,
- trudniejszy do utrzymania i idempotencji.

Rekomendacja:

- `v1` opierac na snapshotach lub deltach okresowych,
- `v2` rozbudowac o eventy tam, gdzie beda potrzebne.

## 5.7 Kwalifikacja i moderacja wynikow

Brakuje jeszcze jednej waznej warstwy:

- nie wszystkie wyniki powinny zawsze trafic do globalnych topek.

Potrzebne sa flagi i polityki:

- `eligible_for_global_rankings`
- `excluded_from_global_rankings`
- `server_trusted`
- `season_locked`

Powody:

- mozna chciec wykluczyc testowe serwery,
- mozna chciec wylaczyc konto z rankingu po karze,
- mozna chciec zamrozic sezon przed publikacja finalnych wynikow.

## 5.8 Sezony, czas i korekty

Topki globalne musza miec jawnie zdefiniowane:

- strefe czasowa,
- moment resetu sezonu,
- polityke korekt po opoznionym syncu,
- polityke przeliczenia po rollbacku lub naprawie danych.

Rekomendacja:

- wszystkie znaczniki czasu liczyc w `UTC`,
- sezon definiowac po `season_id`,
- agregaty robic jako przeliczalne, a nie tylko "write once".

## 6. Architektura danych

## 6.1 Baza globalna

Minimalne tabele / kolekcje:

- `global_accounts`
- `global_players`
- `global_guilds`
- `global_guild_instances`
- `server_registry`
- `leaderboard_metric_definitions`
- `leaderboard_metric_snapshots`
- `leaderboard_aggregates`
- `leaderboard_seasons`
- `moderation_flags`
- `sync_jobs`
- `sync_audit_log`

## 6.2 Baza serwerowa

Po stronie serwera pozostaja:

- `guilds`
- `guild_members`
- `players`
- `player_stats`
- `guild_stats`
- tabele gameplayowe

Serwer powinien znac:

- `server_id`
- `game_id`
- mapowanie lokalnego konta / postaci na `global_account_id`

## 6.3 Granica odpowiedzialnosci

Global backend odpowiada za:

- rezerwacje nazw gildii,
- nadawanie `global_guild_id`,
- walidacje claimu na nowym serwerze,
- agregacje globalnych metryk,
- udostepnianie danych dla launchera i strony.

Serwer gry odpowiada za:

- sprawdzenie wymagan do stworzenia gildii,
- faktyczne stworzenie lokalnej gildii,
- zarzadzanie czlonkami,
- produkcje lokalnych statystyk,
- eksport danych do backendu globalnego.

## 7. API i synchronizacja

## 7.1 Endpointy gildii

Minimalne endpointy:

- `POST /api/global/guilds/reserve-or-attach`
- `GET /api/global/guilds/by-name/{normalized_name}`
- `GET /api/global/guilds/{global_guild_id}`
- `POST /api/global/guilds/{global_guild_id}/attach-server`
- `POST /api/global/guilds/{global_guild_id}/heartbeat`

## 7.2 Endpointy topek

Minimalne endpointy:

- `POST /api/global/leaderboards/ingest-snapshot`
- `GET /api/global/leaderboards/{metric_key}`
- `GET /api/global/leaderboards/{metric_key}/by-ruleset/{ruleset}`
- `GET /api/global/players/{global_account_id}/summary`
- `GET /api/global/guilds/{global_guild_id}/summary`

## 7.3 Bezpieczenstwo integracji

Wazne:

- tylko backend serwera albo zaufany worker moze wysylac dane sync,
- launcher i strona tylko odczytuja,
- nie robimy bezposrednich zapisow globalnych z frontu.

Rekomendacja:

- podpisane requesty serwer -> global API,
- `server_api_key` lub podpis HMAC / Ed25519,
- idempotency key dla ingestu,
- audit log dla zmian rezerwacji i agregacji.

## 7.4 Kontrakt API dla frontow i i18n

Frontendy nie powinny dostawac tylko "gotowego HTML w JSON".

API powinno zwracac:

- surowe dane,
- enumy i statusy techniczne,
- klucze lub mapowalne typy dla komunikatow,
- daty i liczby w formacie nadajacym sie do lokalnego renderu.

To pozwala:

- utrzymac jeden model danych dla launchera, `WWW Tibia`, stron per-gra i `RedDaxe.pl`,
- nie duplikowac logiki tlumaczen po backendzie i froncie,
- nie mieszac jezykow przy fallbackach.

## 8. Integracja z launcherem, stronami gry i RedDaxe.pl

## 8.1 Launcher

Launcher moze pokazywac:

- globalne topki,
- profil gracza w sieci serwerow,
- liste serwerow, na ktorych istnieje dana gildia,
- informacje o tym, czy nazwa gildii jest globalnie zajeta.

Ale launcher nie powinien byc zrodlem prawdy.

Launcher czyta tylko z globalnego API.

## 8.2 RedDaxe.pl

`RedDaxe.pl` nie ma byc publicznym katalogiem topek i gildii.

`RedDaxe.pl` ma byc panelem kontowym z minimalnym zarzadzaniem gildia.

Stan po pierwszej implementacji:

- panel konta pokazuje sekcje `guilds` tylko wtedy, gdy zalogowane konto jest ownerem co najmniej jednej globalnej gildii,
- zalogowane konto bez globalnej gildii widzi tylko akcje `Zaloz gildie`,
- aktualny zakres tej zakladki jest read-only i owner-centric,
- widok pokazuje globalne gildie ownera, instancje oraz lokalnych czlonkow dla Tibii,
- formularz `RedDAXE` `/reddaxe/guild-found.php` jest osobnym entry pointem i nie przerzuca juz usera na layout `WWW Tibia`,
- formularz `RedDAXE` `/reddaxe/guild-found.php` nadal ma jeszcze pole lokalnego hasla konta jako przejsciowy mechanizm potwierdzenia akcji,
- temat usuniecia tego pola i zastapienia go polityka `session trust + CSRF + audit + rate limit` zostal wydzielony do osobnego planu:
  - `Dokumentacja/2026-03-09_plan_reddaxe_auth_akcji_wrazliwych_i_social.md`,
- formularz ma juz czytelne stany sukcesu dla:
  - pierwszego globalnego utworzenia,
  - attach / odtworzenia gildii ownera na innym serwerze,
  - auto-przypisania pierwszego `local leader`,
- panel ma juz tez podstawowe delegowanie `local leader` dla instancji Tibii oraz read-only stan bootstrapu / braku lidera,
- panel ma juz tez jawny `transfer owner` na inne konto globalne,
- `attach / odtworzenie gildii` z `RedDAXE` zostaje swiadomie poza zakresem, bo ma pozostac po stronie fizycznego serwera / strony serwera,
- poza zakresem `RedDAXE` pozostaja nadal bardziej rozbudowane funkcje lokalne gildii na samym serwerze.

Minimalny zakres:

- minimalny panel gildii,
- lista czlonkow gildii z podzialem na serwery,
- widok instancji gildii na roznych serwerach,
- tylko podstawowe akcje ownership / attach / zarzadzanie dostepem, jesli zostana dopuszczone produktowo.

To jest wymagany element produktu, a nie opcjonalny dodatek:

- `RedDaxe.pl` ma pokazywac sklad gildii per serwer,
- `RedDaxe.pl` nie ma zastapowac publicznego katalogu gildii,
- `RedDaxe.pl` ma sluzyc tylko zalogowanemu ownerowi z istniejaca gilda / minimalnemu zarzadzaniu.
- logged-in user bez gildii ma miec tylko wejscie w flow `Zaloz gildie`, a nie pelny panel ownera.
- pierwsze utworzenie globalnej gildii moze wejsc z trzech rownorzednych pathow:
  - formularz `RedDAXE` `/reddaxe/guild-found.php`,
  - flow WWW `/community/guilds/found`,
  - bezposredni flow serwerowy,
  a wszystkie te pathy musza rezerwowac nazwe w tym samym registry.

Na `RedDaxe.pl` nie planujemy:

- publicznych topek globalnych,
- publicznych list gildii,
- pelnych publicznych profili gildii pod SEO / katalog.

Jesli panel ma pokazywac dane z serwerow, to tylko przez backend:

- backend globalny pobiera lub cache'uje dane z serwerow,
- frontend strony nie laczy sie bezposrednio z bazami serwerow.

## 8.3 WWW Tibia

`WWW Tibia` tez musi byc przygotowane pod ten system jako publiczna strona gry.

`WWW Tibia` ma byc publiczna strona gry dla danych dotyczacych Tibii.

Minimalny zakres:

- widok globalnych topek,
- widok globalnej gildii,
- widok topki gildii,
- wyszukiwarka gildii / gracza,
- CTA do launchera i stron konta,
- spojne komunikaty bledow i pustych stanow.

Rozszerzony zakres docelowy:

- widok `all worlds` dla gildii Tibii,
- glowne zarzadzanie gildia dla Tibii,
- laczenie danych globalnych z lokalnym systemem gildii Canary po stronie backendu WWW.

`WWW Tibia` nie zastępuje `RedDaxe.pl` jako panelu zarzadzania.

Podzial:

- `WWW Tibia` = publiczny katalog, publiczne widoki i glowne zarzadzanie gildia dla Tibii,
- `RedDaxe.pl` = listy czlonkow, instancje gildii i tylko minimalne zarzadzanie.

## 8.4 Inne strony per-gra

Ten sam model ma obowiazywac dla innych gier.

To znaczy:

- kazda gra moze miec swoja strone z pelnymi topkami i widokami gildii,
- publiczne dane maja byc filtrowane po `game_id`, `server_id`, `ruleset` lub `family`,
- backend globalny dostarcza wspolne API, ale frontend gry pokazuje tylko dane relewantne dla tej gry.

## 8.5 Podzial odpowiedzialnosci frontow

Podzial docelowy:

- `RedDaxe.pl`:
  - panel zarzadzania gildia
  - lista czlonkow gildii z podzialem na serwery
  - operacje ownership / attach / administracja
- `WWW Tibia`:
  - publiczne topki
  - publiczne gildie
  - topki gildii
  - profile graczy / gildii dla gry Tibia
- inne strony per-gra:
  - analogiczny publiczny zakres dla danej gry

Do decyzji produktowej:

- czy `WWW Tibia` ma byc portalem marketingowo-katalogowym,
- a `RedDaxe.pl` panelem kontowym i zarzadczym.

## 8.6 Wspolny standard i18n i copy

Dla launchera, `WWW Tibia`, stron per-gra i `RedDaxe.pl` trzeba utrzymac jeden standard:

- wszystkie nowe widoki objete `i18n`,
- wspolne nazwy kategorii i filtrow,
- wspolne nazwy statusow gildii i rankingow,
- wspolna polityka fallbacku jezykowego,
- testy na brak mixed strings.

## 9. Edge cases i decyzje do podjecia

## 9.1 Gildia usunieta lokalnie

Do decyzji:

- czy `global guild` zostaje aktywna bez instancji lokalnych,
- czy trafia do `archived`,
- czy nazwa kiedys moze byc uwolniona.

Rekomendacja:

- nie uwalniac nazw automatycznie w v1.

## 9.2 Rename gildii

To jest trudny przypadek, bo rename dotyka globalnej rezerwacji.

Rekomendacja v1:

- zablokowac globalny rename,
- pozwolic tylko na reczne operacje administracyjne.

Stan na `2026-03-08`:

- adminowy `rename` jest juz zablokowany w runtime i w panelu admina,
- pelny kontrolowany `rename + migracja registry` zostaje poza zakresem P0.

## 9.3 Merge / split kont

Jesli konto globalne zmieni wlasciciela albo polaczymy konta, topki globalne moga sie zmienic.

Rekomendacja:

- nie wspierac merge kont w v1,
- trzymac prosty, stabilny model `global_account_id`.

## 9.4 Race condition przy zakladaniu gildii

Jesli dwa serwery probuja w tym samym momencie zalozyc gildie o tej samej nazwie, musimy miec jasna odpowiedz:

- wygrywa pierwszy commit w backendzie globalnym,
- drugi dostaje konflikt,
- serwer lokalny pokazuje i18n komunikat o zajetej nazwie.

## 9.5 Migracja i backfill danych historycznych

Plan bez migracji bylby niepelny.

Do zaplanowania:

- jak zaczytac istniejace gildie do `global guild registry`,
- czy pierwsza migracja ma rezerwowac wszystkie obecne nazwy,
- od jakiej daty liczymy topki globalne,
- czy historyczne statystyki beda backfillowane, czy startujemy "od teraz".

Rekomendacja v1:

- gildie migrowac od razu,
- topki globalne uruchomic najpierw od nowego punktu startowego, a backfill historii traktowac jako opcje.

## 9.6 Oszustwa i duplikaty ingestu

Potrzebujemy:

- idempotentnych importow,
- sygnatur requestow,
- znacznikow czasu,
- wersjonowania schematu danych,
- mozliwosci przeliczenia agregatow od nowa.

## 9.7 Moderacja i spory

Przy globalnych gildiach i topkach beda potrzebne narzedzia administracyjne:

- reczne zablokowanie nazwy gildii,
- reczne rozwiazanie sporu ownership,
- wykluczenie serwera z topki globalnej,
- wykluczenie konta lub gildii z rankingu,
- reczne przeliczenie agregatow po naprawie danych.

Bez tego system bedzie poprawny technicznie, ale slaby operacyjnie.

## 10. Kolejnosc wdrozenia

### Faza 0 - decyzje kontraktowe

- zdefiniowac `global_account_id`,
- zdefiniowac `server_id` i `game_id`,
- zdefiniowac normalizacje nazw gildii,
- zdefiniowac pierwsze metryki globalne.

### Faza 1 - global guild registry

- dodac globalna tabele rezerwacji nazw gildii,
- dodac endpoint reserve / attach,
- spiac tworzenie gildii na serwerze z walidacja globalna,
- dodac widok listy instancji gildii per serwer.

### Faza 2 - global leaderboards v1

- dodac eksport snapshotow z serwerow,
- dodac proste agregaty globalne,
- pokazac globalne topki na `WWW Tibia` i innych stronach per-gra,
- pokazac podstawowe topki w launcherze.

### Faza 3 - enrichment i porownania

- dodac profile gracza i gildii,
- dodac grupowanie po rulesetach,
- dodac sezonowosc,
- dodac cache i bardziej zaawansowane rankingi,
- domknac i18n i finalne UX dla wszystkich frontow.

## 11. Rekomendacja wykonawcza

Najpierw zrobic `global guild registry`, bo:

- ma prostszy model danych,
- od razu daje wartosc produktowa,
- porzadkuje tozsamosc i namespace,
- przygotowuje fundament pod globalne topki.

Dopiero potem robic `global leaderboards`, bo one wymagaja:

- stabilnej tozsamosci gracza,
- kanalow synchronizacji,
- sensownego modelu metryk,
- rozstrzygniecia problemu porownywalnosci miedzy serwerami.
