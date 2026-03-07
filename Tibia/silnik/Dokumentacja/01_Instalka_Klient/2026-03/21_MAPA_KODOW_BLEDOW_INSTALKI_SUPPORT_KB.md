# Mapa Kodow Bledow Instalki -> Instrukcje Support/KB

Data: 2026-03-06
Zakres: K110
Zrodlo kontraktu: `launcher-rust/docs/contracts/error-codes.md`

## 1. Manifest i integralnosc danych
1. `LCH_MANIFEST_FETCH_FAILED`
Akcja gracza: sprawdz internet i sprobuj ponownie.
Akcja support: sprawdz endpoint `update.php`, TLS i dostepnosc API.
2. `LCH_MANIFEST_PARSE_FAILED`
Akcja gracza: ponow probe po chwili.
Akcja support: zweryfikuj JSON manifestu i zgodnosc schema.
3. `LCH_MANIFEST_SCHEMA_UNSUPPORTED`
Akcja gracza: zaktualizuj launcher.
Akcja support: potwierdz `minLauncherVersion` i rollout wersji.
4. `LCH_MANIFEST_SIGNATURE_INVALID`
Akcja gracza: nie kontynuuj update, zglos problem.
Akcja support: zweryfikuj podpis i klucz publiczny.

## 2. Download i patch
1. `LCH_DOWNLOAD_FAILED`
Akcja gracza: ponow pozniej.
Akcja support: sprawdz CDN/URL/rate-limit.
2. `LCH_FILE_HASH_MISMATCH`
Akcja gracza: uruchom naprawe/update ponownie.
Akcja support: potwierdz `sha256` i integralnosc artefaktu.
3. `LCH_PATCH_APPLY_FAILED`
Akcja gracza: uruchom naprawe instalacji.
Akcja support: sprawdz prawa zapisu, blokady plikow, staging.
4. `LCH_ROLLBACK_FAILED`
Akcja gracza: zatrzymaj start, kontakt z support.
Akcja support: uruchom procedury rollback awaryjnego.

## 3. Start gry i sesja
1. `LCH_TOKEN_REQUEST_FAILED`
Akcja gracza: ponow logowanie.
Akcja support: sprawdz `launcher-token.php`, `login.php`, `account-context.php`.
2. `LCH_TOKEN_REJECTED`
Akcja gracza: sprawdz aktualizacje i sesje.
Akcja support: sprawdz walidacje tokenu i zgodnosc files hash.
3. `LCH_TOKEN_RATE_LIMITED`
Akcja gracza: odczekaj i sprobuj ponownie.
Akcja support: sprawdz limity i ewentualny abuse.
4. `LCH_CLIENT_NOT_FOUND`
Akcja gracza: uruchom naprawe.
Akcja support: potwierdz komplet plikow klienta.
5. `LCH_CLIENT_START_FAILED`
Akcja gracza: ponow start po naprawie.
Akcja support: sprawdz executable, uprawnienia i working dir.

## 4. Bezpieczenstwo i runtime
1. `LCH_TLS_REQUIRED`
Akcja gracza: brak akcji po stronie usera.
Akcja support: popraw konfiguracje endpointu na HTTPS.
2. `LCH_LAUNCHER_UPDATE_REQUIRED`
Akcja gracza: wykonaj self-update launchera.
Akcja support: potwierdz poprawna publikacje `launcher-version`.
3. `LCH_STATE_CORRUPTED`
Akcja gracza: uruchom naprawe.
Akcja support: sprawdz `installed_state.json` i logi.
4. `LCH_STAGING_CLEANUP_FAILED`
Akcja gracza: zwykle mozna kontynuowac.
Akcja support: sprawdz cleanup i prawa zapisu.

## 5. Kody preflight/anti-tamper (wdrozone w tej iteracji)
1. `LCH_PREFLIGHT_NOT_WRITABLE`
Akcja gracza: uruchom launcher z prawami zapisu do katalogu gry.
Akcja support: sprawdz ACL/owner dla `client_dir` i `launcher_data_dir`.
2. `LCH_PREFLIGHT_INSUFFICIENT_SPACE`
Akcja gracza: zwolnij miejsce na dysku i ponow update.
Akcja support: zweryfikuj dostepne miejsce i wymagania update.
3. `LCH_PREFLIGHT_SPACE_CHECK_FAILED`
Akcja gracza: ponow probe po restarcie launchera.
Akcja support: sprawdz filesystem i odczyt metryk wolnego miejsca.
4. `LCH_ANTI_TAMPER_REPAIR_FAILED`
Akcja gracza: uruchom reczna naprawe/update.
Akcja support: sprawdz katalog kwarantanny i logi anti-tamper.

## 6. Eskalacja
1. P0: manifest signature/tls/update required masowo -> natychmiast rollback lub freeze publikacji.
2. P1: pojedyncze preflight/token/client start -> support operacyjny + monitor trendu.
3. P2: incydenty niestale -> backlog i obserwacja.
