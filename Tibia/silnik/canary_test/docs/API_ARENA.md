# Arena PvP — API Documentation

> **Version:** Pre-Alpha 1.0  
> **Date:** 2026-02-21  
> **System:** Canary OT Server — Arena PvP Module

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Network Protocol (Opcodes)](#network-protocol)
3. [C++ API (ArenaSystem)](#c-api)
4. [Lua API](#lua-api)
5. [Database Schema](#database-schema)
6. [i18n Keys](#i18n-keys)
7. [Configuration (config.lua)](#configuration)
8. [File Structure](#file-structure)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    OTClient (UI)                            │
│  Opcode 0xD0 (client→server)  │  Opcode 0xDB (server→client)│
└────────────────────┬──────────────────────┬─────────────────┘
                     │                      │
┌────────────────────▼──────────────────────▼─────────────────┐
│            ProtocolGame (network layer)                      │
│  parseArenaAction(msg)  │  sendArena*(msg)                   │
└────────────────────┬──────────────────────┬─────────────────┘
                     │                      │
┌────────────────────▼──────────────────────▼─────────────────┐
│                  ArenaSystem (singleton)                      │
│  Queue ─── Matchmaking ─── Match ─── Stats/DB               │
└────────────────────┬──────────────────────┬─────────────────┘
                     │                      │
          ┌──────────▼──────────┐  ┌────────▼────────┐
          │  Lua Scripts        │  │  IOArena (DB)    │
          │  Talkactions, NPC,  │  │  MySQL queries   │
          │  Security, Logging  │  └─────────────────┘
          └─────────────────────┘
```

### Key Components

| Component | File | Purpose |
|---|---|---|
| ArenaSystem | `src/game/arena/arena_system.hpp/cpp` | Main singleton, lifecycle, queue, combat hooks |
| ArenaMatchmaking | `src/game/arena/arena_matchmaking.hpp/cpp` | MMR-based matchmaking algorithm |
| ArenaMatch | `src/game/arena/arena_match.hpp/cpp` | Individual match state machine |
| ArenaDefinitions | `src/game/arena/arena_definitions.hpp` | Enums, structs, helpers |
| IOArena | `src/io/io_arena.hpp/cpp` | Database persistence |
| ArenaFunctions | `src/lua/functions/core/game/arena_functions.hpp/cpp` | Lua bindings |
| ProtocolGame | `src/server/network/protocol/protocolgame.cpp` | Network packets |

---

## Network Protocol

### Client → Server: Opcode `0xD0`

The client sends opcode `0xD0` to trigger arena actions. The first byte after the opcode is the sub-action:

| Sub-Action | Byte | Payload | Description |
|---|---|---|---|
| Open Arena UI | `0x01` | — | Server responds with status + stats |
| Join Queue | `0x02` | `uint8_t modeId` | Join arena queue for mode (1-8) |
| Leave Queue | `0x03` | — | Leave current queue |
| Request Ranking | `0x04` | `uint32_t page`, `uint8_t filterMode` | Get ranking page (0-indexed) |
| Request History | `0x05` | `uint32_t page` | Get match history |

### Server → Client: Opcode `0xDB`

The server sends opcode `0xDB` with sub-types:

#### Sub `0x01` — Arena Status
```
uint8_t  playerState         (0=IDLE, 1=IN_QUEUE, 2=IN_MATCH)
uint8_t  numModes            (8 = total modes)
  [repeated numModes times]:
    uint8_t   modeId
    uint16_t  queueSize
uint16_t activeMatchCount
```

#### Sub `0x02` — Player Stats
```
int32_t   mmr
uint32_t  wins
uint32_t  losses
uint32_t  draws
int32_t   winStreak
int32_t   bestStreak
uint32_t  totalKills
uint32_t  totalDeaths
int32_t   totalDamage        (cast to int32)
int32_t   totalHealing       (cast to int32)
int32_t   arenaPoints
```

#### Sub `0x03` — Match Found
```
uint32_t  matchId
uint8_t   mode
uint8_t   playerCount
  [repeated playerCount times]:
    uint32_t  playerId
    uint8_t   team
    string    playerName
```

#### Sub `0x04` — Match Live Update
```
uint32_t  matchId
uint8_t   matchState         (0=WAITING, 1=COUNTDOWN, 2=IN_PROGRESS, 3=FINISHED)
uint16_t  elapsedSeconds
uint8_t   numTeams
  [repeated numTeams times]:
    uint8_t   teamId
    uint16_t  score
uint8_t   playerCount
  [repeated playerCount times]:
    uint32_t  playerId
    uint8_t   team
    uint16_t  kills
    uint16_t  deaths
    int32_t   damageDealt
    int32_t   healingDone
```

#### Sub `0x05` — Ranking Data
```
uint32_t  page
uint16_t  numEntries
  [repeated numEntries times]:
    uint32_t  playerId
    string    playerName
    int32_t   mmr
    uint32_t  wins
    uint32_t  losses
    int32_t   winStreak
    int32_t   bestStreak
```

#### Sub `0x06` — Match History
```
uint16_t  numEntries
  [repeated numEntries times]:
    uint32_t  matchId
    uint8_t   mode
    uint32_t  startedAt        (unix timestamp)
    uint16_t  duration         (seconds)
    uint8_t   winnerTeam
    uint8_t   playerTeam
    uint16_t  kills
    uint16_t  deaths
    int32_t   damageDealt
    int32_t   healingDone
    int32_t   mmrChange
```

#### Sub `0x07` — Match Result
```
uint32_t  matchId
uint8_t   mode
uint8_t   winnerTeam
uint16_t  elapsedSeconds
uint8_t   playerCount
  [repeated playerCount times]:
    uint32_t  playerId
    uint8_t   team
    uint16_t  kills
    uint16_t  deaths
    int32_t   damageDealt
    int32_t   healingDone
    int32_t   mmrChange
```

---

## C++ API

### ArenaSystem (singleton)

Access via `g_arenaSystem()`.

#### Lifecycle

| Method | Description |
|---|---|
| `void init()` | Initialize arena system, load from DB |
| `void shutdown()` | Save state, clean up |
| `void tick()` | Called every 5s by Game loop — runs matchmaking + match checks |

#### Queue Management

| Method | Params | Returns | Description |
|---|---|---|---|
| `joinQueue` | `shared_ptr<Player>, ArenaMode` | `bool` | Add player to queue |
| `leaveQueue` | `shared_ptr<Player>` | `bool` | Remove player from queue |
| `isPlayerInQueue` | `uint32_t playerId` | `bool` | Check if player is queued |

#### Match State

| Method | Params | Returns | Description |
|---|---|---|---|
| `isPlayerInArena` | `uint32_t playerId` | `bool` | Check if player is in active match |
| `getPlayerState` | `uint32_t playerId` | `ArenaPlayerState` | Get IDLE/IN_QUEUE/IN_MATCH |
| `getPlayerMatch` | `uint32_t playerId` | `ArenaMatch*` | Get player's current match (or nullptr) |

#### Combat Hooks

| Method | Params | Description |
|---|---|---|
| `onArenaKill` | `killerId, victimId` | Process kill event during match |
| `onArenaDeath` | `playerId` | Process death event |
| `onArenaLogout` | `playerId` | Handle disconnect during match |
| `onArenaDamage` | `attackerId, targetId, damage` | Track damage dealt |
| `onArenaHeal` | `healerId, amount` | Track healing done |

#### Stats & Rankings

| Method | Params | Returns | Description |
|---|---|---|---|
| `getPlayerStats` | `uint32_t playerId` | `ArenaPlayerStats` | Get player's arena statistics |
| `getTopRanking` | `limit=50, offset=0` | `vector<ArenaRankEntry>` | Query top players |
| `getPlayerHistory` | `playerId, limit=20` | `vector<ArenaMatchHistory>` | Query match history |
| `getActiveMatchCount` | — | `uint32_t` | Number of ongoing matches |
| `getQueueSize` | `ArenaMode` | `uint32_t` | Players waiting in specific mode |

### MMR Calculation

ELO-style formula:
```
Expected = 1 / (1 + 10^((Ropp - Rself) / 400))
Change = round(K * (Actual - Expected))
K = 25
```

Clamping:
- Winners get at least **+10** MMR
- Losers lose at most **-30** MMR

### Matchmaking Algorithm

Search range expansion based on wait time:
| Wait Time | MMR Range |
|---|---|
| 0-30s | ±100 |
| 30-60s | ±200 |
| 60-120s | ±500 |
| 120s+ | ±9999 (match anyone) |

Matching strategy:
- **1v1**: Find closest-MMR pair within range
- **2v2/3v3**: Group N closest players, all must be within range of each other
- **FFA/LMS**: 4-8 players, closest MMR cluster
- **Team assignment**: Zigzag by MMR descending for balance

---

## Lua API

### Arena Global Constants

| Constant | Value | Description |
|---|---|---|
| `Arena.MODE_1V1` | 1 | 1v1 Duel |
| `Arena.MODE_2V2` | 2 | 2v2 Team |
| `Arena.MODE_3V3` | 3 | 3v3 Team |
| `Arena.MODE_FFA` | 4 | Free For All |
| `Arena.MODE_CTF` | 5 | Capture The Flag |
| `Arena.MODE_KOTH` | 6 | King of the Hill |
| `Arena.MODE_LMS` | 7 | Last Man Standing |
| `Arena.MODE_TOURNAMENT` | 8 | Tournament |
| `Arena.STATE_IDLE` | 0 | Not in arena |
| `Arena.STATE_IN_QUEUE` | 1 | Waiting in queue |
| `Arena.STATE_IN_MATCH` | 2 | In active match |

### Arena Global Methods

| Method | Params | Returns | Description |
|---|---|---|---|
| `Arena.getPlayerStats(playerId)` | `number` | `table` | Get stats table (mmr, wins, losses, etc.) |
| `Arena.getTopRanking(limit)` | `number` | `table[]` | Array of rank entries |
| `Arena.getPlayerHistory(playerId, limit)` | `number, number` | `table[]` | Array of match history entries |
| `Arena.getActiveMatchCount()` | — | `number` | Active matches count |
| `Arena.getQueueSize(modeId)` | `number` | `number` | Queue size for mode |

### Player Arena Methods

| Method | Params | Returns | Description |
|---|---|---|---|
| `player:arenaJoinQueue(modeId)` | `number` | `boolean` | Join queue |
| `player:arenaLeaveQueue()` | — | `boolean` | Leave queue |
| `player:arenaGetState()` | — | `number` | Get state (0/1/2) |
| `player:arenaIsInArena()` | — | `boolean` | Is in active match |
| `player:arenaIsInQueue()` | — | `boolean` | Is in queue |
| `player:arenaGetStats()` | — | `table` | Get own stats |
| `player:arenaGetMMR()` | — | `number` | Get current MMR |
| `player:arenaSendStatus()` | — | — | Force-send arena status packet |

### ArenaConfig (Lua table in `data/libs/systems/arena.lua`)

Key fields:
- `ArenaConfig.rewards` — Win/loss MMR and points
- `ArenaConfig.mmr` — Default, min, max MMR
- `ArenaConfig.storage` — Storage keys for match state
- `ArenaConfig.antiCheat` — Anti-boost settings
- `ArenaConfig.titles` — MMR tier titles (12 tiers)
- `ArenaConfig.shop` — Shop items with prices

Helper functions:
- `ArenaConfig.getTitleForMMR(mmr)` — Get title string for MMR value
- `ArenaConfig.getModeName(player, modeId)` — Get localized mode name
- `ArenaConfig.getTranslatedTitle(player, mmr)` — Get localized title
- `ArenaConfig.canPlayerJoin(player)` — Validate join eligibility
- `ArenaConfig.formatRecord(player, stats)` — Format W-L-D string
- `ArenaConfig.formatKDR(stats)` — Format kill/death ratio string

---

## Database Schema

### Tables

```sql
CREATE TABLE arena_players (
    player_id INT UNSIGNED NOT NULL PRIMARY KEY,
    mmr INT NOT NULL DEFAULT 1000,
    wins INT UNSIGNED NOT NULL DEFAULT 0,
    losses INT UNSIGNED NOT NULL DEFAULT 0,
    draws INT UNSIGNED NOT NULL DEFAULT 0,
    win_streak INT NOT NULL DEFAULT 0,
    best_streak INT NOT NULL DEFAULT 0,
    total_damage BIGINT NOT NULL DEFAULT 0,
    total_healing BIGINT NOT NULL DEFAULT 0,
    total_kills INT UNSIGNED NOT NULL DEFAULT 0,
    total_deaths INT UNSIGNED NOT NULL DEFAULT 0,
    arena_points INT NOT NULL DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE arena_matches (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    mode TINYINT UNSIGNED NOT NULL,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL,
    duration INT UNSIGNED NOT NULL DEFAULT 0,
    winner_team TINYINT UNSIGNED NOT NULL DEFAULT 0,
    status TINYINT UNSIGNED NOT NULL DEFAULT 0
);

CREATE TABLE arena_match_players (
    match_id INT UNSIGNED NOT NULL,
    player_id INT UNSIGNED NOT NULL,
    team TINYINT UNSIGNED NOT NULL DEFAULT 0,
    kills SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    deaths SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    damage_dealt BIGINT NOT NULL DEFAULT 0,
    healing_done BIGINT NOT NULL DEFAULT 0,
    mmr_change INT NOT NULL DEFAULT 0,
    PRIMARY KEY (match_id, player_id),
    FOREIGN KEY (match_id) REFERENCES arena_matches(id),
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE arena_queue (
    player_id INT UNSIGNED NOT NULL PRIMARY KEY,
    mode TINYINT UNSIGNED NOT NULL,
    mmr INT NOT NULL DEFAULT 1000,
    queued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE arena_seasons (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    active TINYINT NOT NULL DEFAULT 0
);

CREATE TABLE arena_season_rankings (
    season_id INT UNSIGNED NOT NULL,
    player_id INT UNSIGNED NOT NULL,
    final_mmr INT NOT NULL,
    final_rank INT UNSIGNED NOT NULL,
    wins INT UNSIGNED NOT NULL DEFAULT 0,
    losses INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (season_id, player_id),
    FOREIGN KEY (season_id) REFERENCES arena_seasons(id),
    FOREIGN KEY (player_id) REFERENCES players(id)
);
```

---

## i18n Keys

Arena translations are stored in `i18n/<locale>/arena.json`. Currently **193 keys**.

Key namespaces:
- `arena.mode.*` — Mode names (1v1, 2v2, etc.)
- `arena.mode_desc.*` — Mode descriptions
- `arena.queue.*` — Queue join/leave/status messages
- `arena.match.*` — Match events (first blood, victory, defeat)
- `arena.stats.*` — Statistics display
- `arena.ranking.*` — Ranking display
- `arena.shop.*` — Shop messages
- `arena.title.*` — MMR tier titles (12 tiers)
- `arena.npc.*` — NPC Arena Master dialogs
- `arena.error.*` — Error messages
- `arena.admin.*` — Admin command messages
- `arena.security.*` — Security restriction messages (7 keys)
- `arena.anticheat.*` — Anti-cheat messages (4 keys)

Supported locales: EN (full), PL (full), 55 others (EN fallback).

---

## Configuration

In `config.lua`:

```lua
arenaSystemEnabled = true          -- Enable/disable arena system
arenaMinLevel = 50                 -- Minimum level to join
arenaJoinCooldownSeconds = 30      -- Cooldown between queue joins
arenaMatchMaxDuration = 600        -- Max match time (seconds)
arenaAfkTimeoutSeconds = 60        -- AFK force-loss timeout
arenaDailyMaxMMRGain = 200         -- Daily MMR gain cap
arenaMaxSameOpponentDaily = 3      -- Max matches vs same player/day for MMR
arenaMinMatchDuration = 30         -- Min match time to count (anti-boost)
arenaAntiBoostEnabled = true       -- Enable anti-wintrading detection
arenaLogEnabled = true             -- Enable logging to logs/arena.log
arenaLogLevel = "INFO"             -- Log level: INFO, WARN, ERROR
```

---

## File Structure

```
src/game/arena/
├── arena_definitions.hpp      # Enums, structs, helpers
├── arena_match.hpp/cpp        # Match state machine
├── arena_matchmaking.hpp/cpp  # Matchmaking algorithm
└── arena_system.hpp/cpp       # Main singleton

src/io/
└── io_arena.hpp/cpp           # Database persistence

src/lua/functions/core/game/
└── arena_functions.hpp/cpp    # Lua bindings

data/libs/systems/
└── arena.lua                  # ArenaConfig & helpers

data/scripts/arena/
├── arena_main.lua             # Core game logic (ArenaPvP table)
├── arena_security.lua         # In-match security restrictions
├── arena_anticheat.lua        # Anti-boost detection
└── arena_logging.lua          # Structured logging

data/scripts/talkactions/player/
├── arena.lua                  # !arena command
└── arena_rewards.lua          # !arena-shop, !arena-title

data/scripts/talkactions/gm/
└── arena_admin.lua            # !arena-admin GM commands

data/scripts/eventcallbacks/player/
└── arena_on_death.lua         # Prevent death penalties

data-otservbr-global/npc/
└── arena_master.lua           # Arena Master NPC

i18n/en/arena.json             # English translations (193 keys)
i18n/pl/arena.json             # Polish translations (193 keys)
i18n/*/arena.json              # Other locale fallbacks

tests/unit/arena/
├── arena_definitions_test.cpp # Definition helpers tests
├── arena_matchmaking_test.cpp # Matchmaking tests
└── CMakeLists.txt

docs/
├── API_ARENA.md               # This file
└── ARENA_TEST_CHECKLIST.md    # Manual test checklist

logs/
└── arena.log                  # Runtime arena logs (auto-created)
```

---

*Generated: 2026-02-21*
