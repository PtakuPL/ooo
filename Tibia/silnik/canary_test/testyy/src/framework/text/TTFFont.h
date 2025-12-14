#pragma once
#include <string>
#include <unordered_map>
#include <vector>
#include <cstdint>

#include <ft2build.h>
#include FT_FREETYPE_H
#include <hb.h>
#include <hb-ft.h>

#include "TextShaper.h"

// OTClient framework graphics
#include <framework/graphics/declarations.h>  // ImagePtr, TexturePtr
#include <framework/graphics/image.h>
#include <framework/graphics/texture.h>
#include <framework/util/color.h>
#include <framework/util/rect.h>

// Minimal glyph metadata stored in an atlas
struct AtlasGlyph {
  TexturePtr texture;   // texture handle of the atlas this glyph lives in
  int x, y;             // position inside the atlas
  int w, h;             // glyph bitmap size
  int bearingX;         // left bearing (pixels)
  int bearingY;         // top bearing  (pixels from baseline)
  int advance;          // advance from FreeType (26.6 fixed) – HB advance is used at draw time
};

class TTFFont;
using TTFFontPtr = std::shared_ptr<TTFFont>;

struct GlyphQuad {
  TexturePtr texture;
  Rect dest; // relative to baseline (0,0)
  Rect src;
};

/**
 * Load the primary TrueType font and optional fallback fonts at the specified pixel height.
 * @param mainTtf Path to the primary TTF file.
 * @param fallbackTtfs Paths to fallback TTF files used when the primary font lacks a glyph.
 * @param pixelSize Desired font height in pixels.
 * @returns `true` if all requested fonts were successfully loaded and initialized, `false` otherwise.
 */

/**
 * Shape and render UTF-32 text at the given baseline position using the current atlas and shaping parameters.
 * @param text32 UTF-32 encoded string to render.
 * @param x X coordinate of the text baseline start in destination space.
 * @param y Y coordinate of the text baseline in destination space.
 * @param params Shaping and layout parameters (e.g., direction, script, language, features).
 * @param color Color to use when rendering the text.
 */

/**
 * Compute the horizontal advance (width) of the shaped text using the current font and shaping parameters.
 * @param text32 UTF-32 encoded string to measure.
 * @param params Shaping and layout parameters affecting glyph selection and positioning.
 * @returns The measured width in pixels.
 */

/**
 * Retrieve the HarfBuzz font handle used for shaping.
 * @returns Pointer to the underlying `hb_font_t` instance.
 */

/**
 * Return the number of texture atlases currently managed by the font.
 * @returns The count of atlases.
 */

/**
 * Get the GPU texture associated with the atlas at the given index.
 * @param index Index of the atlas.
 * @returns A TexturePtr referencing the atlas texture; may be null if the index is out of range.
 */

/**
 * Shape the provided text and build a list of glyph quads describing destination rectangles and source atlas regions.
 * @param text32 UTF-32 encoded string to shape and convert to quads.
 * @param params Shaping and layout parameters used during shaping.
 * @param outQuads Vector to be populated with resulting GlyphQuad entries.
 * @returns A Rect describing the bounding box of the resulting laid-out text relative to the baseline.
 */

/**
 * Ensure the specified glyph is present in an atlas, rasterizing and packing it if necessary.
 * @param glyphIndex Glyph index in the main FreeType face to cache.
 * @param codepoint Optional Unicode codepoint used for fallback lookup when the main face lacks the glyph.
 * @returns Pointer to the cached AtlasGlyph metadata for the requested glyph, or `nullptr` on failure.
 */

/**
 * Rasterize a glyph from the provided FreeType face into an atlas and create its AtlasGlyph entry.
 * @param face FreeType face to rasterize the glyph from.
 * @param glyphIndex Glyph index within the provided face.
 * @param cacheKey Unique key used for caching/mapping this rasterized glyph.
 * @returns Pointer to the created AtlasGlyph metadata, or `nullptr` if rasterization or packing failed.
 */

/**
 * Create a new empty texture atlas and return its index within the managed atlas list.
 * @returns Index of the newly created atlas, or a negative value on failure.
 */
class TTFFont {
public:
  TTFFont();
  ~TTFFont();

  // Load the main TTF and optional fallbacks; pixelSize is the font height in pixels
  bool load(const std::string& mainTtf,
            const std::vector<std::string>& fallbackTtfs,
            int pixelSize);

  // Draw shaped text at baseline position (x,y)
  void drawText(const std::u32string& text32,
                float x, float y,
                const ShapeParams& params,
                const Color& color);

  // Measure width of a string (uses HarfBuzz shaping)
  float measureTextWidth(const std::u32string& text32,
                         const ShapeParams& params);

  hb_font_t* hbFont() const { return m_hbFont; }
  size_t atlasCount() const { return m_atlases.size(); }
  TexturePtr getAtlasTexture(size_t index) const;
  Rect buildQuads(const std::u32string& text32,
                  const ShapeParams& params,
                  std::vector<GlyphQuad>& outQuads);

private:
  struct Atlas;

  // When fonts are loaded from PhysFS archives (e.g. .otpkg), FreeType must use memory faces.
  // These buffers keep font data alive for the lifetime of FT_Face objects created via FT_New_Memory_Face.
  std::string m_mainFontData;
  std::vector<std::string> m_fallbackFontData;

  // Ensure glyph is present in atlas, rasterizing and packing when needed
  // glyphIndex: glyph index in main font, codepoint: Unicode codepoint for fallback lookup
  const AtlasGlyph* cacheGlyph(uint32_t glyphIndex, char32_t codepoint = 0);

  // Rasterize glyph from a specific face into atlas
  const AtlasGlyph* rasterizeGlyph(FT_Face face, uint32_t glyphIndex, uint32_t cacheKey);

  // Create a new empty atlas and return its index
  int ensureAtlas();

  // Ensure GPU textures exist for all atlases (lazy init after GL context is ready)
  void ensureAtlasesGpuTextures();
  bool ensureAtlasGpuTexture(Atlas& atlas);

  // FreeType & HarfBuzz state
  FT_Library m_ftLib = nullptr;
  FT_Face    m_face  = nullptr;
  hb_font_t* m_hbFont = nullptr;

  // (Reserved for future) fallback faces and hb_font objects
  std::vector<FT_Face>     m_fallbackFaces;
  std::vector<hb_font_t*>  m_fallbackHbFonts;

  int m_pixelSize = 12;

  struct Atlas {
    TexturePtr texture;   // GPU texture
    ImagePtr   image;     // CPU-side backing store (RGBA)
    int width, height;
    int penX, penY, rowH; // simple row-based packer
  };
  std::vector<Atlas> m_atlases;
  std::unordered_map<uint32_t, AtlasGlyph> m_glyphs;
};
