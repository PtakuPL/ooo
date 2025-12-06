#include "TextShaper.h"
#include <stdexcept>
#include <algorithm>

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

static hb_direction_t toHbDir(TextDirection d) {
  switch (d) {
    case TextDirection::RTL: return HB_DIRECTION_RTL;
    case TextDirection::LTR: return HB_DIRECTION_LTR;
    default: return HB_DIRECTION_LTR; // AUTO -> detect from script
  }
}

// Apply FriBidi algorithm for proper visual ordering of bidirectional text
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

std::vector<ShapedGlyph> TextShaper::shape(const std::u32string& text32,
                                           hb_font_t* hbFont,
                                           const ShapeParams& params) {
  std::vector<ShapedGlyph> out;
  if (!hbFont || text32.empty()) return out;

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
  float x = 0.0f, y = 0.0f;

  for (unsigned int i = 0; i < glyphCount; ++i) {
    ShapedGlyph g;
    g.glyphIndex = info[i].codepoint; // After shaping, this is the glyph index
    // Use cluster to map back to original codepoint for fallback font lookup
    const unsigned int cluster = info[i].cluster;
    g.codepoint = (cluster < visualOrder.size()) ? static_cast<char32_t>(visualOrder[cluster]) : 0;
    g.x = x + (pos[i].x_offset / 64.0f);
    g.y = y - (pos[i].y_offset / 64.0f);
    g.advanceX = pos[i].x_advance / 64.0f;
    g.advanceY = pos[i].y_advance / 64.0f;
    x += g.advanceX;
    y += g.advanceY;
    out.push_back(g);
  }

  hb_buffer_destroy(buf);
  return out;
}