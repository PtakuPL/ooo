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
| CR-1 | WYSOKIE | Niespójny format hosta — `GameModes.server.host` to sam host, ale `tryHttpLogin` parsuje `G.host` jako host/path. `httpLoginUrl` zdefiniowany ale nigdzie nieużywany. | `init.lua:28`, `entergame.lua:691`, `init.lua:32` | ⬜ TODO |
| CR-2 | ŚREDNIE | Komunikat błędu HTTP nieaktualny po usunięciu fallbacku — nadal sugeruje "Enable Http login / port 80/8080" co jest mylące. | `httplogin.cpp:135` | ⬜ TODO |
| CR-3 | ŚREDNIE | X7 częściowo zrobione — body usunięte z logów, ale `req.headers` i `res.headers` nadal wypisywane. Wrażliwe nagłówki (np. `Set-Cookie`) mogą wyciekać. | `httplogin.cpp:53,63` | ⬜ TODO |
| CR-4 | NISKIE | Unused variable — `httpLogin` nadal łapany przez lambdy ale już nieużywany po X2b. Potencjalny warning kompilatora przy ostrzejszych flagach. | `httplogin.cpp:106,146` | ⬜ TODO |

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
| B1 | `gameMode` + `launchToken` w login.php | ⬜ TODO | — |
| B2 | Filtrowanie worldów wg gameMode | ⬜ TODO | — |
| B3 | Nowy endpoint `ticket.php` | ⬜ TODO | — |
| B4 | Tabela `ticket_nonces` MySQL | ⬜ TODO | — |
| B5 | Klient Lua: request do ticket.php | ✅ DONE | niezacommitowane |
| B6 | Klient C++: `requestTicket()` | ✅ DONE | niezacommitowane |
| B7 | Test flow login→ticket→connect | ⬜ TODO | — |

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

### Faza E — Launcher z auto-update
| # | Zadanie | Status | Commit |
|---|---------|--------|--------|
| E1-E7 | (jeszcze do rozpisania) | ⬜ TODO | — |

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
| `init.lua` | A1, A-FIX | NIE |
| `modules/client_entergame/entergame.lua` | A2, A3, A5, A-FIX, B5 | NIE |
| `modules/client_entergame/entergame.otui` | A2 | NIE |
| `modules/client_entergame/characterlist.lua` | B5 | NIE |
| `modules/client_serverlist/serverlist.lua` | A4, A-FIX | NIE |
| `modules/game_hotkeys/hotkeys_manager.lua` | A6 | NIE |
| `src/framework/net/httplogin.cpp` | X2, X2b, X7, B6 | **TAK** |
| `src/framework/net/httplogin.h` | B6 | **TAK** |
| `src/framework/luafunctions.cpp` | B6 | **TAK** |

### Canary Server — `canary/` (9 plików, 7 C++, 2 nowe)
| Plik | Fazy | C++? | Nowy? |
|------|------|------|-------|
| `src/server/network/protocol/ticket_validator.hpp` | C1 | **TAK** | ✅ NOWY |
| `src/server/network/protocol/ticket_validator.cpp` | C1 | **TAK** | ✅ NOWY |
| `src/server/network/protocol/protocolgame.cpp` | C2, D1, D2-D10 | **TAK** | |
| `src/server/network/protocol/protocolgame.hpp` | D1 | **TAK** | |
| `src/config/config_enums.hpp` | C3 | **TAK** | |
| `src/config/configmanager.cpp` | C3 | **TAK** | |
| `src/creatures/creatures_definitions.hpp` | D1 | **TAK** | |
| `src/creatures/players/player.hpp` | D1, D8 | **TAK** | |
| `src/game/game.cpp` | D8 | **TAK** | |

### Konfiguracja (2 pliki)
| Plik | Fazy |
|------|------|
| `canary/config.lua.dist` | C4 |
| `canary_test/config.lua` | C4 |

### Dokumentacja (3 pliki)
| Plik | Aktualizowane na bieżąco |
|------|--------------------------|
| `Dokumentacja/01_Instalka_Klient/2026-03/00_START_PRACY_CHECKLISTA.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/01_DZIENNIK_PRAC.md` | ✅ |
| `Dokumentacja/01_Instalka_Klient/2026-03/02_DZIENNIK_BUILDOW_GHA.md` | ✅ |

**RAZEM: 23 pliki** (10 C++, 6 Lua, 1 OTUI, 2 config Lua, 1 config dist, 3 dokumentacja)  
**Niezacommitowane**: wszystkie oprócz A1 (`72681f84c`) i A2-A5 (`b216fe683`)  
**Commity na branchu**: `72681f84c` (A1), `b216fe683` (A2-A5) — reszta do zacommitowania
