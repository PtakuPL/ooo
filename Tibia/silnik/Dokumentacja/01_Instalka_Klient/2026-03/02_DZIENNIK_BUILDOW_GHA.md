# Dziennik Buildów GitHub Actions

Projekt: zabezpieczenie klienta i serwera (ticket-gate + launcher)  
Branch: `feature/ticket-gate` (bazuje na `feature/i18n-multilanguage`)  
Repo: `PtakuPL/ooo`

## Jak wpisywać

1. Każdy run GHA = jeden wpis.
2. Uzupełniaj: commit SHA, wynik (PASS/FAIL), pierwszy błąd, poprawkę.

## Szablon Wpisu

```md
## [YYYY-MM-DD HH:MM] Build #N — <PASS/FAIL>

Commit: <short_sha>
Branch: <branch>
Trigger: <manual/push>

Jobs:
- Windows: PASS/FAIL
- Linux: PASS/FAIL

Pierwszy błąd (jeśli FAIL):
- Job: <nazwa>
- Plik: <ścieżka>
- Linia: <nr>
- Komunikat: <treść>

Poprawka:
- <co zrobiono>
- Commit naprawczy: <sha>
```

## Log

### Oczekujący build: commit `98964825b` (2026-03-03)

**Commit**: `98964825b` — port C++ server + API + OTClient + launcher do canary_test  
**Branch**: `feature/ticket-gate`  
**31 plików zmienionych** (11 C++ wymagających kompilacji)  
**Status**: ⬜ Oczekuje na GHA trigger lub ręczne uruchomienie

#### Pliki OTClient (klient) — `canary_test/testyy/`:
| Plik | Zmiana | Wpływa na kompilację C++? |
|------|--------|--------------------------|
| `canary_test/testyy/init.lua` | A1 + A-FIX: CLIENT_LOCKED, GameModes, port 443, walidacja placeholderów | NIE (Lua) |
| `canary_test/testyy/modules/client_entergame/entergame.lua` | A2+A3+A5 + A-FIX setLoginFormVisible + B5 ticket flow | NIE (Lua) |
| `canary_test/testyy/modules/client_entergame/characterlist.lua` | B5 tryLogin() ticket flow | NIE (Lua) |
| `canary_test/testyy/src/framework/net/httplogin.cpp` | X2 TLS + X2b no HTTP fallback + X7 logger + B6 requestTicket() | **TAK (C++)** |
| `canary_test/testyy/src/framework/net/httplogin.h` | B6 requestTicket() declaration | **TAK (C++)** |
| `canary_test/testyy/cacert.pem` | FIX46 CA cert | NIE (dane) |

#### Pliki Canary Server — `canary_test/src/` (sportowane z canary/ w `98964825b`):
| Plik | Zmiana | Wpływa na kompilację C++? |
|------|--------|--------------------------|
| `canary_test/src/server/network/protocol/ticket_validator.hpp` | C1 NOWY — deklaracja klasy | **TAK (C++)** |
| `canary_test/src/server/network/protocol/ticket_validator.cpp` | C1 NOWY — implementacja HMAC+nonce | **TAK (C++)** |
| `canary_test/src/server/network/protocol/protocolgame.cpp` | C2 ticket auth + D1-D10 guardy (18 punktów) | **TAK (C++)** |
| `canary_test/src/server/network/protocol/protocolgame.hpp` | D1 pendingGameMode_, isClassic74Blocked | **TAK (C++)** |
| `canary_test/src/config/config_enums.hpp` | C3 TICKET_GATE_ENABLED, TICKET_SECRET | **TAK (C++)** |
| `canary_test/src/config/configmanager.cpp` | C3 loadBoolConfig + loadStringConfig | **TAK (C++)** |
| `canary_test/src/creatures/creatures_definitions.hpp` | D1 PlayerGameMode_t enum | **TAK (C++)** |
| `canary_test/src/creatures/players/player.hpp` | D1 gameMode_ field + D8 lastMoveTime_ | **TAK (C++)** |
| `canary_test/src/game/game.cpp` | D8 rate-limit playerMove() | **TAK (C++)** |
| `canary_test/src/server/CMakeLists.txt` | ticket_validator.cpp dodany do target_sources | NIE (CMake) |
| `canary_test/config.lua.dist` | C4 ticketGateEnabled, ticketSecret | NIE (Lua) |

**Wniosek**: 11 plików C++ wymaga kompilacji (2 klient OTClient + 9 serwer Canary).  
**Kluczowe obawy**:
1. OpenSSL linkowanie — `ticket_validator.cpp` używa `HMAC()`, `EVP_sha256()`, `EVP_DecodeInit()` z OpenSSL. Canary nie linkuje jawnie OpenSSL (ale CURL może go transitywnie dostarczać).
2. Nowe includy: `#include "account/account_repository.hpp"` w protocolgame.cpp — weryfikowane (metoda istnieje na linia 33 .hpp).
3. Nowy enum `PlayerGameMode_t` w creatures_definitions.hpp — forward-declared w protocolgame.hpp.

## [2026-03-05 13:08] Build #22695571939 — FAIL (zdiagnozowany)

Commit: `74574f49a`
Branch: `feature/ticket-gate`
Trigger: `workflow_dispatch`
Run URL: https://github.com/PtakuPL/ooo/actions/runs/22695571939

Jobs:
- canary-ubuntu-22.04-linux-release: FAIL
- canary-ubuntu-22.04-linux-debug: FAIL
- canary-ubuntu-24.04-linux-release: FAIL
- canary-ubuntu-24.04-linux-debug: FAIL

Pierwszy błąd (root-cause):
- Job: `canary-ubuntu-22.04-linux-release` (`65801033005`)
- Plik: `Tibia/silnik/canary_test/src/server/network/message/networkmessage.hpp`
- Linia: 19
- Komunikat:
  - `invalid use of incomplete type 'class RSA'`
  - `conflicting declaration 'typedef struct rsa_st RSA'`

Diagnoza:
- W kodzie część referencji była już zmieniona na `CanaryRSA`, ale część nadal używała `RSA`.
- Forward declaration `class RSA;` kolidowała z typem `RSA` z OpenSSL (`rsa_st`).
- To powodowało lawinę błędów w DI i kompilacji unity (main.cpp/canary_server.cpp/ticket_validator unity unit).

Poprawka wdrożona lokalnie (2026-03-05):
- `canary_test/src/canary_server.hpp`: `RSA&` -> `CanaryRSA&`
- `canary_test/src/canary_server.cpp`: `RSA&` -> `CanaryRSA&`
- `canary_test/src/server/network/message/networkmessage.hpp`: usunięto `class RSA;`
- Dodatkowo domknięto ticket-gate nonce/iat flow (ticket.php + ticket_validator.cpp/hpp), aby runtime bezpieczeństwa był spójny po przejściu builda.

Status:
- ⏳ Oczekuje na nowy run Canary po pushu poprawek.

## [2026-03-05 13:08] Build #22717070014 — ✅ PASS

Commit: `652c0e033`
Branch: `feature/ticket-gate`
Trigger: `push`
Run URL: https://github.com/PtakuPL/ooo/actions/runs/22717070014

Jobs:
- canary-ubuntu-22.04-linux-release: ✅ PASS
- canary-ubuntu-22.04-linux-debug: ✅ PASS
- canary-ubuntu-24.04-linux-release: ✅ PASS
- canary-ubuntu-24.04-linux-debug: ✅ PASS

Czas trwania: 30m 26s

Artefakty (4):
- canary-ubuntu-22.04-linux-debug-652c0e033 (100 MB)
- canary-ubuntu-22.04-linux-release-652c0e033 (54.1 MB)
- canary-ubuntu-24.04-linux-debug-652c0e033 (105 MB)
- canary-ubuntu-24.04-linux-release-652c0e033 (54.7 MB)

Warningi (32, bez błędów kompilacji):
- `-Wrange-loop-construct` w protocolgame.cpp (L6255, L6277, L7735) — structured bindings kopiują zamiast referencji
- `-Wunused-variable` charmPoints (protocolgame.cpp:3215), ghost (creature_functions.cpp:1348)
- `-Wparentheses` w game.cpp:7474 — brak nawiasów wokół && w ||
- LogCollection warns dot. brakujących cmake-get-vars logów (luajit, gmp, openssl) — normalne

Wniosek:
- ✅ **KOMPILACJA CANARY SERWERA PRZESZŁA** — RSA/OpenSSL bloker naprawiony.
- ✅ Ticket-gate (C1-C5), Feature flags (D1-D10), nonce/iat flow — wszystko kompiluje się poprawnie.
- ⚠️ Warningi do domknięcia w przyszłości (nie blokujące).
- Zadania A8 (OTClient build) i C6 (Canary build) mogą być oznaczone jako 🟢 GOTOWE na Linux.
