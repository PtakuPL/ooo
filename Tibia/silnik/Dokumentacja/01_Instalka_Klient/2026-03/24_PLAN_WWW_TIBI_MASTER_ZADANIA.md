# Master Plan Zadań: WWW Tibia (CanaryAAC) — Multiserwer + Konto Globalne + i18n

**Data:** 2026-03-06  
**Priorytet:** Tylko WWW Tibia. RedDAXE dopiero po domknięciu WWW.  
**Źródła:** `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md`, `16_PLAN_WWW_REDDAXE_I18N.md`, `2026-03-06_master_backlog_caly_system.md`

---

## Aktualny stan (screenshot 2026-03-06 22:49)

Problemy widoczne na stronie:
1. **`title_not_found`** w tytule zakładki — `<head data-i18n-title="site.title">` jest na `<head>`, a `i18n.js` szuka na `documentElement` (`<html>`) → klucz nie jest aplikowany; PHP `$title` nie ustawiony dla `/latestnews`
2. **`/latestnews` → 404** — brak trasy w FastRoute (`system/routes.php`), `friendly_urls=false`
3. **Selektor serwerów** (All Servers / Classic 7.4 / Modern) — już widoczny, ale nie połączony z logiką filtrowania na stronie głównej
4. **Login box** — wizualnie obecny (Global Account), ale wymaga weryfikacji działania
5. **Right sidebar** — NAJLEPSI GRACZE, NOWY GRACZ widoczne, ale dane mogą być niepoprawne dla 2 serwerów
6. **Język** — domyślny PL ustawiony, ale wiele elementów nadal EN (zwłaszcza template fallbacki)

---

## FAZA 1: Naprawy krytyczne (P0) — strona musi działać

| ID | Zadanie | Zależność | Status |
|---|---|---|---|
| W01 | **Fix routing `/latestnews`** — dodać trasę FastRoute `['GET', 'latestnews', 'news.php']` w `system/routes.php` + wyczyścić cache (`cache/route.cache`) | — | ✅ DONE |
| W02 | **Fix `title_not_found`** — przenieść `data-i18n-title="site.title"` z `<head>` na `<html>` w `templates/tibiacom/index.php` + ustawić fallback PHP `$title` | — | ✅ DONE |
| W03 | **Fix routing stron z `friendly_urls=false`** — audyt: które strony dają 404 przez brak trasy FastRoute; dodać brakujące aliasy (`/newsarchive`, `/community/*`, `/downloads`, `/payment` itd.) | W01 | ✅ DONE |
| W04 | **Fix strona główna** — upewnić się, że `news.php` ładuje się poprawnie, news z DB się wyświetlają, featured article i ticker działają | W01 | ✅ DONE |
| W05 | **Login box pełna weryfikacja** — test: login z istniejącym kontem, redirect do `/account/manage`, wyświetlenie `Welcome [name]` po zalogowaniu, logout | — | ✅ DONE |
| W06 | **Create Account redirect** — klik "Create Account" na stronie Tibia → redirect do RedDAXE (lub formularz na stronie) → konto tworzone w `canaryaac.accounts` | — | ✅ DONE (redirect 302 → RedDAXE, verified) |

---

## FAZA 2: Konto Globalne na WWW (P0) — ref: SYS-B01, SYS-B05, SYS-F03

| ID | Zadanie | Zależność | Status |
|---|---|---|---|
| W10 | **Account Manage — sekcja konta globalnego** — wyświetlić: "Konto Globalne: [nazwa]", "Email: [email]", "Premium: [dni]". Oddzielić od kont technicznych serwerów. | W05 | ✅ DONE (verified) |
| W11 | **Account Manage — postacie pogrupowane per serwer** — sekcje "Postacie Classic 7.4" i "Postacie Modern" z osobnymi przyciskami "Utwórz postać". | W10 | ✅ DONE (WWW-03) |
| W12 | **Create Character — wymuszony wybór serwera** — radio: `○ Classic 7.4  ○ Modern`. Brak domyślnego — gracz musi kliknąć. Zapis `world`/`world_id` do `players`. | W11 | ✅ DONE (WWW-02) |
| W13 | **Sync-login SSO z launchera** — endpoint `/account/sync-login?syncToken=...` konsumuje token i zakłada sesję MyAAC | — | ✅ DONE (WWW-05) |
| W14 | **Profile switch** — po zalogowaniu na konto globalne, gracz może przełączyć kontekst serwera (classic74/modern) bez wylogowania | W10 | ✅ DONE (global_profile_mode + profile-switch.php) |
| W15 | **Account manage — pokaż status serwera** — przy każdym serwerze: ONLINE/OFFLINE + liczba graczy online | W10 | ✅ DONE (sesja 2026-03-07 — server_status w manage.php + template badge) |
| W16 | **DB Separacja: tabela `games` + `account_games` + factory functions** — dynamiczne worldy w login.php, endpoint games-list.php, bazy global_accounts/api_core/cms_web | — | ✅ DONE (sesja 2026-03-07) |

---

## FAZA 3: Multiserwer na jednej stronie (P0) — ref: SYS-C01, SYS-F03, K44-K66

| ID | Zadanie | Zależność | Status |
|---|---|---|---|
| W20 | **Selektor serwera w nawigacji** — globalny dropdown/tabs w topbarze lub sidebarze: `[Wszystkie] [Classic 7.4] [Modern]`. Zapamiętywanie w sesji `$_SESSION['server_mode']`. | — | ✅ DONE (K66, verified) |
| W21 | **Dual PDO — drugie połączenie do `canary_modern`** — helper PHP `getModernDB()` wracający PDO do `canary_modern`. Config z `config.local.php`. | — | ✅ DONE (K64, verified + nowe getGameDb()) |
| W22 | **Strona główna (news) — filtr per serwer** — newsy mogą mieć `server_mode` (all/classic74/modern). Selektor filtruje widoczne newsy. | W20, W21 | ✅ DONE (sesja 2026-03-07 — game_mode ENUM column + WHERE filter) |
| W23 | **Highscores — dual-server z tabs** — już zrobione kodowo, potrzebny smoke test runtime + fix routing `/community/highscores` (404) | W20, W21 | ✅ DONE (smoke test passed — 200, vocation filter EN slugs, pagination fix, column alignment, mode label) |
| W24 | **Online — dual-server z tabs** — już zrobione kodowo, potrzebna weryfikacja runtime | W20, W21 | ✅ DONE (WWW-07) |
| W25 | **Characters search — wynik z obu baz** — wyszukiwanie postaci szuka w `canaryaac.players` + `canary_modern.players`, oznacza serwer przy wyniku | W21 | ✅ DONE (sesja 2026-03-07 — cross-server search + proxy class + [Modern] tag) |
| W26 | **Gildie — lista per serwer** — `/guilds?mode=classic74` pokazuje gildie z classic, `/guilds?mode=modern` z modern, `/guilds?mode=all` z obu | W21 | ✅ DONE (sesja 2026-03-07 — dual DB guild list + [server] tag) |
| W27 | **Domy — per serwer** — `/houses?mode=classic74` / `/houses?mode=modern` | W21 | ✅ DONE (sesja 2026-03-07 — dual DB house list) |
| W28 | **Sidebar NAJLEPSI GRACZE — dane z aktywnego serwera** — right sidebar "Top Players" pobiera z bazy odpowiadającej wybranememu `server_mode` | W20, W21 | ✅ DONE (sesja 2026-03-07 — dual DB top players with server_mode filter) |
| W29 | **Sidebar NOWY GRACZ — link z preselectem serwera** — "Dołącz do gry" / "Utwórz konto" uwzględnia wybrany serwer w linku | W20 | ✅ DONE (sesja Plan 25 — newcomer.php + newcomer.html.twig + router __redirect__ forwards query params + create.php forwards mode) |
| W30 | **Rules per serwer** — `/rules?mode=classic74` i `/rules?mode=modern` (różne zasady) | W20 | ✅ DONE (WWW-10) |
| W31 | **Shop/Sklep — wybór serwera w checkout** — gracz musi wybrać docelowy serwer zanim kupi itemki; zapis `world_id/game_mode` do płatności | W20, W21 | 🟢 CODE DONE (K45) — **UWAGA:** `/shop` → 404 runtime 2026-03-07 |

---

## FAZA 4: i18n kompletne (P0/P1) — ref: SYS-F04, K42

| ID | Zadanie | Zależność | Status |
|---|---|---|---|
| W40 | **Audyt: skanuj WSZYSTKIE `data-i18n` klucze vs pl.json/en.json** — skrypt listujący brakujące klucze | — | ✅ DONE (I18N-01) |
| W41 | **pl.json — uzupełnić brakujące klucze** — dodać wszystkie klucze potrzebne dla DOM | W40 | ✅ DONE (1053 kluczy) |
| W42 | **en.json — weryfikacja kompletności** — angielska wersja musi mieć te same klucze co pl.json | W40 | ✅ DONE (1053 kluczy, parity PL=EN) |
| W43 | **Locale PHP (main.php) — uzupełnić brakujące `__()` klucze** — skan `__('klucz')` vs `locale/pl/main.php` | — | ✅ DONE (341 kluczy PL/EN parity, 0 brakujących) |
| W44 | **Template Twig — zamienić hardcoded EN na `__()` lub `data-i18n`** — każdy user-visible string po angielsku → klucz tłumaczenia | — | ✅ DONE (account.management: Global Profile, Active Profile, Switch Profile → __()) |
| W45 | **Headline GIF-y → PL** — 20+ obrazków nagłówków (highscores, news, account itp.) — generowane przez `headline.php` z parametrem `?t=` → muszą brać z `__()` | — | ✅ DONE |
| W46 | **Menu nawigacja — pełne PL** — left sidebar: NOWOŚCI, KONTO, SPOŁECZNOŚĆ, FORUM, BIBLIOTEKA → wszystkie pozycje w PL | — | ✅ DONE |
| W47 | **Nowe klucze multiserwer** — selektor, etykiety, komunikaty: "Wszystkie serwery", "Classic 7.4", "Modern", "Brak postaci na tym serwerze" itp. | W20 | ✅ DONE (PL+EN locale + JSON: server_selector_label, server_all, server_classic74, server_modern, error_no_characters_server) |
| W48 | **i18n: formularze (login, create account, create character, lost password)** — wszystkie labele, placeholdery, komunikaty błędów w PL | — | ✅ DONE (Create.php: 16 msg→__(), CreateCharacter.php: 9 msg→__(), ChangePassword.php: 2 msg→__(), Registration.php: 4 msg→__()) |
| W49 | **i18n: komunikaty błędów** — 404, 500, "nie znaleziono postaci", "nieprawidłowe hasło", "konto zablokowane" itd. → PL | — | ✅ DONE (38 nowych kluczy w PL+EN locale + 26 nowych kluczy w pl.json/en.json: error.*, success.*) |
| W50 | **Przełącznik języka** — dropdown PL/EN w footerze lub navbarze, zapisuje cookie `locale`, przeładowuje stronę | — | ✅ DONE (i18n.js) |

---

## FAZA 5: Baza danych — 2 bazy serwerowe (P0) — ref: SYS-H01, K47-K50, K61

| ID | Zadanie | Zależność | Status |
|---|---|---|---|
| W60 | **Utworzenie bazy `canary_modern`** — kopia schematu `canaryaac` (bez danych gracza) z poprawnym prefixem tabel | — | ✅ DONE (existed) |
| W61 | **MySQL triggers: sync `canaryaac.accounts` → `canary_modern.accounts`** — INSERT/UPDATE/DELETE, pola synchronizowane wg spec K61 | W60 | ✅ DONE (triggers found in canaryaac) |
| W62 | **`config.local.php` — dodać DSN modern** — `$config['modern_database_host']` itd. (już jest `modern_database_name`) | W60 | ✅ DONE |
| W63 | **Helper `getModernDB()`** — singleton PDO do `canary_modern`, lazy-loaded | W62 | ✅ DONE (+ nowe getGameDb() w common.php) |
| W64 | **Migracja `007_payment_world_split`** — kolumny `world_id`, `game_mode` w `canary_payments` | W60 | 🟢 READY |
| W65 | **Provisioning kont** — przy rejestracji: konto tworzone w `canaryaac`, trigger kopiuje do `canary_modern`. Weryfikacja. | W61 | ✅ DONE (triggers active) |
| W66 | **Test E2E: rejestracja → konto istnieje w obu bazach** — curl/php test sprawdzający obecność w obu bazach po register | W65 | ✅ DONE (sesja 2026-03-07 — verified triggers sync, 1021 accounts matched) |

---

## FAZA 6: API kontrakty i hardening (P1) — ref: SYS-A01, SYS-G01

| ID | Zadanie | Zależność | Status |
|---|---|---|---|
| W70 | **Kontrakt API zamrożony** — dokument z finalnym payloadem każdego endpointu (`login`, `register`, `ticket`, `context`, `sync-*`, `toplist`, `players-list`) | — | 🔄 PARTIAL (K9) |
| W71 | **Rate limiting na API** — `register-account.php`: max 3 rejestracje/IP/godzinę; `login.php`: max 10 prób/konto/minutę | — | ✅ DONE (applyRateLimit() w common.php + api_rate_limits table + login:email 10/min + login:ip 30/min + register:ip 3/h) |
| W72 | **Cleanup wygasłych tokenów** — cron/skrypt: `ticket_sessions` TTL, `account_sync_tokens` TTL, `launch_tokens` TTL | — | ✅ DONE (cleanup-expired.php — 7 tabel + cron co godzinę) |
| W73 | **Structured logging** — API loguje: endpoint, account_id, IP (hash), result, timestamp. Bez sekretów. | — | ✅ DONE (logTicketEvent w login.php: success/bad_password/account_not_found/rate_limited + register rate_limited) |
| W74 | **Recovery flow: reset hasła** — `/account/lost` → email z linkiem → zmiana hasła. Działa z kontem globalnym. | — | ⬜ TODO |
| W75 | **Recovery flow: verify email** — po rejestracji wysyłka maila weryfikacyjnego; blokada pełnego dostępu do weryfikacji | — | ⬜ TODO |

---

## FAZA 7: UX i wygląd (P1) — ref: SYS-F07, SYS-F09

| ID | Zadanie | Zależność | Status |
|---|---|---|---|
| W80 | **Layout jak tibia.com** — header, left sidebar, content, right sidebar — proporcje, spacing, grafiki | — | 🔄 PARTIAL |
| W81 | **News ticker na stronie głównej** — animowany pasek wiadomości pod header'em | W04 | ⬜ TODO |
| W82 | **Featured Article na stronie głównej** — wyróżniony artykuł z obrazkiem | W04 | ⬜ TODO |
| W83 | **Right sidebar — kompletna** — Top Players, Nowy Gracz, Gallery/Screenshots, Social (opcjonalnie) | W28, W29 | ⬜ TODO |
| W84 | **Responsywność/DPI test** — 100%, 125%, 150% DPI — brak overflow, clipping | — | ⬜ TODO |
| W85 | **Downloads — czysta strona z CTA** — "Pobierz Launcher", wymagania, instrukcja | — | ✅ DONE (WWW-09) |
| W86 | **Copy spójność** — jednolite komunikaty: "Konto Globalne" (nie "Global Account"), "Utwórz postać" (nie "Create Character") w całym serwisie | — | ✅ DONE (menus.php, index.php, Base.php, Lost.php, CreateCharacter.php, create.php — 350 kluczy PL/EN + 1083 JSON) |

---

## FAZA 8: Testy E2E i akceptacja (P1) — ref: SYS-J01-J05

| ID | Zadanie | Zależność | Status |
|---|---|---|---|
| W90 | **Test: nowy gracz od zera** — wejście na stronę → rejestracja → login → create character (classic74) → widzi postać | Faza 1-3 | ⬜ TODO |
| W91 | **Test: nowy gracz modern** — rejestracja → create character (modern) → postać w modern DB | Faza 1-3 | ⬜ TODO |
| W92 | **Test: SSO z launchera** — sync-login → auto-login WWW → create character → widzi postać | W13 | ⬜ TODO |
| W93 | **Test: highscores dual-server** — `/highscores?mode=all`, `classic74`, `modern` — poprawne dane | W23 | ⬜ TODO |
| W94 | **Test: online dual-server** — `/online?mode=all`, `classic74`, `modern` — poprawne dane | W24 | ⬜ TODO |
| W95 | **Test: characters search cross-server** — szukanie nazwy z classic i modern — oba znaleziono | W25 | ⬜ TODO |
| W96 | **Test: shop dual-server** — checkout wymusza wybór serwera | W31 | ⬜ TODO |
| W97 | **Test: i18n kompletność** — przejście przez każdą stronę, brak EN stringów przy `lang=pl` | W40-W50 | ⬜ TODO |
| W98 | **Test: konto z RedDAXE działa na WWW** — konto z portalu → login na WWW → widzi postacie | W05 | ⬜ TODO |

---

## FAZA 9: Runtime bugs wykryte 2026-03-07

| ID | Zadanie | Zależność | Status |
|---|---|---|---|
| W100 | **`/community/houses` → 404** — brak routingu lub brakujący plik strony houses w runtime | W27 | ⬜ TODO |
| W101 | **`/shop` → 404** — brak routingu sklepu w runtime, endpoint nie odpowiada | W31 | ⬜ TODO |
| W102 | **Online page — `a.country` column error** — dual modern query emituje `Unknown column 'a.country'` dla bazy `canary_modern`. Tabela `accounts` w `canary_modern` nie ma kolumny `country`. Strona ładuje się, ale modern data jest pusta. | W24 | ⬜ TODO |
| W103 | **Guilds — `description` column error** — `Unknown column 'description' in SELECT` w `/community/guilds`. Schema mismatch w tabeli `guilds`. Strona zwraca 200 (graceful degradation) ale dane mogą być niekompletne. | W26 | ⬜ TODO |
| W104 | **Highscores vocation dropdown — surowe nazwy PL z config** — dropdown pokazuje `Czarnoksiężnik`, `Paladyn` itd. z configa zamiast przetłumaczonych nazw z `__()`. Warunki `{% if vocationLabel == 'Sorcerer' %}` nigdy nie matchują polskich nazw. Nie blokuje (config jest po polsku), ale docelowo lookup po indeksie zamiast po nazwie EN. | W23 | ⬜ TODO (minor) |
| W105 | **Create Character — success message widoczność** — zweryfikować czy i18n `create_char_success_title` + `create_char_success_description` z placeholderami `$NAME$` i `$SERVER$` działa poprawnie w runtime na obu serwerach | W12 | ⬜ TODO (smoke) |

---

## Kolejność realizacji

```
FAZA 1 (P0): W01 → W02 → W03 → W04 → W05 → W06
    ↓
FAZA 2 (P0): W10 → W14 → W15
    ↓
FAZA 3 (P0): W20 → W21 → W22 → W23 → W25 → W26 → W27 → W28 → W29 → W31
    ↓
FAZA 4 (P0/P1): W41 → W42 → W43 → W44 → W47 → W48 → W49
    ↓
FAZA 5 (P0): W60 → W61 → W62 → W63 → W64 → W65 → W66
    ↓
FAZA 6 (P1): W70 → W71 → W72 → W73 → W74 → W75
    ↓
FAZA 7 (P1): W80 → W81 → W82 → W83 → W84 → W86
    ↓
FAZA 8 (P1): W90-W98
```

> **RedDAXE** — po ukończeniu Faz 1-4 WWW Tibia: RDX-04 (pełne PL), RDX-06 (spójność wizualna).

---

## Mapowanie na SYS-* z master backlogu (GPT 5.4)

| SYS | Zadanie WWW | Status |
|---|---|---|
| SYS-A03 | Nazewnictwo `classic74/modern/all` konsekwentnie | W20, W47 |
| SYS-B01 | Rejestracja z WWW = to samo konto globalne | W06, W65 |
| SYS-B02 | Provisioning kont technicznych dla engine | W61, W65 |
| SYS-B03 | SSO dwukierunkowy (launcher↔WWW) | W13 ✅, W14 |
| SYS-B05 | Rozdzielenie w UI: konto globalne vs techniczne vs postać | W10, W11 |
| SYS-C01 | Mapowanie `world_id` → classic74/modern | W12 ✅, W21 |
| SYS-C02 | Wybór trybu przed połączeniem | W12 ✅, W20 |
| SYS-C03 | Filtrowanie per world w login/context/ticket | K1-K4 ✅ |
| SYS-F01 | RedDAXE i WWW te same endpointy | K31 ✅ |
| SYS-F03 | Account pages z konto globalne + postacie per serwer | W10, W11 ✅ |
| SYS-F04 | i18n cały WWW | W40-W50 |
| SYS-F05 | Sync-login jednorazowy token | W13 ✅ |
| SYS-F06 | Refresh context po create character | W14 |
| SYS-G01 | Hardening API | W71-W73 |
| SYS-H01 | Schemat baz: globalne + techniczne | W60-W65 |

---

## Definition of Done — WWW Tibia

1. Strona główna ładuje się bez 404 i bez `title_not_found`
2. Gracz może się zarejestrować, zalogować, utworzyć postać na obu serwerach
3. Selektor serwera widoczny i działa na: highscores, online, guilds, houses, characters
4. Konto globalne ma jasne rozdzielenie od postaci per serwer w Account Manage
5. Cała strona po polsku (brak EN stringów przy `lang=pl`)
6. Przełącznik PL/EN działa
7. Dane z obu baz (classic74 + modern) wyświetlają się poprawnie
8. SSO z launchera → auto-login na WWW
9. Testy E2E W90-W98 PASS
