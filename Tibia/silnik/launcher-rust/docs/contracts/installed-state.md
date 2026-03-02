# Zamrożony schemat: installed_state.json

**ID:** LR-006  
**Status:** FROZEN  
**Data:** 2026-03-02

## Cel

Lokalny stan techniczny launchera. Odpowiada na pytania:
- Co jest zainstalowane?
- Jaki manifest był ostatnio zastosowany?
- Czy update został przerwany?
- Jaki był ostatni filesHash?

## Lokalizacja

```
{install_dir}/.launcher/installed_state.json
```

## Schemat

```json
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
  "lastApiBaseUrl": "https://example.com/api/",
  "tlsEnforced": true,
  "lastLauncherVersionCheckUtc": null,
  "lastKnownServerManifestVersion": null,
  "lastTokenRequest": null,
  "updateTransaction": { ... },
  "managedFilesIndex": { ... }
}
```

## Pola top-level

| Pole | Typ | Wymagane | Opis |
|------|-----|----------|------|
| `schemaVersion` | string | TAK | `"1.0"` |
| `installId` | string (UUID) | TAK | Unikalny identyfikator instalacji |
| `channel` | string | TAK | `stable`/`test`/`dev` |
| `clientInstallPath` | string | TAK | Ścieżka klienta gry |
| `launcherVersion` | string | TAK | Wersja launchera, która zapisała stan |
| `currentManifestVersion` | string? | TAK | Ostatnia w pełni zastosowana wersja (null jeśli nigdy) |
| `currentManifestId` | string? | TAK | ID manifestu |
| `currentFilesHash` | string? | TAK | Ostatni obliczony filesHash po udanym update |
| `lastSuccessfulUpdateUtc` | string? | NIE | Czas ostatniego udanego update |
| `lastUpdateAttemptUtc` | string? | NIE | Czas ostatniej próby |
| `lastUpdateResult` | enum | TAK | `"never_run"`, `"success"`, `"failed"`, `"partial"`, `"rollback_success"`, `"rollback_failed"` |
| `lastErrorCode` | string? | NIE | Kod błędu `LCH_*` |
| `lastErrorMessage` | string? | NIE | Krótki komunikat techniczny |
| `lastApiBaseUrl` | string | TAK | Ostatni użyty URL API |
| `tlsEnforced` | boolean | TAK | Zawsze `true` (hard-fail bez TLS) |
| `lastLauncherVersionCheckUtc` | string? | NIE | Czas ostatniego sprawdzenia wersji launchera |
| `lastKnownServerManifestVersion` | string? | NIE | Wersja manifestu serwerów |
| `lastTokenRequest` | object? | NIE | Metadane ostatniego requestu tokena (BEZ samego tokena) |
| `updateTransaction` | object | TAK | Stan trwającego/przerwanego patchowania |
| `managedFilesIndex` | map | TAK | Lokalny indeks plików zarządzanych |

## updateTransaction

| Pole | Typ | Opis |
|------|-----|------|
| `txId` | string (UUID) | ID transakcji |
| `status` | enum | `"idle"`, `"preparing"`, `"downloading"`, `"verifying"`, `"applying"`, `"finalizing"`, `"rollback_required"`, `"rollback_in_progress"` |
| `targetManifestVersion` | string? | Docelowa wersja |
| `targetManifestId` | string? | Docelowy ID manifestu |
| `startedAtUtc` | string? | Start transakcji |
| `updatedFiles` | array[string] | Zaktualizowane pliki |
| `backupFiles` | array[string] | Pliki zbackupowane |
| `deletePlanned` | array[string] | Pliki do usunięcia |
| `deleteApplied` | array[string] | Pliki już usunięte |
| `stagingPath` | string? | Ścieżka staging |
| `resumeSupported` | boolean | Czy można wznowić |

## managedFilesIndex

Mapa `path → metadata`:

| Pole | Typ | Opis |
|------|-----|------|
| `sha256` | string | Hash pliku |
| `size` | integer | Rozmiar |
| `manifestVersion` | string | Z jakiej wersji manifestu |
| `managed` | boolean | Czy zarządzany |
| `installedAtUtc` | string | Kiedy zainstalowany |
| `tags` | array[string] | Tagi |
| `wasModifiedLocally` | boolean | Czy zmodyfikowany lokalnie |

## lastTokenRequest

Zapisujemy TYLKO metadane, NIGDY sam token.

| Pole | Typ | Opis |
|------|-----|------|
| `requestedAtUtc` | string | Czas requestu |
| `launcherVersion` | string | Wersja launchera |
| `manifestVersion` | string? | Wersja manifestu |
| `filesHashPrefix` | string? | Pierwsze 8-12 znaków hasha (diagnostyka) |
| `result` | enum | `"unknown"`, `"success"`, `"rejected"`, `"rate_limited"`, `"network_error"` |

## Zasady zapisu

1. **Atomowy zapis**: `tmp file` → `fsync` → `rename` (zapobiega uszkodzeniu przy crash)
2. **Przy starcie**: sprawdź `updateTransaction.status` — jeśli nie `"idle"`, uruchom recovery
3. **Po update**: zaktualizuj `currentManifestVersion`, `currentFilesHash`, `lastSuccessfulUpdateUtc`
4. **Po błędzie**: zapisz `lastErrorCode`, `lastErrorMessage`
5. **Token**: nigdy nie zapisuj samego tokena — tylko metadane requestu
