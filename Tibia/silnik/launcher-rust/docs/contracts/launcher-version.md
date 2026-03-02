# Kontrakt API: launcher-version.php

**ID:** LR-001  
**Status:** FROZEN  
**Data:** 2026-03-02

## Endpoint

```
GET /api/launcher-version.php
```

## Opis

Zwraca informację o najnowszej wersji launchera. Służy do mechanizmu self-update.

## Response (200 OK)

```json
{
  "version": "0.2.0",
  "minVersion": "0.1.0",
  "required": true,
  "url": "https://example.com/releases/launcher/0.2.0/",
  "sha256": "abcdef1234567890...",
  "releaseDate": "2026-03-02",
  "notes": "Poprawki stabilności"
}
```

## Pola

| Pole | Typ | Wymagane | Opis |
|------|-----|----------|------|
| `version` | string (semver) | TAK | Najnowsza dostępna wersja launchera |
| `minVersion` | string (semver) | TAK | Minimalna akceptowalna wersja — starsze MUSZĄ się zaktualizować |
| `required` | boolean | TAK | `true` = update obowiązkowy, launcher nie pozwala kontynuować bez aktualizacji |
| `url` | string (URL) | TAK | Bazowy URL do pobrania paczki launchera |
| `sha256` | string (hex) | TAK | Hash paczki launchera do weryfikacji po pobraniu |
| `releaseDate` | string (YYYY-MM-DD) | NIE | Data wydania wersji |
| `notes` | string | NIE | Krótki opis zmian (techniczny) |

## Kody błędów HTTP

| Kod | Znaczenie |
|-----|-----------|
| 200 | OK — dane wersji |
| 503 | Serwer tymczasowo niedostępny — launcher powinien retry |

## Logika po stronie launchera

1. Pobierz `GET /api/launcher-version.php`
2. Porównaj `version` z lokalną wersją launchera
3. Jeśli lokalna < `minVersion` → wymuś self-update (hard block)
4. Jeśli lokalna < `version` i `required=true` → wymuś self-update
5. Jeśli lokalna < `version` i `required=false` → zaproponuj update (soft)
6. Jeśli lokalna >= `version` → kontynuuj normalnie

## Uwagi

- Endpoint publiczny, bez autoryzacji.
- Launcher powinien cache'ować odpowiedź max 5 minut.
- TLS wymagane (hard-fail bez HTTPS).
