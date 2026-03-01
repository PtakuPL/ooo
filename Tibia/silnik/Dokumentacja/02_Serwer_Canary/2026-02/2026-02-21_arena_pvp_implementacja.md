# ⚔️ Arena PvP — Stan Implementacji

> **Data aktualizacji:** 2026-02-21 (Phase 4 done)  
> **Branch git:** `master`  
> **Bazuje na:** ARENA_SYSTEM_PLAN.md

---

## 📊 PODSUMOWANIE POSTĘPU

| Faza | Opis | Status |
|------|------|--------|
| 0 | Przygotowanie (analiza kodu, branch) | ✅ DONE |
| 1 | Baza danych (6 tabel SQL) | ✅ DONE |
| 2 | Core C++ serwera | ✅ DONE (pliki + hooki) |
| 3 | Matchmaking | ✅ DONE (w ramach Fazy 2) |
| 4 | Protokół sieciowy (opcodes) | ✅ DONE |
| 5 | Skrypty Lua (tryby, NPC, bindings) | ⬜ TODO |
| 6 | UI klienta OTClient | ⬜ TODO |
| 7 | Strona WWW (rankingi) | ⬜ TODO |
| 8 | Bezpieczeństwo / Anti-cheat | ⬜ TODO |
| 9 | Sezony i nagrody | ⬜ TODO |
| 10 | i18n (tłumaczenia) | ⬜ TODO |
| 11 | Testy | ⬜ TODO |
| 12 | Dokumentacja + mapy + deploy | ⬜ TODO |

---

## ✅ FAZA 0 — PRZYGOTOWANIE (DONE)

### Co zrobiono:
- Analiza kodu Market (wzorzec 3-warstwowy: Protocol → Game → IOMarket)
- Analiza hooków Combat/Death/PvP — znaleziono kluczowe punkty integracji
- Analiza systemu Party, Logout, Zone
- Zidentyfikowano wolne opcodes: `0xD0`, `0xDB`, `0xE0`, `0xEA`
- Utworzono branch `feature/arena-pvp`

### Kluczowe ustalenia:
- `ZONE_PVP` automatycznie wyłącza drop i skill loss (creature.cpp L518)
- System `Zone` (zone.hpp) — idealny do obszarów areny (auto-tracking graczy)
- Market opcodes: 0xF4-0xF9; Arena opcodes: 0xD0 (client→server), 0xDB (server→client) — multiplexowane
- Punkty hooków: `Creature::onDeath()`, `Player::onKilledPlayer()`, `Player::removePlayer()`

---

## ✅ FAZA 1 — BAZA DANYCH (DONE)

### Co zrobiono:
- Utworzono plik migracji: `data/migrations/20260221_arena_tables.sql`
- Dodano tabele do `schema.sql`
- Wykonano migrację na bazie `canaryaac`
- Przetestowano CRUD + FK CASCADE

### 6 tabel:
| Tabela | Opis |
|--------|------|
| `arena_players` | Profil arenowy (MMR, wins, losses, streak, damage, healing, points) |
| `arena_matches` | Historia meczy (tryb, mapa, czas, zwycięzca, sezon) |
| `arena_match_players` | Statystyki per gracz per mecz (kills, deaths, dmg, MMR change) |
| `arena_queue` | Kolejka matchmakingu (czyszczona przy restarcie) |
| `arena_seasons` | Sezony (nazwa, daty, aktywny) |
| `arena_season_rankings` | Ranking na koniec sezonu (snapshot) |

---

## ✅ FAZA 2 — CORE C++ SERWERA (DONE)

### Utworzone pliki (1927 linii kodu łącznie):

| Plik | Linie | Opis |
|------|-------|------|
| `src/game/arena/arena_definitions.hpp` | 202 | Enumy, struktury danych (ArenaMode, ArenaMatchState, ArenaPlayerStats itd.) |
| `src/game/arena/arena_match.hpp` | 104 | Klasa ArenaMatch — stan pojedynczego meczu |
| `src/game/arena/arena_match.cpp` | 319 | Logika meczu (addPlayer, onKill, onDeath, checkWinCondition, finish) |
| `src/game/arena/arena_matchmaking.hpp` | 54 | Klasa ArenaMatchmaking — algorytm dobierania |
| `src/game/arena/arena_matchmaking.cpp` | 265 | Matchmaking (kolejki, MMR range, auto-balance, tick) |
| `src/game/arena/arena_system.hpp` | 95 | Klasa ArenaSystem — singleton zarządzający |
| `src/game/arena/arena_system.cpp` | 627 | Główna logika (joinQueue, leaveQueue, startMatch, finishMatch, hooki) |
| `src/io/ioarena.hpp` | 42 | IOArena — warstwa DB |
| `src/io/ioarena.cpp` | 219 | Operacje SQL (getPlayerStats, createMatch, saveMatchPlayer, getTopRanking) |

### Integracja z istniejącym kodem:

| Co | Gdzie | Status |
|----|-------|--------|
| Include `arena_system.hpp` | `game.cpp` L13 | ✅ |
| `g_arenaSystem().init()` | `game.cpp` L576 (start) | ✅ |
| `g_arenaSystem().tick()` | `game.cpp` L578 (co 2s task) | ✅ |
| `g_arenaSystem().shutdown()` | `game.cpp` L8415 | ✅ |
| Hook kill w arenie | `creature.cpp` L512-518 (onDeath) | ✅ |
| Hook logout z areny | `player.cpp` L4354-4355 (removePlayer) | ✅ |
| CMake game/ | `src/game/CMakeLists.txt` L13-15 | ✅ |
| CMake io/ | `src/io/CMakeLists.txt` L17 | ✅ |

### Funkcjonalności zaimplementowane:
- **ArenaSystem singleton** z globalnym accessorem `g_arenaSystem()`
- **Kolejki matchmakingu** per tryb (1v1, 2v2, 3v3, FFA, LMS)
- **Algorytm MMR** (Elo-based: K=25, expected score formula)
- **Rozszerzanie zakresu** szukania (±100 → ±200 → ±500 → dowolny)
- **Auto-balance drużyn** (sort MMR, podział zygzakiem)
- **Lifecycle meczu**: start → countdown → in_progress → finished
- **Hooki**: onArenaKill, onArenaDeath, onArenaLogout
- **Teleportacja**: na arenę (spawn points) i powrót (temple)
- **Heal/cleanse** na starcie meczu
- **Zapis wyników** do DB po meczu
- **IOArena** z pełnym CRUD (getPlayerStats, createMatch, getTopRanking itd.)

---

## ⬜ CO ZOSTAŁO DO ZROBIENIA

### Faza 5 — Skrypty Lua (NEXT)
- Lua bindings (Arena.joinQueue, Arena.leaveQueue, player:openArena itd.)
- Przebudowa arena_2x2.lua i arena_10x10.lua
- NPC arena_master.lua
- System nagród

### Faza 6 — UI klienta (OTClient)
- Moduł modules/game_arena/
- Okno areny (tryby, statystyki, ranking, historia)
- Overlay w trakcie meczu (timer, score)

### Faza 7 — WWW
- html_copy/arena/ (rankings.php, player.php, api.php)

### Fazy 8-12
- Anti-cheat, sezony, i18n, testy, mapy, deploy

---

## ✅ FAZA 4 — PROTOKÓŁ SIECIOWY (DONE)

### Co zrobiono:
- Implementacja `parseArenaAction()` — multiplexowany handler w switch case 0xD0
- Sub-actions client→server (0x01-0x05): OPEN, JOIN_QUEUE, LEAVE_QUEUE, REQUEST_RANKING, REQUEST_HISTORY
- Implementacja 7 metod send do klienta (opcode 0xDB, sub-byte multiplexing):

| Metoda | Sub | Opis |
|--------|-----|------|
| `sendArenaStatus()` | 0x01 | Stan gracza + rozmiary kolejek + aktywne mecze |
| `sendArenaStats()` | 0x02 | Pełne statystyki gracza (MMR, W/L/D, streaki, K/D, dmg, heal, punkty) |
| `sendArenaMatchFound()` | 0x03 | Znaleziono mecz — lista graczy z drużynami |
| `sendArenaMatchUpdate()` | 0x04 | Scoreboard na żywo (wyniki drużyn + statsy graczy) |
| `sendArenaRankingData()` | 0x05 | Ranking paginowany (MMR, wins, losses, streaki) |
| (inline in parse) | 0x06 | Historia meczy gracza (matchId, mode, time, K/D, mmrChange) |
| `sendArenaMatchResult()` | 0x07 | Wynik końcowy meczu z MMR changes |

### Zmodyfikowane pliki:
| Plik | Zmiany |
|------|--------|
| `protocolgame.hpp` | Include `arena_definitions.hpp`, deklaracja parse + 6 metod send |
| `protocolgame.cpp` | case 0xD0 w switch, ~270 linii implementacji metod |
| `arena_match.hpp` | Dodano convenience: `getPlayerCount()`, `getPlayerStats()` (map), `getElapsedSeconds()`, `getTeamScores()`, `getPlayerName()` |
| `arena_match.cpp` | Implementacja nowych convenience methods |

### Protokół wire-format:
```
Client→Server (0xD0):
  [0xD0][subAction:u8][...data]
  sub 0x01: open (no data)
  sub 0x02: join [mode:u8]
  sub 0x03: leave (no data)
  sub 0x04: ranking [page:u32][filterMode:u8]
  sub 0x05: history [page:u32]

Server→Client (0xDB):
  [0xDB][subType:u8][...data]
  sub 0x01: status [state:u8][numModes:u8][{mode:u8,queueSize:u16}...][activeMatches:u16]
  sub 0x02: stats [mmr:i32][wins:u32][losses:u32][draws:u32][winStreak:i32][bestStreak:i32][kills:u32][deaths:u32][damage:i32][healing:i32][points:i32]
  sub 0x03: matchFound [matchId:u32][mode:u8][playerCount:u8][{pid:u32,team:u8,name:str}...]
  sub 0x04: matchUpdate [matchId:u32][state:u8][elapsed:u16][numTeams:u8][{team:u8,score:u16}...][numPlayers:u8][{pid:u32,team:u8,kills:u16,deaths:u16,dmg:i32,heal:i32}...]
  sub 0x05: ranking [page:u32][count:u16][{pid:u32,name:str,mmr:i32,wins:u32,losses:u32,winStreak:i32,bestStreak:i32}...]
  sub 0x06: history [count:u16][{matchId:u32,mode:u8,startAt:u32,duration:u16,winnerTeam:u8,playerTeam:u8,kills:u16,deaths:u16,dmg:i32,heal:i32,mmrChange:i32}...]
  sub 0x07: matchResult [matchId:u32][mode:u8][winnerTeam:u8][elapsed:u16][numPlayers:u8][{pid:u32,team:u8,kills:u16,deaths:u16,dmg:i32,heal:i32,mmrChange:i32}...]
```

---

## 🔑 WOLNE OPCODES ARENY

| Opcode | Kierunek | Użycie |
|--------|----------|--------|
| `0xD0` | Client → Server | parseArenaAction() multiplexowany (sub 0x01-0x05) |
| `0xDB` | Server → Client | sendArenaData() multiplexowany (sub 0x01-0x06) |
| `0xE0` | Rezerwa | (do wykorzystania w przyszłości) |
| `0xEA` | Rezerwa | (do wykorzystania w przyszłości) |

---

## ⚠️ UWAGI
- Mapy aren na końcu — pomysł losowych punktów na mapie z blokadą terenu
- Kompilacja nie lokalna — używamy GitHub Actions / CI
- Nie robimy kompilacji na WSL
