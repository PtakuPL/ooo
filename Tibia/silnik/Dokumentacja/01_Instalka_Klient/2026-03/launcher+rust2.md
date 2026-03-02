Dokładnie tak — to jest opisane w sekcji 5 planu jako Download Center. Ale rozjaśnijmy precyzyjnie co jest co, bo tu łatwo pomieszać trzy różne rzeczy:

Trzy różne byty
Byt	Co to jest	Kto go pobiera
Installer	Mały plik (~10-50 MB) — instaluje launcher na nowej maszynie	Użytkownik ręcznie (ze strony/Download Center)
Launcher	Główna apka (~5-20 MB) — zarządza grą	Installer go instaluje, potem launcher sam się aktualizuje
Klient gry (OTClient + dane)	Właściwa gra (~100-500 MB)	Launcher go pobiera i patchuje
Flow użytkownika
Weryfikacja integralności — tak, na dwóch poziomach
Poziom 1: Launcher → Klient gry
Efekt: Jeśli gracz podmieni pliki klienta, token zostanie odrzucony i nie wejdzie do gry.

Poziom 2: Download Center → Instalatory
Odpowiedź na Twoje pytanie
Tak — launcher będzie miał:

dostęp do katalogu instalatorów (Windows/Linux/Android) przez API
weryfikację SHA-256 pobranych instalatorów
weryfikację integralności klienta gry przy każdym uruchomieniu
token reject jeśli ktoś zmodyfikował pliki klienta
Instalatory nie są "w bazie danych" dosłownie — są na CDN/serwerze plików, a baza/API trzyma metadane (URL, hash, wersja). Launcher pyta API "co jest dostępne?" i wyświetla, potem pobiera i weryfikuje.


Przygotuję spójny plan architektury i wdrożenia launchera w Rust+Tauri, tak żeby pasował do Twojego modelu (wybór świata w kliencie) i do założeń z planu zabezpieczeń.

Myślał przez 54s

Tak — i to da się zrobić spójnie z Twoim planem zabezpieczeń bez psucia instalki, jeśli przyjmiemy właściwy podział ról:

Launcher (Rust+Tauri) = update + integralność + synchronizacja listy serwerów + uruchomienie klienta

Klient OTClient = UX gry (wybór trybu / świata / postaci, login flow, UI gry)

API + Canary = właściwe bezpieczeństwo (ticket-gate HMAC, walidacje, nonce, TTL)

To jest zgodne z Twoją architekturą warstw bezpieczeństwa i z opisem Fazy E w planie. 

plan_zabezpieczenia_klienta_i_s…

 

plan_zabezpieczenia_klienta_i_s…

Spójny plan projektu: pełnoprawny launcher Rust+Tauri + updater + integracja z ticket-gate
1) Założenia nadrzędne (żeby wszystko pasowało do planu)
1.1. Co zostaje po staremu (i powinno zostać)

W Twoim planie klient:

pokazuje listę serwerów,

blokuje ręczne dodawanie/edycję,

obsługuje tryb gry (Classic/Modern),

robi login / wybór postaci / wybór świata w ramach UI klienta. 

plan_zabezpieczenia_klienta_i_s…

 

plan_zabezpieczenia_klienta_i_s…

 

plan_zabezpieczenia_klienta_i_s…

To zostawiamy.
Nie dublujemy tego w launcherze.

1.2. Co przejmuje launcher (docelowo Rust+Tauri)

Zgodnie z Fazą E launcher ma:

sprawdzić wersję launchera,

pobrać manifest plików,

porównać hashe lokalne vs manifest,

pobrać różnice,

zweryfikować integralność,

pobrać launch-token,

uruchomić klienta z OTC_LAUNCH_TOKEN przez env (nie CLI). 

plan_zabezpieczenia_klienta_i_s…

1.3. Najważniejsza zasada bezpieczeństwa (bez zmiany)

W Twoim planie twardą barierą jest ticket-gate + HMAC w API/Canary, a launcher/launch-token to warstwa utrudniająca (speed-bump / UX). To musi zostać zachowane 1:1.

2) Czy Rust+Tauri „popsuje instalkę”?

Nie, jeśli instalka zostanie potraktowana jako bootstrapper (instaluje launcher i odpala go), a nie jako główne narzędzie aktualizacji.

Docelowy model

Instalka: mała, stabilna, rzadko zmieniana

Launcher: główna aplikacja codzienna

Klient: aktualizowany przez launcher

To jest dokładnie zgodne z Twoim celem („wystarczy pobrać launcher, a on pobiera/aktualizuje pliki lua itd.”).

Ważne doprecyzowanie

Tauri nie psuje instalki, ale trzeba zaplanować:

gdzie instalowany jest launcher,

jak launcher robi self-update,

jak instalka wykrywa istniejącą instalację,

jak nie nadpisywać plików użytkownika.

3) Architektura docelowa (spójna z planem zabezpieczeń)
3.1. Warstwy — finalny podział odpowiedzialności
Warstwa A — Installer Bootstrap (instalka)

Rola:

tworzy katalog instalacji,

kopiuje Launcher.exe + minimalne pliki konfiguracyjne,

dodaje skrót,

uruchamia launcher.

Nie robi pełnego patchowania klienta.

Warstwa B — Launcher Rust+Tauri (główna aplikacja)

Rola:

aktualizacje plików klienta,

synchronizacja listy serwerów (z API/manifestu),

integralność (sha256, filesHash),

pobranie launch-token,

start klienta z OTC_LAUNCH_TOKEN,

logi i diagnostyka.

To odpowiada temu, co już masz w Python MVP (E1–E12), tylko przeniesione do kompilowanego launchera.

Warstwa C — Klient OTClient (instalka/klient gry)

Rola:

UI trybu gry / loginu / wyboru świata/postaci,

odczyt OTC_LAUNCH_TOKEN z env,

przekazanie launchToken do login.php,

standardowy flow login.php → ticket.php → connect do Canary.

Wybór świata pozostaje w kliencie — zgodnie z Twoją uwagą i Twoim planem.

Warstwa D — API HTTP + Canary

Rola:

update.php, launcher-version.php, launcher-token.php

login.php, ticket.php

walidacje tokenów / ticketów / nonce / TTL / HMAC

finalna decyzja bezpieczeństwa po stronie serwera

To już masz w dużej mierze przygotowane w planie i dzienniku prac.

4) Architektura launchera Rust+Tauri (wewnętrzna)
4.1. Najlepszy układ: Tauri UI + osobny „core” launchera w Rust

Żeby projekt był trwały i testowalny:

Tauri UI (frontend)
Ekrany: status, aktualizacja, logi, ustawienia, start gry

Rust Core (biblioteka/crate)
Logika: manifest, hash, update, token, process launch

Rust Updater Helper (mały exe)
Do self-update launchera (bo launcher nie może bezpiecznie nadpisać sam siebie, gdy działa)

To da Ci:

łatwiejsze testy jednostkowe,

możliwość późniejszego CLI do diagnostyki,

mniejsze ryzyko „bałaganu” w Tauri commands.

4.2. Moduły launchera (Rust Core)
A) config

ścieżki instalacji

kanał (stable/test/dev)

URL API

timeouty / retry

ustawienia logów

B) manifest

pobieranie update.php

parsowanie manifestu

walidacja pól

(opcjonalnie) podpis manifestu / HMAC (defense-in-depth)

W planie podpis manifestu jest opisany jako opcjonalny i „speed-bump” (zwłaszcza w Pythonie), ale w Rust też może zostać jako dodatkowa warstwa.

C) file_index

skan lokalnych plików

SHA-256 per plik

liczenie filesHash z faktycznych lokalnych plików, nie z manifestu (to krytyczne)

D) patcher

plan zmian: download / replace / delete / keep

pobieranie plików

weryfikacja sha256

staging (tmp) + atomowa podmiana

rollback w razie błędu

E) api_client

launcher-version.php

update.php

launcher-token.php

obsługa rate-limit / komunikatów błędów / retry

F) launcher_token

pobranie tokena

obsługa TTL (300s)

powiązanie launcherVersion + filesHash

logika „token pobierz dopiero po update i tuż przed startem klienta”

G) process_runner

uruchomienie klienta

przekazanie OTC_LAUNCH_TOKEN przez env (nie CLI)

opcjonalne monitorowanie procesu / exit code / crash info

H) serverlist_sync

pobranie listy serwerów z API / manifestu

zapis do plików klienta (ServerList, init.lua, itp. wg Twojej implementacji)

zachowanie blokady ręcznej edycji przez gracza (klient locked)

To jest spójne z celem z planu: launcher zarządza listą serwerów, gracz nie edytuje ręcznie.

I) diagnostics

log update

log błędów API

eksport logów do pliku ZIP/TXT (przydatne do supportu)

5) Spójność z Twoim modelem bezpieczeństwa (najważniejszy punkt)
5.1. Hierarchia warstw — zachować bez zmian

Twój plan jasno rozdziela:

twardą warstwę: ticket-gate HMAC

średnią warstwę: blokady klienta + launch-token

UX/speed-bump: launcher, filesHash, challenge-response.

Rust+Tauri nie zmienia tej hierarchii.
On tylko wzmacnia warstwę launchera (utrudnia reverse engineering względem PyInstaller), ale nie zastępuje ticket-gate.

5.2. Launch-token (sekcja 16.3) — jak wdrożyć w Rust, bez zmiany logiki

Zachowujemy 1:1 założenia z planu:

token jednorazowy UUID

TTL 300s

IP-binding

rate-limit

filesHash z lokalnych plików

token przekazywany do klienta przez OTC_LAUNCH_TOKEN (env).

I zachowujemy uczciwą ocenę:

to nadal nie jest dowód kryptograficzny uruchomienia oficjalnego launchera, bo endpoint jest publiczny.

5.3. Ticket-gate (2-fazowy) — bez przenoszenia do launchera

Launcher nie powinien wchodzić w logikę:

wyboru postaci,

ticket.php,

wyboru świata.

To pozostaje w kliencie i API, zgodnie z Twoim planem 2-fazowego flow (login.php → wybór postaci → ticket.php → connect).

Launcher kończy swoją rolę na:

aktualizacji,

pobraniu launch-tokena,

uruchomieniu klienta.

To jest idealnie spójne z Twoją ostatnią uwagą.

5.4. Manifest version pinning / grace period — obowiązkowo uwzględnić

W planie masz ważną ochronę na race condition rolloutu:

token zawiera manifest_version,

API przy konsumpcji akceptuje current + previous przez grace period,

porównanie filesHash do hashy dla właściwej wersji manifestu. 

plan_zabezpieczenia_klienta_i_s…

Rust launcher musi wspierać to bez skrótów, czyli:

wysyłać filesHash i launcherVersion,

nie zakładać, że „latest” zawsze = jedyna akceptowana wersja,

poprawnie obsłużyć komunikat „zrestartuj launcher”.

6) Plan wdrożenia Rust+Tauri — etapami (bez ryzyka rozwalenia działającego MVP)
Etap 0 — Specyfikacja kontraktów (najpierw papier, potem kod)

To kluczowe, żeby nie rozwalić zgodności z obecnym API/Python MVP.

Do spisania (wersjonowane dokumenty)

Kontrakt API launchera

launcher-version.php response

update.php manifest schema

launcher-token.php request/response/errors

Kontrakt lokalnego stanu launchera

installed_state.json

launcher_settings.json

log policy

Kontrakt plików zarządzanych

które pliki są managed

które są user-owned

które mogą być kasowane

które nigdy nie mogą być nadpisane

Kontrakt integracji z klientem

ścieżka klienta

nazwa exe

env OTC_LAUNCH_TOKEN

ew. inne zmienne (kanał, ścieżka logów)

Rezultat etapu: stabilna specyfikacja kompatybilna z aktualnym Python launcherem.

Etap 1 — Rust Core (bez Tauri UI, tryb CLI/testowy)

Najpierw backend logiki, żeby szybciej testować.

Funkcje

pobieranie manifestu

porównanie hashy

download + verify

liczenie filesHash

pobranie launch-token

uruchom klienta z env (testowo może bez UI)

Po co tak?

łatwiejsze testy

szybsze debugowanie

można porównać wynik 1:1 z Python launcherem (parytet)

Cel: osiągnąć funkcjonalność E1–E12 na Rust CLI, korzystając z istniejących endpointów i bazy.

Etap 2 — Tauri UI v1 (nakładka na Rust Core)

Dopiero teraz dokładamy GUI.

Ekrany v1 (minimalny, produkcyjny)

Status

wersja launchera

wersja klienta (manifest/local)

status API

Aktualizacja

progress bar

lista aktualizowanych plików (opcjonalnie skrócona)

Start gry

przycisk „Uruchom”

Logi / pomoc

pokaż ostatni błąd

eksport logów

Ustawienia

kanał stable/test

ścieżka instalacji

auto-start launchera (opcjonalnie)

Czego nie robi UI v1

nie robi wyboru świata/postaci

nie dubluje loginu klienta

nie dotyka ticket-gate

Etap 3 — Integracja z instalką (bootstrap model)
Nowy model instalatora

Instalka:

instaluje Launcher.exe

instaluje minimalny config (api_url, channel=stable)

tworzy skrót

uruchamia launcher

Opcjonalny wariant „hybryda”

Jeśli chcesz lepszy UX przy słabym internecie:

instalka zawiera minimalny snapshot klienta (np. ostatni stabilny build),

launcher po pierwszym starcie robi tylko „dogranie różnic”.

To nie psuje architektury — po prostu skraca pierwszy update.

Etap 4 — Self-update launchera (helper process)

To element, którego nie warto wciskać za wcześnie, ale trzeba go mieć w planie.

Mechanizm

Launcher sprawdza launcher-version.php

Jeśli update wymagany:

pobiera nową paczkę launchera

uruchamia LauncherUpdaterHelper.exe

zamyka launcher

helper podmienia pliki

helper restartuje launcher

W planie masz już launcher-version.php, więc jest dobra baza pod ten flow.

Etap 5 — Hardening / defense-in-depth (opcjonalne, po stabilnym v1)

Tutaj wrzucamy rzeczy z Twojego planu jako ulepszenia, nie blokery:

challenge-response (sekcja 16.16) 

plan_zabezpieczenia_klienta_i_s…

podpis manifestu (HMAC / docelowo lepiej asymetryczny podpis)

metrics/logi odrzuceń ticketów po stronie serwera (ważne operacyjnie) 

plan_zabezpieczenia_klienta_i_s…

cert pinning po stronie klienta (jeśli chcesz ten poziom hardeningu) 

plan_zabezpieczenia_klienta_i_s…

7) Plan integracji z istniejącym Python launcherem (bez ryzyka)

Masz już działające MVP i testy smoke (launch token required, fake token fail, true token OK, one-time use OK). To ogromna przewaga — nie zaczynasz od zera. 

01_DZIENNIK_PRAC

Strategia migracji (najbezpieczniejsza)
Faza M1 — Parytet funkcjonalny

Rust launcher robi dokładnie to samo co Python launcher:

te same endpointy

ten sam filesHash

ten sam env token

ten sam flow

Faza M2 — Kanał testowy

Python launcher zostaje na stable

Rust+Tauri launcher testujesz na test/dev

porównujesz logi, błędy, hashy, czasy aktualizacji

Faza M3 — Soft rollout

mały % graczy / testerzy

fallback do Python launchera (awaryjnie)

Faza M4 — Full rollout

Rust+Tauri staje się domyślny

Python launcher zostaje jako fallback serwisowy jeszcze przez jakiś czas

To jest zgodne z Twoim stylem pracy: iteracyjnie, bez wywracania wszystkiego naraz.

8) Repo / struktura projektu (propozycja)
Wariant rekomendowany: osobne repo launchera + integracja przez API

To daje porządek i niezależne release’y.

Repo 1 — launcher-rust

apps/launcher-tauri/ (UI Tauri)

crates/launcher-core/ (manifest, patcher, filesHash, token)

crates/launcher-api/ (klient HTTP)

crates/launcher-helper/ (self-update helper)

crates/common-models/ (structy manifest/response)

docs/

tests/ (fixture manifesty, testy patchera)

.github/workflows/

Repo 2 — obecny projekt gry / API / Canary

endpointy PHP

klient OTClient

serwer Canary

schema SQL

manifest generator

Alternatywa (mono-repo)

Da się, ale łatwiej o mieszanie odpowiedzialności i dłuższe pipeline’y.

9) CI/CD i release pipeline (praktycznie)
9.1. Build launchera (Rust+Tauri)

Pipeline GHA:

build launcher-core tests

build Tauri app (Windows)

artefakt: Launcher.exe

opcjonalnie build helper updater

publikacja release (GitHub Release / prywatny storage)

9.2. Build klienta

Osobno (jak teraz):

kompilacja klienta

generacja manifestu

upload plików na hosting/CDN (E13) — to i tak masz jako wymagane zadanie.

9.3. Publish update

wrzucasz pliki klienta

generujesz manifest

aktywujesz manifest_version

launcher pobiera latest

API respektuje current + previous grace period

To musi być zsynchronizowane z zasadą z planu dot. rollout race condition. 

plan_zabezpieczenia_klienta_i_s…

10) Szczegółowy backlog funkcjonalny (Rust+Tauri)
MVP (produkcyjne minimum)

 pobierz launcher-version.php

 pobierz update.php?channel=stable

 oblicz lokalne SHA-256

 porównaj + pobierz zmienione pliki

 staging + atomowa podmiana

 oblicz filesHash

 pobierz launch-token

 uruchom klienta z OTC_LAUNCH_TOKEN

 logi błędów

 podstawowy ekran UI z progressem

V1.1 (stabilizacja)

 retry/resume pobrań

 lepsze komunikaty błędów (TLS/API/rate-limit/hash mismatch)

 „Napraw instalację” (verify all + redownload)

 eksport logów

V1.2 (operacyjne)

 self-update launchera

 kanały stable/test/dev

 status API/serwera (tylko podgląd)

 telemetria techniczna (opcjonalnie, opt-in)

V2 (hardening)

 challenge-response

 podpis manifestu (silniejszy model)

 metrics i dashboard odrzuceń token/ticket

 rotacja kluczy HMAC (kid) jeśli jeszcze nie domknięte wszędzie

11) Ryzyka i decyzje techniczne (ważne przed startem)
11.1. Tauri na Windows — runtime

Tauri na Windows używa WebView. Trzeba zdecydować:

czy wymagamy istniejącego runtime systemowego,

czy bootstrapper ma sprawdzać/doinstalować wymagany runtime.

To nie jest problem architektury, ale trzeba uwzględnić w instalce.

11.2. Self-update vs otwarty plik EXE

Klasyczny problem — rozwiązywany helperem.
Nie próbować robić „nadpisz samego siebie” w głównym procesie.

11.3. Pliki użytkownika vs pliki zarządzane

Najczęstsza mina w updaterach:

launcher usuwa coś, czego nie powinien,

albo nadpisuje config użytkownika.

Dlatego manifest musi mieć flagi (np. managed, preserve_user, optional).

11.4. Kolejność prac a stan kodu C++

W planie masz status, że kod w canary_test/ nadal wymaga poprawek guardów i buildów GHA. To oznacza: launcher Rust można projektować równolegle, ale rollout produkcyjny i tak powinien iść po stabilizacji buildów/serwera. 

plan_zabezpieczenia_klienta_i_s…

12) Rekomendowana kolejność prac (realna, bez chaosu)
Krok A — Specyfikacja kontraktów (manifest + state + API)

Najpierw zamrażasz formaty i zachowanie.

Krok B — Rust Core (CLI/test)

Odtwarzasz parytet z Python launcherem.

Krok C — Tauri UI v1

Dopinasz GUI na gotowym core.

Krok D — Integracja z instalką (bootstrap)

Niech instalka tylko instaluje launcher.

Krok E — Kanał testowy + soft rollout

Python jako fallback.

Krok F — Self-update launchera

Po stabilizacji.

Krok G — Hardening (challenge-response, podpis manifestu, telemetry)

Na końcu.

Przygotuję teraz konkretną specyfikację manifest.json i installed_state.json (z flagami plików i zasadami aktualizacji), tak żeby była zgodna z Twoim planem zabezpieczeń i gotowa pod Rust+Tauri.

Myślał przez 56s

Świetnie. Poniżej masz roboczą specyfikację techniczną pod Rust + Tauri, która jest spójna z Twoim planem zabezpieczeń (launch-token jako warstwa pomocnicza, ticket-gate + HMAC jako twarda bariera), z obecnym flow API (update.php, launcher-token.php, launcher-version.php) i z założeniem, że wybór świata zostaje w kliencie. 

plan_zabezpieczenia_klienta_i_s…

 

plan_zabezpieczenia_klienta_i_s…

 

plan_zabezpieczenia_klienta_i_s…

Specyfikacja robocza — manifest.json + installed_state.json (Rust+Tauri launcher)
0. Cel specyfikacji

Celem jest zdefiniowanie dwóch głównych kontraktów lokalnych/serwerowych:

manifest.json — opis aktualnej wersji klienta i listy plików zarządzanych przez launcher (co pobrać, co zweryfikować, co usunąć, co zachować).

installed_state.json — lokalny stan instalacji po stronie launchera (co mamy, na jakiej wersji, ostatni udany update, stan patchowania, hash zestawu plików, itp.).

Spec ma umożliwić:

bezpieczne aktualizacje plików klienta (.exe, .dll, .lua, .otui, assets, tłumaczenia),

zgodność z istniejącym filesHash i launch-token,

odporność na przerwany update (staging + rollback),

migrację z obecnego prostszego manifestu (sekcja 16.10) bez rozwalania obecnego API/Python MVP. 

plan_zabezpieczenia_klienta_i_s…

 

01_DZIENNIK_PRAC

1. Zasady nadrzędne (spójność z planem zabezpieczeń)
1.1. Hierarchia bezpieczeństwa (bez zmian)

Twarda warstwa: ticket-gate + HMAC po stronie API/Canary.

Warstwa średnia: launcher + launch-token + filesHash + blokady klienta.

Warstwa UX/speed-bump: dodatkowe utrudnienia (challenge-response, podpis manifestu itd.). 

plan_zabezpieczenia_klienta_i_s…

 

plan_zabezpieczenia_klienta_i_s…

1.2. Launch-token nie jest dowodem kryptograficznym launchera

To pozostaje prawdą także po migracji na Rust+Tauri — kompilowany launcher utrudnia obejście, ale nie zmienia natury endpointu publicznego. 

plan_zabezpieczenia_klienta_i_s…

1.3. filesHash liczony z lokalnych plików (nie z manifestu)

To jest krytyczne i zostaje bez zmian. 

plan_zabezpieczenia_klienta_i_s…

 

plan_zabezpieczenia_klienta_i_s…

1.4. Token do klienta wyłącznie przez OTC_LAUNCH_TOKEN (env)

Nie przez argument CLI. 

plan_zabezpieczenia_klienta_i_s…

 

01_DZIENNIK_PRAC

2. manifest.json — specyfikacja v2 (rozszerzona, kompatybilna)
2.1. Założenia kompatybilności

Obecny manifest w planie ma prostą strukturę:

version

releaseDate

channel

files[]

opcjonalnie changelog[] 

plan_zabezpieczenia_klienta_i_s…

Proponuję v2 rozszerzoną, ale w sposób kompatybilny:

stare pola zostają,

nowe pola są opcjonalne dla starego launchera,

Rust launcher używa nowych pól, gdy są dostępne.

2.2. Top-level schema (manifest.json)
Pola wymagane (v2)

schemaVersion (string) — np. "2.0"

version (string) — wersja klienta, np. "1.0.3"

releaseDate (string, YYYY-MM-DD) — data publikacji

channel (string) — np. "stable", "test", "dev"

files (array) — lista plików zarządzanych

filesHashExpected (string, hex sha256) — hash oczekiwany zestawu plików dla tej wersji manifestu

manifestId (string) — unikalny identyfikator manifestu (np. UUID lub channel:version)

generatedAtUtc (string, ISO-8601) — data/czas wygenerowania

Pola zalecane (v2)

changelog (array)

servers (array) — lista serwerów do synchronizacji do klienta (jeśli chcesz trzymać to w manifeście zamiast osobnego servers.php)

minLauncherVersion (string) — minimalna wersja launchera, która obsługuje ten manifest

gracePreviousVersionAcceptedUntilUtc (string, ISO-8601) — informacja pomocnicza dla UI/diagnostyki (serwer nadal decyduje)

signature (string) — podpis manifestu (opcjonalny defense-in-depth; patrz sekcja 16.14 planu) 

plan_zabezpieczenia_klienta_i_s…

Pola opcjonalne (operacyjne)

baseUrl (string) — bazowy URL dla plików (jeśli files[].url są względne)

notes (string) — techniczne notatki release

rollout (object) — metadane rolloutu (np. aktywność kanału)

2.3. files[] — struktura wpisu pliku (v2)
Pola wymagane

path (string) — ścieżka względna w instalacji (separator /)

sha256 (string, hex) — hash pliku

size (integer) — rozmiar w bajtach

url (string) — URL pobrania (pełny lub względny)

managed (boolean) — czy plik jest zarządzany przez launcher

action (string enum) — domyślnie "file"; patrz niżej

Pola zalecane

required (boolean) — czy plik jest wymagany do startu klienta

includeInFilesHash (boolean) — czy plik uczestniczy w obliczaniu filesHash (domyślnie true)

overwritePolicy (string enum) — polityka nadpisywania

deletePolicy (string enum) — polityka usuwania

executable (boolean) — czy plik wykonywalny (pomocnicze)

tags (array[string]) — np. ["client-bin"], ["lua","ui"], ["asset"]

mode (string) — np. "0644" (opcjonalne; bardziej pod Linux)

Pola opcjonalne (diagnostyka/optimizacje)

compressedSize (integer)

checksumAlgo (string) — np. "sha256" (na dziś można pominąć, zakładać sha256)

etag (string) — do optymalizacji pobierania

lastModifiedUtc (string ISO-8601)

2.4. action — typy wpisów w files[]

Proponowane enumy:

"file" — normalny plik do pobrania/aktualizacji

"delete" — wpis oznacza, że launcher ma usunąć plik (kontrolowany cleanup)

"mkdir" — opcjonalnie utwórz katalog (zwykle niepotrzebne, bo tworzymy przy pliku)

"noop" — rezerwowe / diagnostyczne (raczej nie używać w MVP)

Praktycznie na start: wystarczy "file" i "delete".

2.5. overwritePolicy — polityka nadpisywania pliku

Proponowane wartości:

"always" — zawsze nadpisz, jeśli hash nie pasuje

"if_hash_differs" — nadpisz tylko gdy lokalny hash ≠ manifest (domyślny sensowny tryb)

"never" — launcher nie nadpisuje (np. pliki user-owned, ale wtedy zwykle managed=false)

"preserve_user" — jeżeli plik istnieje i był lokalnie modyfikowany przez użytkownika, nie nadpisuj automatycznie; loguj ostrzeżenie

Rekomendacja MVP

większość plików zarządzanych: "if_hash_differs"

pliki konfiguracyjne użytkownika: nie wrzucać do managed=true, albo oznaczyć managed=false

2.6. deletePolicy — polityka usuwania

Proponowane wartości:

"allow" — launcher może usunąć plik, jeśli manifest wyda action=delete

"protect" — launcher nigdy nie usuwa automatycznie

"orphan_cleanup" — launcher może usunąć plik osierocony, ale tylko jeśli był wcześniej managed=true

Rekomendacja

Na start:

usuwanie tylko dla plików wprost oznaczonych action=delete

bez agresywnego orphan cleanup (żeby nie skasować czegoś niechcący)

2.7. filesHashExpected — definicja

To jest hash całego zestawu plików oczekiwany przez API dla danej manifest_version.

Powinien być zgodny z logiką z planu:

sortowanie po path

hash z faktycznych lokalnych plików

brak pliku = "MISSING" w łańcuchu wejściowym (jak w sekcji 16.3) 

plan_zabezpieczenia_klienta_i_s…

Ważne doprecyzowanie dla v2

filesHashExpected powinien być liczony wyłącznie z plików:

managed=true

action="file"

includeInFilesHash=true (domyślnie true)

Dzięki temu możesz mieć w manifeście wpisy, które nie wpływają na bezpieczeństwo/logikę integralności (np. pliki pomocnicze, telemetria, cache seed).

2.8. servers[] — opcjonalna lista serwerów do synchronizacji (jeśli w manifeście)

To jest zgodne z Twoim planem: launcher aktualizuje listę serwerów, gracz nie edytuje ręcznie, a wybór świata odbywa się w kliencie. 

plan_zabezpieczenia_klienta_i_s…

 

plan_zabezpieczenia_klienta_i_s…

Przykładowa struktura servers[]

id (string)

name (string)

host (string)

port (integer)

gameMode (enum: "classic74"|"modern")

visible (boolean)

enabled (boolean)

priority (integer)

channel (string, opcjonalnie)

Launcher zapisuje to do plików klienta (init.lua / ServerList wg Twojej implementacji), ale nie pokazuje wyboru świata w launcherze.

2.9. Przykład manifest.json v2 (propozycja)
{
  "schemaVersion": "2.0",
  "manifestId": "stable:1.0.3",
  "version": "1.0.3",
  "releaseDate": "2026-03-02",
  "generatedAtUtc": "2026-03-02T18:15:22Z",
  "channel": "stable",
  "minLauncherVersion": "0.2.0",
  "baseUrl": "https://twojadomena.pl/files/stable/1.0.3/",
  "filesHashExpected": "8d1b5f...abc123",
  "files": [
    {
      "path": "otclient.exe",
      "sha256": "a1b2c3...",
      "size": 15728640,
      "url": "otclient.exe",
      "managed": true,
      "action": "file",
      "required": true,
      "includeInFilesHash": true,
      "overwritePolicy": "if_hash_differs",
      "deletePolicy": "protect",
      "executable": true,
      "tags": ["client-bin"]
    },
    {
      "path": "modules/client_entergame/entergame.lua",
      "sha256": "112233...",
      "size": 32768,
      "url": "modules/client_entergame/entergame.lua",
      "managed": true,
      "action": "file",
      "required": true,
      "includeInFilesHash": true,
      "overwritePolicy": "if_hash_differs",
      "deletePolicy": "allow",
      "tags": ["lua","ui"]
    },
    {
      "path": "userdata/settings_local.json",
      "sha256": "",
      "size": 0,
      "url": "",
      "managed": false,
      "action": "file",
      "required": false,
      "includeInFilesHash": false,
      "overwritePolicy": "never",
      "deletePolicy": "protect",
      "tags": ["user-config"]
    }
  ],
  "servers": [
    {
      "id": "classic74-main",
      "name": "Classic 7.4",
      "host": "classic.example.com",
      "port": 7171,
      "gameMode": "classic74",
      "visible": true,
      "enabled": true,
      "priority": 10
    },
    {
      "id": "modern-main",
      "name": "Modern",
      "host": "modern.example.com",
      "port": 7171,
      "gameMode": "modern",
      "visible": true,
      "enabled": true,
      "priority": 20
    }
  ],
  "changelog": [
    { "date": "2026-03-02", "text": "Poprawki launchera i synchronizacja listy serwerów" }
  ],
  "signature": "opcjonalny-podpis-manifestu"
}
3. installed_state.json — lokalny stan instalacji (launcher)
3.1. Cel pliku

installed_state.json to stan techniczny launchera, nie ustawienia użytkownika.

Ma odpowiadać na pytania:

co jest zainstalowane,

jaki manifest był ostatnio poprawnie zastosowany,

czy update został przerwany,

jaki był ostatni filesHash,

czy trzeba dokończyć rollback / repair.

3.2. Lokalizacja

Propozycja:

w katalogu instalacji launchera lub klienta (np. launcher_data/installed_state.json)

nie w katalogu user config klienta

Zalecenie (Windows)

C:\...\TwojaGra\launcher\installed_state.json albo

C:\...\TwojaGra\.launcher\installed_state.json

3.3. Struktura top-level installed_state.json
Pola wymagane

schemaVersion (string) — np. "1.0"

installId (string UUID) — unikalny identyfikator instalacji

channel (string) — stable/test/dev

currentManifestVersion (string|null) — ostatnia w pełni zastosowana wersja

currentManifestId (string|null)

currentFilesHash (string|null) — ostatni obliczony filesHash po udanym update

clientInstallPath (string) — ścieżka klienta

launcherVersion (string) — wersja launchera, która zapisała ten stan

lastSuccessfulUpdateUtc (string|null)

Pola operacyjne (zalecane)

lastKnownServerManifestVersion (string|null) — jeśli servers sync jest oddzielnie wersjonowany

lastLauncherVersionCheckUtc (string|null)

lastUpdateAttemptUtc (string|null)

lastUpdateResult (enum) — "success" | "failed" | "partial" | "rollback_success" | "rollback_failed"

lastErrorCode (string|null)

lastErrorMessage (string|null)` (krótkie, techniczne)

Pola bezpieczeństwa / diagnostyki

lastTokenRequest (object, opcjonalnie) — tylko metadane, nigdy sam token

lastApiBaseUrl (string)

tlsEnforced (boolean) — pomocnicze (na dziś powinno być true; hard-fail TLS w planie)

Pola stanu transakcji update (bardzo ważne)

updateTransaction (object|null) — stan trwającego/przerwanego patchowania

staging (object|null) — ścieżki tymczasowe i metadata

managedFilesIndex (object) — lokalny indeks plików zarządzanych (patrz niżej)

3.4. updateTransaction — stan patchowania (anty-corruption / anti-half-state)
Cel

Jeśli padnie prąd/internet, launcher przy kolejnym starcie ma wiedzieć:

czy poprzedni update był w trakcie,

czy trzeba dokończyć,

czy zrobić rollback,

czy odpalić repair.

Proponowana struktura

txId (string UUID)

status (enum):

"idle"

"preparing"

"downloading"

"verifying"

"applying"

"finalizing"

"rollback_required"

"rollback_in_progress"

targetManifestVersion (string)

targetManifestId (string)

startedAtUtc (string)

updatedFiles (array[string])

backupFiles (array[string])

deletePlanned (array[string])

deleteApplied (array[string])

stagingPath (string)

resumeSupported (boolean)

3.5. managedFilesIndex — lokalny indeks zarządzanych plików

To nie zastępuje manifestu — to lokalny snapshot po udanym update, przydatny do:

repair,

bezpiecznego orphan cleanup,

wykrywania, co launcher wcześniej zarządzał.

Proponowana struktura

Mapa path -> metadata:

sha256

size

manifestVersion

managed

installedAtUtc

tags

wasModifiedLocally (bool; opcjonalnie, wyliczane przy skanie)

3.6. Przykład installed_state.json
{
  "schemaVersion": "1.0",
  "installId": "6dc9f21d-b6af-44e2-bd7f-5b4f4a3f7a11",
  "channel": "stable",
  "clientInstallPath": "C:\\Games\\TwojaGra\\client",
  "launcherVersion": "0.2.0",
  "currentManifestVersion": "1.0.3",
  "currentManifestId": "stable:1.0.3",
  "currentFilesHash": "8d1b5f...abc123",
  "lastSuccessfulUpdateUtc": "2026-03-02T18:20:10Z",
  "lastUpdateAttemptUtc": "2026-03-02T18:18:03Z",
  "lastUpdateResult": "success",
  "lastErrorCode": null,
  "lastErrorMessage": null,
  "lastApiBaseUrl": "https://twojadomena.pl/api/",
  "tlsEnforced": true,
  "updateTransaction": {
    "txId": "f4d4ab61-8b6a-4974-b8e8-2f846ad77887",
    "status": "idle",
    "targetManifestVersion": "1.0.3",
    "targetManifestId": "stable:1.0.3",
    "startedAtUtc": "2026-03-02T18:18:03Z",
    "updatedFiles": [
      "modules/client_entergame/entergame.lua"
    ],
    "backupFiles": [],
    "deletePlanned": [],
    "deleteApplied": [],
    "stagingPath": "C:\\Games\\TwojaGra\\.launcher\\staging\\f4d4ab61",
    "resumeSupported": true
  },
  "managedFilesIndex": {
    "otclient.exe": {
      "sha256": "a1b2c3...",
      "size": 15728640,
      "manifestVersion": "1.0.3",
      "managed": true,
      "installedAtUtc": "2026-03-02T18:20:08Z",
      "tags": ["client-bin"]
    },
    "modules/client_entergame/entergame.lua": {
      "sha256": "112233...",
      "size": 32768,
      "manifestVersion": "1.0.3",
      "managed": true,
      "installedAtUtc": "2026-03-02T18:20:09Z",
      "tags": ["lua", "ui"]
    }
  }
}
4. Zasady obliczania filesHash (kontrakt zgodny z planem)
4.1. Źródło prawdy

filesHash liczymy z:

manifestu aktywnej wersji (lista ścieżek),

lokalnych plików na dysku (ich realny SHA-256),

sortowania po path.

4.2. Dokładne reguły (zalecane)

Weź manifest.files

Odfiltruj wpisy:

managed=true

action="file"

includeInFilesHash != false

Sortuj po path rosnąco (UTF-8 byte order / zwykłe lexicographic)

Dla każdego wpisu:

jeśli plik istnieje lokalnie → policz SHA-256 pliku

jeśli brak → wpisz "MISSING"

Sklej wszystkie wartości w jeden string

Zrób SHA-256 z połączonego stringa → wynik hex = filesHash

4.3. Ważne

Nie liczymy filesHash z sha256 z manifestu — plan słusznie podkreśla, że to psułoby sens walidacji.

5. Algorytm aktualizacji (launcher) — kontrakt wykonania
5.1. Flow wysokiego poziomu (spójny z Fazą E)

GET /api/launcher-version.php

ewentualny self-update launchera (później / helper)

GET /api/update.php?channel=...

walidacja manifestu

skan lokalnych plików i plan patcha

download do staging

SHA-256 verify każdego pobranego pliku

atomowa podmiana (temp -> rename)

aktualizacja listy serwerów do plików klienta (jeśli w manifeście/servers API)

obliczenie filesHash

POST /api/launcher-token.php (launcherVersion, filesHash, manifestVersion)

uruchom klienta z OTC_LAUNCH_TOKEN (env)

5.2. Zasady patchowania plików (MVP)

Pobieraj do staging (.launcher/staging/<txId>/...)

Weryfikuj hash przed podmianą

Twórz katalogi docelowe przed rename

Podmieniaj atomowo, gdy system pozwala

Przy błędzie:

oznacz updateTransaction.status = rollback_required

nie aktualizuj currentManifestVersion

nie generuj tokena

5.3. Zasady usuwania plików

Na start (bezpiecznie):

usuwaj tylko wpisy z manifestu action="delete"

nie rób automatycznego kasowania „nieznanych” plików użytkownika

5.4. „Repair install” (tryb naprawy)

Launcher powinien mieć tryb:

pełny skan plików zarządzanych

redownload wszystkich niezgodnych

odbudowa managedFilesIndex

ponowne przeliczenie filesHash

To będzie bardzo przydatne przy supportcie i po przerwanych aktualizacjach.

6. Kontrakt zgodności z API (launcher-token.php, login.php) — ważne
6.1. launcher-token.php request (Rust launcher)

Launcher wysyła co najmniej:

launcherVersion

filesHash

channel

manifestVersion (kluczowe dla rollout race condition / grace period)

To pasuje do planu z manifest_version w tabeli launch_tokens i późniejszej walidacji w login.php.

6.2. login.php konsumpcja tokena

Pozostaje po stronie API:

SELECT ... FOR UPDATE

walidacja IP

TTL 300s

walidacja manifest_version (current + previous w grace period)

walidacja files_hash

DELETE (jednorazowość)

6.3. Launcher nie dotyka ticket-gate

Launcher kończy się na starcie klienta + token env. Ticket/HMAC flow zostaje w kliencie+API+Canary, zgodnie z planem.

7. Specyfikacja błędów (launcher, lokalnie)
7.1. Kody błędów lokalne (propozycja)

Warto ustandaryzować w Rust Core (do logów/UI):

LCH_MANIFEST_FETCH_FAILED

LCH_MANIFEST_PARSE_FAILED

LCH_MANIFEST_SCHEMA_UNSUPPORTED

LCH_MANIFEST_SIGNATURE_INVALID

LCH_DOWNLOAD_FAILED

LCH_FILE_HASH_MISMATCH

LCH_PATCH_APPLY_FAILED

LCH_ROLLBACK_FAILED

LCH_FILES_HASH_COMPUTE_FAILED

LCH_TOKEN_REQUEST_FAILED

LCH_TOKEN_REJECTED

LCH_CLIENT_START_FAILED

LCH_TLS_REQUIRED

Te kody zapisuj w installed_state.json (lastErrorCode) i pokaż użytkownikowi uproszczony komunikat.

8. Wersjonowanie i migracja (z obecnego manifestu v1 → v2)
8.1. Strategia migracji bez psucia Python launchera
Faza M1 (bezpieczna)

Serwer nadal zwraca obecny manifest (v1), ale dodaje nowe pola opcjonalnie:

schemaVersion

manifestId

filesHashExpected

pola rozszerzone w files[] (gdy gotowe)

Stary launcher Python ignoruje nieznane pola (jeśli parser na to pozwala), a Rust launcher zaczyna z nich korzystać.

8.2. Faza M2

Rust launcher wspiera:

v1 manifest (fallback parser)

v2 manifest (pełne flagi)

8.3. Faza M3

Po stabilizacji można wymusić minLauncherVersion i przejść na v2-only.

9. Rust + Tauri — mapowanie tej specyfikacji na kod (praktyczne)
9.1. launcher-core (Rust)

Crates/moduły (proponowane):

models::manifest (serde structs)

models::installed_state

update::planner

update::patcher

integrity::hash

api::client

security::launch_token

process::runner

serverlist::sync

state::store

9.2. Tauri UI

Tauri wywołuje komendy:

check_launcher_version

check_for_updates

apply_update

repair_install

launch_game

export_logs

UI nie przechowuje logiki bezpieczeństwa — tylko prezentuje stan z launcher-core.

10. Minimalne testy akceptacyjne dla tej specyfikacji (bardzo polecam)
10.1. Manifest / parser

parse v1 (stary)

parse v2 (nowy)

reject brak wymaganych pól

reject duplikat path

10.2. filesHash

zgodność z referencyjnym wynikiem (fixture)

MISSING daje przewidywalny wynik

zmiana 1 pliku zmienia filesHash

10.3. Patcher

partial update

przerwanie w połowie

restart launchera → recovery / rollback

10.4. Integracja z API

token OK przy poprawnym filesHash

token fail przy złym filesHash

login fail po ponownym użyciu tokena (one-time use)

grace period current + previous działa zgodnie z planem

11. Decyzje „na teraz” (żeby ruszyć bez blokad)

Jeśli chcesz szybko wejść w implementację Rust+Tauri, proponuję zamrozić na start te decyzje:

manifest.json v2 kompatybilny (stare pola zostają)

filesHash zgodny z obecną logiką z planu

servers[] może być w manifeście (na start wygodne)

installed_state.json + updateTransaction obowiązkowo

brak agresywnego orphan cleanup w MVP

podpis manifestu jako opcjonalny etap V2 (defense-in-depth) — zgodnie z planem 16.14 

plan_zabezpieczenia_klienta_i_s…

wybór świata zostaje w kliencie (launcher tylko sync listy + start)

Jeśli chcesz, mogę teraz przygotować następny dokument roboczy:
konkretne Rust structy (serde) dla ManifestV2, ManifestFileEntry, InstalledState, UpdateTransaction + mapowanie parsera v1 -> v2 (kompatybilność).
Przygotowuję teraz wersję roboczą „pod implementację”: konkretne structy Rust (serde) dla manifestu i lokalnego stanu oraz parser kompatybilny v1 -> v2, żebyś mógł to od razu wpiąć do launcher-core.

Myślał przez 46s

Świetnie. Poniżej masz konkretny roboczy szkic pod implementację: serde structy Rust dla:

ManifestV2

ManifestFileEntry

InstalledState

UpdateTransaction

oraz parser kompatybilny v1 -> v2 (normalizacja), tak żeby to pasowało do Twojego planu zabezpieczeń (launch-token jako warstwa pomocnicza, ticket-gate + HMAC jako twarda bariera) i do flow, gdzie wybór świata zostaje w kliencie. 

plan_zabezpieczenia_klienta_i_s…

 

plan_zabezpieczenia_klienta_i_s…

 

plan_zabezpieczenia_klienta_i_s…

1) Założenie implementacyjne (krótkie)

W kodzie launchera najlepiej mieć:

Raw typy wejściowe (v1/v2 z API)

NormalizedManifest (jeden model wewnętrzny, na którym działa patcher)

Dzięki temu:

łatwo wspierasz migrację,

Tauri UI nie zna szczegółów v1/v2,

patcher działa tylko na jednej strukturze.

2) Rust serde — modele manifestu (v2 + v1 + model znormalizowany)
2.1. Kod: manifest.rs (roboczy szkic)
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, BTreeSet};

/// ===============================
/// V2 (docelowy manifest z API)
/// ===============================

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ManifestV2Raw {
    pub schema_version: String,              // "2.0"
    pub manifest_id: String,                 // np. "stable:1.0.3"
    pub version: String,                     // np. "1.0.3"
    pub release_date: String,                // YYYY-MM-DD
    pub generated_at_utc: String,            // ISO-8601
    pub channel: String,                     // stable/test/dev

    #[serde(default)]
    pub min_launcher_version: Option<String>,

    #[serde(default)]
    pub base_url: Option<String>,

    #[serde(default)]
    pub files_hash_expected: Option<String>,

    #[serde(default)]
    pub files: Vec<ManifestFileEntryV2Raw>,

    #[serde(default)]
    pub servers: Vec<ServerEntryRaw>,

    #[serde(default)]
    pub changelog: Vec<ChangelogEntryRaw>,

    #[serde(default)]
    pub grace_previous_version_accepted_until_utc: Option<String>,

    #[serde(default)]
    pub signature: Option<String>,

    #[serde(default)]
    pub notes: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ManifestFileEntryV2Raw {
    pub path: String,

    #[serde(default)]
    pub sha256: Option<String>,

    #[serde(default)]
    pub size: Option<u64>,

    #[serde(default)]
    pub url: Option<String>,

    #[serde(default = "default_true")]
    pub managed: bool,

    #[serde(default)]
    pub action: ManifestFileAction,

    #[serde(default)]
    pub required: bool,

    #[serde(default = "default_true")]
    pub include_in_files_hash: bool,

    #[serde(default)]
    pub overwrite_policy: OverwritePolicy,

    #[serde(default)]
    pub delete_policy: DeletePolicy,

    #[serde(default)]
    pub executable: bool,

    #[serde(default)]
    pub tags: Vec<String>,

    #[serde(default)]
    pub mode: Option<String>,

    #[serde(default)]
    pub compressed_size: Option<u64>,

    #[serde(default)]
    pub etag: Option<String>,

    #[serde(default)]
    pub last_modified_utc: Option<String>,
}

/// ===============================
/// V1 (legacy manifest z obecnego API / MVP)
/// ===============================

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ManifestV1Raw {
    pub version: String,
    pub release_date: String,
    pub channel: String,

    #[serde(default)]
    pub files: Vec<ManifestFileEntryV1Raw>,

    #[serde(default)]
    pub changelog: Vec<ChangelogEntryRaw>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ManifestFileEntryV1Raw {
    pub path: String,
    pub sha256: String,
    pub size: u64,
    pub url: String,
}

/// ===============================
/// Wspólne modele pomocnicze
/// ===============================

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum ManifestFileAction {
    #[default]
    File,
    Delete,
    Mkdir,
    Noop,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum OverwritePolicy {
    Always,
    #[default]
    IfHashDiffers,
    Never,
    PreserveUser,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum DeletePolicy {
    Allow,
    #[default]
    Protect,
    OrphanCleanup,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub struct ServerEntryRaw {
    pub id: String,
    pub name: String,
    pub host: String,
    pub port: u16,

    #[serde(default)]
    pub game_mode: Option<String>, // np. classic74 / modern

    #[serde(default = "default_true")]
    pub visible: bool,

    #[serde(default = "default_true")]
    pub enabled: bool,

    #[serde(default)]
    pub priority: i32,

    #[serde(default)]
    pub channel: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub struct ChangelogEntryRaw {
    pub date: String,
    pub text: String,
}

/// ===========================================
/// Model znormalizowany (wewnętrzny dla launchera)
/// ===========================================

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct NormalizedManifest {
    pub schema_version: String,          // "1-compat" albo "2.0"
    pub manifest_id: String,
    pub version: String,
    pub release_date: String,
    pub generated_at_utc: Option<String>,
    pub channel: String,

    pub min_launcher_version: Option<String>,
    pub base_url: Option<String>,
    pub files_hash_expected: Option<String>,

    pub files: Vec<ManifestFileEntry>,
    pub servers: Vec<ServerEntryRaw>,
    pub changelog: Vec<ChangelogEntryRaw>,

    pub grace_previous_version_accepted_until_utc: Option<String>,
    pub signature: Option<String>,
    pub notes: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ManifestFileEntry {
    pub path: String,
    pub sha256: Option<String>,
    pub size: Option<u64>,
    pub url: Option<String>,

    pub managed: bool,
    pub action: ManifestFileAction,
    pub required: bool,
    pub include_in_files_hash: bool,
    pub overwrite_policy: OverwritePolicy,
    pub delete_policy: DeletePolicy,
    pub executable: bool,
    pub tags: Vec<String>,
    pub mode: Option<String>,
}

impl NormalizedManifest {
    pub fn validate_basic(&self) -> Result<(), ManifestValidationError> {
        if self.version.trim().is_empty() {
            return Err(ManifestValidationError::InvalidField("version"));
        }
        if self.channel.trim().is_empty() {
            return Err(ManifestValidationError::InvalidField("channel"));
        }
        if self.files.is_empty() {
            return Err(ManifestValidationError::InvalidField("files"));
        }

        // Duplikaty path = błąd krytyczny
        let mut seen = BTreeSet::new();
        for f in &self.files {
            if f.path.trim().is_empty() {
                return Err(ManifestValidationError::InvalidField("files[].path"));
            }
            if !seen.insert(f.path.clone()) {
                return Err(ManifestValidationError::DuplicatePath(f.path.clone()));
            }

            match f.action {
                ManifestFileAction::File => {
                    if f.managed {
                        if f.sha256.as_deref().unwrap_or("").is_empty() {
                            return Err(ManifestValidationError::MissingRequiredForFile {
                                path: f.path.clone(),
                                field: "sha256",
                            });
                        }
                        if f.size.is_none() {
                            return Err(ManifestValidationError::MissingRequiredForFile {
                                path: f.path.clone(),
                                field: "size",
                            });
                        }
                        // URL może być pusty, jeśli używasz base_url + path, ale wtedy zbudujesz go później.
                    }
                }
                ManifestFileAction::Delete => {
                    // Dla delete nie wymagamy sha256/size/url
                }
                ManifestFileAction::Mkdir | ManifestFileAction::Noop => {
                    // MVP: dozwolone, ale patcher może je ignorować lub obsłużyć warunkowo.
                }
            }
        }

        Ok(())
    }
}

#[derive(Debug)]
pub enum ManifestValidationError {
    InvalidField(&'static str),
    DuplicatePath(String),
    MissingRequiredForFile { path: String, field: &'static str },
}

impl std::fmt::Display for ManifestValidationError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::InvalidField(name) => write!(f, "Invalid field: {}", name),
            Self::DuplicatePath(path) => write!(f, "Duplicate path in manifest: {}", path),
            Self::MissingRequiredForFile { path, field } => {
                write!(f, "Missing field '{}' for managed file '{}'", field, path)
            }
        }
    }
}

impl std::error::Error for ManifestValidationError {}

/// ===========================================
/// Parser kompatybilny v1 -> v2 (normalizacja)
/// ===========================================

#[derive(Debug)]
pub enum ManifestParseError {
    Json(serde_json::Error),
    Validation(ManifestValidationError),
    UnsupportedSchema(String),
}

impl From<serde_json::Error> for ManifestParseError {
    fn from(value: serde_json::Error) -> Self {
        Self::Json(value)
    }
}

impl From<ManifestValidationError> for ManifestParseError {
    fn from(value: ManifestValidationError) -> Self {
        Self::Validation(value)
    }
}

pub fn parse_manifest_compat(json_text: &str) -> Result<NormalizedManifest, ManifestParseError> {
    let value: serde_json::Value = serde_json::from_str(json_text)?;

    let normalized = match value.get("schemaVersion").and_then(|v| v.as_str()) {
        Some(schema) if schema.starts_with('2') => {
            let raw: ManifestV2Raw = serde_json::from_value(value)?;
            normalize_v2(raw)?
        }
        Some(other) => {
            return Err(ManifestParseError::UnsupportedSchema(other.to_string()));
        }
        None => {
            // Legacy v1 fallback
            let raw: ManifestV1Raw = serde_json::from_value(value)?;
            normalize_v1(raw)?
        }
    };

    normalized.validate_basic()?;
    Ok(normalized)
}

fn normalize_v2(raw: ManifestV2Raw) -> Result<NormalizedManifest, ManifestParseError> {
    let files = raw
        .files
        .into_iter()
        .map(|f| ManifestFileEntry {
            path: normalize_rel_path(&f.path),
            sha256: normalize_opt_string(f.sha256),
            size: f.size,
            url: normalize_opt_string(f.url),
            managed: f.managed,
            action: f.action,
            required: f.required,
            include_in_files_hash: f.include_in_files_hash,
            overwrite_policy: f.overwrite_policy,
            delete_policy: f.delete_policy,
            executable: f.executable,
            tags: normalize_tags(f.tags),
            mode: f.mode,
        })
        .collect::<Vec<_>>();

    Ok(NormalizedManifest {
        schema_version: raw.schema_version,
        manifest_id: if raw.manifest_id.trim().is_empty() {
            format!("{}:{}", raw.channel, raw.version)
        } else {
            raw.manifest_id
        },
        version: raw.version,
        release_date: raw.release_date,
        generated_at_utc: Some(raw.generated_at_utc),
        channel: raw.channel,
        min_launcher_version: raw.min_launcher_version,
        base_url: raw.base_url,
        files_hash_expected: raw.files_hash_expected,
        files,
        servers: raw.servers,
        changelog: raw.changelog,
        grace_previous_version_accepted_until_utc: raw.grace_previous_version_accepted_until_utc,
        signature: raw.signature,
        notes: raw.notes,
    })
}

fn normalize_v1(raw: ManifestV1Raw) -> Result<NormalizedManifest, ManifestParseError> {
    let files = raw
        .files
        .into_iter()
        .map(|f| ManifestFileEntry {
            path: normalize_rel_path(&f.path),
            sha256: Some(f.sha256),
            size: Some(f.size),
            url: Some(f.url),
            managed: true,
            action: ManifestFileAction::File,
            required: true,
            include_in_files_hash: true,
            overwrite_policy: OverwritePolicy::IfHashDiffers,
            delete_policy: DeletePolicy::Protect,
            executable: is_probably_executable(&f.path),
            tags: infer_tags_from_path(&f.path),
            mode: None,
        })
        .collect::<Vec<_>>();

    Ok(NormalizedManifest {
        schema_version: "1-compat".to_string(),
        manifest_id: format!("{}:{}", raw.channel, raw.version),
        version: raw.version,
        release_date: raw.release_date,
        generated_at_utc: None,
        channel: raw.channel,
        min_launcher_version: None,
        base_url: None,
        files_hash_expected: None, // w legacy może nie istnieć
        files,
        servers: Vec::new(),
        changelog: raw.changelog,
        grace_previous_version_accepted_until_utc: None,
        signature: None,
        notes: None,
    })
}

/// ===========================================
/// Helpery normalizacji
/// ===========================================

fn normalize_rel_path(input: &str) -> String {
    // Normalizacja pod Windows/Linux w manifeście trzymamy zawsze slash "/"
    let p = input.trim().replace('\\', "/");
    let p = p.trim_start_matches("./").to_string();
    p
}

fn normalize_opt_string(v: Option<String>) -> Option<String> {
    v.and_then(|s| {
        let t = s.trim().to_string();
        if t.is_empty() { None } else { Some(t) }
    })
}

fn normalize_tags(tags: Vec<String>) -> Vec<String> {
    tags.into_iter()
        .map(|t| t.trim().to_lowercase())
        .filter(|t| !t.is_empty())
        .collect()
}

fn is_probably_executable(path: &str) -> bool {
    let p = path.to_ascii_lowercase();
    p.ends_with(".exe") || p.ends_with(".bat") || p.ends_with(".cmd")
}

fn infer_tags_from_path(path: &str) -> Vec<String> {
    let p = path.to_ascii_lowercase();
    let mut tags = Vec::new();

    if p.ends_with(".exe") || p.ends_with(".dll") {
        tags.push("client-bin".to_string());
    }
    if p.ends_with(".lua") {
        tags.push("lua".to_string());
    }
    if p.ends_with(".otui") {
        tags.push("otui".to_string());
    }
    if p.contains("/modules/") {
        tags.push("ui".to_string());
    }
    if p.contains("/data/") || p.contains("/assets/") {
        tags.push("asset".to_string());
    }

    tags
}
3) Rust serde — installed_state.json + transakcja update
3.1. Kod: installed_state.rs (roboczy szkic)
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

/// ===========================================
/// installed_state.json (lokalny stan techniczny)
/// ===========================================

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InstalledState {
    pub schema_version: String, // np. "1.0"

    pub install_id: String,     // UUID
    pub channel: String,        // stable/test/dev

    pub client_install_path: String,
    pub launcher_version: String,

    pub current_manifest_version: Option<String>,
    pub current_manifest_id: Option<String>,
    pub current_files_hash: Option<String>,

    pub last_successful_update_utc: Option<String>,
    pub last_update_attempt_utc: Option<String>,
    pub last_update_result: UpdateResult,

    pub last_error_code: Option<String>,
    pub last_error_message: Option<String>,

    pub last_api_base_url: String,

    #[serde(default = "default_true")]
    pub tls_enforced: bool,

    #[serde(default)]
    pub last_launcher_version_check_utc: Option<String>,

    #[serde(default)]
    pub last_known_server_manifest_version: Option<String>,

    #[serde(default)]
    pub last_token_request: Option<LastTokenRequestMeta>,

    pub update_transaction: UpdateTransaction,

    #[serde(default)]
    pub managed_files_index: BTreeMap<String, ManagedFileState>,
}

impl InstalledState {
    pub fn new_minimal(
        install_id: String,
        channel: String,
        client_install_path: String,
        launcher_version: String,
        api_base_url: String,
    ) -> Self {
        Self {
            schema_version: "1.0".to_string(),
            install_id,
            channel,
            client_install_path,
            launcher_version,
            current_manifest_version: None,
            current_manifest_id: None,
            current_files_hash: None,
            last_successful_update_utc: None,
            last_update_attempt_utc: None,
            last_update_result: UpdateResult::NeverRun,
            last_error_code: None,
            last_error_message: None,
            last_api_base_url: api_base_url,
            tls_enforced: true,
            last_launcher_version_check_utc: None,
            last_known_server_manifest_version: None,
            last_token_request: None,
            update_transaction: UpdateTransaction::idle(),
            managed_files_index: BTreeMap::new(),
        }
    }

    pub fn mark_error(&mut self, code: impl Into<String>, message: impl Into<String>, now_utc: String) {
        self.last_update_attempt_utc = Some(now_utc);
        self.last_update_result = UpdateResult::Failed;
        self.last_error_code = Some(code.into());
        self.last_error_message = Some(message.into());
    }

    pub fn clear_error(&mut self) {
        self.last_error_code = None;
        self.last_error_message = None;
    }
}

/// ===========================================
/// Metadane ostatniego requestu tokena (bez tokena!)
/// ===========================================

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LastTokenRequestMeta {
    pub requested_at_utc: String,
    pub launcher_version: String,
    pub manifest_version: Option<String>,
    pub files_hash_prefix: Option<String>, // np. pierwsze 8-12 znaków do diagnostyki
    pub result: TokenRequestResult,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum TokenRequestResult {
    #[default]
    Unknown,
    Success,
    Rejected,
    RateLimited,
    NetworkError,
}

/// ===========================================
/// updateTransaction - stan transakcji patchowania
/// ===========================================

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UpdateTransaction {
    pub tx_id: String, // UUID
    pub status: UpdateTxStatus,

    pub target_manifest_version: Option<String>,
    pub target_manifest_id: Option<String>,

    pub started_at_utc: Option<String>,
    pub updated_files: Vec<String>,
    pub backup_files: Vec<String>,

    pub delete_planned: Vec<String>,
    pub delete_applied: Vec<String>,

    pub staging_path: Option<String>,

    #[serde(default = "default_true")]
    pub resume_supported: bool,
}

impl UpdateTransaction {
    pub fn idle() -> Self {
        Self {
            tx_id: String::new(),
            status: UpdateTxStatus::Idle,
            target_manifest_version: None,
            target_manifest_id: None,
            started_at_utc: None,
            updated_files: Vec::new(),
            backup_files: Vec::new(),
            delete_planned: Vec::new(),
            delete_applied: Vec::new(),
            staging_path: None,
            resume_supported: true,
        }
    }

    pub fn begin(&mut self, tx_id: String, manifest_version: String, manifest_id: String, now_utc: String, staging_path: String) {
        self.tx_id = tx_id;
        self.status = UpdateTxStatus::Preparing;
        self.target_manifest_version = Some(manifest_version);
        self.target_manifest_id = Some(manifest_id);
        self.started_at_utc = Some(now_utc);
        self.updated_files.clear();
        self.backup_files.clear();
        self.delete_planned.clear();
        self.delete_applied.clear();
        self.staging_path = Some(staging_path);
    }

    pub fn mark_idle(&mut self) {
        *self = Self::idle();
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum UpdateTxStatus {
    #[default]
    Idle,
    Preparing,
    Downloading,
    Verifying,
    Applying,
    Finalizing,
    RollbackRequired,
    RollbackInProgress,
}

/// ===========================================
/// Stan lokalnego indeksu plików zarządzanych
/// ===========================================

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ManagedFileState {
    pub sha256: String,
    pub size: u64,
    pub manifest_version: String,
    pub managed: bool,
    pub installed_at_utc: String,

    #[serde(default)]
    pub tags: Vec<String>,

    #[serde(default)]
    pub was_modified_locally: bool,
}

/// ===========================================
/// Wynik ostatniego update'u
/// ===========================================

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum UpdateResult {
    #[default]
    NeverRun,
    Success,
    Failed,
    Partial,
    RollbackSuccess,
    RollbackFailed,
}

fn default_true() -> bool { true }
4) Parser v1 -> v2 — jak tego używać w launcher-core

Poniżej prosty przykład użycia parsera kompatybilnego i zapisu decyzji do installed_state:

fn load_and_prepare_manifest(
    manifest_json: &str,
    state: &mut InstalledState,
    now_utc: String,
) -> Result<NormalizedManifest, Box<dyn std::error::Error>> {
    let manifest = parse_manifest_compat(manifest_json).map_err(|e| {
        state.mark_error("LCH_MANIFEST_PARSE_FAILED", format!("{e:?}"), now_utc.clone());
        e
    })?;

    // Opcjonalnie: walidacja min wersji launchera
    if let Some(min_ver) = &manifest.min_launcher_version {
        // porównanie semver możesz dodać później (np. semver crate)
        // jeśli za stary launcher -> zwróć czytelny błąd i pokaż self-update
        let _ = min_ver;
    }

    state.clear_error();
    Ok(manifest)
}
5) Najważniejsze zasady walidacji (które warto dodać od razu)

To są rzeczy, które bardzo pomogą i ograniczą „dziwne” błędy w produkcji:

5.1. Walidacja ścieżek (koniecznie)

Dla każdego files[].path:

zakaz ..

zakaz ścieżek absolutnych (C:\, /root/...)

zakaz pustej ścieżki

normalizacja slashy do /

To ważne dla bezpieczeństwa patchera (path traversal).

Przykład helpera (prosty)
pub fn validate_safe_rel_path(path: &str) -> Result<(), String> {
    let p = path.replace('\\', "/");
    if p.trim().is_empty() {
        return Err("empty path".into());
    }
    if p.starts_with('/') {
        return Err("absolute path not allowed".into());
    }
    if p.contains("../") || p == ".." {
        return Err("path traversal not allowed".into());
    }
    if p.contains(':') {
        // Windows drive letters / ADS defense (prosty filtr)
        return Err("colon not allowed in relative manifest path".into());
    }
    Ok(())
}
5.2. Walidacja duplikatów path

Masz już w validate_basic(). To obowiązkowe.

5.3. Walidacja pól zależnych od action

action=file i managed=true → wymagaj sha256, size

action=delete → nie wymagaj sha256, size, url

5.4. Walidacja filesHashExpected

Na start może być opcjonalne (dla kompatybilności v1), ale dla v2 docelowo warto wymagać.

6) Minimalne API launcher-core (żeby Tauri był cienki)

Proponuję taki interfejs wewnętrzny (roboczo), żeby UI tylko wywoływał funkcje:

pub struct LauncherCore {
    // config, http client, paths, logger...
}

impl LauncherCore {
    pub fn check_launcher_version(&self) -> Result<(), LauncherError> { todo!() }

    pub fn fetch_manifest(&self, channel: &str) -> Result<NormalizedManifest, LauncherError> { todo!() }

    pub fn plan_update(&self, manifest: &NormalizedManifest) -> Result<UpdatePlan, LauncherError> { todo!() }

    pub fn apply_update(&self, manifest: &NormalizedManifest, plan: &UpdatePlan) -> Result<(), LauncherError> { todo!() }

    pub fn compute_files_hash(&self, manifest: &NormalizedManifest) -> Result<String, LauncherError> { todo!() }

    pub fn request_launch_token(
        &self,
        launcher_version: &str,
        manifest_version: Option<&str>,
        files_hash: &str,
        channel: &str,
    ) -> Result<String, LauncherError> { todo!() }

    pub fn launch_client_with_env(&self, token: &str) -> Result<(), LauncherError> { todo!() }

    pub fn repair_install(&self, manifest: &NormalizedManifest) -> Result<(), LauncherError> { todo!() }
}

To jest spójne z Twoim flow z planu (check version → update → filesHash → token → start klienta z env). 

01_DZIENNIK_PRAC

 

plan_zabezpieczenia_klienta_i_s…

7) Mapowanie v1 -> v2 (logika biznesowa, ważne decyzje)

Poniżej jawnie wypisuję, jak legacy v1 mapuje się do modelu v2/normalized:

schemaVersion brak → ustaw "1-compat"

manifestId brak → generuj "${channel}:${version}"

generatedAtUtc brak → None

filesHashExpected brak → None

servers[] brak → pusta lista

signature brak → None

files[].managed → true

files[].action → file

files[].required → true

files[].includeInFilesHash → true

files[].overwritePolicy → if_hash_differs

files[].deletePolicy → protect

To daje pełną kompatybilność bez łamania starego endpointu.

8) Co dopiąć jako następny krok (bardzo praktyczne)

Żeby to realnie ruszyło w kodzie, następny sensowny krok to:

UpdatePlan struct + planner

to_download

to_replace

to_delete

to_keep

compute_files_hash() referencyjne

dokładnie wg Twojego planu (MISSING, sort po path, hash z lokalnych plików)

installed_state read/write atomic

zapis do temp + rename

test fixtures

1x manifest v1

1x manifest v2

kilka lokalnych plików do testów patchera

9) Ważna uwaga praktyczna pod Tauri (żeby nie było miny)

Tauri UI powinien dostawać z launcher-core prosty DTO/status, a nie całe surowe struktury manifestu. Dzięki temu:

UI nie zależy od zmian schematu,

łatwiej utrzymać kompatybilność,

mniej ryzyka, że logika bezpieczeństwa „wycieknie” do frontendu.

Jeśli chcesz, mogę teraz przygotować kolejny element (już stricte pod implementację):

UpdatePlan + algorytm planowania zmian (to_download / to_replace / to_delete / to_keep)

oraz referencyjną funkcję compute_files_hash() w Rust zgodną 1:1 z Twoim planem (w tym MISSING, sortowanie i reguły includeInFilesHash).