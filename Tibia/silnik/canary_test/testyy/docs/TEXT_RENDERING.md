# Text Rendering and Localization System Documentation

This document provides detailed information about the OTClient text rendering pipeline and localization system.

## Table of Contents

1. [Overview](#overview)
2. [Text Rendering Pipeline](#text-rendering-pipeline)
3. [Localization System](#localization-system)
4. [Adding New Languages](#adding-new-languages)
5. [Font Configuration](#font-configuration)
6. [Technical Details](#technical-details)

---

## Overview

OTClient uses a sophisticated text rendering system that supports:
- **50+ languages** through UTF-8 encoding
- **Complex text scripts** (Arabic, Hebrew, Thai, etc.) via HarfBuzz
- **Bidirectional text** (RTL languages) via FriBidi
- **TrueType fonts** via FreeType

---

## Text Rendering Pipeline

### Pipeline Stages

```
Input Text (UTF-8)
       │
       ▼
┌──────────────────┐
│   FriBidi        │  → Bidirectional text reordering (RTL/LTR)
│   (BiDi)         │
└──────────────────┘
       │
       ▼
┌──────────────────┐
│   HarfBuzz       │  → Text shaping (ligatures, combining chars)
│   (Shaping)      │
└──────────────────┘
       │
       ▼
┌──────────────────┐
│   FreeType       │  → Glyph rasterization
│   (Rendering)    │
└──────────────────┘
       │
       ▼
┌──────────────────┐
│   Texture Atlas  │  → GPU texture caching
└──────────────────┘
       │
       ▼
   Rendered Text
```

### Key Components

| Component | File | Purpose |
|-----------|------|---------|
| TTFFont | `src/framework/text/TTFFont.cpp` | TrueType font loading and glyph caching |
| TextShaper | `src/framework/text/TextShaper.cpp` | HarfBuzz text shaping integration |
| LocaleShaping | `src/framework/text/LocaleShaping.cpp` | Locale-specific shaping rules |
| BitmapFont | `src/framework/graphics/bitmapfont.cpp` | Bitmap font fallback rendering |
| CachedText | `src/framework/graphics/cachedtext.cpp` | Text caching for performance |

---

## Localization System

### Architecture

The localization system uses Lua files for translations:

```
data/locales/
├── en.lua      # English (default)
├── de.lua      # German
├── es.lua      # Spanish
├── fr.lua      # French
├── it.lua      # Italian
├── ja.lua      # Japanese
├── pl.lua      # Polish
├── pt.lua      # Portuguese
├── ru.lua      # Russian
├── sv.lua      # Swedish
└── zh.lua      # Chinese
```

### Locale File Structure

```lua
locale = {
  name = "xx",              -- ISO 639-1 code
  charset = "utf-8",        -- Character encoding
  languageName = "Language", -- Display name

  formatNumbers = true,
  decimalSeperator = '.',
  thousandsSeperator = ',',

  translation = {
    ["English text"] = "Translated text",
    -- ... more translations
  }
}

modules.client_locales.installLocale(locale)
```

### Translation Function

Use `tr()` in Lua scripts:

```lua
-- Simple translation
local text = tr("Hello World")

-- With format parameters
local text = tr("Level %d", playerLevel)
```

---

## Adding New Languages

### Step 1: Create Locale File

Create `data/locales/xx.lua` where `xx` is the ISO 639-1 language code:

```lua
locale = {
  name = "xx",
  charset = "utf-8",
  languageName = "Language Name",

  formatNumbers = true,
  decimalSeperator = '.',
  thousandsSeperator = ',',

  translation = {}
}

modules.client_locales.installLocale(locale)
```

### Step 2: Add Translations

Translate all keys from `neededtranslations.lua`:

```lua
translation = {
  ["Accept"] = "...",
  ["Cancel"] = "...",
  -- See modules/client_locales/neededtranslations.lua for full list
}
```

### Step 3: Add Flag Image

Add flag icon at `data/images/flags/xx.png` (32x22 pixels)

### Step 4: Test

1. Start the client
2. Open language picker (first run or through settings)
3. Select your new language
4. Verify all UI elements display correctly

---

## Font Configuration

### Default Fonts

Fonts are configured in the data files:

```
data/fonts/
├── verdana-11px-bold.otfont      # UI font
├── verdana-11px-monochrome.otfont # Console font
└── ...
```

### TTF Font Support

For full Unicode support, TTF fonts are loaded via FreeType:

```cpp
// In source code
TTFFont::load("fonts/NotoSans.ttf", fontSize);
```

### Font Fallback

When a glyph is missing:
1. Try primary TTF font
2. Try fallback fonts (Noto Sans, etc.)
3. Fall back to bitmap font
4. Display placeholder glyph

---

## Technical Details

### Character Encoding

- **Input**: UTF-8 (universal)
- **Internal**: UTF-32 (for processing)
- **Display**: Platform-specific (rendered via OpenGL)

### Supported Scripts

| Script | Languages | Notes |
|--------|-----------|-------|
| Latin | EN, ES, FR, DE, PT, PL, etc. | Full support |
| Cyrillic | RU, UK, BG, etc. | Full support |
| CJK | ZH, JA, KO | Requires CJK fonts |
| Arabic | AR | RTL + shaping |
| Hebrew | HE | RTL support |
| Thai | TH | Complex shaping |
| Devanagari | HI, NE | Complex shaping |

### Performance Optimization

1. **Glyph Atlas**: Frequently used glyphs cached in GPU texture
2. **Text Caching**: CachedText stores pre-shaped text
3. **Batch Rendering**: Multiple text draws batched together
4. **Lazy Loading**: Glyphs loaded on-demand

### Memory Usage

| Component | Memory |
|-----------|--------|
| TTF Font (per font) | ~2-10 MB |
| Glyph Atlas | ~4-16 MB per atlas |
| CachedText | ~100 bytes per text |

---

## Troubleshooting

### Common Issues

**Problem**: Text displays as boxes/rectangles
- **Solution**: Install appropriate font with required glyphs

**Problem**: RTL text displays backwards
- **Solution**: Ensure FriBidi is enabled in build

**Problem**: Characters appear garbled
- **Solution**: Check charset in locale file matches actual encoding

**Problem**: Some translations missing
- **Solution**: Add missing keys to translation table

### Debug Tools

```lua
-- Generate list of missing translations
modules.client_locales.generateNewTranslationTable("xx")

-- Check current locale
print(modules.client_locales.getCurrentLocale().name)
```

---

## Related Documentation

- `docs/ARCHITECTURE.md` - Overall architecture
- `I18N_Progress.md` - Implementation progress
- `I18N_Next_Steps.md` - Future improvements

---

*Last updated: December 2025*
