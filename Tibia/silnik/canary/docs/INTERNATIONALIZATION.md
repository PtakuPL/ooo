# Canary Server Architecture and Internationalization Documentation

This document provides a comprehensive overview of the Canary server project structure, explaining how to implement multi-language support (50+ languages) and how the components interact.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Directory Structure](#directory-structure)
3. [Core Components](#core-components)
4. [Internationalization Strategy](#internationalization-strategy)
5. [Client-Server Integration](#client-server-integration)
6. [Implementation Guide](#implementation-guide)

---

## Project Overview

Canary is an open-source Tibia server emulator built with modern C++20. It serves as the backend for OTClient connections.

### Key Features
- Modern C++20 codebase
- Lua scripting for game logic
- Protocol buffer support
- MySQL/MariaDB database support
- Multi-threaded architecture

---

## Directory Structure

```
canary/
├── src/                    # Main source code
│   ├── server/             # Network server
│   ├── game/               # Game logic
│   ├── creatures/          # Player/NPC/Monster handling
│   ├── items/              # Item management
│   ├── map/                # Map handling
│   ├── lua/                # Lua bindings
│   ├── database/           # Database layer
│   ├── io/                 # I/O operations
│   ├── utils/              # Utility functions
│   ├── kv/                 # Key-value storage
│   ├── security/           # Security features
│   └── protobuf/           # Protocol definitions
├── data/                   # Server data files
├── data-canary/            # Canary-specific data
├── data-otservbr-global/   # OTServBR data
├── docker/                 # Docker configuration
└── docs/                   # Documentation
```

---

## Core Components

### 1. Server Module (`src/server/`)

Handles all network communication:

| File | Purpose | Interactions |
|------|---------|--------------|
| `server.cpp` | Main server loop | All network |
| `protocol*.cpp` | Protocol handlers | Game, Login |
| `connection.cpp` | Connection management | Clients |

### 2. Game Module (`src/game/`)

Core game logic:

| File | Purpose | Interactions |
|------|---------|--------------|
| `game.cpp` | Main game state | All modules |
| `scheduling/` | Task scheduling | Events |
| `functions/` | Game functions | Lua bindings |

### 3. Creatures Module (`src/creatures/`)

Entity management:

| Subdirectory | Purpose |
|--------------|---------|
| `players/` | Player handling, accounts |
| `npcs/` | NPC behavior and dialogue |
| `monsters/` | Monster AI |
| `combat/` | Combat calculations |

### 4. Items Module (`src/items/`)

Item and inventory management.

### 5. Lua Module (`src/lua/`)

Lua scripting interface:

| Subdirectory | Purpose |
|--------------|---------|
| `functions/` | Lua function bindings |
| `scripts/` | Core Lua scripts |

### 6. Database Module (`src/database/`)

Database abstraction layer supporting MySQL/MariaDB.

### 7. I/O Module (`src/io/`)

File I/O and resource loading.

---

## Internationalization Strategy

### Current State

The server primarily handles game logic while text rendering is handled by the client. However, server-side internationalization is needed for:

1. **NPC Dialogues** - Conversations with NPCs
2. **Item Names/Descriptions** - Item text
3. **Quest Text** - Quest descriptions and objectives
4. **System Messages** - Server announcements
5. **Error Messages** - User-facing errors

### Implementation Approach

#### 1. Translation Key System

Create a translation system using keys instead of hardcoded text:

```cpp
// utils/i18n.hpp
class I18N {
public:
    static std::string translate(const std::string& key, 
                                  const std::string& locale = "en");
    static void loadTranslations(const std::string& locale);
    
private:
    static std::unordered_map<std::string, 
           std::unordered_map<std::string, std::string>> translations_;
};
```

#### 2. Translation Files Structure

```
data/i18n/
├── en/
│   ├── npcs.json
│   ├── items.json
│   ├── quests.json
│   └── system.json
├── pl/
│   └── ... (same structure)
├── pt/
│   └── ...
└── (50+ more languages)
```

#### 3. JSON Translation Format

```json
{
  "npc.greeting": "Hello, adventurer!",
  "npc.farewell": "Safe travels!",
  "item.sword": "Sword",
  "quest.intro": "Your quest begins here..."
}
```

#### 4. Per-Player Locale

Store player language preference:

```sql
ALTER TABLE players ADD COLUMN locale VARCHAR(5) DEFAULT 'en';
```

Set the server-wide default via `serverDefaultLocale` in `config.lua`.

### Files to Modify

| File | Changes Needed |
|------|----------------|
| `src/creatures/npcs/npc.cpp` | Use I18N for dialogue |
| `src/items/item.cpp` | Translatable names |
| `src/game/game.cpp` | System messages |
| `src/server/protocol*.cpp` | Send locale-aware text |
| `src/creatures/players/player.cpp` | Store/use player locale |

---

## Client-Server Integration

### Protocol Enhancement

For multi-language support, the protocol should:

1. **Send locale preference** from client to server
2. **Send translated text** from server to client
3. **Support UTF-8** throughout the pipeline

### Message Flow

```
Client                          Server
   |                               |
   |-- Login (with locale) ------->|
   |                               |-- Load translations
   |                               |
   |<-- NPC Dialogue (translated) -|
   |<-- Item Names (translated) ---|
```

### OTClient Integration

The OTClient already supports UTF-8 and multi-language rendering. The server integration requires:

1. **Protocol extension** for locale
2. **Server-side translation** system
3. **Database schema** for player locale

---

## Implementation Guide

### Step 1: Create I18N Utility

```cpp
// src/utils/i18n.hpp
#pragma once
#include <string>
#include <unordered_map>

namespace i18n {

class Translator {
public:
    static Translator& getInstance();
    
    void loadLocale(const std::string& locale);
    std::string get(const std::string& key, 
                    const std::string& locale = "en") const;
    
    // Supported locales (50+)
    static const std::vector<std::string> SUPPORTED_LOCALES;
    
private:
    std::unordered_map<std::string, 
        std::unordered_map<std::string, std::string>> translations_;
};

} // namespace i18n
```

### Step 2: Add Translation Files

Create translation files for each supported language:

```json
// data/i18n/en/common.json
{
    "welcome_message": "Welcome to the game!",
    "logout_message": "Goodbye!",
    "level_up": "You advanced to level {level}!"
}
```

Use `python Tibia/silnik/canary/tools/export_items_translations.py --locale en --locale pl` to bootstrap the 36k+ item name entries (the script keeps files in `i18n/<locale>/items.json` in sync with `data/items/items.xml`).

### Step 3: Integrate with NPCs

```cpp
// In npc.cpp
void Npc::onCreatureSay(Creature* creature, SpeakClasses type, 
                         const std::string& text) {
    if (auto player = creature->getPlayer()) {
        std::string locale = player->getLocale();
        std::string response = i18n::Translator::getInstance()
            .get("npc." + npcType + ".greeting", locale);
        // ...
    }
}
```

### Step 4: Update Protocol

Extend login protocol to include locale preference.

### Step 5: Database Migration

```sql
-- Migration script
ALTER TABLE players ADD COLUMN locale VARCHAR(5) DEFAULT 'en';
CREATE INDEX idx_players_locale ON players(locale);
```

---

## Supported Languages (Target: 50+)

### Tier 1 - Major Languages
- English (en)
- Spanish (es)
- Portuguese (pt)
- Polish (pl)
- German (de)
- French (fr)
- Russian (ru)
- Chinese (zh)

### Tier 2 - European
- Italian (it), Dutch (nl), Swedish (sv), Norwegian (no), Danish (da)
- Finnish (fi), Czech (cs), Hungarian (hu), Romanian (ro)

### Tier 3 - Asian
- Japanese (ja), Korean (ko), Thai (th), Vietnamese (vi)
- Indonesian (id), Malay (ms), Hindi (hi)

### Tier 4 - Other
- Arabic (ar), Hebrew (he), Turkish (tr), Greek (el)
- Ukrainian (uk), Croatian (hr), Serbian (sr), Bulgarian (bg)
- And more...

---

## Testing

### Unit Tests

Create tests for the translation system:

```cpp
// tests/unit/i18n_test.cpp
TEST(I18N, LoadsTranslations) {
    auto& translator = i18n::Translator::getInstance();
    translator.loadLocale("en");
    
    EXPECT_EQ("Hello!", translator.get("greeting", "en"));
}

TEST(I18N, FallbackToEnglish) {
    auto& translator = i18n::Translator::getInstance();
    
    // Unknown key should fallback
    EXPECT_FALSE(translator.get("unknown.key", "xx").empty());
}
```

### Integration Tests

Test end-to-end:
1. Client sends locale preference
2. Server responds with translated text
3. Client renders correctly

---

## Related Documentation

- OTClient: `testyy/docs/ARCHITECTURE.md`
- I18N Progress: `testyy/I18N_Progress.md`
- I18N Next Steps: `testyy/I18N_Next_Steps.md`

---

*Last updated: December 2025*
