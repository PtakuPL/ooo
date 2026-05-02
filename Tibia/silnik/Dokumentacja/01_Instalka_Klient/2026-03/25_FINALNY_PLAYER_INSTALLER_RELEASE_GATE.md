# Finalny player installer Windows/Linux - release gate

Data: 2026-05-02
Status: aktywny gate decyzyjny
Zakres: bootstrap -> launcher -> client pack -> start gry jako zwykly gracz

## 0. Aktualizacja 2026-05-02 — sealed player + fail-closed live API

Dzisiejsza runda domknela najwazniejsze zabezpieczenia przed uruchomieniem GHA:

- workflow client package buduje OTClient z `-DOTCLIENT_PLAYER_BUILD=ON` i sprawdza `OTCLIENT_PLAYER_BUILD:BOOL=ON` w `CMakeCache.txt`,
- natywny `ConfigManager` w sealed buildzie ignoruje `OTC_DEV_MODE`, wymusza `devMode=false` i `clientLocked=true`,
- `verify-player-package.sh` jest wspolnym gate dla GHA i deployu paczki gracza,
- deploy klienta idzie przez staging, verification i rollback,
- live/repo `generate_manifest.php`, `update.php`, `launcher-token.php` blokuja dirty manifesty,
- launcher Rust czysci odziedziczone `OTC_*` przed ustawieniem swiezego launch-contextu.

Stan live jest celowo zamkniety dla starej paczki: obecny runtime jest brudny, wiec publiczny `update.php?channel=stable` oraz `launcher-token.php` zwracaja `503` do czasu deployu czystego client bundle z GHA.

## 1. Odpowiedz krotka

Nie oznaczamy jeszcze obecnej paczki `otclient-windows-x64-1.2.0.zip` jako finalnej chronionej instalki gracza.

Obecny projekt ma juz fundamenty:
- launcher pobiera i aktualizuje klienta,
- release launchera produkuje ZIP-y instalacyjne dla bootstrapa,
- API katalog rozroznia ZIP launchera dla bootstrapa (`LAUNCHER_PACKAGE_*`) od surowej binarki self-update (`LAUNCHER_DOWNLOAD_URL*`),
- launcher uruchamia `otclient.exe` / `otclient` z `OTC_LAUNCH_TOKEN`, `OTC_SESSION_TOKEN`, `OTC_CHANNEL`, opcjonalnie `OTC_GAME_MODE`,
- klient w player mode pokazuje blokade, gdy nie ma kontekstu launchera,
- API `login.php` przy `CLIENT_LOCKED=true` wymaga jednorazowego launch tokenu,
- `launcher-token.php` sprawdza `filesHash`, `manifestVersion`, kanal i TTL tokenu,
- klient ma ticket-gate przed polaczeniem z game serverem.

To jest warstwowy anti-tamper i kontrola oficjalnego flow, nie pelny DRM. Nie uzywamy okreslenia "maksymalne bezpieczenstwo" dla desktopowego klienta, bo uzytkownik kontroluje swoje urzadzenie i proces klienta.

Nie jest jeszcze domkniete:
- ukrycie wrazliwych Lua/i18n/modyfikacji przed graczem,
- protected resource layer (`*.otpkg` / `*.otpkg.enc` albo rownowazny mechanizm),
- pelny release smoke na swiezym Windows/Linux artefakcie pobranym przez launcher,
- smoke Unicode finalnej paczki: arabski RTL, japonski, chinski SC/TC, koreanski i inne skrypty azjatyckie,
- server-side hardening dla WWW/API/game server/DB,
- staging VPS/dedyk z prawdziwym HTTPS, DB, manifestami i serwerem gry.

## 2. Co znaczy finalna instalka gracza

Finalny flow gracza:

```text
WWW -> bootstrap -> launcher -> pobranie/naprawa client packa -> login/account context -> launch token -> otclient -> ticket -> game server
```

Wymagania finalne:
- publiczny download na WWW prowadzi do bootstrapa albo launchera, nie do surowego ZIP-a klienta,
- launcher instaluje klienta do `client/`, aktualizuje go z manifestu i sprawdza integralnosc,
- `otclient.exe` / `otclient` w profilu player nie laczy sie bez oficjalnego launchera,
- backend odrzuca login bez launch tokenu,
- backend odrzuca klienta z nieznanym lub zmienionym `filesHash`,
- game server odrzuca wejscie bez poprawnego ticketu,
- wrazliwa logika gry pozostaje po stronie serwera,
- warstwa protected klienta nie jest publikowana jako zwykle plaintext pliki w paczce gracza.

## 2.1 Model bezpieczenstwa i ograniczenia

Nie zakladamy, ze desktopowy klient jest nie do obejscia. Zakladamy warstwy:

| Warstwa | Co daje | Czego nie daje |
|---|---|---|
| `OTC_LAUNCH_TOKEN` + `CLIENT_LOCKED` | Blokuje zwykly direct launch i wymusza oficjalny flow launchera. | Nie zatrzymuje osoby debugujacej proces i kopiujacej token/runtime context. |
| `filesHash` + manifest | Wykrywa zwykle modyfikacje katalogu klienta i nieznane wersje. | Nie jest ochrona przed patchowaniem pamieci procesu. |
| Ticket przed game serverem | Serwer gry nie przyjmuje zwyklego wejscia bez ticketu. | Ticket tez istnieje w runtime, wiec musi miec krotki TTL i byc jednorazowy. |
| Protected packages | Utrudnia casualowe kopiowanie Lua/i18n/modow z dysku. | To obfuskacja/asset-pack hardening, nie pelna ochrona IP; po zaladowaniu Lua istnieje w pamieci. |
| Server-side logic | Realnie chroni walke, loot, eventy, ekonomie i anty-cheat checks. | Wymaga dobrego monitoringu, rate-limitow i backupow. |

Dalsze wzmocnienia po release candidate:
- TLS hard-fail i cert/public-key pinning w launcherze oraz kliencie tam, gdzie ma to sens operacyjny,
- krotkozyjace tokeny z nonce/challenge binding,
- podpisywanie binarek: Authenticode na Windows, podpis/checksum artefaktow na Linux,
- release manifest podpisany kluczem, ktorego prywatna czesc nie trafia do repo,
- brak sekretow w kliencie i trzymanie krytycznej logiki wyłącznie po stronie serwera.

## 3. Status mechanizmow

| Obszar | Status | Uwagi |
|---|---|---|
| GHA Windows/Linux client pack | CODE DONE / GHA PENDING | Workflow ma `OTCLIENT_PLAYER_BUILD=ON`, CMakeCache gate i `verify-player-package.sh`; run po tej rundzie jeszcze nie byl odpalony. |
| Launcher startuje klienta | CODE DONE | `launch_game` przekazuje tokeny przez env, a process runner czysci odziedziczone `OTC_*`. |
| Blokada direct launch w UI klienta | CODE DONE | Player mode bez launch tokenu pokazuje ekran "uruchom przez launcher". |
| Native sealed player policy | CODE DONE / GHA PENDING | `OTCLIENT_PLAYER_BUILD` wymusza locked runtime niezaleznie od `OTC_DEV_MODE`; wymaga potwierdzenia w artefakcie GHA. |
| API wymusza launch token | CODE DONE | `login.php` fail-closed przy `CLIENT_LOCKED=true`, poza freshInstall/source=web. |
| `launcher-token.php` filesHash gate | CODE DONE | Sprawdza manifest/kanal/hash, odrzuca brak aktywnego manifestu i od 2026-05-02 blokuje dirty manifest `503 manifest_blocked`. |
| `update.php` dirty manifest gate | CODE DONE / LIVE ACTIVE | Obecny dirty stable manifest zwraca `503` do czasu czystego deployu. |
| Package verifier | CODE DONE | `verify-player-package.sh` sprawdza executable, init native lock, allowlist/denylist i sekrety. |
| Ticket przed game serverem | CODE DONE | Klient prosi o ticket i laczy z nim. |
| Unicode Arabic/CJK final smoke | IN_PROGRESS / SMOKE PENDING | Fallbacki `.otfont` rozszerzone i verifier wymaga kluczowych Noto fontow; wymagany test finalnej paczki przed publicznym release i Androidem. |
| Protected Lua/i18n/mods | TODO P0 | Wymaga przeniesienia wrazliwych zasobow do protected package. |
| Server-side hardening | TODO P0 | Rate limit, firewall, backupy, monitoring i separacja uslug przed publicznym testem. |
| Release deploy na VPS | TODO P0 | Wymaga docelowego hostingu, HTTPS, DB, manifestow i smoke testu. |
| Android installer/launcher | FUTURE P1/P2 | Jest workflow APK, ale nie ma jeszcze pelnego modelu dystrybucji jak desktop. |

## 4. P0 przed publikacja dla gracza

1. Zbudowac finalny client pack w GHA na kanale `stable`; build musi przejsc `OTCLIENT_PLAYER_BUILD:BOOL=ON` oraz `verify-player-package.sh` dla Windows/Linux.
2. Zbudowac pelny launcher release w GHA i wdrozyc ZIP-y dla bootstrapa:
   - `launcher-tauri-windows-x86_64.zip`,
   - `launcher-tauri-linux-x86_64.zip`,
   - `canary_test/html_copy/apik/v1/deploy_launcher.sh <version> <win.zip> <linux.zip>`.
3. Wgrac client pack Windows+Linux przez `canary_test/testyy/tools/deploy-player-client-bundle.sh <win.zip> <linux.tar.gz> <version> stable`, wygenerowac manifest i wpis w `manifest_versions`.
4. Ustawic `.env` API dla staging/prod:
   - `CLIENT_LOCKED=true`,
   - `LAUNCHER_MIN_VERSION`,
   - `LAUNCH_TOKEN_TTL`,
   - `LAUNCHER_PACKAGE_URL_WIN/LINUX`,
   - `LAUNCHER_PACKAGE_SHA256_WIN/LINUX`,
   - `LAUNCHER_PACKAGE_SIZE_WIN/LINUX`,
   - `CLIENT_PACK_VERSION`,
   - `CLIENT_PACK_DOWNLOAD_URL_WIN/LINUX`,
   - `CLIENT_PACK_SHA256_WIN/LINUX`,
   - `CLIENT_PACK_SIZE_WIN/LINUX`,
   - `CLIENT_PACK_MANIFEST_URL_WIN/LINUX`,
   - manifest/version hash zgodny z paczka.
5. Podpiac `installer-catalog.php` dla bootstrapa, launchera i client packa; katalog musi zwracac `url`, `sha256`, `size`, `channel`, `version`.
6. Zrobic smoke test jako zwykly gracz:
   - pobierz ze strony bootstrap,
   - zainstaluj launcher,
   - zaloguj konto,
   - launcher pobiera/naprawia klienta,
   - kliknij `Graj`,
   - klient dostaje `OTC_LAUNCH_TOKEN`,
   - postac laczy sie z serwerem,
   - uruchomienie samego `otclient.exe` bez launchera konczy sie blokada.
7. Zrobic test negatywny:
   - usun/zmien plik w `client/`,
   - launcher ma naprawic albo backend ma odrzucic `filesHash`,
   - stary launch token po TTL ma byc odrzucony.
8. Zrobic hard-gate trybow z `26_HANDOFF_CODEX_CLAUDE_FINAL_INSTALLER_INTEGRACJA.md`:
   - modern/normal ticket nie moze wejsc na Classic 7.4 (`worldId=0`),
   - classic ticket nie moze wejsc na Modern (`worldId=1`),
   - Classic 7.4 blokuje rune/item hotkeye i Smart Equip,
   - gracz po loginie w launcherze wybiera tryb w kliencie i nie wpisuje drugi raz loginu/hasla.
9. Zrobic Unicode smoke finalnej instalki:
   - `data/fonts/noto-12.otfont` i legacy `.otfont` musza ladowac fallbacki dla Arabic, Hebrew, Japanese, Chinese SC/TC, Korean, Thai/Devanagari co najmniej na krytycznych ekranach,
   - arabski musi renderowac bez kwadratow i z poprawnym RTL shapingiem,
   - japonski/chinski/koreanski nie moga pokazywac tofu/squares,
   - test wykonac na swiezym artefakcie GHA, nie na lokalnym dev runtime.
10. Zdecydowac zakres protected layer dla pierwszej publicznej wersji:
   - minimum: wrazliwe Lua/i18n/modyfikacje poza plaintext,
   - pragmatycznie: jawny bootstrap + protected packages,
   - docelowo: bez plaintext dla warstwy protected na dysku.
11. Domknac server-side hardening przed wpuszczeniem zewnetrznych graczy:
   - `nginx limit_req` / rate-limit na `login.php`, `launcher-token.php`, `ticket.php`, `installer-catalog.php`, rejestracje i sync-tokeny,
   - IP-throttling albo captcha na rejestracji i odzyskiwaniu konta,
   - firewall: publiczne tylko WWW/API i porty gry, DB tylko lokalnie/prywatnie,
   - osobne konta systemowe dla web/php-fpm, game servera i zadan deploy,
   - logrotate i alert na wzrost 4xx/5xx oraz bledy token/ticket,
   - automatyczny backup API DB i game DB przed testami graczy,
   - procedura rollbacku client packa i manifestu.

## 5. Android

Android traktujemy jako kolejny tor po desktop release candidate.

Aktualnie jest workflow budujacy APK, ale Android wymaga osobnej decyzji:
- czy launcher logic bedzie wbudowany w jedna aplikacje APK/AAB,
- jak robimy update assetow,
- jak robimy ticket/launch-session bez klasycznego desktopowego env var,
- czy uzywamy Play Integrity API / wlasnego attestation dla publicznych testow,
- jak podpisujemy APK/AAB i dystrybuujemy build testowy.
- czy ten sam gate Unicode/RTL/CJK przechodzi na Androidzie, gdzie font packaging i shaping moga zachowac sie inaczej niz desktop.

Nie mieszamy Androida z P0 desktop, bo desktop jest teraz najkrotsza droga do realnego testu gracza.

## 6. VPS / dedyk

Staging VPS mozna kupic przed protected layer, jesli celem jest wczesny test infrastruktury, runtime smoke i optymalizacja. To nie musi czekac na idealna paczke klienta, ale musi byc jasno oznaczone jako staging.

Produkcje/dedyk pod graczy kupujemy najlepiej w momencie, gdy mamy:
- zielony GHA dla client packa i launchera,
- gotowy bootstrap/launcher artifact,
- gotowy client pack `stable`,
- liste wymaganych domen, portow, certyfikatow i baz,
- plan migracji `.env` bez sekretow w repo.

Nie powinien to byc finalny produkcyjny serwer, dopoki protected layer, server-side hardening i release smoke nie przejda.

## 7. Decyzja na teraz

Nastepny krok techniczny:
- domknac desktop release candidate Windows/Linux,
- nie publikowac surowego ZIP-a klienta jako finalnej instalki,
- wdrozyc protected layer dla wrazliwych zasobow jako obfuskacje/asset-pack hardening,
- domknac server-side hardening,
- po zielonym GHA zrobic staging deploy i test end-to-end jako zwykly gracz.

## 8. Doprecyzowanie po pauzie usera — bootstrap nie jest przebudowywany logicznie (2026-05-02)

User slusznie doprecyzowal, ze obecny model ma juz dzialac tak:

```text
stary bootstrap -> installer-catalog.php?type=launcher -> aktualny pelny launcher ZIP
stary pelny launcher -> launcher-version.php/API -> aktualny pelny launcher
aktualny launcher -> update.php -> aktualny client pack
aktualny launcher -> launcher-token.php -> OTClient -> ticket -> game server
```

Dlatego bieżący zakres Codexa nie polega na wymyslaniu nowego bootstrap mechanizmu. Zakres jest operacyjny:

- upewnic sie, ze GHA release faktycznie produkuje artefakty, ktore API moze podac starym bootstrapom/launcherom,
- upewnic sie, ze `installer-catalog.php` ma komplet `url`, `sha256`, `size`, `version` dla `bootstrap`, `launcher` i `client`,
- upewnic sie, ze `build-client-package.yml` produkuje czysty player runtime, ktory nie blokuje `update.php`/`launcher-token.php`,
- potem wykonac smoke na starym bootstrapie/launcherze, a nie tylko na swiezo zbudowanej lokalnej paczce.

Zmiany odnotowane przed pauza:

- aktywny `.github/workflows/build-client-package.yml` zostal ustawiony pod player package GHA: `OTCLIENT_PLAYER_BUILD=ON`, `RelWithDebInfo`, CMakeCache gate, czyszczenie dev/operator files, trim locale, `verify-player-package.sh`,
- `.github/workflows/release-launcher.yml` zostal rozszerzony o publikacje binarek `launcher-bootstrap-*` w GitHub Release; to jest artefakt dla download/API, nie zmiana zachowania bootstrap runtime.

Decyzja operacyjna: przed kolejnymi zmianami w kodzie trzeba potwierdzic z userem, czy te workflow zmiany zostaja, a nastepnie odpalic GHA i testowac realny update chain:

```text
old bootstrap/old launcher -> API latest -> new launcher -> clean client pack -> launch token/ticket
```
