# Canary Server Lua Scripting API Documentation

This document provides comprehensive documentation for Lua scripting in the Canary server, including internationalization support for 53+ languages.

## Table of Contents

1. [Overview](#overview)
2. [Directory Structure](#directory-structure)
3. [Core Libraries](#core-libraries)
4. [Script Types](#script-types)
5. [Internationalization in Scripts](#internationalization-in-scripts)
6. [API Reference](#api-reference)
7. [Best Practices](#best-practices)

---

## Overview

Canary uses Lua 5.4 for scripting game logic, events, NPCs, monsters, and spells. The Lua environment provides extensive APIs for interacting with the game world.

### Key Features
- Modern Lua 5.4 support
- Object-oriented design with metatables
- Event-driven architecture
- Extensive game API
- Multi-language support through client localization

---

## Directory Structure

```
data/
├── core.lua              # Core initialization
├── global.lua            # Global variables and functions
├── stages.lua            # Experience stages configuration
├── libs/                 # Library modules
│   ├── libs.lua          # Library loader
│   ├── core/             # Core libraries
│   ├── compat/           # Compatibility modules
│   ├── debugging/        # Debug utilities
│   ├── functions/        # Utility functions
│   ├── systems/          # Game systems
│   └── tables/           # Data tables
├── scripts/              # Game scripts
│   ├── actions/          # Item actions
│   ├── creaturescripts/  # Creature events
│   ├── events/           # Global events
│   ├── globalevents/     # Scheduled events
│   ├── monsters/         # Monster definitions
│   ├── movements/        # Tile movements
│   ├── npcs/             # NPC scripts
│   ├── spells/           # Spell implementations
│   ├── talkactions/      # Chat commands
│   └── weapons/          # Weapon scripts
├── npclib/               # NPC library
├── modules/              # Server modules
├── chatchannels/         # Chat channel definitions
└── events/               # Event handlers
```

---

## Core Libraries

### libs/core/

Core functionality modules:

| File | Purpose |
|------|---------|
| `bits.lua` | Bit manipulation functions |
| `container.lua` | Container operations |
| `item_type.lua` | Item type utilities |
| `itemfunctions.lua` | Item manipulation |
| `player.lua` | Player utilities |
| `position.lua` | Position calculations |
| `string.lua` | String extensions |
| `table.lua` | Table utilities |

### libs/functions/

Utility function modules:

| File | Purpose |
|------|---------|
| `functions.lua` | General utility functions |
| `boss_lever.lua` | Boss lever system |
| `exercise_training.lua` | Training dummy system |
| `hazard_system.lua` | Hazard zone system |
| `forge_functions.lua` | Forge system |

### libs/systems/

Game system modules:

| File | Purpose |
|------|---------|
| `concoctions.lua` | Alchemy/potion system |
| `daily_reward.lua` | Daily reward system |
| `features.lua` | Feature toggles |
| `hireling.lua` | Hireling NPC system |
| `imbuing.lua` | Imbuing system |
| `prey.lua` | Prey system |
| `wheel.lua` | Wheel of Destiny |

---

## Script Types

### Actions (`scripts/actions/`)

Handle item use events:

```lua
local myAction = Action()

function myAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Send localized message (client handles translation)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "You used the item.")
    return true
end

myAction:id(ITEM_ID)
myAction:register()
```

### CreatureScripts (`scripts/creaturescripts/`)

Handle creature events:

```lua
local loginEvent = CreatureEvent("PlayerLogin")

function loginEvent.onLogin(player)
    -- Welcome message - client translates based on locale
    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Welcome to the server!")
    return true
end

loginEvent:register()
```

### TalkActions (`scripts/talkactions/`)

Handle chat commands:

```lua
local helpCommand = TalkAction("!help", "/help")

function helpCommand.onSay(player, words, param)
    -- Commands work in any language
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Available commands: !help, !online, !stats")
    return true
end

helpCommand:separator(" ")
helpCommand:groupType("normal")
helpCommand:register()
```

### GlobalEvents (`scripts/globalevents/`)

Scheduled server events:

```lua
local serverSave = GlobalEvent("ServerSave")

function serverSave.onTime(interval)
    -- Broadcast supports client localization
    Game.broadcastMessage("Server save in 5 minutes!", MESSAGE_STATUS_WARNING)
    return true
end

serverSave:time("06:00:00")
serverSave:register()
```

### Spells (`scripts/spells/`)

Spell implementations:

```lua
local healSpell = Spell(SPELL_INSTANT)

function healSpell.onCastSpell(creature, variant)
    local player = creature:getPlayer()
    if player then
        player:addHealth(100)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You feel refreshed!")
    end
    return true
end

healSpell:name("Light Healing")
healSpell:words("exura")
healSpell:level(8)
healSpell:mana(20)
healSpell:group("healing")
healSpell:cooldown(1000)
healSpell:groupCooldown(1000)
healSpell:register()
```

---

## Internationalization in Scripts

### Client-Side Translation

The Canary server sends messages in a base language (usually English). The OTClient handles translation using its locale system.

### Message Types

```lua
-- Standard messages (translated by client)
player:sendTextMessage(MESSAGE_INFO_DESCR, "Your message here")

-- Channel messages
player:sendChannelMessage(nil, "Channel message", TALKTYPE_CHANNEL_R1, CHANNEL_HELP)

-- Private messages
player:sendPrivateMessage(fromPlayer, "Private message", TALKTYPE_PRIVATE_FROM)
```

### Best Practices for I18N

1. **Use Simple Strings**: Avoid complex concatenations
```lua
-- Good - easy to translate
player:sendTextMessage(MESSAGE_INFO_DESCR, "You gained 100 experience points.")

-- Avoid - hard to translate
player:sendTextMessage(MESSAGE_INFO_DESCR, "You " .. action .. " " .. count .. " " .. item)
```

2. **Use Format Strings**: Client can handle placeholders
```lua
-- Format strings allow proper localization
local message = string.format("You have %d gold coins.", player:getMoney())
```

3. **Consistent Terminology**: Use same terms throughout
```lua
-- Always use same terms for game concepts
"Experience Points"  -- not "XP", "Exp", "experience"
"Gold Coins"         -- not "gold", "money", "gp"
"Health Points"      -- not "HP", "health", "life"
```

---

## API Reference

### Player Object

```lua
-- Information
player:getName()           -- Get player name
player:getLevel()          -- Get level
player:getExperience()     -- Get experience
player:getVocation()       -- Get vocation object
player:getMoney()          -- Get gold coins
player:getCapacity()       -- Get capacity

-- Modification
player:addExperience(exp, sendText)
player:addMoney(amount)
player:addItem(itemId, count, canDropOnMap, subType)
player:removeItem(itemId, count, subType, ignoreEquipped)

-- Communication
player:sendTextMessage(type, message)
player:sendChannelMessage(author, text, type, channelId)
player:showTextDialog(itemId, text, canWrite, length)

-- Movement
player:teleportTo(position, pushMovement)
player:getPosition()
```

### Creature Object

```lua
-- Information
creature:getName()
creature:getHealth()
creature:getMaxHealth()
creature:getMana()
creature:getMaxMana()
creature:getPosition()
creature:getDirection()

-- Modification
creature:addHealth(healthChange)
creature:addMana(manaChange)
creature:say(text, type, ghost, target, position)
creature:remove()
```

### Item Object

```lua
-- Information
item:getId()
item:getCount()
item:getName()
item:getWeight()
item:getAttribute(key)

-- Modification
item:setAttribute(key, value)
item:transform(newItemId)
item:remove(count)
item:moveTo(destination)
```

### Position Object

```lua
-- Creation
local pos = Position(x, y, z)

-- Methods
pos:getDistance(destPos)
pos:isSightClear(destPos)
pos:sendMagicEffect(effect)
pos:sendDistanceEffect(destPos, effect)

-- Tile access
local tile = Tile(pos)
```

### Game Functions

```lua
-- Broadcasting
Game.broadcastMessage(message, type)

-- World information
Game.getWorldType()
Game.getPlayers()
Game.getMonsters()
Game.getNpcs()

-- Item/creature creation
Game.createItem(itemId, count, position)
Game.createMonster(name, position, extended, force)
Game.createNpc(name, position)
```

---

## Best Practices

### 1. Error Handling

```lua
local function safeOperation(player)
    if not player then
        return false
    end
    
    local item = player:getItemById(ITEM_ID)
    if not item then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Item not found.")
        return false
    end
    
    return true
end
```

### 2. Performance

```lua
-- Cache repeated lookups
local playerPos = player:getPosition()
local nearbyCreatures = Game.getSpectators(playerPos, false, false, 7, 7, 5, 5)

-- Use local variables
local math_random = math.random
for i = 1, 1000 do
    local value = math_random(1, 100)
end
```

### 3. Code Organization

```lua
-- Group related functionality
local MySystem = {}

function MySystem.init()
    -- Initialization
end

function MySystem.process(player)
    -- Processing logic
end

function MySystem.cleanup()
    -- Cleanup
end

return MySystem
```

### 4. Logging

```lua
-- Use built-in logging
Spdlog.info("Player " .. player:getName() .. " performed action")
Spdlog.warn("Warning: unusual behavior detected")
Spdlog.error("Error: operation failed")
```

---

## Supported Languages in Client

The OTClient supports 53 languages for UI translation:

| Region | Languages |
|--------|-----------|
| Western European | English, German, Spanish, French, Italian, Portuguese, Dutch, Swedish, Danish, Norwegian, Finnish, Icelandic |
| Eastern European | Polish, Czech, Hungarian, Romanian, Bulgarian, Slovak, Croatian, Serbian, Slovenian, Albanian, Macedonian |
| Baltic | Lithuanian, Latvian, Estonian |
| Slavic/Cyrillic | Russian, Ukrainian, Belarusian |
| Asian | Chinese, Japanese, Korean, Vietnamese, Thai, Hindi, Indonesian, Malay, Filipino, Bengali |
| Middle Eastern (RTL) | Arabic, Hebrew, Persian, Turkish |
| Caucasus | Georgian, Armenian, Azerbaijani |
| Central Asian | Kazakh, Uzbek |
| African | Afrikaans, Swahili |
| Other | Basque, Catalan, Galician, Greek |

Server messages are sent in the base language, and OTClient translates them based on the user's selected locale.

---

## Version Information

- **Canary Server**: Modern C++20
- **Lua Version**: 5.4
- **Protocol**: 12.x - 13.x
- **Languages Supported**: 53

---

*This documentation is part of the Canary Server I18N initiative. For OTClient-specific documentation, see the testyy/docs/ folder.*
