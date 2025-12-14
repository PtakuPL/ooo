#include "TTFFont.h"

#include <cmath>
#include <algorithm>
#include <exception>
// OTClient rendering helpers
#include <framework/core/logger.h>
#include <framework/graphics/drawpoolmanager.h> // g_drawPool
#include <framework/graphics/coordsbuffer.h>
#include <framework/graphics/graphics.h>
#include <framework/core/resourcemanager.h>
#include <framework/util/rect.h>
#include <framework/util/color.h>
#include <framework/util/point.h>
#include <framework/util/size.h>

TTFFont::TTFFont() {}
/**
 * @brief Releases all native font resources owned by this TTFFont.
 *
 * @details Destroys the HarfBuzz font handles (primary and fallbacks), frees the FreeType face objects (primary and fallbacks), and shuts down the FreeType library handle owned by this instance.
 */
TTFFont::~TTFFont() {
  if (m_hbFont) hb_font_destroy(m_hbFont);
  for (auto* f : m_fallbackHbFonts) if (f) hb_font_destroy(f);
  if (m_face) FT_Done_Face(m_face);
  for (auto f : m_fallbackFaces) if (f) FT_Done_Face(f);
  if (m_ftLib) FT_Done_FreeType(m_ftLib);
}

/**
 * @brief Loads the primary TrueType font and optional fallback fonts, initializes shaping and atlases.
 *
 * Initializes the FreeType library, creates the main FT_Face and corresponding HarfBuzz font, sets the pixel size,
 * attempts to load and register each fallback font (creating both FT_Face and HarfBuzz font when available), and
 * ensures an initial glyph atlas is allocated.
 *
 * @param mainTtf Path to the primary TrueType font file to load.
 * @param fallbackTtfs Vector of file paths for fallback TrueType fonts to register for missing glyphs.
 * @param pixelSize Pixel height to set for all loaded font faces.
 * @return true if the FreeType library, main font, HarfBuzz font(s), and an initial atlas were successfully created; false if initialization or loading the main face failed.
 */
bool TTFFont::load(const std::string& mainTtf,
                   const std::vector<std::string>& fallbackTtfs,
                   int pixelSize) {
  g_logger.info(fmt::format("TTFFont::load() mainTtf='{}' size={}", mainTtf, pixelSize));
  
  const FT_Error initError = FT_Init_FreeType(&m_ftLib);
  if (initError) {
    g_logger.error("TTFFont: FT_Init_FreeType failed (error={})", initError);
    return false;
  }
  g_logger.info("TTFFont: FreeType initialized OK");

  // Try to load font - first via filesystem path, then via memory
  bool mainLoaded = false;
  
  // Method 1: Try getRealPath() for direct filesystem access
  const std::string realPath = g_resources.getRealPath(mainTtf);
  g_logger.info(fmt::format("TTFFont: getRealPath('{}') = '{}'", mainTtf, realPath));
  
  if (!realPath.empty()) {
    const FT_Error faceError = FT_New_Face(m_ftLib, realPath.c_str(), 0, &m_face);
    if (faceError == 0) {
      mainLoaded = true;
      g_logger.info(fmt::format("TTFFont: FT_New_Face succeeded with path '{}'", realPath));
    } else {
      g_logger.warning(fmt::format("TTFFont: FT_New_Face failed (error={}) for path '{}'", faceError, realPath));
    }
  }
  
  // Method 2: Fallback to memory loading (for PhysFS archives)
  if (!mainLoaded) {
    g_logger.info("TTFFont: trying memory-based loading...");
    try {
      m_mainFontData = g_resources.readFileContents(mainTtf);
      g_logger.info(fmt::format("TTFFont: readFileContents got {} bytes", m_mainFontData.size()));
    } catch (const std::exception& e) {
      g_logger.error(fmt::format("TTFFont: readFileContents exception: {}", e.what()));
      return false;
    } catch (...) {
      g_logger.error("TTFFont: readFileContents unknown exception");
      return false;
    }

    if (m_mainFontData.empty()) {
      g_logger.error("TTFFont: font data is empty");
      return false;
    }

    const FT_Error memFaceError = FT_New_Memory_Face(
        m_ftLib,
        reinterpret_cast<const FT_Byte*>(m_mainFontData.data()),
        static_cast<FT_Long>(m_mainFontData.size()),
        0,
        &m_face);
    if (memFaceError == 0) {
      mainLoaded = true;
      g_logger.info("TTFFont: FT_New_Memory_Face succeeded");
    } else {
      g_logger.error(fmt::format("TTFFont: FT_New_Memory_Face failed (error={})", memFaceError));
    }
  }

  if (!mainLoaded) {
    g_logger.error("TTFFont: failed to load main font by any method");
    return false;
  }

  const FT_Error pixelSizeError = FT_Set_Pixel_Sizes(m_face, 0, pixelSize);
  if (pixelSizeError) {
    g_logger.error("TTFFont: FT_Set_Pixel_Sizes failed (error={})", pixelSizeError);
    return false;
  }
  m_pixelSize = pixelSize;
  g_logger.info(fmt::format("TTFFont: pixel size set to {}", pixelSize));

  // Create HarfBuzz face/font from FT_Face
  hb_face_t* hbFace = hb_ft_face_create(m_face, nullptr);
  m_hbFont = hb_ft_font_create(m_face, nullptr);
  hb_face_destroy(hbFace);
  if (!m_hbFont) {
    g_logger.error("TTFFont: HarfBuzz font creation failed");
    return false;
  }
  g_logger.info("TTFFont: HarfBuzz font created OK");

  // Load fallback fonts for CJK, Arabic, and other scripts
  for (const auto& fallbackPath : fallbackTtfs) {
    g_logger.info(fmt::format("TTFFont: loading fallback font '{}'", fallbackPath));
    FT_Face fallbackFace = nullptr;
    bool fallbackLoaded = false;

    // Try filesystem path first using getRealPath()
    const std::string realFallbackPath = g_resources.getRealPath(fallbackPath);
    if (!realFallbackPath.empty()) {
      const FT_Error err = FT_New_Face(m_ftLib, realFallbackPath.c_str(), 0, &fallbackFace);
      if (err == 0) {
        fallbackLoaded = true;
        g_logger.info(fmt::format("TTFFont: fallback '{}' loaded from filesystem", fallbackPath));
      }
    }

    // Fallback to memory face (PhysFS archive-safe).
    if (!fallbackLoaded) {
      try {
        m_fallbackFontData.emplace_back(g_resources.readFileContents(fallbackPath));
        const auto& data = m_fallbackFontData.back();
        if (!data.empty()) {
          const FT_Error err = FT_New_Memory_Face(
              m_ftLib,
              reinterpret_cast<const FT_Byte*>(data.data()),
              static_cast<FT_Long>(data.size()),
              0,
              &fallbackFace);
          if (err == 0) {
            fallbackLoaded = true;
            g_logger.info(fmt::format("TTFFont: fallback '{}' loaded from memory", fallbackPath));
          } else {
            m_fallbackFontData.pop_back();
          }
        } else {
          m_fallbackFontData.pop_back();
        }
      } catch (const std::exception& e) {
        g_logger.warning(fmt::format("TTFFont: fallback '{}' exception: {}", fallbackPath, e.what()));
        continue;
      } catch (...) {
        continue;
      }
    }

    if (!fallbackLoaded) {
      g_logger.warning(fmt::format("TTFFont: failed to load fallback '{}'", fallbackPath));
      continue;
    }

    const FT_Error fallbackSizeError = FT_Set_Pixel_Sizes(fallbackFace, 0, pixelSize);
    if (fallbackSizeError) {
      FT_Done_Face(fallbackFace);
      continue;
    }
    hb_font_t* fallbackHbFont = hb_ft_font_create(fallbackFace, nullptr);
    if (fallbackHbFont) {
      m_fallbackFaces.push_back(fallbackFace);
      m_fallbackHbFonts.push_back(fallbackHbFont);
    } else {
      FT_Done_Face(fallbackFace);
    }
  }

  g_logger.info(fmt::format("TTFFont::load() completed successfully with {} fallback fonts", m_fallbackFaces.size()));
  return true;
}

/**
 * @brief Create and append a new texture atlas for glyph rasterization.
 *
 * Initializes a 2048×2048 atlas with pen/row metrics reset, allocates a blank RGBA image,
 * creates a GPU texture for that image (smoothing enabled, no mipmaps or compression),
 * stores the atlas in the internal list, and returns its index.
 *
 * @return int Index of the newly created atlas within the internal atlas list.
 */
int TTFFont::ensureAtlas() {
  int atlasSize = 1024;
  const int maxTextureSize = g_graphics.getMaxTextureSize();
  if (maxTextureSize > 0)
    atlasSize = std::min(atlasSize, maxTextureSize);
  atlasSize = std::max(atlasSize, 256);

  try {
    Atlas a;
    a.width = atlasSize;
    a.height = atlasSize;
    a.penX = a.penY = a.rowH = 0;

    // Create blank RGBA image and corresponding GPU texture
    a.image = std::make_shared<Image>(Size(a.width, a.height), 4 /*bpp*/, nullptr);
    a.texture = std::make_shared<Texture>(a.image, /*buildMipmaps*/false, /*compress*/false);
    a.texture->setSmooth(true);

    // NOTE: On some platforms (notably Windows) fonts may be loaded before the GL context is ready.
    // In that case, Texture::create() would produce m_id=0 and all subsequent sub-uploads would be ignored.
    // We defer GPU creation until we actually render (when g_graphics.ok() is true).
    if (g_graphics.ok()) {
      a.texture->create();
    }

    m_atlases.push_back(a);
    return static_cast<int>(m_atlases.size() - 1);
  } catch (const std::exception& e) {
    g_logger.error("TTF: failed to allocate glyph atlas {}x{}: {}", atlasSize, atlasSize, e.what());
    return -1;
  } catch (...) {
    g_logger.error("TTF: failed to allocate glyph atlas {}x{}: unknown exception", atlasSize, atlasSize);
    return -1;
  }
}

bool TTFFont::ensureAtlasGpuTexture(Atlas& atlas)
{
  if (!atlas.texture)
    return false;

  if (!atlas.texture->isEmpty())
    return true;

  if (!g_graphics.ok())
    return false;

  if (!atlas.image)
    return false;

  // Re-upload the whole atlas image to initialize the GL texture id and content.
  atlas.texture->updateImage(atlas.image);
  atlas.texture->create();

  if (atlas.texture->isEmpty()) {
    g_logger.warning("TTFFont: failed to create atlas GPU texture (id=0) even though g_graphics.ok()=true");
    return false;
  }

  static bool s_loggedOnce = false;
  if (!s_loggedOnce) {
    g_logger.info("TTFFont: atlas GPU texture created lazily (id={})", atlas.texture->getId());
    s_loggedOnce = true;
  }

  return true;
}

void TTFFont::ensureAtlasesGpuTextures()
{
  if (!g_graphics.ok())
    return;

  for (auto& atlas : m_atlases) {
    ensureAtlasGpuTexture(atlas);
  }
}

/**
 * @brief Retrieve or create a cached AtlasGlyph for a glyph from the main font or fallbacks.
 *
 * Checks the in-memory glyph cache for the provided glyph index. If not cached, attempts to
 * load and render the glyph from the primary FreeType face and rasterizes it into an atlas.
 * If the primary face cannot produce a glyph and a Unicode `codepoint` is provided, searches
 * each fallback face for the codepoint, renders the first matching glyph found, and rasterizes
 * it using a composite cache key that encodes the fallback index and glyph index.
 *
 * Glyph index 0 (the `.notdef` glyph) is treated as missing unless the rendered bitmap has
 * non-zero dimensions.
 *
 * @param glyphIndex Glyph index to lookup or rasterize from the main face.
 * @param codepoint Unicode codepoint used to search fallback faces when the main face cannot render the glyph (0 to skip fallback search).
 * @return const AtlasGlyph* Pointer to the cached or newly rasterized AtlasGlyph on success, `nullptr` if no glyph could be rendered.
 */
const AtlasGlyph* TTFFont::cacheGlyph(uint32_t glyphIndex, char32_t codepoint) {
  // First check cache by glyph index (main font)
  auto it = m_glyphs.find(glyphIndex);
  if (it != m_glyphs.end()) return &it->second;

  // Try to render from main font
  if (FT_Load_Glyph(m_face, glyphIndex, FT_LOAD_DEFAULT) == 0 &&
      FT_Render_Glyph(m_face->glyph, FT_RENDER_MODE_NORMAL) == 0) {
    // Check if glyph was found (not the .notdef glyph with index 0, or has actual bitmap)
    FT_GlyphSlot g = m_face->glyph;
    if (glyphIndex != 0 || g->bitmap.width > 0) {
      return rasterizeGlyph(m_face, glyphIndex, glyphIndex);
    }
  }

  // Main font failed - try fallback fonts using codepoint
  if (codepoint != 0) {
    for (size_t fbIdx = 0; fbIdx < m_fallbackFaces.size(); ++fbIdx) {
      FT_Face fallbackFace = m_fallbackFaces[fbIdx];
      // Get glyph index for this codepoint in fallback font
      FT_UInt fbGlyphIndex = FT_Get_Char_Index(fallbackFace, codepoint);
      if (fbGlyphIndex == 0) continue; // .notdef glyph - font doesn't have this char

      if (FT_Load_Glyph(fallbackFace, fbGlyphIndex, FT_LOAD_DEFAULT) == 0 &&
          FT_Render_Glyph(fallbackFace->glyph, FT_RENDER_MODE_NORMAL) == 0) {
        // Use unique cache key: high bits for fallback index, low bits for glyph
        const uint32_t cacheKey = static_cast<uint32_t>((fbIdx + 1) << 24) | (fbGlyphIndex & 0xFFFFFF);
        return rasterizeGlyph(fallbackFace, fbGlyphIndex, cacheKey);
      }
    }
  }

  return nullptr;
}

/**
 * @brief Rasterizes a FreeType glyph into the font atlas and caches the result.
 *
 * Rasterizes the glyph bitmap from the provided FreeType face and places it into
 * an atlas texture (creating a new atlas if necessary), uploads the updated
 * atlas sub-region to the GPU, and records glyph metrics in the glyph cache
 * under the provided cache key.
 *
 * @param face FreeType face that contains the loaded glyph (face->glyph must be set).
 * @param glyphIndex Index of the glyph within the given FreeType face.
 * @param cacheKey Unique cache key used to store and lookup the resulting AtlasGlyph.
 *                 This key must uniquely identify the face/glyph combination.
 * @return const AtlasGlyph* Pointer to the cached AtlasGlyph corresponding to `cacheKey`.
 */
const AtlasGlyph* TTFFont::rasterizeGlyph(FT_Face face, uint32_t glyphIndex, uint32_t cacheKey) {
  // Check if already in cache
  auto it = m_glyphs.find(cacheKey);
  if (it != m_glyphs.end()) return &it->second;

  FT_GlyphSlot g = face->glyph;
  const int w = g->bitmap.width;
  const int h = g->bitmap.rows;

  // Space/empty glyph
  if (w == 0 || h == 0) {
    AtlasGlyph ag{};
    ag.texture = nullptr;
    ag.x = ag.y = ag.w = ag.h = 0;
    ag.bearingX = g->bitmap_left;
    ag.bearingY = g->bitmap_top;
    ag.advance  = static_cast<int>(g->advance.x);
    m_glyphs[cacheKey] = ag;
    return &m_glyphs[cacheKey];
  }

  if (m_atlases.empty()) {
    if (ensureAtlas() < 0)
      return nullptr;
  }

  // Pack into current atlas; make a new one if needed
  Atlas* A = &m_atlases.back();
  if (A->penX + w + 2 > A->width) { A->penX = 0; A->penY += A->rowH + 2; A->rowH = 0; }
  if (A->penY + h + 2 > A->height) {
    if (ensureAtlas() < 0)
      return nullptr;
    A = &m_atlases.back();
  }

  // Convert FT grayscale bitmap -> RGBA (white with alpha)
  ImagePtr glyphImage;
  try {
    glyphImage = std::make_shared<Image>(Size(w, h), 4);
    for (int yy = 0; yy < h; ++yy) {
      const uint8_t* srcRow = g->bitmap.buffer + yy * g->bitmap.pitch;
      for (int xx = 0; xx < w; ++xx) {
        const uint8_t a = srcRow[xx];
        uint8_t* dst = glyphImage->getPixel(xx, yy);
        dst[0] = 255; dst[1] = 255; dst[2] = 255; dst[3] = a;
      }
    }
  } catch (const std::exception& e) {
    g_logger.error("TTF: glyph rasterization failed (glyph={} {}x{}): {}", glyphIndex, w, h, e.what());
    return nullptr;
  } catch (...) {
    g_logger.error("TTF: glyph rasterization failed (glyph={} {}x{}): unknown exception", glyphIndex, w, h);
    return nullptr;
  }

  // Copy to CPU atlas and upload only the updated sub-region to the GPU
  const Point destPoint(A->penX, A->penY);
  A->image->blit(destPoint, glyphImage);

  // Make sure the atlas has a valid GL texture id before sub-upload.
  if (!ensureAtlasGpuTexture(*A)) {
    // We still keep CPU atlas updated, so once GL is ready a full upload can happen.
    // Returning nullptr here prevents caching a glyph that would never render.
    return nullptr;
  }

  A->texture->uploadSubPixels(Rect(destPoint, Size(w, h)), glyphImage);

  // Register glyph metrics
  AtlasGlyph ag{};
  ag.texture  = A->texture;
  ag.x = A->penX; ag.y = A->penY; ag.w = w; ag.h = h;
  ag.bearingX = g->bitmap_left;
  ag.bearingY = g->bitmap_top;
  ag.advance  = static_cast<int>(g->advance.x);
  m_glyphs[cacheKey] = ag;

  // Advance pen
  A->penX += w + 2;
  if (h > A->rowH) A->rowH = h;

  return &m_glyphs[cacheKey];
}

/**
 * @brief Renders shaped Unicode text to the screen using cached glyph atlases.
 *
 * Shapes the provided UTF-32 text into glyph quads, groups quads into batches by atlas
 * texture, and submits textured quad batches to the global draw pool using the given color.
 * If no HarfBuzz font is loaded or the text is empty, the call is a no-op.
 *
 * @param text32 UTF-32 encoded text to render.
 * @param x Horizontal baseline position in pixels.
 * @param y Vertical baseline position in pixels.
 * @param params Shaping parameters (e.g., direction, script, language, tracking) used for layout.
 * @param color Color applied to the rendered glyphs.
 */
void TTFFont::drawText(const std::u32string& text32,
             float x, float y,
             const ShapeParams& params,
             const Color& color) {
  static bool s_loggedFirstCall = false;
  static bool s_warnedMissingHbFont = false;
  static bool s_warnedNoQuads = false;
  static bool s_warnedNullOrEmptyTexture = false;

  if (!m_hbFont) {
    if (!s_warnedMissingHbFont) {
      g_logger.warning("TTFFont::drawText: m_hbFont is null (font not ready); text will not render");
      s_warnedMissingHbFont = true;
    }
    return;
  }

  if (text32.empty())
    return;

  // If atlases were created before GL was ready, their Texture ids may still be 0.
  // Ensure GPU textures exist before we start batching/drawing.
  ensureAtlasesGpuTextures();

  std::vector<GlyphQuad> quads;
  const Rect bounds = buildQuads(text32, params, quads);
  if (quads.empty()) {
    if (!s_warnedNoQuads) {
      g_logger.warning("TTFFont::drawText: buildQuads produced 0 quads for {} codepoints (text will not render)", text32.size());
      s_warnedNoQuads = true;
    }
    return;
  }

  if (!s_loggedFirstCall) {
    g_logger.info("TTFFont::drawText: first call OK (quads={}, x={}, y={})", quads.size(), x, y);
    s_loggedFirstCall = true;
  }

  struct Batch {
    TexturePtr texture;
    CoordsBufferPtr coords;
  };

  std::vector<Batch> batches;
  batches.reserve(m_atlases.size());
  std::unordered_map<const Texture*, size_t> batchIndex;
  batchIndex.reserve(m_atlases.size());

  const auto getBatchCoords = [&](const TexturePtr& texture) -> CoordsBufferPtr {
    const auto raw = texture.get();
    const auto [it, inserted] = batchIndex.try_emplace(raw, batches.size());
    if (inserted) {
      batches.push_back({ texture, std::make_shared<CoordsBuffer>(std::max<size_t>(quads.size(), 16)) });
      return batches.back().coords;
    }
    return batches[it->second].coords;
  };

  const Point baselineOffset(static_cast<int>(std::lround(x)), static_cast<int>(std::lround(y)));
  for (const auto& quad : quads) {
    Rect dest = quad.dest;
    dest.translate(baselineOffset);
    getBatchCoords(quad.texture)->addRect(dest, quad.src);
  }

  for (const auto& batch : batches) {
    if (batch.coords && batch.coords->getVertexCount() > 0) {
      if (!batch.texture || batch.texture->isEmpty()) {
        if (!s_warnedNullOrEmptyTexture) {
          g_logger.warning("TTFFont::drawText: submitting vertices={} with INVALID texture (ptr={}, id={}) -> text will not render", 
                           batch.coords->getVertexCount(), (batch.texture != nullptr), batch.texture ? batch.texture->getId() : 0);
          s_warnedNullOrEmptyTexture = true;
        }
      }
      g_drawPool.addTexturedCoordsBuffer(batch.texture, batch.coords, color);
    }
  }
}

float TTFFont::measureTextWidth(const std::u32string& text32,
                                const ShapeParams& params) {
  if (!m_hbFont || text32.empty()) return 0.f;
  const auto shaped = TextShaper::shape(text32, m_hbFont, params);
  float penX = 0.f;
  for (const auto& sg : shaped) {
    penX += sg.advanceX;
  }
  return penX;
}

TexturePtr TTFFont::getAtlasTexture(const size_t index) const
{
  if (index >= m_atlases.size())
    return nullptr;
  return m_atlases[index].texture;
}

/**
 * @brief Shape UTF-32 text into drawable glyph quads and compute its bounding rectangle.
 *
 * Shapes the provided UTF-32 string using the font and shaping parameters, fills
 * outQuads with GlyphQuad entries for each glyph that has atlas geometry, and
 * computes the pixel-aligned bounding Rect that encloses the drawn glyphs.
 *
 * @param text32 UTF-32 encoded text to shape and layout.
 * @param params Shaping and layout parameters (e.g., direction, script, features).
 * @param outQuads Vector that will be cleared and then populated with glyph quads
 *                 (texture, destination rect, source rect) for rendering.
 * @return Rect Pixel-aligned bounding box of the resulting laid-out text. Returns
 *         an empty Rect if shaping cannot be performed (for example, no font or
 *         empty input). If no drawable glyphs are produced, the returned rect
 *         spans the advance width with a height equal to the font pixel size;
 *         width and height are clamped to at least 1. 
 */
Rect TTFFont::buildQuads(const std::u32string& text32,
             const ShapeParams& params,
             std::vector<GlyphQuad>& outQuads)
{
  outQuads.clear();
  if (!m_hbFont || text32.empty())
    return {};

  const auto shaped = TextShaper::shape(text32, m_hbFont, params);
  if (shaped.empty())
    return {};

  outQuads.reserve(shaped.size());

  float penX = 0.f;
  float penY = 0.f;
  bool hasBounds = false;
  float minX = 0.f;
  float minY = 0.f;
  float maxX = 0.f;
  float maxY = static_cast<float>(m_pixelSize);

  for (const auto& sg : shaped) {
    const AtlasGlyph* ag = cacheGlyph(sg.glyphIndex, sg.codepoint);
    if (ag && ag->w > 0 && ag->h > 0) {
      const float dx = penX + ag->bearingX + sg.x;
      const float dy = penY - ag->bearingY - sg.y;
      GlyphQuad quad;
      quad.texture = ag->texture;
      quad.dest = Rect(static_cast<int>(std::lround(dx)),
               static_cast<int>(std::lround(dy)),
               ag->w, ag->h);
      quad.src = Rect(ag->x, ag->y, ag->w, ag->h);
      outQuads.push_back(quad);

      if (!hasBounds) {
        minX = quad.dest.left();
        minY = quad.dest.top();
        maxX = quad.dest.right() + 1;
        maxY = quad.dest.bottom() + 1;
        hasBounds = true;
      } else {
        minX = std::min<float>(minX, quad.dest.left());
        minY = std::min<float>(minY, quad.dest.top());
        maxX = std::max<float>(maxX, static_cast<float>(quad.dest.right() + 1));
        maxY = std::max<float>(maxY, static_cast<float>(quad.dest.bottom() + 1));
      }
    }

    penX += sg.advanceX;
    penY += sg.advanceY;
  }

  if (!hasBounds) {
    minX = 0.f;
    minY = 0.f;
    maxX = penX;
    maxY = static_cast<float>(m_pixelSize);
  } else {
    maxX = std::max<float>(maxX, penX);
  }

  const int left = static_cast<int>(std::floor(minX));
  const int top = static_cast<int>(std::floor(minY));
  const int width = std::max(0, static_cast<int>(std::ceil(maxX) - left));
  const int height = std::max(0, static_cast<int>(std::ceil(maxY) - top));
  return Rect(left, top, width == 0 ? 1 : width, height == 0 ? m_pixelSize : height);
}
