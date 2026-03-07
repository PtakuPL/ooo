# Master Backlog Caly System

**Data:** 2026-03-06  
**Cel:** doprowadzic caly ekosystem do stanu produkcyjnego: serwer, launcher, instalka, paczka gracza, konto globalne, RedDAXE, WWW Tibia, baza danych i API.  
**Zasada nadrzedna:** nie plan szybkiego domkniecia, tylko backlog na profesjonalny rollout.

## 1. Definicja produktu koncowego

System jest gotowy dopiero wtedy, gdy jednoczesnie sa spelnione ponizsze warunki:

1. Gracz zaklada jedno konto globalne i uzywa go w launcherze, RedDAXE i WWW bez rozjazdu danych.
2. Dwa serwery dzialaja jako dwa swiaty jednego ekosystemu: Classic 7.4 i Modern.
3. Launcher jest glownym punktem wejscia: logowanie, aktualizacje, integralnosc, start klienta, przejscie do WWW.
4. Instalka jest bootstrapem, a nie drugim launcherem.
5. API jest jednym kontraktem dla launchera, WWW i klienta.
6. Ticket-gate i HMAC sa twarda bariera bezpieczenstwa, a nie tylko dodatkiem UX.
7. Paczka gracza jest czysta, powtarzalna i gotowa do publikacji bez plikow developerskich.
8. WWW i RedDAXE maja spojne flow konta, postaci, pobran i komunikatow.
9. Baza danych ma jasno zdefiniowane zrodlo prawdy, migracje i procedury cleanup/rollback.
10. Projekt ma gate'y release, monitoring, runbooki supportowe i procedury hotfix.

## 2. Architektura docelowa

### Zrodlo prawdy

1. `canaryaac.accounts` jest masterem dla tozsamosci i konta globalnego.
2. `canary.accounts` i `canary_modern.accounts` sa projection/sync target dla engine.
3. Postacie pozostaja per serwer, ale konto jest jedno.

### Wejscia do systemu

1. Launcher Rust/Tauri: podstawowe wejscie gracza.
2. RedDAXE: portal marketingowo-logistyczny, download center, konto i CTA.
3. WWW Tibia/MyAAC: account management, tworzenie postaci, highscores, panel gracza.

### Warstwy techniczne

1. API HTTP: wspolne kontrakty login, account-context, launcher-version, manifest, ticket, sync token.
2. Canary/OTClient: logika gry i walidacja ticket-gate.
3. SQL: konta, sesje, nonce, manifest versions, synchronizacja i cleanup.
4. Paczki artefaktow: launcher, client package, manifest, podpisy, release metadata.

## 3. Najwazniejsze luki wykryte na teraz

1. Istnieje kilka warstw loginu i API, ale wymagaja scalenia do jednego oficjalnego kontraktu.
2. RedDAXE, WWW i launcher sa juz obecne, ale musza uzywac tego samego flow konta globalnego.
3. Jest plan konta globalnego, plan launchera i plan instalki, ale brakuje jednego backlogu nadrzednego z zaleznosciami miedzy nimi.
4. Ticket-gate ma migracje SQL, ale jego gotowosc produkcyjna zalezy od end-to-end flow launcher -> API -> klient -> serwer.
5. Istnieja dwa swiaty i `world_id`, ale wymagaja konsekwentnego przeprowadzenia przez UI, API i baze.
6. WWW/API maja cechy prototypu i debugowania, wiec potrzebuja hardeningu produkcyjnego.
7. Brakuje jednego gate'u systemowego obejmujacego calosc, nie tylko instalke albo launcher osobno.

## 4. Kolejnosc strategiczna

Prace powinny isc w tej kolejnosci, bo kazdy kolejny blok zalezy od poprzedniego:

1. Ustalenie jednego modelu danych i kontraktow API.
2. Domkniecie konta globalnego i synchronizacji kont do obu serwerow.
3. Domkniecie flow postaci per serwer i `world_id`.
4. Domkniecie launcher login/context/create-character/play.
5. Domkniecie WWW i RedDAXE pod ten sam system konta.
6. Domkniecie packagingu gracza i bootstrap instalki.
7. Hardening bezpieczenstwa i operacji.
8. Test matrix i gate publikacyjny.

## 5. Backlog glowny

### TRACK A. Fundament architektury i kontraktow

**P0**

1. `SYS-A01`: spisac i zamrozic oficjalne kontrakty API dla: `login.php`, `launcher-version.php`, `update.php`, `launcher-token.php`, `ticket.php`, `account-context.php`, `account-sync-token.php`, `account-sync-consume.php`.
2. `SYS-A02`: zdefiniowac jedno zrodlo prawdy dla sesji, konta, listy swiatow, listy postaci i statusu launchera.
3. `SYS-A03`: ustalic finalne nazewnictwo trybow `classic74`, `modern`, `all` i przeniesc je konsekwentnie przez DB, API, launcher i WWW.
4. `SYS-A04`: ustalic finalna odpowiedzialnosc komponentow: co robi instalka, co robi launcher, co robi klient, czego nie robi RedDAXE.
5. `SYS-A05`: przygotowac `system contract matrix` z mapowaniem endpoint -> consumer -> payload -> auth -> expected errors.

**P1**

6. `SYS-A06`: przygotowac versioning API i polityke kompatybilnosci wstecznej.
7. `SYS-A07`: przygotowac schemat kodow bledow wspolny dla API, launchera i supportu.
8. `SYS-A08`: przygotowac ADR-y dla kluczowych decyzji: konto globalne, installer bootstrap, ticket-gate, dwa serwery.

### TRACK B. Konto globalne i tozsamosc

**P0**

1. `SYS-B01`: potwierdzic, ze rejestracja z launchera, RedDAXE i WWW zapisuje to samo konto globalne.
2. `SYS-B02`: zapewnic zapis `engine_password_sha1` i kompatybilnosc z engine przy zachowaniu glównego haszowania konta globalnego.
3. `SYS-B03`: wdrozyc i potwierdzic dwukierunkowy flow SSO: launcher -> WWW oraz WWW/RedDAXE -> launcher.
4. `SYS-B04`: przygotowac polityke sesji: TTL, refresh, revoke, single-use tokeny, konflikt sesji, logout globalny.
5. `SYS-B05`: rozdzielic wyraznie konto globalne od postaci serwerowych w UI i komunikatach.

**P1**

6. `SYS-B06`: dodac audit trail zdarzen konta: rejestracja, login, create-character, switch mode, token issue, token consume.
7. `SYS-B07`: dodac recovery flow: reset hasla, verify email, lockout, suspicious login.
8. `SYS-B08`: przygotowac backlog 2FA i social login tak, by nie rozwalil podstawowego modelu konta.

### TRACK C. Serwery i model dwoch swiatow

**P0**

1. `SYS-C01`: potwierdzic i udokumentowac mapowanie `world_id` na Classic 7.4 i Modern.
2. `SYS-C02`: zagwarantowac, ze tworzenie postaci zawsze wymaga jawnego wyboru serwera albo swiadomego preselectu z `mode`.
3. `SYS-C03`: dopilnowac, by login/context/ticket zwracaly dane odfiltrowane per wybrany swiat.
4. `SYS-C04`: przygotowac blokady funkcji 7.4 po stronie serwera, klienta i instalki jako osobny kontrolowany zestaw feature flags, nie jako przypadkowe if-y.
5. `SYS-C05`: zdefiniowac zestaw roznic Classic vs Modern: hotkeys, runy, mechaniki, UI, pliki klienta, walidacje po stronie serwera.

**P1**

6. `SYS-C06`: przygotowac centralny registry feature flags dla obu swiatow.
7. `SYS-C07`: dopisac testy regresji dla ograniczen 7.4 i dla braku ich wycieku do Modern.
8. `SYS-C08`: przygotowac checklisty content parity vs intentional divergence miedzy swiatami.

### TRACK D. Launcher Rust/Tauri

**P0**

1. `SYS-D01`: domknac flow `login -> account-context -> wybor serwera -> wybor postaci -> play`.
2. `SYS-D02`: domknac flow `brak postaci -> create-character w WWW -> powrot -> refresh context`.
3. `SYS-D03`: zablokowac start gry bez waznej sesji, bez postaci i bez zgodnosci wersji launchera/manifestu.
4. `SYS-D04`: potwierdzic self-update z helperem i jasnym restartem launchera.
5. `SYS-D05`: doprowadzic do parytetu funkcjonalnego wzgledem obecnego launchera Python tam, gdzie to wymagane.
6. `SYS-D06`: wdrozyc bezpieczne przechowywanie lokalnego stanu sesji bez trzymania hasla plain text.

**P1**

7. `SYS-D07`: dopracowac UI serwerow i postaci, z jasnym stanem ONLINE/OFFLINE/BRAK POSTACI.
8. `SYS-D08`: dopracowac i18n launchera oraz mikrocopy dla bledow i flow create-character.
9. `SYS-D09`: dopracowac repair mode, diagnostics pack i telemetry bez wycieku sekretow.
10. `SYS-D10`: przygotowac rollout channels `dev/stage/stable` i polityke forced upgrade.

### TRACK E. Instalka i paczka gracza

**P0**

1. `SYS-E01`: utrzymac instalke jako bootstrapper instalujacy launcher i minimalny config.
2. `SYS-E02`: przygotowac allowlist/denylist paczki gracza, bez plikow dev/test/debug/sekretow.
3. `SYS-E03`: przygotowac first-run bootstrap klienta z walidacja manifestu, podpisu i checksum.
4. `SYS-E04`: przygotowac atomowe update, rollback i auto-repair klienta.
5. `SYS-E05`: zapewnic, ze paczka gracza nie wymaga recznej konfiguracji do wejscia do gry.

**P1**

6. `SYS-E06`: dopracowac onboarding nowego gracza: konto globalne, wybor serwera, postac, start.
7. `SYS-E07`: dodac package lint, security package scan i diff dev -> gracz.
8. `SYS-E08`: przygotowac uninstall, support bundle i top problems runbook.

### TRACK F. WWW Tibia i RedDAXE

**P0**

1. `SYS-F01`: wymusic, aby RedDAXE i WWW korzystaly z tych samych endpointow rejestracji i logowania.
2. `SYS-F02`: ujednolicic flow pobierania launchera i CTA po rejestracji/logowaniu.
3. `SYS-F03`: wdrozyc account pages pokazujace postacie per serwer z jasnym przejciem do create-character.
4. `SYS-F04`: wdrozyc sync-login z jednorazowym tokenem z launchera do WWW.
5. `SYS-F05`: odswiezanie `account-context` po utworzeniu postaci ma byc przewidywalne i bez restartu launchera.

**P1**

6. `SYS-F06`: uporzadkowac copy i UX dla nowego gracza, powracajacego gracza i gracza bez postaci.
7. `SYS-F07`: dopracowac download center, release notes, FAQ i komunikaty o dwoch serwerach.
8. `SYS-F08`: przygotowac spojnosc wizualna i informacyjna miedzy RedDAXE i WWW.

### TRACK G. API i bezpieczenstwo

**P0**

1. `SYS-G01`: utwardzic `login.php`, `ticket.php`, `launcher-token.php` i `account-sync-*` pod walidacje danych, TTL, single-use i replay protection.
2. `SYS-G02`: potwierdzic produkcyjne dzialanie tabel `launch_tokens`, `manifest_versions`, `ticket_sessions`, `ticket_nonces`.
3. `SYS-G03`: dopiac cleanup wygaslych rekordow i procedury operacyjne dla awarii cleanup.
4. `SYS-G04`: wdrozyc rate limiting, structured logging i redakcje sekretow w logach API.
5. `SYS-G05`: dopracowac podpisy manifestow, weryfikacje artefaktow i blokade startu przy mismatch.
6. `SYS-G06`: zapewnic HTTPS everywhere i zakaz fallbacku na niezabezpieczone endpointy produkcyjne.

**P1**

7. `SYS-G07`: przygotowac rotacje kluczy/HMAC i grace period dla wersji launchera.
8. `SYS-G08`: dodac audyt bezpieczenstwa endpointow publicznych i polityke odpowiedzi na naduzycia.
9. `SYS-G09`: przygotowac minimalny threat model dla launchera, klienta, API i WWW.

### TRACK H. Baza danych i migracje

**P0**

1. `SYS-H01`: opisac i wdrozyc finalny schemat zaleznosci baz: konto globalne, konta engine, postacie, sesje, tokeny, nonce.
2. `SYS-H02`: przygotowac migracje idempotentne dla wszystkich krytycznych tabel i kolumn.
3. `SYS-H03`: przygotowac test danych po migracji: stare konta, stare postacie, brak `world_id`, konflikt ID, null-e.
4. `SYS-H04`: przygotowac plan rollbacku migracji dla P0 zmian danych.

**P1**

5. `SYS-H05`: przygotowac narzedzia diagnostyczne SQL dla supportu i operacji.
6. `SYS-H06`: przygotowac retencje danych technicznych i polityke cleanup dla tabel sesyjnych.

### TRACK I. DevOps, release i operacje

**P0**

1. `SYS-I01`: przygotowac jeden master gate systemowy przed kompilacja i publikacja.
2. `SYS-I02`: przygotowac wersjonowanie release artefaktow: launcher, paczka gracza, manifest, signature, DB migration set.
3. `SYS-I03`: przygotowac checkliste `go/no-go` obejmujaca serwer, API, launcher, WWW, baze i paczke gracza.
4. `SYS-I04`: przygotowac monitoring po publikacji: login failures, update failures, ticket failures, create-character failures.
5. `SYS-I05`: przygotowac hotfix i rollback runbook dla artefaktow i dla migracji danych.

**P1**

6. `SYS-I06`: przygotowac dziennik releasow i status page dla zespolu.
7. `SYS-I07`: przygotowac alarmy i ownership dla P0/P1 incydentow.
8. `SYS-I08`: przygotowac raport dzienny 24h po wydaniu.

### TRACK J. QA, support i akceptacja

**P0**

1. `SYS-J01`: zbudowac test matrix end-to-end dla flow nowego gracza i gracza wracajacego.
2. `SYS-J02`: potwierdzic scenariusze na Windows 10, Windows 11, no-admin, polskie znaki, spacje w sciezce.
3. `SYS-J03`: potwierdzic scenariusze `brak postaci`, `expired token`, `manifest mismatch`, `przerwany update`, `pelny dysk`, `brak uprawnien`.
4. `SYS-J04`: potwierdzic scenariusz `konto z RedDAXE -> launcher`, `konto z WWW -> launcher`, `launcher -> WWW -> create-character -> launcher`.
5. `SYS-J05`: potwierdzic scenariusz `play` na obu serwerach w jednym modelu konta globalnego.

**P1**

6. `SYS-J06`: przygotowac tablice `kod bledu -> akcja gracza -> akcja supportu`.
7. `SYS-J07`: przygotowac support FAQ i gotowe komunikaty dla najczestszych problemow.
8. `SYS-J08`: przygotowac plan regresji po kazdym releasie krytycznym.

## 6. Gate systemowy

Nie wolno uznac systemu za gotowy, dopoki wszystkie ponizsze gate'y nie maja PASS:

1. `G-SYS-01`: jedno konto globalne dziala z launcherem, RedDAXE i WWW.
2. `G-SYS-02`: gracz moze zalozyc konto w dowolnym froncie i zalogowac sie w dowolnym innym.
3. `G-SYS-03`: create-character dziala dla Classic i Modern bez rozjazdu danych.
4. `G-SYS-04`: launcher poprawnie blokuje start bez postaci, bez sesji, bez zgodnosci wersji.
5. `G-SYS-05`: ticket-gate PASS end-to-end na obu serwerach.
6. `G-SYS-06`: paczka gracza jest czysta i przechodzi package lint/security scan.
7. `G-SYS-07`: update, rollback i repair PASS.
8. `G-SYS-08`: WWW i RedDAXE maja spojne CTA, copy i flow dla nowego gracza.
9. `G-SYS-09`: monitoring, runbook i hotfix procedure sa gotowe.
10. `G-SYS-10`: dokumentacja stanu systemu jest aktualna.

## 7. Recommended execution waves

### Wave 1. Kontrakty i konto globalne

1. `SYS-A01..A05`
2. `SYS-B01..B05`
3. `SYS-H01..H04`

### Wave 2. Dwa swiaty i API

1. `SYS-C01..C05`
2. `SYS-G01..G06`

### Wave 3. Launcher flow

1. `SYS-D01..D06`
2. `SYS-F04..F05`

### Wave 4. WWW, RedDAXE i UX

1. `SYS-F01..F08`
2. `SYS-B06..B08`

### Wave 5. Paczka gracza i release

1. `SYS-E01..E08`
2. `SYS-I01..I08`
3. `SYS-J01..J08`

## 8. Zasady realizacji

1. Najpierw kontrakt i dane, potem kod kliencki.
2. Nie duplikowac logiki konta miedzy launcherem, RedDAXE i WWW.
3. Nie robic z instalki drugiego launchera.
4. Nie przenosic twardego security z API/Canary do launchera.
5. Wszystkie P0 musza miec dowod PASS albo jawny BLOCKED z obejściem.
6. Kazda zmiana P0 musi zostawic wpis w dokumentacji i stan gate.

## 9. Definition of Done dla calego systemu

System jest profesjonalnie gotowy, gdy:

1. nowy gracz przechodzi od pobrania do wejscia do gry bez recznej konfiguracji,
2. stare konto i stare postacie nie zostaja zgubione po migracjach,
3. dwa serwery sa obslugiwane jako jeden ekosystem i nie mieszaja danych,
4. launcher, WWW i RedDAXE sa tylko roznymi wejsciami do tego samego konta globalnego,
5. release mozna powtorzyc kontrolowanie i z rollbackiem,
6. support ma narzedzia do diagnozy, a nie zgadywania,
7. po publikacji da sie monitorowac zdrowie systemu operacyjnie, nie tylko recznie.