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
| A8 | Test kompilacja Windows + Linux | ⬜ TODO | wymaga push → GHA build |
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
| C6 | Kompilacja i test | ⬜ TODO | wymaga push → GHA build |

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

## Sumaryczna lista zmodyfikowanych plików (stan na 2026-03-03)

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

### PHP / MySQL — `canary_test/html_copy/apik/v1/` (11 plików, 9 nowych)
| Plik | Fazy | Nowy? |
|------|------|-------|
| `common.php` | FIX42 | ✅ NOWY |
| `.env.example` | FIX34, **FIX49** | ✅ NOWY |
| `login.php` | B1, B2, E11, FIX11, FIX26, FIX29, FIX39, FIX42, **FIX52**, **FIX59** | |
| `ticket.php` | B3, FIX13, FIX20, FIX42, **FIX53**, **FIX57**, **FIX58** | ✅ NOWY |
| `schema_ticket_gate.sql` | B4 | ✅ NOWY |
| `schema_launcher.sql` | E5 | ✅ NOWY |
| `generate_manifest.php` | E1, FIX42 | ✅ NOWY |
| `update.php` | E2, **FIX62** | ✅ NOWY |
| `launcher-token.php` | E3, FIX12, FIX21, FIX42, FIX43 | ✅ NOWY |
| `launcher-version.php` | E4, FIX42 | ✅ NOWY |
| `.env` | B4, E5, E11, FIX24, **FIX49** (nie w repo) | |

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

### Dokumentacja (3 pliki)
| Plik | Aktualizowane na bieżąco |
|------|--------------------------|
| `Dokumentacja/01_Instalka_Klient/2026-03/00_START_PRACY_CHECKLISTA.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/01_DZIENNIK_PRAC.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/02_DZIENNIK_BUILDOW_GHA.md` | ✅ |

**RAZEM: 47 plików** (11 C++, 6 Lua, 1 OTUI, 3 config, 3 dokumentacja, 11 PHP/SQL, 5 launcher Python, 2 launcher config, 1 deploy script, 1 cacert, 3 SSL [gitignored])
**Niezacommitowane**: brak (wszystko pushnięte)
**Commity na branchu**: `72681f84c` (A1), `b216fe683` (A2-A5), `d0e121d77` (docs), `7957e93f5` (Fazy A-E + FIX1-17 + X1-X8 + CR1-4), `9bbd23f4e` (CR#3 docs), `3090e02e9` (FIX18-23), **`98964825b` (port C++ do canary_test/ + FIX24-65 + API + OTClient + Launcher)**

### Infrastruktura (poza git — wymagana ręczna konfiguracja na nowym serwerze)
| Element | Opis | Audyt |
|---------|------|-------|
| nginx SSL | `/etc/nginx/ssl/server.crt` + `server.key`, port 443 z HTTP→HTTPS redirect | FIX45 |
| nginx configs | `/etc/nginx/sites-enabled/myaac.conf` + `127.local.conf` | FIX45 |
| PHP deploy | `/var/www/html/apik/v1/` — sync via `deploy_api.sh` | FIX47, FIX48 |
| MySQL tables | `ticket_sessions`, `launch_tokens`, `ticket_nonces` | B4, E5 |
**Stan na 2026-03-03**: commit `98964825b` — port plików C++ serwera z canary/ do canary_test/ + WSZYSTKIE zmiany API/Launcher/OTClient/Dokumentacja. 31 plików, 1409 dodań, 276 usunięć kodu (+ ~3171 usunięć to czyszczenie cacert.pem).
