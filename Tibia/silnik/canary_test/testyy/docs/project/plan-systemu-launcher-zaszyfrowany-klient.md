# Plan systemu launcher -> player client + dev client

Status: draft do akceptacji  
Data: 2026-03-08  
Zakres: launcher Rust + klient OTClient + packaging CI/CD

## 1. Cel

Chcemy zbudowac system, w ktorym:

- istnieje gotowy `player client` dla graczy, pobierany i uruchamiany przez launcher,
- istnieje osobny `dev client` tylko dla wlasciciela / developera,
- `player client` moze zawierac wybrane jawne pliki i katalogi, jesli sa uznane za publiczne,
- wrazliwe elementy klienta nie sa dostarczane graczowi w jawnej formie,
- launcher uzupelnia i aktualizuje warstwe chroniona przed startem sesji,
- zwykly gracz nie moze po prostu otworzyc folderu klienta i uzyskac wrazliwej logiki lub prywatnych pakietow.

## 2. Wazne ograniczenie

Tego systemu nie nalezy traktowac jako pelnego DRM.

Nie da sie osiagnac modelu:

- "uzytkownik nie moze odczytac plikow",
- ale "launcher i klient uruchomione na tym samym koncie uzytkownika moga je odczytac"

za pomoca samych uprawnien plikow.

Powod:

- system operacyjny kontroluje prawa dostepu glownie per konto, a nie per konkretne `exe`,
- jesli klient potrafi odczytac i odszyfrowac zasob, wlasciciel komputera z odpowiednia wiedza moze go finalnie wyciagnac z pamieci lub z IPC.

Cel praktyczny tego projektu jest inny:

- podniesc prog wejscia bardzo wysoko,
- ukryc tylko wrazliwe zasoby przed zwyklym graczem,
- wymusic uruchamianie przez launcher,
- utrudnic kopiowanie i proste modyfikacje klienta.

## 3. Stan obecny

Obecny kod daje juz kilka dobrych punktow zaczepienia:

- klient czyta token z launchera przez `OTC_LAUNCH_TOKEN` w `init.lua`,
- klient umie skanowac paczki `.otpkg`,
- workflow paczki dla graczy obecnie kopiuje jawne `data/`, `modules/`, `mods/`, `init.lua`,
- startup klienta nadal wymaga fizycznego `init.lua` na dysku,
- system szyfrowania istnieje w kodzie, ale jest obecnie wylaczony.

Do tego dochodzi wazna obserwacja produktowa:

- model zblizony do OTCv8 pokazuje publiczny, gotowy klient dla graczy z widocznymi plikami startowymi i binariami,
- rozwoj idzie osobnym torem developerskim,
- to znaczy, ze pelne "ukryj wszystko" nie jest naszym celem.

To oznacza, ze potrzebujemy modelu hybrydowego:

- warstwa publiczna dla `player client`,
- warstwa chroniona dla wrazliwych elementow,
- osobny `dev client` z wieksza widocznoscia plikow.

## 4. Docelowy model architektoniczny

### 4.1 Zasada ogolna

Docelowo `player client` nie powinien dostawac wszystkich wrazliwych zasobow w formie jawnej.

Model docelowy:

1. Launcher pobiera manifest wersji klienta.
2. Launcher rozroznia warstwe `public`, `protected` i `dev-only`.
3. Launcher pobiera brakujace zaszyfrowane paczki dla warstwy `protected`.
4. Launcher uzyskuje z backendu jednorazowy `launch ticket`.
5. Launcher uruchamia klienta i przekazuje mu dane sesyjne przez IPC.
6. Klient weryfikuje ticket i laduje tylko te chronione zasoby, ktore sa potrzebne.
7. Zasoby publiczne moga pozostac widoczne na dysku, jesli sa na allowliscie.
8. Klient nie startuje poprawnie bez launchera i bez poprawnego ticketu dla warstwy chronionej.

### 4.2 Model hybrydowy

Podzial klienta:

- warstwa `public`:
  - binarki,
  - bootstrap,
  - czesc konfiguracji,
  - wybrane moduly i zasoby, ktore moga byc jawne
- warstwa `protected`:
  - wrazliwe moduly,
  - prywatna logika serwerowa,
  - prywatne konfiguracje,
  - wybrane assety lub skrypty
- warstwa `dev-only`:
  - narzedzia developerskie,
  - override,
  - debug helpers,
  - pliki robocze tylko dla wlasciciela / developera

Zasada:

- nie chowamy wszystkiego na sile,
- chowamy tylko to, co rzeczywiscie jest wrazliwe albo ma sens biznesowy do ochrony.

### 4.3 Zalecany format zasobow

Rekomendacja:

- uzywac paczek `*.otpkg` jako formatu logicznego dla warstwy `protected`,
- dla warstwy `public` dopuszczac normalne pliki i katalogi,
- przechowywac na dysku launchera tylko wariant zaszyfrowany dla paczek chronionych, np. `protected-base.otpkg.enc`, `protected-mods.otpkg.enc`.

Powody:

- kod klienta juz ma logike zwiazana z `.otpkg`,
- to minimalizuje liczbe zmian w loaderze zasobow,
- to dobrze pasuje do modelu OTCv8, gdzie czesc klienta jest publiczna i gotowa do uzycia.

### 4.4 Reprezentacja paczek

Minimalny zestaw paczek chronionych:

- `protected-bootstrap.otpkg.enc`
- `protected-data.otpkg.enc`
- `protected-modules.otpkg.enc`
- `protected-mods.otpkg.enc`

Opcjonalnie:

- oddzielny `server-branding.otpkg.enc`,
- oddzielny `premium-features.otpkg.enc`,
- oddzielny `private-assets.otpkg.enc`,
- oddzielny `hotfix.otpkg.enc`.

## 5. Boot flow

## 5.1 Wersja przejsciowa

Najtansza implementacyjnie wersja:

- zostawiamy jawny bootstrap i wybrane publiczne pliki klienta,
- bootstrap nie zawiera wrazliwej logiki gry,
- bootstrap tylko:
  - odbiera dane sesji z launchera,
  - montuje zaszyfrowane paczki chronione,
  - uruchamia glowny init lub dolacza chronione moduly.

Co moze byc jawne:

- `otclient.exe`
- DLL/so wymagane przez runtime
- `init.lua` bootstrap
- wybrane `data/`, `modules/`, `mods/`
- layouty i configi publiczne
- maly loader startowy

Co nie powinno byc jawne:

- wrazliwe moduly i skrypty,
- prywatna konfiguracja serwera,
- prywatne assety,
- wszystko, co trafi do warstwy `protected`.

## 5.2 Wersja docelowa

Docelowo mamy dwie dopuszczalne drogi:

- wariant pragmatyczny:
  - jawny `init.lua` bootstrap zostaje,
  - wrazliwe elementy sa w warstwie chronionej
- wariant hardening:
  - bootstrap zostaje przeniesiony do C++ albo zasobu osadzonego,
  - zewnetrzny `init.lua` mozna ograniczyc albo usunac

To oznacza:

- brak jawnych `.lua` nie jest juz celem absolutnym,
- celem jest brak jawnych wrazliwych `.lua` i prywatnej logiki.

## 6. Transport kluczy i sesji

### 6.1 Czego nie robic

Nie rekomenduje:

- zapisu klucza deszyfrujacego do pliku obok klienta,
- trzymania stalego sekretu w jawnym `init.lua`,
- uzywania samego `read-only`, `hidden` albo ACL jako glownego zabezpieczenia,
- przekazywania docelowego klucza zawartosci przez zwykle pliki tymczasowe.

### 6.2 Zalecany mechanizm

Rekomendacja:

- launcher otwiera IPC:
  - Windows: Named Pipe
  - Linux: Unix Domain Socket lub pipe anonimowy
- launcher uruchamia klienta z parametrem sesji, np. `--launcher-session=<id>`
- klient laczy sie z IPC i pobiera:
  - launch ticket
  - identyfikator wersji
  - liste paczek
  - jednorazowy klucz sesyjny albo material do odszyfrowania paczek

### 6.3 Material kryptograficzny

Proponowany model minimalny:

- backend wystawia podpisany `launch ticket`,
- launcher przekazuje klientowi ticket oraz krotkozyjacy klucz sesyjny,
- klient weryfikuje ticket wbudowanym kluczem publicznym,
- klient odblokowuje paczki tylko dla tej sesji.

Rekomendowane prymitywy:

- podpis ticketu: Ed25519
- szyfrowanie paczek: AES-256-GCM

Powody:

- dobre wsparcie po stronie Rust,
- sensowne wsparcie po stronie C++ i OpenSSL,
- prosty model podpis + szyfrowanie.

## 7. Ladowanie zasobow

Docelowo klient powinien ladowac warstwe chroniona bez jawnego rozpakowywania na dysk.

Preferowana kolejnosc:

1. Montowanie odszyfrowanych paczek z pamieci.
2. Jesli to zbyt duzy koszt wdrozeniowy w pierwszym kroku:
   - uzycie bezpieczniejszego pliku tymczasowego tylko na czas procesu,
   - natychmiastowe usuniecie po zakonczeniu pracy.

Wersja docelowa powinna dazyc do:

- zero plaintext dla paczek `protected`,
- brak wycieku chronionych `.lua` na dysk,
- minimum metadanych pozostawionych po zamknieciu klienta,
- zachowania widocznych tylko tych plikow, ktore sa celowo publiczne.

## 8. Wymuszanie startu tylko przez launcher

Klient powinien fail-closed.

Jesli nie ma poprawnej sesji od launchera:

- brak ticketu,
- ticket wygasl,
- ticket nie pasuje do wersji,
- brak paczek,
- podpis niepoprawny,

to klient ma sie zamknac z czytelnym komunikatem diagnostycznym.

Dodatkowo:

- launcher powinien podawac wersje i kanal,
- klient powinien odrzucac niezgodna wersje paczek,
- launcher powinien pilnowac kompletnego zestawu plikow przed startem.

## 9. Zmiany w packagingu

Aktualny workflow "package for players" trzeba zmienic z modelu "jawne wszystko" na model hybrydowy.

Nowe zasady:

- workflow klasyfikuje pliki na `public`, `protected`, `dev-only`,
- workflow kopiuje tylko allowlistowane pliki publiczne do `player client`,
- workflow buduje paczki `.otpkg` dla warstwy `protected`,
- workflow szyfruje paczki chronione do `*.otpkg.enc`,
- workflow generuje manifest zawierajacy:
  - nazwe paczki
  - wersje
  - hash SHA-256
  - rozmiar
  - kanal
  - role `public/protected/dev-only`
  - ewentualne flagi zgodnosci

Allowlista artefaktow dla `player client`:

- `otclient.exe`
- wymagane biblioteki runtime
- `init.lua` bootstrap, jesli zostaje publiczny
- wybrane katalogi `data/`, `modules/`, `mods/`, jesli sa oznaczone jako publiczne
- layouty, konfiguracje i assety publiczne
- `client-manifest.json`
- zaszyfrowane paczki `*.otpkg.enc` warstwy chronionej

Nowa denylista dla `player client`:

- wszystkie pliki sklasyfikowane jako `protected`, jesli trafiaja w plaintext,
- wszystkie pliki `dev-only`,
- `*.proto`
- pliki zrodlowe
- CMake, Cargo, debug symbols, skrypty CI

## 10. Zmiany po stronie launchera

Launcher powinien zyskac nowy pipeline:

1. Sprawdzenie lokalnego cache paczek.
2. Pobranie tylko brakujacych lub niezgodnych hashami paczek.
3. Pobranie `launch ticket`.
4. Utworzenie IPC.
5. Start klienta z parametrem sesji.
6. Przekazanie danych sesyjnych do klienta.
7. Oczekiwanie na `handshake ok`.
8. Sprzatanie po bledzie lub po zakonczeniu sesji.

Launcher powinien tez logowac:

- wersje paczek,
- hash manifestu,
- status weryfikacji,
- powody odmowy startu.

## 11. Zmiany po stronie klienta

Po stronie klienta trzeba wykonac minimum:

1. Nowy tryb startu "launcher-managed".
2. Loader sesji przez IPC.
3. Weryfikacja podpisu ticketu.
4. Weryfikacja zgodnosci wersji i hashy.
5. Odszyfrowanie i zamontowanie paczek chronionych.
6. Polaczenie warstwy publicznej i chronionej w runtime.
7. Zamkniecie klienta przy bledach walidacji.

W praktyce beda potrzebne zmiany przynajmniej w:

- startupie klienta,
- `ResourceManager`,
- loaderze skryptow,
- packagingu i discovery zasobow,
- diagnostyce/logach.

## 12. Backend / API

System wymaga prostego wsparcia backendowego.

Backend powinien dostarczac:

- manifest wersji klienta,
- liste paczek publicznych i chronionych do pobrania,
- podpisany `launch ticket`,
- informacje o wygasnieciu ticketu,
- ewentualnie polityke kanalu `stable/beta/dev`.

Ticket powinien zawierac co najmniej:

- `session_id`
- `user_id` lub identyfikator launchera
- `client_version`
- `channel`
- `issued_at`
- `expires_at`
- liste dozwolonych paczek lub `manifest_hash`
- `profile`

Klient nie musi znac prywatnego sekretu backendu.
Klient powinien znac tylko klucz publiczny do weryfikacji podpisu.

## 13. Fazy wdrozenia

### Faza 0 - prerequisite

Zakres:

- naprawa aktualnego faila buildu Windows,
- ustalenie finalnego formatu paczek i kryptografii,
- decyzja: czy `player client` ma zostawic jawny bootstrap i ktore pliki sa `public/protected/dev-only`.

Wyjscie:

- stabilny build Windows i Linux,
- decyzje architektoniczne spisane i zatwierdzone.

### Faza 1 - packaging v1

Zakres:

- klasyfikacja `public/protected/dev-only`,
- budowanie paczek `protected`,
- szyfrowanie do `*.otpkg.enc`,
- nowy manifest artefaktow,
- nowy `player client` z warstwa publiczna i chroniona.

Wyjscie:

- `player client` zawiera tylko jawne pliki z allowlisty i brak plaintext dla warstwy `protected`.

### Faza 2 - launcher session v1

Zakres:

- pobieranie manifestu i paczek przez launcher,
- cache paczek po hashach,
- pobieranie launch ticketu,
- Named Pipe / UDS handshake,
- start klienta z sesja.

Wyjscie:

- klient dostaje sesje tylko z launchera,
- launcher ma diagnostyke dla startu klienta.

### Faza 3 - client bootstrap v1

Zakres:

- tryb `launcher-managed`,
- weryfikacja ticketu,
- odszyfrowanie paczek `protected`,
- montowanie warstwy chronionej,
- start z bootstrapu publicznego albo mieszanej warstwy.

Wyjscie:

- klient uruchamia gre z warstwy publicznej i chronionej.

### Faza 4 - opcjonalny hardening bootstrapu

Zakres:

- opcjonalne przeniesienie bootstrapu do C++ albo do zasobu osadzonego,
- ewentualne ograniczenie lub usuniecie fizycznego `init.lua` z `player client`,
- nowa polityka lintowania artefaktow tylko jesli ten hardening bedzie potrzebny.

Wyjscie:

- zredukowana powierzchnia jawnego bootstrapu, jesli uznamy to za potrzebne.

### Faza 5 - hardening

Zakres:

- podpisy manifestow,
- dodatkowe kontrole hashy,
- telemetryczne logi odmowy startu,
- rotacja kluczy i procedura emergency revoke.

Wyjscie:

- system gotowy do produkcyjnego rollout.

## 14. Kryteria akceptacji

System uznajemy za gotowy do pierwszego rollout, gdy:

- klient nie uruchamia gry bez poprawnego ticketu,
- `player client` zawiera tylko publiczne pliki z allowlisty,
- `player client` nie zawiera plaintext warstwy `protected`,
- launcher potrafi pobrac i zweryfikowac wszystkie paczki,
- klient potrafi zaladowac warstwe publiczna i chroniona razem,
- istnieje osobny `dev client` dla wlasciciela / developera,
- build Windows i Linux przechodzi,
- update klienta nie wymaga recznego kopiowania zasobow.

## 15. Ryzyka

Najwazniejsze ryzyka:

- zbyt duzy scope w pierwszej iteracji,
- problemy cross-platform z IPC,
- zbyt skomplikowane zarzadzanie kluczami,
- spadek czasu startu klienta przez deszyfrowanie,
- falszywe poczucie "pelnego zabezpieczenia",
- antywirusy lub EDR reagujace na nietypowy bootstrap i IPC.

Mitigacje:

- robic rollout etapami,
- najpierw wersja przejsciowa z minimalnym bootstrapem,
- najpierw udowodnic stabilnosc flow na Windows,
- od poczatku logowac wszystkie odrzucenia startu.

## 16. Decyzje do podjecia przed implementacja

1. Czy pierwsza wersja ma zostawic jawny bootstrap i `init.lua` dla `player client`?
2. Ktore pliki i katalogi klasyfikujemy jako `public`, ktore jako `protected`, a ktore jako `dev-only`?
3. Czy paczki szyfrujemy w jednym kluczu per release, czy w modelu rotowalnym per kanal?
4. Czy Named Pipe / UDS jest jedynym IPC, czy robimy tez fallback?
5. Czy launcher ma obslugiwac offline cache, czy zawsze wymagamy online przy starcie?
6. Czy implementujemy montowanie z pamieci od razu, czy przejscie przez wersje tymczasowa?

## 17. Rekomendacja wykonawcza

Najbardziej pragmatyczna kolejnosc:

1. Naprawic obecny build Windows.
2. Rozpisac klasyfikacje `public/protected/dev-only`.
3. Zmienic packaging na hybrydowy `player client + protected packages`.
4. Dodac sesje launcher -> klient przez IPC.
5. Odpalic klient z jawnym bootstrapem i chroniona warstwa.
6. Dopiero potem zdecydowac, czy hardening `init.lua` jest w ogole potrzebny.

Taka kolejnosc daje szybki efekt produktowy:

- gracz dostaje gotowego klienta w modelu blizszym OTCv8,
- tylko wrazliwe elementy sa ukryte,
- `dev client` moze pozostac wygodny i bardziej jawny,
- mozna testowac system etapami,
- nie blokujemy sie od razu na najtrudniejszym refaktorze startupu.

## 18. Profile dystrybucji: player i dev

Ten system ma obslugiwac dwa glowne profile klienta desktopowego:

- `player`
- `dev`

Oba profile powinny korzystac z tego samego silnika dystrybucji:

- ten sam launcher resolver,
- ten sam format manifestu,
- ten sam model paczek,
- ten sam system hashy i wersjonowania,
- ten sam backend wydajacy manifesty i ticket.

Roznica miedzy nimi ma byc polityka i poziom widocznosci plikow, a nie osobny chaos technologiczny.

Profil `player`:

- jest gotowym klientem dla graczy,
- moze wygladac podobnie do publicznego modelu OTCv8,
- moze miec jawny bootstrap i wybrane jawne katalogi,
- ma byc wygodny do pobrania i uruchomienia,
- ma dostawac warstwe `protected` przez launcher.

Profil `dev`:

- jest prywatnym klientem tylko dla wlasciciela / developera,
- moze miec wiecej jawnych plikow,
- moze miec jawne `init.lua`, `data/`, `modules/`, `mods/`,
- moze miec override, debug, hot-reload i inne narzedzia robocze,
- nie musi spelniac tej samej polityki ukrywania co `player`.

Wniosek architektoniczny:

- `player client` ma byc produktem glownym dla graczy,
- `dev client` ma byc produktem wewnetrznym dla wlasciciela,
- oba maja byc budowane na tej samej podstawie technologicznej,
- launcher ma umiec uzupelniac brakujace zaszyfrowane paczki dla `player`,
- samo API ma byc po stronie launchera, a nie po stronie klienta.

## 19. Zasada bezpieczenstwa API

Uprzywilejowany dostep do API powinien miec launcher.

Klient nie powinien:

- trzymac stalego sekretu API,
- znac kluczy backendowych,
- samodzielnie pobierac kluczy deszyfrujacych w trybie uprzywilejowanym.

Klient powinien dostawac tylko minimum potrzebne do startu sesji:

- podpisany `launch ticket`,
- ograniczony czasowo material sesyjny,
- informacje o paczkach do zamontowania.

To spelnia zalozenie:

- "API ma launcher",
- klient dostaje tylko to, co jest potrzebne do jednego uruchomienia,
- bez launchera paczki nie daja sie poprawnie wykorzystac.

## 20. Wymagania optymalizacyjne

Zeby ten system byl praktyczny, musi byc rowniez wydajny.

Wymagania:

- cache po hashach, a nie po samej nazwie pliku,
- pobieranie tylko brakujacych albo zmienionych paczek,
- mozliwosc dzielenia paczek na `base`, `hotfix`, `branding`, `locale`, `dev-tools`,
- wspolny manifest dla wielu kanalow,
- mozliwosc pozniejszego rozszerzenia na Android bez przepisywania calego backendu.

Praktyczny cel:

- launcher ma umiec "uzupelnic brakujace pliki" przez dociagniecie brakujacych zaszyfrowanych paczek warstwy `protected`,
- a `player client` ma pozostawac gotowym publicznym klientem z jawna warstwa `public`.

## 21. Gotowosc pod Android

Ten system od poczatku ma byc projektowany tak, zeby pozniej przeniesc go do launchera / instalek Android.

To oznacza juz teraz:

- wspolny format manifestu dla desktop i Android,
- wspolne nazewnictwo paczek,
- wspolna semantyka kanalow `dev/stable/beta`,
- wspolny model podpisu ticketu i hashy paczek,
- unikanie zalozen typu "tylko Windows IPC i tylko Windows cache layout".

W praktyce:

- desktop jest pierwsza implementacja referencyjna,
- Android jest planowany jako drugi etap, ale nie jako osobny system od zera.

## 22. Powiazane dokumenty

Dokument wykonawczy z taskami:

- `docs/project/plan-systemu-launcher-zaszyfrowany-klient-taski.md`

Dokument kierunkowy pod Android:

- `docs/project/plan-launcher-android-zaszyfrowane-zasoby.md`

## 23. Model zagrozen i granice systemu

Ten plan ma chronic glownie przed:

- zwyklym graczem, ktory tylko otwiera katalog `player client`,
- prostym kopiowaniem wrazliwych plikow i pakietow chronionych,
- prostym uruchamianiem klienta bez launchera,
- prostym replay ticketu lub rollbackiem do starego manifestu,
- prostym "repair" przez reczne podmiany plikow.

Ten plan nie gwarantuje pelnej ochrony przed:

- wlascicielem komputera z debuggerem,
- dumpem pamieci procesu,
- hookowaniem funkcji deszyfrujacych,
- patchowaniem lokalnego binarium,
- zaawansowanym reverse engineeringiem.

Wniosek:

- to ma byc system "hard to abuse", nie "impossible to reverse",
- najlepsze efekty da polaczenie:
  - sealed packages,
  - jednorazowej sesji,
  - fail-closed,
  - podpisow i hashy,
  - rozsadnego hardeningu runtime.

## 24. Dodatkowe wymagania bezpieczenstwa po review

### 24.1 Binarka klienta i launchera

Samo zaszyfrowanie zasobow nie wystarczy.

Dlatego plan powinien obejmowac tez:

- podpisywanie wydan launchera i klienta,
- weryfikacje integralnosci release chain w launcherze,
- opcjonalne self-checki integralnosci binarki klienta,
- opcjonalny anti-debug / anti-tamper / anti-dump jako warstwa utrudniajaca.

Wazna uwaga:

- anti-debug i anti-tamper na desktopie sa tylko hardeningiem,
- nie wolno traktowac ich jako glownego filaru bezpieczenstwa,
- nie powinny blokowac fazy 1-3 wdrozenia.

### 24.2 Polityka kluczy i pamieci

Brakujacy element planu to cykl zycia klucza w runtime.

Wymagania:

- klucz sesyjny ma zyc tylko tyle, ile jest potrzebne do walidacji i montowania,
- po uzyciu ma byc nadpisany / wyzerowany,
- plaintext paczek nie moze byc trzymany dlugotrwale bez potrzeby,
- wszystkie bufory z kluczami i materialem sesyjnym powinny miec jawna polityke zeroization.

Decyzja projektowa:

- dla warstwy `protected` w `player client` plaintext tymczasowy na dysku jest zabroniony,
- `player client` wymaga montowania warstwy chronionej z pamieci albo innego rozwiazania bez jawnego pliku roboczego,
- ewentualny fallback z plikiem tymczasowym moze istniec tylko dla `dev` lub narzedzi wewnetrznych.

### 24.3 Kanal launcher -> klient

Sam Named Pipe / UDS nie wystarczy jako jedyne zabezpieczenie.

Preferowana implementacja v1:

- Windows: kanal anonimowy / odziedziczony handle lub inny mechanizm niepublicznego IPC,
- Linux: `socketpair` lub odziedziczony FD,
- Named Pipe / UDS tylko jako fallback.

Jesli fallback publiczny bedzie potrzebny:

- nazwa endpointu musi byc losowa per sesja,
- endpoint musi powstac przed startem klienta,
- musi istniec challenge-response z nonce sesji,
- klient i launcher musza wzajemnie sprawdzic zgodnosc ticketu, `session_id` i `manifest_hash`.

### 24.4 Replay, reuse i anti-rollback

Ticket nie moze byc tylko "krotkozyjacym tokenem".

Musi miec:

- `jti` / unikalny identyfikator sesji,
- semantyke single-use po stronie backendu,
- `issued_at` i `expires_at`,
- powiazanie z `manifest_hash`,
- powiazanie z `profile`,
- powiazanie z `platform/arch`,
- powiazanie z `session_nonce`,
- opcjonalnie powiazanie z `install_id`.

Manifest i release musza miec anti-rollback:

- monotoniczny `release_id`,
- minimalny dozwolony `release_floor`,
- lokalne zapamietanie najwyzszego zaakceptowanego floor dla `player`,
- odrzucanie starszych, nawet poprawnie podpisanych manifestow, jesli sa ponizej floor.

### 24.5 Offline policy

To wymaga jawnej decyzji, nie tylko "do ustalenia".

Rekomendacja v1:

- `player`: online-only przy starcie sesji warstwy chronionej,
- `dev`: moze dostac ograniczony offline mode, jesli bedzie potrzebny roboczo.

Powod:

- offline dla `player` oznacza lokalny cache uprawnien lub kluczy,
- to znaczaco podnosi ryzyko replay i lokalnej ekstrakcji.

Jesli kiedys pojawi sie offline dla `player`, to tylko jako osobna faza:

- krotki grace period,
- lokalny stan zaszyty i chroniony przez OS-provided secure storage,
- twarde TTL i anti-rollback dla cache.

### 24.6 Ochrona API i rate limiting

Launcher ma miec uprzywilejowany dostep do API, ale backend nie powinien slepo ufac samej obecnosci launchera na dysku.

Dlatego backend powinien miec:

- rate limiting per konto,
- rate limiting per `install_id`,
- rate limiting per IP / subnet,
- telemetryke nietypowych prob pobierania ticketow,
- mozliwosc szybkiego revoke.

Rekomendacja:

- zamiast "fingerprintingu" niejawnego lepiej miec jawny `install_id`,
- `install_id` powinien byc generowany przez launcher przy pierwszym uruchomieniu,
- ten identyfikator ma byc uzywany do polityk bezpieczenstwa i diagnostyki,
- nie nalezy traktowac `hash binarki launchera` jako jedynego anchoru zaufania.

## 25. Decyzje v1 po review

Rekomendowane decyzje na teraz:

1. `player client` ma byc profilem hybrydowym `public + protected`.
2. `player` jest online-only w fazie 1-3 dla warstwy chronionej.
3. `player` nie uzywa plaintext tmp file dla warstwy chronionej.
4. `dev client` moze miec wiecej jawnych plikow i ewentualne fallbacki robocze.
5. IPC domyslnie ma byc niepubliczne i odziedziczane, nie publiczny Named Pipe.
6. Ticket ma byc single-use i zwiazany z `manifest_hash + profile + platform + session_nonce`.
7. Release ma miec anti-rollback przez `release_id` i `release_floor`.
8. Launcher ma miec `install_id` i rate limiting po stronie backendu.
9. Anti-debug / anti-dump trafia do fazy hardening, nie do fundamentu.
