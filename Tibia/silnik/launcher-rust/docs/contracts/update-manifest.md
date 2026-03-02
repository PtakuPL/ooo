# Kontrakt API: update.php (Manifest)

**ID:** LR-002  
**Status:** FROZEN  
**Data:** 2026-03-02

## Endpoint

```
GET /api/update.php?channel={channel}
```

## Parametry query

| Parametr | Typ | Wymagane | Opis |
|----------|-----|----------|------|
| `channel` | string | TAK | Kanał aktualizacji: `stable`, `test`, `dev` |

## Opis

Zwraca manifest opisujący aktualną wersję klienta gry i listę plików zarządzanych przez launcher.

## Response (200 OK) — Manifest v2

```json
{
  "schemaVersion": "2.0",
  "manifestId": "stable:1.0.3",
  "version": "1.0.3",
  "releaseDate": "2026-03-02",
  "generatedAtUtc": "2026-03-02T18:15:22Z",
  "channel": "stable",
  "minLauncherVersion": "0.2.0",
  "baseUrl": "https://example.com/files/stable/1.0.3/",
  "filesHashExpected": "8d1b5f...abc123",
  "files": [],
  "servers": [],
  "changelog": [],
  "gracePreviousVersionAcceptedUntilUtc": "2026-03-02T19:15:22Z",
  "signature": null
}
```

## Pola top-level

| Pole | Typ | Wymagane v2 | Wymagane v1 | Opis |
|------|-----|-------------|-------------|------|
| `schemaVersion` | string | TAK | BRAK (fallback v1) | `"2.0"` |
| `manifestId` | string | TAK | generowany | Unikalny ID manifestu, np. `"stable:1.0.3"` |
| `version` | string | TAK | TAK | Wersja klienta |
| `releaseDate` | string (YYYY-MM-DD) | TAK | TAK | Data publikacji |
| `generatedAtUtc` | string (ISO-8601) | TAK | NIE | Czas generacji |
| `channel` | string | TAK | TAK | `stable`/`test`/`dev` |
| `minLauncherVersion` | string (semver) | NIE | NIE | Min. wersja launchera obsługująca ten manifest |
| `baseUrl` | string (URL) | NIE | NIE | Bazowy URL dla plików (jeśli `files[].url` są względne) |
| `filesHashExpected` | string (hex sha256) | TAK | NIE | Oczekiwany filesHash zestawu plików |
| `files` | array | TAK | TAK | Lista plików — patrz sekcja poniżej |
| `servers` | array | NIE | NIE | Lista serwerów do synchronizacji |
| `changelog` | array | NIE | NIE | Historia zmian |
| `gracePreviousVersionAcceptedUntilUtc` | string (ISO-8601) | NIE | NIE | Grace period dla poprzedniej wersji |
| `signature` | string | NIE | NIE | Opcjonalny podpis manifestu (defense-in-depth) |

## files[] — wpis pliku

| Pole | Typ | Wymagane | Domyślne | Opis |
|------|-----|----------|----------|------|
| `path` | string | TAK | — | Ścieżka względna (separator `/`) |
| `sha256` | string (hex) | TAK* | — | Hash pliku (*nie wymagany dla `action=delete`) |
| `size` | integer | TAK* | — | Rozmiar w bajtach (*nie wymagany dla `action=delete`) |
| `url` | string | TAK* | — | URL pobrania (*nie wymagany dla `action=delete`) |
| `managed` | boolean | NIE | `true` | Czy plik jest zarządzany przez launcher |
| `action` | enum | NIE | `"file"` | `"file"`, `"delete"`, `"mkdir"`, `"noop"` |
| `required` | boolean | NIE | `false` | Czy wymagany do startu klienta |
| `includeInFilesHash` | boolean | NIE | `true` | Czy uczestniczy w obliczaniu filesHash |
| `overwritePolicy` | enum | NIE | `"if_hash_differs"` | `"always"`, `"if_hash_differs"`, `"never"`, `"preserve_user"` |
| `deletePolicy` | enum | NIE | `"protect"` | `"allow"`, `"protect"`, `"orphan_cleanup"` |
| `executable` | boolean | NIE | `false` | Czy plik wykonywalny |
| `tags` | array[string] | NIE | `[]` | Tagi klasyfikujące plik np. `["client-bin"]`, `["lua","ui"]` |

## servers[] — wpis serwera (opcjonalny)

| Pole | Typ | Wymagane | Opis |
|------|-----|----------|------|
| `id` | string | TAK | Unikalny identyfikator serwera |
| `name` | string | TAK | Nazwa wyświetlana |
| `host` | string | TAK | Adres hosta |
| `port` | integer | TAK | Port |
| `gameMode` | string | NIE | `"classic74"`, `"modern"` |
| `visible` | boolean | NIE | Domyślnie `true` |
| `enabled` | boolean | NIE | Domyślnie `true` |
| `priority` | integer | NIE | Kolejność sortowania |

## changelog[]

| Pole | Typ | Wymagane | Opis |
|------|-----|----------|------|
| `date` | string | TAK | Data wpisu |
| `text` | string | TAK | Treść |

## Walidacja po stronie launchera

1. Jeśli brak `schemaVersion` → traktuj jako v1 (fallback)
2. `schemaVersion` zaczynające się od `"2"` → parse jako v2
3. Inne `schemaVersion` → błąd `LCH_MANIFEST_SCHEMA_UNSUPPORTED`
4. Wymagane pola: `version`, `channel`, `files` (niepusta)
5. Duplikaty `path` w `files[]` → błąd `LCH_MANIFEST_PARSE_FAILED`
6. Dla `action=file` + `managed=true`: `sha256`, `size` wymagane
7. Walidacja path traversal: zakaz `..`, ścieżek absolutnych, dwukropka

## Kompatybilność v1

Manifest v1 (bez `schemaVersion`) zawiera tylko:
- `version`, `releaseDate`, `channel`, `files[]` (path, sha256, size, url), `changelog[]`

Launcher normalizuje v1 do modelu wewnętrznego z domyślnymi wartościami:
- `managed=true`, `action="file"`, `includeInFilesHash=true`
- `overwritePolicy="if_hash_differs"`, `deletePolicy="protect"`

## Kody błędów HTTP

| Kod | Znaczenie |
|-----|-----------|
| 200 | OK — manifest |
| 400 | Brak/nieprawidłowy parametr `channel` |
| 503 | Serwer tymczasowo niedostępny |
