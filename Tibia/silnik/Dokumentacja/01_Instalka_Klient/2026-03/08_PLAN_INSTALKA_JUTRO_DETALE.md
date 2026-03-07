# Plan Instalki na Jutro — Szczegóły Operacyjne
**Data planu:** 2026-03-06  
**Dzień realizacji:** 2026-03-07  
**Zakres:** instalka dev + instalka gracza + bootstrap launcher + update + recovery + testy

## 1. Co znaczy „instalka gotowa”
1. Gracz pobiera paczkę, uruchamia launcher i bez ręcznej konfiguracji przechodzi do gry.
2. Aktualizacja klienta działa automatycznie i bezpiecznie (checksum, retry, rollback).
3. Po zalogowaniu w launcherze nie ma dodatkowego logowania w instalce/kliencie.
4. Przy `all` gracz wybiera serwer i postać; brak postaci blokuje start z jasnym komunikatem.
5. Paczka gracza nie zawiera plików developerskich ani sekretów.

## 2. Artefakty i kontrakty
### 2.1 Artefakty wejściowe
1. `launcher-tauri(.exe)`
2. `launcher-cli(.exe)`
3. `client package` (`otclient.exe` + zasoby)
4. `manifest` + `signature` + `checksums`

### 2.2 Artefakty wyjściowe (gracz)
1. `player_package/launcher*`
2. `player_package/client/*`
3. `player_package/launcher_config.json`
4. `player_package/manifest.json` (jeśli lokalnie cache’owany)
5. `player_package/README_START.txt` (instrukcja dla gracza)

### 2.3 Kontrakty API (instalka)
1. `launcher-version.php`
2. `generate_manifest.php` / endpoint manifestu
3. `login.php`
4. `ticket.php`
5. `account-context.php`
6. `account-sync-token.php`
7. `account-sync-consume.php`

## 3. Backlog instalki (bardzo szczegółowy)
Legenda:
1. `INS-P0` blokuje kompilację i publikację.
2. `INS-P1` wymagane do stabilnego RC.
3. `INS-P2` poprawki po pierwszej kompilacji.

### 3.1 Packaging i separacja dev/gracz
1. `INS-P0-01`: potwierdzić finalną strukturę folderów paczki gracza.
2. `INS-P0-02`: wdrożyć allowlist plików do paczki gracza.
3. `INS-P0-03`: wdrożyć denylist plików dev/test/debug.
4. `INS-P0-04`: sprawdzić brak sekretów i tokenów w paczce.
5. `INS-P0-05`: sprawdzić brak źródeł `.cpp/.rs/.lua` z toru developerskiego.
6. `INS-P0-06`: sprawdzić brak plików CI/GHA i narzędzi build.
7. `INS-P1-07`: dodać raport diff dev->gracz (co wycięto).
8. `INS-P1-08`: dodać automatyczny test „package lint”.
9. `INS-P1-09`: dopisać metadane wersji i kanału w paczce.
10. `INS-P1-10`: ujednolicić nazewnictwo ZIP i folderów publikacyjnych.

### 3.2 Bootstrap i pierwsze uruchomienie
1. `INS-P0-11`: launcher wykrywa brak klienta i uruchamia bootstrap download.
2. `INS-P0-12`: pierwszy start wymusza walidację manifestu i podpisu.
3. `INS-P0-13`: pierwszy start kończy się statusem PASS/FAIL z kodem błędu.
4. `INS-P0-14`: flow błędu sieci pokazuje „Ponów/Napraw/Zamknij”.
5. `INS-P1-15`: dodać progress bar z liczbą plików i ETA.
6. `INS-P1-16`: dodać retry policy (timeout/backoff/max attempts).
7. `INS-P1-17`: dodać rozróżnienie błędu API vs uszkodzonego pliku.
8. `INS-P1-18`: dodać log startup diagnostics do folderu logów.
9. `INS-P2-19`: onboarding wizard (konto globalne -> serwer -> postać).
10. `INS-P2-20`: onboarding PL/EN (bez mixu językowego).

### 3.3 Aktualizacje i integralność
1. `INS-P0-21`: wdrożyć twarde sprawdzanie checksum wszystkich plików krytycznych.
2. `INS-P0-22`: wdrożyć blokadę startu przy niezgodności pliku krytycznego.
3. `INS-P0-23`: dodać auto-repair z manifestu dla pliku krytycznego.
4. `INS-P0-24`: wdrożyć atomowy update (temp -> verify -> swap).
5. `INS-P1-25`: wdrożyć rollback po nieudanym swap.
6. `INS-P1-26`: wdrożyć handling przerwanego pobrania (resume).
7. `INS-P1-27`: test delta update jednego pliku.
8. `INS-P1-28`: test update wielu plików równolegle.
9. `INS-P1-29`: test update przy pełnym dysku.
10. `INS-P1-30`: test update przy braku uprawnień zapisu.
11. `INS-P2-31`: wersjonowanie cache manifestu i czyszczenie starych wersji.
12. `INS-P2-32`: polityka retention lokalnych backupów update.

### 3.4 SSO launcher -> instalka/klient
1. `INS-P0-33`: przekazanie sesji/tokenu z launchera do klienta bez ręcznego logowania.
2. `INS-P0-34`: walidacja tokenu po stronie klienta/serwera przed startem.
3. `INS-P0-35`: blokada startu gry przy nieważnej sesji.
4. `INS-P0-36`: komunikat „zaloguj ponownie w launcherze” przy expired token.
5. `INS-P0-37`: przy `all` wymusić wybór serwera przed startem.
6. `INS-P0-38`: przy braku postaci na wybranym serwerze zablokować start i podać link create-character.
7. `INS-P1-39`: po utworzeniu postaci odświeżyć context bez restartu launchera.
8. `INS-P1-40`: potwierdzić, że tokeny nie trafiają do jawnych logów.
9. `INS-P1-41`: potwierdzić czyszczenie tokenu z pamięci po starcie.
10. `INS-P2-42`: test „zmiana konta w launcherze” i reset kontekstu instalki.

### 3.5 Konfiguracja runtime i profile
1. `INS-P0-43`: profile `dev/stage/prod` mają spójne endpointy.
2. `INS-P0-44`: profile wymuszają HTTPS na endpointach.
3. `INS-P0-45`: walidacja schematu `launcher_config.json` przed użyciem.
4. `INS-P1-46`: walidacja mapowania portów `7172/7174` i game mode.
5. `INS-P1-47`: test niepoprawnego configu (czytelny błąd + stop).
6. `INS-P1-48`: fallback na domyślny config tylko gdy bezpieczny i jawnie sygnalizowany.
7. `INS-P2-49`: eksport aktywnego profilu do diagnostics.
8. `INS-P2-50`: checklista „switch prod <-> stage”.

### 3.6 Recovery i wsparcie
1. `INS-P1-51`: `repair mode` — pełny verify i automatyczna naprawa.
2. `INS-P1-52`: `safe reset` cache/settings bez kasowania kont i postaci.
3. `INS-P1-53`: gotowy pakiet logs+diag do zgłoszenia support.
4. `INS-P1-54`: mapowanie kodów błędów instalatora na instrukcje naprawcze.
5. `INS-P2-55`: skrypt czystego uninstall.
6. `INS-P2-56`: dokument „Top 15 problemów instalki i rozwiązania”.

### 3.7 Test matrix (obowiązkowe)
1. `INS-P0-57`: Windows 10 — first install PASS.
2. `INS-P0-58`: Windows 11 — first install PASS.
3. `INS-P0-59`: no-admin user — install/update PASS.
4. `INS-P0-60`: ścieżka z polskimi znakami — PASS.
5. `INS-P0-61`: ścieżka z odstępami — PASS.
6. `INS-P0-62`: brak postaci na serwerze — poprawna blokada startu.
7. `INS-P1-63`: wolne łącze i timeout — retry PASS.
8. `INS-P1-64`: rozłączenie sieci podczas update — recovery PASS.
9. `INS-P1-65`: uszkodzony plik klienta — auto-repair PASS.
10. `INS-P1-66`: stale manifest — poprawna obsługa.
11. `INS-P1-67`: równoległe uruchomienie 2 launcherów — lock PASS.
12. `INS-P1-68`: update przy uruchomionej grze — defer PASS.
13. `INS-P2-69`: testy smoke po aktualizacji launchera.
14. `INS-P2-70`: testy regresji dzień po kompilacji.

### 3.8 Integracja konto globalne + WWW + RedDAXE (przed kompilacją)
1. `INS-P0-71`: flow `launcher login -> instalka -> start` bez ponownego logowania.
2. `INS-P0-72`: flow `WWW create-character -> powrót do launchera` z zachowaniem `mode`.
3. `INS-P0-73`: flow `konto założone na RedDAXE -> login launcher` (pełna zgodność konta globalnego).
4. `INS-P0-74`: wymusić odświeżenie `account-context` po utworzeniu postaci na WWW.
5. `INS-P0-75`: blokada startu gry gdy `account-context` nie ma postaci dla wybranego serwera.
6. `INS-P1-76`: przycisk „Utwórz postać Classic/Modern” w installer flow z poprawnym deep-linkiem.
7. `INS-P1-77`: komunikaty SSO i create-character spójne w PL/EN.
8. `INS-P1-78`: obsługa błędu expired token z automatycznym retry i czytelną instrukcją.
9. `INS-P1-79`: odświeżenie UI listy postaci bez restartu aplikacji.
10. `INS-P1-80`: test konfliktu sesji (zmiana konta w przeglądarce vs launcher) i poprawna resynchronizacja.
11. `INS-P2-81`: telemetryczne eventy dla etapów `login/context/create-character/start`.
12. `INS-P2-82`: gotowy tekst FAQ „jedno konto globalne, osobne postacie na serwerach”.
13. `INS-P2-83`: checklista UX „gracz nowy” vs „gracz wracający z WWW”.
14. `INS-P2-84`: walidacja copy i microcopy pod support (bez skrótów technicznych).
15. `INS-P2-85`: przygotować backlog integracji social login bezpiecznie (Google/Facebook/Steam).

### 3.9 Akceptacja release i wsparcie po publikacji
1. `INS-P0-86`: checklista `go/no-go` dla instalki przed kompilacją.
2. `INS-P0-87`: checklista `go/no-go` po kompilacji i przed publikacją paczki gracza.
3. `INS-P1-88`: minimalny zestaw metryk po publikacji (error rate, update failures, login failures).
4. `INS-P1-89`: alarmy dla przekroczenia progów błędów (pierwsze 24h).
5. `INS-P1-90`: procedura hotfix i rollback (kto, kiedy, na podstawie czego).
6. `INS-P1-91`: runbook „jak odtworzyć problem gracza z logów i diagnostyki”.
7. `INS-P1-92`: wzór odpowiedzi support na najczęstsze kody błędów.
8. `INS-P1-93`: tabela „kod błędu -> akcja gracza -> akcja supportu”.
9. `INS-P2-94`: raport dzienny po publikacji (`PASS/FAIL/BLOCKED` + liczby).
10. `INS-P2-95`: plan porządkowania długów technicznych instalki po pierwszym RC.
11. `INS-P2-96`: lista „co przenosimy do etapu NSIS/Inno”.
12. `INS-P2-97`: lista „co zostaje w launcher bootstrap i nie idzie do pełnego instalatora”.
13. `INS-P2-98`: SLA support dla błędów krytycznych (`P0`) i wysokich (`P1`).
14. `INS-P2-99`: definicja freeze po publikacji (okno bez zmian wysokiego ryzyka).
15. `INS-P2-100`: podsumowanie lessons learned do kolejnego release.

## 4. Gate instalki przed kompilacją
1. `G-INS-01`: wszystkie `INS-P0` mają PASS.
2. `G-INS-02`: raport package lint PASS.
3. `G-INS-03`: raport security package scan PASS.
4. `G-INS-04`: matryca Windows (min. 10/11 + no-admin) PASS.
5. `G-INS-05`: SSO launcher->klient PASS na obu serwerach.
6. `G-INS-06`: create-character gating PASS.
7. `G-INS-07`: update + rollback scenariusz PASS.

## 5. Gate instalki po kompilacji
1. `PG-INS-01`: artefakty skompilowane i podpisane.
2. `PG-INS-02`: paczka gracza zbudowana z właściwej gałęzi i wersji.
3. `PG-INS-03`: manifest release wygenerowany i podpisany.
4. `PG-INS-04`: update ze starszej wersji klienta PASS.
5. `PG-INS-05`: szybki smoke login globalny + wybór serwera + start gry PASS.

## 6. Wymagane wpisy do dokumentacji podczas realizacji
1. Każdy `INS-P0` po zamknięciu: wpis do `01_DZIENNIK_PRAC.md`.
2. Każdy build artefaktu: wpis do `02_DZIENNIK_BUILDOW_GHA.md`.
3. Każdy nowy bug instalatora: wpis do `00_START_PRACY_CHECKLISTA.md` (nowe K-task).
4. Koniec dnia: podsumowanie PASS/FAIL/BLOCKED i decyzja o kompilacji.

## 7. Harmonogram instalki na jutro (bez kompilacji lokalnej)
1. `08:00-09:00`: packaging audit (`INS-P0-01..06`) + potwierdzenie struktury paczki.
2. `09:00-10:00`: bootstrap i first-run flow (`INS-P0-11..14`).
3. `10:00-11:00`: integralność update (`INS-P0-21..24`).
4. `11:00-12:00`: SSO launcher->instalka (`INS-P0-33..38`).
5. `12:00-13:00`: integracja konto globalne/WWW (`INS-P0-71..75`).
6. `13:00-14:00`: profile i config hardening (`INS-P0-43..45`).
7. `14:00-15:00`: test matrix P0 (`INS-P0-57..62`) i wpisy PASS/FAIL.
8. `15:00-16:00`: domknięcie `G-INS-01..07`.
9. `16:00-17:00`: P1 runtime polish (`INS-P1-63..80`).
10. `17:00-18:00`: finalny raport instalki + decyzja `go/no-go` (`INS-P0-86`, `INS-P0-87`).

## 8. Definition of Done instalki (jutro)
1. Wszystkie zadania `INS-P0` są `PASS` albo mają jawny `BLOCKED` z obejściem zaakceptowanym w dzienniku.
2. Gate `G-INS-01..07` jest zamknięty.
3. Checklista główna ma uzupełnione statusy `K90-K119`.
4. Dokumentacja zawiera pełny stan: co działa, co nie działa, co blokuje kompilację.
5. Brak lokalnych kompilacji Rust/Tauri/serwera podczas realizacji tego planu.

## 9. Ryzyka instalki i działania
1. Ryzyko: mismatch wersji launcher/manifest. Działanie: blokada startu + jasny komunikat + wymuszony update.
2. Ryzyko: cache/runtime permissions (`Permission denied`). Działanie: runbook uprawnień + test na użytkowniku bez admina.
3. Ryzyko: wygasłe tokeny SSO. Działanie: retry/refresh + fallback do ponownego loginu w launcherze.
4. Ryzyko: mieszanie kont po zmianie sesji w przeglądarce. Działanie: refresh context + hard reset sesji lokalnej.
5. Ryzyko: pliki dev/debug w paczce gracza. Działanie: allowlist+denylist + package lint + security scan.
6. Ryzyko: niespójne i18n i nieczytelne błędy dla gracza. Działanie: test PL/EN + review copy support.

## 10. Mapowanie na checklistę główną (`K90-K119`)
1. `K90-K94`: packaging, bootstrap, update, recovery (`INS-P0-01..32`, `INS-P1-51..56`).
2. `K95-K99`: SSO + create-character gating + config/profile + test matrix (`INS-P0-33..62`, `INS-P0-71..75`).
3. `K100-K104`: i18n onboarding, rules links, health check endpointów, compatibility i lock-file (`INS-P1-76..80`, `INS-P1-67..68`).
4. `K105-K109`: integrity/preflight/support/release/post-release (`INS-P1-29..30`, `INS-P1-88..93`).
5. `K110-K112`: error-code mapping i gate `G-INS`/`PG-INS`.
6. `K113-K119`: obowiązkowe aktualizacje dokumentacji, harmonogram i decyzja końcowa `go/no-go`.

## 11. Polityka „bez lokalnej kompilacji” dla instalki
1. Do czasu zamkniecia `G-INS-01..07` i globalnych gate'ow (`J-GATE-*`) nie wykonujemy lokalnej kompilacji launchera/klienta/serwera.
2. Wszystkie kompilacje i walidacje artefaktow wykonujemy wyłącznie przez GitHub Actions po formalnej decyzji `GO`.
3. W tym oknie dopuszczalne sa tylko:
	- zmiany kodu,
	- aktualizacje dokumentacji,
	- uzupelnianie checklist,
	- przygotowanie raportow i matryc PASS/FAIL/BLOCKED.
4. Naruszenie polityki wymaga wpisu incydentu w `01_DZIENNIK_PRAC.md` i resetu decyzji do `NO-GO` do czasu ponownej oceny.

## 12. Szablon zamkniecia gate `G-INS-01..07` (K111)
1. Data/czas zamkniecia:
2. Odpowiedzialny:
3. Wynik gate: `PASS` / `FAIL` / `BLOCKED`
4. Dowody:
	- `G-INS-01` (`INS-P0`):
	- `G-INS-02` (package lint):
	- `G-INS-03` (security scan):
	- `G-INS-04` (Windows matrix):
	- `G-INS-05` (SSO 2 serwery):
	- `G-INS-06` (create-character gating):
	- `G-INS-07` (update + rollback):
5. Znane ryzyka po zamknieciu gate:
6. Decyzja pre-build: `GO` / `NO-GO`
7. Linki do wpisow: `01_DZIENNIK_PRAC.md`, `00_START_PRACY_CHECKLISTA.md`

## 13. Szablon decyzji po kompilacji `PG-INS-01..05` (K112/K118)
1. Data/czas oceny post-build:
2. Wersja builda / artefaktow:
3. Wynik gate post-build: `PASS` / `FAIL` / `BLOCKED`
4. Dowody:
	- `PG-INS-01` (artefakty + podpis):
	- `PG-INS-02` (paczka z właściwej gałęzi):
	- `PG-INS-03` (manifest release + podpis):
	- `PG-INS-04` (update ze starszej wersji):
	- `PG-INS-05` (smoke login + wybor serwera + start gry):
5. Decyzja publikacji paczki gracza: `GO` / `NO-GO`
6. Plan rollback/hotfix (gdy `FAIL` albo `BLOCKED`):
7. Linki do wpisow: `02_DZIENNIK_BUILDOW_GHA.md`, `19_CHECKLISTA_PUBLIKACJI_PACZKI_GRACZA.md`, `20_CHECKLISTA_MONITORING_24H_PO_PUBLIKACJI.md`

## 14. Checkpointy godzinowe 08:00-18:00 (K114)
1. `08:00` Start dnia: potwierdzenie scope i ownerow blokow `INS-P0`.
	- Dowod: wpis startowy w `01_DZIENNIK_PRAC.md`.
2. `09:00` Checkpoint packaging (`INS-P0-01..06`).
	- Kryterium: status `PASS/FAIL/BLOCKED` dla kazdego punktu + link do dowodu.
3. `10:00` Checkpoint bootstrap (`INS-P0-11..14`).
	- Kryterium: gotowa ocena first-run + kody bledow dla scenariuszy FAIL.
4. `11:00` Checkpoint integralnosc update (`INS-P0-21..24`).
	- Kryterium: potwierdzony flow verify/repair/rollback na poziomie dokumentacyjnym i kodowym.
5. `12:00` Checkpoint SSO (`INS-P0-33..38`).
	- Kryterium: decyzja PASS/FAIL/BLOCKED dla login->start bez ponownego logowania.
6. `13:00` Checkpoint konto globalne/WWW (`INS-P0-71..75`).
	- Kryterium: potwierdzone create-character gating + odswiezanie kontekstu.
7. `14:00` Checkpoint profile/config (`INS-P0-43..45`).
	- Kryterium: HTTPS-only poza dev + schema validation + status endpointow.
8. `15:00` Checkpoint test matrix P0 (`INS-P0-57..62`).
	- Kryterium: wpisany wynik per scenariusz i jawne blokery.
9. `16:00` Checkpoint gate `G-INS-01..07`.
	- Kryterium: uzupelniony szablon z sekcji 12 + decyzja pre-build `GO/NO-GO`.
10. `17:00` Checkpoint P1 runtime polish (`INS-P1-63..80`).
	- Kryterium: lista domknietych tematow i tematow przeniesionych po buildzie.
11. `18:00` Raport koncowy dnia.
	- Kryterium: decyzja `GO/NO-GO` dla instalki + lista ryzyk rezydualnych + linki do wpisow.
