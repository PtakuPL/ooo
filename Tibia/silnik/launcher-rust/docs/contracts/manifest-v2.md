# Zamrożony schemat: manifest.json v2

**ID:** LR-005  
**Status:** FROZEN  
**Data:** 2026-03-02

## Cel

Definicja schematu manifestu v2 — dokument referencyjny dla implementacji parsera,
walidatora i plannera w launcher-core.

## Kompatybilność

- **v1** (bez `schemaVersion`) — obsługiwany jako fallback, normalizowany do modelu wewnętrznego
- **v2** (`schemaVersion` zaczynające się od `"2"`) — pełna wersja z flagami plików

## JSON Schema (uproszczona)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Launcher Manifest v2",
  "type": "object",
  "required": ["schemaVersion", "manifestId", "version", "releaseDate", "generatedAtUtc", "channel", "files", "filesHashExpected"],
  "properties": {
    "schemaVersion": { "type": "string", "pattern": "^2\\." },
    "manifestId": { "type": "string", "minLength": 1 },
    "version": { "type": "string", "minLength": 1 },
    "releaseDate": { "type": "string", "pattern": "^\\d{4}-\\d{2}-\\d{2}$" },
    "generatedAtUtc": { "type": "string", "format": "date-time" },
    "channel": { "type": "string", "enum": ["stable", "test", "dev"] },
    "minLauncherVersion": { "type": "string" },
    "baseUrl": { "type": "string", "format": "uri" },
    "filesHashExpected": { "type": "string", "pattern": "^[0-9a-f]{64}$" },
    "files": {
      "type": "array",
      "minItems": 1,
      "items": { "$ref": "#/$defs/fileEntry" }
    },
    "servers": {
      "type": "array",
      "items": { "$ref": "#/$defs/serverEntry" }
    },
    "changelog": {
      "type": "array",
      "items": { "$ref": "#/$defs/changelogEntry" }
    },
    "gracePreviousVersionAcceptedUntilUtc": { "type": "string", "format": "date-time" },
    "signature": { "type": "string" },
    "notes": { "type": "string" }
  },
  "$defs": {
    "fileEntry": {
      "type": "object",
      "required": ["path"],
      "properties": {
        "path": { "type": "string", "minLength": 1 },
        "sha256": { "type": "string", "pattern": "^[0-9a-f]{64}$" },
        "size": { "type": "integer", "minimum": 0 },
        "url": { "type": "string" },
        "managed": { "type": "boolean", "default": true },
        "action": { "type": "string", "enum": ["file", "delete", "mkdir", "noop"], "default": "file" },
        "required": { "type": "boolean", "default": false },
        "includeInFilesHash": { "type": "boolean", "default": true },
        "overwritePolicy": { "type": "string", "enum": ["always", "if_hash_differs", "never", "preserve_user"], "default": "if_hash_differs" },
        "deletePolicy": { "type": "string", "enum": ["allow", "protect", "orphan_cleanup"], "default": "protect" },
        "executable": { "type": "boolean", "default": false },
        "tags": { "type": "array", "items": { "type": "string" } }
      }
    },
    "serverEntry": {
      "type": "object",
      "required": ["id", "name", "host", "port"],
      "properties": {
        "id": { "type": "string" },
        "name": { "type": "string" },
        "host": { "type": "string" },
        "port": { "type": "integer", "minimum": 1, "maximum": 65535 },
        "gameMode": { "type": "string" },
        "visible": { "type": "boolean", "default": true },
        "enabled": { "type": "boolean", "default": true },
        "priority": { "type": "integer", "default": 0 }
      }
    },
    "changelogEntry": {
      "type": "object",
      "required": ["date", "text"],
      "properties": {
        "date": { "type": "string" },
        "text": { "type": "string" }
      }
    }
  }
}
```

## Reguły walidacji

1. **Duplikaty path** — ODRZUĆ manifest z duplikatami `files[].path`
2. **Path traversal** — ODRZUĆ wpisy z `..`, ścieżkami absolutnymi, dwukropkiem
3. **action=file + managed=true** — WYMAGAJ `sha256`, `size`
4. **action=delete** — NIE wymagaj `sha256`, `size`, `url`
5. **filesHashExpected** — v2: WYMAGANE; v1: opcjonalne (brak pola)

## Normalizacja v1 → v2

| Pole v2 | Wartość dla v1 |
|---------|----------------|
| `schemaVersion` | `"1-compat"` |
| `manifestId` | `"{channel}:{version}"` |
| `generatedAtUtc` | `null` |
| `filesHashExpected` | `null` |
| `files[].managed` | `true` |
| `files[].action` | `"file"` |
| `files[].required` | `true` |
| `files[].includeInFilesHash` | `true` |
| `files[].overwritePolicy` | `"if_hash_differs"` |
| `files[].deletePolicy` | `"protect"` |
