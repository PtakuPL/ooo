# Taski wdrozeniowe - launcher -> player client + dev client

Status: draft wykonawczy  
Data: 2026-03-08  
Powiazany dokument bazowy: `plan-systemu-launcher-zaszyfrowany-klient.md`

## 1. Zasada nadrzedna

Desktop ma miec jeden wspolny system dystrybucji klienta dla dwoch profili:

- `player`
- `dev`

Nie robimy dwoch roznych "mini platform". Robimy jeden pipeline:

- jeden format manifestu,
- jeden sposob pobierania,
- jeden system cache,
- jeden backend wydajacy paczki,
- jeden model sesji launcher -> klient.

## 2. Profil `player` i profil `dev`

### 2.1 Profil `player`

Profil `player` ma byc gotowym klientem dla graczy.

To znaczy:

- launcher pobiera i aktualizuje `player client`,
- `player client` moze miec widoczne pliki publiczne,
- launcher uzupelnia tylko warstwe `protected`,
- gracz dostaje gotowy klient blizszy modelowi publicznego OTCv8 niz "sealed everything".

Profil `player` moze miec:

- jawny `init.lua` bootstrap,
- wybrane jawne `data/`, `modules/`, `mods/`,
- layouty i pliki publiczne,
- publiczne binarki i runtime,
- zaszyfrowana tylko warstwe `protected`.

Ale nadal:

- musi byc kompatybilny z tym samym manifestem,
- musi korzystac z tego samego resolvera paczek,
- musi byc zgodny z tym samym modelem aktualizacji.

### 2.2 Profil `dev`

Profil `dev` ma byc prywatnym klientem tylko dla wlasciciela / developera.

Wymagania:

- moze miec wiecej jawnych plikow,
- moze miec debug, override i hot-reload,
- moze miec jawne `init.lua`, `data/`, `modules/`, `mods/`,
- moze byc dystrybuowany przez launcher albo lokalnie,
- nie powinien narzucac polityki ukrywania plikow na `player client`.

### 2.3 Wspolny kontrakt

Profil `player` i `dev` maja dzielic:

- `client_version`
- `channel`
- `platform`
- `arch`
- `manifest_hash`
- `package_hash`
- `ticket verification`

## 3. Priorytety wdrozenia

Kolejnosc priorytetow:

1. Naprawic fundament desktopowego buildu i packagingu.
2. Ujednolicic `player` i `dev` pod jeden system manifestu.
3. Dodac resolver paczek i cache do launchera.
4. Dodac sesje launcher -> klient.
5. Uszczelnic tylko warstwe `protected` profilu `player`.
6. Doprojektowac mobilne rozszerzenie pod Android.

## 4. Epic A - Kontrakty i decyzje architektoniczne

### A1. Profilowanie produktu

- [ ] Zdefiniowac profile: `player`, `dev`, `android-future`.
- [ ] Spisac roznice polityk miedzy `player` i `dev`.
- [ ] Ustalic, ktore funkcje sa wspolne, a ktore tylko developerskie.
- [ ] Ustalic klasyfikacje `public/protected/dev-only`.

### A2. Schemat manifestu

- [ ] Zaprojektowac jeden schemat manifestu dla desktop i przyszlego Androida.
- [ ] Dodac pola: `version`, `channel`, `platform`, `arch`, `packages`, `hashes`, `bootstrap_required`.
- [ ] Dodac pole profilu: `profile=player|dev`.
- [ ] Dodac pole `requires_launcher=true/false`.
- [ ] Dodac pole klasyfikacji paczki: `public|protected|dev-only`.

### A3. Polityka kryptograficzna

- [ ] Potwierdzic wybor: Ed25519 dla ticketow.
- [ ] Potwierdzic wybor: AES-256-GCM dla paczek.
- [ ] Ustalic model rotacji kluczy.
- [ ] Ustalic czy klucz zawartosci jest per release, per kanal, czy per paczka.

### A4. Polityka sesji

- [ ] Zdefiniowac TTL launch ticketu.
- [ ] Zdefiniowac zachowanie offline.
- [ ] Zdefiniowac zachowanie po wygasnieciu ticketu.
- [ ] Zdefiniowac polityke "fail-closed" po stronie klienta.

## 5. Epic B - Packaging i artefakty

### B1. Budowa paczek logicznych

- [ ] Przygotowac klasyfikator `public/protected/dev-only`.
- [ ] Przygotowac skrypt do skladania `protected-bootstrap.otpkg`.
- [ ] Przygotowac skrypt do skladania `protected-data.otpkg`.
- [ ] Przygotowac skrypt do skladania `protected-modules.otpkg`.
- [ ] Przygotowac skrypt do skladania `protected-mods.otpkg`.
- [ ] Ustalic zasade dzielenia na `base/hotfix/branding/private-assets/dev-tools`.

### B2. Szyfrowanie paczek

- [ ] Dodac krok szyfrowania `*.otpkg -> *.otpkg.enc`.
- [ ] Dodac SHA-256 dla kazdej paczki.
- [ ] Dodac walidacje integralnosci po szyfrowaniu.
- [ ] Dodac wersjonowanie paczek zgodne z kanalami.

### B3. Manifest artefaktow

- [ ] Generowac `client-manifest.json`.
- [ ] Wpisywac do manifestu rozmiary, hashe i role paczek.
- [ ] Oznaczac, ktore paczki sa wymagane dla `player`, a ktore dla `dev`.
- [ ] Oznaczac zgodnosc platform i architektur.
- [ ] Oznaczac, ktore pliki sa jawne w `player`, a ktore musza trafic do `protected`.

### B4. Zmiany w workflow CI

- [ ] Naprawic obecny build Windows jako prerequisite.
- [ ] Przerobic `build-client-package` na hybrydowy `player client + protected packages`.
- [ ] Rozdzielic artefakty `player` i `dev`.
- [ ] Dodac lint, ktory blokuje wyciek `protected` w plaintext do `player`.
- [ ] Dodac osobny lint, ktory pilnuje, ze `dev-only` nie trafia do `player`.

## 6. Epic C - Launcher desktop core

### C1. Resolver manifestu

- [ ] Dodac parser i walidator manifestu.
- [ ] Dodac porownanie lokalnego stanu z manifestem z API.
- [ ] Dodac wykrywanie brakujacych paczek.
- [ ] Dodac wykrywanie paczek ze zlym hashem.

### C2. Downloader i cache

- [ ] Dodac cache po hashach.
- [ ] Dodac resume / retry pobierania.
- [ ] Dodac atomowe zapisy plikow po pobraniu.
- [ ] Dodac auto-cleanup starych paczek.
- [ ] Dodac metryki czasu pobierania i hit rate cache.

### C3. Uzupelnianie klienta przed startem

- [ ] Przed kazdym startem sprawdzac komplet paczek dla wybranego profilu.
- [ ] Dociagac tylko brakujace zaszyfrowane paczki.
- [ ] Dociagac hotfixy bez przepakowywania calego klienta.
- [ ] Blokowac start, jesli zestaw paczek jest niekompletny.

To jest bezposrednia implementacja zalozenia:

- launcher ma uzupelniac brakujace pliki,
- ale tylko dla warstwy `protected`, nie przez przepakowywanie calej warstwy publicznej.

### C4. Sesja launcher -> klient

- [ ] Dodac tworzenie IPC.
- [ ] Dodac `launch session id`.
- [ ] Dodac przekazanie ticketu i danych paczek.
- [ ] Dodac oczekiwanie na `handshake ok`.
- [ ] Dodac timeout i obsluge bledow sesji.

## 7. Epic D - API i backend

### D1. Endpointy

- [ ] Zaprojektowac endpoint manifestu klienta.
- [ ] Zaprojektowac endpoint ticketu startowego.
- [ ] Zaprojektowac endpoint listy paczek / kanalow.
- [ ] Dodac endpoint revocation / emergency deny.

### D2. Polityka dostepu

- [ ] Uprzywilejowany dostep do API ma miec launcher.
- [ ] Klient nie dostaje stalego sekretu API.
- [ ] Klient dostaje tylko podpisany ticket i material sesyjny.
- [ ] Ticket ma byc powiazany z wersja, kanalem i czasem zycia.

### D3. Optymalizacja backendowa

- [ ] Manifest ma wspierac roznice per kanal i profil.
- [ ] Backend ma zwracac tylko potrzebne paczki dla danej platformy i architektury.
- [ ] Backend ma wspierac spojnosc desktop -> Android.

## 8. Epic E - Klient desktop

### E1. Bootstrap mode

- [ ] Dodac tryb startu `launcher-managed`.
- [ ] Dodac obsluge sesji z IPC.
- [ ] Dodac walidacje ticketu i wygasniecia.
- [ ] Dodac mapowanie ticket -> zestaw paczek.

### E2. Loader zasobow

- [ ] Dodac ladowanie paczek zaszyfrowanych.
- [ ] Dodac weryfikacje hashy przed montowaniem.
- [ ] Dodac polityke ladowania `public bootstrap -> public files -> protected packages -> hotfix`.
- [ ] Dodac diagnostyke bledu montowania.

### E3. Hybrydowy bootstrap i warstwa chroniona

- [ ] Wersja 1: zostawic jawny bootstrap i allowliste publicznych plikow.
- [ ] Wersja 2: przeniesc tylko wrazliwe fragmenty do `protected`.
- [ ] Wersja 3: ocenic, czy bootstrap C++ jest w ogole potrzebny.
- [ ] Upewnic sie, ze `player` nie eksportuje plaintext warstwy `protected`.

### E4. Fail-closed

- [ ] Zamykac klienta przy braku sesji.
- [ ] Zamykac klienta przy blednym tickecie.
- [ ] Zamykac klienta przy niezgodnosci hashy.
- [ ] Zamykac klienta przy niekompletnych paczkach.

## 9. Epic F - Profil `dev`

### F1. Dystrybucja dev dla wlasciciela

- [ ] Dodac kanal `dev` do manifestu.
- [ ] Dodac artefakty `dev` budowane przez CI.
- [ ] Dodac obsluge pobierania buildow developerskich.
- [ ] Dodac polityke rollback dla buildow dev.

### F2. Dodatki developerskie

- [ ] Ustalic czy `dev` dopuszcza paczki override.
- [ ] Ustalic czy `dev` dopuszcza jawne skrypty tylko lokalnie.
- [ ] Ustalic czy `dev` ma miec hot-reload i dodatkowe logi.
- [ ] Oddzielic te funkcje od profilu `player`.

### F3. Kompatybilnosc

- [ ] Utrzymac zgodny model manifestu z `player`.
- [ ] Utrzymac ten sam cache i resolver.
- [ ] Utrzymac te same nazwy paczek bazowych tam, gdzie to mozliwe.

## 10. Epic G - Profil `player`

### G1. Twarde ograniczenia

- [ ] Jawne sa tylko pliki z allowlisty `public`.
- [ ] Brak plaintext dla warstwy `protected`.
- [ ] Brak startu warstwy `protected` bez launchera.
- [ ] Brak dostepu klienta do uprzywilejowanego API.

### G2. Walidacja release

- [ ] Dodatkowe testy integracyjne `player`.
- [ ] Test "fresh install".
- [ ] Test "repair from partial cache".
- [ ] Test "manifest mismatch".
- [ ] Test "expired ticket".

## 11. Epic H - Testy i obserwowalnosc

### H1. Testy automatyczne

- [ ] Test parsera manifestu.
- [ ] Test hash validation.
- [ ] Test deszyfrowania paczek.
- [ ] Test handshake launcher -> klient.
- [ ] Test fail-closed dla warstwy `protected` w `player`.

### H2. Testy reczne

- [ ] Scenariusz: czysta instalacja.
- [ ] Scenariusz: usunieta jedna paczka z cache.
- [ ] Scenariusz: uszkodzony plik paczki.
- [ ] Scenariusz: brak internetu.
- [ ] Scenariusz: upgrade `dev -> player`.

### H3. Telemetria

- [ ] Logowac powod odmowy startu.
- [ ] Logowac czas pobierania.
- [ ] Logowac cache hit / miss.
- [ ] Logowac manifest mismatch.

## 12. Epic I - Przygotowanie pod Android

### I1. Wymagania architektoniczne juz teraz

- [ ] Nie zaszywac formatow i sciezek tylko pod Windows.
- [ ] Dodac pola `platform` i `abi` do manifestu.
- [ ] Rozdzielic pakiety bazowe od platform-specific runtime.
- [ ] Trzymac wspolny model ticketu i hashy.

### I2. Artefakty

- [ ] Ustalic ktore paczki beda wspolne dla desktop i Android.
- [ ] Ustalic ktore paczki beda per ABI Android.
- [ ] Ustalic jak packaging desktop ma pomagac pozniej packagingowi Android.

## 13. Epic J - Hardening i polityka bezpieczenstwa

### J1. Model zagrozen

- [ ] Spisac jawnie, przed kim system ma chronic, a przed kim nie.
- [ ] Odroznic wymagania "sealed package" od "best effort anti-reverse".
- [ ] Zamknac decyzje, ktore elementy sa wymagane w `player`, a ktore opcjonalne w `dev`.

### J2. Tozsamosc instalacji i polityka launchera

- [ ] Dodac `install_id` generowany przy pierwszym uruchomieniu.
- [ ] Uzywac `install_id` w requestach ticketowych.
- [ ] Dodac rate limiting per `install_id`.
- [ ] Dodac podpisywanie wydan launchera i klienta.
- [ ] Ustalic, ze `hash launchera` moze byc tylko sygnalem diagnostycznym, a nie root of trust.

### J3. IPC hardening

- [ ] Windows: zaprojektowac kanal oparty o odziedziczone handle.
- [ ] Linux: zaprojektowac `socketpair` / odziedziczony FD.
- [ ] Zostawic Named Pipe / UDS tylko jako fallback.
- [ ] Dodac losowy `session_nonce`.
- [ ] Dodac challenge-response po starcie klienta.

### J4. Key lifecycle i secure memory

- [ ] Dodac polityke secure allocation dla materialu sesyjnego.
- [ ] Dodac zeroization kluczy po uzyciu.
- [ ] Dodac zeroization buforow z plaintextem po montowaniu.
- [ ] Dla `player` zakazac plaintext tmp file dla warstwy `protected`.
- [ ] Dla `dev` jawnie oznaczyc, czy fallback tmp jest dozwolony.

### J5. Anti-replay i anti-rollback

- [ ] Dodac `jti` i single-use semantyke ticketu.
- [ ] Dodac `session_nonce`.
- [ ] Zwiazac ticket z `manifest_hash`, `profile`, `platform`, `arch`.
- [ ] Dodac `release_id`.
- [ ] Dodac `release_floor`.
- [ ] Odrzucac starsze podpisane manifesty ponizej floor.

### J6. Offline policy

- [ ] Potwierdzic `player = online-only` dla v1 dla warstwy `protected`.
- [ ] Potwierdzic, czy `dev` ma miec offline mode.
- [ ] Jesli kiedys dodamy offline dla `player`, opisac osobna faze i osobne ryzyka.

### J7. Runtime hardening

- [ ] Dodac code signing dla release.
- [ ] Dodac opcjonalne self-checki integralnosci binarki klienta.
- [ ] Ocenic koszt i zysk anti-debug.
- [ ] Ocenic koszt i zysk anti-dump.
- [ ] Potraktowac te elementy jako utrudnienie, nie gwarancje.

## 14. Milestones

### M0 - Architektura zatwierdzona

Done gdy:

- profil `player` i `dev` sa spisane,
- schema manifestu jest ustalona,
- polityka ticketu i kluczy jest ustalona,
- polityka `online-only vs offline` jest ustalona,
- polityka anti-rollback jest ustalona.

### M1 - Packaging foundation

Done gdy:

- CI buduje `*.otpkg.enc`,
- `player` ma allowliste warstwy `public`,
- launcher potrafi policzyc i sprawdzic hashe,
- `player` nie generuje plaintext tmp file dla warstwy `protected`.

### M2 - Launcher-managed start

Done gdy:

- launcher uzupelnia brakujace paczki,
- klient odbiera sesje z launchera,
- klient nie startuje bez poprawnego ticketu,
- ticket jest single-use,
- handshake wykorzystuje `session_nonce`.

### M3 - Hybrid player package

Done gdy:

- `player` ma czysty podzial `public/protected`,
- flow przechodzi testy integracyjne,
- anti-rollback dziala dla manifestu i release.

### M4 - Dev channel complete

Done gdy:

- `dev` tez korzysta z launcher download flow,
- update `dev` dziala z manifestu,
- `dev` nie rozwala modelu `player`.

## 15. Rekomendacja wykonawcza

Najbardziej pragmatyczna implementacja:

1. Zrobic M0.
2. Zrobic M1.
3. Zrobic M2.
4. Uspokoic profil `player`.
5. Dopiero potem dopinac wygodny `dev`.
6. Rownolegle pilnowac zgodnosci z przyszlym Androidem.
