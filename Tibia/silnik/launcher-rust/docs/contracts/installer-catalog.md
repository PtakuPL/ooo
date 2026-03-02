# Kontrakt: installer-catalog.php

**ID:** LR-004  
**Status:** zamrozony  
**Data:** 2026-03-03

## Endpoint

```
GET /api/installer-catalog.php?channel=stable
```

## Response (JSON)

```json
{
  "channel": "stable",
  "version": "0.2.0",
  "generatedAtUtc": "2026-03-02T18:00:00Z",
  "artifacts": [
    {
      "platform": "windows",
      "arch": "x86_64",
      "filename": "TwojaGra-Setup-0.2.0.exe",
      "url": "https://cdn.example.com/releases/TwojaGra-Setup-0.2.0.exe",
      "sha256": "abcdef1234567890...",
      "size": 52428800,
      "type": "installer"
    },
    {
      "platform": "linux",
      "arch": "x86_64",
      "filename": "TwojaGra-0.2.0.AppImage",
      "url": "https://cdn.example.com/releases/TwojaGra-0.2.0.AppImage",
      "sha256": "fedcba0987654321...",
      "size": 61865984,
      "type": "installer"
    },
    {
      "platform": "android",
      "arch": "arm64",
      "filename": "TwojaGra-0.2.0.apk",
      "url": "https://cdn.example.com/releases/TwojaGra-0.2.0.apk",
      "sha256": "112233445566...",
      "size": 45088768,
      "type": "installer"
    }
  ]
}
```

## Pola wymagane

| Pole | Typ | Opis |
|---|---|---|
| `channel` | string | Kanal (stable/test/dev) |
| `version` | string | Wersja launchera/instalki |
| `artifacts` | array | Lista artefaktow do pobrania |
| `artifacts[].platform` | string | `windows` / `linux` / `android` |
| `artifacts[].arch` | string | `x86_64` / `arm64` |
| `artifacts[].filename` | string | Nazwa pliku |
| `artifacts[].url` | string | URL do pobrania |
| `artifacts[].sha256` | string | Hash SHA-256 (hex) |
| `artifacts[].size` | integer | Rozmiar w bajtach |
| `artifacts[].type` | string | `installer` / `portable` / `update` |

## Pola opcjonalne

| Pole | Typ | Opis |
|---|---|---|
| `generatedAtUtc` | string | ISO-8601 timestamp |
| `artifacts[].signature` | string | Podpis .sig (opcjonalny, Etap 5) |
| `artifacts[].minOsVersion` | string | Minimalna wersja OS |

## Walidacja klienta

1. Sprawdz `channel` — musi zgadzac sie z zadanym
2. Sprawdz czy `artifacts` nie jest pusty
3. Dla kazdego artefaktu: `sha256` i `size` musza byc niepuste
4. Po pobraniu: weryfikuj SHA-256 przed instalacja

## Kody bledow

- `404` — kanal nie istnieje
- `500` — blad serwera
- `429` — rate limit

## Uzycie w launcherze

Endpoint uzywany w UI Download Center (LR-044) do wyswietlenia
listy dostepnych artefaktow. Launcher pobiera plik, weryfikuje hash
i pozwala uzytkownikowi zainstalowac.
