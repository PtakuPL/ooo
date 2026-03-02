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
| A6 | Feature flags: blokada hotkey runes | ✅ DONE | niezacommitowane |
| A7 | Feature flags: ukrycie modułów (market, itp.) | ❌ N/A | wycofane — blokady od serwera (Faza D) |
| A8 | Test kompilacja Windows + Linux | ⬜ TODO | — |
| A-FIX | Codex review: port 443, ServerList lock, setLoginFormVisible, placeholder walidacja | ✅ DONE | niezacommitowane |

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
| X2 | Hard-fail TLS w kliencie (`httplogin.cpp:211`) | ✅ DONE | niezacommitowane | KRYTYCZNY |
| X2b | Usunięcie HTTP fallback (`httplogin.cpp:108` + Emscripten) | ✅ DONE | niezacommitowane | KRYTYCZNY |
| X3 | Fix ServerList bypass | ✅ DONE (A-FIX) | niezacommitowane | — |
| X7 | Usunięcie logów haseł (Logger: req.body + res.body) | ✅ DONE | niezacommitowane | NISKI |

### Faza B — API HTTP ticket-gate
| # | Zadanie | Status | Commit |
|---|---------|--------|--------|
| B1 | `gameMode` + `launchToken` w login.php | ✅ DONE | niezacommitowane |
| B2 | Filtrowanie worldów wg gameMode | ✅ DONE | niezacommitowane |
| B3 | Nowy endpoint `ticket.php` | ✅ DONE | niezacommitowane |
| B4 | Tabela `ticket_nonces` + `ticket_sessions` MySQL | ✅ DONE | niezacommitowane |
| B5 | Klient Lua: request do ticket.php | ✅ DONE | niezacommitowane |
| B6 | Klient C++: `requestTicket()` | ✅ DONE | niezacommitowane |
| B7 | Test flow login→ticket→connect | ✅ DONE | smoke test CLI |

### Faza C — Serwer Canary ticket-gate
| # | Zadanie | Status | Commit |
|---|---------|--------|--------|
| C1 | `ticket_validator.cpp/.h` | ✅ DONE | niezacommitowane |
| C2 | Integracja z `protocolgame.cpp` | ✅ DONE | niezacommitowane |
| C3 | Klucze w `configmanager.cpp` + `config_enums.hpp` | ✅ DONE | niezacommitowane |
| C4 | Konfiguracja `config.lua` / `config.lua.dist` | ✅ DONE | niezacommitowane |
| C5 | Nonce store | ✅ DONE (in-memory w ticket_validator) | niezacommitowane |
| C6 | Kompilacja i test | ⬜ TODO | — |

### Faza D — Feature flags serwer Canary
| # | Zadanie | Status | Commit |
|---|---------|--------|--------|
| D1 | `GameMode` enum + pole w `Player` | ✅ DONE | niezacommitowane |
| D2 | Blokada rune-on-creature hotkey | ✅ DONE | niezacommitowane |
| D3 | Blokada Quick Loot / Auto Loot | ✅ DONE | niezacommitowane |
| D4 | Blokada Market (5 metod) | ✅ DONE | niezacommitowane |
| D5 | Blokada Prey System | ✅ DONE | niezacommitowane |
| D6 | Blokada Wheel of Destiny | ✅ DONE | niezacommitowane |
| D7 | Blokada Smart Equip | ✅ DONE | niezacommitowane |
| D8 | Rate-limit run 1000ms | ✅ DONE | niezacommitowane |
| D9 | Blokada Action Bar packets | ❌ N/A | brak w codebase |
| D10 | Blokada Bestiary | ✅ DONE | niezacommitowane |
| D11 | Test integracyjny | ⬜ TODO | — |

### Faza E — Launcher z auto-update ✅ GOTOWE
| # | Zadanie | Status | Commit |
|---|---------|--------|--------|
| E1 | Skrypt `generate_manifest.php` | ✅ DONE | niezacommitowane |
| E2 | Endpoint `update.php` | ✅ DONE | niezacommitowane |
| E3 | Endpoint `launcher-token.php` | ✅ DONE | niezacommitowane |
| E4 | Endpoint `launcher-version.php` | ✅ DONE | niezacommitowane |
| E5 | Tabela `launch_tokens` + `manifest_versions` MySQL | ✅ DONE | niezacommitowane |
| E6-E8 | Launcher Python (GUI + pobieranie + token) | ✅ DONE | niezacommitowane |
| E9 | Launcher self-update | ✅ DONE | niezacommitowane |
| E10 | Klient: `OTC_LAUNCH_TOKEN` env + C++ + Lua | ✅ DONE | niezacommitowane |
| E11 | API `login.php`: walidacja `launchToken` | ✅ DONE | niezacommitowane |
| E12 | Smoke test flow | ✅ DONE | niezacommitowane |
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

## Sumaryczna lista zmodyfikowanych plików (stan na 2026-03-02)

### OTClient — `canary_test/testyy/` (9 plików, 3 C++)
| Plik | Fazy | C++? |
|------|------|------|
| `init.lua` | A1, A-FIX, FIX16 | NIE |
| `modules/client_entergame/entergame.lua` | A2, A3, A5, A-FIX, B5, FIX4, FIX6, FIX8 | NIE |
| `modules/client_entergame/entergame.otui` | A2 | NIE |
| `modules/client_entergame/characterlist.lua` | B5 | NIE |
| `modules/client_serverlist/serverlist.lua` | A4, A-FIX, FIX8, FIX14 | NIE |
| `modules/game_hotkeys/hotkeys_manager.lua` | A6 | NIE |
| `src/framework/net/httplogin.cpp` | X2, X2b, X7, B6, FIX4, E10 | **TAK** |
| `src/framework/net/httplogin.h` | B6, FIX4, E10 | **TAK** |
| `src/framework/luafunctions.cpp` | B6, E10 | **TAK** |

### Canary Server — `canary/` (10 plików, 8 C++, 2 nowe)
| Plik | Fazy | C++? | Nowy? |
|------|------|------|-------|
| `src/server/network/protocol/ticket_validator.hpp` | C1, FIX10 | **TAK** | ✅ NOWY |
| `src/server/network/protocol/ticket_validator.cpp` | C1, FIX5, FIX10, FIX13 | **TAK** | ✅ NOWY |
| `src/server/network/protocol/protocolgame.cpp` | C2, D1, D2-D10, FIX1, FIX3, FIX9, FIX10, FIX15 | **TAK** | |
| `src/server/network/protocol/protocolgame.hpp` | D1 | **TAK** | |
| `src/server/CMakeLists.txt` | FIX2 | NIE | |
| `src/config/config_enums.hpp` | C3 | **TAK** | |
| `src/config/configmanager.cpp` | C3 | **TAK** | |
| `src/creatures/creatures_definitions.hpp` | D1 | **TAK** | |
| `src/creatures/players/player.hpp` | D1, D8 | **TAK** | |
| `src/game/game.cpp` | D8, FIX7 | **TAK** | |

### Konfiguracja (2 pliki)
| Plik | Fazy |
|------|------|
| `canary/config.lua.dist` | C4 |
| `canary_test/config.lua` | C4 |

### PHP / MySQL — `canary_test/html_copy/apik/v1/` (9 plików, 7 nowych)
| Plik | Fazy | Nowy? |
|------|------|-------|
| `login.php` | B1, B2, E11, FIX11 | |
| `ticket.php` | B3, FIX13 | ✅ NOWY |
| `schema_ticket_gate.sql` | B4 | ✅ NOWY |
| `schema_launcher.sql` | E5 | ✅ NOWY |
| `generate_manifest.php` | E1 | ✅ NOWY |
| `update.php` | E2 | ✅ NOWY |
| `launcher-token.php` | E3, FIX12 | ✅ NOWY |
| `launcher-version.php` | E4 | ✅ NOWY |
| `.env` | B4, E5, E11 (CLIENT_LOCKED) | |

### Launcher Python — `canary_test/launcher/` (5 plików, 5 nowych)
| Plik | Fazy | Nowy? |
|------|------|-------|
| `launcher.py` | E6-E8 | ✅ NOWY |
| `launcher_config.json` | E6 | ✅ NOWY |
| `requirements.txt` | E6 | ✅ NOWY |
| `build_launcher.bat` | E12, FIX17 | ✅ NOWY |
| `build_launcher.sh` | E12 | ✅ NOWY |

### Dokumentacja (3 pliki)
| Plik | Aktualizowane na bieżąco |
|------|--------------------------|
| `Dokumentacja/01_Instalka_Klient/2026-03/00_START_PRACY_CHECKLISTA.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/01_DZIENNIK_PRAC.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/02_DZIENNIK_BUILDOW_GHA.md` | ✅ |

**RAZEM: 42 pliki** (11 C++, 6 Lua, 1 OTUI, 2 config Lua, 1 config dist, 3 dokumentacja, 9 PHP/SQL, 5 launcher Python, 4 wygenerowane)  
**Niezacommitowane**: wszystkie oprócz A1 (`72681f84c`) i A2-A5 (`b216fe683`) + docs restoration (`d0e121d77`)  
**Commity na branchu**: `72681f84c` (A1), `b216fe683` (A2-A5), `d0e121d77` (docs) — reszta do zacommitowania  
**Stan na 2026-03-02**: commit zbiorczy ze wszystkimi zmianami A6-E12 + FIX1-FIX17 + audyty X1-X8 + CR-1..CR-4
