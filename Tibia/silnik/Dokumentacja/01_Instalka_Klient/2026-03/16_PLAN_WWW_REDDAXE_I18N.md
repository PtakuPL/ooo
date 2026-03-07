# Plan: WWW Tibia (CanaryAAC) + RedDAXE Portal + i18n
**Data planu:** 2026-03-06  
**Realizacja:** 2026-03-07  
**Priorytet:** P0-P2

---

## Stan obecny (audyt 2026-03-06)

### WWW Tibia (CanaryAAC)
- **Silnik:** MyAAC (PHP, Twig templates)
- **Ścieżka:** `/var/www/html/`
- **Template:** `templates/tibiacom/`
- **i18n klient-side:** `resources/i18n/i18n.js` (200 linii), `pl.json` (970 kluczy)
- **i18n serwer-side:** `system/locale/pl/main.php` (268+ linii)
- **Nginx:** :443, sites-enabled: `127.local.conf`, `myaac.conf`

### Naprawione wczoraj (2026-03-05/06):
- ✅ `<div id="Loginbox">` wrapper dodany (div balance 282/282)
- ✅ CSS `#LoginBox` → `#Loginbox` case fix
- ✅ Destructive data-i18n na CaptionContainer usunięte
- ✅ 16 page titles przetłumaczone (__() calls)
- ✅ 5 system Twig templates: Password→Hasło, Account Login→Logowanie
- ✅ pl.json: 970 kluczy, wszystkie homepage keys zweryfikowane

### RedDAXE Portal
- **Ścieżka:** `/var/www/html/reddaxe/`
- **Pliki:** 6 PHP (account-create, account-login, bootstrap, go, index, post-login)
- **i18n:** Własny system `reddaxe_t()`, cookie-based lang

### Znane problemy:
1. ❌ Strona wygląda inaczej niż tibia.com reference (układ, kafelki)
2. ❌ News ticker może nie działać
3. ❌ Right sidebar (Webshop, Networks, Trailer) — brak lub widoczność
4. ❌ Niektóre strony dalej mają EN fallback text
5. ✅ Create character ma wybór serwera + persist `world/world_id` (fallback schema)
6. ❌ Highscores/online nie respektują dual-server
7. ❌ RedDAXE nie jest w pełni PL

---

## Aktualizacja statusu (2026-03-06 10:55)

### Zakończone
- `RDX-01`: `account-create.php` działa przez API (`/apik/v1/register-account.php`), bez bezpośredniego INSERT do DB.
- `RDX-02`: `account-login.php` działa przez API (`/apik/v1/login.php` + `/apik/v1/account-context.php`) i tworzy sesję WWW (`CanaryAAC`).
- `RDX-03`: `post-login.php` pokazuje konto + listę postaci per serwer (`classic74`/`modern`) + status sesji.
- `RDX-05`: CTA "Pobierz launcher" widoczne na `index.php` i po zalogowaniu (`post-login.php`).

### W trakcie
- `RDX-04`: i18n RedDAXE rozszerzone o nowe klucze login/post-login; pełny audyt mixed PL/EN nadal do domknięcia.

### Otwarte
- `WWW-01..WWW-13` bez zmian funkcjonalnych w tej paczce (poza RedDAXE i smoke testami API/session).

### Błędy wykryte i naprawione w tej paczce
- Kontrakt `launcher-token.php` zwracał `token`, a RedDAXE oczekiwał `launchToken`:
  - skutek: login RedDAXE kończył się błędem `Launch token required`.
  - naprawa: fallback na oba klucze (`launchToken` lub `token`) w `reddaxe/account-login.php`.
- Runtime HTTPS self-signed na localhost blokował połączenia curl z RedDAXE do API:
  - naprawa: warunkowe wyłączenie TLS verify tylko dla `https://127.0.0.1|localhost|::1`.

---

## Aktualizacja statusu (2026-03-06 11:05)

### Zakończone
- `WWW-03`: `account/manage` renderuje postacie w sekcjach `Classic 7.4` / `Modern` / `Unknown` + osobne przyciski create z `mode=classic74|modern`.
- `WWW-04`: naprawa login box (`#Loginbox` wrapper w `index.php` + korekta selektora CSS `#Loginbox #LoginButtonContainer`).
- `WWW-09`: strona `downloads` zaktualizowana do CTA launchera (`/files/launcher/launcher.exe`) + instrukcja i wymagania.

### W trakcie
- `WWW-01` / `WWW-11`: częściowy audyt i18n DOM; usunięto ryzykowne `data-i18n` z kontenerów `CaptionContainer` w `account.login.html.twig`.
- `WWW-02`: dodano wybór serwera (`mode`) w formularzu tworzenia postaci oraz próbę zapisu `world_id` po utworzeniu postaci (gdy kolumna istnieje).

### Otwarte / blokery
- `WWW-02`: na runtime `canaryaac.players` nie ma kolumny `world_id` (`HAS_WORLD=0`), więc persist trybu `modern/classic` jest obecnie blokowany przez schemat DB.
- `WWW-05..WWW-08`, `WWW-10`, `WWW-12`, `WWW-13` bez zmian w tej paczce.

---

## Aktualizacja statusu (2026-03-06 11:24)

### Zakończone
- `WWW-05`: wdrożona strona `/account/sync-login` (nowy plik `system/pages/account/sync-login.php`) z:
  - walidacją i jednorazową konsumpcją `syncToken` z `account_sync_tokens`,
  - ustawieniem sesji MyAAC (`setSession('account')`, `setSession('password')`),
  - bezpiecznym `redirect` i fallbackiem błędów do `/account/login?...&sync_error=...`.
- `WWW-02`: domknięty fallback zapisu serwera postaci:
  - jeśli istnieje `players.world_id` → zapis przez `setWorldId(...)`,
  - jeśli istnieje `players.world` → SQL update `players.world = ...`.
  - smoke PASS: utworzenie postaci w `mode=modern` zapisało `world=1`.

### W trakcie
- `WWW-01` / `WWW-11`: dalszy audyt i18n (hardcoded EN + bezpieczne `data-i18n` na kontenerach).

---

## Aktualizacja statusu (2026-03-06 11:35)

### Zakończone
- `WWW-06`: highscores dual-server działa w 3 opcjach serwera:
  - `mode=all`
  - `mode=classic74`
  - `mode=modern`
- Dodana nowa kategoria topki: `onlinetime` (czas online), dostępna dla wszystkich 3 trybów.
- Ranking `mode=all` został doprecyzowany pod paginację (merge topów z obu serwerów na podstawie `offset+limit`, zamiast stałego limitu).
- W tabeli rankingów dodana kolumna `Świat/World`, aby było widać źródło wyniku (`Classic 7.4` / `Modern`).

### Testy smoke
- `GET /highscores/onlinetime?mode=all` -> `200`, widoczna kategoria czasu online + kolumna świata.
- `GET /highscores/onlinetime?mode=classic74` -> `200`.
- `GET /highscores/onlinetime?mode=modern` -> `200`.
- `GET /highscores/experience?mode=all` -> `200`, bez regresji widoku.

### Błędy wykryte i naprawione
- `WWW-05`:
  - błąd architektury sesji: sam endpoint API `account-sync-www-login.php` nie ustawiał natywnej sesji MyAAC (`account` + `password` z prefixem), więc panel konta mógł nie widzieć loginu.
  - naprawa: `account/sync-login` ustawia pełną sesję MyAAC po poprawnej walidacji tokenu.
- `WWW-02`:
  - wcześniejsze założenie „bloker: brak `world_id`” było niepełne dla runtime schema.
  - naprawa: fallback `world`/`world_id` + test E2E.

### Testy smoke (runtime `/var/www/html`)
- `/account/sync-login?syncToken=...&redirect=/account/manage` → `302` do `/account/manage`, następnie `/account/manage` = zalogowany użytkownik.
- Reużycie tego samego tokenu w nowej sesji → `302` do `/account/login?...&sync_error=sync_token_already_used`.
- `POST /apik/v1/account-sync-token.php` zwraca `consumeUrl` wskazujący nowy endpoint: `/account/sync-login?syncToken=...`.

---

## Aktualizacja statusu (2026-03-06 11:52)

### Zakończone
- `WWW-07`: lista online dual-server wdrożona na runtime (`/var/www/html`) z 3 trybami:
  - `mode=all`
  - `mode=classic74`
  - `mode=modern`
- `online.php`: merge listy graczy online z obu baz (classic + modern), wspólne sortowanie i cache per `mode+order`.
- `online.html.twig`: dodany selector trybu serwera + podsumowanie online (`Classic 7.4`, `Modern`, `Total`) + kolumna `Świat/World`.
- Linki sortowania zachowują aktualny tryb dla `classic74/modern` (dla `all` brak parametru jest intencjonalny, bo to tryb domyślny).

### Testy smoke (runtime `/var/www/html`)
- `php -l /var/www/html/system/pages/online.php` -> `No syntax errors`.
- `GET /online?mode=all` -> `200`, selector trybu + podsumowanie + kolumna świata widoczne.
- `GET /online?mode=classic74` -> `200`, selector trybu + podsumowanie + kolumna świata widoczne.
- `GET /online?mode=modern` -> `200`, selector trybu + podsumowanie + kolumna świata widoczne.

### W trakcie
- `WWW-01` / `WWW-11`: dalszy audyt i18n stron i templatek.

### Otwarte
- `WWW-08`, `WWW-10`, `WWW-12`, `WWW-13`.

---

## Aktualizacja statusu (2026-03-06 11:56)

### Zakończone
- `WWW-08`: zapamiętywanie wyboru serwera w sesji (`server_mode`) wdrożone dla:
  - `/highscores`
  - `/online`
- Jeśli URL nie ma parametru `mode`, strona bierze ostatni wybór z sesji.
- Linki paginacji/sortowania/filterów generują teraz jawny `mode` również dla `mode=all` (eliminuje konflikt z poprzednim stanem sesji).

### Testy smoke (runtime `/var/www/html`)
- `php -l /var/www/html/system/pages/highscores.php` -> `No syntax errors`.
- `php -l /var/www/html/system/pages/online.php` -> `No syntax errors`.
- Test sesji (cookie jar) `online`: `?mode=modern` -> `/online` (bez `mode`) zachowuje `modern`; potem `?mode=all` -> `/online` zachowuje `all`.
- Test sesji (cookie jar) `highscores`: `?mode=classic74` -> `/highscores/experience` (bez `mode`) zachowuje `classic74`; potem `?mode=all` -> `/highscores/experience` zachowuje `all`.
- Re-test endpointów:
  - `/online?mode=all|classic74|modern` -> `200`
  - `/highscores/onlinetime?mode=all|classic74|modern` -> `200`

### W trakcie
- `WWW-01` / `WWW-11`: audyt i18n.

### Otwarte
- `WWW-10`, `WWW-12`, `WWW-13`.

---

## Aktualizacja statusu (2026-03-06 12:01)

### Zakończone
- `WWW-11` (część): domknięty i18n hardening dla widoków dual-server:
  - `/online`
  - `/highscores` (w tym `onlinetime`)
- Usunięte hardcoded teksty backend/Twig w tych ścieżkach:
  - rekord online (`player(s)`, `on DATE`) -> klucze locale
  - etykieta daty serwera i typy PvP -> klucze locale
  - alt outfitu gracza -> klucz locale
  - fallback profesji `Unknown` -> klucz locale
  - jednostki czasu online (`d/h/m`) -> klucze locale
- Dodane nowe klucze i18n do locale `pl` i `en`:
  - `online_record_players_count`
  - `online_record_on_date`
  - `online_server_datetime`
  - `online_pvp_open`
  - `online_pvp_optional`
  - `online_pvp_hardcore`
  - `vocation_unknown`
  - `highscores_time_days_short`
  - `highscores_time_hours_short`
  - `highscores_time_minutes_short`

### Testy smoke (runtime `/var/www/html`)
- `php -l`:
  - `/var/www/html/system/pages/highscores.php` -> OK
  - `/var/www/html/system/pages/online.php` -> OK
  - `/var/www/html/system/locale/pl/main.php` -> OK
  - `/var/www/html/system/locale/en/main.php` -> OK
- `GET /online?mode=all|classic74|modern` -> `200`
- `GET /highscores/onlinetime?mode=all|classic74|modern` -> `200`

### W trakcie
- `WWW-01` / `WWW-11`: dalszy audyt pozostałych templatek i stron poza `online/highscores`.

### Otwarte
- `WWW-10`, `WWW-12`, `WWW-13`.

---

## Aktualizacja statusu (2026-03-06 12:06)

### Zakończone
- `WWW-11` (kolejna część): i18n hardening dla templatek:
  - `templates/tibiacom/account.login.html.twig`
  - `templates/tibiacom/account.management.html.twig`
- Usunięte hardcoded user-visible teksty i podmienione na `__()` + klucze locale:
  - login title, password label, "remember me", "new player", tagline teksty
  - hint/note/sekcje konta (general/public/logs/characters)
  - nagłówki tabel (action/date/ip/name/world/level/status)
  - komunikaty listy postaci (`no characters found`, `[DELETED]`, `online/offline`, `edit`)
- Rozszerzone locale `pl/en` o klucze dla powyższych widoków (spójność server-side i18n).

### Testy smoke (runtime `/var/www/html`)
- `php -l /var/www/html/system/locale/pl/main.php` -> `OK`
- `php -l /var/www/html/system/locale/en/main.php` -> `OK`
- `GET /account/login` -> `200`
- Repo scan: brak starych hardcoded EN stringów w patched plikach (`account.login`/`account.management`) dla wzorców z audytu.

### W trakcie
- `WWW-01` / `WWW-11`: dalszy audyt pozostałych podstron i komponentów.

### Otwarte
- `WWW-10`, `WWW-12`, `WWW-13`.

---

## Zadania WWW (CanaryAAC)

### WWW-01 (P0): Audit i18n pozostałych stron ✅ (2026-03-07)
**Cel:** Przejrzeć każdą stronę i znaleźć hardcoded EN text
**Strony do sprawdzenia:**
```
/                           → Strona główna (news)
/account/manage             → Account management
/account/create             → Rejestracja
/account/characters/create  → Tworzenie postaci
/characters                 → Wyszukiwanie postaci
/online                     → Lista online
/highscores                 → Topki
/downloads                  → Pobieranie
/community                  → Społeczność
/guilds                     → Gildie
/shop                       → Sklep
/rules                      → Zasady
```
**Metoda:** Dla każdej strony:
1. `curl -sk https://127.0.0.1/STRONA | grep -i 'data-i18n'` → sprawdzić klucze
2. Sprawdzić widok w przeglądarce → szukać EN tekstu
3. Brakujące tłumaczenia → dodać do `pl.json`

### WWW-02 (P0): Tworzenie postaci z wyborem serwera ✅
**Plik:** `/var/www/html/system/pages/account/characters/create.php`
- Dodać radio/select: "Serwer: ○ Classic 7.4  ○ Modern"
- Ustawić `world_id`/`world` w `canaryaac.players` (fallback schema)
- Routing INSERT do odpowiedniej engine DB

### WWW-03 (P0): Account Management — postacie per serwer ✅
**Plik:** `/var/www/html/templates/tibiacom/account.management.html.twig`
- Wyświetlić postacie pogrupowane per serwer
- Osobne sekcje: "Postacie Classic 7.4" i "Postacie Modern"
- Przycisk "Utwórz postać" per serwer

### WWW-04 (P0): Naprawić Login Box na stronie głównej ✅
**Plik:** `templates/tibiacom/index.php` + `basic.css`
- Loginbox wrapper dodany ✅, ale wizualnie trzeba sprawdzić:
  - Czy input fields widoczne?
  - Czy przycisk "Login" działa?
  - Czy "Create Account" link widoczny?
  - Czy na mobile nie overflowuje?

### WWW-05 (P0): Strona sync-login dla SSO z launchera ✅
**Plik:** NOWY → `/var/www/html/system/pages/account/sync-login.php`
- URL: `/account/sync-login?token=XYZ`
- Waliduje token przez API
- Ustawia sesję MyAAC
- Redirect do `/account/manage`
(Szczegóły w 13_PLAN_KONTO_GLOBALNE_UNIFIED.md → ACC-05)

### WWW-06 (P1): Highscores — dual-server ✅
**Plik:** `/var/www/html/system/pages/highscores.php` (lub odpowiednik)
- Parametr `?server=all|classic74|modern`
- `all` → merge z obu baz, oznaczać serwer
- `classic74` → query canary.players
- `modern` → query canary_modern.players
- Tabs: [All] [Classic 7.4] [Modern]
- Dodatkowo: kategoria `onlinetime` (czas online) działa w tych 3 trybach.

### WWW-07 (P1): Lista online — dual-server ✅
**Plik:** `/var/www/html/system/pages/online.php` (lub odpowiednik)
- Jak highscores — tabs per serwer
- Query per engine DB
- Podsumowanie: "Classic 7.4: 5 online | Modern: 3 online | Total: 8"

### WWW-08 (P1): Server selector persistence w sesji ✅
**Plik:** `/var/www/html/system/` (hook w MyAAC)
- Po wybraniu serwera (np. w highscores) → zapisać w sesji
- `$_SESSION['server_mode'] = 'classic74'`
- Następne strony pamiętają wybór
- Dropdown/toggle w nawigacji: [Classic 7.4 ▼]

### WWW-09 (P1): Downloads — link do paczki/launchera ✅
**Plik:** `/var/www/html/system/pages/downloads.php` (lub strona w DB myaac_pages)
- CTA: "Pobierz Launcher" → link do ZIP z launcherem
- Informacja o wymaganiach: Windows 10/11, WebView2
- Instrukcja: Rozpakuj → Uruchom launcher.exe → Gotowe

### WWW-10 (P1): Zasady (Rules) — per serwer ✅ (2026-03-07)
**Pliki:** myaac_pages w DB
- ✅ Strona Rules dla Classic 7.4 — `rules_classic74` (id=5) wstawiona do DB
- ✅ Strona Rules dla Modern — `rules_modern` (id=7) wstawiona do DB
- ✅ Strona Rules ogólne — `rules` (id=4) przetłumaczona na PL
- Smoke test 3 trybów PASS

### WWW-11 (P1): Reszta data-i18n — przejrzeć wszystkie Twig templates ✅ (2026-03-07)
**Pliki do audytu:**
```bash
grep -rl 'data-i18n' /var/www/html/templates/tibiacom/*.twig | sort
```
Dla każdego template:
1. Sprawdzić czy klucze istnieją w pl.json
2. Sprawdzić czy data-i18n NIE jest na container divach (bug CaptionContainer)
3. Poprawić brakujące

### WWW-12 (P2): News system — tłumaczenie
- News tickers na stronie głównej
- Czy news wyświetla się po polsku?
- Czy admin panel news obsługuje PL?

### WWW-13 (P2): Clipping test DPI 100/125/150%
- Otworzyć stronę w Chrome z DPI 100%, 125%, 150%
- Sprawdzić: login box, menu, content area, right sidebar
- Raportować problemy z overflow

---

## Zadania RedDAXE Portal

### RDX-01 (P0): Rejestracja → przez API (nie bezpośrednio DB) ✅
**Plik:** `/var/www/html/reddaxe/account-create.php`
- Sprawdzić: czy korzysta z `/apik/v1/register-account.php`?
- Jeśli bezpośredni INSERT → refactorować na API call
- Musi tworzyć konto w canaryaac (master) → triggery syncują

### RDX-02 (P0): Login → przez API ✅
**Plik:** `/var/www/html/reddaxe/account-login.php`
- Sprawdzić: czy korzysta z `/apik/v1/login.php`?
- Po loginie: zapisać sesję, redirect do dashboard

### RDX-03 (P1): Post-login dashboard ✅
**Plik:** `/var/www/html/reddaxe/post-login.php`
- Wyświetlić:
  - Witaj, [nazwa konta]!
  - Twoje postacie: [lista per serwer]
  - CTA: [Pobierz Launcher] [Przejdź do WWW] [Utwórz postać]

### RDX-04 (P1): i18n RedDAXE — pełne PL 🔄
**Plik:** `/var/www/html/reddaxe/bootstrap.php` (system tłumaczeń)
- Sprawdzić wszystkie klucze `reddaxe_t()`
- Upewnić się że PL jest kompletne
- Przetłumaczyć brakujące

### RDX-05 (P1): CTA "Pobierz Launcher" ✅
**Plik:** `/var/www/html/reddaxe/index.php`
- Widoczny przycisk "Pobierz Launcher" na stronie głównej RedDAXE
- Link: do ZIP z launcherem

### RDX-06 (P2): Spójność wizualna RedDAXE ↔ WWW
- Logo, kolory, fonty — spójne
- Linki między RedDAXE ↔ WWW działają
- Brak mixed PL/EN na żadnej stronie

---

## Zadania i18n (globalne)

### I18N-01 (P1): Audyt pl.json — kompletność ✅ (2026-03-07) — 72 nowe klucze, total 1042
```bash
# Znaleźć wszystkie data-i18n klucze w HTML/Twig:
grep -roh 'data-i18n="[^"]*"' /var/www/html/templates/tibiacom/ | \
  sed 's/data-i18n="//;s/"//' | sort -u > /tmp/html_keys.txt

# Sprawdzić które brakują w pl.json:
python3 -c "
import json
with open('/var/www/html/resources/i18n/pl.json') as f:
    pljson = json.load(f)
with open('/tmp/html_keys.txt') as f:
    html_keys = [l.strip().split('.')[-1] if '.' in l.strip() else l.strip() for l in f if l.strip()]
# Klucze które mogą zaczynać się od 'text.' lub 'attr.' prefix:
for key in open('/tmp/html_keys.txt'):
    key = key.strip()
    base = key.split('.', 1)[1] if '.' in key else key
    if base not in pljson and key not in pljson:
        print(f'BRAK: {key}')
"
```

### I18N-02 (P1): Weryfikacja że i18n.js nie łamie DOM ✅ (2026-03-07) — 99 instancji sprawdzonych, 0 niebezpiecznych
**Sprawdzić:** Że żaden `data-i18n` nie jest na divie z dziećmi (jak był na CaptionContainer)
```bash
# Znaleźć data-i18n na DIV-ach (potencjalnie niebezpieczne):
grep -n 'data-i18n' /var/www/html/templates/tibiacom/*.twig | grep -i '<div'
grep -n 'data-i18n' /var/www/html/templates/tibiacom/*.php | grep -i '<div'
```

### I18N-03 (P1): Locale PHP — brakujące klucze
**Plik:** `/var/www/html/system/locale/pl/main.php`
- Sprawdzić każde użycie `__()` w PHP
- Czy klucz istnieje w main.php?
```bash
grep -roh "__('[^']*')" /var/www/html/system/pages/ | sort -u | head -30
```

### I18N-04 (P2): en.json — angielskie tłumaczenia
**Plik:** `/var/www/html/resources/i18n/en.json`
- Czy istnieje? Może brakować — i18n.js ma domyślnie PL
- Jeśli brak: stworzyć z EN textami jako fallback

### I18N-05 (P2): Przełącznik języka na stronie
- Dropdown PL/EN w navbar
- Zapisuje wybór w cookie/sesji
- i18n.js automatycznie ładuje odpowiedni plik

---

## Matryca testów WWW/RedDAXE

| # | Test | Oczekiwany wynik | Status |
|---|---|---|---|
| T-WWW-01 | Strona główna — layout jak tibia.com | Login box, menu, news, sidebar | 🔄 PARTIAL (login box fix) |
| T-WWW-02 | Login → account manage | Poprawne logowanie | ✅ PASS (2026-03-06) |
| T-WWW-03 | Rejestracja → konto działa | Nowe konto + auto-login | ⬜ |
| T-WWW-04 | Tworzenie postaci z wyborem serwera | Postać w odpowiedniej DB | ✅ PASS (2026-03-06 11:24) |
| T-WWW-05 | Account manage — postacie per serwer | Pogrupowane Classic/Modern | ✅ PASS (2026-03-06) |
| T-WWW-06 | Highscores dual-server | Tabs all/classic/modern | ✅ PASS (2026-03-06 11:35) |
| T-WWW-07 | Online dual-server | Oba serwery osobno i razem | ✅ PASS (2026-03-06 11:52) |
| T-WWW-11 | Persist `server_mode` w sesji | Wejście bez `mode` używa ostatniego wyboru | ✅ PASS (2026-03-06 11:56) |
| T-WWW-08 | i18n — brak EN na krytycznych stronach | Wszystko PL | ✅ PASS (2026-03-07) — characters, spells, serverinfo, exp_table, team, lost, account templates, rules |
| T-WWW-09 | Sync login (SSO z launchera) | Auto-login na WWW | ✅ PASS (2026-03-06 11:35) |
| T-WWW-10 | Downloads → link do launchera | ZIP pobieralny | ✅ PASS (2026-03-06) |
| T-RDX-01 | RedDAXE — rejestracja | Konto w canaryaac | ✅ PASS (2026-03-06) |
| T-RDX-02 | RedDAXE — login | Sesja + dashboard | ✅ PASS (2026-03-06) |
| T-RDX-03 | RedDAXE — CTA launcher | Link widoczny i działa | ✅ PASS (2026-03-06) |
| T-RDX-04 | RedDAXE — pełne PL | Brak mixed PL/EN | 🔄 W TRAKCIE |
