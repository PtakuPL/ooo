# Challenge-Response Flow for Launch Token

**LR-052** — Hardening (Etap 5)  
**Data:** 2026-03-03  
**Status:** Implementacja

---

## 1. Cel

Dodać warstwę challenge-response do flow launch-token, aby:
- Utrudnić automatyzację requestów bez prawdziwego launchera.
- Powiązać filesHash z konkretnym request ID (nonce).
- Dodać time-binding — nonce jest ważny przez TTL.

**WAŻNE:** To jest warstwa UX/speed-bump, NIE twarda bariera.  
Twarda warstwa to ticket-gate + HMAC po stronie Canary.

---

## 2. Flow

```
Launcher                         API
   |                              |
   |─── GET /challenge.php ──────>|
   |                              |
   |<── { nonce, expiresIn } ─────|
   |                              |
   |   compute filesHash          |
   |   compute response =         |
   |     SHA256(nonce + filesHash) |
   |                              |
   |─── POST /launcher-token.php ─>|
   |    { launcherVersion,         |
   |      filesHash,               |
   |      channel,                 |
   |      manifestVersion,         |
   |      nonce,                   |
   |      challengeResponse }      |
   |                              |
   |<── { token, expiresIn } ─────|
```

### 2.1 Endpoint: `GET /challenge.php`

**Request:**
```
GET /challenge.php?channel=stable
```

**Response:**
```json
{
  "nonce": "a1b2c3d4e5f6...",
  "expiresInSeconds": 120,
  "issuedAtUtc": "2026-03-03T12:00:00Z"
}
```

### 2.2 Rozszerzony `LaunchTokenRequest`

Nowe pola (opcjonalne - backward compatibility):
```json
{
  "launcherVersion": "0.2.0",
  "filesHash": "abc123...",
  "channel": "stable",
  "manifestVersion": "2.0.0",
  "nonce": "a1b2c3d4e5f6...",
  "challengeResponse": "sha256_hex..."
}
```

### 2.3 Obliczenie response

```
challengeResponse = SHA-256( nonce + ":" + filesHash )
```

Separator `:` zapobiega kolizjom prefix/suffix.

---

## 3. Walidacja po stronie API

1. Sprawdź czy `nonce` istnieje w storage (Redis/DB) i nie wygasł.
2. Oblicz oczekiwany response: `SHA-256(nonce + ":" + filesHash)`.
3. Porównaj z `challengeResponse` (case-insensitive hex).
4. Jeśli niezgodne → 403 `CHALLENGE_FAILED`.
5. Po użyciu — unieważnij nonce (one-time use).

### 3.1 Backward compatibility

- Jeśli API nie wspiera challenge (stara wersja) → oba pola puste, flow działa jak dotychczas.
- Jeśli launcher nie wysyła challenge → API akceptuje (tryb legacy).
- Dopiero po włączeniu flagi `requireChallenge=true` w config API → brak challenge = 403.

---

## 4. Kody błędów

| Kod | Opis |
|-----|------|
| `CHALLENGE_EXPIRED` | Nonce wygasł (TTL) |
| `CHALLENGE_INVALID` | Response nie zgadza się |
| `CHALLENGE_REUSE` | Nonce użyty powtórnie |

---

## 5. Implikacje bezpieczeństwa

- **NIE jest to kryptograficzny dowód** posiadania launchera.
- Utrudnia prostą automatyzację (musi zrobić 2 requesty, obliczyć hash).
- Nonce TTL ogranicza okno replay.
- One-time use nonce blokuje replay attack.
- Dalsze hardening: rate-limit per IP na `/challenge.php`.
