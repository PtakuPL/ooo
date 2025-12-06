#include "TTFFont.h"

#include <cmath>
#include <algorithm>
// OTClient rendering helpers
#include <framework/graphics/drawpoolmanager.h> // g_drawPool
#include <framework/graphics/coordsbuffer.h>
#include <framework/util/rect.h>
#include <framework/util/color.h>
#include <framework/util/point.h>
#include <framework/util/size.h>

TTFFont::TTFFont() {}
TTFFont::~TTFFont() {
  if (m_hbFont) hb_font_destroy(m_hbFont);
  for (auto* f : m_fallbackHbFonts) if (f) hb_font_destroy(f);
  if (m_face) FT_Done_Face(m_face);
  for (auto f : m_fallbackFaces) if (f) FT_Done_Face(f);
  if (m_ftLib) FT_Done_FreeType(m_ftLib);
}

bool TTFFont::load(const std::string& mainTtf,
                   const std::vector<std::string>& fallbackTtfs,
                   int pixelSize) {
  if (FT_Init_FreeType(&m_ftLib)) return false;
  if (FT_New_Face(m_ftLib, mainTtf.c_str(), 0, &m_face)) return false;
  FT_Set_Pixel_Sizes(m_face, 0, pixelSize);
  m_pixelSize = pixelSize;

  // Create HarfBuzz face/font from FT_Face
  hb_face_t* hbFace = hb_ft_face_create(m_face, nullptr);
  m_hbFont = hb_ft_font_create(m_face, nullptr);
  hb_face_destroy(hbFace);

  // Load fallback fonts for CJK, Arabic, and other scripts
  for (const auto& fallbackPath : fallbackTtfs) {
    FT_Face fallbackFace = nullptr;
    if (FT_New_Face(m_ftLib, fallbackPath.c_str(), 0, &fallbackFace) == 0) {
      FT_Set_Pixel_Sizes(fallbackFace, 0, pixelSize);
      hb_font_t* fallbackHbFont = hb_ft_font_create(fallbackFace, nullptr);
      if (fallbackHbFont) {
        m_fallbackFaces.push_back(fallbackFace);
        m_fallbackHbFonts.push_back(fallbackHbFont);
      } else {
        FT_Done_Face(fallbackFace);
      }
    }
  }

  ensureAtlas();
  return true;
}

int TTFFont::ensureAtlas() {
  Atlas a;
  a.width = 2048; a.height = 2048;
  a.penX = a.penY = a.rowH = 0;

  // Create blank RGBA image and corresponding GPU texture
  a.image = std::make_shared<Image>(Size(a.width, a.height), 4 /*bpp*/, nullptr);
  a.texture = std::make_shared<Texture>(a.image, /*buildMipmaps*/false, /*compress*/false);
  a.texture->setSmooth(true);
  a.texture->create();

  m_atlases.push_back(a);
  return static_cast<int>(m_atlases.size() - 1);
}

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
    ag.texture = m_atlases.back().texture;
    ag.x = ag.y = ag.w = ag.h = 0;
    ag.bearingX = g->bitmap_left;
    ag.bearingY = g->bitmap_top;
    ag.advance  = static_cast<int>(g->advance.x);
    m_glyphs[cacheKey] = ag;
    return &m_glyphs[cacheKey];
  }

  // Pack into current atlas; make a new one if needed
  Atlas* A = &m_atlases.back();
  if (A->penX + w + 2 > A->width) { A->penX = 0; A->penY += A->rowH + 2; A->rowH = 0; }
  if (A->penY + h + 2 > A->height) { ensureAtlas(); A = &m_atlases.back(); }

  // Convert FT grayscale bitmap -> RGBA (white with alpha)
  ImagePtr glyphImage = std::make_shared<Image>(Size(w, h), 4);
  for (int yy = 0; yy < h; ++yy) {
    const uint8_t* srcRow = g->bitmap.buffer + yy * g->bitmap.pitch;
    for (int xx = 0; xx < w; ++xx) {
      const uint8_t a = srcRow[xx];
      uint8_t* dst = glyphImage->getPixel(xx, yy);
      dst[0] = 255; dst[1] = 255; dst[2] = 255; dst[3] = a;
    }
  }

  // Copy to CPU atlas and upload only the updated sub-region to the GPU
  const Point destPoint(A->penX, A->penY);
  A->image->blit(destPoint, glyphImage);
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

void TTFFont::drawText(const std::u32string& text32,
             float x, float y,
             const ShapeParams& params,
             const Color& color) {
  if (!m_hbFont || text32.empty()) return;

  std::vector<GlyphQuad> quads;
  const Rect bounds = buildQuads(text32, params, quads);
  if (quads.empty())
    return;

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
    if (batch.coords && batch.coords->getVertexCount() > 0)
      g_drawPool.addTexturedCoordsBuffer(batch.texture, batch.coords, color);
  }
}

float TTFFont::measureTextWidth(const std::u32string& text32,
                                const ShapeParams& params) {
  if (!m_hbFont || text32.empty()) return 0.f;
  std::vector<GlyphQuad> quads;
  const Rect bounds = buildQuads(text32, params, quads);
  return bounds.isValid() ? bounds.width() : 0.f;
}

TexturePtr TTFFont::getAtlasTexture(const size_t index) const
{
  if (index >= m_atlases.size())
    return nullptr;
  return m_atlases[index].texture;
}

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
