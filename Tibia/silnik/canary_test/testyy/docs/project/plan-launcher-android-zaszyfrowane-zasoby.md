# Plan launchera Android - zaszyfrowane zasoby i wspolny system dystrybucji

Status: draft kierunkowy  
Data: 2026-03-08  
Powiazanie: ten dokument zaklada, ze desktopowy system `launcher -> player client + dev client` stanie sie baza referencyjna.

## 1. Cel

Po wdrozeniu desktopowego systemu chcemy przeniesc ten sam model na Android:

- launcher / instalka Android pobiera klienta i paczki,
- glownym profilem mobilnym jest `player`,
- ewentualny `dev` na Androidzie jest wtorny i wewnetrzny,
- paczki zasobow sa zaszyfrowane,
- API pozostaje po stronie launchera / aplikacji zarzadzajacej,
- klient Android nie dostaje uprzywilejowanych sekretow,
- aktualizacje i naprawa instalacji dzialaja z manifestu.

## 2. Zasada strategiczna

Android nie powinien dostac "osobnego wymyslonego systemu".

Rekomendacja:

- reuse tego samego backendu,
- reuse tego samego manifestu,
- reuse tego samego modelu paczek,
- reuse tego samego modelu hashy i ticketow,
- reuse tego samego podzialu profilow i kanalow `player/dev/beta/stable`.

To znaczy:

- desktop ma byc pierwsza implementacja,
- Android ma byc rozszerzeniem, a nie nowym projektem od zera.

## 3. Glowne roznice wzgledem desktop

Android narzuca inne warunki operacyjne:

- storage powinien byc app-private,
- aktualizacje maja byc odporne na przerwania,
- trzeba uwzglednic ABI, np. `arm64-v8a`,
- polityka uruchamiania i aktualizacji jest inna niz na desktopie,
- nie chcemy opierac sie na jawnych plikach na shared storage.

Wniosek:

- Android od poczatku powinien korzystac z app-private storage,
- paczki zasobow powinny byc trzymane poza przestrzenia widoczna jako zwykly folder uzytkownika.

## 4. Rekomendowany model produktu Android

Rekomendacja docelowa:

- launcher Android i klient Android powinny byc jedna logiczna aplikacja produktowa,
- warstwa "launcherowa" jest ekranem zarzadzajacym pobieraniem, sesja i update,
- warstwa "klientowa" jest natywnym runtime gry.

Powod:

- inter-process secret passing na Androidzie jest trudniejsze i mniej warte niz na desktopie,
- jedna aplikacja upraszcza storage, update i sesje,
- latwiej trzymac zasoby w app-private storage.

Wersja alternatywna, mniej zalecana:

- osobny launcher Android + osobna aplikacja klienta.

Tej wersji nie nalezy wybierac na starcie, chyba ze pojawi sie twarde wymaganie biznesowe.

## 5. Manifest i paczki

Manifest Android powinien byc zgodny z desktopem, ale rozszerzony o:

- `platform=android`
- `abi`
- `min_client_api`
- `package_group`
- `bootstrap_role`

Paczki:

- `bootstrap.otpkg.enc`
- `data.otpkg.enc`
- `modules.otpkg.enc`
- `mods.otpkg.enc`
- ewentualne paczki `android-runtime` albo `android-ui`

Wazne:

- nazwy paczek maja byc mozliwie zgodne z desktopem,
- roznice platformowe maja byc w manifestach, nie w chaosie nazewniczym.

## 6. Bezpieczenstwo Android

Model bezpieczenstwa:

- API access ma warstwa launcherowa aplikacji,
- runtime klienta dostaje tylko podpisany ticket i dane sesji,
- zaszyfrowane paczki siedza w app-private storage,
- klucze sesyjne nie sa zapisywane luzem do plikow roboczych.

Mozliwe dodatkowe wsparcie:

- Android Keystore do ochrony lokalnych materialow pomocniczych,
- krotkozyjace tokeny sesyjne,
- weryfikacja podpisu manifestu i ticketu po stronie natywnej.

Wazna przewaga Android wzgledem desktop:

- Android daje realniejsze mozliwosci ochrony lokalnego materialu kryptograficznego,
- storage moze byc app-private,
- platforma daje mocniejsze primitive pod secure storage niz typowy desktop.

Ale nadal:

- nie nalezy obiecywac pelnego DRM,
- rooted device i reverse engineering dalej pozostaja zagrozeniem.

## 7. Optymalizacja

Android musi byc bardziej agresywnie zoptymalizowany niz desktop.

Wymagania:

- pobieranie tylko brakujacych paczek,
- cache po hashach,
- mozliwosc resume,
- mozliwosc repair po przerwanym pobraniu,
- mozliwosc odlozonego cleanup starych paczek,
- mierzenie czasu startu po deszyfrowaniu.

## 8. Taski przygotowawcze pod Android juz na etapie desktop

- [ ] Dodac pola `platform` i `abi` do manifestu juz teraz.
- [ ] Nie hardcodowac desktopowych sciezek w schemacie manifestu.
- [ ] Utrzymac wspolny format `*.otpkg.enc`.
- [ ] Trzymac wspolny model podpisu ticketu.
- [ ] Trzymac wspolny model hashy paczek.
- [ ] Rozdzielic runtime platformowy od paczek wspolnych.
- [ ] Nie projektowac `package` desktopowego wokol plaintext tmp file, bo to nie przeniesie sie dobrze na Android.

## 9. Fazy Android

### A0 - Projekt kontraktow

- [ ] Potwierdzic, ze desktopowy manifest da sie rozszerzyc o Android bez lamania kompatybilnosci.
- [ ] Potwierdzic zestaw ABI.
- [ ] Ustalic polityke cache i storage.

### A1 - Launcher shell Android

- [ ] Ekran stanu instalacji i aktualizacji.
- [ ] Pobieranie manifestu.
- [ ] Pobieranie zaszyfrowanych paczek.
- [ ] Resume i retry.
- [ ] Repair po brakujacych paczkach.
- [ ] Generowanie i utrzymywanie lokalnego `install_id`.

### A2 - Runtime integracja

- [ ] Integracja klienta z app-private storage.
- [ ] Odczyt sesji i ticketu z warstwy launcherowej.
- [ ] Ladowanie zaszyfrowanych paczek.
- [ ] Weryfikacja hashy i podpisu.
- [ ] Wykorzystanie secure storage / keystore do ochrony lokalnych sekretow pomocniczych.

### A3 - Kanal `dev` na Android

- [ ] Dodac `dev` jako kanal manifestu Android.
- [ ] Dopuszczac dodatkowe paczki developerskie.
- [ ] Utrzymac zgodnosc z desktopowym workflow `dev`.

### A4 - Release hardening

- [ ] Testy na czystej instalacji.
- [ ] Testy po uszkodzeniu jednej paczki.
- [ ] Testy po przerwaniu pobierania.
- [ ] Testy zgodnosci ticketu i manifestu.
- [ ] Testy anti-rollback manifestu i release floor.
- [ ] Testy rate limit / revoke po stronie API.

## 10. Dodatkowe wymagania bezpieczenstwa Android

Android powinien od poczatku uwzgledniac:

- `install_id`,
- anti-replay ticketu,
- anti-rollback manifestu,
- rate limiting po stronie backendu,
- brak stalego sekretu API w runtime klienta,
- rozdzielenie "uprawnienia do pobrania" od "uprawnienia do uruchomienia".

Rekomendacja:

- launcher / warstwa zarzadzajaca pobiera i autoryzuje,
- runtime klienta tylko konsumuje podpisany ticket i zestaw paczek,
- wszelkie polityki offline dla release nalezy dodawac dopiero po stabilnym online-first flow.

## 11. Kryteria akceptacji Android

Plan Android mozna uznac za gotowy do implementacji, gdy:

- desktopowy manifest ma juz pola potrzebne Androidowi,
- profil `dev` i `package` sa wspolnie zdefiniowane,
- backend umie zwracac paczki per `platform/abi/channel`,
- launcher desktop udowodni dzialanie cache, sesji i sealed package flow,
- wiadomo, czy Android idzie jako jedna aplikacja czy dwa byty.

## 12. Rekomendacja

Najrozsadniejsza kolejnosc:

1. Ustabilizowac desktop.
2. Ujednolicic manifest i backend pod wieloplatformowosc.
3. Dopiero potem robic launcher / instalke Android.

Jesli to zrobimy odwrotnie, prawie na pewno powstana dwa rozne systemy dystrybucji, ktore beda sie rozjezdzac.
