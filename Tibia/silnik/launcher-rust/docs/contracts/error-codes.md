# Kody błędów launchera (LCH_*)

**ID:** LR-007  
**Status:** FROZEN  
**Data:** 2026-03-02

## Cel

Ustandaryzowane kody błędów dla logów, `installed_state.json` (`lastErrorCode`) i UI.

## Kody

| Kod | Scenariusz | Komunikat użytkownika |
|-----|-----------|----------------------|
| `LCH_MANIFEST_FETCH_FAILED` | Nie udało się pobrać manifestu z API | Nie można sprawdzić aktualizacji. Sprawdź połączenie internetowe. |
| `LCH_MANIFEST_PARSE_FAILED` | Manifest JSON uszkodzony lub nieparsowalny | Błąd danych aktualizacji. Spróbuj ponownie. |
| `LCH_MANIFEST_SCHEMA_UNSUPPORTED` | Nieznana `schemaVersion` w manifeście | Wymagana nowsza wersja launchera. |
| `LCH_MANIFEST_SIGNATURE_INVALID` | Podpis manifestu nie przechodzi weryfikacji | Błąd weryfikacji aktualizacji. Zgłoś problem. |
| `LCH_MANIFEST_PATH_TRAVERSAL` | Wykryto `..` lub ścieżkę absolutną w `files[].path` | Wykryto niebezpieczną ścieżkę w aktualizacji. |
| `LCH_MANIFEST_DUPLICATE_PATH` | Duplikat `path` w `files[]` | Błąd danych aktualizacji (duplikat pliku). |
| `LCH_DOWNLOAD_FAILED` | Nie udało się pobrać pliku z URL | Nie można pobrać pliku. Sprawdź połączenie. |
| `LCH_FILE_HASH_MISMATCH` | SHA-256 pobranego pliku nie pasuje do manifestu | Pobrany plik jest uszkodzony. Ponów pobieranie. |
| `LCH_PATCH_APPLY_FAILED` | Błąd podczas podmianki plików (staging → docelowy) | Aktualizacja nie powiodła się. Spróbuj naprawić instalację. |
| `LCH_ROLLBACK_FAILED` | Rollback po błędzie nie powiódł się | Przywracanie nie powiodło się. Napraw instalację ręcznie. |
| `LCH_ROLLBACK_SUCCESS` | Rollback wykonany pomyślnie (informacyjne) | Aktualizacja cofnięta do poprzedniej wersji. |
| `LCH_FILES_HASH_COMPUTE_FAILED` | Nie udało się obliczyć filesHash | Błąd weryfikacji plików. Napraw instalację. |
| `LCH_TOKEN_REQUEST_FAILED` | Nie udało się pobrać launch-tokena (sieć/serwer) | Nie można uzyskać tokena startu. Spróbuj ponownie. |
| `LCH_TOKEN_REJECTED` | Serwer odrzucił request tokena (403) | Token odrzucony. Sprawdź aktualizacje. |
| `LCH_TOKEN_RATE_LIMITED` | Zbyt wiele requestów tokena (429) | Za dużo prób. Poczekaj chwilę. |
| `LCH_CLIENT_START_FAILED` | Nie udało się uruchomić procesu klienta | Nie można uruchomić gry. Sprawdź instalację. |
| `LCH_CLIENT_NOT_FOUND` | Exe klienta nie znalezione na dysku | Plik klienta gry nie znaleziony. Napraw instalację. |
| `LCH_TLS_REQUIRED` | Połączenie bez TLS (hard-fail) | Wymagane bezpieczne połączenie (HTTPS). |
| `LCH_STATE_CORRUPTED` | `installed_state.json` uszkodzony/nieparsowalny | Stan launchera uszkodzony. Uruchamiam naprawę. |
| `LCH_LAUNCHER_UPDATE_REQUIRED` | Wersja launchera za stara (< minVersion) | Wymagana aktualizacja launchera. |
| `LCH_STAGING_CLEANUP_FAILED` | Nie udało się wyczyścić katalogu staging | Ostrzeżenie: pliki tymczasowe nie zostały wyczyszczone. |

## Użycie

1. **Logi**: zapisywane z pełnym kodem + szczegółami technicznymi
2. **installed_state.json**: `lastErrorCode` = kod, `lastErrorMessage` = skrócony opis techniczny
3. **UI**: mapowanie kodu → komunikat user-facing (kolumna "Komunikat użytkownika")
4. **Tauri DTO**: `{ code: "LCH_...", userMessage: "...", technicalDetail: "..." }`

## Severity

| Prefix | Severity | Akcja |
|--------|----------|-------|
| `LCH_MANIFEST_*` | CRITICAL | Zablokuj update |
| `LCH_DOWNLOAD_*` | ERROR | Retry, potem zablokuj |
| `LCH_FILE_*` | ERROR | Retry download |
| `LCH_PATCH_*` | CRITICAL | Rollback |
| `LCH_ROLLBACK_*` | CRITICAL/INFO | Informuj użytkownika |
| `LCH_TOKEN_*` | ERROR | Retry, potem zablokuj launch |
| `LCH_CLIENT_*` | ERROR | Zablokuj launch |
| `LCH_TLS_*` | CRITICAL | Hard-fail |
| `LCH_STATE_*` | WARNING | Auto-repair |
| `LCH_LAUNCHER_*` | CRITICAL | Wymuś self-update |
| `LCH_STAGING_*` | WARNING | Loguj, kontynuuj |
