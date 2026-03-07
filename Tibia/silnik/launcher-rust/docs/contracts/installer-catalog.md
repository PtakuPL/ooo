# Kontrakt: installer-catalog.php

**ID:** LR-004  
**Status:** zaktualizowany (BL-31)  
**Data:** 2026-03-03  
**Aktualizacja:** 2026-03-07 — parametr `type`, artefakty bootstrap

## Endpoint

```
GET /apik/v1/installer-catalog.php?channel=stable
GET /apik/v1/installer-catalog.php?type=launcher    ← tylko pełny launcher
GET /apik/v1/installer-catalog.php?type=bootstrap   ← tylko lekki bootstrap
GET /apik/v1/installer-catalog.php?type=installer   ← legacy (wsteczna kompatybilność)
GET /apik/v1/installer-catalog.php?type=all          ← wszystko (domyślne)
```

### Parametr `type` (BL-15)

| Wartość | Opis |
|---|---|
| `all` (domyślny) | Zwraca wszystkie artefakty |
| `launcher` | Tylko pełny launcher (Tauri) — używany przez bootstrap |
| `bootstrap` | Tylko lekki bootstrap launcher (~KB) — wyświetlany na stronie do pobrania |
| `installer` | Legacy wpis — wsteczna kompatybilność |

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
| `artifacts[].type` | string | `launcher` / `bootstrap` / `installer` (legacy) |

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

## Uzycie w bootstrap launcher

Bootstrap launcher odpytuje `?type=launcher` aby znalezc pełny launcher
do pobrania. Filtruje po `platform` i `arch`, pobiera URL, weryfikuje SHA-256.

## Synchronizacja z RedDaxe.pl

Strona RedDaxe.pl (`download.php`, `reddaxe/index.php`) odczytuje dane
z tego API (lub z `.env`) aby wyświetlić wersję, hash i link do pobrania.
Każdy deploy nowej wersji artefaktu = aktualizacja `.env` = strona automatycznie
pokazuje nowe dane.

## Przykład odpowiedzi z `?type=bootstrap`

```json
{
  "brand": "RedDAXE.pl",
  "generatedAtUtc": "2026-03-07T12:00:00Z",
  "artifacts": [
    {
      "id": "bootstrap-win",
      "name": "Bootstrap Launcher",
      "type": "bootstrap",
      "platform": "windows",
      "arch": "x86_64",
      "channel": "stable",
      "version": "1.0.0",
      "filename": "launcher-bootstrap-windows-x86_64.exe",
      "url": "/files/bootstrap/launcher-bootstrap-windows-x86_64.exe",
      "sha256": "abc123...",
      "releaseDate": "2026-03-07",
      "notes": "Lekki launcher"
    }
  ]
}
```
