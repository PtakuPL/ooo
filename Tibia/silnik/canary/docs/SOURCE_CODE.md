# Canary Server Source Code Documentation

This document provides comprehensive documentation for the Canary server source code, explaining the architecture, key components, and how different files interact.

## Table of Contents

1. [Directory Structure](#directory-structure)
2. [Core Components](#core-components)
3. [Game Logic](#game-logic)
4. [Database Layer](#database-layer)
5. [Network Layer](#network-layer)
6. [Lua Scripting](#lua-scripting)
7. [Internationalization](#internationalization)

---

## Directory Structure

```
src/
├── main.cpp                 # Server entry point
├── canary_server.cpp/hpp    # Main server class
├── core.hpp                 # Core includes
├── declarations.hpp         # Forward declarations
├── pch.hpp                  # Precompiled header
├── account/                 # Account management
├── config/                  # Configuration
├── creatures/               # NPCs, monsters, players
├── database/                # Database abstraction
├── enums/                   # Enumeration types
├── game/                    # Core game logic
├── io/                      # I/O operations
├── items/                   # Item system
├── kv/                      # Key-value storage
├── lib/                     # Utility libraries
├── lua/                     # Lua scripting
├── map/                     # Map management
├── protobuf/                # Protocol buffers
├── security/                # Security features
├── server/                  # Network server
└── utils/                   # Utility functions
```

---

## Core Components

### Entry Point (`main.cpp`, `canary_server.cpp/hpp`)

**Purpose**: Server initialization and main loop.

**Key Functions**:
- `main()` - Entry point, initializes server
- `CanaryServer::run()` - Main server loop
- `CanaryServer::shutdown()` - Graceful shutdown

**Initialization Sequence**:
```
main() → CanaryServer::init() 
      → ConfigManager::load()
      → Database::connect()
      → Map::load()
      → ScriptEnvironment::load()
      → Server::listen()
```

---

### Configuration (`config/`)

**Purpose**: Server configuration management.

| File | Description |
|------|-------------|
| `configmanager.cpp/hpp` | Configuration loading/access |

**Configuration File**: `config.lua.dist`

**Key Settings**:
```lua
-- Server info
serverName = "Canary"
ip = "127.0.0.1"
port = 7172

-- Database
mysqlHost = "127.0.0.1"
mysqlUser = "root"
mysqlPass = ""
mysqlDatabase = "canary"

-- Game
worldType = "pvp"
rateExp = 1
rateLoot = 1
```

---

## Game Logic

### Game Core (`game/`)

**Purpose**: Core game mechanics.

| File | Description |
|------|-------------|
| `game.cpp/hpp` | Main game class |
| `game/scheduling/` | Event scheduling |
| `game/movement/` | Movement handling |
| `game/zones/` | Zone management |

**Game Class Responsibilities**:
- Player management
- World state
- Combat system
- Event dispatching

---

### Creatures (`creatures/`)

**Purpose**: All living entities.

```
creatures/
├── appearance/           # Visual appearance
├── combat/               # Combat system
│   ├── combat.cpp/hpp    # Combat mechanics
│   ├── condition.cpp/hpp # Status conditions
│   └── spells.cpp/hpp    # Spell system
├── creature.cpp/hpp      # Base creature class
├── interactions/         # Creature interactions
├── monsters/             # Monster AI
│   ├── monster.cpp/hpp   # Monster class
│   ├── monsters.cpp/hpp  # Monster manager
│   └── spawns/           # Spawn system
├── npcs/                 # NPC system
│   ├── npc.cpp/hpp       # NPC class
│   └── npcs.cpp/hpp      # NPC manager
└── players/              # Player handling
    ├── player.cpp/hpp    # Player class
    ├── grouping/         # Party system
    ├── imbuements/       # Imbuement system
    ├── management/       # Player management
    ├── vocations/        # Vocation system
    └── wheel/            # Wheel of destiny
```

**Creature Hierarchy**:
```
Thing (base)
  └── Creature
        ├── Player
        ├── Monster
        └── Npc
```

---

### Items (`items/`)

**Purpose**: Item system.

| File | Description |
|------|-------------|
| `item.cpp/hpp` | Base item class |
| `items.cpp/hpp` | Item manager |
| `containers/` | Container handling |
| `functions/` | Item functions |
| `tile.cpp/hpp` | Tile class |
| `weapons/` | Weapon system |

**Item Types**:
- Regular items
- Containers
- Weapons
- Equipment
- Teleports
- Doors

---

### Map (`map/`)

**Purpose**: World map management.

| File | Description |
|------|-------------|
| `map.cpp/hpp` | Map class |
| `mapcache.cpp/hpp` | Map caching |
| `spectators.cpp/hpp` | Spectator tracking |
| `house/` | House system |
| `utils/` | Map utilities |

**Map Features**:
- OTBM map loading
- Tile management
- Pathfinding
- House system
- Spectator lists

---

## Database Layer

### Database (`database/`)

**Purpose**: Database abstraction.

| File | Description |
|------|-------------|
| `database.cpp/hpp` | Database interface |
| `databasemanager.cpp/hpp` | Connection management |
| `databasetasks.cpp/hpp` | Async query tasks |

**Supported Databases**:
- MySQL/MariaDB

**Query Example**:
```cpp
Database& db = Database::getInstance();
DBResult_ptr result = db.storeQuery("SELECT * FROM players WHERE name = 'Player'");
if (result) {
    std::string name = result->getString("name");
}
```

---

## Network Layer

### Server (`server/`)

**Purpose**: Network communication.

```
server/
├── server.cpp/hpp           # Main server
└── network/
    ├── connection/          # Connection handling
    ├── message/             # Message parsing
    ├── protocol/            # Protocol implementation
    │   ├── protocolgame.cpp/hpp     # Game protocol
    │   ├── protocollogin.cpp/hpp    # Login protocol
    │   └── protocolstatus.cpp/hpp   # Status protocol
    └── webhook/             # Discord webhooks
```

**Protocol Stack**:
```
TCP Socket → Connection → Protocol → Game Logic
```

**Message Types**:
- Login messages
- Game messages
- Status queries

---

## Lua Scripting

### Lua (`lua/`)

**Purpose**: Lua scripting engine.

```
lua/
├── creature/              # Creature bindings
├── functions/             # Lua functions
│   ├── core/              # Core functions
│   ├── creatures/         # Creature functions
│   ├── events/            # Event functions
│   ├── items/             # Item functions
│   └── map/               # Map functions
├── global/                # Global bindings
├── modules/               # Lua modules
├── scripts/               # Script loading
└── callbacks/             # Event callbacks
```

**Lua Integration Points**:
- NPC dialogues
- Spells
- Events (onLogin, onDeath, etc.)
- Actions (item use)
- Movements (step on/off)
- Talkactions (commands)

**Example Spell Script**:
```lua
local spell = Spell("instant")

function onCastSpell(creature, variant)
    local target = creature:getTarget()
    if target then
        creature:say("Attack!", TALKTYPE_MONSTER_SAY)
        return combat:execute(creature, variant)
    end
    return false
end

spell:name("Example Spell")
spell:words("exori")
spell:level(20)
spell:mana(40)
spell:register()
```

---

## Internationalization

### I18N Architecture

**Current State**: Server-side text is hardcoded in English.

**Implementation Strategy** (see `docs/INTERNATIONALIZATION.md`):

1. **Translation Key System**:
```cpp
// Before:
player->sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have advanced to level 10!");

// After:
player->sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "LEVEL_ADVANCE", level);
```

2. **Translation Files**: `data/translations/{lang}.json`
```json
{
  "LEVEL_ADVANCE": "You have advanced to level {0}!",
  "DEATH_MESSAGE": "You are dead.",
  "SKILL_ADVANCE": "You advanced in {0} (level {1})."
}
```

3. **Player Locale Setting**:
```sql
ALTER TABLE players ADD COLUMN locale VARCHAR(5) DEFAULT 'en';
```

4. **Protocol Extension**:
```cpp
// New packet type for localized messages
void ProtocolGame::sendLocalizedMessage(uint8_t type, const std::string& key, 
                                        const std::vector<std::string>& args);
```

---

## Key Source Files for I18N

### Files Requiring Modification

| File | Purpose | Changes Needed |
|------|---------|----------------|
| `creatures/players/player.cpp` | Player class | Add locale property, translation methods |
| `server/network/protocol/protocolgame.cpp` | Game protocol | Add localized message packets |
| `game/game.cpp` | Game logic | Use translation keys for messages |
| `lua/functions/creatures/player_functions.cpp` | Lua bindings | Expose translation to Lua |

### New Files to Create

| File | Purpose |
|------|---------|
| `utils/i18n/translator.cpp/hpp` | Translation system |
| `utils/i18n/locale.cpp/hpp` | Locale management |
| `data/translations/*.json` | Translation files |

---

## Message Categories for Translation

### Priority 1 - Player Feedback
- Level up messages
- Skill advance messages
- Death messages
- Loot messages
- Quest messages

### Priority 2 - NPC Dialogues
- Shop dialogues
- Quest NPCs
- Tutorial messages

### Priority 3 - System Messages
- Login messages
- Server broadcasts
- Error messages

### Priority 4 - Combat
- Spell names
- Damage messages
- Effect descriptions

---

## Translation Implementation Steps

1. **Create Translation Manager**:
```cpp
class Translator {
public:
    static Translator& getInstance();
    std::string translate(const std::string& locale, 
                         const std::string& key,
                         const std::vector<std::string>& args = {});
    void loadTranslations(const std::string& locale);
private:
    std::map<std::string, std::map<std::string, std::string>> translations;
};
```

2. **Modify Player Class**:
```cpp
class Player {
    // ... existing code ...
    std::string locale = "en";
public:
    void setLocale(const std::string& loc) { locale = loc; }
    const std::string& getLocale() const { return locale; }
    void sendLocalizedMessage(MessageClasses type, const std::string& key,
                             const std::vector<std::string>& args = {});
};
```

3. **Add Protocol Support**:
```cpp
// In ProtocolGame
void ProtocolGame::sendLocalizedTextMessage(const TextMessage& message,
                                           const std::string& translationKey,
                                           const std::vector<std::string>& args);
```

4. **Create Translation Files**: 
   - 53+ language files matching client locales
   - JSON format for easy editing

---

## Build Integration

### CMake Updates
```cmake
# Add I18N source files
set(I18N_SOURCES
    src/utils/i18n/translator.cpp
    src/utils/i18n/locale.cpp
)

# Add JSON library for translation parsing
find_package(nlohmann_json REQUIRED)
target_link_libraries(canary nlohmann_json::nlohmann_json)
```

### Dependency Addition
```json
// vcpkg.json
{
  "dependencies": [
    "nlohmann-json"
  ]
}
```

---

*This documentation is part of the Canary Server I18N implementation project.*
*Last updated: December 2024*
