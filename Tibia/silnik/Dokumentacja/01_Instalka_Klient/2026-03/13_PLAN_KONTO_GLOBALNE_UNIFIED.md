# Plan: Konto Globalne — Unified Account System
**Data planu:** 2026-03-06  
**Realizacja:** 2026-03-07  
**Priorytet:** P0 — fundament całego systemu

---

## Koncepcja

```
                    ┌─────────────────────────┐
                    │   canaryaac.accounts     │
                    │   (MASTER / źródło       │
                    │    prawdy)               │
                    └───────┬────────┬─────────┘
                 trigger    │        │    trigger
              ┌─────────────┘        └─────────────┐
              ▼                                     ▼
     ┌────────────────┐                   ┌────────────────┐
     │ canary.accounts │                   │ canary_modern  │
     │ (engine 7.4)    │                   │ .accounts      │
     └────────────────┘                   │ (engine modern)│
                                          └────────────────┘

  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
  │ Launcher │   │ RedDAXE  │   │ WWW Tibia│   │ Klient   │
  │ (Tauri)  │   │ (portal) │   │ (AAC)    │   │ (OTClient│
  └────┬─────┘   └────┬─────┘   └────┬─────┘   └────┬─────┘
       │               │               │               │
       └───────────────┴───────┬───────┴───────────────┘
                               │
                    ┌──────────▼──────────┐
                    │    API /apik/v1/    │
                    │  (jedno źródło)     │
                    └─────────────────────┘
```

**Zasada:** Jedno konto globalne → osobne postacie per serwer.
- Rejestracja w DOWOLNYM miejscu (launcher / RedDAXE / WWW) → konto w canaryaac
- Logowanie w DOWOLNYM miejscu → sesja + dostęp do 2 serwerów
- Postacie tworzone na WWW → każda przypisana do konkretnego serwera (world_id)

---

## Ścieżki użytkownika (User Flows)

### Flow 1: Nowy gracz z Launchera
```
1. Gracz pobiera ZIP z launcherem
2. Uruchamia launcher.exe
3. Ekran: "Nie masz konta? Zarejestruj się"
4. → Klik "Rejestracja" → otwarcie okna w launcherze (lub przeglądarce → RedDAXE)
5. Wypełnia: email, hasło, (opcjonalnie: nazwa konta)
6. API: POST /apik/v1/register-account.php → konto w canaryaac
7. Triggery syncują do canary + canary_modern
8. → Powrót do launchera → auto-login
9. Ekran: "Nie masz postaci. Utwórz postać na: [Classic 7.4] [Modern]"
10. → Klik → otwiera WWW z auto-login tokenem (/account/characters/create?mode=classic74&token=...)
11. Gracz tworzy postać na WWW
12. → Powrót/callback → launcher odświeża account-context
13. → Widzi postać → klik "GRAJ" → ticket → start klienta
```

### Flow 2: Gracz rejestruje się przez RedDAXE
```
1. Gracz wchodzi na stronę RedDAXE
2. Klik "Utwórz konto"
3. Formularz: email, hasło
4. API: POST /apik/v1/register-account.php → konto w canaryaac
5. Redirectuje do post-login.php → CTA: "Pobierz launcher" / "Przejdź do WWW"
6. Jeśli pobiera launcher → uruchamia → loguje się tym samym kontem → działa
7. Jeśli WWW → auto-login → tworzy postać → gotowe
```

### Flow 3: Gracz rejestruje się przez WWW Tibia
```
1. Gracz wchodzi na stronę Tibia (CanaryAAC)
2. Klik "Utwórz konto" (/account/create)
3. Formularz MyAAC → INSERT INTO canaryaac.accounts
4. Auto-login → account management → "Utwórz postać" z wyborem serwera
5. Pobiera launcher z sekcji Downloads
6. Loguje się w launcherze tym samym kontem → widzi postać → gra
```

### Flow 4: Przejście launcher → WWW (SSO)
```
1. Gracz zalogowany w launcherze
2. Klik "Moje konto" / "Utwórz postać" / "Pokaż highscores"
3. Launcher generuje: POST /apik/v1/account-sync-www-token.php → otrzymuje one-time token
4. Launcher otwiera przeglądarkę: https://twojserwer.pl/account/sync-login?token=XYZ
5. WWW: GET → POST /apik/v1/account-sync-www-login.php → waliduje token → ustawia sesję PHP
6. Gracz jest zalogowany na WWW bez wpisywania hasła
7. Po akcji (np. stworzeniu postaci) → zamyka przeglądarkę lub wraca do launchera
```

### Flow 5: Przejście WWW → Launcher (nie trzeba ponownie logować)
```
1. Gracz zalogowany na WWW
2. Pobiera launcher / już ma launcher
3. Launcher ma zapisane credentials (zaszyfrowane lokalnie)
4. Launcher: auto-login przy starcie → POST /apik/v1/login.php → sessionKey
5. Jeśli credentials wygasły → "Zaloguj się ponownie" (raz)
6. Po zalogowaniu → launcher zapamiętuje → następnym razem auto
```

---

## Zadania

### ACC-01 (P0): Weryfikacja flow rejestracji API
**Plik:** `/var/www/html/apik/v1/register-account.php`
- Test: POST z { email, password, name? }
- Oczekiwanie: INSERT canaryaac.accounts + triggery → sync do canary + canary_modern
- Weryfikacja: `SELECT * FROM canary.accounts ORDER BY id DESC LIMIT 1` po rejestracji

### ACC-02 (P0): Weryfikacja `engine_password_sha1` przy rejestracji
**Problem:** canaryaac używa Argon2, canary/canary_modern używają SHA1
**Plik:** `/var/www/html/apik/v1/register-account.php` lub `/var/www/html/system/` (rejestracja MyAAC)
- Przy tworzeniu konta: `canaryaac.accounts.password` = Argon2 hash
- JEDNOCZEŚNIE: `canaryaac.accounts.engine_password_sha1` = SHA1(password) 
- Trigger mapuje: `canary.accounts.password = COALESCE(NEW.engine_password_sha1, '0')`
- **Test:** Zarejestruj konto → sprawdź czy `engine_password_sha1` nie jest NULL

### ACC-03 (P0): API account-sync-www-token.php — flow SSO
**Plik:** `/var/www/html/apik/v1/account-sync-www-token.php`
- Input: sessionKey (z launchera)
- Output: `{ "token": "XYZ", "expires": 1234567890, "redirectUrl": "..." }`
- Token: jednorazowy, TTL=300s, powiązany z accountId

### ACC-04 (P0): API account-sync-www-login.php — konsumpcja tokenu
**Plik:** `/var/www/html/apik/v1/account-sync-www-login.php`
- Input: `{ "token": "XYZ" }`
- Walidacja: token istnieje, nie expired, nie consumed
- Output: ustawia sesję PHP (dla MyAAC) + redirect do /account/manage
- Zabezpieczenie: oznacz token jako consumed po użyciu

### ACC-05 (P0): WWW — endpoint do odbioru sync tokenu
**Plik:** Potrzebny nowy plik lub hook w MyAAC:  
`/var/www/html/system/pages/account/sync-login.php`
```php
<?php
// Odbiera token z URL, waliduje przez API, ustawia sesję MyAAC
$token = $_GET['token'] ?? '';
if (!$token) { redirect('/'); }

// Waliduj przez API
$response = apiCall('account-sync-www-login.php', ['token' => $token]);
if ($response['success']) {
    // Ustaw sesję MyAAC
    $_SESSION['account_id'] = $response['accountId'];
    $_SESSION['logged'] = true;
    redirect('/account/manage');
} else {
    redirect('/?error=invalid_sync_token');
}
```

### ACC-06 (P0): Launcher — przechowywanie credentials
**Plik:** `launcher-rust/crates/launcher-core/src/state.rs`
- Po loginie: zapisać `sessionKey` + `accountId` + timestamp
- Przy starcie: sprawdzić czy sesja ważna → auto-login
- Jeśli expired → próba refresh → jeśli fail → ekran logowania
- **Bezpieczeństwo:** Credentials zaszyfrowane (platform keyring lub AES z machine ID)

### ACC-07 (P1): Tworzenie postaci — wybór serwera
**Plik:** `/var/www/html/system/pages/account/characters/create.php`
- Dodać select/radio: "Serwer: [Classic 7.4] [Modern]"
- Walidacja: wybrany serwer → ustawić `world_id` w canaryaac.players
- Routing: INSERT do odpowiedniej engine DB (canary lub canary_modern)
- Jeśli przyszedł z launchera z parametrem `?mode=classic74` → pre-select

### ACC-08 (P1): RedDAXE — rejestracja → to samo API
**Plik:** `/var/www/html/reddaxe/account-create.php`
- Sprawdzić: czy korzysta z `/apik/v1/register-account.php`
- Jeśli bezpośrednio INSERT do DB → refactorować na API call
- Po rejestracji: CTA "Pobierz Launcher" + "Przejdź do strony"

### ACC-09 (P1): RedDAXE — login → to samo API
**Plik:** `/var/www/html/reddaxe/account-login.php`
- Sprawdzić: czy korzysta z `/apik/v1/login.php`
- Dopo loginu: redirect do `post-login.php` z kontekstem konta

### ACC-10 (P1): WWW Account Management — postacie per serwer
**Plik:** `/var/www/html/templates/tibiacom/account.management.html.twig`
- Wyświetlać postacie pogrupowane:
```
Classic 7.4:
  - GOD (Level 1)
  - Knight Test (Level 8)
Modern:
  - Ptaku Modern (Level 8)
[Utwórz postać Classic] [Utwórz postać Modern]
```

### ACC-11 (P1): Blokada tworzenia postaci bez wyboru serwera
- Jeśli `mode=all` i użytkownik nie wybrał serwera → komunikat
- Jeśli `mode=classic74` → auto-set world_id=0
- Jeśli `mode=modern` → auto-set world_id=1

### ACC-12 (P2): FAQ — "Jak działa konto globalne?"
**Plik:** Nowa strona w MyAAC lub statyczny HTML
```
P: Czy mam jedno konto na oba serwery?
O: Tak! Jedno konto globalne, ale postacie są osobne per serwer.

P: Jak utworzyć postać na drugim serwerze?
O: Wejdź w Account Management → Utwórz postać → Wybierz serwer.

P: Czy mogę przenieść postać między serwerami?
O: Nie, postacie są przypisane do serwera na stałe.
```

---

## Tabela: Gdzie logowanie/rejestracja się odbywa

| Frontend | Rejestracja | Login | Tworzy postać | Auto-login z launchera |
|---|---|---|---|---|
| Launcher | API register-account.php | API login.php | NIE (redirect do WWW) | N/A (sam jest źródłem) |
| RedDAXE | API register-account.php | API login.php | NIE (redirect do WWW) | Tak (sync token) |
| WWW Tibia | MyAAC form → DB | MyAAC form → DB | TAK (/account/characters/create) | Tak (sync token) |
| Klient OTC | NIE | Ticket (z launchera) | NIE | N/A (ticket-gate) |

---

## Matryca testów kont

| # | Test | Oczekiwany wynik | Status |
|---|---|---|---|
| T-ACC-01 | Rejestracja z launchera | Konto w canaryaac + sync do obu engine DB | ✅ PASS (2026-03-07) — account id=35, sync OK |
| T-ACC-02 | Rejestracja z RedDAXE | Konto w canaryaac + sync | ✅ PASS (2026-03-06) |
| T-ACC-03 | Rejestracja z WWW | Konto w canaryaac + sync | ✅ PASS (2026-03-07) — SHA1 + engine_password_sha1 set |
| T-ACC-04 | Login launcher → context z postaciami | Postacie per world_id | ✅ PASS (2026-03-06) |
| T-ACC-05 | Launcher → WWW (sync token) | Auto-login na WWW bez hasła | ✅ PASS (2026-03-07) — SSO E2E: PHPSESSID + myaac_ prefix |
| T-ACC-06 | Tworzenie postaci Classic z WWW | W canaryaac + canary.players | ✅ PASS (2026-03-07) — Test Klasyk, world=0 |
| T-ACC-07 | Tworzenie postaci Modern z WWW | W canaryaac + canary_modern.players | ✅ PASS (2026-03-07) — Test Modernowy, world=1 |
| T-ACC-08 | Login WWW → widok postaci per serwer | Pogrupowane Classic/Modern | ✅ PASS (2026-03-07) — manage.php grouping OK |
| T-ACC-09 | Zmiana hasła → sync do engine DB | SHA1 w canary + canary_modern updated | ✅ CODE DONE (2026-03-07) — change-password.php + lost.php set engine_password_sha1, runtime test pending |
| T-ACC-10 | engine_password_sha1 nie NULL po rejestracji | SHA1 hash obecny | ✅ PASS (2026-03-07) — API + MyAAC create.php both set it |
