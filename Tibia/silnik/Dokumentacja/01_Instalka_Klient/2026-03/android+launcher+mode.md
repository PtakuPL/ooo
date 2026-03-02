# Android + Launcher + Mode (Android First)
**Data:** 2026-03-02  
**Zakres:** tylko Android (Windows/Linux w kolejnym kroku)  
**Cel:** gracz instaluje launcher/apkę Android, która pobiera wymagane pliki i blokuje start/logowanie bez API.

---

## 1. Cel biznesowy (Android)

1. Gracz instaluje jedną apkę (launcher Android).
2. Aplikacja przed uruchomieniem gry:
- sprawdza API,
- pobiera/aktualizuje pliki klienta,
- pobiera launch-token,
- dopiero potem uruchamia klienta.
3. Gdy API jest niedostępne: aplikacja ma tryb blokady (brak wejścia do gry).
4. Logowanie pozostaje zgodne z ticket-gate (HMAC).

---

## 2. Co już działa, a co nie (stan obecny)

## 2.1 Działa

1. API launcherowe istnieje (`update.php`, `launcher-token.php`, `launcher-version.php`).
2. Ticket flow działa architektonicznie (`login.php` -> `ticket.php` -> Canary validator).
3. Klient ma lock mode i tryby gry (`CLIENT_LOCKED`, `GameModes`).
4. TLS hard-fail jest ustawiony w `httplogin.cpp`.

## 2.2 Luki krytyczne dla Androida

1. `gameMode` nie jest wysyłany przez C++ body logowania (`httpLogin`), co rozwala spójność session/ticket dla `classic74`.
2. `launchToken` jest czytany tylko z env (`OTC_LAUNCH_TOKEN`), a na Androidzie nie ma desktopowego launchera env.
3. Brakuje Android bootstrap flow (preflight API + update + token + blokada offline).
4. Brakuje gotowego pipeline tworzenia `data.zip` dla Android assets (w repo jest placeholder).
5. Android unzip ma błąd pamięci (`malloc` + `delete[]`) i brak checka na brak `data.zip`.
6. W `init.lua` nadal są placeholdery hostów (`ZMIEN_NA_ADRES...`).
7. Walidacja world-mode jest niespójna (worldName/string), powinna być worldId/mapping.

---

## 3. Ważna decyzja architektoniczna (Android)

Android nie powinien aktualizować natywnej biblioteki gry (`libotclient.so`) poza aktualizacją APK.  
Android launcher powinien aktualizować tylko dane i skrypty (pakiet gry), a nie samą binarkę aplikacji.

Praktyczny model:
1. APK zawiera minimalny bootstrap + natywny client.
2. Przy starcie pobierany jest manifest i paczka danych.
3. Dane trafiają do `internal storage` (`/data/data/<package>/files/...`).
4. Klient działa na zaktualizowanych danych.
5. Aktualizacja samej aplikacji (APK) osobnym kanałem (nowa wersja APK).

---

## 4. Docelowy flow Android (blokada bez API)

1. Start aplikacji Android.
2. Ekran bootstrap (progress + retry).
3. `GET /api/launcher-version.php`
4. `GET /api/update.php?channel=stable`
5. Download brakujących/zmienionych plików + hash verify.
6. Obliczenie `filesHash` lokalnych plików.
7. `POST /api/launcher-token.php` -> `launchToken`.
8. Przekazanie tokenu do klienta (nie przez env).
9. Start klienta.
10. Login:
- `POST /api/login.php` (z `gameMode` + `launchToken`)
- `POST /api/ticket.php`
- connect do Canary z ticketem HMAC.

Jeśli krok 3-7 nie przejdzie: brak możliwości wejścia do gry.

---

## 5. Zmiany obowiązkowe (P0)

## 5.1 C++/Lua (klient)

1. Dodać `gameMode` do JSON body logowania w `LoginHttp`:
- `httplogin.h/.cpp`: rozszerzyć sygnatury `httpLogin`, `loginHttpsJson`, `loginHttpJson`.
- `luafunctions.cpp`: binding nowego parametru.
- `entergame.lua`: przekazywać `CurrentGameMode` do `http:httpLogin(...)`.

2. Usunąć zależność Android od env tokenu:
- dodać API setter tokenu w runtime (Lua/C++) bez env.
- token ustawiany przez Android bootstrap przed loginem.

3. Naprawić składanie URL login path w `entergame.lua`:
- usunąć przypadek `//login.php`.

4. Utrzymać lock mode:
- `CLIENT_LOCKED=true` dla produkcyjnej apki Android.
- jeśli brak tokenu lub API niedostępne -> brak logowania.

## 5.2 PHP/API

1. `login.php`:
- wymaga `launchToken` przy `CLIENT_LOCKED=true` (już jest),
- oczekuje `gameMode` i zapisuje go w sesji.

2. `ticket.php`:
- walidacja world względem gameMode (mapowanie po `worldId`, nie tylko string `worldName`),
- odrzucenie niespójnych par world/mode.

3. Ujednolicić kontrakt world:
- klient wysyła `worldId`,
- ticket zawiera `worldId`,
- Canary waliduje `worldId` serwera.

## 5.3 Android (Kotlin + native bootstrap)

1. Dodać `LauncherActivity`/`BootstrapManager`:
- preflight API,
- update danych,
- hash verify,
- pobranie `launchToken`,
- uruchomienie `MainActivity`/native.

2. Zaimplementować twardą blokadę offline:
- brak API = ekran błędu + Retry,
- brak ścieżki "graj offline".

3. Przechowywać token i metadata bezpiecznie:
- token krótkotrwały (TTL),
- nie logować tokenów.

4. Spiąć bootstrap z C++ klientem:
- JNI/Lua bridge do ustawienia `G.launchToken` przed logowaniem.

## 5.4 Android assets/package

1. Dodać faktyczny skrypt tworzenia `data.zip` (PowerShell/Bash).
2. Dodać check w CI, że `data.zip` istnieje przed build APK.
3. Upewnić się, że `cacert.pem` jest obecny w runtime data.
4. Naprawić `AndroidManager::unZipAssetData()`:
- `free()` zamiast `delete[]` dla bufora z `malloc`,
- check `AAssetManager_open(...) == nullptr`,
- bezpieczne logowanie błędu i fail-closed.

---

## 6. Zmiany ważne (P1)

1. API listy serwerów dla Android lock mode:
- endpoint `servers.php` albo sekcja w manifeście,
- bootstrap aktualizuje listę serwerów dynamicznie.

2. Rollback manifestu:
- akceptacja current + previous version.

3. Lepsza odporność download:
- resume/retry per plik,
- atomowy swap temp -> final.

4. Telemetria techniczna:
- błędy bootstrap, hash mismatch, brak API, timeouty.

---

## 7. Zmiany opcjonalne (P2, hardening)

1. Device attestation (Play Integrity/SafetyNet) dla Android token flow.
2. Certificate pinning (defense-in-depth).
3. Podpis manifestu (server-side signature verify po stronie klienta).

---

## 8. Plan testów Android (must-have)

1. Brak internetu przy starcie -> bootstrap block screen.
2. API 500/timeout -> block + retry działa.
3. Niepoprawny TLS cert -> hard fail.
4. Uszkodzony plik lokalny -> redownload + poprawny hash.
5. Brak tokenu -> login odrzucony.
6. Token expired -> login odrzucony, ponowne pobranie tokenu działa.
7. `classic74`:
- login.php zapisuje `gameMode=classic74`,
- ticket.php nie odrzuca poprawnego wyboru,
- Canary wpuszcza tylko poprawny świat/tryb.
8. `modern`: analogicznie.
9. Próba wejścia bez API po wcześniejszym starcie -> blokada.

---

## 9. Definicja "Android GOTOWE"

Android uznajemy za gotowy, gdy:
1. APK uruchamia bootstrap i nie wpuszcza do gry bez API.
2. `gameMode` jest wysyłany i zachowany end-to-end.
3. launchToken działa na Androidzie bez env.
4. ticket-gate przechodzi dla `classic74` i `modern`.
5. data update + hash verify działa na czystej instalacji i po aktualizacji.
6. CI buduje APK + ma smoke test bootstrap/login/ticket.
7. i18n/Unicode działa na Androidzie dla LTR+RTL+CJK (bez braków glyphów w krytycznych ekranach).

---

## 10. Minimalna kolejność wdrożenia (Android-only)

1. P0: `gameMode` w C++/Lua login body.
2. P0: Android bootstrap + token injection bez env.
3. P0: blokada offline (fail-closed przed uruchomieniem gry).
4. P0: fixy Android assets + unzip + `cacert.pem`.
5. P0: worldId/gameMode spójność w `ticket.php` + Canary validator.
6. P1: dynamiczna lista serwerów z API.
7. P1: retry/rollback/telemetria.
8. P2: attestation/pinning/podpis manifestu.
9. P0: domknięcie i18n runtime (`setLocaleTag` + czyszczenie cache glyphów po zmianie języka).
10. P0/P1: pełne pakowanie fontów/locale/i18n do `data.zip` + test matrix RTL/CJK.

---

## 11. Uwaga o Windows/Linux (poza zakresem tego dokumentu)

Docelowy wspólny model launcherowy dla Windows/Linux/Android jest dobry kierunkowo, ale Android wymaga osobnego bootstrap flow i nie może być traktowany identycznie jak desktop `.exe`.

---

## 12. Android i18n + Unicode + Glyph (zakres rozszerzony)

Cel i18n dla Androida:
1. Jeden APK + bootstrap musi poprawnie wyświetlać teksty świata (Latin, Cyrylica, Greka, CJK, RTL).
2. Zmiana języka w runtime nie może zostawiać starych atlasów glyphów.
3. Brak API nadal blokuje wejście do gry, ale nie może psuć lokalnych zasobów i18n UI bootstrapa.

---

## 13. Stan obecny i18n (na bazie kodu)

1. CMake ma text stack ON:
- `OTC_ENABLE_TTF=ON`
- `OTC_ENABLE_HARFBUZZ=ON`
- `OTC_ENABLE_FRIBIDI=ON`

2. Pipeline tekstu istnieje:
- FreeType -> HarfBuzz -> FriBidi -> render.

3. Zasoby fontów są szerokie (`data/fonts/ttf`, wiele Noto fallback dla różnych skryptów).

4. Mapa locale/BCP47/RTL istnieje:
- `data/i18n/locales.otml` (ma wpisy RTL, m.in. arabskie/hebrew/farsi).

5. Moduł locale istnieje (`modules/client_locales/locales.lua`) i przełącza język w runtime.

6. Luki wymagające domknięcia:
- W Android assets nadal jest placeholder (`android/app/src/main/assets/put_data_zip_here.txt`) i brak gotowego `data.zip`.
- W `locales.lua` są wywołania `g_fonts.setLocaleTag` i `g_fonts.clearGlyphCaches`, a w Lua binding jest tylko `g_fonts.clearAllFontCaches` (niespójny kontrakt runtime).
- W `data/locales` bazowe pliki językowe to obecnie głównie `en.lua`, `pl.lua`, `ja.lua`; większość innych to `game_i18n_*_compact.lua`, więc pełna lista języków wymaga świadomego domknięcia.
- `locales.lua` woła `dofile 'i18n_layout'`, a plik nie jest widoczny w repo (ryzyko błędu runtime/pakowania).

---

## 14. Zmiany obowiązkowe i18n dla Android (P0/P1)

## 14.1 P0 - build/runtime correctness

1. Wymusić text stack w buildzie Android release:
- build ma failować, jeśli HarfBuzz/FriBidi/TTF zostaną wyłączone przez brak dependency.

2. Naprawić kontrakt Lua<->C++ dla zmiany locale:
- albo dodać bindingi `setLocaleTag` + `clearGlyphCaches`,
- albo zmienić `locales.lua`, by używał realnie istniejących API (`clearAllFontCaches` + setter LocaleShaping).

3. Domknąć `i18n_layout`:
- dostarczyć plik i spakować go,
- albo usunąć `dofile` i zostawić bezpieczny fallback.

4. Domknąć launcher data package:
- `data.zip` musi zawierać komplet i18n/fontów (patrz sekcja 15),
- bootstrap ma fail-closed, jeśli paczka i18n nie przejdzie hash verify.

## 14.2 P1 - coverage quality

1. Zdecydować docelową listę wspieranych języków na Android:
- jeśli "wszystkie litery świata" ma być realnym SLA, trzeba utrzymać bazowe locale files i testy dla każdej grupy skryptów.

2. Ustalić politykę fallback glyphów:
- kolejność fontów fallback per skrypt (Arab, CJK, Deva, Thai itd.),
- jawny fallback marker/log, gdy glyph nie istnieje.

3. Ograniczyć rozmiar paczki:
- opcjonalne warianty (full fonts vs region packs), ale bez łamania minimalnego coverage Unicode.

---

## 15. Co MUSI wejść do Android `data.zip` (i18n)

1. `data/fonts/**` (w tym `data/fonts/ttf/**` i `.otfont` konfiguracje fallback).
2. `data/locales/**` (bazowe locale + `game_i18n_*` + compact dictionaries).
3. `data/i18n/locales.otml` (tag/script/dir).
4. `modules/client_locales/**` (UI i logika wyboru języka).
5. Wszystkie pliki wymagane przez `dofile(...)` z modułów locale (w tym `i18n_layout`, jeśli ma zostać).
6. `cacert.pem` (TLS), żeby bootstrap/API działał bez obchodzenia zabezpieczeń.

---

## 16. Android i18n test matrix (must-have)

1. PL: `zażółć gęślą jaźń` w login/chat/UI.
2. TR: `I/İ/ı/i` (case i diakrytyki).
3. RU/UA: Cyrylica w chat/NPC/system message.
4. EL: Greka.
5. AR + HE + FA: RTL (w tym mieszany tekst z cyframi i znakami LTR).
6. HI/BN/TA/TE: Indic shaping (łączenia znaków).
7. TH: Thai shaping.
8. ZH/JA/KO: CJK fallback i brak tofu glyphów.
9. Runtime switch locale (`en -> ar -> ja -> pl`) bez restartu i bez artefaktów cache.
10. Wymuszone brakujące fonty: klient ma dać kontrolowany fallback/log, nie crash.
11. Czysta instalacja Android: po bootstrap wszystkie testy 1-9 przechodzą.
12. Aktualizacja z poprzedniej wersji: testy 1-9 nadal przechodzą po migracji paczki danych.

---

## 17. Definicja "Android GOTOWE + i18n"

Poza sekcją 9, dodajemy warunek:
1. Test matrix z sekcji 16 przechodzi na przynajmniej 1 urządzeniu ARM64 + 1 emulatorze Android.
2. CI ma automatyczny check obecności plików i18n/fontów w `data.zip`.
3. Build Android release failuje, jeśli text stack (TTF/HarfBuzz/FriBidi) jest zdegradowany.

---

## 18. Pliki referencyjne (repo)

1. `canary_test/testyy/CMakeLists.txt` (OTC_ENABLE_TTF/HARFBUZZ/FRIBIDI).
2. `canary_test/testyy/modules/client_locales/locales.lua` (runtime locale switch + ładowanie `game_i18n_*`).
3. `canary_test/testyy/src/framework/luafunctions.cpp` (aktualne bindingi `g_fonts`).
4. `canary_test/testyy/src/framework/text/LocaleShaping.cpp` (tagi locale, script/direction).
5. `canary_test/testyy/data/i18n/locales.otml` (mapowanie locale + RTL/LTR).
6. `canary_test/testyy/data/fonts/noto-12.otfont` i `canary_test/testyy/data/fonts/ttf/*` (fallback glyphów).
7. `canary_test/testyy/src/framework/platform/androidmanager.cpp` (unzip `data.zip` na Androidzie).
8. `canary_test/testyy/android/app/src/main/assets/put_data_zip_here.txt` (placeholder assets).
9. `canary_test/testyy/docs/BUILD_GUIDE.md` (wzmianka o `create_android_assets.ps1`).
10. `canary_test/testyy/docs/FAZA_5_TESTY_MANUALNE.md` (manualne testy Unicode/RTL).

---

## 19. 3 ryzyka krytyczne - plan naprawczy krok po kroku

## 19.1 Ryzyko A: brak gotowego `data.zip` dla Android

Problem:
- launcher/klient Android nie ma kompletnej paczki assets, więc bootstrap i i18n nie są deterministyczne.

Kroki:
1. Dodać skrypt budowania assets: `canary_test/testyy/create_android_assets.sh` (oraz opcjonalnie `.ps1`).
2. Skrypt ma pakować minimum: `data/`, `modules/`, `mods/`, `init.lua`, `cacert.pem`.
3. Skrypt ma wykluczać pliki śmieciowe (`*.bak`, `*.tmp`, `docs/`, archiwa robocze).
4. Wynik skryptu: `canary_test/testyy/android/app/src/main/assets/data.zip`.
5. Dodać walidację ZIP po zbudowaniu:
- `data/i18n/locales.otml`,
- `data/fonts/ttf/*`,
- `data/locales/*`,
- `modules/client_locales/locales.lua`.
6. Dodać krok CI: build fail, jeśli `data.zip` nie istnieje albo nie zawiera wymaganych ścieżek.
7. W Android runtime zostawić tryb fail-closed: brak/korupcja `data.zip` = brak przejścia do gry.

Kryterium DONE:
1. `data.zip` powstaje automatycznie i ląduje w `android/app/src/main/assets/`.
2. CI potwierdza obecność krytycznych plików i18n/fontów.
3. Czysta instalacja Android przechodzi bootstrap bez ręcznego kopiowania plików.

## 19.2 Ryzyko B: niespójny kontrakt locale runtime (`locales.lua` vs `g_fonts`)

Problem:
- Lua woła `g_fonts.setLocaleTag` i `g_fonts.clearGlyphCaches`, a aktualne bindingi nie gwarantują tych metod.

Kroki:
1. Ujednolicić API C++/Lua (jedna wersja kontraktu).
2. W C++ dodać/udostępnić:
- `setLocaleTag(tag)` -> ustawia domyślny tag w `LocaleShaping`,
- `clearGlyphCaches()` -> alias do `clearAllFontCaches()`.
3. Dodać bindingi w `src/framework/luafunctions.cpp` dla obu metod.
4. W `modules/client_locales/locales.lua` zostawić tylko metody, które istnieją w bindingu (bez warunków maskujących brak API).
5. Dodać log diagnostyczny przy zmianie locale: `oldLocale -> newLocale`, `localeTag`, `cacheCleared=true`.
6. Wykonać test runtime na Android: `en -> ar -> ja -> pl` bez restartu i bez artefaktów.

Kryterium DONE:
1. Przełączanie języka działa stabilnie na Androidzie.
2. Brak brakujących metod Lua w logach.
3. Zmiana locale odświeża shaping/glyph cache w 100% przypadków.

## 19.3 Ryzyko C: `dofile 'i18n_layout'` bez pliku

Problem:
- moduł locales może wysypać się na starcie, jeśli plik nie istnieje w paczce.

Kroki:
1. Dodać plik `canary_test/testyy/modules/client_locales/i18n_layout.lua` z minimalnym no-op API:
- `i18nLayout.init()`,
- `i18nLayout.terminate()`.
2. Zmienić ładowanie na bezpieczne:
- `pcall(dofile, 'i18n_layout')` + warning, bez crash.
3. Dodać test startu aplikacji bez tego pliku (symulacja) - moduł ma przejść w fallback mode.
4. Dodać `i18n_layout.lua` do obowiązkowej listy plików walidowanych w kroku budowy `data.zip`.
5. Dodać test regresji: `client_locales` ładuje się poprawnie na czystej instalacji Android.

Kryterium DONE:
1. Brak crasha modułu locales przy starcie.
2. `i18n_layout` działa (lub bezpiecznie fallbackuje) na każdej instalacji.
3. CI wykrywa brak pliku przed publikacją APK.
