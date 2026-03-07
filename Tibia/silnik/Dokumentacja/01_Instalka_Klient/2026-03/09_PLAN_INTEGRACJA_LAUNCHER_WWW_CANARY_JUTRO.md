# Plan Integracji na Jutro — Launcher + WWW/RedDAXE + Canary
**Data planu:** 2026-03-06  
**Dzień realizacji:** 2026-03-07  
**Tryb:** integracja E2E przed finalnym `START GHA`  
**Zakaz:** brak lokalnych kompilacji do czasu zamknięcia gate'ów integracyjnych

## 1. Cel integracji
1. Jedno konto globalne działa spójnie na 3 frontach: launcher, WWW Tibia, RedDAXE.
2. Canary `classic74` i `modern` działają równolegle, z poprawnym routowaniem postaci i sesji.
3. Po loginie w launcherze użytkownik nie loguje się ponownie na WWW/instalce.
4. Tworzenie postaci jest rozdzielone per serwer, ale dostępne z jednego konta globalnego.
5. Przed kompilacją mamy zamkniętą matrycę PASS/FAIL/BLOCKED dla krytycznych flow.

## 2. Zakres systemów
1. Launcher Rust/Tauri + launcher-cli.
2. API (`/apik/v1/*`) dla loginu, tokenów sync, contextu konta i statusów.
3. WWW Tibia (CanaryAAC + legacy `index.php/*`) i portal RedDAXE.
4. Canary server: `classic74` + `modern`, ticket flow i mapowanie `worldId/gameMode`.
5. Bazy danych: `canaryaac` + `canary_modern` oraz synchronizacja kont.

## 3. Kontrakty integracyjne (must-have)
1. `login.php` zwraca spójny `sessionKey` + worlds context.
2. `account-context.php` zwraca postacie per świat (`classic74/modern`) i nie gubi `mode`.
3. `account-sync-token.php` i `account-sync-consume.php` działają one-time + TTL.
4. `ticket.php` odrzuca mismatch postać/świat (`fail-closed`).
5. `toplist.php` i `players-list.php` obsługują `all/classic74/modern`.
6. `launcher-version.php` i manifest mają spójne wersjonowanie.

## 4. Krytyczne flow E2E (P0)
1. Rejestracja konta globalnego w launcherze -> auto-login -> context PASS.
2. Rejestracja konta globalnego na WWW/RedDAXE -> login w launcherze PASS.
3. Launcher -> „Utwórz postać Classic” -> WWW -> powrót -> start gry PASS.
4. Launcher -> „Utwórz postać Modern” -> WWW -> powrót -> start gry PASS.
5. Login launcher -> przejście na WWW bez drugiego logowania PASS.
6. Brak postaci na serwerze -> blokada „Graj” + czytelny komunikat PASS.
7. `gameMode=all` -> wymuszony wybór serwera przed ticket/start PASS.
8. Ticket replay/mismatch -> poprawna blokada PASS.
9. Legacy trasy WWW (`index.php/account/*`, `index.php/online`, `index.php/highscores`) działają bez regresji krytycznych.
10. RedDAXE i WWW mają spójny stan sesji konta globalnego.

## 5. Backlog integracyjny na jutro
Legenda:
1. `INT-P0`: blokuje kompilację.
2. `INT-P1`: wysokie, wymagane przed RC.
3. `INT-P2`: domknięcie jakościowe po pierwszym buildzie.

### 5.1 Launcher <-> API
1. `INT-P0-01`: potwierdzić login natywny launcher -> `sessionKey`.
2. `INT-P0-02`: potwierdzić rejestrację natywną launcher -> konto globalne.
3. `INT-P0-03`: po loginie launcher pobiera `account-context` i poprawnie mapuje serwery.
4. `INT-P0-04`: launcher wymusza wybór serwera, gdy `mode=all`.
5. `INT-P0-05`: launcher blokuje start przy braku postaci na wybranym serwerze.
6. `INT-P1-06`: fallback dla expired sync token (retry + czytelny komunikat).
7. `INT-P1-07`: telemetryczny log błędów login/context (bez tokenów w logach).
8. `INT-P1-08`: kompatybilność wersji launcher vs manifest vs API.
9. `INT-P2-09`: finalna checklista smoke launchera na czystym Windows.
10. `INT-P2-10`: checklista regresji UI i18n w launcherze (PL/EN).

### 5.2 API <-> WWW/RedDAXE
1. `INT-P0-11`: flow token issue/consume one-time + replay test.
2. `INT-P0-12`: flow WWW-account -> launcher login (bez manualnych tokenów).
3. `INT-P0-13`: flow launcher-account -> WWW create-character (auto-login).
4. `INT-P0-14`: flow RedDAXE-account -> WWW + launcher (jedno konto globalne).
5. `INT-P1-15`: normalizacja błędów API (`code/message/details`) na krytycznych endpointach.
6. `INT-P1-16`: audyt logów pod wyciek tokenów/sesji.
7. `INT-P1-17`: rate-limit i anti-abuse dla sync i OAuth endpointów.
8. `INT-P2-18`: tabela kompatybilności endpointów legacy vs nowe trasy.
9. `INT-P2-19`: checklista rotacji sekretów po zamknięciu integracji.
10. `INT-P2-20`: runbook „jak debugować sync token flow”.

### 5.3 WWW/RedDAXE <-> Canary
1. `INT-P0-21`: create-character trafia do poprawnej bazy wg `mode`.
2. `INT-P0-22`: highscores/online/players-list respektują `all/classic74/modern`.
3. `INT-P0-23`: krytyczne trasy 404 usunięte (`community/highscores`, `shop/payment` lub jawne fallbacki).
4. `INT-P0-24`: rules `all/classic74/modern` działają i są podpięte do flow rejestracji.
5. `INT-P1-25`: i18n konta i krytycznych widoków bez mix EN/PL.
6. `INT-P1-26`: anti-clipping 100/125/150% dla widoków krytycznych.
7. `INT-P1-27`: persystencja wyboru serwera w sesji WWW.
8. `INT-P2-28`: finalny smoke legacy `index.php/*` + nowy routing.
9. `INT-P2-29`: FAQ „jedno konto globalne, postacie per serwer”.
10. `INT-P2-30`: lista known issues WWW/RedDAXE po dniu integracji.

### 5.4 Canary + DB split
1. `INT-P0-31`: triggery sync kont `canaryaac <-> canary_modern` działają poprawnie.
2. `INT-P0-32`: initial sync brakujących kont bez konfliktów.
3. `INT-P0-33`: ticket flow odrzuca cross-server mismatch.
4. `INT-P0-34`: world map (`classic74=0`, `modern=1`, `all`) spójny we wszystkich warstwach.
5. `INT-P1-35`: test degradacji (odpięcie modern) z przewidywalnym fallbackiem.
6. `INT-P1-36`: testy list/topki osobno i agregowane.
7. `INT-P1-37`: monitoring DB health i lag sync.
8. `INT-P2-38`: SQL snapshot + restore drill.
9. `INT-P2-39`: runbook awaryjny dual-db.
10. `INT-P2-40`: backlog hardening (anti-silent-fallback).

## 6. Matryca testów integracyjnych (obowiązkowa)
1. `T-INT-01`: launcher register -> context -> PASS.
2. `T-INT-02`: WWW register -> launcher login -> PASS.
3. `T-INT-03`: RedDAXE register -> WWW login -> PASS.
4. `T-INT-04`: launcher create-character classic74 -> PASS.
5. `T-INT-05`: launcher create-character modern -> PASS.
6. `T-INT-06`: tryb `all` bez postaci -> blokada startu -> PASS.
7. `T-INT-07`: sync token replay -> 409/odrzucenie -> PASS.
8. `T-INT-08`: mismatch ticket/world -> odrzucenie -> PASS.
9. `T-INT-09`: legacy `index.php/account/create` -> brak false CSRF -> PASS.
10. `T-INT-10`: `index.php/highscores` + `community/highscores` -> PASS.
11. `T-INT-11`: `shop/payment` z kontekstem serwera -> PASS.
12. `T-INT-12`: i18n PL/EN i brak krytycznych mixed strings -> PASS.

## 7. Harmonogram integracji (jutro)
1. `08:00-09:30`: Launcher/API kontrakty i login/context (`INT-P0-01..05`).
2. `09:30-11:00`: Sync token + WWW/RedDAXE flow (`INT-P0-11..14`).
3. `11:00-12:30`: Canary/DB split + ticket validations (`INT-P0-31..34`).
4. `12:30-14:00`: Create-character per serwer + powrót do launchera (`INT-P0-21..24`).
5. `14:00-15:30`: Trasy krytyczne WWW + i18n/clipping (`INT-P1-25..27`).
6. `15:30-17:00`: Matryca testów `T-INT-01..12`, wpisy PASS/FAIL/BLOCKED.
7. `17:00-18:00`: Zamknięcie gate integracyjnego + decyzja `go/no-go`.

## 8. Gate integracyjny przed kompilacją
1. `G-INT-01`: wszystkie `INT-P0` mają PASS lub jawny BLOCKED z obejściem.
2. `G-INT-02`: matryca `T-INT-01..12` wykonana i opisana.
3. `G-INT-03`: brak krytycznych 404 na trasach wymaganych przez launcher i WWW.
4. `G-INT-04`: konto globalne działa na launcher + WWW + RedDAXE.
5. `G-INT-05`: create-character per-serwer działa i blokady są poprawne.
6. `G-INT-06`: dokumentacja (`00`, `01`, `07`, `08`, `09`) zaktualizowana.
7. `G-INT-07`: decyzja `START GHA` zaakceptowana po gate globalnym + installerowym + integracyjnym.

## 9. Definition of Done (integracja)
1. Launcher, WWW i RedDAXE współdzielą jedno konto globalne bez rozjazdu sesji.
2. Gracz tworzy osobne postacie dla Classic/Modern i uruchamia właściwy serwer.
3. Krytyczne flow są potwierdzone testami i wpisane do dokumentacji.
4. Brak lokalnych kompilacji podczas realizacji planu integracyjnego.

## 10. Ryzyka i mitigacje
1. Ryzyko: rozjazd legacy route vs nowy routing.
   Mitigacja: testy równoległe `index.php/*` i nowych tras + fallbacki.
2. Ryzyko: cache/uprawnienia maskują zmiany runtime.
   Mitigacja: jawny runbook cache + wpisy BLOCKED z obejściem.
3. Ryzyko: expired token podczas przejścia launcher->WWW.
   Mitigacja: retry/refresh flow + komunikaty i fallback.
4. Ryzyko: niespójne mapowanie `mode/worldId`.
   Mitigacja: testy kontraktowe API + ticket validation.
5. Ryzyko: mieszane i18n utrudnia testy użytkownika.
   Mitigacja: oddzielna matryca PL/EN i odhaczanie krytycznych ekranów.

## 11. Mapowanie na checklistę (`K120-K149`)
1. `K120-K129`: Launcher/API integracja (`INT-P0-01..INT-P2-10`).
2. `K130-K139`: API/WWW/RedDAXE + Canary (`INT-P0-11..INT-P2-30`).
3. `K140-K145`: DB split + ticket + monitoring (`INT-P0-31..INT-P2-40`).
4. `K146-K149`: matryca testów, gate integracyjny i decyzja `go/no-go`.
