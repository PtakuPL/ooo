# Copilot Instructions for this Repository

This repo hosts a C++ MMORPG server and a customized client:
- Canary server (C++17/CMake) in `src/` with data in `data/`, `data-canary/`, `data-otservbr-global/`.
- OTClient Redemption client (C++20 + Lua) in `testyy/` (fork of mehah/otclient). Upstreams for reference in `oryginall/` — do not edit upstream copies.

## Project Map
- Server: core C++ in `src/`, configs in `config.lua`, migrations under `data-canary/migrations/` and `data-otservbr-global/migrations/`.
- Client: C++ engine in `testyy/src/framework/{graphics,ui}/`, Lua modules in `testyy/modules/` and `testyy/data/`.
- Docs: `dokumentacja/ogolny-opis-modyfikacji.md` records fork-specific behavior; update here when changing cross-cutting logic.

## Build & Run Workflows
- Linux server: use CMake presets (`CMakePresets.json`). Common commands: `./recompile.sh` then `./start.sh`.
- Windows server: `build_windows.bat` per `BUILD_WINDOWS.md`.
- Client: follow `testyy/README.md` (CMake + vcpkg). Keep `vcpkg.json` consistent and avoid ad-hoc build systems.
- Docker: respect `docker/` and `docker-compose.yml`; mirror existing patterns for any additions.

## Conventions & Patterns
- Track upstream structure; make surgical diffs in `src/` and `testyy/`. Compare against `oryginall/` before altering core files.
- Prefer adding features via Lua (`testyy/modules/**`, `testyy/data/**`) and config over C++ changes when feasible.
- Logging: use `g_logger` with `{}` placeholders; avoid printf-style `%s/%d`. Example: `g_logger.error("invalid size: {}", size);`.
- Use helper subsystems: `src/kv/` (config), `src/lib/di/` (dependency injection), `src/lib/thread/` (threading).

## Client Engine Specifics
- Graphics stack: maintain the current pipeline — draw pool → painter → coordsbuffer → framebuffer. Do not reintroduce depth buffer logic.
- When editing `testyy/src/framework/graphics/*` or `ui/*`, check differences documented in `dokumentacja/ogolny-opis-modyfikacji.md` and compare with `oryginall/otclient` to keep fork-specific behavior.
- New UI/game logic should be Lua-first. If C++ changes are necessary, keep APIs compatible with existing modules.

## Testing & Debugging
- Server tests: `tests/` (see `tests/README.md`). Adjust tests when touching protocol/combat/map logic.
- Debug: use `gdb_debug/` helpers and `start_gdb.sh` for server; for client, create small Lua repros in `testyy/modules/`.

## Integration Points
- Protocol compatibility and features are documented in `testyy/README.md` (Support Protocol). Use those flags when wiring client↔server.
- Asset pipelines: textures/APNG in client (`testyy/data/**`), server scripts in `data/**`. Keep paths and formats consistent with upstream.

## Examples
- Add a server feature via Lua: modify `data-canary/scripts/**` or `data/scripts/**` and expose config in `config.lua`.
- Client rendering change: extend `testyy/src/framework/graphics/drawpool.cpp` but preserve batching/hashing; update doc in `dokumentacja/ogolny-opis-modyfikacji.md`.
- Migrations: add files under `data-canary/migrations/` instead of changing schema directly.

If any section is unclear or you need deeper engine notes (e.g., painter/coordsbuffer specifics), say which area to expand and we’ll refine this guide.
