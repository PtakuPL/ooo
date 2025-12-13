# TTF Font System & Unicode Support for OTClient

## Overview

This document describes the TrueType Font (TTF) system implementation in OTClient that enables full Unicode support for international character display across all world languages.

## Architecture

### Font Loading Pipeline

```
.otfont config file
       ↓
BitmapFont::load()
       ↓
TTFFont::load(mainTtf, fallbackTtfs, pixelSize)
       ↓
g_resources.getRealPath() → Convert PhysFS virtual path to real filesystem path
       ↓
FT_New_Face() → FreeType loads the TTF file
       ↓
hb_ft_font_create() → HarfBuzz creates shaping context
       ↓
Glyph Atlas → GPU texture for rendering
```

### Key Components

| Component | File | Purpose |
|-----------|------|---------|
| TTFFont | `src/framework/text/TTFFont.cpp` | TTF loading, glyph rasterization, atlas management |
| TextShaper | `src/framework/text/TextShaper.cpp` | HarfBuzz text shaping for complex scripts |
| BitmapFont | `src/framework/graphics/bitmapfont.cpp` | Font config parsing, TTF/bitmap font switching |
| FontManager | `src/framework/graphics/fontmanager.cpp` | Global font registry |
| ResourceManager | `src/framework/core/resourcemanager.cpp` | Path resolution (PhysFS → real path) |

## Critical Fix: Path Resolution

### Problem
FreeType's `FT_New_Face()` requires an absolute filesystem path, but OTClient uses PhysFS virtual paths (e.g., `/fonts/ttf/NotoSans-Regular.ttf`).

### Solution
Added path conversion in `TTFFont::load()`:

```cpp
#include <framework/core/resourcemanager.h>

bool TTFFont::load(const std::string& mainTtf, ...) {
    // Convert virtual path to real filesystem path
    const std::string realMainPath = g_resources.getRealPath(mainTtf);
    if (FT_New_Face(m_ftLib, realMainPath.c_str(), 0, &m_face)) return false;
    
    // Same for fallback fonts
    for (const auto& fallbackPath : fallbackTtfs) {
        const std::string realFallbackPath = g_resources.getRealPath(fallbackPath);
        if (FT_New_Face(m_ftLib, realFallbackPath.c_str(), 0, &fallbackFace) == 0) {
            // ...
        }
    }
}
```

## Font Configuration

### TTF Font Config (.otfont)

```yaml
Font
  name: noto-12
  type: ttf
  source: /fonts/ttf/NotoSans-Regular.ttf
  bold-source: /fonts/ttf/NotoSans-Bold.ttf
  size: 12
  fallback: [ /fonts/ttf/NotoSansSC-Regular.ttf, /fonts/ttf/NotoNaskhArabic-Regular.ttf ]
```

### Bitmap Font Config (.otfont) - Legacy

```yaml
Font
  name: verdana-11px-antialised
  texture: verdana-11px-antialised_cp1250
  charset: cp1250
  height: 14
  glyph-size: 16 16
  space-width: 4
  default: true
```

## Required TTF Fonts

### Core Fonts (Latin, Cyrillic, Greek)

| Font File | Coverage | Required |
|-----------|----------|----------|
| NotoSans-Regular.ttf | Latin, Cyrillic, Greek, Extended Latin | ✅ Yes |
| NotoSans-Bold.ttf | Bold variant | ✅ Yes |
| NotoSansMono-Regular.ttf | Monospace (console) | ✅ Yes |

### Fallback Fonts (World Languages)

| Font File | Script Coverage | Languages |
|-----------|-----------------|-----------|
| NotoSansSC-Regular.ttf | CJK Simplified | Chinese (Simplified) |
| NotoSansTC-Regular.ttf | CJK Traditional | Chinese (Traditional), Japanese Kanji |
| NotoSansJP-Regular.ttf | Japanese | Japanese (Hiragana, Katakana, Kanji) |
| NotoSansKR-Regular.ttf | Korean | Korean (Hangul) |
| NotoNaskhArabic-Regular.ttf | Arabic | Arabic, Persian, Urdu |
| NotoSansHebrew-Regular.ttf | Hebrew | Hebrew, Yiddish |
| NotoSansThai-Regular.ttf | Thai | Thai |
| NotoSansDevanagari-Regular.ttf | Devanagari | Hindi, Sanskrit, Marathi |
| NotoSansBengali-Regular.ttf | Bengali | Bengali, Assamese |
| NotoSansTamil-Regular.ttf | Tamil | Tamil |
| NotoSansGeorgian-Regular.ttf | Georgian | Georgian |
| NotoSansArmenian-Regular.ttf | Armenian | Armenian |

## Language Support Matrix

| Language | Script | Base Font | Fallback Required |
|----------|--------|-----------|-------------------|
| English | Latin | NotoSans | No |
| Polish | Latin Extended | NotoSans | No |
| German | Latin | NotoSans | No |
| French | Latin | NotoSans | No |
| Spanish | Latin | NotoSans | No |
| Portuguese | Latin | NotoSans | No |
| Russian | Cyrillic | NotoSans | No |
| Ukrainian | Cyrillic | NotoSans | No |
| Greek | Greek | NotoSans | No |
| Chinese (Simplified) | CJK | - | NotoSansSC |
| Chinese (Traditional) | CJK | - | NotoSansTC |
| Japanese | CJK + Kana | - | NotoSansJP |
| Korean | Hangul | - | NotoSansKR |
| Arabic | Arabic | - | NotoNaskhArabic |
| Hebrew | Hebrew | - | NotoSansHebrew |
| Thai | Thai | - | NotoSansThai |
| Hindi | Devanagari | - | NotoSansDevanagari |

## HarfBuzz Text Shaping

HarfBuzz provides complex text shaping for:
- **Right-to-Left (RTL)**: Arabic, Hebrew
- **Complex Scripts**: Thai, Devanagari, Bengali
- **Ligatures**: Arabic connected forms, Latin fi/fl
- **Diacritics**: Proper positioning of accents

### Shaping Parameters

```cpp
struct ShapeParams {
    hb_direction_t direction;  // LTR, RTL, TTB, BTT
    hb_script_t script;        // HB_SCRIPT_LATIN, HB_SCRIPT_ARABIC, etc.
    const char* language;      // "en", "pl", "ar", etc.
};
```

## File Structure

```
data/fonts/
├── ttf/
│   ├── NotoSans-Regular.ttf        # Main font
│   ├── NotoSans-Bold.ttf           # Bold variant
│   ├── NotoSansMono-Regular.ttf    # Monospace
│   ├── NotoSansSC-Regular.ttf      # Chinese Simplified
│   ├── NotoSansTC-Regular.ttf      # Chinese Traditional
│   ├── NotoSansJP-Regular.ttf      # Japanese
│   ├── NotoSansKR-Regular.ttf      # Korean
│   ├── NotoNaskhArabic-Regular.ttf # Arabic
│   ├── NotoSansHebrew-Regular.ttf  # Hebrew
│   ├── NotoSansThai-Regular.ttf    # Thai
│   └── NotoSansDevanagari-Regular.ttf # Hindi
├── noto-12.otfont                  # TTF config with fallbacks
├── mono-12.otfont                  # Monospace TTF config
└── verdana-11px-*.otfont           # Legacy bitmap fonts
```

## Migration from Bitmap to TTF

### Per-Module Migration

To migrate a UI module from bitmap to TTF fonts:

1. In `.otui` files, change:
   ```yaml
   font: verdana-11px-antialised
   ```
   to:
   ```yaml
   font: noto-12
   ```

2. Test character rendering for all supported languages.

### Global Default Font

To set TTF as the global default:

1. In `noto-12.otfont`, add:
   ```yaml
   default: true
   ```

2. In `verdana-11px-antialised.otfont`, remove or set:
   ```yaml
   default: false
   ```

## Troubleshooting

### "TTF load failed" Error

**Symptom**: Log shows `TTF load failed: /fonts/ttf/NotoSans-Regular.ttf`

**Cause**: PhysFS virtual path passed to FreeType instead of real filesystem path.

**Solution**: Ensure `g_resources.getRealPath()` is called before `FT_New_Face()`.

### Garbled Characters

**Symptom**: Polish characters like "ąęźżółść" display as boxes or wrong characters.

**Causes**:
1. Using bitmap font with CP1250 charset instead of TTF
2. Source text is UTF-8 but font expects different encoding
3. Missing glyphs in font

**Solution**: Use TTF font (noto-12) which supports full Unicode.

### Missing Glyphs (Boxes/Tofu)

**Symptom**: Some characters display as empty boxes (□).

**Cause**: Font doesn't contain the required glyph.

**Solution**: Add appropriate fallback font to the `fallback:` list in .otfont config.

## Performance Considerations

- **Atlas Size**: 2048×2048 pixels per atlas
- **Glyph Caching**: Glyphs are rasterized once and cached in atlas
- **Memory**: Each font face + HarfBuzz context ≈ 1-2 MB
- **Fallback Lookup**: Sequential search through fallback fonts (O(n))

## References

- [FreeType Documentation](https://freetype.org/freetype2/docs/)
- [HarfBuzz Manual](https://harfbuzz.github.io/)
- [Google Noto Fonts](https://fonts.google.com/noto)
- [Unicode Scripts](https://unicode.org/standard/supported.html)
