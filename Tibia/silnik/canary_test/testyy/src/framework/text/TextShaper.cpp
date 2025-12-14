#include "TextShaper.h"
#include <stdexcept>
#include <algorithm>
#include <mutex>
#include <unordered_map>
#include <type_traits>

namespace {
constexpr size_t kShapeCacheMaxEntries = 256;
constexpr size_t kShapeCacheMaxLength = 256;

struct ShapeCacheKey {
  hb_font_t* font {};
  std::u32string text;
  TextDirection direction { TextDirection::AUTO };
  std::string script;
  std::string language;

  bool operator==(const ShapeCacheKey &) const = default;
};

struct ShapeCacheKeyHasher {
  size_t operator()(const ShapeCacheKey &key) const {
    size_t seed = std::hash<hb_font_t*>{}(key.font);
    const auto combine = [&seed](size_t value) {
      seed ^= value + 0x9e3779b9 + (seed << 6) + (seed >> 2);
    };
    combine(std::hash<std::u32string>{}(key.text));
    combine(std::hash<std::underlying_type_t<TextDirection>>{}(static_cast<std::underlying_type_t<TextDirection>>(key.direction)));
    combine(std::hash<std::string>{}(key.script));
    combine(std::hash<std::string>{}(key.language));
    return seed;
  }
};

struct ShapeCacheEntry {
  std::vector<ShapedGlyph> glyphs;
  size_t tick = 0;
};

std::unordered_map<ShapeCacheKey, ShapeCacheEntry, ShapeCacheKeyHasher> g_shapeCache;
size_t g_shapeCacheTick = 0;
std::mutex g_shapeCacheMutex;
} // namespace
#include <mutex>
#include <unordered_map>

/**
 * @brief Maps a four-character script tag to the corresponding HarfBuzz script enum.
 *
 * @param s Script tag (e.g., "Latn", "Cyrl", "Grek").
 * @return hb_script_t Corresponding `HB_SCRIPT_*` value; returns `HB_SCRIPT_LATIN` when the tag is not recognized.
 */
static hb_script_t toHbScript(const std::string& s) {
  if (s == "Cyrl") return HB_SCRIPT_CYRILLIC;
  if (s == "Grek") return HB_SCRIPT_GREEK;
  if (s == "Arab") return HB_SCRIPT_ARABIC;
  if (s == "Hebr") return HB_SCRIPT_HEBREW;
  if (s == "Hani") return HB_SCRIPT_HAN;
  if (s == "Hang") return HB_SCRIPT_HANGUL;
  if (s == "Jpan") return HB_SCRIPT_HIRAGANA;
  if (s == "Thai") return HB_SCRIPT_THAI;
  if (s == "Deva") return HB_SCRIPT_DEVANAGARI;
  if (s == "Beng") return HB_SCRIPT_BENGALI;
  return HB_SCRIPT_LATIN;
}

/**
 * @brief Convert a TextDirection value to the corresponding HarfBuzz direction.
 *
 * Maps TextDirection::RTL to HB_DIRECTION_RTL and TextDirection::LTR to HB_DIRECTION_LTR.
 * For other values (e.g., AUTO) returns HB_DIRECTION_LTR so script-based detection may occur later.
 *
 * @param d The input text direction.
 * @return hb_direction_t The HarfBuzz direction constant corresponding to `d`.
 */
static hb_direction_t toHbDir(TextDirection d) {
  switch (d) {
    case TextDirection::RTL: return HB_DIRECTION_RTL;
    case TextDirection::LTR: return HB_DIRECTION_LTR;
    default: return HB_DIRECTION_LTR; // AUTO -> detect from script
  }
}

/**
 * @brief Reorders a sequence of Unicode codepoints from logical to visual order using FriBidi.
 *
 * Reorders input codepoints for visual display according to the Unicode Bidirectional Algorithm
 * with the given paragraph base direction. Also returns the resolved per-codepoint embedding
 * levels via the outLevels parameter.
 *
 * @param logical Unicode codepoints in logical (storage) order.
 * @param baseDir Paragraph base direction used to resolve embedding levels.
 * @param outLevels Output vector that will be resized and filled with the resolved embedding
 *                  level for each codepoint (one entry per input codepoint).
 * @return std::vector<uint32_t> Codepoints in visual order. Returns an empty vector if `logical`
 *                              is empty. If the computed maximum embedding level is 0 (no
 *                              reordering required), the original `logical` sequence is returned.
 */
static std::vector<uint32_t> applyBidiReordering(const std::vector<uint32_t>& logical,
                                                  TextDirection baseDir,
                                                  std::vector<int8_t>& outLevels) {
  if (logical.empty()) return {};
  
  size_t len = logical.size();
  std::vector<FriBidiChar> input(logical.begin(), logical.end());
  std::vector<FriBidiChar> visual(len);
  std::vector<FriBidiCharType> bidiTypes(len);
  std::vector<FriBidiLevel> levels(len);
  
  // Get character types
  fribidi_get_bidi_types(input.data(), len, bidiTypes.data());
  
  // Determine base direction
  FriBidiParType parType = (baseDir == TextDirection::RTL) 
    ? FRIBIDI_PAR_RTL 
    : ((baseDir == TextDirection::AUTO) ? FRIBIDI_PAR_ON : FRIBIDI_PAR_LTR);
  
  // Get embedding levels
  FriBidiLevel maxLevel = fribidi_get_par_embedding_levels(
    bidiTypes.data(), len, &parType, levels.data());
  
  if (maxLevel == 0) {
    // No reordering needed
    return logical;
  }
  
  // Copy for reordering
  std::copy(input.begin(), input.end(), visual.begin());
  
  // Reorder line
  fribidi_reorder_line(0, bidiTypes.data(), len, 0, parType, 
                        levels.data(), visual.data(), nullptr);
  
  // Store levels for potential use (e.g., cursor positioning)
  outLevels.resize(len);
  for (size_t i = 0; i < len; ++i) {
    outLevels[i] = static_cast<int8_t>(levels[i]);
  }
  
  return std::vector<uint32_t>(visual.begin(), visual.end());
}

/**
 * @brief Shapes a UTF-32 string into positioned glyphs using HarfBuzz and applies FriBidi reordering for bidirectional text.
 *
 * Applies bidirectional reordering to the input logical codepoints, shapes the resulting visual sequence with the
 * provided HarfBuzz font, and returns glyph indices with per-glyph positions and advances.
 *
 * @param text32 Input text as a UTF-32 string of Unicode codepoints.
 * @param hbFont HarfBuzz font to use for shaping; if `nullptr` an empty vector is returned.
 * @param params Shaping parameters (direction, script, language) that influence buffer settings and shaping.
 * @return std::vector<ShapedGlyph> A vector of shaped glyphs. Each element contains the glyph index produced by
 * HarfBuzz, a `codepoint` derived from the glyph's cluster (mapped back into the visual-ordered input for fallback lookup,
 * or 0 if out of range), and x/y positions and advance values in device units (floats). Returns an empty vector if
 * `hbFont` is null or `text32` is empty.
 */
std::vector<ShapedGlyph> TextShaper::shape(const std::u32string& text32,
                                           hb_font_t* hbFont,
                                           const ShapeParams& params) {
  std::vector<ShapedGlyph> out;
  if (!hbFont || text32.empty()) return out;

  const bool allowCache = text32.size() <= kShapeCacheMaxLength;
  ShapeCacheKey cacheKey;
  if (allowCache) {
    cacheKey.font = hbFont;
    cacheKey.text = text32;
    cacheKey.direction = params.direction;
    cacheKey.script = params.script;
    cacheKey.language = params.language;

    std::lock_guard cacheLock(g_shapeCacheMutex);
    if (const auto it = g_shapeCache.find(cacheKey); it != g_shapeCache.end()) {
      it->second.tick = ++g_shapeCacheTick;
      return it->second.glyphs;
    }
  }

  // Convert to codepoints
  std::vector<uint32_t> codepoints(text32.begin(), text32.end());
  
  // Apply FriBidi reordering for proper visual display of bidirectional text
  std::vector<int8_t> bidiLevels;
  std::vector<uint32_t> visualOrder = applyBidiReordering(codepoints, params.direction, bidiLevels);

  hb_buffer_t* buf = hb_buffer_create();

  // Add codepoints in visual order
  hb_buffer_add_codepoints(buf, visualOrder.data(), (int)visualOrder.size(), 0, (int)visualOrder.size());

  hb_buffer_set_script(buf, toHbScript(params.script));
  hb_buffer_set_direction(buf, toHbDir(params.direction));
  hb_buffer_set_language(buf, hb_language_from_string(params.language.c_str(), -1));

  // Apply shaping (ligatures, kerning, glyph substitution)
  hb_shape(hbFont, buf, nullptr, 0);

  unsigned int glyphCount = 0;
  hb_glyph_info_t* info = hb_buffer_get_glyph_infos(buf, &glyphCount);
  hb_glyph_position_t* pos = hb_buffer_get_glyph_positions(buf, &glyphCount);

  out.reserve(glyphCount);
  for (unsigned int i = 0; i < glyphCount; ++i) {
    ShapedGlyph g;
    g.glyphIndex = info[i].codepoint; // After shaping, this is the glyph index
    // Use cluster to map back to original codepoint for fallback font lookup
    const unsigned int cluster = info[i].cluster;
    g.codepoint = (cluster < visualOrder.size()) ? static_cast<char32_t>(visualOrder[cluster]) : 0;
    // IMPORTANT: x/y are per-glyph offsets; the caller maintains the pen cursor using advanceX/advanceY.
    // Returning absolute positions here would double-apply advances in TTFFont::buildQuads.
    g.x = (pos[i].x_offset / 64.0f);
    g.y = -(pos[i].y_offset / 64.0f);
    g.advanceX = pos[i].x_advance / 64.0f;
    g.advanceY = pos[i].y_advance / 64.0f;
    out.push_back(g);
  }

  hb_buffer_destroy(buf);

  if (allowCache && !out.empty()) {
    std::lock_guard cacheLock(g_shapeCacheMutex);
    const size_t tick = ++g_shapeCacheTick;
    g_shapeCache.insert_or_assign(cacheKey, ShapeCacheEntry { out, tick });
    if (g_shapeCache.size() > kShapeCacheMaxEntries) {
      auto victim = std::min_element(g_shapeCache.begin(), g_shapeCache.end(),
        [](const auto &lhs, const auto &rhs) { return lhs.second.tick < rhs.second.tick; });
      if (victim != g_shapeCache.end()) {
        g_shapeCache.erase(victim);
      }
    }
  }
  return out;
}
