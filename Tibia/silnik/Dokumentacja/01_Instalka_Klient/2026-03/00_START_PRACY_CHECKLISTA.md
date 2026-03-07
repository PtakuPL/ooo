# Start Pracy i Zasady Prowadzenia Zmian

Data utworzenia: 2026-03-01  
Zakres: ticket-gate, tryby gry, blokada serwerów, launcher

---

## Status Zadań (aktualizować na bieżąco!)

### Faza A — Klient UX
| # | Zadanie | Status | Commit |
|---|---------|--------|--------|
| A1 | `CLIENT_LOCKED` + `GameModes` w `init.lua` | ✅ DONE | `72681f84c` |
| A2 | Ekran wyboru trybu (`gameModePanel`) | ✅ DONE | `b216fe683` |
| A3 | Logika wyboru trybu w `entergame.lua` | ✅ DONE | `b216fe683` |
| A4 | Blokada `ServerList.add/remove` | ✅ DONE | `b216fe683` |
| A5 | Ukrycie pól serwera/portu/protokołu | ✅ DONE | `b216fe683` |
| A6 | Feature flags: blokada hotkey runes | ✅ DONE | `7957e93f5` → `98964825b` |
| A7 | Feature flags: ukrycie modułów (market, itp.) | ❌ N/A | wycofane — blokady od serwera (Faza D) |
| A8 | Test kompilacja Windows + Linux | 🟢 Linux PASS | GHA #22717070014; Windows ⬜ TODO |
| A-FIX | Codex review: port 443, ServerList lock, setLoginFormVisible, placeholder walidacja | ✅ DONE | `7957e93f5` → `98964825b` |

### Znane problemy C++ (NIE ruszamy w Fazie A — do Fazy B/X2)
| # | Problem | Plik | Linia | Priorytet | Status |
|---|---------|------|-------|-----------|--------|
| CPP-1 | TLS verification wyłączone (`enable_server_certificate_verification(false)`) | `src/framework/net/httplogin.cpp` | 211 | KRYTYCZNY | ✅ NAPRAWIONE (X2) |
| CPP-2 | HTTP fallback po HTTPS fail (`loginHttpJson`) | `src/framework/net/httplogin.cpp` | 108-109 | KRYTYCZNY | ✅ NAPRAWIONE (X2b) |
| CPP-3 | Emscripten HTTP fallback (`http://` URL) | `src/framework/net/httplogin.cpp` | ~170 | WYSOKI | ✅ NAPRAWIONE (X2b) |
| CPP-4 | `loginHttpJson()` definicja — dead code (nie wywoływana) | `src/framework/net/httplogin.cpp` | 236 | NISKI | ⚠️ do cleanup |

### Codex Review — nowe findings (2026-03-01)
| # | Priorytet | Problem | Plik | Status |
|---|-----------|---------|------|--------|
| CR-1 | WYSOKIE | Niespójny format hosta — `GameModes.server.host` to sam host, ale `tryHttpLogin` parsuje `G.host` jako host/path. `httpLoginUrl` zdefiniowany ale nigdzie nieużywany. | `init.lua:28`, `entergame.lua:691`, `init.lua:32` | ✅ DONE |
| CR-2 | ŚREDNIE | Komunikat błędu HTTP nieaktualny po usunięciu fallbacku — nadal sugeruje "Enable Http login / port 80/8080" co jest mylące. | `httplogin.cpp:135` | ✅ DONE |
| CR-3 | ŚREDNIE | X7 częściowo zrobione — body usunięte z logów, ale `req.headers` i `res.headers` nadal wypisywane. Wrażliwe nagłówki (np. `Set-Cookie`) mogą wyciekać. | `httplogin.cpp:53,63` | ✅ DONE |
| CR-4 | NISKIE | Unused variable — `httpLogin` nadal łapany przez lambdy ale już nieużywany po X2b. Potencjalny warning kompilatora przy ostrzejszych flagach. | `httplogin.cpp:106,146` | ✅ DONE |

### Codex Review — FIX1-FIX8 (2026-03-01 sesja nocna)
| # | Problem | Naprawa | Status |
|---|---------|---------|--------|
| FIX1 | 6 guardów D6/D10 wstawionych w złe miejsca w protocolgame.cpp | Usunięto błędne, dodano poprawne do metod parse* | ✅ DONE |
| FIX2 | ticket_validator.cpp brakujący w CMakeLists.txt | Dodano do target_sources | ✅ DONE |
| FIX3 | Brak ścieżki authType="ticket" — sessionKey splitowany przez `\n` | Dodano ticketGateActive check | ✅ DONE |
| FIX4 | requestTicket brak worldName w JSON | Dodano worldName do C++ i Lua | ✅ DONE |
| FIX5 | HMAC na base64 vs JSON — niespójność z planem | Udokumentowano: base64 jest celowe (JWT-like) | ✅ DONE |
| FIX6 | Client fail-open — config error → bypass ticketu | Zmieniono na fail-closed + onTicketConfigError() | ✅ DONE |
| FIX7 | D8 "rate-limit rune" ale kod limituje ruch | Udokumentowano: ruch celowy, runy kliencko (D7) | ✅ DONE |
| FIX8 | ServerList ukryta zamiast read-only | Lista widoczna, add/remove/select ukryte | ✅ DONE |

### Quick Security Wins (X2, X3, X7)
| # | Zadanie | Status | Commit | Priorytet |
|---|---------|--------|--------|-----------|
| X2 | Hard-fail TLS w kliencie (`httplogin.cpp:211`) | ✅ DONE | `7957e93f5` → `98964825b` | KRYTYCZNY |
| X2b | Usunięcie HTTP fallback (`httplogin.cpp:108` + Emscripten) | ✅ DONE | `7957e93f5` → `98964825b` | KRYTYCZNY |
| X3 | Fix ServerList bypass | ✅ DONE (A-FIX) | `7957e93f5` → `98964825b` | — |
| X7 | Usunięcie logów haseł (Logger: req.body + res.body) | ✅ DONE | `7957e93f5` → `98964825b` | NISKI |

### Faza B — API HTTP ticket-gate
| # | Zadanie | Status | Commit |
|---|---------|--------|--------|
| B1 | `gameMode` + `launchToken` w login.php | ✅ DONE | `7957e93f5` → `98964825b` |
| B2 | Filtrowanie worldów wg gameMode | ✅ DONE | `7957e93f5` → `98964825b` |
| B3 | Nowy endpoint `ticket.php` | ✅ DONE | `7957e93f5` → `98964825b` |
| B4 | Tabela `ticket_nonces` + `ticket_sessions` MySQL | ✅ DONE | `7957e93f5` → `98964825b` |
| B5 | Klient Lua: request do ticket.php | ✅ DONE | `7957e93f5` → `98964825b` |
| B6 | Klient C++: `requestTicket()` | ✅ DONE | `7957e93f5` → `98964825b` |
| B7 | Test flow login→ticket→connect | ✅ DONE | `7957e93f5` (smoke test CLI) |

### Faza C — Serwer Canary ticket-gate
| # | Zadanie | Status | Commit |
|---|---------|--------|--------|
| C1 | `ticket_validator.cpp/.h` | ✅ DONE | `7957e93f5` → `98964825b` |
| C2 | Integracja z `protocolgame.cpp` | ✅ DONE | `7957e93f5` → `98964825b` |
| C3 | Klucze w `configmanager.cpp` + `config_enums.hpp` | ✅ DONE | `7957e93f5` → `98964825b` |
| C4 | Konfiguracja `config.lua` / `config.lua.dist` | ✅ DONE | `7957e93f5` → `98964825b` |
| C5 | Nonce store | ✅ DONE (in-memory w ticket_validator) | `7957e93f5` → `98964825b` |
| C6 | Kompilacja i test | ✅ DONE (Linux) | GHA #22717070014 PASS (652c0e033) |

### Faza D — Feature flags serwer Canary
| # | Zadanie | Status | Commit |
|---|---------|--------|--------|
| D1 | `GameMode` enum + pole w `Player` | ✅ DONE | `7957e93f5` → `98964825b` |
| D2 | Blokada rune-on-creature hotkey | ✅ DONE | `7957e93f5` → `98964825b` |
| D3 | Blokada Quick Loot / Auto Loot | ✅ DONE | `7957e93f5` → `98964825b` |
| D4 | Blokada Market (5 metod) | ✅ DONE | `7957e93f5` → `98964825b` |
| D5 | Blokada Prey System | ✅ DONE | `7957e93f5` → `98964825b` |
| D6 | Blokada Wheel of Destiny | ✅ DONE | `7957e93f5` → `98964825b` |
| D7 | Blokada Smart Equip | ✅ DONE | `7957e93f5` → `98964825b` |
| D8 | Rate-limit run 1000ms | ✅ DONE | `7957e93f5` → `98964825b` |
| D9 | Blokada Action Bar packets | ❌ N/A | brak w codebase |
| D10 | Blokada Bestiary | ✅ DONE | `7957e93f5` → `98964825b` |
| D11 | Test integracyjny | ⬜ TODO | wymaga kompilacji |

### Faza E — Launcher z auto-update ✅ GOTOWE
| # | Zadanie | Status | Commit |
|---|---------|--------|--------|
| E1 | Skrypt `generate_manifest.php` | ✅ DONE | `7957e93f5` → `98964825b` |
| E2 | Endpoint `update.php` | ✅ DONE | `7957e93f5` → `98964825b` |
| E3 | Endpoint `launcher-token.php` | ✅ DONE | `7957e93f5` → `98964825b` |
| E4 | Endpoint `launcher-version.php` | ✅ DONE | `7957e93f5` → `98964825b` |
| E5 | Tabela `launch_tokens` + `manifest_versions` MySQL | ✅ DONE | `7957e93f5` → `98964825b` |
| E6-E8 | Launcher Python (GUI + pobieranie + token) | ✅ DONE | `7957e93f5` → `98964825b` |
| E9 | Launcher self-update | ✅ DONE | `7957e93f5` → `98964825b` |
| E10 | Klient: `OTC_LAUNCH_TOKEN` env + C++ + Lua | ✅ DONE | `7957e93f5` → `98964825b` |
| E11 | API `login.php`: walidacja `launchToken` | ✅ DONE | `7957e93f5` → `98964825b` |
| E12 | Smoke test flow | ✅ DONE | `7957e93f5` |
| E13 | Hosting plików klienta | ⬜ TODO | — |

### Codex Review #2 — FIX9-FIX17 (2026-03-02) ✅ GOTOWE
| # | Priorytet | Problem | Naprawa | Status |
|---|-----------|---------|---------|--------|
| FIX9+15 | KRYTYCZNE | Wheel D6 guards: broken braces + floating code | Guardy na początek funkcji, usunięty floating block | ✅ DONE |
| FIX10 | KRYTYCZNE | Auth bypass po ticket — `gameWorldAuthentication(ticketString)` zawsze FAIL | Skip gameWorldAuth, użyj `ticketAccountId` + `g_accountRepository()` | ✅ DONE |
| FIX11 | KRYTYCZNE | `(int)$expires_at` na TIMESTAMP | Już naprawione (E11 sesja) — `strtotime()` | ✅ DONE |
| FIX12 | WYSOKIE | launcher-token.php: empty manifestVersion = skip filesHash | Fail-closed — sprawdź filesHash vs najnowszy manifest | ✅ DONE |
| FIX13 | WYSOKIE | worldName w tickecie nigdy niewalidowany | ticket.php: wymagany; ticket_validator: vs SERVER_NAME | ✅ DONE |
| FIX14 | WYSOKIE | ServerList pusta w CLIENT_LOCKED | Wypełnienie z GameModes w `ServerList.init()` | ✅ DONE |
| FIX16 | ŚREDNIE | CLIENT_LOCKED drift: init.lua=true, .env=false | .env zsync do true + komentarze SYNC w obu plikach | ✅ DONE |
| FIX17 | NISKIE | `--icon "icon.ico"` — brak pliku | Linia wykomentowana w build_launcher.bat | ✅ DONE |

### Codex Review #3 — nowe findings (2026-03-02) ✅ NAPRAWIONE
| # | Priorytet | Problem | Plik(i) | Status |
|---|-----------|---------|---------|--------|
| FIX18 | KRYTYCZNE | gameMode nie wysyłany w body login HTTP → sesja=modern → ticket mismatch | `httplogin.h/cpp`, `luafunctions.cpp`, `entergame.lua` | ✅ DONE |
| FIX19 | WYSOKIE | worldName: API wystawia "Classic 7.4" ale SERVER_NAME="Tibia 7.4 test" → mismatch | `ticket_validator.cpp` | ✅ DONE |
| FIX20 | WYSOKIE | ticket.php: brak walidacji world↔gameMode (plan wymaga mapowania) | `ticket.php` | ✅ DONE |
| FIX21 | ŚREDNIE | launcher-token.php: fail-open przy pustej manifest_versions (sprzeczne z opisem) | `launcher-token.php` | ✅ DONE |
| FIX22 | ŚREDNIE | Podwójny slash w login URL (`//login.php`) | `entergame.lua` | ✅ DONE |
| FIX23 | ŚREDNIE | Nonce replay-store: cleanup >10k ale nigdzie cyklicznie nie wywoływany | `ticket_validator.hpp/cpp` | ✅ DONE |

### Audyt end-to-end #7 — FIX56-FIX65 (2026-03-02) ✅ DEEP STATIC REVIEW
| # | Priorytet | Problem | Plik(i) | Status |
|---|-----------|---------|---------|--------|
| FIX56 | KRYTYCZNE | Emscripten UAF: fetch→status po close | `httplogin.cpp` | ✅ DONE |
| FIX57 | WYSOKIE | TICKET_SECRET placeholder mismatch | `ticket.php` | ✅ DONE |
| FIX58 | WYSOKIE | ticket.php world IDs 1/2 vs login.php 0/1 | `ticket.php` | ✅ DONE |
| FIX59 | ŚREDNIE | Empty gameMode → ALL chars worldId=0 | `login.php` | ✅ DONE |
| FIX60 | ŚREDNIE | Launcher deletes user logs/cache | `launcher.py` | ✅ DONE |
| FIX61 | ŚREDNIE | raw `this` w async lambda | SKIP (LuaObject refcount) | ⬜ SKIP |
| FIX62 | NISKIE | update.php error format ≠ sendError | `update.php` | ✅ DONE |
| FIX63 | NISKIE | previewState case mismatch | `entergame.lua` | ✅ DONE |
| FIX64 | NISKIE | variable shadowing account/password | `entergame.lua` | ✅ DONE |
| FIX65 | NISKIE | deploy_api.sh: brak set -e | `deploy_api.sh` | ✅ DONE |

### Audyt end-to-end #6 — FIX50-FIX55 (2026-03-02) ✅ CODEX REVIEW FIXES
| # | Priorytet | Problem | Plik(i) | Status |
|---|-----------|---------|---------|--------|
| FIX50 | KRYTYCZNE | Lua parse error: `child:getStyleName` bez args | `entergame.lua` | ✅ DONE |
| FIX51 | WYSOKIE | launcher.py szuka `error` ale API zwraca `errorCode` | `launcher.py` | ✅ DONE |
| FIX52 | WYSOKIE | premium: `lastday + premdays*86400` = podwójne naliczanie | `login.php` | ✅ DONE |
| FIX53 | ŚREDNIE | ticket.php worldName-only validation = kruche | `ticket.php` | ✅ DONE |
| FIX54 | ŚREDNIE | characterlist.lua: `G.sessionKey` zamiast legacySessionKey | `characterlist.lua` | ✅ DONE |
| FIX55 | NISKIE | randomseed per-request → kolizja w 1s | `entergame.lua` | ✅ DONE |

### Audyt end-to-end #5 — FIX25, FIX31-33, FIX45-C2, FIX-W1 (2026-03-02) ✅ INFRASTRUKTURA + DEPLOYMENT
| # | Priorytet | Problem | Plik(i) | Status |
|---|-----------|---------|---------|--------|
| FIX25 | KRYTYCZNE | Placeholder ZMIEN_NA_ADRES → prawdziwy adres 127.0.0.1 | `init.lua` | ✅ DONE |
| FIX31 | WYSOKIE | launcher_config.json http→https + apiUrl→/apik/v1/ | `html_copy/launcher_config.json` | ✅ DONE |
| FIX32 | WYSOKIE | launcher clientDir ./client → ../testyy | `launcher/launcher_config.json` | ✅ DONE |
| FIX33 | WYSOKIE | CLIENT_LOCKED + TICKET_SECRET auto-validation | `deploy_api.sh` | ✅ DONE |
| FIX45 | KRYTYCZNE | SSL/TLS na nginx (self-signed CA+cert, port 443) | nginx config + ssl/ | ✅ DONE |
| FIX46 | WYSOKIE | cacert.pem dla klienta OTClient | `testyy/cacert.pem` | ✅ DONE |
| FIX47 | WYSOKIE | deploy_api.sh — automatyczny sync PHP→/var/www/html | `deploy_api.sh` (nowy) | ✅ DONE |
| FIX48 | WYSOKIE | Sync 9 plików API do /var/www/html | deployed files | ✅ DONE |
| FIX49 | ŚREDNIE | .env URL http→https | `.env`, `.env.example` | ✅ DONE |
| FIX-C1 | KRYTYCZNE | config.lua ip bind 172.29.76.234 → 0.0.0.0 (WORLD_IP mismatch) | `config.lua` | ✅ DONE |
| FIX-C2 | WYSOKIE | cacert.pem ścieżka ./cacert.pem → g_resources.getWorkDir() | `httplogin.cpp` | ✅ DONE |
| FIX-W1 | NISKIE | Odwrócona logika port detection → zawsze 443 domyślnie | `entergame.lua` | ✅ DONE |

### Audyt end-to-end #4 — FIX24-FIX44 (2026-03-02) ✅ NAPRAWIONE
| # | Priorytet | Problem | Plik(i) | Status |
|---|-----------|---------|---------|--------|
| FIX24 | KRYTYCZNE | .env brak WORLD_IP → klienci dostają 127.0.0.1 | `.env`, `.env.example` | ✅ DONE |
| FIX26 | KRYTYCZNE | login.php brak ismaincharacter/ishidden/dailyrewardstate | `login.php` | ✅ DONE |
| FIX27 | KRYTYCZNE | math.random(1) = zawsze 1 → kolizja requestId | `entergame.lua` | ✅ DONE |
| FIX28 | KRYTYCZNE | Non-ticket auth: UUID zamiast account\npassword | `entergame.lua` | ✅ DONE |
| FIX29 | WYSOKIE | premium hardcoded 0/false zamiast z DB | `login.php` | ✅ DONE |
| FIX30 | WYSOKIE | ticket port z srv.port zamiast G.port | `entergame.lua` | ✅ DONE |
| FIX34 | WYSOKIE | .env.example + .gitignore (sekrety nie w repo) | `.env.example`, `.gitignore` | ✅ DONE |
| FIX35 | WYSOKIE | cacert.pem brak → TLS fail bez komunikatu | `httplogin.cpp` | ✅ DONE |
| FIX38 | ŚREDNIE | startHttpLogin loguje body z session keys | `httplogin.cpp` | ✅ DONE |
| FIX39 | ŚREDNIE | Brak obsługi argon2/bcrypt haseł | `login.php` | ✅ DONE |
| FIX42 | ŚREDNIE | loadEnvFiles×5 duplikacja → common.php | `common.php` + 5 plików PHP | ✅ DONE |
| FIX43 | NISKIE | launcher-token error format inny niż reszta | `launcher-token.php` (via common.php) | ✅ DONE |
| FIX44+CPP-4 | NISKIE | Dead code loginHttpJson usunięty | `httplogin.h/cpp` | ✅ DONE |

### Faza K — Wspólne Konto + 2 Serwery (launcher + strona) [PLAN]

> **UWAGA numeracja**: Checklista poniżej używa kompaktowej numeracji K1-K19.
> Plan szczegółowy w `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` ma rozszerzoną numerację K1-K21
> (K15 tu = K15+K16+K17 tam; K16 tu = K18 tam; K17 tu = K19 tam; K18 tu = K20 tam; K19 tu = K21 tam).

| # | Zadanie | Status | Artefakt |
|---|---------|--------|----------|
| K1 | Ujednolicić login i sesję `gameMode=all` (wybór serwera po loginie) | ✅ RUNTIME PASS (2026-03-05) — login zwraca 2 worldy (Classic7.4+Modern), sessionkey OK | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K2 | Spójne mapowanie `gameMode ↔ worldId ↔ worldName` dla API/launchera/strony | ✅ RUNTIME PASS — worldId 0=Classic7.4, 1=Modern, mapowanie spójne | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K3 | Rozdział postaci per serwer na bazie `players.world` (z fallbackiem) | ✅ RUNTIME PASS (2026-03-05) — charactersByWorld mapuje world=0→classic74, world=1→modern | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K4 | Ticket flow dla sesji `all` + twarda walidacja world/character | ✅ RUNTIME PASS (2026-03-05) — ticket OK, cross-mode mismatch blokowany | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K5 | Rejestracja konta z launchera (API) | ✅ RUNTIME PASS (2026-03-05) — register OK (accountId=10), dupe=409 | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K6 | Endpoint kontekstu konta: wybór serwera i postaci per serwer | ✅ RUNTIME PASS (2026-03-05) — zwraca account+worlds+charactersByWorld | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K7 | Topki wspólne + per-serwer (`all/classic74/modern`) | 🔄 PARTIAL — API runtime PASS (2026-03-05); WWW/MyAAC (`/community/highscores` + legacy `/index.php/highscores`) rozdzial serwera wdrozony kodowo (2026-03-06), runtime smoke pending | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K8 | Listy graczy wspólne + per-serwer (`all/classic74/modern`) | ✅ RUNTIME PASS (2026-03-05) — players-list filtruje modern/classic74 | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K9 | Kontrakt JSON launcher+WWW dla konta wspólnego i 2 serwerów | ✅ opisane (docs) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K10 | Testy i wpisy PASS/FAIL/BLOCKED do dziennika wyników | ✅ RUNTIME E2E PASS: K1,K5-K8,K12-K14 all PASS (2026-03-05); K15 503 (no secrets) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K11 | Migracja DB pod identity/social/sync (`004_identity_social`) | ✅ APPLIED (2026-03-05 19:12) | `canary_test/html_copy/apik/v1/migrations/004_*` |
| K12 | Sync WWW↔launcher: issue/consume jednorazowego tokenu | ✅ RUNTIME PASS (2026-03-05) — sync-token issued + consumed + replay=409 | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K13 | Flow: konto założone w launcherze -> tworzenie postaci na WWW | ✅ RUNTIME PASS (2026-03-05) — consume→session+cookie+redirect /account/createcharacter | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K14 | Flow: konto założone na WWW -> synchronizacja z launcherem | ✅ RUNTIME PASS (2026-03-05) — www-login sets CanaryAAC cookie + 302 redirect | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K15 | Social login Google/Facebook/Steam w launcherze (link/create) | 🔄 backend gotowy w repo, runtime deployed; brak secrets providerów (GOOGLE_CLIENT_ID itp.) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K16 | Hardening social/sync (PKCE, state/nonce, rate-limit, audit) | ✅ DONE — migracja 005 APPLIED (2026-03-05 20:16), PKCE+state+audit w repo, OAUTH_RATE_LIMIT_ENABLED=true w .env | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K17 | UX: po rejestracji w launcherze przyciski `Utworz postac Tibia 7.4/Modern` + redirect WWW z preselectem swiata | ✅ kod gotowy (repo) + K14 runtime PASS (www-login redirect z preselectem) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K18 | Launcher: `Utworz postac` probuje auto-login WWW przez `account-sync-token.php` (z `sessionKey`) + fallback bez auto-logowania | ✅ RUNTIME PASS (K12-K14 full flow) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K19 | Natywny login konta w launcherze (email+haslo -> `sessionKey` bez recznego wklejania) | 🟢 kod gotowy (repo): formularz UI + komenda Tauri, runtime E2E pending | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K20 | Spec globalnego konta launchera dla wielu gier (`identity` + profile per gra/serwer) | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K21 | Security scope multi-game (token tozsamosci vs token profilu gry + audit) | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K22 | Gildie: model globalny + odwzorowanie per gra/serwer (rozne wymagania/czlonkowie) | ⏸ DEFERRED (po stabilizacji login/security) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K23 | UI aren (launcher/WWW) | ⏸ DEFERRED (po stabilizacji login/security) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K24 | Natywna rejestracja konta w launcherze + auto-login + fallback do recznego loginu | 🟢 kod gotowy (repo), runtime E2E pending | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K28 | Ujednolicenie rejestracji WWW/API (walidacja + pola konta) | 🟢 kod gotowy (repo), runtime E2E pending | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K29 | Portal `RedDAXE.pl`: IA front-doora (download, konto, WWW, forum, wiki, external) | ✅ RUNTIME PASS (2026-03-05) — portal/index.php HTTP 200 | `04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md` |
| K30 | `RedDAXE.pl`: download launchera + checksum + fallback link | ✅ RUNTIME PASS (2026-03-05) — download.php HTTP 200, SHA-256 widoczny | `04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md` |
| K31 | `RedDAXE.pl`: rejestracja/logowanie konta wspolnego (ten sam backend `accounts`) | ✅ RUNTIME PASS (2026-03-05) — register+login+duplikat E2E PASS | `04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md` |
| K32 | `RedDAXE.pl`: routing i bezpieczne przekierowania do WWW/forum/wiki/external | ✅ RUNTIME PASS (2026-03-05) — www/forum/wiki 302, external 302, open-redirect 400 | `04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md` |
| K33 | Testy pre-kompilacyjne E2E portalu (konto + download + nawigacja) | ✅ RUNTIME PASS (2026-03-05) — 14/14 testow E2E PASS | `04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md` |
| K34 | Spojnosc brandingu i copy miedzy `RedDAXE.pl`, WWW i launcherem | 🟢 branding MVP OK (dark theme, polski copy), pelny branding po kompilacji launchera | `04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md` |
| K35 | Spike architektury: czy portal `RedDAXE.pl` zostaje na PHP czy przechodzi na Python+Django (koszt/migracja/ryzyko) | ⬜ TODO (decyzja arch) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K36 | Model globalnych rang (Helper/Admin/Multiadmin) dla wielu gier/serwerow | ⬜ TODO (po stabilizacji kont/security) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K37 | Federacja rang do forum/serwisow zewnetrznych (badge/title sync API + mapowanie uprawnien) | ⬜ TODO (etap pozniejszy) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K38 | Django bootstrap: projekt + inspectdb `accounts` + model `StaffRole` + Django Admin panel | ⬜ TODO (po K35 spike) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K39 | DRF REST API: endpointy rang i integracji (GET/POST staff roles, Discord webhook sync) | ⬜ TODO (po K38) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K40 | Migracja portalu RedDAXE z PHP na Django (templates + views + auth) | ⬜ TODO (po K38+K39) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K41 | Pelne i18n portalu RedDAXE (`/portal` + `/reddaxe`): slowniki, fallback, selector jezyka, bez hardcoded PL | 🔄 PARTIAL — `/portal` runtime PASS (13/13); `/reddaxe` i18n wdrozone kodowo (PL/EN, selector, fallback, lokalny smoke PASS 2026-03-05), deploy/runtime smoke pending | `04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md` |
| K42 | Pelne i18n WWW Tibia (CanaryAAC): strony konta/postaci/topki/listy + komunikaty bledow | 🔄 PARTIAL (2026-03-07) — characters.html.twig: 18 etykiet EN→PL (Nazwa/Płeć/Profesja/Poziom/Doświadczenie/Poziom magii/Zabójstwa/Miasto/Saldo/Dom/Utworzono/Umiejętności/Zadania/Ekwipunek/Ofiary/Sygnatura), getSkillName()→PL (walka wręcz/mieczem/maczugą/toporem/dystansowa, obrona tarczą, wędkarstwo, poziom magii), genders→PL (Kobieta/Mężczyzna), daty→dd.mm.YYYY. Wcześniej: 20+ obrazów GIF→PL, CSS overlay sidebar, highscores fix. | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K43 | Matryca testow i18n E2E (launcher+portal+WWW): PL/EN + fallback + brak brakujacych kluczy | 🔄 PARTIAL — portal `/portal` + AAC runtime PASS; `/reddaxe` lokalny smoke PASS po i18n; launcher i runtime smoke `/reddaxe` pending | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K44 | CanaryAAC WWW: rozdzial rankingow (`community/highscores` + `api/highscores`) na `all/classic74/modern` + filtr serwera w UI (takze legacy `/index.php/highscores`) | 🟢 CODE DONE; runtime smoke czesciowy (2026-03-05): `/index.php/highscores`=200, `/community/highscores`=404, API split PASS | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K45 | CanaryAAC WWW Shop: wybor serwera (Classic/Modern) w checkout + propagacja contextu + zapis `world_id/game_mode` w `canary_payments` (gdy kolumny istnieja) | 🟢 CODE DONE; runtime smoke (2026-03-05): `/shop/payment`=404, migracja `007_payment_world_split` gotowa, deploy routingu pending | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K46 | Topki laczone (agregaty cross-server: np. zabicia, monety) jako osobny typ rankingu ponad 2 serwerami | ⬜ TODO (projekt DB + endpoint + UI) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K47 | Architektura 2 baz serwerow: model `global accounts` + `game_classic74` + `game_modern` + kontrakt polaczen DB | ⬜ TODO (spec) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K48 | Migracje infra: DSN/ENV dla `DB_GAME_CLASSIC74_*` i `DB_GAME_MODERN_*` + bootstrap polaczen | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K49 | Warstwa repozytoriow per-serwer (read/write routing po `gameMode`) | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K50 | Mapowanie kont `global -> world` (`account_world_links`) + provisioning profili serwerowych | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K51 | API agregujace topki/listy z 2 baz (`all/classic74/modern`) + znacznik zrodla rekordu | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K52 | WWW: jedna strona nad 2 bazami (server switch, fallback/degraded mode) | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K53 | Checkout sklepu SMS: twardy kontekst serwera/bazy + walidacja koszyka per-serwer | 🔄 SPEC READY (2026-03-05) | `05_PLAN_SKLEP_SMS_2_BAZY.md` |
| K54 | Callback SMS: idempotencja + podpis provider + anti-replay + routing creditu do poprawnej bazy | 🔄 PARTIAL — callback core wdrozony (`CallbackProcessor` + PayPal/MercadoPago/PagSeguro), migracja `009` + runtime E2E/secrets pending | `05_PLAN_SKLEP_SMS_2_BAZY.md` |
| K55 | Historia zakupow: widok `all` + filtry per-serwer + audit trail | 🔄 PARTIAL — audit ledger schema + zapis ledger z callbackow wdrozone; read-model/UI pending | `05_PLAN_SKLEP_SMS_2_BAZY.md` |
| K56 | Rekonsyliacja platnosci (cron/worker): wykrywanie rozjazdow provider <-> DB | 🔄 SPEC READY (2026-03-05) | `05_PLAN_SKLEP_SMS_2_BAZY.md` |
| K57 | Matryca testow E2E (bez kompilacji): register/login/create-character/shop-sms dla 2 baz | 🔄 SPEC READY (2026-03-05) | `05_PLAN_SKLEP_SMS_2_BAZY.md` |
| K58 | Plan migracji danych: model 1-baza -> 2-bazy + rollback | 🔄 SPEC READY (2026-03-05) | `05_PLAN_SKLEP_SMS_2_BAZY.md` |
| K59 | Monitoring i alerty: DB health, callback SMS errors, duplicate txn, lag rekonsyliacji | 🔄 SPEC READY (2026-03-05) | `05_PLAN_SKLEP_SMS_2_BAZY.md` |
| K60 | Runbook operacyjny: onboarding nowego serwera/bazy i procedury awaryjne | 🔄 DRAFT READY (2026-03-05) | `05_PLAN_SKLEP_SMS_2_BAZY.md` |
| K61 | MySQL triggery sync kont `canaryaac.accounts` → `canary_modern.accounts` (AFTER INSERT/UPDATE/DELETE) + initial sync 15 brakujacych kont | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` §13 |
| K62 | Wspolne premium punkty (coins_balance) — bidirectional sync z lockiem | ⬜ TODO (przyszlosc) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` §13.4 |
| K63 | Cross-server item trading (escrow API) | ⬜ TODO (przyszlosc) | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` §13.5 |
| K64 | CanaryAAC WWW dual PDO: drugie polaczenie do `canary_modern` + mode filter w stronach | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` §13.6 |
| K65 | Deploy K44+K45 z repo (`html_copy/`) na runtime (`/var/www/html/`) + smoke test | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K66 | Selektor serwera (Classic 7.4 / Modern / All) w nawigacji WWW + persystencja w sesji | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` §13.6 |
| K67 | HTTPS canonical runtime: usunac emisje `http://127.0.0.1/*` z legacy HTML (`base href`, linki, assety) | ✅ DONE (2026-03-05) — `site_url=https://127.0.0.1`; smoke `index.php/online` bez `http://127.0.0.1` | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K68 | Deploy drift fix: zsynchronizowac runtime `/var/www/html` z repo (`html_copy`) + clear cache + smoke | 🔄 PARTIAL (2026-03-06 15:27) — dodatkowo zsynchronizowano runtime dla `routes/pages/account.php`, `reddaxe/post-login.php`, `reddaxe/i18n/{pl,en}.php`, `apik/v1/{account-sync-token.php,account-sync-consume.php}`, `system/pages/account/create.php`; smoke PASS 16/16 po aktualizacji oczekiwanego `302` dla create-account. Uwaga: `route.cache` nieusuwalny bez sudo hasla, dlatego trasa clean `/createaccount` nadal 404, ale aktywna legacy trasa `/index.php/account/create` daje poprawny redirect 302 do RedDAXE. | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K69 | Legacy menu i18n: migracja `myaac_menu` (tibiacom) z plain EN na klucze i18n/render tlumaczen | ✅ DONE (2026-03-05) — wpisy `myaac_menu` przepisane na `<span data-i18n=\"nav.*\">...` | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K70 | Legacy pages i18n: usuniecie hardcoded EN z `system/templates/*.twig` (min. `online`, `highscores`, `news`) | ✅ DONE (2026-03-07) (2026-03-06) — kolejne fixy runtime: `system/templates/{online,characters.form,highscores}.twig` + `system/pages/highscores.php`; fallback EN zastapiony locale (`__()`), filtry/etykiety topki po PL, naprawa linku `(error)` dla postaci modern (`getPlayerLink` fallback). Dokończono: characters, spells, serverinfo, experience_table, team — wszystkie przetłumaczone na PL (batch replacement). Pełna lista: 5 szablonów. | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K71 | Strategia naglowkow w obrazkach (`headline-*.gif`): per-jezyk assets albo HTML/CSS text | 🔄 PARTIAL (2026-03-06) — wdrozono dynamiczne naglowki `headline.php?t=...` dla content headline + `News Ticker` + `Featured Article`; pozostaje decyzja docelowa (pelny per-jezyk asset pack vs full HTML/CSS). | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K72 | Matryca testow i18n rozszerzona o legacy trasy `index.php/*` + raport PASS/FAIL | ⬜ TODO | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K73 | Decyzja arch: utrzymanie legacy `tibiacom` vs migracja UI na nowy frontend | ⬜ TODO | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K74 | UX anti-clipping dla `tibiacom` (100/125/150% DPI, overflow/height fixes) | 🔄 PARTIAL (2026-03-06) — pakiet CSS rozszerzony: `PlayersOnline` line-height/min-height, `Themebox` (min-height + auto), `CurrentPollText` bez twardego `overflow:hidden`, dodatkowo `boxes/templates/highscores.html.twig` (wrap + scroll + mniejsze offsety). highscores sidebar fix (usunięto outfit overlap, zmniejszono font), CSS overlay na boxy. Test wizualny pending. | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K75 | Audyt kolizji kluczy i18n w legacy Twig (przypadki typu jeden klucz dla wielu naglowkow, np. `page.section`) + normalizacja kluczy | 🔄 IN PROGRESS (2026-03-06) — online/characters.form poprawione (`online.world_information`, `online.players_online_heading`, `online.search_character`); pozostale szablony pending | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K76 | Fix flow `account/manage -> account/create`: usunac false-positive CSRF (`token is invalid`) przy zwyklym wejsciu na rejestracje | ✅ DONE (2026-03-06) — `csrfProtect()` w `account/create.php` tylko dla submitu `save=1`; przycisk `Create Account` na loginie przelaczony na `GET` | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K77 | `Tibia Rules` jako 3 dzialajace opcje (`all/classic74/modern`) + fallback global rules | ✅ DONE (2026-03-07) (2026-03-06) — dodano `system/pages/rules.php` + `rules.mode.html.twig`, tabs i fallback source (`rules`), linki z rejestracji i menu do `?subtopic=rules`; dedykowane treści `rules_classic74` (id=5) i `rules_modern` (id=7) wstawione do DB, smoke test 3 trybów PASS | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K78 | i18n konta (login/rejestracja): usunac mix EN/PL i placeholders typu `{{server}}` | ✅ DONE (2026-03-07) (2026-03-06) — poprawiono `account.create` (etykiety, JS walidacja, checkbox regulaminu), `account.login` (`Nowy na $SERVER$` bez `{{server}}`), lokalizacja komunikatu CSRF; dokończono: lost.php (69 stringów), account.management (22), login, lost.form, 11+ szablonów konta — pełne PL | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K79 | Runtime deploy hotfixow konta/rules + smoke test bez kompilacji | 🔄 PARTIAL (2026-03-06) — sync do `/var/www/html` wykonany; smoke PASS dla `/index.php/account/manage`, `/index.php/account/create`, `/index.php?subtopic=rules&mode=*`; purge cache (`route.cache`, `myaac_*`) nadal `Permission denied` | `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` |
| K80 | Plan dnia kompilacji: szczegolowy backlog i harmonogram prac 2 agentow (`P0/P1/P2`) | ✅ DONE (2026-03-06) | `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` |
| K81 | Canary 2-bazy: triggery sync `accounts` + initial sync + test konfliktow | ✅ DONE (2026-03-06) — trigger `acc_sync_ad` dodany, `acc_sync_ai/au` naprawione (ID preservation), initial sync 3 baz (canaryaac→canary→canary_modern), orphany usuniete, IDs spójne | `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` |
| K82 | Konto globalne E2E: launcher <-> RedDAXE <-> WWW + sync token one-time + replay tests | ⬜ TODO (jutro, P0) | `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` |
| K83 | SSO UX: po loginie w launcherze brak ponownego logowania przy przejsciu na WWW/instalke | 🔄 PARTIAL — CODE DONE (2026-03-06): launcher persistuje `sessionKey` po restarcie (`localStorage`), fallback do recznego loginu tylko gdy brak/blad sync tokenu; runtime E2E smoke pending | `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` |
| K84 | Tworzenie postaci per-serwer: konto globalne, postacie osobne (`classic74/modern`) | 🔄 PARTIAL — CODE DONE (2026-03-06): blokada world-select w UI launcher flow + twarda walidacja backend `mode->world` w `CreateCharacter::insertCharacter`; runtime E2E smoke pending | `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` |
| K85 | WWW/RedDAXE i18n + UX: domkniecie hardcoded EN, clipping DPI 100/125/150, rules content 3-mode | ⬜ TODO (jutro, P0/P1) | `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` |
| K86 | Runtime trasy krytyczne: usuniecie remaining 404 (`community/highscores`, `shop/payment`, flow mode) | ✅ DONE (2026-03-06) — clean URL routes dodane do `routes.php`, `route.cache` wyczyszczony, smoke: `community/*`=200, `shop/payment`→302→`/payment` (500 preexisting) | `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` |
| K87 | Gate pre-kompilacja (`G0-G7`): warunki START GHA i plan rollback | ⬜ TODO (jutro, P0) | `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` |
| K88 | Pelna kompilacja GHA: serwer + launcher + paczka gracza + walidacja artefaktow/checksum | ⬜ TODO (jutro, P0) | `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` |
| K89 | Post-build E2E: login globalny, create character 2 serwery, update launchera, start klienta | ⬜ TODO (jutro, P0/P1) | `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` |
| K90 | Instalka: kontrakt paczki gracza (`allowlist/denylist`, brak dev tools/sekretow, layout finalny) | 🔄 PARTIAL (2026-03-06 12:16) — workflow `build-client-package.yml` ma twardy top-level allowlist i denylist rozszerzen dla Windows/Linux; do domkniecia: finalna walidacja po GHA artefakcie release | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K91 | Instalka: `package lint` + security scan artefaktu paczki gracza | ✅ CODE DONE (2026-03-06 12:16) — dodano kroki `Package lint (allowlist/denylist + secret scan)` w jobach Windows i Linux + raporty `package-lint-report-*.txt`; runtime PASS oczekuje na run GHA | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K92 | Instalka: bootstrap first-run (`manifest/signature/checksum`) fail-closed | 🔄 PARTIAL — CODE DONE (2026-03-06 14:07) — launcher-tauri: first-run wykrywa bootstrap po `installed_state`, wymusza `SignaturePolicy::Require` dla manifestu, wymaga `filesHashExpected` i porownuje lokalny `compute_files_hash` z manifestem (takze dla `plan.is_up_to_date`), fail-closed na mismatch/missing | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K93 | Instalka: update atomowy + rollback + retry/resume | ⬜ TODO (jutro, P0/P1) | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K94 | Instalka: `repair mode` + `safe reset` + support bundle | ⬜ TODO (jutro, P1) | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K95 | Instalka SSO: launcher -> instalka/klient bez ponownego logowania | 🔄 PARTIAL — CODE DONE (2026-03-06) — po wyborze trybu klient auto-loguje sesja launchera (`OTC_LAUNCH_TOKEN`) i pokazuje wybor postaci bez recznego wpisywania danych; relogin tylko dla expired/invalid token/session | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K96 | Instalka gating: blokada startu gry bez postaci na wybranym serwerze | 🔄 PARTIAL — CODE DONE (2026-03-06) — fail-closed gate + twarda walidacja mode/world (`worldId`) przy liscie postaci i przy samym logowaniu; `classic74` nie polaczy `modern` ani obcych worldow | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K97 | Deep-link create-character (WWW) + powrot do launchera z zachowanym `mode` | 🔄 PARTIAL — CODE DONE (2026-03-06) — deep-link do `account/createcharacter` z `mode`, po powrocie automatyczne odswiezenie account-context i ponowna proba wejscia na poprawny tryb | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K98 | Instalka config hardening: `dev/stage/prod`, schema validation, HTTPS-only | 🔄 PARTIAL — CODE DONE (2026-03-06) — `launcher_config.rs` rozszerzony o profile `dev/stage/prod`, twarda walidacje schematu (`deny_unknown_fields`, wymagane profile, fail-closed), spojnosc endpoint path miedzy profilami i wymuszenie HTTPS poza `dev`; `ApiClient::new` zwraca `TlsRequired` dla non-HTTPS gdy `dev_mode=false` | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K99 | Matryca P0 instalki: Windows 10/11 + no-admin + polskie znaki/spacje w sciezce | ⬜ TODO (jutro, P0) | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K100 | i18n instalki/launchera w onboardingu (PL/EN, bez mixed strings) | 🔄 PARTIAL — CODE DONE (2026-03-06) — onboarding launcher nie wyswietla juz surowych mixed komunikatow backend (`PL/EN/raw`); login/rejestracja/create-character fallback mapuja znane `LCH_*` do i18n i inaczej pokazuja lokalne komunikaty generyczne PL/EN | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K101 | Linki i tresci zasad `all/classic74/modern` widoczne z flow instalki | 🔄 PARTIAL — CODE DONE (2026-03-06) — dodane przyciski zasad w launcher UI (`all/classic74/modern`) z deeplinkiem `?subtopic=rules&mode=*` i tlumaczeniami PL/EN | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K102 | Health-check endpointow krytycznych przed kompilacja (`version/manifest/login/context`) | 🔄 PARTIAL — CODE DONE (2026-03-06) — dodana komenda `health_check_critical_endpoints` (Tauri) sprawdza `launcher-version.php`, `update.php?channel=*`, `login.php`, `account-context.php`; dla endpointow auth akceptuje statusy `401/403/405/422` jako reachable | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K103 | Kompatybilnosc wersji `launcher <-> manifest <-> client` (minVersion gate) | 🔄 PARTIAL — CODE DONE (2026-03-06) — dodany gate `min_launcher_version` z manifestu: `check_for_updates`, `start_update` i `pre_launch_check` fail-closed zwracaja `LCH_LAUNCHER_UPDATE_REQUIRED` dla zbyt starego launchera; parsowanie semver w trybie relaxed (`vX.Y.Z` oraz `X.Y`) | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K104 | Blokada wielu instancji launchera + cleanup stale lock-file | 🔄 PARTIAL — CODE DONE (2026-03-06) — `launcher-tauri` tworzy `launcher.lock` (`create_new`), blokuje drugi start i czyści stale lock-file (dead PID / lock starszy niz 12h); lock usuwany automatycznie przy zamknieciu | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K105 | Anti-tamper: detekcja podmiany plikow krytycznych + kwarantanna + re-download | 🔄 PARTIAL — CODE DONE (2026-03-06) — wykryta podmiana plikow krytycznych uruchamia flow kwarantanny (`launcher_data/quarantine/critical-*`) i automatyczny redownload przez `repair_tampered_critical_files` + standardowy `start_update` pipeline | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K106 | Preflight zasobow: wolne miejsce i uprawnienia zapisu przed update/startem | 🔄 PARTIAL — CODE DONE (2026-03-06) — dodane twarde preflight checks przed `update` i `start`: test zapisu w `client_dir/launcher_data_dir` oraz kontrola wolnego miejsca (`fs2::available_space`) z fail-closed kodami `LCH_PREFLIGHT_*` | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K107 | Runbook support: top problemy instalki + gotowe scenariusze naprawcze | ✅ DONE (2026-03-06) — utworzony runbook support dla najczestszych incydentow integracji/aktualizacji instalki z procedura eskalacji i scenariuszami napraw | `18_RUNBOOK_SUPPORT_INSTALKA_TOP_PROBLEMY.md` |
| K108 | Checklista publikacji paczki gracza (release readiness) | ✅ DONE (2026-03-06) — utworzona checklista GO/NO-GO publikacji artefaktow pod auto-update launchera i klienta (hash/signature/profile/tls/rollback readiness) | `19_CHECKLISTA_PUBLIKACJI_PACZKI_GRACZA.md` |
| K109 | Checklista monitoringu pierwszych 24h po publikacji | ✅ DONE (2026-03-06) — utworzona checklista monitoringu 0-24h z progami alarmowymi i akcjami dla incydentow po publikacji | `20_CHECKLISTA_MONITORING_24H_PO_PUBLIKACJI.md` |
| K110 | Mapa kodow bledow instalatora -> instrukcje support/KB | ✅ DONE (2026-03-06) — utworzona mapa `LCH_*` + `LCH_PREFLIGHT_*`/`LCH_ANTI_TAMPER_*` z instrukcjami gracz/support i poziomami eskalacji | `21_MAPA_KODOW_BLEDOW_INSTALKI_SUPPORT_KB.md` |
| K111 | Gate przed kompilacja instalki: zamkniete `G-INS-01..07` | 🔄 PARTIAL — PREP DONE (2026-03-06 14:16) — dodany formalny szablon zamkniecia gate (`G-INS-01..07`) z dowodami PASS/FAIL/BLOCKED i decyzja pre-build `GO/NO-GO`; wykonanie runtime pozostaje na dzien kompilacji | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K112 | Gate po kompilacji instalki: zamkniete `PG-INS-01..05` | ⬜ TODO (jutro, P0/P1) | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K113 | Obowiazkowa aktualizacja dokumentacji po kazdym `INS-P0` (checklista + dziennik) | 🔄 IN PROGRESS (2026-03-06) — po kazdym batchu INS statusy i dziennik sa aktualizowane na biezaco (`K95-K104`, `K100-K101`, `K102-K104`); do domkniecia finalna weryfikacja po zamknieciu pozostalych `INS-P0` | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K114 | Harmonogram instalki 08:00-18:00 z checkpointami godzinowymi | ✅ DONE (2026-03-06 14:16) — doprecyzowany harmonogram 08:00-18:00 o checkpointy godzinowe, kryteria akceptacji i wymagane dowody dokumentacyjne | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K115 | Integracja konto globalne launcher/WWW/RedDAXE w flow instalki | 🔄 PARTIAL — CODE DONE (2026-03-06 14:25) — launcher rejestruje konto tym samym flow co WWW/RedDAXE (`type=register`, `register-account.php`) i uzywa kanonicznego email lowercase zwracanego przez API do auto-login; do domkniecia E2E runtime | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K116 | Polityka „bez lokalnej kompilacji” do czasu zamkniecia gate'ow instalki i globalnych | ✅ DONE (2026-03-06 14:16) — dopisana twarda polityka no-local-build z warunkami `START GHA` i konsekwencja `NO-GO` przy naruszeniu; zsynchronizowana w planie globalnym i planie instalki | `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` + `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K117 | Decyzja `go/no-go` dla instalki przed startem GHA (udokumentowana) | 🔄 PARTIAL — PREP DONE (2026-03-06 14:16) — dodany formalny szablon decyzji pre-build oparty o `G-INS-01..07`; finalna decyzja wymaga jutrzejszych wynikow runtime | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K118 | Decyzja `go/no-go` dla publikacji paczki gracza po buildzie | 🔄 PARTIAL — PREP DONE (2026-03-06 14:16) — dodany formalny szablon decyzji post-build oparty o `PG-INS-01..05`; finalna decyzja po wynikach GHA i smoke po buildzie | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K119 | Backlog „instalka v2 (NSIS/Inno)” po domknieciu MVP/RC | ⬜ TODO (po jutrzejszej kompilacji) | `08_PLAN_INSTALKA_JUTRO_DETALE.md` |
| K120 | Integracja launcher/API: login natywny + `sessionKey` + context serwerow | ⬜ TODO (jutro, P0) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K121 | Integracja launcher/API: rejestracja natywna konta globalnego | 🔄 PARTIAL — CODE DONE (2026-03-06 14:25) — `launcher-api` wysyla teraz rejestracje jako `type=register` (jak RedDAXE/WWW) do `register-account.php`; launcher korzysta z kanonicznego email z odpowiedzi API | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K122 | Integracja launcher: wymuszony wybor serwera dla `gameMode=all` | ⬜ TODO (jutro, P0) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K123 | Integracja launcher: blokada „Graj” bez postaci na wybranym serwerze | ⬜ TODO (jutro, P0) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K124 | Integracja launcher->WWW: deep-link `Utworz postac` z `mode` i powrotem do launchera | ⬜ TODO (jutro, P0) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K125 | Integracja launcher->WWW: brak ponownego logowania po przejsciu (SSO) | ⬜ TODO (jutro, P0) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K126 | Integracja launcher/API: expired token fallback (retry + czytelny komunikat) | ⬜ TODO (jutro, P1) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K127 | Integracja launcher/API: kompatybilnosc wersji launcher/manifest/API | ⬜ TODO (jutro, P1) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K128 | Integracja launcher: i18n smoke PL/EN bez brakujacych kluczy krytycznych | ⬜ TODO (jutro, P1) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K129 | Integracja launcher: checklista regresji na czystym Windows | ⬜ TODO (jutro, P2) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K130 | Integracja API/WWW: token sync one-time + TTL + replay reject | 🔄 PARTIAL — CODE DONE (2026-03-06 14:34) — launcher dodal twardy refresh kontekstu po powrocie z flow sync-token (`refresh_launcher_account_context` -> `account-context.php`), a API `account-sync-consume.php` dostalo dodatkowa walidacje `source` (`source_mismatch`) i `account-sync-token.php` deterministyczny cleanup zuzytych/wygaslych tokenow; finalne domkniecie po runtime E2E token replay | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K131 | Integracja WWW->launcher: konto utworzone na WWW loguje sie w launcherze | 🔄 PARTIAL — CODE DONE (2026-03-06 14:48) — launcher odswieza sesje po powrocie z WWW bez recznego reloginu; komunikaty launchera nie pokazuja juz liczby postaci (brak podgladu postaci w launcher UI) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K132 | Integracja launcher->WWW: konto utworzone w launcherze tworzy postac na WWW | 🔄 PARTIAL — CODE DONE (2026-03-06 14:48) — postacie pozostaja tworzone na `/account/createcharacter` (WWW Tibia), a launcher domyka petle powrotu sesji bez ujawniania listy/licznikow postaci | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K133 | Integracja RedDAXE: to samo konto globalne dziala na RedDAXE/WWW/launcher | ✅ RUNTIME PASS (2026-03-06 15:27) — runtime sync wdrozony; aktywna trasa rejestracji WWW `/index.php/account/create` (GET/POST) przekierowuje `302` do `/reddaxe/account-create.php?source=tibiawww`; RedDAXE/launcher nadal bez list postaci | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K134 | Integracja WWW: create-character trafia do poprawnego serwera/bazy | ✅ RUNTIME PASS (2026-03-06 18:46) — E2E `run/k134_e2e_www.sh`: register+login WWW+create-character (classic/modern) PASS; dowod DB `players.world`: `Kclassic...=0`, `Kmodern...=1`; sciezki kompatybilnosci `/account/createcharacter` i `/index.php/account/createcharacter` -> `302` -> `/account/character/create` (`200`) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K135 | Integracja WWW: topki/listy/online poprawnie dla `all/classic74/modern` | ✅ RUNTIME PASS (2026-03-06 19:05) — root-cause naprawiony: `players-list.php` ignorowal `mode` (czytal tylko `gameMode`), przez co `mode=classic74/modern` zwracal dane `all`; po fixie (`mode` + backward-compatible `gameMode`) runtime zwraca poprawny split: `all=17`, `classic74=7` (`worldId=0`), `modern=10` (`worldId=1`), `onlineOnly=1` zwraca poprawne `mode`; `toplist.php` split utrzymany (`all=17`, `classic74=7`, `modern=10`), `index.php/online?mode=*` = `200` | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K136 | Integracja WWW: usuniecie krytycznych 404 (`community/highscores`, `shop/payment`) | ✅ RUNTIME PASS (2026-03-06 18:10) — `community/highscores` = `200`; `shop/payment` = `302` -> `/payment`; `/payment` = `302` -> `/account/login` (brak 404) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K137 | Integracja WWW: rules 3-mode (`all/classic74/modern`) podpięte do flow konta | 🔄 PARTIAL — CODE DONE (2026-03-06 19:25): w aktywnym szablonie tworzenia postaci (`system/templates/account.characters.create.html.twig`) dodane mode-aware linki `rules` (`?subtopic=rules&mode=all|classic74|modern`) + dynamiczny link wg wybranego trybu; runtime smoke tras `rules?mode=*` = `200`; do domkniecia: walidacja end-to-end na zalogowanej sesji konta (formularz create-character) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K138 | Integracja WWW/RedDAXE: i18n krytycznych ekranow bez mix EN/PL | ⬜ TODO (jutro, P1) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K139 | Integracja WWW/RedDAXE: anti-clipping i test DPI 100/125/150 | ⬜ TODO (jutro, P1) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K140 | Integracja Canary/DB: triggery sync kont i initial sync bez konfliktow | ⬜ TODO (jutro, P0) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K141 | Integracja Canary: ticket flow blokuje mismatch postac/swiat | ⬜ TODO (jutro, P0) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K142 | Integracja Canary: mapowanie `worldId/gameMode` spójne end-to-end | ⬜ TODO (jutro, P0) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K143 | Integracja Canary: monitoring DB health i lag sync | ⬜ TODO (jutro, P1) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K144 | Integracja Canary: fallback/degraded mode przy odpieciu modern | ⬜ TODO (jutro, P1) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K145 | Integracja Canary: SQL snapshot + restore drill | ⬜ TODO (jutro, P2) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K146 | Matryca integracyjna `T-INT-01..12`: pelne PASS/FAIL/BLOCKED z wpisami | ⬜ TODO (jutro, P0) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K147 | Gate integracyjny `G-INT-01..07` zamkniety przed `START GHA` | ⬜ TODO (jutro, P0) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K148 | Decyzja `go/no-go` integracji (udokumentowana) przed kompilacja | ⬜ TODO (jutro, P0) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K149 | Plan hotfix po integracji (24h po kompilacji) | ⬜ TODO (jutro, P1/P2) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K150 | WWW: info o serwerze na stronie postaci (Classic 7.4 / Modern) — postać nie może istnieć na obu serwerach jednocześnie | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K151 | WWW: Highscores — głowa/avatar postaci + flaga kraju przy każdym graczu w rankingu | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K152 | WWW: Wybór obywatelstwa/narodowości przy kreacji postaci (nationality) | ⬜ TODO | `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` |
| K153 | Runtime prep test: RedDAXE -> WWW (konto globalne + 2 postacie + widocznosc) | ✅ RUNTIME PASS (2026-03-06 19:19) — nowy skrypt `run/k153_e2e_reddaxe_global.sh`: konto utworzone przez formularz RedDAXE, login RedDAXE (`post-login`) PASS, create-character `classic74`+`modern` PASS, widocznosc obu postaci na `/account/manage` PASS, DB verify `players.world`: classic=0, modern=1 | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K154 | Runtime E2E: system przełączania profilu konta globalnego (WWW + API/launcher) | ✅ RUNTIME PASS (2026-03-06) — dodano helper sesji `global_profile_mode`, endpoint WWW `/account/profile-switch`, endpoint API `/apik/v1/account-profile-switch.php`, oraz skrypt `run/k154_e2e_global_profile_switch.sh` (PASS: WWW switch classic/modern + sync WWW->launcher + `account-context` zwraca `gameMode=modern`) | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K155 | UI/UX: dopasowanie wygladu pod system konta globalnego (widocznosc trybu + profilu) | ✅ RUNTIME DEPLOYED (2026-03-06) — przebudowany pasek wyboru serwera na layout `tibiacom` (styl + kontekstowe linki z zachowaniem URL), dodany hint aktywnego profilu konta globalnego oraz szybkie pozycje `Global Profile` w menu `Account`; doszlifowane przyciski switchera w `account/manage` | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K156 | UI fix: pojedynczy sidebar logowania + domyslnie zwiniete kategorie + social bar (Twitch/YouTube/Fankit) | ✅ RUNTIME DEPLOYED (2026-03-06) — usuniety dodatkowy box global-account z lewej kolumny (zostaje jeden login sidebar), wylaczona persystencja rozwijania menu (kazdy refresh startuje ze zwinietymi kategoriami), dodany gorny pasek social nad contentem | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K157 | WWW community fallback: `online/highscores` domyslnie respektuja aktywny profil globalny (`global_profile_mode`) | ✅ RUNTIME DEPLOYED (2026-03-06) — gdy brak `mode` w URL, `online.php` i `highscores.php` biora najpierw `global_profile_mode` (`classic74/modern`) zamiast starego fallbacku; dla zalogowanych synchronizowane sa sesje `server_mode` i `global_profile_mode` | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K158 | Hotfix clean-account routing: `/account*` fallback + stabilne menu init bez crasha na 404 | ✅ RUNTIME DEPLOYED (2026-03-06) — dodano fallback redirects dla `/account`, `/index.php/account/manage/login/logout/create` do dzialajacych URL (`?subtopic=accountmanagement` / `reddaxe/account-create.php`), plus null-check w `LoadMenu()` dla brakujacych `submenu_*`, co usuwa efekt "wszystko rozwiniete" na stronach bledow | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K159 | UI polish sidebar: `Loginbox` kolorystycznie spojny i lepiej spasowany z `Menu` | ✅ RUNTIME DEPLOYED (2026-03-06) — korekty CSS (`Loginbox` spacing, fallback bg `#0d2e2b`, dosuniecie `MenuTop/Menu`) poprawiaja laczenie blokow i stabilnosc kolorow | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K160 | UI + status panel: czytelny `Loginbox`, fallback tekstow i rozwijany status `API + Classic 7.4 + Modern` z licznikami | ✅ RUNTIME DEPLOYED (2026-03-06) — przebudowa `PlayersOnline` na global+per-serwer (z DB online count + fallback), i18n klucze PL/EN, usuniecie efektu czarnych paskow pod loginem i poprawa widocznosci `Utwórz konto` | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K161 | Hard fix `Loginbox`: usuniecie grafik-fontow i czarnych pol, powrot do stabilnej geometrii | ✅ RUNTIME DEPLOYED (2026-03-06) — `LoadLoginBox` przestaje ustawac obrazkowe napisy dla statusow, inline tla `loginbox-textfield-background` usuniete, CSS przywraca klasyczne proporcje login/menu i wymusza tekstowy fallback etykiet | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K162 | Replace sidebar `Zaloguj`: nowy komponent i18n + mechanizmy konta globalnego | 🔄 REWORK REQUIRED (2026-03-06) — funkcjonalnie dziala, ale wizualnie nie pasuje do stylu tibiacom (kolizje z paskiem nawigacji, odstepy/ramki); wymagany redesign z zachowaniem oryginalnych grafik obramowan i geometrii | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K163 | Sidebar `Zaloguj` v3: zachowac styl tibiacom (fonty + grafiki ramek), ale napisy jako tekst i18n (nie obrazki) | 🔄 IN PROGRESS (2026-03-06) — etap 2: anti-overlap sidebar/menu przez pseudo-cap (`box-top/box-bottom`) i usuniecie konfliktowych override `transform:scale`; pozostaje finalny visual pass PL/EN | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K164 | Geometria sidebar/menu: pomiar koncowek grafik (nie tekstu), anti-overlap i staly grid offsetow | ✅ RUNTIME DEPLOYED (2026-03-06) — zmienne geometrii (`:root`) wdrozone i podlaczone do `#Loginbox/#Menu/#MenuTop/#MenuBottom/.MenuButton`; frame sidebaru oparty o oryginalne grafiki `box-top/box-bottom/chain`; standard procesu: `22_STANDARD_WPROWADZANIA_ZMIAN_TIBI_UI.md` | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K165 | i18n obrazkow menu (`spolecznosc`, `forum`, itp.): per-jezyk asset pipeline + fallback | ⬜ TODO | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K166 | Highscores UI fix: lewy padding i clipping labeli przy obramowce (start od tego ekranu) | 🔄 PARTIAL (2026-03-06) — `system/templates/highscores.html.twig`: dodany `HighscoresMainCol` + dodatkowy inset/padding; `basic.css`: guard na left-edge clipping dla tabel highscores; finalny tuning po screenshot review | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K167 | Status serwera v2: global + per-world z konfiguracji listy serwerow (latwe dodawanie nowych) + pelne i18n | ⬜ TODO | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |
| K168 | QA layout guardrails: checklista pomiaru grafiki, screenshoty PL/EN, DPI 100/125/150, before/after diff | 🔄 PARTIAL (2026-03-06) — standard procesu dodany: `22_STANDARD_WPROWADZANIA_ZMIAN_TIBI_UI.md`; wykonanie pelnej matrycy screenshot diff pozostaje do runtime QA | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` |

**Legenda**: ⬜ TODO | 🔄 W TRAKCIE | ✅ DONE | ❌ FAIL (wymaga fix)

---

## Cel

Ten plik definiuje prosty proces, żeby:
1. było wiadomo co zrobiliśmy, kiedy i po co,
2. łatwo znaleźć źródło błędu po kompilacji lub testach,
3. szybko odtworzyć historię zmian w plikach.

## Reguły Pracy

1. Każdy blok pracy zapisujemy w `01_DZIENNIK_PRAC.md`.
2. Każdy run GitHub Actions zapisujemy w `02_DZIENNIK_BUILDOW_GHA.md`.
3. Każdy wpis musi zawierać:
- datę i godzinę (CET/CEST),
- zakres zadania (np. `A3`, `B3`, `X2`),
- listę plików zmienionych,
- listę nowych plików,
- wynik i decyzję co dalej.
4. Przy błędzie kompilacji zapisujemy:
- nazwę joba,
- pierwszy realny błąd (pierwszy fail, nie lawina kolejnych),
- poprawkę i commit, który naprawił.
5. Małe, częste commity:
- jeden commit = jeden logiczny krok,
- wiadomość commita z prefiksem zadania, np. `A3: wybór trybu gry w entergame`.

## Minimalny Workflow na Każdy Krok

1. Dopisz wpis "START" w `01_DZIENNIK_PRAC.md`.
2. Zrób zmianę w kodzie.
3. Dopisz wpis "KONIEC" z plikami i wynikiem.
4. Zrób commit.
5. Uruchom GitHub Actions.
6. Dopisz wynik runa w `02_DZIENNIK_BUILDOW_GHA.md`.

## Definicja "gotowe"

Zadanie uznajemy za gotowe tylko gdy:
1. kod jest w repo,
2. wpis w dzienniku prac istnieje,
3. build GHA dla commita jest zapisany,
4. przy failu jest wpis z diagnozą i poprawką.

---

## Sumaryczna lista zmodyfikowanych plików (stan na 2026-03-05)

### OTClient — `canary_test/testyy/` (11 plików, 3 C++)
| Plik | Fazy | C++? |
|------|------|------|
| `init.lua` | A1, A-FIX, FIX16, **FIX25** | NIE |
| `modules/client_entergame/entergame.lua` | A2, A3, A5, A-FIX, B5, FIX4, FIX6, FIX8, FIX18, FIX22, FIX27, FIX28, FIX30, **FIX-W1**, **FIX50**, **FIX55**, **FIX63**, **FIX64** | NIE |
| `modules/client_entergame/entergame.otui` | A2 | NIE |
| `modules/client_entergame/characterlist.lua` | B5, **FIX54** | NIE |
| `modules/client_serverlist/serverlist.lua` | A4, A-FIX, FIX8, FIX14 | NIE |
| `modules/game_hotkeys/hotkeys_manager.lua` | A6 | NIE |
| `src/framework/net/httplogin.cpp` | X2, X2b, X7, B6, FIX4, E10, FIX18, FIX35, FIX38, FIX44/CPP-4, **FIX-C2**, **FIX56** | **TAK** |
| `src/framework/net/httplogin.h` | B6, FIX4, E10, FIX18, FIX44/CPP-4 | **TAK** |
| `src/framework/luafunctions.cpp` | B6, E10, FIX18 | **TAK** |
| `cacert.pem` | **FIX46** | NIE | ✅ NOWY |

### Canary Server — `canary_test/src/` (10 plików, 8 C++, 2 nowe)

> **UWAGA**: Pliki C++ serwera zostały sportowane z `canary/` do `canary_test/` w commicie `98964825b`.
> GHA workflow `build-canary.yml` kompiluje z `canary_test/`, więc TYLKO ten katalog jest budowany.

| Plik | Fazy | C++? | Nowy? |
|------|------|------|-------|
| `src/server/network/protocol/ticket_validator.hpp` | C1, FIX10, FIX23 | **TAK** | ✅ NOWY |
| `src/server/network/protocol/ticket_validator.cpp` | C1, FIX5, FIX10, FIX13, FIX19, FIX23 | **TAK** | ✅ NOWY |
| `src/server/network/protocol/protocolgame.cpp` | C2, D1, D2-D10, FIX1, FIX3, FIX9, FIX10, FIX15 | **TAK** | |
| `src/server/network/protocol/protocolgame.hpp` | D1 | **TAK** | |
| `src/server/CMakeLists.txt` | FIX2 | NIE | |
| `src/config/config_enums.hpp` | C3 | **TAK** | |
| `src/config/configmanager.cpp` | C3 | **TAK** | |
| `src/creatures/creatures_definitions.hpp` | D1 | **TAK** | |
| `src/creatures/players/player.hpp` | D1, D8 | **TAK** | |
| `src/game/game.cpp` | D8, FIX7 | **TAK** | |

### Konfiguracja (3 pliki)
| Plik | Fazy |
|------|------|
| `canary_test/config.lua.dist` | C4 |
| `canary_test/config.lua` | C4, **FIX-C1** |
| `canary_test/.gitignore` | **FIX34**, Audyt#5 (ssl/) |

### PHP / MySQL — `canary_test/html_copy/apik/v1/` (21 plików, 19 nowych)
| Plik | Fazy | Nowy? |
|------|------|-------|
| `common.php` | FIX42 | ✅ NOWY |
| `.env.example` | FIX34, **FIX49** | ✅ NOWY |
| `login.php` | B1, B2, E11, FIX11, FIX26, FIX29, FIX39, FIX42, **FIX52**, **FIX59**, K1 | |
| `ticket.php` | B3, FIX13, FIX20, FIX42, **FIX53**, **FIX57**, **FIX58**, K4 | ✅ NOWY |
| `schema_ticket_gate.sql` | B4 | ✅ NOWY |
| `schema_launcher.sql` | E5 | ✅ NOWY |
| `generate_manifest.php` | E1, FIX42 | ✅ NOWY |
| `update.php` | E2, **FIX62** | ✅ NOWY |
| `launcher-token.php` | E3, FIX12, FIX21, FIX42, FIX43 | ✅ NOWY |
| `launcher-version.php` | E4, FIX42 | ✅ NOWY |
| `register-account.php` | K5 | ✅ NOWY |
| `account-context.php` | K6 | ✅ NOWY |
| `toplist.php` | K7 | ✅ NOWY |
| `players-list.php` | K8 | ✅ NOWY |
| `account-sync-token.php` | K12 | ✅ NOWY |
| `account-sync-consume.php` | K12, K13 | ✅ NOWY |
| `account-sync-www-login.php` | K13, K14 | ✅ NOWY |
| `account-sync-www-token.php` | K14 | ✅ NOWY |
| `oauth-start.php` | K15, K16 | ✅ NOWY |
| `oauth-callback.php` | K15, K16 | ✅ NOWY |
| `server-status.php` | K2 | ✅ NOWY |
| `challenge.php` | E3 | ✅ NOWY |
| `.env` | B4, E5, E11, FIX24, **FIX49**, K16 (nie w repo) | |

### Migracje — `canary_test/html_copy/apik/v1/migrations/` (13 plików, nowe)
| Plik | Fazy | Nowy? |
|------|------|-------|
| `migrate.php` | K11 | ✅ NOWY |
| `001_ticket_gate_rollout.sql` | B4 | ✅ NOWY |
| `001_ticket_gate_rollback.sql` | B4 | ✅ NOWY |
| `002_launcher_tables_rollout.sql` | E5 | ✅ NOWY |
| `002_launcher_tables_rollback.sql` | E5 | ✅ NOWY |
| `003_cleanup_events_rollout.sql` | K11 | ✅ NOWY |
| `003_cleanup_events_rollback.sql` | K11 | ✅ NOWY |
| `004_identity_social_rollout.sql` | K11 | ✅ NOWY |
| `004_identity_social_rollback.sql` | K11 | ✅ NOWY |
| `005_oauth_rate_limit_rollout.sql` | K16 | ✅ NOWY |
| `005_oauth_rate_limit_rollback.sql` | K16 | ✅ NOWY |
| `006_unique_email_rollout.sql` | Luka #6 | ✅ NOWY |
| `006_unique_email_rollback.sql` | Luka #6 | ✅ NOWY |

### Launcher Python — `canary_test/launcher/` (5 plików, 5 nowych)
| Plik | Fazy | Nowy? |
|------|------|-------|
| `launcher.py` | E6-E8, **FIX51**, **FIX60** | ✅ NOWY |
| `launcher_config.json` | E6, **FIX32** | ✅ NOWY |
| `requirements.txt` | E6 | ✅ NOWY |
| `build_launcher.bat` | E12, FIX17 | ✅ NOWY |
| `build_launcher.sh` | E12 | ✅ NOWY |

### Launcher HTML — `canary_test/html_copy/` (1 plik)
| Plik | Fazy | Nowy? |
|------|------|-------|
| `launcher_config.json` | **FIX31** | |

### Deployment — `canary_test/` (1 plik, nowy)
| Plik | Fazy | Nowy? |
|------|------|-------|
| `deploy_api.sh` | **FIX47**, **FIX33** | ✅ NOWY |

### Launcher Rust — `launcher-rust/` (32+ plików)
Szczegóły w `2026-03-03_launcher_sprint*.md` i `2026-03-05_PLAN_PRZED_KOMPILACJA.md`.
Główne moduły: launcher-cli, launcher-tauri (UI), wspólna logika (commands, dto, language packs, self-update, channel/signature).
Commity: `6421c9631` (A-1 do A-9), + poprawki CI: `8fbe846d4` (cargo fmt + usunięcie .cargo/config.toml).

### Dokumentacja aktywna (11 plikow)
| Plik | Aktualizowane na bieżąco |
|------|--------------------------|
| `Dokumentacja/01_Instalka_Klient/2026-03/00_START_PRACY_CHECKLISTA.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/01_DZIENNIK_PRAC.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/02_DZIENNIK_BUILDOW_GHA.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/03_PLAN_WSPOLNE_KONTO_2_SERWERY.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/04_PLAN_PORTAL_REDDAXE_PREKOMPILACJA.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/05_PLAN_SKLEP_SMS_2_BAZY.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/08_PLAN_INSTALKA_JUTRO_DETALE.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/10_AUDYT_DOKUMENTACJI_I_BRAKOW_2026-03-06.md` | ✅ |

**RAZEM: 70+ plikow** (11 C++, 6 Lua, 1 OTUI, 3 config, 10+ dokumentacja aktywna, 23 PHP/SQL, 11 migracji SQL, 5 launcher Python, 2 launcher config, 1 deploy script, 1 cacert, 3 SSL [gitignored])
**Niezacommitowane**: pliki Fazy K dodane do repo, ale PUSH WSTRZYMANY (czeka na zakończenie wszystkich zadań)
**Commity na branchu**: `72681f84c` (A1), `b216fe683` (A2-A5), `d0e121d77` (docs), `7957e93f5` (Fazy A-E + FIX1-17 + X1-X8 + CR1-4), `9bbd23f4e` (CR#3 docs), `3090e02e9` (FIX18-23), **`98964825b` (port C++ do canary_test/ + FIX24-65 + API + OTClient + Launcher)**, + commity Fazy K (launcher-rust + PHP endpoints)

### Infrastruktura (poza git — wymagana ręczna konfiguracja na nowym serwerze)
| Element | Opis | Audyt |
|---------|------|-------|
| nginx SSL | `/etc/nginx/ssl/server.crt` + `server.key`, port 443 z HTTP→HTTPS redirect | FIX45 |
| nginx configs | `/etc/nginx/sites-enabled/myaac.conf` + `127.local.conf` | FIX45 |
| PHP deploy | `/var/www/html/apik/v1/` — sync via `deploy_api.sh` | FIX47, FIX48 |
| MySQL tables | `ticket_sessions`, `ticket_nonces`, `launch_tokens`, `manifest_versions`, `account_identity_links`, `oauth_states`, `account_sync_tokens`, `oauth_rate_limits`, `_migrations`, `canary_payments.world_id/game_mode` (po rollout 007) | B4, E5, K11, K16, K45 |
**Stan na 2026-03-08**: Fazy A-E ✅ DONE, Faza K — endpointy deployed na runtime, testy E2E PASS (K1,K5-K8,K12-K14), migracje 001-005 APPLIED; K42 🔄 REOPEN (legacy `index.php/*` + `tibiacom` nadal EN/hardcoded, audyt `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md`), K43 E2E matrix 23/23 PASS dla nowego scope; K44/K45 🟢 CODE DONE (deploy pending); **Opcja B (2 bazy) zatwierdzona** — K61-K66 dodane (§13 w 03_PLAN), a nowy tor pre-release to K47-K60 (separacja DB + agregacja WWW + sklep SMS) + K67-K74 (runtime legacy UI/i18n fix); K15 social wymaga secrets; K19 natywny login TODO; plan dnia kompilacji rozszerzony o tor instalatora (`K80-K119`, pliki `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` + `08_PLAN_INSTALKA_JUTRO_DETALE.md`), tor integracyjny launcher+WWW+Canary (`K120-K149`, plik `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md`) oraz audyt brakow dokumentacji (`10_AUDYT_DOKUMENTACJI_I_BRAKOW_2026-03-06.md`).
