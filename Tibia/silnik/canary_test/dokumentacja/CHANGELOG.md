# Changelog

## 06-12-2025 - Issue #30: Full i18n Implementation (Part 2)
### Additional UI Internationalization
- **Shop module**: Added `tr()` wrapper to `gift.otui`, `changename.otui`, `game_shop.otui` (9 texts)
- **Graphics options**: Added `tr()` wrapper to `graphics.otui`, `effects.otui` (5 texts)
- **Interface options**: Added `tr()` wrapper to `interface.otui` (2 texts)
- **New Polish translations**: Added 14 new translation keys for shop and graphics UI

### Knowledge Sharing
- **AGENT_HANDOFF.md**: Added cross-agent handoff template + git workflow checklist so Issue #30 work logs merge cleanly into `main`

## 06-12-2025 - Issue #30: Full i18n Implementation (Part 1)
### Font System Improvements
- **TTFFont fallback loading**: Activated fallback font loading in `TTFFont::load()` - now properly loads CJK, Arabic and other fallback fonts
- **Glyph fallback mechanism**: Modified `cacheGlyph()` to automatically try fallback fonts when main font lacks a glyph
- **New `rasterizeGlyph()` method**: Extracted glyph rasterization to font-agnostic method with unique cache keys

### Text Shaping (HarfBuzz + FriBidi)
- **FriBidi integration**: Added `applyBidiReordering()` function for proper RTL/BiDi text display (Arabic, Hebrew)
- **Extended script support**: Added mappings for Hebrew, Korean (Hangul), Thai, Devanagari, Bengali scripts
- **Codepoint tracking**: Added `codepoint` field to `ShapedGlyph` struct for fallback font lookup

### UI Internationalization
- **Fixed font config**: Corrected fallback paths in `NotoSans-12.otfont` (NotoSansSC-Regular.ttf, NotoNaskhArabic-Regular.ttf)
- **tr() wrapper fixes**: Added `tr()` to hard-coded tooltips in `imbuing.otui`, `boss_slots.otui`, `charms.otui`
- **Polish translations**: Added new translation keys for imbuing, boss slots, and charms tooltips
- **Bitmap font coverage**: Added missing aliases `verdana-10px-antialiased` and `verdana-bold-8px-antialiased` so Cyclopedia widgets no longer reference absent resources
- **Updater dialog localization**: All user-facing updater strings (checksum/timeout/errors) now go through `tr()` with matching entries in `modules/client_locales/neededtranslations.lua`
- **Text stack README**: Added `src/framework/text/README.md` documenting the shaping pipeline and how to register new TTF fonts + fallback chains
- **Polish installer strings**: `data/locales/pl.lua` zawiera teraz tłumaczenia komunikatów aktualizatora, dzięki czemu instalka jest w pełni po polsku

### Code Quality
- **Fixed compiler warning**: Removed extra semicolon in `eventdispatcher.h`
- **Unit tests**: Created `tests/` directory with TextShaper unit tests (11 test cases)
- **Test framework**: Added Google Test (gtest) to vcpkg.json, BUILD_TESTING CMake option

### CI/CD
- **vcpkg baseline update**: Updated to `ab2977be50c702126336e5088f4836060733c899`
- **Submodule cleanup**: Removed orphaned `oryginall/canary-serwer` from git index

### Documentation
- **Reorganized docs**: Moved all .md files to `testyy/docs/` with subdirectories (ci-cd/, i18n/, analysis/, project/, archive/)
- **Tests README**: Added comprehensive documentation for unit tests

## 05-12-2023
### Breaking API Changes
- `UIWidget` property `qr-code` & `qr-code-border` replaced with `UIQrCode` properties `code` & `code-border`
- `image-source-base64` replaced with `image-source: base64:/path/to/image`
- `#include "shadermanager.h"` moved to `#include <framework/graphics/shadermanager.h>`
