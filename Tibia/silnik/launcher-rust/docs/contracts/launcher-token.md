# Kontrakt API: launcher-token.php

**ID:** LR-003  
**Status:** FROZEN  
**Data:** 2026-03-02

## Endpoint

```
POST /api/launcher-token.php
Content-Type: application/x-www-form-urlencoded
```

## Opis

Wydaje jednorazowy launch-token powiązany z wersją launchera, integalnością plików i adresem IP klienta. Token jest przekazywany do klienta gry przez zmienną środowiskową `OTC_LAUNCH_TOKEN`.

**Uwaga:** launch-token NIE jest dowodem kryptograficznym uruchomienia oficjalnego launchera — endpoint jest publiczny. To warstwa UX/speed-bump, nie twarda bariera (ticket-gate + HMAC to twarda warstwa).

## Request body

| Pole | Typ | Wymagane | Opis |
|------|-----|----------|------|
| `launcherVersion` | string (semver) | TAK | Wersja launchera wysyłającego request |
| `filesHash` | string (hex sha256) | TAK | Hash obliczony z lokalnych plików wg algorytmu filesHash |
| `channel` | string | TAK | Kanał: `stable`, `test`, `dev` |
| `manifestVersion` | string | TAK | Wersja manifestu, na podstawie którego wykonano ostatni update |

## Response (200 OK)

```json
{
  "token": "550e8400-e29b-41d4-a716-446655440000",
  "expiresInSeconds": 300
}
```

| Pole | Typ | Opis |
|------|-----|------|
| `token` | string (UUID) | Jednorazowy launch-token |
| `expiresInSeconds` | integer | TTL tokena w sekundach (domyślnie 300) |

## Response — błędy

```json
{
  "error": "files_hash_mismatch",
  "message": "Integrity check failed. Please update your client."
}
```

| Kod HTTP | `error` | Opis |
|----------|---------|------|
| 400 | `missing_fields` | Brak wymaganych pól w request |
| 403 | `files_hash_mismatch` | filesHash nie pasuje do oczekiwanego dla danej manifestVersion |
| 403 | `launcher_version_rejected` | Wersja launchera za stara lub nieznana |
| 403 | `manifest_version_expired` | manifestVersion poza grace period |
| 429 | `rate_limited` | Za dużo requestów z tego IP |
| 500 | `internal_error` | Błąd serwera |

## Logika serwera (launcher-token.php)

1. Waliduj wymagane pola
2. Sprawdź rate-limit per IP
3. Waliduj `launcherVersion` (>= minVersion z konfiguracji)
4. Waliduj `manifestVersion` (current lub previous w grace period)
5. Waliduj `filesHash` vs oczekiwany hash dla danej `manifestVersion`
6. Wygeneruj UUID token
7. Zapisz do DB: `token`, `ip`, `launcher_version`, `files_hash`, `manifest_version`, `created_at`, `expires_at`
8. Zwróć token + TTL

## Logika konsumpcji (login.php)

1. Klient przesyła token z `OTC_LAUNCH_TOKEN` do `login.php`
2. `SELECT ... FOR UPDATE` z tabeli `launch_tokens`
3. Walidacja: IP match, TTL (300s), `manifest_version` (current + previous)
4. `DELETE` — jednorazowe użycie
5. Kontynuacja flow logowania

## Algorytm filesHash (kontrakt)

1. Weź `manifest.files[]` gdzie `managed=true` AND `action="file"` AND `includeInFilesHash=true`
2. Sortuj po `path` rosnąco (UTF-8 lexicographic)
3. Dla każdego wpisu: jeśli plik istnieje lokalnie → SHA-256 pliku; jeśli brak → `"MISSING"`
4. Sklej wszystkie wartości w jeden string
5. SHA-256 z połączonego stringa → hex = `filesHash`

**KRYTYCZNE:** filesHash liczymy z LOKALNYCH plików, nie z sha256 z manifestu.

## Logika po stronie launchera

1. Zakończ update klienta (apply all patches)
2. Oblicz `filesHash` z lokalnych plików
3. `POST /api/launcher-token.php` z `launcherVersion`, `filesHash`, `channel`, `manifestVersion`
4. Odbierz token
5. Uruchom klienta z `OTC_LAUNCH_TOKEN={token}` (env, NIE CLI argument)
6. Token jest jednorazowy — nie cache'ować, nie zapisywać na dysk

## Uwagi bezpieczeństwa

- Token przekazywany WYŁĄCZNIE przez zmienną środowiskową `OTC_LAUNCH_TOKEN`
- Nigdy przez argument CLI (widoczny w process list)
- Token NIE jest zapisywany w `installed_state.json` (tylko metadane requestu bez samego tokena)
- IP-binding: token ważny tylko dla IP, z którego został wydany
- TTL: 300 sekund
- Jednorazowy: DELETE po konsumpcji w login.php
