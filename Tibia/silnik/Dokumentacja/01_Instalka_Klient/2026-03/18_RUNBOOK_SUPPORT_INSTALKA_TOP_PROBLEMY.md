# Runbook Support Instalka - Top Problemy i Scenariusze Naprawcze

Data: 2026-03-06
Zakres: K107

## 1. Cel
Runbook dla supportu przy wdrozeniu auto-update launchera i instalki.
Priorytet: utrzymac integralnosc plikow, sesji i endpointow bez lokalnej kompilacji.

## 2. Szybka klasyfikacja incydentu
1. P0 (krytyczne): launcher nie startuje, update loop, masowy fail tokenow, uszkodzony manifest.
2. P1 (wysokie): fail update pojedynczych userow, problemy TLS/endpoint, brak miejsca.
3. P2 (srednie): problemy UX/i18n, pojedyncze fallbacki create-character.

## 3. Top problemy i naprawa
1. Objaw: launcher blokuje start z `LCH_LAUNCHER_UPDATE_REQUIRED`.
Akcja: sprawdz `launcher-version.php` (`version`, `minVersion`, `required`), potwierdz poprawny URL i sha256 paczki.
2. Objaw: `LCH_MANIFEST_FETCH_FAILED` / `LCH_MANIFEST_PARSE_FAILED`.
Akcja: sprawdz `update.php?channel=*`, walidnosc JSON, dostepnosc HTTPS i cert.
3. Objaw: `LCH_MANIFEST_SIGNATURE_INVALID`.
Akcja: potwierdz zgodnosc podpisu i `manifestPublicKey` w configu launchera.
4. Objaw: `LCH_FILE_HASH_MISMATCH` / `LCH_PATCH_APPLY_FAILED`.
Akcja: uruchom repair flow; sprawdz staging i prawa zapisu w `client_dir`.
5. Objaw: anti-tamper trigger (critical files modified).
Akcja: potwierdz utworzenie `launcher_data/quarantine/critical-*`, potem redownload przez update.
6. Objaw: `LCH_PREFLIGHT_INSUFFICIENT_SPACE`.
Akcja: zwolnij miejsce; wymagane minimum: update (download*2 + overhead), launch (min free threshold).
7. Objaw: `LCH_PREFLIGHT_NOT_WRITABLE`.
Akcja: popraw uprawnienia do `client_dir` i `launcher_data_dir`.
8. Objaw: `LCH_TLS_REQUIRED`.
Akcja: sprawdz profile config; poza `dev` endpointy musza byc HTTPS.
9. Objaw: `LCH_TOKEN_REQUEST_FAILED` / `LCH_TOKEN_REJECTED`.
Akcja: sprawdz `launcher-token.php`, `login.php`, `account-context.php`, rate-limit i sesje.
10. Objaw: `LCH_CLIENT_NOT_FOUND` / `LCH_CLIENT_START_FAILED`.
Akcja: potwierdz obecny binary klienta i poprawny working dir; w razie potrzeby repair/update.

## 4. Procedura support (standard)
1. Zbieranie danych: kod bledu `LCH_*`, timestamp, channel, launcher version, manifest version.
2. Potwierdzenie endpointow: `launcher-version`, `update`, `login`, `account-context`.
3. Ocena integralnosci: pre-launch check, anti-tamper, files hash.
4. Decyzja: retry / repair / rollback channel / emergency fallback.
5. Komunikat do gracza: jeden krok naraz, bez technicznego zargonu.

## 5. Escalation matrix
1. P0: natychmiast do maintainera launchera + API (SLA do 15 min).
2. P1: eskalacja w tej samej zmianie dyzurowej (SLA do 60 min).
3. P2: backlog/support queue (SLA do 24h).

## 6. Definition of Ready dla supportu
1. Dostepny eksport logow launchera.
2. Dostepna mapa kodow bledow -> akcje support.
3. Dostepna checklista rollback i go/no-go.
