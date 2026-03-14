# Plan RedDAXE - auth akcji wrazliwych i kont social

Status: plan do wdrozenia  
Data: 2026-03-09  
Zakres: `RedDAXE.pl` + `apik/v1` + konta `Google / Facebook / Steam`

## 1. Powod wydzielenia planu

Aktualny formularz `RedDAXE` `/reddaxe/guild-found.php` wymaga ponownego podania hasla konta przed zalozeniem globalnej gildii.

To podejscie jest niespojne z docelowym systemem kont, bo:

- dla kont `Google-only`, `Facebook-only` i `Steam-only` user moze nie znac zadnego lokalnego hasla,
- dla zwyklych kont obniza to UX i duplikuje potwierdzenie mimo aktywnej sesji,
- backend social auth jest juz u Was czesciowo gotowy, ale UI i polityka akcji wrazliwych nie sa jeszcze domkniete.

Ten plan wydziela temat poza sam plan globalnych gildii, bo dotyka warstwy kont, logowania, sesji i social login.

## 2. Stan obecny

Na dzien `2026-03-09`:

- `RedDAXE` ma aktywny formularz `/reddaxe/guild-found.php`,
- formularz wymaga pola `Haslo konta`,
- backend `apik/v1` ma juz flow:
  - `oauth-start.php`
  - `oauth-callback.php`
  - `account_identity_links`
  - providerow `google`, `facebook`, `steam`,
- konta social moga byc juz tworzone lub linkowane, ale warstwa WWW nie jest jeszcze projektowo domknieta pod akcje wrazliwe,
- nie ma jeszcze jednego jawnego modelu:
  - kiedy wystarcza sama aktywna sesja,
  - kiedy potrzebny jest `step-up auth`,
  - jak traktowac konta bez lokalnego hasla.

## 3. Decyzja produktowa v1

Decyzja na teraz:

- dla zalozenia globalnej gildii w `RedDAXE` nie wymagamy ponownego podania hasla,
- ufamy aktywnej, poprawnej sesji WWW,
- zabezpieczenia dla tej akcji maja byc oparte o:
  - `CSRF`,
  - walidacje uprawnien po stronie serwera,
  - `POST-only`,
  - audit log,
  - rate limiting,
  - opcjonalny prosty confirm w UI.

To oznacza:

- pole hasla w `guild-found.php` ma zostac usuniete,
- `guild-found.php` ma byc poprawne dla kont lokalnych i social-only,
- `step-up auth` nie jest blockerem dla `guild-found` w v1.

## 4. Podzial akcji po poziomie ryzyka

### 4.1 Poziom A - read-only

Wystarcza aktywna sesja:

- podglad panelu konta,
- podglad panelu gildii,
- lista instancji gildii,
- lista czlonkow gildii.

### 4.2 Poziom B - akcje sredniego ryzyka

Wystarcza aktywna sesja + zabezpieczenia formularza:

- zalozenie globalnej gildii,
- zmiana `local leader`,
- podstawowe akcje ownera gildii, ktore nie zmieniaja samego konta.

Wymagane zabezpieczenia:

- `CSRF token`,
- `Origin/Referer` check dla POST, jesli to realnie mozliwe w runtime,
- ponowna walidacja ownership / scope po stronie backendu,
- audit log z `account_id`, `ip`, `user_agent`, `action`, `result`,
- rate limit per konto i per IP,
- `SameSite=Lax` lub mocniejszy model cookies, jesli nie rozbije loginu / callbackow.

### 4.3 Poziom C - akcje wysokiego ryzyka

Tu plan zaklada mocniejsze potwierdzenie w przyszlym etapie:

- `transfer owner` globalnej gildii,
- unlink ostatniego providera social,
- zmiana e-maila,
- zmiana hasla,
- usuniecie konta,
- inne akcje, ktore moga odciac usera od konta albo przekazac kontrole nad globalna gildia.

Docelowe opcje:

- `session freshness` na podstawie czasu od loginu,
- albo provider-aware `step-up auth`,
- albo lokalne haslo, jesli konto je posiada,
- ale bez wymuszania lokalnego hasla dla kont social-only.

## 5. Model dla kont social

### 5.1 Google / Facebook / Steam

Konto utworzone przez providera social ma byc pelnoprawnym kontem globalnym.

To oznacza:

- nie moze byc gorzej traktowane niz konto `email + haslo`,
- nie moze byc blokowane na akcjach tylko dlatego, ze nie ma lokalnego hasla,
- musi miec czytelny stan linked providers w panelu konta.

### 5.2 Lokalnie ustawione haslo

Lokalne haslo dla konta social ma byc opcjonalne.

Nie wymuszamy go do:

- logowania przez providera,
- zalozenia globalnej gildii,
- podstawowego zarzadzania gildiami.

Mozemy je dopuscic jako opcjonalny fallback do:

- odzyskiwania konta,
- re-autoryzacji czesci akcji wysokiego ryzyka,
- wejscia awaryjnego, jesli provider jest chwilowo niedostepny.

### 5.3 Linked providers

Panel konta `RedDAXE` powinien finalnie pokazywac:

- czy konto ma podpite `Google`,
- czy konto ma podpite `Facebook`,
- czy konto ma podpite `Steam`,
- ktory provider jest `primary`,
- czy konto ma lokalne haslo,
- czy mozna bezpiecznie odpiac dany provider.

## 6. Zabezpieczenia wymagane przed usunieciem hasla z guild-found

Minimalny pakiet zabezpieczen v1:

1. `CSRF token` dla formularza `guild-found.php`.
2. Walidacja sesji po stronie backendu bez zaufania do danych z frontu.
3. Serwerowa walidacja:
   - konto jest zalogowane,
   - wybrana postac nalezy do konta,
   - postac nalezy do wybranego swiata,
   - postac spelnia lokalne wymagania,
   - nazwa gildii przechodzi walidacje lokalna i globalna.
4. Audit log akcji `guild_found_submit`.
5. Rate limit:
   - per konto,
   - per IP,
   - z krotszym oknem dla porazek.
6. Czytelny komunikat `i18n`, ze operacja zostanie wykonana na aktualnie zalogowanym koncie.
7. Brak twardej zaleznosci od lokalnego hasla.

## 7. Step-up auth - ale tylko tam, gdzie ma sens

`Step-up auth` nie jest odrzucany, tylko przesuwany na odpowiedni zakres.

Powinien trafic dopiero do:

- `transfer owner`,
- unlink providera,
- zmiana danych konta,
- akcje bezpowrotnie zmieniajace ownership lub metode logowania.

Mozliwe warianty:

### 7.1 Session freshness

Najprostszy model:

- jesli sesja jest mlodsza niz np. `10-15 min`, akcja przechodzi,
- jesli jest starsza, system prosi o dodatkowe potwierdzenie.

Plus:

- dziala dla lokalnych i social kont.

### 7.2 Provider-aware reauth

Mocniejszy model docelowy:

- konto lokalne -> potwierdza lokalnym haslem lub TOTP,
- konto `Google` -> przechodzi przez reauth Google,
- konto `Facebook` -> przechodzi przez reauth Facebook,
- konto `Steam` -> przechodzi przez ponowne OpenID / session confirm.

To jest poprawne architektonicznie, ale nie jest szybkim zadaniem.

## 8. Moduly / biblioteki

Mozna korzystac z darmowych modulow, ale z jasna polityka:

- najpierw reuse tego, co juz macie w `oauth-start.php` i `oauth-callback.php`,
- nie wymieniac dzialajacego backendu OAuth tylko dlatego, ze istnieje biblioteka,
- biblioteke dokladac tylko tam, gdzie realnie obniza ryzyko lub koszt utrzymania,
- preferowac biblioteki:
  - aktywnie utrzymywane,
  - z licencja zgodna z projektem,
  - lekkie,
  - bez wymuszania pelnej przebudowy obecnego flow.

Rekomendacja:

- v1: wykorzystac obecny backend i dopiac polityke sesji / CSRF / audit / rate limit,
- v2: dopiero wtedy ocenic, czy potrzebna jest dodatkowa biblioteka do `step-up auth`.

## 9. Fazy wdrozenia

### Faza 0 - audit i decyzje

- spisac wszystkie akcje wrazliwe na `RedDAXE`,
- przypisac je do poziomu `A / B / C`,
- potwierdzic polityke:
  - `guild-found` bez hasla,
  - `transfer owner` jako kandydat do mocniejszego auth,
  - social-only accounts bez wymogu lokalnego hasla.

### Faza 1 - guild-found bez hasla

- usunac pole hasla z `guild-found.php`,
- dodac `CSRF`,
- dodac audit log,
- dodac rate limit,
- dodac `i18n` copy pod sesje / ownership,
- przetestowac konta:
  - lokalne,
  - `Google-only`,
  - `Facebook-only`,
  - `Steam-only`,
  - konta z providerem + lokalnym haslem.

### Faza 2 - panel konta social

- pokazac linked providers w `RedDAXE`,
- pokazac czy konto ma lokalne haslo,
- dodac akcje:
  - link provider,
  - unlink provider,
  - ustaw lokalne haslo,
  - ustaw / zmien podstawowa metode logowania,
- wszystkie teksty tylko przez `i18n`.

### Faza 3 - ochrona akcji poziomu C

- zaprojektowac `session freshness` albo provider-aware `step-up`,
- podpiac to pod:
  - `transfer owner`,
  - unlink ostatniego providera,
  - zmiane e-maila,
  - zmiane hasla.

### Faza 4 - QA i rollout

- smoke testy PL / EN,
- matrix kont:
  - local-only,
  - google-only,
  - facebook-only,
  - steam-only,
  - linked mixed,
- testy CSRF,
- testy sesji wygaslej / odswiezonej,
- testy callbackow social po `127.0.0.1`, domenie lokalnej i docelowej domenie produkcyjnej.

## 10. Taski do wykonania

- [ ] Wydzielic liste akcji `RedDAXE` poziomu `A / B / C`.
- [ ] Usunac haslo z `guild-found.php`.
- [ ] Dodac `CSRF` do `guild-found.php`.
- [ ] Dodac audit log dla `guild_found_submit`.
- [ ] Dodac rate limit dla `guild_found_submit`.
- [ ] Dopic `i18n` copy pod sesje zamiast hasla.
- [ ] Spisac stan linked providers w panelu konta.
- [ ] Dodac UI `Google / Facebook / Steam` w `RedDAXE`, jesli nie jest jeszcze wyeksponowane.
- [ ] Dopic bezpieczny unlink providera.
- [ ] Dopic opcjonalne ustawienie lokalnego hasla dla kont social.
- [ ] Zaprojektowac polityke `step-up auth` dla akcji poziomu `C`.
- [ ] Zrobic matrix testow kont lokalnych i social.

## 11. Wplyw na plan globalnych gildii

Wazna decyzja domenowa:

- `global guild registry` nie moze zakladac istnienia lokalnego hasla konta,
- `RedDAXE` ma wspierac zalozenie globalnej gildii tak samo dla kont lokalnych i social,
- polityka auth dla akcji gildii musi byc zgodna z przyszlym modelem `Google / Facebook / Steam`.

Dlatego temat zostaje formalnie wydzielony do osobnego planu i nie powinien byc rozwijany ad hoc przy samych taskach gildii.
