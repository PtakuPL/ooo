# Master Backlog Caly System

**Data:** 2026-03-06  
**Cel:** doprowadzic caly ekosystem do stanu produkcyjnego: serwer, launcher, instalka, paczka gracza, konto globalne, RedDAXE, WWW Tibia, baza danych i API.  
**Zasada nadrzedna:** nie plan szybkiego domkniecia, tylko backlog na profesjonalny rollout.

## 0. Sprostowania i definicje krytyczne

Ten dokument musi byc czytany zgodnie z ponizszymi zalozeniami, bo od nich zalezy caly plan:

1. Istnieja dwa warianty instalki: instalka dev i instalka klienta.
2. Instalka dev jest powiazana z folderem `canary_test/testyy` i jest budowana przez workflow na GitHub Actions.
3. Instalka klienta jest artefaktem dla gracza i jest dystrybuowana przez launcher z zasobow wystawionych przez API.
4. Launcher moze pobierac takze instalke dev, jesli zostanie ona celowo opublikowana w katalogu API na WSL.
5. Instalka nie jest tylko prostym downloaderem. To chroniony artefakt klienta/dev, ktory musi przejsc walidacje bezpieczenstwa, integralnosci i dostepu do internetu.
6. Chroniona instalka nie powinna dzialac poprawnie, jesli nie ma dostepu do internetu albo jesli wykryto modyfikacje plikow, integralnosci lub konfiguracji.
7. Tryb `7.4` i `modern` musi byc wybierany przed polaczeniem i przed wyborem postaci, a potem twardo egzekwowany przez launcher, instalke, klienta i API.
8. Jesli wybrano tryb `7.4`, nie wolno laczyc sie z `modern`; jesli wybrano `modern`, nie wolno laczyc sie z `7.4`.
9. Lista serwerow nie moze byc dodawana ani edytowana lokalnie przez gracza. Serwery sa publikowane i sterowane tylko zdalnie przez API.
10. Konto globalne to nie to samo co konto techniczne serwera. Konto globalne daje jedna tozsamosc i jedno logowanie, ale dla kazdej gry/serwera musza istniec osobne konta techniczne, profile i postacie.
11. Postac nigdy nie jest wspoldzielona miedzy `7.4` i `modern`, a system przenoszenia postaci nie wchodzi w zakres tego modelu.
12. Konto globalne ma dzialac nie tylko dla launchera, RedDAXE i WWW Tibia, ale takze dla kolejnych stron WWW, for i przyszlych gier podpietych do tego ekosystemu.
13. Na ten moment zmiany w plikach serwerowych Canary sa utrzymywane wspolnie, wiec plan zaklada jeden tor zmian serwera i jeden proces kompilacji serwera, dopoki nie pojawi sie realna potrzeba rozdzielenia.
14. WWW Tibia i powiazane strony maja byc konsekwentnie prowadzone w systemie i18n, a nie jako osobne, recznie tlumaczone wyjatki.

## 1. Definicja produktu koncowego

System jest gotowy dopiero wtedy, gdy jednoczesnie sa spelnione ponizsze warunki:

1. Gracz zaklada jedno konto globalne w launcherze, WWW Tibia, RedDAXE albo innej podpietej stronie i uzywa tej samej tozsamosci wszedzie bez rozjazdu danych logowania.
2. Konto globalne automatycznie lub kontrolowanie provisionuje osobne konta techniczne dla poszczegolnych serwerow/gier, bez wymuszania nowych hasel dla gracza.
3. Dwa serwery dzialaja jako dwa odrebne swiaty jednego ekosystemu: Classic 7.4 i Modern, ale nie wspoldziela postaci.
4. Launcher jest glownym punktem wejscia: logowanie, aktualizacje, integralnosc, start klienta, przejscie do WWW i pobieranie artefaktow instalki z API.
5. Instalka wystepuje w wariancie dev i klient, jest budowana/publikowana kontrolowanie i ma aktywne zabezpieczenia integralnosci oraz wymagania online.
6. Tryb `7.4` albo `modern` jest wybierany przed polaczeniem i twardo blokuje laczenie z niewlasciwym serwerem.
7. Lista serwerow jest dostarczana tylko z API i gracz nie moze lokalnie dopisywac ani podmieniac serwerow.
8. API jest jednym kontraktem dla launchera, instalki, WWW i klienta.
9. Ticket-gate i HMAC sa twarda bariera bezpieczenstwa, a nie tylko dodatkiem UX.
10. Paczka gracza i artefakty instalki sa czyste, powtarzalne i gotowe do publikacji bez plikow developerskich, debugowych i sekretow.
11. WWW Tibia, RedDAXE i kolejne strony maja spojne flow konta, postaci, pobran, komunikatow i i18n.
12. Baza danych ma jasno zdefiniowane zrodlo prawdy, migracje i procedury cleanup/rollback.
13. Projekt ma gate'y release, monitoring, runbooki supportowe i procedury hotfix.

## 2. Architektura docelowa

### Zrodlo prawdy

1. `canaryaac.accounts` jest masterem dla globalnej tozsamosci, globalnego logowania i autoryzacji wspolnej dla launchera, WWW i przyszlych stron.
2. `canary.accounts` i `canary_modern.accounts` sa osobnymi kontami technicznymi/projekcjami dla engine i nie oznaczaja wspoldzielonej postaci.
3. Postacie, profile gry i dane engine pozostaja odrebne per serwer/gra, nawet jesli sa podpiete do jednego konta globalnego.
4. Model docelowy to: jedno konto globalne, wiele kont technicznych/serwerowych, zero wspoldzielenia postaci miedzy swiatami.

### Wejscia do systemu

1. Launcher Rust/Tauri: podstawowe wejscie gracza.
2. RedDAXE: portal marketingowo-logistyczny, download center, konto i CTA.
3. WWW Tibia/MyAAC: account management, tworzenie postaci, highscores, panel gracza.
4. Kolejne strony WWW, fora i nowe gry: maja korzystac z tego samego konta globalnego i wspolnego modelu autoryzacji.

### Warstwy techniczne

1. API HTTP: wspolne kontrakty login, register, account-context, launcher-version, manifest, ticket, sync token, katalog serwerow i katalog artefaktow instalki.
2. Canary/OTClient/Instalka: logika gry, blokady trybu, walidacja ticket-gate, walidacja integralnosci i walidacja online.
3. SQL: konta globalne, konta techniczne serwerow, sesje, nonce, manifest versions, synchronizacja i cleanup.
4. Paczki artefaktow: launcher, instalka klienta, instalka dev, client package, manifest, podpisy, release metadata.
5. I18n: launcher, instalka, WWW Tibia, RedDAXE i kolejne strony nie sa wyjatkami, tylko czescia jednego systemu.
6. Remote config: lista serwerow i dostepne artefakty sa sterowane zdalnie przez API, a nie lokalnym plikiem edytowanym przez gracza.

## 3. Najwazniejsze luki wykryte na teraz

1. Istnieje kilka warstw loginu i API, ale wymagaja scalenia do jednego oficjalnego kontraktu.
2. RedDAXE, WWW i launcher sa juz obecne, ale musza uzywac tego samego flow konta globalnego.
3. Jest plan konta globalnego, plan launchera i plan instalki, ale brakuje jednego backlogu nadrzednego z zaleznosciami miedzy nimi.
4. Ticket-gate ma migracje SQL, ale jego gotowosc produkcyjna zalezy od end-to-end flow launcher -> API -> klient -> serwer.
5. Istnieja dwa swiaty i `world_id`, ale wymagaja konsekwentnego przeprowadzenia przez UI, API i baze.
6. Nie bylo dosc jasno wpisane, ze konto globalne nie znosi potrzeby posiadania osobnych kont technicznych per serwer/gra.
7. Nie bylo dosc jasno wpisane, ze instalka dev/klient jest artefaktem chronionym, wymagajacym internetu i kontroli integralnosci.
8. Nie bylo dosc jasno wpisane, ze tryb 7.4/modern ma byc wybierany i blokowany jeszcze przed wyborem postaci i polaczeniem.
9. Nie bylo dosc jasno wpisane, ze gracz nie moze lokalnie dodawac serwerow, bo katalog serwerow ma byc tylko z API.
10. WWW/API maja cechy prototypu i debugowania, wiec potrzebuja hardeningu produkcyjnego.
11. Brakuje jednego gate'u systemowego obejmujacego calosc, nie tylko instalke albo launcher osobno.
12. Plan za slabo eksponowal obowiazek i18n dla calego WWW Tibia i stron powiazanych.

## 4. Kolejnosc strategiczna

Prace powinny isc w tej kolejnosci, bo kazdy kolejny blok zalezy od poprzedniego:

1. Ustalenie jednego modelu danych i kontraktow API.
2. Domkniecie konta globalnego oraz provisioningu osobnych kont technicznych do obu serwerow.
3. Domkniecie flow postaci per serwer, `world_id` i wyboru trybu przed polaczeniem.
4. Domkniecie zdalnego katalogu serwerow oraz artefaktow instalki przez API.
5. Domkniecie launcher login/context/create-character/play.
6. Domkniecie WWW i RedDAXE pod ten sam system konta oraz i18n.
7. Domkniecie packagingu gracza oraz obu wariantow instalki.
8. Hardening bezpieczenstwa i operacji.
9. Test matrix i gate publikacyjny.

## 5. Backlog glowny

### TRACK A. Fundament architektury i kontraktow

**P0**

1. `SYS-A01`: spisac i zamrozic oficjalne kontrakty API dla: `register-account.php`, `login.php`, `launcher-version.php`, `update.php`, `launcher-token.php`, `ticket.php`, `account-context.php`, `account-sync-token.php`, `account-sync-consume.php`, katalogu serwerow i katalogu artefaktow instalki.
2. `SYS-A02`: zdefiniowac jedno zrodlo prawdy dla globalnej tozsamosci, sesji, kont technicznych serwerow, listy swiatow, listy postaci i statusu launchera/instalki.
3. `SYS-A03`: ustalic finalne nazewnictwo trybow `classic74`, `modern`, `all` i przeniesc je konsekwentnie przez DB, API, launcher i WWW.
4. `SYS-A04`: ustalic finalna odpowiedzialnosc komponentow: co robi instalka dev, co robi instalka klienta, co robi launcher, co robi klient, czego nie robi RedDAXE i czego nie wolno robic lokalnie graczowi.
5. `SYS-A05`: przygotowac `system contract matrix` z mapowaniem endpoint -> consumer -> payload -> auth -> expected errors -> mode gating -> online requirement.

**P1**

6. `SYS-A06`: przygotowac versioning API i polityke kompatybilnosci wstecznej.
7. `SYS-A07`: przygotowac schemat kodow bledow wspolny dla API, launchera i supportu.
8. `SYS-A08`: przygotowac ADR-y dla kluczowych decyzji: konto globalne, model instalek dev/klient, ticket-gate, dwa serwery, zdalny katalog serwerow.

### TRACK B. Konto globalne i tozsamosc

**P0**

1. `SYS-B01`: potwierdzic, ze rejestracja z launchera, RedDAXE, WWW Tibia i kolejnych podpietych stron zapisuje to samo konto globalne.
2. `SYS-B02`: zapewnic provisionowanie osobnych kont technicznych dla engine przy zachowaniu jednego hasla/tozsamosci globalnej, w tym zapis `engine_password_sha1` lub rownowaznego mechanizmu kompatybilnego z engine.
3. `SYS-B03`: wdrozyc i potwierdzic dwukierunkowy flow SSO: launcher -> WWW oraz WWW/RedDAXE -> launcher.
4. `SYS-B04`: przygotowac polityke sesji: TTL, refresh, revoke, single-use tokeny, konflikt sesji, logout globalny.
5. `SYS-B05`: rozdzielic wyraznie w modelu danych, UI i komunikatach: konto globalne, konto techniczne serwera oraz postac serwerowa.

**P1**

6. `SYS-B06`: dodac audit trail zdarzen konta: rejestracja, login, create-character, switch mode, token issue, token consume.
7. `SYS-B07`: dodac recovery flow: reset hasla, verify email, lockout, suspicious login.
8. `SYS-B08`: przygotowac backlog 2FA i social login tak, by nie rozwalil podstawowego modelu konta.

### TRACK C. Serwery i model dwoch swiatow

**P0**

1. `SYS-C01`: potwierdzic i udokumentowac mapowanie `world_id` na Classic 7.4 i Modern oraz finalne mapowanie `mode` przed polaczeniem.
2. `SYS-C02`: zagwarantowac, ze wybor trybu/serwera nastepuje przed polaczeniem i przed wyborem postaci, a tworzenie postaci zawsze wymaga jawnego wyboru serwera albo swiadomego preselectu z `mode`.
3. `SYS-C03`: dopilnowac, by login/context/ticket/instalka zwracaly i egzekwowaly dane odfiltrowane per wybrany swiat.
4. `SYS-C04`: przygotowac blokady funkcji 7.4 po stronie serwera, klienta i instalki jako osobny kontrolowany zestaw feature flags, nie jako przypadkowe if-y.
5. `SYS-C05`: zdefiniowac zestaw roznic Classic vs Modern: hotkeys, runy, mechaniki, UI, pliki klienta, walidacje po stronie serwera oraz blokade laczenia z niewlasciwym serwerem.

**P1**

6. `SYS-C06`: przygotowac centralny registry feature flags dla obu swiatow.
7. `SYS-C07`: dopisac testy regresji dla ograniczen 7.4 i dla braku ich wycieku do Modern.
8. `SYS-C08`: przygotowac checklisty content parity vs intentional divergence miedzy swiatami.
9. `SYS-C09`: utrzymac na obecnym etapie jeden tor zmian plikow serwerowych Canary i jeden proces kompilacji serwera, z roznicami wynikajacymi z `mode` i feature flags.

### TRACK D. Launcher Rust/Tauri

**P0**

1. `SYS-D01`: domknac flow `login -> account-context -> wybor serwera -> wybor postaci -> play`.
2. `SYS-D02`: domknac flow `brak postaci -> create-character w WWW -> powrot -> refresh context`.
3. `SYS-D03`: zablokowac start gry bez waznej sesji, bez postaci, bez zgodnosci wersji launchera/manifestu i bez zgodnosci wybranego trybu z docelowym serwerem.
4. `SYS-D04`: potwierdzic self-update z helperem i jasnym restartem launchera oraz obsluge pobierania artefaktow instalki z API.
5. `SYS-D05`: doprowadzic do parytetu funkcjonalnego wzgledem obecnego launchera Python tam, gdzie to wymagane.
6. `SYS-D06`: wdrozyc bezpieczne przechowywanie lokalnego stanu sesji bez trzymania hasla plain text.

**P1**

7. `SYS-D07`: dopracowac UI serwerow i postaci, z jasnym stanem ONLINE/OFFLINE/BRAK POSTACI oraz zdalnym katalogiem serwerow tylko z API.
8. `SYS-D08`: dopracowac i18n launchera oraz mikrocopy dla bledow i flow create-character.
9. `SYS-D09`: dopracowac repair mode, diagnostics pack i telemetry bez wycieku sekretow.
10. `SYS-D10`: przygotowac rollout channels `dev/stage/stable` i polityke forced upgrade.

**P0 — Lekki Launcher (Bootstrap) — NOWY SUB-TRACK**

11. `SYS-D11`: zaprojektowac i zaimplementowac lekki launcher bootstrap w Rust (~KB) jako jednorazowy installer pelnego launchera — szczegoly w `25_PLAN_LEKKI_LAUNCHER_BOOTSTRAP.md`.
12. `SYS-D12`: lekki launcher pobiera pelny launcher z `installer-catalog.php?type=launcher`, weryfikuje SHA-256 i instaluje go w katalogu uzytkownika bez uprawnien admina.
13. `SYS-D13`: rozszerzyc `installer-catalog.php` o parametr `type=launcher` dla artefaktow pelnego launchera.
14. `SYS-D14`: utworzyc workflow GHA `build-bootstrap-launcher.yml` do kompilacji lekkiego launchera na Windows i Linux z weryfikacja rozmiaru < 500 KB.
15. `SYS-D15`: opublikowac lekki launcher na www/reddaxe jako glowny punkt wejscia "Pobierz gre", pelny launcher dostepny jako alternatywa "Wersja portable".

**P1 — Lekki Launcher (Bootstrap)**

16. `SYS-D16`: dodac minimalne GUI (Win32 progress bar / Linux TUI) do lekkiego launchera.
17. `SYS-D17`: dodac detekcje istniejacego pelnego launchera i pytanie o nadpisanie.
18. `SYS-D18`: dodac obsluge bledow i czytelne komunikaty (brak internetu, zly hash, brak miejsca).
19. `SYS-D19`: wykonac E2E test sciezki: bootstrap → pelny launcher → klient → gra.
20. `SYS-D20`: zaktualizowac kontrakty `installer-bootstrap.md` i `installer-catalog.md` o nowy model dwupoziomowy.

### TRACK E. Instalka i paczka gracza

**P0**

1. `SYS-E01`: utrzymac dwa oficjalne warianty instalki: dev oraz klient, z jasnym zrodlem builda, publikacji i dystrybucji przez GHA oraz API.
2. `SYS-E02`: zapewnic, ze chroniona instalka wymaga dostepu do internetu do walidacji bezpieczenstwa i odmawia pracy przy wykryciu naruszenia integralnosci albo podmiany plikow.
3. `SYS-E03`: przygotowac pobieranie przez launcher odpowiedniego artefaktu instalki z API: klient albo dev, zaleznie od publikacji i uprawnionego scenariusza.
4. `SYS-E04`: przygotowac first-run walidacje manifestu, podpisu, checksum, trybu serwera i zdalnego katalogu serwerow.
5. `SYS-E05`: przygotowac atomowe update, rollback i auto-repair klienta/instalki bez mozliwosci recznego obejscia listy serwerow.
6. `SYS-E06`: zapewnic, ze paczka gracza nie wymaga recznej konfiguracji do wejscia do gry.

**P1**

7. `SYS-E07`: dopracowac onboarding nowego gracza: konto globalne, wybor trybu, wybor serwera, postac, start.
8. `SYS-E08`: dodac package lint, security package scan i diff dev -> gracz.
9. `SYS-E09`: przygotowac uninstall, support bundle i top problems runbook.

### TRACK F. WWW Tibia i RedDAXE

**P0**

1. `SYS-F01`: wymusic, aby RedDAXE i WWW korzystaly z tych samych endpointow rejestracji i logowania.
2. `SYS-F02`: ujednolicic flow pobierania launchera i CTA po rejestracji/logowaniu.
3. `SYS-F03`: wdrozyc account pages pokazujace osobno konto globalne, konta techniczne serwerow i postacie per serwer, z jasnym przejsciem do create-character.
4. `SYS-F04`: objac cale WWW Tibia, RedDAXE i kolejne podpiete strony systemem i18n, bez twardych wyjatkow dla nowych widokow konta i logowania.
5. `SYS-F05`: wdrozyc sync-login z jednorazowym tokenem z launchera do WWW.
6. `SYS-F06`: odswiezanie `account-context` po utworzeniu postaci ma byc przewidywalne i bez restartu launchera.

**P1**

7. `SYS-F07`: uporzadkowac copy i UX dla nowego gracza, powracajacego gracza i gracza bez postaci.
8. `SYS-F08`: dopracowac download center, release notes, FAQ i komunikaty o dwoch serwerach oraz o relacji konto globalne -> konto serwera.
9. `SYS-F09`: przygotowac spojnosc wizualna i informacyjna miedzy RedDAXE i WWW.

### TRACK G. API i bezpieczenstwo

**P0**

1. `SYS-G01`: utwardzic `login.php`, `ticket.php`, `launcher-token.php`, katalog serwerow, katalog artefaktow instalki i `account-sync-*` pod walidacje danych, TTL, single-use i replay protection.
2. `SYS-G02`: potwierdzic produkcyjne dzialanie tabel `launch_tokens`, `manifest_versions`, `ticket_sessions`, `ticket_nonces`.
3. `SYS-G03`: dopiac cleanup wygaslych rekordow i procedury operacyjne dla awarii cleanup.
4. `SYS-G04`: wdrozyc rate limiting, structured logging i redakcje sekretow w logach API.
5. `SYS-G05`: dopracowac podpisy manifestow, weryfikacje artefaktow, weryfikacje integralnosci instalki i blokade startu przy mismatch albo pracy offline poza dozwolonym zakresem.
6. `SYS-G06`: zapewnic HTTPS everywhere i zakaz fallbacku na niezabezpieczone endpointy produkcyjne.

**P1**

7. `SYS-G07`: przygotowac rotacje kluczy/HMAC i grace period dla wersji launchera.
8. `SYS-G08`: dodac audyt bezpieczenstwa endpointow publicznych i polityke odpowiedzi na naduzycia.
9. `SYS-G09`: przygotowac minimalny threat model dla launchera, klienta, API i WWW.

### TRACK H. Baza danych i migracje

**P0**

1. `SYS-H01`: opisac i wdrozyc finalny schemat zaleznosci baz: konto globalne, konta techniczne engine, postacie, sesje, tokeny, nonce oraz relacje dla przyszlych gier/stron.
2. `SYS-H02`: przygotowac migracje idempotentne dla wszystkich krytycznych tabel i kolumn.
3. `SYS-H03`: przygotowac test danych po migracji: stare konta, stare postacie, brak `world_id`, konflikt ID, null-e.
4. `SYS-H04`: przygotowac plan rollbacku migracji dla P0 zmian danych.

**P1**

5. `SYS-H05`: przygotowac narzedzia diagnostyczne SQL dla supportu i operacji.
6. `SYS-H06`: przygotowac retencje danych technicznych i polityke cleanup dla tabel sesyjnych.

### TRACK I. DevOps, release i operacje

**P0**

1. `SYS-I01`: przygotowac jeden master gate systemowy przed kompilacja i publikacja.
2. `SYS-I02`: przygotowac wersjonowanie release artefaktow: launcher, instalka klienta, instalka dev, paczka gracza, manifest, signature, DB migration set.
3. `SYS-I03`: przygotowac checkliste `go/no-go` obejmujaca serwer, API, launcher, instalke, WWW, baze i paczke gracza.
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
3. `SYS-J03`: potwierdzic scenariusze `brak postaci`, `expired token`, `manifest mismatch`, `przerwany update`, `pelny dysk`, `brak uprawnien`, `brak internetu`, `naruszona integralnosc instalki`.
4. `SYS-J04`: potwierdzic scenariusz `konto z RedDAXE -> launcher`, `konto z WWW -> launcher`, `launcher -> WWW -> create-character -> launcher`, `inna podpieta strona -> launcher`.
5. `SYS-J05`: potwierdzic scenariusz `play` na obu serwerach w jednym modelu konta globalnego, ale z osobnymi kontami technicznymi/postaciami.

**P1**

6. `SYS-J06`: przygotowac tablice `kod bledu -> akcja gracza -> akcja supportu`.
7. `SYS-J07`: przygotowac support FAQ i gotowe komunikaty dla najczestszych problemow.
8. `SYS-J08`: przygotowac plan regresji po kazdym releasie krytycznym.

## 6. Gate systemowy

Nie wolno uznac systemu za gotowy, dopoki wszystkie ponizsze gate'y nie maja PASS:

1. `G-SYS-01`: jedno konto globalne dziala z launcherem, RedDAXE, WWW Tibia i co najmniej jednym dodatkowym podpietym frontendem logowania.
2. `G-SYS-02`: gracz moze zalozyc konto w dowolnym froncie i zalogowac sie w dowolnym innym.
3. `G-SYS-03`: create-character dziala dla Classic i Modern bez rozjazdu danych, ale z osobnymi kontami technicznymi i postaciami.
4. `G-SYS-04`: wybor trybu nastepuje przed polaczeniem, a blokada polaczenia z niewlasciwym serwerem PASS.
5. `G-SYS-05`: lista serwerow i artefaktow jest dostarczana tylko z API, bez mozliwosci lokalnego dopisywania przez gracza.
6. `G-SYS-06`: launcher/instalka poprawnie blokuja start bez postaci, bez sesji, bez zgodnosci wersji, bez internetu dla flow chronionego i przy naruszeniu integralnosci.
7. `G-SYS-07`: ticket-gate PASS end-to-end na obu serwerach.
8. `G-SYS-08`: paczka gracza oraz artefakty instalki sa czyste i przechodza package lint/security scan.
9. `G-SYS-09`: update, rollback i repair PASS.
10. `G-SYS-10`: WWW i RedDAXE maja spojne CTA, copy, i18n i flow dla nowego gracza.
11. `G-SYS-11`: monitoring, runbook i hotfix procedure sa gotowe.
12. `G-SYS-12`: dokumentacja stanu systemu jest aktualna.

## 7. Recommended execution waves

### Wave 1. Kontrakty, konto globalne i model instalek

1. `SYS-A01..A05`
2. `SYS-B01..B05`
3. `SYS-H01..H04`

### Wave 2. Dwa swiaty i API

1. `SYS-C01..C05`
2. `SYS-G01..G06`

### Wave 3. Launcher flow

1. `SYS-D01..D06`
2. `SYS-F04..F05`

### Wave 4. WWW, RedDAXE, i18n i UX

1. `SYS-F01..F08`
2. `SYS-B06..B08`

### Wave 5. Paczka gracza i release

1. `SYS-E01..E08`
2. `SYS-I01..I08`
3. `SYS-J01..J08`

## 8. Zasady realizacji

1. Najpierw kontrakt i dane, potem kod kliencki.
2. Nie duplikowac logiki konta miedzy launcherem, RedDAXE i WWW.
3. Instalka ma miec wlasna role i zabezpieczenia; nie moze dublowac logiki launchera, ale nie wolno tez splycac jej do roli pustego downloadera.
4. Nie przenosic twardego security z API/Canary do launchera.
5. Wszystkie P0 musza miec dowod PASS albo jawny BLOCKED z obejściem.
6. Kazda zmiana P0 musi zostawic wpis w dokumentacji i stan gate.

## 9. Definition of Done dla calego systemu

System jest profesjonalnie gotowy, gdy:

1. nowy gracz przechodzi od pobrania do wejscia do gry bez recznej konfiguracji,
2. stare konto, stare konta techniczne i stare postacie nie zostaja zgubione po migracjach,
3. dwa serwery sa obslugiwane jako jeden ekosystem i nie mieszaja danych ani postaci,
4. launcher, WWW, RedDAXE i kolejne strony sa roznymi wejsciami do tej samej tozsamosci globalnej,
5. instalka dev i instalka klienta sa kontrolowanymi artefaktami z walidacja integralnosci i polityka publikacji,
6. release mozna powtorzyc kontrolowanie i z rollbackiem,
7. support ma narzedzia do diagnozy, a nie zgadywania,
8. po publikacji da sie monitorowac zdrowie systemu operacyjnie, nie tylko recznie.