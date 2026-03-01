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

(brak buildów — jeszcze nie pushowano zmian z Fazy A)

### Stan plików do push (niezacommitowane zmiany):

#### Pliki OTClient (klient) — `canary_test/testyy/`:
| Plik | Zmiana | Wpływa na kompilację C++? |
|------|--------|--------------------------|
| `canary_test/testyy/init.lua` | A1 + A-FIX: CLIENT_LOCKED, GameModes, port 443, walidacja placeholderów | NIE (Lua) |
| `canary_test/testyy/modules/client_entergame/entergame.lua` | A2+A3+A5 + A-FIX setLoginFormVisible + B5 ticket flow | NIE (Lua) |
| `canary_test/testyy/modules/client_entergame/entergame.otui` | A2 gameModePanel | NIE (OTUI) |
| `canary_test/testyy/modules/client_serverlist/serverlist.lua` | A4 + A-FIX ServerList lock fix | NIE (Lua) |
| `canary_test/testyy/modules/game_hotkeys/hotkeys_manager.lua` | A6 hotkey rune guard | NIE (Lua) |
| `canary_test/testyy/modules/client_entergame/characterlist.lua` | B5 tryLogin() ticket flow | NIE (Lua) |
| `canary_test/testyy/src/framework/net/httplogin.cpp` | X2 TLS + X2b no HTTP fallback + X7 logger + B6 requestTicket() | **TAK (C++)** |
| `canary_test/testyy/src/framework/net/httplogin.h` | B6 requestTicket() declaration | **TAK (C++)** |
| `canary_test/testyy/src/framework/luafunctions.cpp` | B6 Lua binding requestTicket | **TAK (C++)** |

#### Pliki Canary (serwer) — niezacommitowane:
| Plik | Zmiana | Wpływa na kompilację C++? |
|------|--------|--------------------------|
| `canary/src/server/network/protocol/ticket_validator.hpp` | C1 NOWY — deklaracja klasy | **TAK (C++)** |
| `canary/src/server/network/protocol/ticket_validator.cpp` | C1 NOWY — implementacja HMAC+nonce | **TAK (C++)** |
| `canary/src/server/network/protocol/protocolgame.cpp` | C2 integracja walidacji ticketu | **TAK (C++)** |
| `canary/src/config/config_enums.hpp` | C3 TICKET_GATE_ENABLED, TICKET_SECRET | **TAK (C++)** |
| `canary/src/config/configmanager.cpp` | C3 loadBoolConfig + loadStringConfig | **TAK (C++)** |
| `canary/config.lua.dist` | C4 ticketGateEnabled, ticketSecret | NIE (Lua) |
| `canary_test/config.lua` | C4 ticketGateEnabled, ticketSecret | NIE (Lua) |
| `canary/src/creatures/creatures_definitions.hpp` | D1 PlayerGameMode_t enum | **TAK (C++)** |
| `canary/src/creatures/players/player.hpp` | D1 gameMode_ field + D8 lastMoveTime_ | **TAK (C++)** |
| `canary/src/server/network/protocol/protocolgame.hpp` | D1 pendingGameMode_ + isClassic74Blocked | **TAK (C++)** |
| `canary/src/server/network/protocol/protocolgame.cpp` | D1 wire-up + D2-D10 guardy (18 punktów) | **TAK (C++)** |
| `canary/src/game/game.cpp` | D8 rate-limit playerMove() | **TAK (C++)** |

**Wniosek**: 12 plików C++ wymagają kompilacji (3 klient + 9 serwer Canary).  
Nowe pliki Canary D: creatures_definitions.hpp, player.hpp, protocolgame.hpp/cpp, game.cpp.  
Po commit + push → uruchomić GHA build i wpisać wynik tutaj.
