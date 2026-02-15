# OTClient Dependencies Documentation

## Overview

This document provides a comprehensive breakdown of all dependencies used by OTClient, their purpose, platform availability, and how they interact with the codebase.

---

## Table of Contents

1. [Dependency Categories](#dependency-categories)
2. [Core Libraries](#core-libraries)
3. [Graphics & Rendering](#graphics--rendering)
4. [Audio System](#audio-system)
5. [Text & Internationalization (I18N)](#text--internationalization-i18n)
6. [Scripting Engine](#scripting-engine)
7. [Networking](#networking)
8. [Platform-Specific Dependencies](#platform-specific-dependencies)
9. [Build System Dependencies](#build-system-dependencies)
10. [Dependency Graph](#dependency-graph)
11. [vcpkg Configuration](#vcpkg-configuration)

---

## Dependency Categories

| Category | Libraries | Purpose |
|----------|-----------|---------|
| Core | physfs, zlib, liblzma, protobuf, nlohmann-json | File I/O, compression, serialization |
| Graphics | glew, opengl, freetype, angle | Rendering, fonts, OpenGL ES |
| Audio | openal-soft, libogg, libvorbis | Sound playback, audio codecs |
| I18N | harfbuzz, fribidi | Text shaping, RTL support |
| Scripting | luajit, lua | Game logic scripting |
| Networking | asio, openssl, cpp-httplib | Network communication, security |
| Utility | abseil, fmt, stduuid, parallel-hashmap, pugixml | Helpers, formatting, XML |
| Platform | discord-rpc, pkgconf | Platform integration |

---

## Core Libraries

### PhysFS (physfs)
**Purpose:** Virtual filesystem abstraction

**Used For:**
- Loading game assets from archives (.zip, .7z)
- Platform-independent file access
- Hot-reloading of resources

**Source Files:**
- `src/framework/core/resourcemanager.cpp`
- `src/framework/core/filestream.cpp`

**Platform:** All (Windows, Linux, macOS, Android, WASM)

---

### Zlib (zlib)
**Purpose:** Data compression

**Used For:**
- Compressing/decompressing network packets
- Asset compression
- PNG image handling (indirect)

**Source Files:**
- `src/framework/net/protocol.cpp`
- `src/framework/core/unzipper.cpp`

**Platform:** All

---

### LZMA (liblzma)
**Purpose:** High-ratio compression algorithm

**Used For:**
- Compressing large assets
- Sprite/texture compression
- Client updates

**Source Files:**
- `src/client/spritemanager.cpp`
- `src/client/spriteappearances.cpp`

**Platform:** All

---

### Protocol Buffers (protobuf)
**Purpose:** Binary serialization format

**Used For:**
- Client-server communication protocol
- Appearance data serialization
- Configuration files

**Source Files:**
- `src/protobuf/` (generated files)
- `src/client/protocolgame*.cpp`

**Dependencies:** abseil (absl) for logging

**Platform:** All

---

### nlohmann-json
**Purpose:** JSON parsing and generation

**Used For:**
- Configuration files
- HTTP API responses
- Discord Rich Presence data

**Source Files:**
- `src/framework/core/configmanager.cpp`
- `src/framework/net/httplogin.cpp`

**Platform:** All

---

### Abseil (abseil)
**Purpose:** C++ utility library (Google)

**Used For:**
- Protobuf runtime support
- Logging infrastructure
- String utilities

**Dependencies Required By:** protobuf

**Platform:** All

---

### fmt
**Purpose:** Modern C++ formatting library

**Used For:**
- String formatting (faster than iostream)
- Log messages
- Error messages

**Source Files:**
- Used throughout `src/framework/` and `src/client/`

**Platform:** All

---

### stduuid
**Purpose:** UUID generation

**Used For:**
- Unique identifiers for sessions
- Player/item tracking
- Cache keys

**Platform:** All (header-only)

---

### parallel-hashmap (phmap)
**Purpose:** Fast concurrent hash maps

**Used For:**
- Texture caching
- Sprite management
- Entity lookup tables

**Source Files:**
- `src/client/thingtypemanager.cpp`
- `src/framework/graphics/texturemanager.cpp`

**Platform:** All (header-only)

---

### pugixml
**Purpose:** XML parsing

**Used For:**
- OTUI files (UI layouts)
- Configuration files
- Map data (OTBM format)

**Source Files:**
- `src/framework/otml/` (OTML uses similar concepts)
- `src/client/mapio.cpp`

**Platform:** All

---

## Graphics & Rendering

### GLEW (glew)
**Purpose:** OpenGL Extension Wrangler

**Used For:**
- Loading OpenGL functions
- Extension management
- Cross-platform OpenGL support

**Source Files:**
- `src/framework/graphics/graphics.cpp`
- `src/framework/graphics/painter.cpp`

**Platform:** Windows, Linux, macOS (NOT Android, NOT WASM)

**CMake Variable:** `GLEW_LIBRARY`, `GLEW_INCLUDE_DIR`

---

### OpenGL (opengl)
**Purpose:** Graphics rendering API

**Used For:**
- All 2D/3D rendering
- Shaders
- Framebuffers

**Source Files:**
- `src/framework/graphics/*.cpp`

**Platform:** Windows (via vcpkg), Linux (system), macOS (framework)

---

### ANGLE (angle)
**Purpose:** OpenGL ES implementation over DirectX

**Used For:**
- Windows OpenGL ES support
- DirectX backend for better compatibility

**Platform:** Windows only

---

### Freetype (freetype)
**Purpose:** TrueType font rendering

**Used For:**
- TTF/OTF font loading
- Glyph rasterization
- Font metrics

**Source Files:**
- `src/framework/text/TTFFont.cpp`
- `src/framework/graphics/bitmapfont.cpp`

**Platform:** All

**CMake:** `OTC_ENABLE_TTF` option (default: ON)

---

## Audio System

### OpenAL Soft (openal-soft)
**Purpose:** 3D audio API

**Used For:**
- Sound playback
- Positional audio
- Audio streaming

**Source Files:**
- `src/framework/sound/soundmanager.cpp`
- `src/framework/sound/soundsource.cpp`

**Platform:** Windows, Linux, macOS, Android (NOT WASM - uses Emscripten OpenAL)

---

### Ogg (libogg)
**Purpose:** Ogg container format

**Used For:**
- Audio file containers
- Streaming audio

**Source Files:**
- `src/framework/sound/oggsoundfile.cpp`

**Platform:** All

---

### Vorbis (libvorbis)
**Purpose:** Vorbis audio codec

**Used For:**
- Decoding .ogg audio files
- Background music
- Sound effects

**Source Files:**
- `src/framework/sound/oggsoundfile.cpp`
- `src/framework/sound/streamsoundsource.cpp`

**Platform:** All

---

## Text & Internationalization (I18N)

### HarfBuzz (harfbuzz)
**Purpose:** Text shaping engine

**Used For:**
- Complex script rendering (Arabic, Thai, Hindi, etc.)
- Ligature handling
- Kerning and positioning

**Source Files:**
- `src/framework/text/TextShaper.cpp`

**Platform:** All

**CMake:** `OTC_ENABLE_HARFBUZZ` option (default: ON)

**Languages Supported:**
- Arabic (العربية) - cursive joining
- Thai (ไทย) - complex clusters
- Hindi (हिन्दी) - Devanagari script
- Hebrew (עברית) - RTL with vowels
- All 53 supported languages

---

### FriBidi (fribidi)
**Purpose:** Bidirectional text algorithm

**Used For:**
- Right-to-Left (RTL) text support
- Mixed RTL/LTR text
- Logical to visual reordering

**Source Files:**
- `src/framework/text/LocaleShaping.cpp`

**Platform:** All

**CMake:** `OTC_ENABLE_FRIBIDI` option (default: ON)

**RTL Languages:**
- Arabic (ar)
- Hebrew (he)
- Persian/Farsi (fa)

---

## Scripting Engine

### LuaJIT (luajit)
**Purpose:** Just-In-Time Lua compiler

**Used For:**
- Game scripting
- UI logic
- Mod support

**Source Files:**
- `src/framework/luaengine/*.cpp`
- `modules/**/*.lua`

**Platform:** Windows, Linux, macOS (NOT WASM, NOT Android)

**Performance:** 10-50x faster than standard Lua

---

### Lua (lua)
**Purpose:** Standard Lua interpreter

**Used For:**
- WASM builds (LuaJIT not supported)
- Fallback scripting

**Platform:** WASM only

**Note:** For WASM builds, CMake uses standard `FindLua` module instead of custom one:
```cmake
# src/CMakeLists.txt lines 483-496
set(_SAVED_CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH})
list(REMOVE_ITEM CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
find_package(Lua REQUIRED)
set(CMAKE_MODULE_PATH ${_SAVED_CMAKE_MODULE_PATH})
```

---

## Networking

### Asio (asio)
**Purpose:** Asynchronous I/O library

**Used For:**
- TCP/UDP networking
- Async operations
- Timer management

**Source Files:**
- `src/framework/net/connection.cpp`
- `src/framework/net/server.cpp`

**Platform:** All (standalone, no Boost)

---

### OpenSSL (openssl)
**Purpose:** Cryptography and TLS

**Used For:**
- Secure connections (TLS/SSL)
- RSA encryption
- Password hashing

**Source Files:**
- `src/framework/util/crypt.cpp`
- `src/framework/net/protocol.cpp`

**Platform:** All

**Alternative:** GMP (for systems without OpenSSL)

---

### cpp-httplib
**Purpose:** HTTP client/server library

**Used For:**
- HTTP login
- REST API communication
- Asset downloads

**Source Files:**
- `src/framework/net/httplogin.cpp`
- `src/framework/net/protocolhttp.cpp`

**Platform:** All (header-only)

---

## Platform-Specific Dependencies

### Discord RPC (discord-rpc)
**Purpose:** Discord Rich Presence integration

**Used For:**
- Showing game status in Discord
- Player activity tracking

**Source Files:**
- `src/framework/discord/discord.cpp`

**Platform:** Windows, Linux, macOS

---

### GMP (gmp)
**Purpose:** GNU Multiple Precision arithmetic

**Used For:**
- RSA encryption (alternative to OpenSSL)
- Large number operations

**Platform:** Used when OpenSSL is not available

---

### X11 (libx11)
**Purpose:** X Window System

**Used For:**
- Window creation on Linux
- Input handling
- Clipboard

**Source Files:**
- `src/framework/platform/x11window.cpp`

**Platform:** Linux only (system library)

---

### EGL
**Purpose:** Platform-independent graphics context

**Used For:**
- OpenGL ES context creation
- Android graphics

**Platform:** Android only

---

## Build System Dependencies

### CMake Modules

The project includes custom CMake modules in `cmake/`:

| Module | Purpose |
|--------|---------|
| `FindLua.cmake` | Find Lua installation |
| `FindLuaJIT.cmake` | Find LuaJIT installation |
| `FindGLEW.cmake` | Find GLEW library |
| `FindOpenAL.cmake` | Find OpenAL library |
| `FindPhysFS.cmake` | Find PhysFS library |
| `FindVorbis.cmake` | Find Vorbis codec |
| `FindOgg.cmake` | Find Ogg container |
| `FindGMP.cmake` | Find GMP library |
| `FindDirectX.cmake` | Find DirectX SDK |
| `FindEGL.cmake` | Find EGL library |

### pkgconf
**Purpose:** Package configuration tool

**Used For:**
- Finding system libraries on Windows
- Generating compiler flags

**Platform:** Windows (host tool)

---

## Dependency Graph

```
OTClient
├── Core System
│   ├── physfs (virtual filesystem)
│   ├── zlib (compression)
│   ├── liblzma (LZMA compression)
│   ├── protobuf → abseil (serialization)
│   └── nlohmann-json (configuration)
│
├── Graphics
│   ├── opengl/glew (rendering)
│   ├── freetype (fonts)
│   │   └── harfbuzz (text shaping)
│   │       └── fribidi (RTL text)
│   └── angle (Windows OpenGL ES)
│
├── Audio
│   ├── openal-soft (playback)
│   └── libvorbis → libogg (codec)
│
├── Scripting
│   ├── luajit (JIT compiler) [Windows/Linux/macOS]
│   └── lua (interpreter) [WASM]
│
├── Networking
│   ├── asio (async I/O)
│   ├── openssl (TLS/crypto)
│   └── cpp-httplib (HTTP)
│
├── Utility
│   ├── fmt (formatting)
│   ├── pugixml (XML)
│   ├── stduuid (UUIDs)
│   └── parallel-hashmap (containers)
│
└── Platform
    ├── discord-rpc (Discord integration)
    ├── x11 (Linux windowing)
    ├── egl (Android graphics)
    └── gmp (alternative crypto)
```

---

## vcpkg Configuration

### vcpkg.json
```json
{
  "name": "otclient",
  "version-string": "1.0.0",
  "dependencies": [
    "asio",
    "abseil",
    "fmt",
    "cpp-httplib",
    "discord-rpc",
    "liblzma",
    "libogg",
    "libvorbis",
    "nlohmann-json",
    "harfbuzz",
    "freetype",
    "fribidi",
    "openal-soft",
    "openssl",
    "parallel-hashmap",
    "physfs",
    "protobuf",
    "pugixml",
    "stduuid",
    "zlib",
    { "name": "glew",   "platform": "windows | linux | osx" },
    { "name": "opengl", "platform": "windows" },
    { "name": "angle",  "platform": "windows" },
    { "name": "luajit", "platform": "windows | linux | osx" },
    { "name": "lua",    "platform": "wasm" },
    { "name": "pkgconf", "host": true, "platform": "windows" }
  ],
  "builtin-baseline": "4c4abc2e8727221ede31021349386dac674309b0"
}
```

### Platform Triplets

| Platform | Triplet | Notes |
|----------|---------|-------|
| Windows (static) | `x64-windows-static` | Recommended for distribution |
| Windows (dynamic) | `x64-windows` | Requires DLLs |
| Linux | `x64-linux` | Standard build |
| macOS | `x64-osx` | Intel Mac |
| macOS ARM | `arm64-osx` | Apple Silicon |
| WASM | `wasm32-emscripten` | Browser build |
| Android | `arm64-android` | 64-bit Android |

---

## Version Requirements

| Dependency | Minimum Version | Recommended |
|------------|-----------------|-------------|
| CMake | 3.16 | 3.27+ |
| GCC | 9.0 | 14.0+ |
| Clang | 10.0 | 15.0+ |
| MSVC | 2019 | 2022 |
| Emscripten | 3.0 | 3.1.73 |
| vcpkg | - | Latest |
| Protobuf | 3.0 | 3.21+ |
| OpenSSL | 1.1.1 | 3.0+ |

---

## Related Documentation

- [BUILD_GUIDE.md](BUILD_GUIDE.md) - Build instructions
- [ARCHITECTURE.md](ARCHITECTURE.md) - Project architecture
- [TEXT_RENDERING.md](TEXT_RENDERING.md) - Text and I18N system
- [SOURCE_CODE.md](SOURCE_CODE.md) - C++ source documentation
