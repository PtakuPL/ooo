# Copilot Instructions for ooo Repository

This document provides instructions for GitHub Copilot to understand and work effectively with this repository.

## Project Overview

This repository contains Tibia-related game development projects:

1. **Canary Server** (`Tibia/silnik/canary_test/`) - An open-source MMORPG server emulator for Tibia, written in C++20
2. **OTClient Redemption** (`Tibia/silnik/canary_test/testyy/`) - An alternative Tibia client written in C++20 with Lua scripting

## Directory Structure

```
ooo/
├── .github/
│   └── workflows/          # CI/CD workflows for various platforms
├── Tibia/
│   └── silnik/
│       ├── canary_test/    # Canary server project
│       │   ├── src/        # C++ source code for server
│       │   ├── data/       # Server data files
│       │   ├── tests/      # Test files
│       │   └── testyy/     # OTClient project
│       │       ├── src/    # C++ source code for client
│       │       ├── modules/# Lua modules
│       │       ├── mods/   # User mods
│       │       └── data/   # Client data files
│       └── canary/         # Additional canary resources
├── bledyw.md               # CI/CD error documentation (Polish)
└── zrobionew.md            # Progress log (Polish)
```

## Build Instructions

### Prerequisites
- CMake 3.22+
- vcpkg package manager
- C++20 compatible compiler (GCC 11+, Clang 13+, or MSVC 2022)

### Building on Linux/Ubuntu
```bash
cd Tibia/silnik/canary_test
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(nproc)
```

### Building on Windows
```bash
cd Tibia/silnik/canary_test
cmake --preset windows-release
cmake --build --preset windows-release
```

### Building OTClient (testyy)
```bash
cd Tibia/silnik/canary_test/testyy
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(nproc)
```

## Coding Standards

### C++ Code
- Follow **C++20** standards
- Use **clang-format** for formatting (configuration in `.clang-format`)
- Use 4 spaces for indentation (tabs converted to spaces)
- Pointer alignment: left-aligned (e.g., `int* ptr`)
- Reference alignment: right-aligned (e.g., `int &ref`)
- Braces on same line (no newline before opening brace)
- Maximum empty lines: 1
- Comments in English

### Lua Scripts
- Use **lua-format** for formatting
- Focus on simple and efficient implementations
- Performance-heavy features should be implemented in C++ instead

### General Guidelines
- Make small, focused changes
- Write tests where possible
- Document complex logic with clear comments
- Use meaningful variable and function names

## Key Architectural Decisions

### Data Storage
- Use the **KV System** for all persistent data storage
- Do NOT create new MySQL tables
- The KV system uses protobuf-based abstraction for performance

### Code Organization
- Each functionality should be a separate module
- Client UI is scripted in Lua with CSS-like styling
- Performance-critical code belongs in C++

## CI/CD Workflows

The repository has multiple CI workflows:
- `build-linux.yml` - Linux build
- `build-ubuntu.yml` - Ubuntu build
- `build-windows.yml` - Windows build with vcpkg
- `build-windows-solution.yml` - Windows build with Visual Studio solution
- `build-browser.yml` - Emscripten/WebAssembly build
- `build-android.yml` - Android build
- `clang-lint.yml` - Clang linting
- `lua-format.yml` - Lua formatting checks
- `analysis-sonarcloud.yml` - SonarCloud code analysis

## Testing

Run tests from the build directory:
```bash
ctest --output-on-failure
```

## Dependencies

Dependencies are managed via vcpkg. Key dependencies include:
- LuaJIT (Lua for Emscripten builds)
- OpenGL/OpenGL ES
- OpenAL
- Protocol Buffers
- fmt library
- Vorbis/Ogg audio libraries

## Notes for Copilot

1. When modifying C++ code, ensure it compiles with C++20 standards
2. Run clang-format on any C++ changes before committing
3. Run lua-format on any Lua script changes
4. Test builds on at least one platform before marking work as complete
5. Check CI workflow status after pushing changes
6. When adding dependencies, check vcpkg.json for correct platform conditions
7. Be aware of platform-specific code paths (Windows vs Linux vs Emscripten)
