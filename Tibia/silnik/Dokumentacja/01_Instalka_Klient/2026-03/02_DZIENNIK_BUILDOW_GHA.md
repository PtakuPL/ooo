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
