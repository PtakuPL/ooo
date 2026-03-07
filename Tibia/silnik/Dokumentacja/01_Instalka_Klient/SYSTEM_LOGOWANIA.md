# System Logowania RedDaxe.pl — Kompleksowa Dokumentacja

> **Wersja:** 1.1 | **Data:** 2026-03  
> **Obejmuje:** Portal RedDAXE, Strona Tibia (MyAAC), API `/apik/v1/`, Launcher Rust, Serwery gry

---

## Spis Treści

1. [Architektura Systemu](#1-architektura-systemu)
2. [Bazy Danych](#2-bazy-danych)
3. [Sesje — Współdzielony Katalog](#3-sesje--współdzielony-katalog)
4. [Ścieżka Logowania: RedDAXE (Portal Główny)](#4-ścieżka-logowania-reddaxe-portal-główny)
5. [Ścieżka Logowania: Tibia WWW (MyAAC)](#5-ścieżka-logowania-tibia-www-myaac)
6. [Synchronizacja Sesji Między Serwisami](#6-synchronizacja-sesji-między-serwisami)
7. [Wylogowanie](#7-wylogowanie)
8. [Ścieżka Logowania: Launcher → Instalka → Serwer Gry](#8-ścieżka-logowania-launcher--instalka--serwer-gry)
9. [API — Endpointy `/apik/v1/`](#9-api--endpointy-apikv1)
10. [Rejestracja Konta](#10-rejestracja-konta)
11. [Synchronizacja WWW ↔ Launcher](#11-synchronizacja-www--launcher)
12. [System Wieloserwerowy (World)](#12-system-wieloserwerowy-world)
13. [Bezpieczeństwo](#13-bezpieczeństwo)
14. [Hashowanie Haseł](#14-hashowanie-haseł)
15. [Pliki i Lokalizacje](#15-pliki-i-lokalizacje)
16. [Diagramy Przepływów](#16-diagramy-przepływów)

---

## 1. Architektura Systemu

System logowania składa się z **pięciu komponentów**, które komunikują się przez wspólną bazę danych i API:

```
┌─────────────────┐     ┌──────────────────┐
│   RedDAXE        │     │   Tibia WWW       │       STRONA WEBOWA
│   Portal         │     │   (MyAAC)         │       (przeglądarka)
│   /reddaxe/      │     │   /system/        │
└───────┬──────────┘     └────────┬──────────┘
        │                         │
        │    ┌────────────────────┘
        │    │
        ▼    ▼
  ┌──────────────────────────────────────┐
  │         API  /apik/v1/               │
  │  login.php · launcher-token.php      │
  │  ticket.php · account-context.php    │
  │  update.php · register-account.php   │
  │  account-sync-www-token.php          │
  │  account-sync-consume.php            │
  └────────┬──────────┬──────────────────┘
           │          │
  ┌────────┘          │
  │                   │
  ▼                   │         GRA (desktop)
┌──────────────────┐  │
│  LAUNCHER         │  │
│  (Rust/Tauri)     │  │
│  launcher-rust/   │  │
│                   │  │
│ • Aktualizacja    │  │
│ • Integralność    │  │
│ • Launch token    │  │
│ • Uruchomienie    │  │
│   instalki        │  │
└────────┬──────────┘  │
         │ env:        │
         │ OTC_LAUNCH_ │
         │ TOKEN       │
         ▼             │
┌──────────────────┐   │
│  INSTALKA         │   │
│  (OTClient)       │   │
│                   │   │
│ • Login (email+   │   │
│   hasło)          │──►│
│ • Lista postaci   │   │
│ • Wybór trybu/    │   │
│   serwera/postaci │   │
│ • Pobranie HMAC   │   │
│   ticket          │   │
│ • Połączenie z    │   │
│   serwerem        │   │
└────────┬──────────┘   │
         │ HMAC ticket  │
         ▼              │
┌──────────────────┐    │
│  SERWER GRY       │    │
│  (Canary C++)     │◄───┘  (walidacja ticket
│                   │        przez ticket_sessions
│ • Classic 7.4     │        lub ticket_validator)
│ • Modern          │
└──────────┬────────┘
           │
  ┌────────┼────────────┐
  ▼        ▼            ▼
┌────────┐┌──────────┐┌──────────────┐
│canary- ││  canary   ││canary_modern │
│  aac   ││(classic74)││  (modern)    │
│(global)││          ││              │
└────────┘└──────────┘└──────────────┘
```

**Kluczowe zasady:**
- RedDAXE jest **centralnym punktem logowania na stronie** — Tibia WWW przekierowuje do niego
- Wszystkie komponenty webowe współdzielą **ten sam katalog sesji PHP** (`system/php_sessions/`)
- API jest **bezstanowe** (token-based) — nie używa sesji PHP
- **Launcher** to program desktopowy: aktualizuje klienta, sprawdza integralność, pobiera launch token i **uruchamia instalkę** — bez launchera nie da się włączyć instalki
- **Instalka (OTClient)** to właściwy klient gry: pokazuje login, listę postaci, łączy się z serwerem — dostaje launch token od launchera przez zmienną środowiskową `OTC_LAUNCH_TOKEN`
- **Serwer gry (Canary)** waliduje HMAC ticket wygenerowany przez `ticket.php` — ticket zawiera accountId, postać, świat i jest podpisany wspólnym sekretem (`TICKET_SECRET` == `ticketSecret` w config.lua)

---

## 2. Bazy Danych

### 2.1 `canaryaac` — Baza Globalna (GLOBAL_DB / API_DB)

Główna baza zawierająca konta graczy i tabele operacyjne API.

| Tabela | Opis |
|--------|------|
| `accounts` | Konta użytkowników (id, name, email, password, premium...) |
| `games` | Dostępne serwery gry (game_mode, game_host, game_port, sort_order) |
| `ticket_sessions` | Aktywne sesje logowania API (session_key, account_id, game_mode, expires_at) |
| `launch_tokens` | Jednorazowe tokeny launchera (token, launcher_version, files_hash, client_ip, expires_at) |
| `account_sync_tokens` | Tokeny synchronizacji WWW↔Launcher (token, account_id, source, target, expires_at, used_at) |
| `api_rate_limits` | Rate limiting (bucket, key_hash, expires_at) |
| `email_verification_tokens` | Weryfikacja e-mail (account_id, email, token_hash, expires_at) |
| `manifest_versions` | Manifesty klienta (version, channel, files_hash, is_active) |
| `ticket_nonces` | Challenge nonces (nonce, expires_at, account_id) |
| `account_identity_links` | OAuth/social login (opcjonalne) |

### 2.2 `canary` — Baza Silnika Classic 7.4 (ENGINE_DB)

| Tabela | Opis |
|--------|------|
| `players` | Postacie (name, level, vocation, account_id, **world=0**, deletion) |

### 2.3 `canary_modern` — Baza Silnika Modern (ENGINE_MODERN_DB)

| Tabela | Opis |
|--------|------|
| `players` | Postacie (name, level, vocation, account_id, **world=1**, deletion) |

### 2.4 Konfiguracja Baz

**API** (`.env`):
```
GLOBAL_DB_HOST, GLOBAL_DB_NAME, GLOBAL_DB_USER, GLOBAL_DB_PASS, GLOBAL_DB_PORT
API_DB_*     — domyślnie = GLOBAL_DB
ENGINE_DB_*  — classic74
ENGINE_MODERN_DB_* — modern
Fallback: DB_HOST, DB_NAME, DB_USER, DB_PASS, DB_PORT
```

**MyAAC** (`config.local.php`):
```php
$config['database_name'] = 'canaryaac';      // Konta
$config['modern_database_name'] = 'canary_modern';  // Modern engine
$config['database_encryption'] = 'sha1';
```

---

## 3. Sesje — Współdzielony Katalog

Oba serwisy webowe (RedDAXE i MyAAC) korzystają z **tego samego katalogu sesji PHP**:

```
/var/www/html/system/php_sessions/
```

Dzięki temu jedno `PHPSESSID` cookie = dostęp do sesji w obu serwisach.

### Klucze sesji RedDAXE
```php
$_SESSION['account']['user'] = ['id' => int, 'name' => string, 'email' => string];
$_SESSION['account']['sessionKey'] = string;  // 64-char hex z API
$_SESSION['login_timeout'] = int;             // timestamp ostatniej aktywności
```

### Klucze sesji MyAAC
```php
$_SESSION['myaac_account']     = int;      // ID konta
$_SESSION['myaac_password']    = string;   // sha1 hash hasła
$_SESSION['myaac_last_visit']  = int;      // timestamp
$_SESSION['myaac_remember_me'] = bool;     // zapamiętaj mnie
$_SESSION['myaac_last_page']   = string;
$_SESSION['myaac_last_uri']    = string;
```

> **Uwaga:** MyAAC używa prefiksu `myaac_` dla wszystkich swoich kluczy sesji. RedDAXE używa `$_SESSION['account']` (tablica) i `$_SESSION['login_timeout']`.

### Czas życia sesji
| Komponent | Timeout | Mechanizm |
|-----------|---------|-----------|
| RedDAXE | 30 min | `time() - login_timeout > 1800` |
| MyAAC | 15 min | `last_visit > time() - 15*60` |
| MyAAC remember_me | Bez limitu | Pomija timeout 15 min |
| API ticket_sessions | 30 min | `SESSION_TTL` w `.env` |

---

## 4. Ścieżka Logowania: RedDAXE (Portal Główny)

### Plik: `/reddaxe/account-login.php`

To jest **główny punkt wejścia logowania** dla całego systemu webowego.

### Diagram przepływu:

```
Użytkownik → GET /reddaxe/account-login.php
           → Formularz (email + hasło + remember me)
           → POST /reddaxe/account-login.php
              │
              ├── 1. Walidacja email/hasło (client-side + server-side)
              │
              ├── 2. Pobierz Launch Token
              │      POST /apik/v1/launcher-token.php
              │      ← { token: "64hex", expiresInSeconds: 300 }
              │
              ├── 3. Logowanie przez API
              │      POST /apik/v1/login.php
              │      → { type: "login", email, password, gameMode: "all", launchToken }
              │      ← { session: { sessionkey: "64hex", ... }, playdata: {...} }
              │
              ├── 4. Pobierz kontekst konta
              │      POST /apik/v1/account-context.php
              │      → { type: "account_context", sessionKey }
              │      ← { account: { id, name, email }, charactersByWorld: {...} }
              │
              └── 5. Ustaw sesję PHP
                     ├── session_regenerate_id(true)  // bezpieczeństwo
                     ├── $_SESSION['account']['user'] = {id, name, email}
                     ├── $_SESSION['account']['sessionKey'] = sessionkey
                     ├── $_SESSION['login_timeout'] = time()
                     │
                     ├── CROSS-SITE SYNC (dla MyAAC):
                     │   ├── $_SESSION['myaac_account'] = accountId
                     │   ├── $_SESSION['myaac_password'] = DB hash lub sha1(hasło)
                     │   ├── $_SESSION['myaac_last_visit'] = time()
                     │   └── $_SESSION['myaac_remember_me'] = rememberMe
                     │
                     └── 302 Redirect → $redirectPath
                         ├── Jeśli source=tibiawww → /?subtopic=accountmanagement
                         └── Normalnie → /reddaxe/post-login.php
```

### Mechanizm "Remember Me"
Gdy użytkownik zaznacza "Zapamiętaj mnie":
1. Cookie sesji `PHPSESSID` przedłużony do **30 dni**
2. Cookie `reddaxe_email` zapisany na 30 dni (pre-fill formularza)
3. `gc_maxlifetime` ustawiony na 30 dni
4. MyAAC `remember_me` = true → pomija 15-minutowy timeout

### Funkcja `reddaxe_issue_launch_token()`
Przed logowaniem przez API, system pobiera launch token:
1. GET `/apik/v1/update.php?channel=stable` → pobiera `filesHash` z aktywnego manifestu
2. POST `/apik/v1/launcher-token.php` → { launcherVersion, filesHash, manifestVersion, channel }
3. Zwraca jednorazowy 64-hex token ważny 5 minut

### Funkcja `reddaxe_fetch_myaac_password_hash()`
Plik: `/reddaxe/bootstrap.php`

Zamiast hashować hasło ponownie, pobiera **istniejący hash z bazy danych**:
```php
function reddaxe_fetch_myaac_password_hash(int $accountId): ?string
{
    // Łączy się z canaryaac.accounts
    // SELECT password FROM accounts WHERE id = :id
    // Zwraca raw hash (sha1) z bazy
}
```

To zapewnia, że `myaac_password` w sesji = dokładnie to samo co w DB, więc walidacja MyAAC zawsze przejdzie.

---

## 5. Ścieżka Logowania: Tibia WWW (MyAAC)

### 5.1 Przekierowanie do RedDAXE

**Plik:** `system/pages/account/base.php`

Gdy użytkownik próbuje wejść na stronę konta na Tibia WWW bez logowania:

```php
if (!$logged) {
    header('Location: /reddaxe/account-login.php?source=tibiawww', true, 302);
    exit;
}
```

Parametr `source=tibiawww` mówi RedDAXE, że po zalogowaniu ma wrócić na stronę Tibia.

### 5.2 Walidacja Sesji na Każdej Stronie

**Plik:** `system/login.php` (ładowany na KAŻDYM page load)

```php
$current_session = getSession('account');  // = $_SESSION['myaac_account']
if ($current_session) {
    $account_logged->load($current_session);
    if ($account_logged->isLoaded()
        && $account_logged->getPassword() == getSession('password')    // hash == hash
        && (getSession('remember_me') || getSession('last_visit') > time() - 15*60))
    {
        $logged = true;
        setSession('last_visit', time());
    } else {
        unsetSession('account');
        // ... clear rest
    }
}
```

**Kluczowe:**
- Porównuje `getPassword()` (z DB) z `getSession('password')` (z sesji)
- Jeśli hash się nie zgadza → wylogowanie
- Jeśli brak `remember_me` i `last_visit` > 15 min → wylogowanie

### 5.3 Logowanie Bezpośrednie przez MyAAC

**Plik:** `system/pages/account/login.php` (POST handler)

Choć normalnie MyAAC przekierowuje do RedDAXE, sam formularz MyAAC nadal działa jako fallback:

```
1. Pobierz email + hasło z POST
2. Sprawdź rate limit
3. Znajdź konto (by email lub name)
4. Waliduj hasło: encrypt(salt + password) == account->getPassword()
5. session_regenerate_id()
6. setSession('account', $id)
7. setSession('password', encrypt(salt + password))
8. setSession('remember_me', $rememberMe)

   CROSS-SITE SYNC (do RedDAXE):
9. $_SESSION['account']['user'] = ['id', 'name', 'email']
10. $_SESSION['account']['sessionKey'] = bin2hex(random_bytes(16))
11. $_SESSION['login_timeout'] = time()
```

Dzięki krokowi 9-11, nawet logowanie przez stary formularz MyAAC automatycznie loguje w RedDAXE.

### 5.4 Dodatkowe Przekierowania

**Plik:** `templates/tibiacom/index.php` (template entry)

```php
// Redirect /account/* to account management
if (in_array($requestPath, ['/account', '/index.php/account/manage',
                             '/index.php/account/login', '/index.php/account/logout'])) {
    header('Location: ' . BASE_URL . '?subtopic=accountmanagement', true, 302);
    exit;
}

// Redirect account create to RedDAXE
if (in_array($requestPath, ['/index.php/account/create', '/account/create'])) {
    header('Location: ' . BASE_URL . 'reddaxe/account-create.php?source=tibiawww', true, 302);
    exit;
}
```

---

## 6. Synchronizacja Sesji Między Serwisami

### 6.1 RedDAXE → MyAAC (Logowanie przez RedDAXE)

Gdy użytkownik loguje się na `/reddaxe/account-login.php`:

```php
// Klucze RedDAXE:
$_SESSION['account']['user'] = ['id' => $accountId, 'name' => $accountName, 'email' => $accountEmail];
$_SESSION['account']['sessionKey'] = $sessionKey;
$_SESSION['login_timeout'] = time();

// Klucze MyAAC (cross-site sync):
$_SESSION['myaac_account'] = $accountId;
$_SESSION['myaac_password'] = reddaxe_fetch_myaac_password_hash($accountId);  // SHA1 hash z DB
$_SESSION['myaac_last_visit'] = time();
$_SESSION['myaac_remember_me'] = $rememberMe;
```

**Efekt:** Po zalogowaniu na RedDAXE → użytkownik automatycznie zalogowany na stronie Tibia WWW.

### 6.2 MyAAC → RedDAXE (Logowanie przez MyAAC)

Gdy użytkownik loguje się przez formularz MyAAC (`system/pages/account/login.php`):

```php
// Klucze MyAAC (standardowe):
setSession('account', $account->getId());
setSession('password', encrypt($password));
setSession('remember_me', $rememberMe);

// Klucze RedDAXE (cross-site sync):
$_SESSION['account']['user'] = ['id' => ..., 'name' => ..., 'email' => ...];
$_SESSION['account']['sessionKey'] = bin2hex(random_bytes(16));
$_SESSION['login_timeout'] = time();
```

**Efekt:** Po zalogowaniu na MyAAC → użytkownik automatycznie zalogowany na RedDAXE.

### 6.3 Dlaczego to Działa

Oba serwisy używają **tego samego katalogu sesji** (`system/php_sessions/`) i **tego samego ciasteczka** (`PHPSESSID`). Klucze sesji nie kolidują bo:
- MyAAC: prefix `myaac_` (`$_SESSION['myaac_account']`, `$_SESSION['myaac_password']`, etc.)
- RedDAXE: tablica `$_SESSION['account']` + `$_SESSION['login_timeout']`

---

## 7. Wylogowanie

### 7.1 RedDAXE Logout (`/reddaxe/logout.php`)

```php
reddaxe_start_shared_session();

// Czyści klucze RedDAXE:
unset($_SESSION['account']['user']);
unset($_SESSION['account']['sessionKey']);
unset($_SESSION['login_timeout']);

// Czyści klucze MyAAC:
unset($_SESSION['myaac_account']);
unset($_SESSION['myaac_password']);
unset($_SESSION['myaac_last_visit']);
unset($_SESSION['myaac_remember_me']);

session_write_close();
header('Location: /reddaxe/index.php');
```

### 7.2 MyAAC Logout (`/system/logout.php`)

```php
if ($account_logged->isLoaded()) {
    // Czyści klucze MyAAC:
    unsetSession('account');     // = unset($_SESSION['myaac_account'])
    unsetSession('password');    // = unset($_SESSION['myaac_password'])
    unsetSession('remember_me'); // = unset($_SESSION['myaac_remember_me'])

    // Czyści klucze RedDAXE:
    unset($_SESSION['account'], $_SESSION['login_timeout']);

    CsrfToken::generate();
    $logged = false;
}
```

### 7.3 Timeout (Auto-wylogowanie)

**RedDAXE** (`post-login.php`):
```php
if ($loginTimeout <= 0 || (time() - $loginTimeout) > 1800) {
    // 30 minut bez aktywności → czyści OBA zestawy kluczy
    unset($_SESSION['account']['user'], $_SESSION['account']['sessionKey'], $_SESSION['login_timeout']);
    unset($_SESSION['myaac_account'], $_SESSION['myaac_password'], ...);
}
```

**MyAAC** (`system/login.php`):
```php
if (!getSession('remember_me') && getSession('last_visit') <= time() - 15*60) {
    // 15 minut bez aktywności + brak remember_me → wylogowanie z MyAAC
    unsetSession('account');
}
```

---

## 8. Ścieżka Logowania: Launcher → Serwer Gry

### Architektura Launchera

Launcher jest aplikacją **Rust** z frontendem **Tauri**:

```
launcher-rust/
├── crates/
│   ├── common-models/     # Wspólne struktury danych
│   ├── launcher-api/      # Klient HTTP do API
│   │   └── src/client.rs  # LauncherApiClient
│   ├── launcher-core/     # Logika biznesowa launchera
│   └── launcher-helper/   # Narzędzia pomocnicze
├── apps/
│   ├── launcher-cli/      # CLI launcher
│   └── launcher-tauri/    # GUI launcher (Tauri)
└── launcher_config.json   # Konfiguracja
```

### Konfiguracja Launchera

```json
{
  "apiBaseUrl": "https://reddaxe.pl/apik/v1",
  "channel": "stable",
  "clientDir": "client",
  "launcherDataDir": ".launcher",
  "devMode": true
}
```

### Przepływ Logowania: Launcher → API → Serwer

```
Launcher (GUI/CLI)
      │
      ├── 1. LAUNCHER TOKEN
      │      POST /apik/v1/launcher-token.php
      │      → { launcherVersion, filesHash, manifestVersion, channel }
      │      ← { token: "64hex", expiresInSeconds: 300 }
      │
      ├── 2. LOGOWANIE
      │      POST /apik/v1/login.php
      │      → { type: "login", email, password, gameMode, launchToken }
      │      ← { session: { sessionkey, key, ispremium, ... },
      │           playdata: { worlds: [...], characters: [...] } }
      │
      ├── 3. KONTEKST KONTA (opcjonalnie)
      │      POST /apik/v1/account-context.php
      │      → { type: "account_context", sessionKey }
      │      ← { account, charactersByWorld, ... }
      │
      ├── 4. WYBÓR POSTACI
      │      Użytkownik wybiera postać + serwer z listy
      │
      └── 5. POŁĄCZENIE Z SERWEREM GRY
             Klient OTClient łączy się z serwerem:
             → sessionKey jako uwierzytelnienie
             → Serwer waliduje sessionKey w tabeli ticket_sessions
```

### Walidacja Launch Token

Launch token zapewnia, że **tylko autoryzowany launcher** może się logować:

1. **Wersja launchera** — musi być >= `LAUNCHER_MIN_VERSION`
2. **Hash plików klienta** — weryfikacja integralności plików gry z tabeli `manifest_versions`
3. **IP binding** — token powiązany z IP klienta
4. **Jednorazowy** — token usuwany po użyciu (atomic SELECT FOR UPDATE)
5. **5-minutowy TTL** — token wygasa po 300 sekundach
6. **Rate limit** — max 5 tokenów/min per IP

### Walidacja Session Key przez Serwer Gry

Serwer gry (C++ Canary) przy połączeniu klienta:
1. Odbiera `sessionKey` od klienta
2. Sprawdza w `canaryaac.ticket_sessions` czy session_key istnieje
3. Weryfikuje `expires_at > NOW()`
4. Pobiera `account_id` i `game_mode`
5. Ładuje postać gracza z odpowiedniej bazy (`canary` lub `canary_modern`)
6. Tworzy połączenie w grze

---

## 9. API — Endpointy `/apik/v1/`

### 9.1 `login.php` — Logowanie

**Żądanie:**
```json
{
  "type": "login",
  "email": "gracz@reddaxe.pl",
  "password": "haslo123",
  "gameMode": "all",           // "all" | "classic74" | "modern"
  "launchToken": "64hex..."    // opcjonalny, wymagany gdy CLIENT_LOCKED=true
}
```

**Walidacje:**
- Rate limit: 10/min per email, 30/min per IP
- Konto musi istnieć w `canaryaac.accounts`
- Hasło: SHA1 (case-insensitive), bcrypt, argon2, lub plaintext
- Launch token (jeśli podany): SELECT FOR UPDATE → weryfikacja → usunięcie

**GameMode:**
- `all` → zwraca światy i postacie ze wszystkich serwerów
- `classic74` → tylko Classic 7.4 (world=0)
- `modern` → tylko Modern (world=1)
- Dynamiczna lista światów z tabeli `games` (world_id = sort_order - 1)

**Odpowiedź (sukces):**
```json
{
  "session": {
    "sessionkey": "64hex_uuid",
    "key": "account_name\npassword",
    "ispremium": true,
    "premiumuntil": 1735689600,
    "status": "active",
    "gameMode": "all"
  },
  "playdata": {
    "worlds": [
      { "id": 0, "name": "Classic 7.4", "pvptype": 0, ... },
      { "id": 1, "name": "Modern", "pvptype": 0, ... }
    ],
    "characters": [
      { "worldid": 0, "name": "Testowy", "level": 8, ... },
      { "worldid": 1, "name": "Lokoi", "level": 100, ... }
    ]
  }
}
```

**Odpowiedź (błąd):**
```json
{
  "errorCode": 3,
  "errorMessage": "Invalid email or password."
}
```

### 9.2 `launcher-token.php` — Token Launchera

**Żądanie:**
```json
{
  "launcherVersion": "1.0.0",
  "filesHash": "sha256_hex",
  "manifestVersion": "1.0.0",
  "channel": "stable",
  "nonce": "optional_challenge",
  "challengeResponse": "optional_response"
}
```

**Walidacje:**
- `launcherVersion >= LAUNCHER_MIN_VERSION`
- `filesHash` musi zgadzać się z `manifest_versions` (channel-specific)
- Challenge-response (opcjonalnie, jeśli CHALLENGE_REQUIRED=true)
- Rate limit: 5/min per IP

**Odpowiedź:**
```json
{
  "token": "64hex_uuid",
  "expiresInSeconds": 300
}
```

**Baza:**
```sql
INSERT INTO launch_tokens (token, launcher_version, files_hash, manifest_version, client_ip, expires_at)
```

### 9.3 `account-context.php` — Kontekst Konta

**Żądanie:**
```json
{
  "type": "account_context",
  "sessionKey": "64hex_z_login.php"
}
```

**Odpowiedź:**
```json
{
  "session": { "sessionKey": "...", "accountId": 123, "gameMode": "all", "expiresAt": ... },
  "account": { "id": 123, "name": "ptaku123", "email": "ptaku@reddaxe.pl" },
  "worlds": [...],
  "charactersByWorld": {
    "classic74": [{ "name": "Testowy", "level": 8, ... }],
    "modern": [{ "name": "Lokoi", "level": 100, ... }],
    "unknown": []
  },
  "counts": { "classic74": 1, "modern": 2, "total": 3 },
  "activeProfile": { ... },
  "links": { ... }
}
```

### 9.4 `register-account.php` — Rejestracja

**Żądanie:**
```json
{
  "type": "register",
  "accountName": "nowygracz",
  "email": "nowy@reddaxe.pl",
  "password": "silnehaslo123",
  "passwordConfirm": "silnehaslo123"
}
```

**Walidacje:**
- Nazwa: `^[A-Za-z0-9_]{3,32}$`
- Email: valid format + unikalność
- Hasło: 6-72 znaków
- Rate limit: 3 rejestracje/godz per IP

**Tworzy:**
1. Konto w `canaryaac.accounts` (hash SHA1 w `password` + `engine_password_sha1`)
2. Token weryfikacji e-mail w `email_verification_tokens` (64 hex, 24h TTL)
3. Wysyła e-mail z linkiem weryfikacyjnym

### 9.5 `verify-email.php` — Weryfikacja E-mail

**GET:** `?token=64hex`

Weryfikuje token, aktywuje konto, przekierowuje do logowania z parametrem `?verified=1`.

### 9.6 `update.php` — Manifest Aktualizacji

**GET:** `?channel=stable`

Zwraca aktualny manifest klienta gry (wersję, hash plików, ścieżki do pobrania).

### 9.7 `ticket.php` — Ticket HMAC do Serwera Gry

**Żądanie:**
```json
{
  "type": "ticket",
  "sessionKey": "64hex_z_login.php",
  "characterName": "Testowy",
  "gameMode": "classic74",
  "worldName": "Classic 7.4"
}
```

**Walidacje:**
1. `sessionKey` istnieje w `ticket_sessions` i nie wygasł
2. `characterName` należy do konta z sesji (ENGINE_DB)
3. `gameMode` zgadza się z sesją (lub sesja ma "all" → wymaga wyboru)
4. `worldName` zgadza się z `games` table dla danego `gameMode`
5. Postać należy do właściwego świata (`players.world == worldId`)

**Generacja HMAC Ticket:**
```
payload = json({accountId, characterName, gameMode, worldName, worldId, nonce, iat, expiresAt})
ticket = base64(payload) + "." + HMAC-SHA256(base64(payload), TICKET_SECRET)
```

**Odpowiedź:**
```json
{
  "ticket": "base64payload.hmachex",
  "expiresAt": 1741000030
}
```

Ticket ważny `TICKET_TTL` sekund (domyślnie 30s). Jednorazowy — nonce walidowany przez serwer gry.

### 9.8 `account-sync-www-token.php` — Token Synchronizacji WWW→Launcher

Patrz: [Sekcja 11](#11-synchronizacja-www--launcher)

### 9.9 `account-sync-consume.php` — Konsumpcja Tokenu Synchronizacji

Patrz: [Sekcja 11](#11-synchronizacja-www--launcher)

### 9.10 `change-account-name.php` — Zmiana Nazwy Wyświetlanej Konta

**Żądanie:**
```json
{
  "type": "change_account_name",
  "sessionKey": "...",
  "newName": "NowaNazwa123"
}
```

**Walidacje:**
- Aktywna sesja (`ticket_sessions`)
- Nazwa: 3-32 znaków `[A-Za-z0-9_ ]`
- Unikalność (case-insensitive, `LOWER(name)`)
- Rate limit: 3 zmiany / 10 min per sesja

**Odpowiedź:**
```json
{ "ok": true, "message": "Account name changed successfully.", "newName": "NowaNazwa123" }
```

### 9.11 `change-character-name.php` — Zmiana Nazwy Postaci

**Żądanie:**
```json
{
  "type": "change_character_name",
  "sessionKey": "...",
  "playerId": 123,
  "gameMode": "classic74",
  "newName": "Nowa Nazwa"
}
```

**Walidacje:**
- Aktywna sesja (`ticket_sessions`)
- Postać należy do konta z sesji (weryfikacja ownership w ENGINE_DB)
- Postać nie jest usunięta (`deletion = 0`)
- Postać nie jest online (`players_online`)
- Nazwa: 3-29 znaków, litery i spacje, bez podwójnych spacji
- Unikalność w **obu** bazach engine (classic + modern) — cross-server check
- Auto-formatowanie: `ucfirst` każde słowo
- Rate limit: 3 zmiany / 10 min per sesja
- Aktualizacja referencji w `player_deaths` (killed_by, mostdamage_by)

**Odpowiedź:**
```json
{ "ok": true, "message": "Character name changed successfully.", "oldName": "Stara Nazwa", "newName": "Nowa Nazwa" }
```

### 9.12 `change-password.php` — Zmiana Hasła

**Żądanie:**
```json
{
  "type": "change_password",
  "sessionKey": "...",
  "currentPassword": "stare",
  "newPassword": "nowe",
  "newPasswordConfirm": "nowe"
}
```

**Walidacje:**
- Aktywna sesja, weryfikacja obecnego hasła (SHA1/bcrypt/argon2/plaintext)
- Nowe hasło: 6-72 znaków
- Rate limit: 5 prób / 5 min per sesja

**Odpowiedź:**
```json
{ "ok": true, "message": "Password changed successfully." }
```

### 9.13 `common.php` — Współdzielone Narzędzia

Zawiera:
- **Połączenia DB:** `getGlobalDb()`, `getApiDb()`, `getEnginePdo()`, `getBothEnginePdos()`, `getGameDb()`
- **Bezpieczeństwo:** `getClientIp()` (z trusted proxy), `hashClientIp()`, `applyRateLimit()`
- **Logowanie:** `logTicketEvent()` → JSONL do pliku
- **Odpowiedzi:** `sendError()` (format OTClient), `sendLauncherError()`, `json_out()`
- **Konfiguracja:** `loadEnvFiles()`, `requireDbConfig()`

---

## 10. Rejestracja Konta

### Przepływ przez RedDAXE

```
Użytkownik → GET /reddaxe/account-create.php
           → Formularz (accountName + email + password + confirmPassword)
           → POST /reddaxe/account-create.php
              │
              ├── Walidacja client-side
              ├── POST /apik/v1/register-account.php
              │     → { type: "register", accountName, email, password, passwordConfirm }
              │     ← { ok: true, accountId: 123 }
              │
              └── Komunikat: "Konto utworzone! Sprawdź email."
                  + Link do logowania z pre-filled email
```

### Weryfikacja E-mail

```
API → Wysyła email z linkiem:
      https://reddaxe.pl/apik/v1/verify-email.php?token=64hex
      (ważny 24 godziny)

Użytkownik klika link → verify-email.php:
      1. Waliduje token
      2. Aktywuje konto (accounts.email_verified = 1)
      3. Usuwa token z email_verification_tokens
      4. 302 → /reddaxe/account-login.php?verified=1
```

### Przekierowanie z Tibia WWW

Strona Tibia WWW `/account/create` automatycznie przekierowuje do RedDAXE:
```php
// templates/tibiacom/index.php
if (in_array($requestPath, ['/index.php/account/create', '/account/create'])) {
    header('Location: /reddaxe/account-create.php?source=tibiawww', true, 302);
    exit;
}
```

---

## 11. Synchronizacja WWW ↔ Launcher

Mechanizm pozwalający użytkownikowi **zalogowanemu na stronie** zsynchronizować sesję z launcherem bez ponownego wpisywania hasła.

### Krok 1: Generowanie Tokenu Synchronizacji

**Plik:** `account-sync-www-token.php`

```
POST /apik/v1/account-sync-www-token.php
→ { "type": "account_sync_www_token", "target": "launcher" }
← {
     "ok": true,
     "syncToken": "64hex",
     "source": "www",
     "target": "launcher",
     "expiresAt": 1735689600,
     "consumeEndpoint": "https://reddaxe.pl/apik/v1/account-sync-consume.php",
     "launcherDeepLink": "launcher://account-sync?token=64hex"
   }
```

**Walidacje:**
- Aktywna sesja webowa (MyAAC session check)
- Sesja nie wygasła (30 min default)
- Konto istnieje
- Max `ACCOUNT_SYNC_WWW_OPEN_TOKENS_MAX` (3) otwartych tokenów per konto

**Baza:**
```sql
INSERT INTO account_sync_tokens
  (token, account_id, source, target, expires_at, metadata_json)
VALUES (?, ?, 'www', 'launcher', ?, ?)
```

Token ważny `ACCOUNT_SYNC_TOKEN_TTL` sekundy (domyślnie 120s = 2 minuty).

### Krok 2: Konsumpcja Tokenu przez Launcher

**Plik:** `account-sync-consume.php`

```
POST /apik/v1/account-sync-consume.php
→ { "type": "account_sync_consume", "syncToken": "64hex", "target": "launcher" }
← {
     "ok": true,
     "sync": {
       "sessionKey": "64hex",
       "accountId": 123,
       "source": "www",
       "target": "launcher",
       "expiresAt": 1735689600
     },
     "account": { ... },
     "charactersByWorld": { ... },
     "identities": [...]
   }
```

**Walidacje:**
- Token istnieje i nie wygasł
- Token nie był jeszcze użyty (jednorazowy)
- **Atomiczność:** `SELECT FOR UPDATE` → `UPDATE used_at=NOW()` → `INSERT ticket_sessions`

### Przepływ UI w Post-Login

Na stronie `/reddaxe/post-login.php` jest przycisk "Synchronizuj z Launcherem":

```
1. Użytkownik klika "Sync to Launcher"
2. JavaScript → fetch('/apik/v1/account-sync-www-token.php', {...})
3. API zwraca syncToken + launcherDeepLink
4. Strona wyświetla deep link: launcher://account-sync?token=64hex
5. Użytkownik klika → launcher otwiera się i automatycznie konsumuje token
6. Launcher ma nową sesję → gotowy do gry
```

---

## 12. System Wieloserwerowy (World)

### Mapowanie Serwerów

| World ID | Serwer | Baza | config.lua |
|----------|--------|------|------------|
| 0 | Classic 7.4 | `canary` | `canary_test/config.lua` |
| 1 | Modern | `canary_modern` | `canary_modern/config.lua` |

Kolumna `players.world` w bazie określa, na którym serwerze gra postać.

### Dynamiczna Lista Światów

API buduje listę serwerów z tabeli `games`:
```sql
SELECT * FROM games WHERE is_active = 1 ORDER BY sort_order
```

Mapowanie: `world_id = sort_order - 1` (0=Classic, 1=Modern)

### Strona Postaci (Characters)

**Plik:** `system/pages/characters.php`

Lista postaci na profilu jest **rozdzielona per serwer**:

```php
// Pobierz world aktualnej postaci
$currentWorldId = (int)$db->query(
    'SELECT world FROM players WHERE id = ' . $player->getId()
)->fetchColumn();

// Rozdziel postacie
foreach ($account_players as $p) {
    if ((int)$p['world'] === $currentWorldId) {
        $sameServerPlayers[] = $p;
    } else {
        $otherServerPlayers[] = $p;
    }
}
```

**Template:** `system/templates/characters.html.twig`
- Główna tabela: "Postacie — Classic 7.4" (lub "Modern")
- Zwijana sekcja: "► Postacie — Modern" (lub "Classic 7.4")
- Domyślnie: zwinięta, kliknięcie = rozwinięcie/zwinięcie

---

## 13. Bezpieczeństwo

### 13.1 Rate Limiting

| Bucket | Limit | Okno |
|--------|-------|------|
| `login:email` | 10 prób | 1 minuta |
| `login:ip` | 30 prób | 1 minuta |
| `register:ip` | 3 rejestracje | 1 godzina |
| `launcher_token:ip` | 5 tokenów | 1 minuta |
| `change_password:session` | 5 prób | 5 minut |
| `change_name:session` | 3 zmiany | 10 minut |
| `change_char_name:session` | 3 zmiany | 10 minut |

Tabela `api_rate_limits`:
```sql
CREATE TABLE api_rate_limits (
  id INT AUTO_INCREMENT PRIMARY KEY,
  bucket VARCHAR(64) NOT NULL,
  key_hash VARCHAR(64) NOT NULL,
  expires_at INT NOT NULL,
  INDEX idx_bucket_key (bucket, key_hash),
  INDEX idx_expires (expires_at)
);
```

### 13.2 Jednorazowe Tokeny

- **Launch tokens** — ważne 5 min, usuwane po użyciu (SELECT FOR UPDATE)
- **Sync tokens** — ważne 2 min, oznaczane jako used_at po konsumpcji
- **Email verification** — ważne 24h, usuwane po weryfikacji

### 13.3 IP Binding

Launch token powiązany z IP klienta:
```php
// Przy tworzeniu:
INSERT INTO launch_tokens (token, ..., client_ip, ...) VALUES (?, ..., ?, ...)

// Przy walidacji:
if ($token['client_ip'] !== getClientIp($ENV)) → reject
```

### 13.4 Trusted Proxies

```env
TRUSTED_PROXIES=127.0.0.1,172.16.0.0/12
```

`getClientIp()` sprawdza `X-Forwarded-For` / `X-Real-IP` tylko jeśli requestujący IP jest w trusted range.

### 13.5 Fail-Closed Design

- Brak `.env` → aplikacja odmawia startu
- Brak aktywnego manifestu → `launcher-token.php` odrzuca żądania
- Brak bazy danych → fatal error (nie fallback do insecure)

### 13.6 Session Regeneration

Przy logowaniu zawsze:
```php
session_regenerate_id(true);  // true = usuń starą sesję
```

### 13.7 JSONL Security Logging

```php
logTicketEvent('login_ok', [
    'account_id' => $accountId,
    'ip_hash' => hashClientIp($ip, $ENV),
    'email_hash' => hash('sha256', $email),
    'game_mode' => $gameMode,
], $ENV);
```

Log format: JSON Lines, jeden event per linia, z timestampem i IP hashowanym (nie raw).

### 13.8 Kluczowe Mechanizmy Bezpieczeństwa (Audyt)

| Kod | Opis |
|-----|------|
| FIX-AUD5 | Channel-specific files hash validation |
| FIX-AUD6 | Manifest version check w launch token |
| FIX-AUD12 | Trusted proxy dla IP detection |
| FIX-AUD13 | Channel-specific manifest verification |
| FIX-AUD18 | Fail-closed DB config (require .env) |
| FIX-AUD21 | No manifests = reject token requests |
| FIX39 | Multi-format password hash support |
| FIX29/52 | Premium calculation from DB |
| W71 | Comprehensive rate limiting |

---

## 14. Hashowanie Haseł

### Na Stronie (MyAAC)

```php
// config.local.php
$config['database_encryption'] = 'sha1';
// Brak soli (database_salt jest pusty)

// encrypt() w system/functions.php:
function encrypt($str) {
    // Jeśli database_salt ustawiony: $str .= $salt;
    return sha1($str);  // lub md5, vahash
}
```

Hash w bazie: `sha1(plaintext_password)`

### W API

API obsługuje **wiele formatów hashów**:
```php
if (strlen($dbHash) === 40) {
    // SHA1: case-insensitive compare
    return strtolower($dbHash) === strtolower(sha1($password));
} elseif (password_get_info($dbHash)['algo'] !== null) {
    // bcrypt/argon2: password_verify()
    return password_verify($password, $dbHash);
} else {
    // Plaintext fallback: hash_equals()
    return hash_equals($dbHash, $password);
}
```

### Cross-Site Sync Hash

Przy logowaniu przez RedDAXE, `myaac_password` w sesji musi dokładnie zgadzać się z hashem w bazie:

```php
// Metoda 1 (preferowana): Pobierz hash bezpośrednio z DB
$dbPasswordHash = reddaxe_fetch_myaac_password_hash($accountId);

// Metoda 2 (fallback): Hashuj hasło ręcznie
$hash = sha1($password);

$_SESSION['myaac_password'] = $dbPasswordHash ?? $hash;
```

Metoda 1 jest bezpieczniejsza bo gwarantuje identyczny hash (eliminuje potencjalne problemy z solą/formatem).

---

## 15. Pliki i Lokalizacje

### Struktura Katalogów

```
/var/www/html/                              # DocumentRoot (runtime)
├── reddaxe/
│   ├── account-login.php                   # Główny punkt logowania
│   ├── account-create.php                  # Rejestracja
│   ├── account-manage.php                  # Zarządzanie kontem (hasło, nazwa, postacie)
│   ├── bootstrap.php                       # Session + HTTP client + helpers
│   ├── logout.php                          # Wylogowanie (oba zestawy kluczy)
│   ├── post-login.php                      # Post-login dashboard + sync
│   ├── reset-password.php                  # Odzyskiwanie hasła
│   ├── go.php                              # Redirect helper
│   ├── index.php                           # Strona główna portalu
│   └── i18n/                               # Tłumaczenia (pl, en)
│
├── apik/v1/
│   ├── login.php                           # API: Logowanie
│   ├── launcher-token.php                  # API: Token launchera
│   ├── ticket.php                          # API: HMAC ticket dla serwera gry
│   ├── update.php                          # API: Manifest aktualizacji
│   ├── register-account.php                # API: Rejestracja
│   ├── register-account-lib.php            # Wspólna logika rejestracji
│   ├── account-context.php                 # API: Kontekst konta
│   ├── account-sync-www-token.php          # API: Token synchronizacji
│   ├── account-sync-consume.php            # API: Konsumpcja tokenu sync
│   ├── change-password.php                 # API: Zmiana hasła
│   ├── change-account-name.php             # API: Zmiana nazwy wyświetlanej konta
│   ├── change-character-name.php           # API: Zmiana nazwy postaci
│   ├── verify-email.php                    # API: Weryfikacja e-mail
│   ├── common.php                          # Współdzielone narzędzia
│   ├── mailer.php                          # Wysyłanie e-maili
│   ├── .env                                # Konfiguracja API
│   ├── manifests/                          # Manifesty klienta
│   └── migrations/                         # Migracje DB
│
├── system/
│   ├── init.php                            # Inicjalizacja MyAAC + branding
│   ├── login.php                           # Walidacja sesji (każdy page load)
│   ├── logout.php                          # Wylogowanie MyAAC + RedDAXE
│   ├── functions.php                       # setSession(), encrypt(), etc.
│   ├── php_sessions/                       # Współdzielony katalog sesji
│   ├── pages/
│   │   ├── account/
│   │   │   ├── base.php                    # Redirect do RedDAXE jeśli niezalogowany
│   │   │   └── login.php                   # POST handler MyAAC + cross-site sync
│   │   └── characters.php                  # Lista postaci (split by world)
│   └── templates/
│       └── characters.html.twig            # Template postaci (zwijane sekcje)
│
├── config.local.php                        # Konfiguracja DB i serwerów
└── templates/tibiacom/
    └── index.php                           # Przekierowania /account/* → RedDAXE
```

### Repozytorium (kod źródłowy)

```
/home/ptaku/serweryt/Tibia/silnik/canary_test/html_copy/
├── reddaxe/            # ← Kod RedDAXE
├── apik/               # ← Kod API (login, ticket, sync, register)
├── system/             # ← Kod MyAAC (zmodyfikowany)
├── config.local.php
└── templates/
```

Branch: `feature/ticket-gate`

### Serwer Gry (Canary)

```
/home/ptaku/serweryt/Tibia/silnik/canary_test/
├── src/server/network/protocol/
│   ├── ticket_validator.cpp   # Walidacja HMAC ticket (ticket-gate)
│   └── ticket_validator.hpp   # Deklaracja TicketValidator + nonce
├── config.lua                 # ticketGateEnabled, ticketSecret, worldId
```

### Launcher (Rust)

```
/home/ptaku/serweryt/Tibia/silnik/launcher-rust/
├── crates/
│   ├── common-models/          # Wspólne struktury danych
│   ├── launcher-api/           # HTTP client do API (client.rs)
│   ├── launcher-core/          # Logika biznesowa:
│   │   ├── process_runner.rs   #   Uruchamianie instalki (OTC_LAUNCH_TOKEN)
│   │   └── serverlist_sync.rs  #   Synchronizacja listy serwerów
│   └── launcher-helper/        # Narzędzia pomocnicze
├── apps/
│   ├── launcher-cli/           # CLI (flow.rs = pełny cykl)
│   └── launcher-tauri/         # GUI (commands.rs, ui/app.js)
├── docs/contracts/             # Dokumentacja kontraktów API
└── launcher_config.json        # Konfiguracja (apiBaseUrl, channel, clientDir)
```

---

## 16. Diagramy Przepływów

### 16.1 Logowanie przez RedDAXE → gra na Tibia WWW

```
[Użytkownik]
     │
     ▼
[GET /reddaxe/account-login.php]
     │ Formularz: email + hasło
     ▼
[POST /reddaxe/account-login.php]
     │
     ├──► [POST /apik/v1/launcher-token.php] → launch token
     ├──► [POST /apik/v1/login.php] → session key
     ├──► [POST /apik/v1/account-context.php] → account info
     │
     ├── Ustaw $_SESSION['account'] (RedDAXE)
     ├── Ustaw $_SESSION['myaac_*'] (Cross-site sync)
     │
     ▼
[302 → /reddaxe/post-login.php lub /?subtopic=accountmanagement]
     │
     ▼
[Tibia WWW: system/login.php waliduje myaac_* klucze]
     │ ✓ $_SESSION['myaac_password'] == DB hash
     │ ✓ $_SESSION['myaac_last_visit'] w ciągu 15 min
     ▼
[Zalogowany na obu serwisach]
```

### 16.2 Tibia WWW redirect → RedDAXE → powrót

```
[Użytkownik odwiedza /?subtopic=accountmanagement]
     │
     ▼
[system/pages/account/base.php]
     │ $logged == false
     ▼
[302 → /reddaxe/account-login.php?source=tibiawww]
     │
     ▼
[Logowanie RedDAXE (jak wyżej)]
     │ $source = 'tibiawww'
     │ $redirectPath = '/?subtopic=accountmanagement'
     ▼
[302 → /?subtopic=accountmanagement]
     │
     ▼
[Zalogowany! Widzi zarządzanie kontem na Tibia WWW]
```

### 16.3 Launcher → Instalka → Serwer Gry (PEŁNY ŁAŃCUCH)

```
[LAUNCHER (Rust/Tauri)]
     │
     ├── 1. GET /apik/v1/update.php → sprawdź aktualizacje klienta
     ├── 2. Oblicz SHA256 plików klienta (filesHash)
     ├── 3. Zsynchronizuj listę serwerów → init_serverlist.lua
     │
     ├── 4. POST /apik/v1/launcher-token.php
     │      → { launcherVersion, filesHash, channel }
     │      ← { token: "abc123...", expiresInSeconds: 300 }
     │
     └── 5. Spawn: otclient
            env: OTC_LAUNCH_TOKEN="abc123..."
            env: OTC_CHANNEL="stable"
            (launcher oddaje kontrolę — fire-and-forget)
            │
            ▼
[INSTALKA (OTClient)]
     │
     ├── 6. Odczytaj OTC_LAUNCH_TOKEN z env
     ├── 7. Pokaż ekran logowania (email + hasło)
     │
     ├── 8. POST /apik/v1/login.php
     │      → { email, password, gameMode: "all", launchToken: "abc123..." }
     │      ← { session: { sessionkey: "xyz789..." },
     │           playdata: { worlds: [...], characters: [...] } }
     │      ⚠ launch token zostaje SKONSUMOWANY (usunięty z DB)
     │
     ├── 9. Wyświetl listę postaci
     │      Gracz wybiera: tryb (classic/modern) → serwer → postać
     │
     ├── 10. POST /apik/v1/ticket.php
     │       → { type: "ticket", sessionKey: "xyz789...",
     │            characterName: "Testowy", gameMode: "classic74",
     │            worldName: "Classic 7.4" }
     │       ← { ticket: "base64payload.hmachex", expiresAt: +30s }
     │
     └── 11. Połączenie TCP z serwerem gry
             → Przesyła HMAC ticket
             │
             ▼
[SERWER GRY (Canary C++)]
     │
     ├── 12. ticket_validator.cpp:
     │       → Weryfikuj HMAC (wspólny ticketSecret z config.lua)
     │       → Sprawdź nonce (anti-replay), iat, expiresAt
     │       → Sprawdź worldId, accountId, characterName
     │
     └── 13. ✓ Akceptuj → załaduj postać → GRA!
```

### 16.4 Synchronizacja WWW → Launcher

```
[Zalogowany na stronie WWW]
     │
     ▼
[/reddaxe/post-login.php → Klik "Sync to Launcher"]
     │
     ├── JS fetch → POST /apik/v1/account-sync-www-token.php
     │              → { type: "account_sync_www_token", target: "launcher" }
     │              ← { syncToken: "tok123...", launcherDeepLink: "launcher://..." }
     │
     ├── Wyświetl deep link
     │
     ▼
[Użytkownik klika deep link → Launcher otwiera się]
     │
     ├── Launcher → POST /apik/v1/account-sync-consume.php
     │              → { type: "account_sync_consume", syncToken: "tok123..." }
     │              ← { sessionKey: "new456...", account: {...}, characters: {...} }
     │
     ▼
[Launcher zalogowany bez wpisywania hasła!]
```

### 16.5 Wylogowanie (Kompletne)

```
[Logout z RedDAXE]                     [Logout z MyAAC]
/reddaxe/logout.php                    /system/logout.php
     │                                      │
     ├── unset account (RedDAXE)            ├── unsetSession (MyAAC keys)
     ├── unset login_timeout                ├── unset account (RedDAXE keys)
     ├── unset myaac_* (MyAAC keys)         ├── unset login_timeout
     │                                      │
     ▼                                      ▼
[Wylogowany z OBU serwisów]            [Wylogowany z OBU serwisów]
```

### 16.6 Trzy Bariery Bezpieczeństwa (Launcher → Instalka → Serwer)

```
┌──────────────────────────────────────────────────────────┐
│ BARIERA 1: LAUNCHER (miękka)                             │
│ ─ Sprawdza integralność plików klienta (filesHash)       │
│ ─ Sprawdza wersję launchera (>= LAUNCHER_MIN_VERSION)    │
│ ─ Wydaje launch token (jednorazowy, IP-bound, 5 min)     │
│ ─ Cel: nie pozwól na uruchomienie zmodyfikowanego klienta│
└─────────────────────────┬────────────────────────────────┘
                          │ OTC_LAUNCH_TOKEN (env)
                          ▼
┌──────────────────────────────────────────────────────────┐
│ BARIERA 2: API login.php (średnia)                       │
│ ─ Wymaga email + hasło + launch token                    │
│ ─ Launch token konsumowany atomicznie (SELECT FOR UPDATE)│
│ ─ IP musi pasować do IP z launch tokenu                  │
│ ─ Rate limited (10/min email, 30/min IP)                 │
│ ─ Wydaje sessionKey (30 min TTL)                         │
│ ─ Cel: autoryzacja użytkownika                           │
└─────────────────────────┬────────────────────────────────┘
                          │ sessionKey
                          ▼
┌──────────────────────────────────────────────────────────┐
│ BARIERA 3: TICKET GATE (twarda)                          │
│ ─ ticket.php generuje HMAC-SHA256 ticket (30s TTL)       │
│ ─ Canary ticket_validator.cpp weryfikuje podpis           │
│ ─ Wspólny TICKET_SECRET (API) == ticketSecret (config.lua)│
│ ─ Nonce jednorazowy (anti-replay)                        │
│ ─ Payload: accountId, character, world, gameMode         │
│ ─ Cel: kryptograficzna gwarancja autentyczności          │
└──────────────────────────────────────────────────────────┘
```

---

## Podsumowanie Zmian Wprowadzonych

| Data | Zmiana | Pliki |
|------|--------|-------|
| 2026-03 | Zarządzanie kontem RedDAXE: zmiana nazwy wyświetlanej | `apik/v1/change-account-name.php`, `reddaxe/account-manage.php` |
| 2026-03 | Zarządzanie kontem RedDAXE: zmiana nazwy postaci | `apik/v1/change-character-name.php`, `reddaxe/account-manage.php` |
| 2026-03 | Rozbudowa account-manage: 4 zakładki (przegląd, hasło, nazwa, postacie) | `reddaxe/account-manage.php`, `reddaxe/i18n/pl.php`, `reddaxe/i18n/en.php` |
| 2026-03 | Front door: "Zarządzaj kontem" → RedDAXE zamiast MyAAC | `reddaxe/index.php` |
| Sesja obecna | Branding: "RedDaxe.pl" w tytule przeglądarki | `system/init.php` |
| Sesja obecna | Rozdzielenie listy postaci per serwer | `system/pages/characters.php`, `system/templates/characters.html.twig` |
| Sesja obecna | Redirect Tibia WWW → RedDAXE przy braku logowania | `system/pages/account/base.php` |
| Sesja obecna | Cross-site sync MyAAC → RedDAXE | `system/pages/account/login.php` |
| Sesja obecna | Powrót na Tibia po logowaniu (source=tibiawww) | `reddaxe/account-login.php` |
| Wcześniej | Cross-site sync RedDAXE → MyAAC | `reddaxe/account-login.php` |
| Wcześniej | Dual-site logout | `reddaxe/logout.php`, `system/logout.php` |
| Wcześniej | Współdzielona sesja PHP | `reddaxe/bootstrap.php` |
| Wcześniej | DB hash fetch zamiast re-hashing | `reddaxe/bootstrap.php` (reddaxe_fetch_myaac_password_hash) |
| Wcześniej | API: login, launcher-token, registration, sync | `apik/v1/` (cały katalog) |
| Wcześniej | Launcher Rust (CLI + Tauri) | `launcher-rust/` |

---

## Zmienne Środowiskowe (`.env`)

### Bazy Danych
| Zmienna | Domyślnie | Opis |
|---------|-----------|------|
| `DB_HOST` | - | Fallback host |
| `DB_NAME` | - | Fallback nazwa bazy |
| `DB_USER` | - | Fallback użytkownik |
| `DB_PASS` | - | Fallback hasło |
| `DB_PORT` | 3306 | Fallback port |
| `GLOBAL_DB_*` | = DB_* | Baza globalna (accounts) |
| `API_DB_*` | = GLOBAL_DB_* | Baza operacyjna API |
| `ENGINE_DB_*` | = DB_* | Classic 7.4 |
| `ENGINE_MODERN_DB_*` | = DB_* | Modern |

### Sesje i Tokeny
| Zmienna | Domyślnie | Opis |
|---------|-----------|------|
| `SESSION_TTL` | 1800 | Czas życia sesji API (30 min) |
| `LAUNCH_TOKEN_TTL` | 300 | Czas życia launch token (5 min) |
| `TICKET_SECRET` | - | **WYMAGANY** — wspólny sekret HMAC (== ticketSecret w config.lua) |
| `TICKET_TTL` | 30 | Czas życia HMAC ticket (30 s) |
| `ACCOUNT_SYNC_TOKEN_TTL` | 120 | Czas życia sync token (2 min) |
| `LAUNCHER_MIN_VERSION` | 1.0.0 | Minimalna wersja launchera |
| `LAUNCHER_VERSION` | 1.0.0 | Aktualna wersja launchera (config) |

### Bezpieczeństwo
| Zmienna | Domyślnie | Opis |
|---------|-----------|------|
| `CLIENT_LOCKED` | false | Wymagaj launch token przy logowaniu |
| `CHALLENGE_REQUIRED` | false | Wymagaj challenge-response |
| `TRUSTED_PROXIES` | - | CSV zaufanych proxy IPs |
| `LOG_IP_SALT` | - | Sól do hashowania IP w logach |

### Rate Limiting
| Zmienna | Domyślnie | Opis |
|---------|-----------|------|
| `LAUNCH_TOKEN_RATE_LIMIT` | 5 | Tokeny/min per IP |
| `ACCOUNT_SYNC_WWW_OPEN_TOKENS_MAX` | 3 | Max otwartych sync tokenów per konto |

### RedDAXE
| Zmienna | Domyślnie | Opis |
|---------|-----------|------|
| `REDDAXE_BRAND` | RedDAXE.pl | Nazwa serwisu |
| `REDDAXE_LOGIN_URL` | - | Ścieżka logowania |
| `REDDAXE_CREATE_URL` | - | Ścieżka rejestracji |
| `REDDAXE_DOWNLOAD_PAGE_URL` | - | Strona pobierania klienta |
| `REDDAXE_ALLOWED_HOSTS` | - | Dozwolone hosty redirect |
