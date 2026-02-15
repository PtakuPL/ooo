# OTClient Architecture Documentation

This document provides a comprehensive overview of the OTClient project structure, explaining each component's purpose, how it works, and its interactions with other parts of the system.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Directory Structure](#directory-structure)
3. [Core Components](#core-components)
4. [Build System](#build-system)
5. [Internationalization (I18N)](#internationalization-i18n)
6. [Platform Support](#platform-support)
7. [CI/CD Workflows](#cicd-workflows)

---

## Project Overview

OTClient is an open-source client for Tibia-like games that supports multiple platforms including Windows, Linux, macOS, Android, and Web (via Emscripten). The project uses C++20 and integrates with vcpkg for dependency management.

### Key Features
- Multi-language text rendering (50+ languages support via TTF/HarfBuzz/FriBidi)
- Cross-platform support (Windows, Linux, macOS, Android, WebAssembly)
- Lua scripting interface
- OpenGL/OpenGL ES graphics
- Network protocol support

---

## Directory Structure

```
testyy/
├── src/                    # Main source code
│   ├── framework/          # Core framework components
│   ├── client/             # Game client logic
│   └── protobuf/           # Protocol buffer definitions
├── browser/                # Emscripten/WebAssembly resources
├── android/                # Android platform files
├── cmake/                  # CMake modules
├── data/                   # Game data files
├── mods/                   # Modification files
├── modules/                # Lua modules
├── docs/                   # Documentation
├── tools/                  # Development tools
└── .github/workflows/      # CI/CD workflow definitions
```

---

## Core Components

### 1. Framework (`src/framework/`)

The framework provides core functionality shared across all platforms.

#### Core Module (`src/framework/core/`)

| File | Purpose | Interactions |
|------|---------|--------------|
| `application.cpp` | Base application class, initialization | All modules |
| `graphicalapplication.cpp` | Graphics application lifecycle | Graphics, UI |
| `asyncdispatcher.cpp` | Thread pool for async operations | Network, I/O |
| `eventdispatcher.cpp` | Event queue and dispatch system | All modules |
| `resourcemanager.cpp` | Asset loading and caching | Data files, textures |
| `modulemanager.cpp` | Lua module loading | Lua engine |
| `configmanager.cpp` | Configuration handling | Settings |
| `logger.cpp` | Logging system | All modules |
| `filestream.cpp` | File I/O abstraction | Resource loading |

#### Graphics Module (`src/framework/graphics/`)

| File | Purpose | Interactions |
|------|---------|--------------|
| `graphics.cpp` | OpenGL initialization and management | All rendering |
| `texture.cpp` | Texture loading and management | Atlas, Images |
| `texturemanager.cpp` | Texture caching and pooling | Resources |
| `shader.cpp` / `shaderprogram.cpp` | GLSL shader management | Rendering |
| `painter.cpp` | Draw operations abstraction | All drawing |
| `drawpool.cpp` | Batched draw call management | Performance |
| `framebuffer.cpp` | Render target management | Effects |
| `bitmapfont.cpp` | Bitmap font rendering | Text rendering |
| `image.cpp` | Image loading (PNG, etc.) | Textures |
| `cachedtext.cpp` | Text caching for performance | UI |
| `fontmanager.cpp` | Font loading and caching | Text rendering |
| `textureatlas.cpp` | Glyph atlas management | TTF fonts |

#### Text Rendering Module (`src/framework/text/`)

This module implements full internationalization support:

| File | Purpose | Interactions |
|------|---------|--------------|
| `TTFFont.cpp` | TrueType font rendering via FreeType | HarfBuzz, Atlas |
| `TextShaper.cpp` | Text shaping with HarfBuzz | TTFFont, FriBidi |
| `LocaleShaping.cpp` | Locale-aware text layout | TextShaper |

#### UI Module (`src/framework/ui/`)

| File | Purpose | Interactions |
|------|---------|--------------|
| `uimanager.cpp` | UI widget management | All UI widgets |
| `uiwidget.cpp` | Base widget class | Derived widgets |
| `uitextedit.cpp` | Text input widget (TTF-aware) | Text rendering |
| `uitranslator.cpp` | UI translation system | I18N |
| `uilayout.cpp` | Layout algorithms | Widget hierarchy |

#### Network Module (`src/framework/net/`)

| File | Purpose | Interactions |
|------|---------|--------------|
| `connection.cpp` | TCP connection handling | Protocol |
| `protocol.cpp` | Base protocol class | Game protocol |
| `inputmessage.cpp` | Incoming packet handling | Protocol |
| `outputmessage.cpp` | Outgoing packet creation | Protocol |
| `protocolhttp.cpp` | HTTP protocol support | Login |
| `webconnection.cpp` | WebSocket (WASM) | Emscripten |

#### Platform Module (`src/framework/platform/`)

| File | Purpose | Platforms |
|------|---------|-----------|
| `win32window.cpp` | Windows window handling | Windows |
| `x11window.cpp` | X11 window handling | Linux |
| `androidwindow.cpp` | Android window handling | Android |
| `browserwindow.cpp` | Emscripten canvas | WebAssembly |
| `platformwindow.cpp` | Platform abstraction | All |

### 2. Client (`src/client/`)

Game-specific client logic:

| File | Purpose | Interactions |
|------|---------|--------------|
| `game.cpp` | Main game state | All client |
| `creature.cpp` | Creature handling | Map, Protocol |
| `player.cpp` | Player logic | Game state |
| `map.cpp` | Map rendering and logic | Tiles, Creatures |
| `tile.cpp` | Single map tile | Items, Creatures |
| `item.cpp` | Item handling | Sprites |
| `protocolgame.cpp` | Game protocol | Network |
| `spritemanager.cpp` | Sprite loading | Resources |
| `thingtype.cpp` | Object type definitions | Data |

### 3. Lua Engine (`src/framework/luaengine/`)

Lua scripting integration:

| File | Purpose | Interactions |
|------|---------|--------------|
| `luainterface.cpp` | Lua state management | All Lua bindings |
| `luaobject.cpp` | C++/Lua object bridge | Framework objects |
| `luavaluecasts.cpp` | Type conversion | Data marshaling |

---

## Build System

### CMakeLists.txt Structure

The main `CMakeLists.txt` configures:
- vcpkg integration for dependencies
- Platform-specific options
- Text stack (FreeType + HarfBuzz + FriBidi)
- Build targets

### Key CMake Variables

| Variable | Purpose |
|----------|---------|
| `WASM` | Enables WebAssembly build |
| `OTC_ENABLE_TTF` | Enable TrueType fonts |
| `OTC_ENABLE_HARFBUZZ` | Enable HarfBuzz shaping |
| `OTC_ENABLE_FRIBIDI` | Enable bidirectional text |

### vcpkg Dependencies

Defined in `vcpkg.json`:
- **Core**: asio, abseil, fmt, nlohmann-json, protobuf
- **Graphics**: freetype, harfbuzz, fribidi (for I18N)
- **Audio**: libogg, libvorbis, openal-soft
- **Platform-specific**: glew, luajit/lua, opengl

---

## Internationalization (I18N)

### Text Rendering Pipeline

```
Text Input → FriBidi (BiDi) → HarfBuzz (Shaping) → FreeType (Glyph) → Atlas → GPU
```

### Supported Languages

The system supports 50+ languages through:
1. **UTF-8 encoding** throughout the codebase
2. **FreeType** for glyph rasterization
3. **HarfBuzz** for complex text shaping (Arabic, Hebrew, Indic scripts)
4. **FriBidi** for bidirectional text (RTL languages)

### Key Files for I18N

- `src/framework/text/TTFFont.cpp` - Font rendering
- `src/framework/text/TextShaper.cpp` - Text shaping
- `src/framework/ui/uitranslator.cpp` - Translation system
- `modules/*/locales/` - Translation files

### Adding New Language Support

1. Create locale files in `modules/*/locales/`
2. Add font fallbacks in font configuration
3. Test with complex scripts (RTL, combining characters)

---

## Platform Support

### Windows
- **Compiler**: MSVC 2019+, Clang
- **Graphics**: OpenGL, DirectX 9 (optional)
- **Dependencies**: vcpkg x64-windows or x64-windows-static

### Linux
- **Compiler**: GCC 9+, Clang
- **Graphics**: OpenGL via GLEW
- **Dependencies**: vcpkg x64-linux + system packages (X11, etc.)

### Android
- **SDK**: Android NDK
- **Graphics**: OpenGL ES 2/3
- **Build**: Gradle + CMake

### WebAssembly (Emscripten)
- **SDK**: Emscripten 3.1.x
- **Graphics**: WebGL 2
- **Build**: `wasm32-emscripten` vcpkg triplet

---

## CI/CD Workflows

Located in `.github/workflows/`:

| Workflow | Purpose | Platform |
|----------|---------|----------|
| `build-linux.yml` | Linux builds | Ubuntu |
| `build-windows.yml` | Windows builds | Windows Server |
| `build-android.yml` | Android APK | Ubuntu (NDK) |
| `build-browser.yml` | WASM build | Ubuntu (Emscripten) |
| `analysis-sonarcloud.yml` | Code quality | Ubuntu |
| `docker-publish.yml` | Container builds | Docker |

### Build Requirements

Each workflow handles:
1. vcpkg installation and caching
2. Dependency installation
3. CMake configuration
4. Build execution
5. Artifact upload

---

## Related Documentation

- `I18N_Progress.md` - Internationalization implementation status
- `I18N_Next_Steps.md` - Upcoming I18N improvements
- `docs/linux-build-deps.md` - Linux build dependencies
- `docs/build-status.md` - Current build status

---

## Contributing

When adding new features:
1. Follow existing code patterns
2. Add UTF-8 support from the start
3. Consider all supported platforms
4. Update documentation accordingly
5. Test with multiple locales

---

*Last updated: December 2025*
