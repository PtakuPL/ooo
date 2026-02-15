# OTClient Module Documentation

This document provides comprehensive documentation for each module in the OTClient, explaining what each module does, how it works, and which files it interacts with.

## Table of Contents

1. [Core Modules](#core-modules)
2. [Client Modules](#client-modules)
3. [Game Modules](#game-modules)
4. [Library Modules](#library-modules)

---

## Core Modules

### `corelib/`
**Purpose**: Core library providing fundamental Lua utilities and OTClient framework bindings.

**Key Files**:
- `init.lua` - Module initialization
- `bitlib.lua` - Bitwise operations
- `color.lua` - Color manipulation utilities
- `const.lua` - Global constants
- `keyboard.lua` - Keyboard input handling
- `mouse.lua` - Mouse input handling
- `network.lua` - Network protocol utilities
- `outputmessage.lua` - Message output formatting
- `position.lua` - Position/coordinate utilities
- `rect.lua` - Rectangle geometry
- `string.lua` - Extended string functions
- `table.lua` - Extended table functions
- `ui/` - UI widget library

**Interactions**: All game modules depend on corelib for basic functionality.

---

### `modulelib/`
**Purpose**: Module loading and management system.

**Key Files**:
- `init.lua` - Module loader initialization

**Interactions**: Manages loading/unloading of all other modules.

---

### `gamelib/`
**Purpose**: Game-specific library providing Tibia protocol and game object utilities.

**Key Files**:
- `init.lua` - Game library initialization
- `creature.lua` - Creature handling
- `game.lua` - Core game state
- `item.lua` - Item handling
- `map.lua` - Map/tile handling
- `player.lua` - Player state
- `protocol.lua` - Protocol messages
- `spell.lua` - Spell system
- `thing.lua` - Base game object

**Interactions**: Used by all game_* modules for Tibia-specific functionality.

---

## Client Modules

### `client/`
**Purpose**: Main client initialization and management.

**Key Files**:
- `init.lua` - Client startup
- `client.lua` - Client state management

**Interactions**: Entry point that loads all other modules.

---

### `client_locales/`
**Purpose**: **Internationalization (I18N) system** - Manages multi-language support for 53+ languages.

**Key Files**:
- `init.lua` - Locale system initialization
- `locales.lua` - Locale management API
- `neededtranslations.lua` - List of strings requiring translation

**Supported Languages** (53 locales):
| Region | Languages |
|--------|-----------|
| Western European | English, German, Spanish, French, Italian, Portuguese, Dutch, Swedish, Danish, Norwegian, Finnish, Catalan, Galician, Icelandic |
| Eastern European | Polish, Czech, Slovak, Hungarian, Romanian, Bulgarian, Croatian, Serbian, Slovenian, Macedonian, Albanian, Greek |
| Baltic | Lithuanian, Latvian, Estonian |
| Asian | Chinese, Japanese, Korean, Thai, Vietnamese, Hindi, Bengali, Indonesian, Malay, Filipino |
| Middle Eastern (RTL) | Turkish, Arabic, Hebrew, Persian |
| Slavic/Cyrillic | Russian, Ukrainian |
| Caucasus & Central Asia | Georgian, Armenian, Azerbaijani, Kazakh, Uzbek |
| African | Afrikaans, Swahili |
| Regional | Basque |

**Interactions**: 
- `data/locales/*.lua` - Individual locale translation files
- Used by all UI modules for text display
- Text rendering pipeline (FreeType + HarfBuzz + FriBidi)

---

### `client_entergame/`
**Purpose**: Login screen and character selection interface.

**Key Files**:
- `init.lua` - Module initialization
- `entergame.lua` - Login logic
- `characterlist.lua` - Character list display
- `entergame.otui` - UI layout

**Interactions**: 
- `client_serverlist/` for server selection
- Network protocol for authentication

---

### `client_serverlist/`
**Purpose**: Server list management and selection.

**Key Files**:
- `init.lua` - Module initialization  
- `serverlist.lua` - Server list logic
- `serverlist.otui` - UI layout

**Interactions**: `client_entergame/` for login flow.

---

### `client_options/`
**Purpose**: Game settings and options menu.

**Key Files**:
- `init.lua` - Module initialization
- `options.lua` - Options logic
- `options.otui` - UI layout

**Interactions**: 
- Graphics settings
- Audio settings
- Control settings
- `client_locales/` for language selection

---

### `client_topmenu/`
**Purpose**: Top menu bar with main navigation buttons.

**Key Files**:
- `init.lua` - Module initialization
- `topmenu.lua` - Menu logic
- `topmenu.otui` - UI layout

**Interactions**: Provides access to options, terminal, and other client features.

---

### `client_bottommenu/`
**Purpose**: Bottom menu bar for game controls.

**Key Files**:
- `init.lua` - Module initialization
- `bottommenu.lua` - Menu logic
- `bottommenu.otui` - UI layout

**Interactions**: Quick access to game features during gameplay.

---

### `client_terminal/`
**Purpose**: Developer console/terminal for debugging.

**Key Files**:
- `init.lua` - Module initialization
- `terminal.lua` - Terminal logic
- `terminal.otui` - UI layout

**Interactions**: Lua command execution, debugging output.

---

### `client_styles/`
**Purpose**: Global UI styling and themes.

**Key Files**:
- `init.lua` - Style initialization
- `*.otui` - Style definitions

**Interactions**: All UI modules use these styles.

---

### `client_background/`
**Purpose**: Background image/animation management.

**Key Files**:
- `init.lua` - Module initialization
- `background.lua` - Background logic

**Interactions**: Displayed behind login screen.

---

### `client_debug_info/`
**Purpose**: Debug information overlay (FPS, memory, etc.).

**Key Files**:
- `init.lua` - Module initialization
- `debuginfo.lua` - Debug display logic

**Interactions**: Overlay on all screens when enabled.

---

## Game Modules

### `game_interface/`
**Purpose**: Main game interface layout and management.

**Key Files**:
- `init.lua` - Module initialization
- `gameinterface.lua` - Interface logic
- `gameinterface.otui` - UI layout

**Interactions**: Container for all in-game UI panels.

---

### `game_inventory/`
**Purpose**: Player inventory display and management.

**Key Files**:
- `init.lua` - Module initialization
- `inventory.lua` - Inventory logic
- `inventory.otui` - UI layout

**Interactions**: 
- `gamelib/item.lua` for item handling
- Equipment slots, bags/containers

---

### `game_skills/`
**Purpose**: Player skills panel display.

**Key Files**:
- `init.lua` - Module initialization
- `skills.lua` - Skills logic
- `skills.otui` - UI layout

**Interactions**: Displays player skill levels and progress.

---

### `game_healthinfo/`
**Purpose**: Health, mana, and status display.

**Key Files**:
- `init.lua` - Module initialization
- `healthinfo.lua` - Health display logic
- `healthinfo.otui` - UI layout

**Interactions**: Real-time player vitals display.

---

### `game_console/`
**Purpose**: In-game chat console.

**Key Files**:
- `init.lua` - Module initialization
- `console.lua` - Console logic
- `console.otui` - UI layout

**Interactions**: 
- Chat channels
- Private messages
- Server messages

---

### `game_battle/`
**Purpose**: Battle list showing nearby creatures.

**Key Files**:
- `init.lua` - Module initialization
- `battle.lua` - Battle list logic
- `battle.otui` - UI layout

**Interactions**: 
- `gamelib/creature.lua` for creature data
- Combat targeting

---

### `game_viplist/`
**Purpose**: VIP (friends) list management.

**Key Files**:
- `init.lua` - Module initialization
- `viplist.lua` - VIP logic
- `viplist.otui` - UI layout

**Interactions**: Online status tracking of friends.

---

### `game_minimap/`
**Purpose**: Minimap display and navigation.

**Key Files**:
- `init.lua` - Module initialization
- `minimap.lua` - Minimap logic
- `minimap.otui` - UI layout

**Interactions**: 
- `gamelib/map.lua` for map data
- Map markers and navigation

---

### `game_hotkeys/`
**Purpose**: Hotkey configuration and management.

**Key Files**:
- `init.lua` - Module initialization
- `hotkeys.lua` - Hotkey logic
- `hotkeys.otui` - UI layout

**Interactions**: 
- Spell casting hotkeys
- Item use hotkeys
- Custom action hotkeys

---

### `game_market/`
**Purpose**: In-game market/auction house.

**Key Files**:
- `init.lua` - Module initialization
- `market.lua` - Market logic
- `market.otui` - UI layout

**Interactions**: Buy/sell items on the market.

---

### `game_npctrade/`
**Purpose**: NPC trading interface.

**Key Files**:
- `init.lua` - Module initialization
- `npctrade.lua` - Trade logic
- `npctrade.otui` - UI layout

**Interactions**: Buy/sell items from NPCs.

---

### `game_outfit/`
**Purpose**: Character outfit/appearance customization.

**Key Files**:
- `init.lua` - Module initialization
- `outfit.lua` - Outfit logic
- `outfit.otui` - UI layout

**Interactions**: Change player appearance, addons, mounts.

---

### `game_spelllist/`
**Purpose**: Spell list and spell information.

**Key Files**:
- `init.lua` - Module initialization
- `spelllist.lua` - Spell list logic
- `spelllist.otui` - UI layout

**Interactions**: 
- `gamelib/spell.lua` for spell data
- Hotkey assignment

---

### `game_cooldown/`
**Purpose**: Spell and ability cooldown display.

**Key Files**:
- `init.lua` - Module initialization
- `cooldown.lua` - Cooldown logic
- `cooldown.otui` - UI layout

**Interactions**: Visual cooldown indicators.

---

### `game_questlog/`
**Purpose**: Quest tracking and log.

**Key Files**:
- `init.lua` - Module initialization
- `questlog.lua` - Quest logic
- `questlog.otui` - UI layout

**Interactions**: Track active and completed quests.

---

### `game_containers/`
**Purpose**: Container (bag/backpack) windows.

**Key Files**:
- `init.lua` - Module initialization
- `containers.lua` - Container logic
- `container.otui` - UI layout

**Interactions**: 
- `gamelib/item.lua` for item handling
- Drag and drop items

---

### `game_playerdeath/`
**Purpose**: Death dialog and respawn.

**Key Files**:
- `init.lua` - Module initialization
- `playerdeath.lua` - Death handling

**Interactions**: Displayed on player death.

---

### `game_textwindow/`
**Purpose**: Text window display (signs, books, etc.).

**Key Files**:
- `init.lua` - Module initialization
- `textwindow.lua` - Text window logic
- `textwindow.otui` - UI layout

**Interactions**: Read/write in-game text items.

---

### `game_textmessage/`
**Purpose**: On-screen text message display.

**Key Files**:
- `init.lua` - Module initialization
- `textmessage.lua` - Message display logic

**Interactions**: Server messages, status messages.

---

### `game_walk/`
**Purpose**: Character movement and pathfinding.

**Key Files**:
- `init.lua` - Module initialization
- `walk.lua` - Walk logic

**Interactions**: 
- Keyboard movement
- Auto-walk pathfinding

---

### `game_modaldialog/`
**Purpose**: Modal dialog windows.

**Key Files**:
- `init.lua` - Module initialization
- `modaldialog.lua` - Dialog logic
- `modaldialog.otui` - UI layout

**Interactions**: Server-sent modal dialogs.

---

### `game_bugreport/`
**Purpose**: Bug report submission.

**Key Files**:
- `init.lua` - Module initialization
- `bugreport.lua` - Bug report logic
- `bugreport.otui` - UI layout

**Interactions**: Submit bug reports to server.

---

### `game_screenshot/`
**Purpose**: Screenshot capture functionality.

**Key Files**:
- `init.lua` - Module initialization
- `screenshot.lua` - Screenshot logic

**Interactions**: Capture and save screenshots.

---

## Additional Game Modules

| Module | Purpose |
|--------|---------|
| `game_actionbar/` | Action bar for quick abilities |
| `game_attachedeffects/` | Attached visual effects |
| `game_blessing/` | Blessing status display |
| `game_creatureinformation/` | Creature info panel |
| `game_cyclopedia/` | Cyclopedia (bestiary, etc.) |
| `game_features/` | Feature flags management |
| `game_healthcircle/` | Circular health display |
| `game_highscore/` | Highscore display |
| `game_imbuementtracker/` | Imbuement tracking |
| `game_imbuing/` | Imbuement system |
| `game_joystick/` | Joystick/gamepad support |
| `game_mainpanel/` | Main game panel |
| `game_playermount/` | Mount management |
| `game_playertrade/` | Player-to-player trading |
| `game_prey/` | Prey system |
| `game_quickloot/` | Quick loot settings |
| `game_rewardwall/` | Reward wall display |
| `game_ruleviolation/` | Rule violation reporting |
| `game_shaders/` | Shader effects |
| `game_shop/` | In-game shop |
| `game_shortcuts/` | Keyboard shortcuts |
| `game_stash/` | Stash/depot management |
| `game_store/` | Tibia store |
| `game_tasks/` | Task/achievement tracking |
| `game_things/` | Thing (item/creature) info |
| `game_unjustifiedpoints/` | Unjustified kill tracking |

---

## Library Modules

### `startup/`
**Purpose**: Initial startup sequence.

**Interactions**: First module loaded, initializes client.

---

### `updater/`
**Purpose**: Client update system.

**Interactions**: Check for and apply updates.

---

## Module Dependencies

```
startup/
  └── client/
        ├── corelib/
        ├── modulelib/
        ├── client_locales/
        ├── client_styles/
        ├── client_background/
        ├── client_topmenu/
        ├── client_bottommenu/
        ├── client_entergame/
        │     └── client_serverlist/
        ├── client_options/
        └── gamelib/
              └── game_*/ (all game modules)
```

---

## Adding New Modules

1. Create a new directory under `modules/`
2. Create `init.lua` with module definition:
```lua
Module
  name: my_module
  description: Module description
  author: Your Name
  website: https://example.com
  version: 1.0
  sandboxed: true
  autoload: true
  autoload-priority: 1000
  reloadable: true
  scripts: [ mymodule.lua ]
```
3. Implement module logic in `mymodule.lua`
4. Add UI in `mymodule.otui` if needed

---

## Internationalization Integration

All modules should use the translation function `tr()` for user-facing text:

```lua
local label = g_ui.createWidget('Label')
label:setText(tr('Hello World'))  -- Will be translated based on locale
```

Translation files are located in `data/locales/{lang}.lua` and follow this format:
```lua
locale = {
  name = "en",
  languageName = "English",
  translation = {
    ["Hello World"] = "Hello World",
    -- Add more translations...
  }
}
modules.client_locales.installLocale(locale)
```

---

*This documentation is part of the OTClient I18N implementation project.*
*Last updated: December 2024*
