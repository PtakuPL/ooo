# OTClient Source Code Documentation

This document provides comprehensive documentation for the C++ source code of OTClient, explaining the architecture, key components, and how different files interact.

## Table of Contents

1. [Directory Structure](#directory-structure)
2. [Framework Layer](#framework-layer)
3. [Client Layer](#client-layer)
4. [Build System](#build-system)

---

## Directory Structure

```
src/
├── main.cpp                 # Application entry point
├── androidmain.cpp          # Android-specific entry point
├── gitinfo.h                # Git version information
├── framework/               # Core framework (platform-independent)
│   ├── core/                # Core utilities
│   ├── graphics/            # Rendering system
│   ├── input/               # Input handling
│   ├── luaengine/           # Lua scripting
│   ├── net/                 # Networking
│   ├── otml/                # OTML parser
│   ├── platform/            # Platform abstraction
│   ├── sound/               # Audio system
│   ├── stdext/              # Standard library extensions
│   ├── ui/                  # UI framework
│   └── xml/                 # XML parser
├── client/                  # Tibia client implementation
│   ├── creatures/           # Creature handling
│   ├── game/                # Game state
│   ├── items/               # Item handling
│   ├── map/                 # Map rendering
│   ├── things/              # Thing definitions
│   └── ui/                  # Client-specific UI
├── protobuf/                # Protocol buffer definitions
└── stduuid/                 # UUID generation
```

---

## Framework Layer

### Core (`framework/core/`)

**Purpose**: Fundamental utilities and application management.

| File | Description |
|------|-------------|
| `application.cpp/h` | Main application class, event loop |
| `asyncdispatcher.cpp/h` | Asynchronous task dispatching |
| `binarytree.cpp/h` | Binary tree data structure |
| `clock.cpp/h` | High-resolution timing |
| `config.h` | Build configuration |
| `configmanager.cpp/h` | Configuration file management |
| `eventdispatcher.cpp/h` | Event system |
| `filestream.cpp/h` | File I/O operations |
| `graphicalapplication.cpp/h` | GUI application base |
| `logger.cpp/h` | Logging system |
| `module.cpp/h` | Module system |
| `modulemanager.cpp/h` | Module loading/management |
| `resourcemanager.cpp/h` | Asset loading |
| `scheduledevent.cpp/h` | Scheduled events |
| `timer.cpp/h` | Timer utilities |

**Key Interactions**:
- `application.cpp` initializes all subsystems
- `configmanager.cpp` loads `config.otml`
- `resourcemanager.cpp` loads game assets

---

### Graphics (`framework/graphics/`)

**Purpose**: OpenGL rendering, text rendering, image handling.

| File | Description |
|------|-------------|
| `animatedtexture.cpp/h` | Animated texture support |
| `apngloader.cpp/h` | Animated PNG loading |
| `atlas.cpp/h` | Texture atlas management |
| `bitmapfont.cpp/h` | Bitmap font rendering |
| `cachedtext.cpp/h` | Text caching for performance |
| `coordsbuffer.cpp/h` | Vertex coordinate buffer |
| `drawcache.cpp/h` | Draw call caching |
| `drawpool.cpp/h` | Draw pool management |
| `drawpoolmanager.cpp/h` | Draw pool lifecycle |
| `fontmanager.cpp/h` | Font loading/management |
| `framebuffer.cpp/h` | Offscreen rendering |
| `framebuffermanager.cpp/h` | Framebuffer lifecycle |
| `graphics.cpp/h` | Core graphics system |
| `hardwarebuffer.cpp/h` | GPU buffer management |
| `image.cpp/h` | Image loading/manipulation |
| `painter.cpp/h` | 2D drawing primitives |
| `paintershaderprogram.cpp/h` | Shader-based painter |
| `shader.cpp/h` | GLSL shader loading |
| `shaderprogram.cpp/h` | Shader program management |
| `texture.cpp/h` | Texture management |
| `texturemanager.cpp/h` | Texture caching |

**Text Rendering Pipeline**:
```
Text String → FreeType (glyph loading) → HarfBuzz (shaping) → FriBidi (BiDi) → OpenGL
```

**Key Files for I18N**:
- `fontmanager.cpp` - Unicode font support
- `bitmapfont.cpp` - Glyph rendering
- `cachedtext.cpp` - Text layout caching

---

### Input (`framework/input/`)

**Purpose**: Keyboard, mouse, and touch input handling.

| File | Description |
|------|-------------|
| `mouse.cpp/h` | Mouse input handling |

**Interactions**:
- Platform layer provides raw input
- Input layer processes and dispatches events
- UI layer consumes input events

---

### Lua Engine (`framework/luaengine/`)

**Purpose**: Lua scripting integration.

| File | Description |
|------|-------------|
| `luabinder.h` | C++ to Lua binding macros |
| `luaexception.cpp/h` | Lua error handling |
| `luainterface.cpp/h` | Lua state management |
| `luaobject.cpp/h` | Lua-visible object base |
| `luavaluecasts.cpp/h` | Type conversions |

**Key Features**:
- All game logic written in Lua
- C++ classes exposed via binding macros
- Hot-reload support for development

---

### Networking (`framework/net/`)

**Purpose**: Network communication.

| File | Description |
|------|-------------|
| `connection.cpp/h` | TCP connection management |
| `inputmessage.cpp/h` | Incoming packet parsing |
| `outputmessage.cpp/h` | Outgoing packet building |
| `protocol.cpp/h` | Protocol base class |
| `server.cpp/h` | Server socket (for local hosting) |

**Protocol Flow**:
```
Server → TCP Socket → InputMessage → Protocol Parser → Game State
Game State → Protocol Builder → OutputMessage → TCP Socket → Server
```

---

### OTML Parser (`framework/otml/`)

**Purpose**: OTClient's configuration file format parser.

| File | Description |
|------|-------------|
| `otmldocument.cpp/h` | Document loading |
| `otmlemitter.cpp/h` | Document writing |
| `otmlexception.cpp/h` | Parse errors |
| `otmlnode.cpp/h` | Node representation |
| `otmlparser.cpp/h` | Parser implementation |

**Format Example**:
```otml
Window
  size: 200 100
  text: Hello World
  Label
    anchors.fill: parent
```

---

### Platform (`framework/platform/`)

**Purpose**: Platform-specific implementations.

| File | Description |
|------|-------------|
| `crashhandler.cpp/h` | Crash reporting |
| `platform.cpp/h` | Platform abstraction |
| `platformwindow.cpp/h` | Window management |
| `sdlwindow.cpp/h` | SDL2 window implementation |
| `unixcrashhandler.cpp` | Linux crash handling |
| `win32crashhandler.cpp` | Windows crash handling |
| `x11window.cpp/h` | X11 window (Linux) |

**Platform Support**:
- Windows (Win32 API)
- Linux (X11, SDL2)
- macOS (SDL2)
- Android (NDK)
- Web (Emscripten/WASM)

---

### Sound (`framework/sound/`)

**Purpose**: Audio playback.

| File | Description |
|------|-------------|
| `combinedsoundsource.cpp/h` | Multi-source audio |
| `oggsoundfile.cpp/h` | OGG Vorbis loading |
| `soundbuffer.cpp/h` | Audio buffer management |
| `soundchannel.cpp/h` | Audio channel |
| `soundfile.cpp/h` | Audio file abstraction |
| `soundmanager.cpp/h` | Audio system management |
| `soundsource.cpp/h` | Audio source |
| `streamsoundsource.cpp/h` | Streaming audio |

**Audio Backend**: OpenAL

---

### UI Framework (`framework/ui/`)

**Purpose**: User interface system.

| File | Description |
|------|-------------|
| `uianchorlayout.cpp/h` | Anchor-based layout |
| `uiboxlayout.cpp/h` | Box layout |
| `uigridlayout.cpp/h` | Grid layout |
| `uihorizontallayout.cpp/h` | Horizontal layout |
| `uilayout.cpp/h` | Layout base class |
| `uimanager.cpp/h` | UI system management |
| `uitextedit.cpp/h` | Text input widget |
| `uitranslator.cpp/h` | **I18N translation system** |
| `uiverticallayout.cpp/h` | Vertical layout |
| `uiwidget.cpp/h` | Base widget class |
| `uiwidgetbasestyle.cpp/h` | Widget styling |
| `uiwidgetimage.cpp/h` | Image widget |
| `uiwidgettext.cpp/h` | Text widget |

**I18N Key File**: `uitranslator.cpp/h`
- Provides `tr()` function for translations
- Loads locale files
- Handles string substitution

---

## Client Layer

### Creatures (`client/creatures/`)

**Purpose**: Player and NPC handling.

| File | Description |
|------|-------------|
| `creature.cpp/h` | Base creature class |
| `localplayer.cpp/h` | Player character |
| `missile.cpp/h` | Projectile effects |
| `outfit.cpp/h` | Creature appearance |
| `thingtypemanager.cpp/h` | Thing type definitions |

---

### Game (`client/game/`)

**Purpose**: Game state management.

| File | Description |
|------|-------------|
| `game.cpp/h` | Core game state |
| `gameconfig.cpp/h` | Game configuration |

---

### Items (`client/items/`)

**Purpose**: Item handling.

| File | Description |
|------|-------------|
| `container.cpp/h` | Container logic |
| `item.cpp/h` | Item class |
| `itemtype.cpp/h` | Item definitions |

---

### Map (`client/map/`)

**Purpose**: Map rendering and management.

| File | Description |
|------|-------------|
| `animatedtext.cpp/h` | Floating text |
| `effect.cpp/h` | Visual effects |
| `houses.cpp/h` | House system |
| `lightview.cpp/h` | Lighting |
| `map.cpp/h` | Map data |
| `mapview.cpp/h` | Map rendering |
| `minimap.cpp/h` | Minimap |
| `statictext.cpp/h` | Static text |
| `tile.cpp/h` | Tile class |

---

### Protocol (`client/`)

**Purpose**: Tibia protocol implementation.

| File | Description |
|------|-------------|
| `protocolgame.cpp/h` | Game protocol |
| `protocolgameparse.cpp` | Incoming packet parsing |
| `protocolgamesend.cpp` | Outgoing packet building |

---

## Build System

### CMake Configuration

**Main Files**:
- `CMakeLists.txt` - Root build configuration
- `cmake/` - CMake modules
- `vcpkg.json` - Dependency manifest

**Key CMake Variables**:
```cmake
FRAMEWORK_SOUND       # Enable audio
FRAMEWORK_GRAPHICS    # Enable graphics
FRAMEWORK_NET         # Enable networking
BUILD_STATIC          # Static linking
BUILD_BROWSER         # Emscripten/WASM build
```

**Dependencies** (vcpkg):
- OpenGL
- SDL2
- OpenAL
- Lua 5.1
- FreeType
- HarfBuzz (optional, for complex text)
- FriBidi (optional, for RTL text)
- zlib
- OpenSSL
- Protocol Buffers

---

## Key Code Paths

### Startup Sequence
```
main.cpp → Application::init() → ResourceManager::init() 
         → Graphics::init() → LuaInterface::init() 
         → ModuleManager::loadModules()
```

### Rendering Loop
```
GraphicalApplication::poll()
  → EventDispatcher::poll()
  → Graphics::beginRender()
  → UIManager::render()
  → MapView::render()
  → Graphics::endRender()
```

### Network Message Flow
```
Connection::recv() → Protocol::onRecv() 
  → ProtocolGame::parsePacket() → Game::processXXX()
```

### Translation Flow
```
Lua: tr("text") → UITranslator::translate() 
  → locale.translation["text"] → Translated text
```

---

## Adding New Features

### Adding a New Protocol Message

1. Define packet ID in `protocolgame.h`
2. Add parser in `protocolgameparse.cpp`:
```cpp
void ProtocolGame::parseMyMessage(const InputMessagePtr& msg) {
    // Parse packet data
    uint32_t value = msg->getU32();
    // Dispatch to game
    g_game.processMyMessage(value);
}
```
3. Add sender in `protocolgamesend.cpp` if needed

### Adding a New UI Widget

1. Create widget class inheriting `UIWidget`
2. Register in Lua bindings
3. Create OTUI style definition

### Adding Translation Support

1. Use `tr()` for all user-visible text
2. Add English text to `neededtranslations.lua`
3. Add translations to each locale file

---

*This documentation is part of the OTClient I18N implementation project.*
*Last updated: December 2024*
