/*
 * Copyright (c) 2010-2025 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "bitmapfont.h"
#include "graphics.h"
#include "image.h"
#include "texturemanager.h"
#include "textureatlas.h"

#include <framework/otml/otml.h>

#include "drawpoolmanager.h"
#include <framework/text/TextShaper.h>
#include <framework/text/Utf8.h>
#include <framework/text/LocaleShaping.h>
#include <framework/core/logger.h>

#include <fmt/format.h>
#include <algorithm>
#include <map>
#include <string>
#include <vector>


static thread_local std::vector<Point> s_glyphsPositions(1);
static thread_local std::vector<int> s_lineWidths(1);


void BitmapFont::load(const OTMLNodePtr& fontNode)
{
    // === TTF path (handled before bitmap parsing) ===
const std::string type = fontNode->valueAt<std::string>("type", "");
if(type == "ttf") {
    try {
        m_isTTF = true;

        // Required fields - use get() with null check instead of at() which throws
        const auto srcNode = fontNode->get("source");
        if (!srcNode) {
            g_logger.error("TTF: missing 'source' field in font definition");
            m_isTTF = false;
            return;
        }
        
        const std::string src = srcNode->value();
        g_logger.info(fmt::format("TTF: loading font source='{}'", src));
        
        // Use the path directly - it should be an absolute virtual path starting with /
        std::string mainPath = src;
        if (src.empty() || src.front() != '/') {
            // Relative path - resolve from source file location
            const std::string srcSource = srcNode->source();
            mainPath = stdext::resolve_path(src, srcSource);
        }
        g_logger.info(fmt::format("TTF: resolved mainPath='{}'", mainPath));
        
        const int size = fontNode->valueAt<int>("size", 12);
        g_logger.info(fmt::format("TTF: size={}", size));

        // Optional fallback: array of paths
        std::vector<std::string> fbPaths;
        if (const auto fb = fontNode->get("fallback")) {
            for (const auto& child : fb->children()) {
                const std::string fbVal = child->value<std::string>();
                if (!fbVal.empty()) {
                    if (!fbVal.empty() && fbVal.front() == '/') {
                        fbPaths.emplace_back(fbVal);
                    } else {
                        fbPaths.emplace_back(stdext::resolve_path(fbVal, child->source()));
                    }
                }
            }
            g_logger.info(fmt::format("TTF: {} fallback fonts configured", fbPaths.size()));
        }

        m_ttf = std::make_shared<TTFFont>();
        if (!m_ttf->load(mainPath, fbPaths, size)) {
            g_logger.error(fmt::format("TTF: load() returned false for '{}'", src));
            m_ttf.reset();
            m_isTTF = false;
            return;  // Don't throw - just fail gracefully
        }

        // for layout purposes
        m_glyphHeight = size;
        m_yOffset = fontNode->valueAt("y-offset", 0);
        g_logger.info(fmt::format("TTF: font '{}' loaded successfully", src));
        return; // skip bitmap path
        
    } catch (const std::exception& e) {
        g_logger.error(fmt::format("TTF: exception while loading: {}", e.what()));
        m_ttf.reset();
        m_isTTF = false;
        return;
    } catch (...) {
        g_logger.error("TTF: unknown exception while loading");
        m_ttf.reset();
        m_isTTF = false;
        return;
    }
}
// === end TTF path ===
const auto& textureNode = fontNode->at("texture");
    const auto& textureFile = stdext::resolve_path(textureNode->value(), textureNode->source());
    const auto& glyphSize = fontNode->valueAt<Size>("glyph-size");
    const int spaceWidth = fontNode->valueAt("space-width", glyphSize.width());

    m_glyphHeight = fontNode->valueAt<int>("height");
    m_yOffset = fontNode->valueAt("y-offset", 0);
    m_firstGlyph = fontNode->valueAt("first-glyph", 32);
    m_glyphSpacing = fontNode->valueAt("spacing", Size(0));

    // load font texture
    m_texture = g_textures.getTexture(textureFile, false);
    if (!m_texture)
        return;
    m_texture->create();

    const Size textureSize = m_texture->getSize();

    if (const auto& node = fontNode->get("fixed-glyph-width")) {
        for (int glyph = m_firstGlyph; glyph < 256; ++glyph)
            m_glyphsSize[glyph] = Size(node->value<int>(), m_glyphHeight);
    } else {
        calculateGlyphsWidthsAutomatically(Image::load(textureFile), glyphSize);
    }

    // 32 and 160 are spaces (&nbsp;)
    m_glyphsSize[32].setWidth(spaceWidth);
    m_glyphsSize[160].setWidth(spaceWidth);

    // use 127 as spacer [Width: 1], Important for the current NPC highlighting system
    m_glyphsSize[127].setWidth(1);

    // new line actually has a size that will be useful in multiline algorithm
    m_glyphsSize[static_cast<uint8_t>('\n')] = { 1, m_glyphHeight };

    // read custom widths
    /*
    if(const auto& node = fontNode->get("glyph-widths")) {
            for(const OTMLNodePtr& child : node->children())
                    m_glyphsSize[stdext::safe_cast<int>(child->tag())].setWidth(child->value<int>());
    }
    */

    // calculate glyphs texture coords
    const int numHorizontalGlyphs = textureSize.width() / glyphSize.width();
    for (int glyph = m_firstGlyph; glyph < 256; ++glyph) {
        m_glyphsTextureCoords[glyph].setRect(((glyph - m_firstGlyph) % numHorizontalGlyphs) * glyphSize.width(),
                                             ((glyph - m_firstGlyph) / numHorizontalGlyphs) * glyphSize.height(),
                                             m_glyphsSize[glyph].width(),
                                             m_glyphHeight);
    }
}

void BitmapFont::drawText(const std::string_view text, const Point& startPos, const Color& color)
{
    const Size boxSize = g_painter->getResolution() - startPos.toSize();
    const Rect screenCoords(startPos, boxSize);
    drawText(text, screenCoords, color, Fw::AlignTopLeft);
}

/**
 * @brief Renders the given text inside the specified screen rectangle using the font's current backend.
 *
 * Renders text into the engine's draw pool clipped to and aligned within screenCoords. If the font is a TTF font
 * this function performs shaping and measures the text, computes the baseline according to the requested alignment,
 * and delegates rendering to the TTF renderer (using the provided color). For bitmap fonts it computes per-glyph
 * positions and emits textured quads using the font texture.
 *
 * @param text The UTF-8 text to render.
 * @param screenCoords Destination rectangle on screen where the text should be placed and aligned.
 * @param color Color to use for rendering the text.
 * @param align Alignment flags that control horizontal and vertical alignment inside screenCoords.
 */
void BitmapFont::drawText(const std::string_view text, const Rect& screenCoords, const Color& color, const Fw::AlignmentFlag align)
{
if (m_isTTF && m_ttf) {
    static bool s_loggedTtfPathOnce = false;
    if (!s_loggedTtfPathOnce) {
        g_logger.info("BitmapFont::drawText: using TTF path (first time). rect=({},{} {}x{})", 
                      screenCoords.left(), screenCoords.top(), screenCoords.width(), screenCoords.height());
        s_loggedTtfPathOnce = true;
    }
    const auto text32 = otc::text::utf8ToU32(text);
    const auto sp = otc::text::LocaleShaping::paramsFromUtf8(text, otc::text::LocaleShaping::getDefaultLocaleTag());
    const int ascentPx = std::max(0, m_ttf->ascent());
    const int descentPx = std::max(0, m_ttf->descent());
    const int lineHeightPx = std::max({ m_ttf->lineHeight(), m_glyphHeight, ascentPx + descentPx });

    // Split text into lines by '\n' for multi-line support
    std::vector<std::u32string> lines;
    {
        std::u32string currentLine;
        for (const char32_t cp : text32) {
            if (cp == U'\n') {
                lines.push_back(currentLine);
                currentLine.clear();
            } else {
                currentLine += cp;
            }
        }
        lines.push_back(currentLine); // last (or only) line
    }

    const int lineCount = static_cast<int>(lines.size());
    const float totalHeight = static_cast<float>(lineHeightPx * lineCount);

    // Calculate starting baseline Y based on vertical alignment
    float startY = static_cast<float>(screenCoords.top()) + static_cast<float>(ascentPx);
    if (align & Fw::AlignBottom) {
        startY = static_cast<float>(screenCoords.bottom()) - totalHeight + static_cast<float>(ascentPx);
    } else if (align & Fw::AlignVerticalCenter) {
        startY = static_cast<float>(screenCoords.top()) + (screenCoords.height() - totalHeight) * 0.5f + static_cast<float>(ascentPx);
    }

    // Render each line
    for (int lineIdx = 0; lineIdx < lineCount; ++lineIdx) {
        const auto& line = lines[lineIdx];
        if (line.empty()) {
            continue; // skip empty lines (just advance Y)
        }

        const float lineWidth = m_ttf->measureTextWidth(line, sp);
        float bx = static_cast<float>(screenCoords.left());

        // Horizontal alignment per line
        if (align & Fw::AlignRight) {
            bx = static_cast<float>(screenCoords.right()) - lineWidth;
        } else if (align & Fw::AlignHorizontalCenter) {
            bx = static_cast<float>(screenCoords.left()) + (screenCoords.width() - lineWidth) * 0.5f;
        }

        const float by = startY + static_cast<float>(lineIdx * lineHeightPx);
        m_ttf->drawText(line, bx, by, sp, color);
    }
    return;
}

    Size textBoxSize;
    calculateGlyphsPositions(text, align, s_glyphsPositions, &textBoxSize);
    for (const auto& [dest, src] : getDrawTextCoords(text, textBoxSize, align, screenCoords, s_glyphsPositions)) {
        g_drawPool.addTexturedRect(dest, m_texture, src, color);
    }
}

/**
 * @brief Renders colored text with TTF support (positions are converted from byte to codepoint for TTF).
 */
void BitmapFont::drawColoredText(const std::string_view text, const Rect& screenCoords,
    const std::vector<std::pair<int, Color>>& textColors, const Color& defaultColor, const Fw::AlignmentFlag align)
{
    if (text.empty())
        return;

    if (m_isTTF && m_ttf) {
        // Convert byte positions to codepoint positions for TTF
        const auto text32 = otc::text::utf8ToU32(text);
        const auto sp = otc::text::LocaleShaping::paramsFromUtf8(text, otc::text::LocaleShaping::getDefaultLocaleTag());
        
        // Build byte-to-codepoint position map
        std::vector<size_t> byteToCodepoint;
        byteToCodepoint.reserve(text.size() + 1);
        size_t cpIdx = 0;
        for (size_t i = 0; i < text.size(); ) {
            byteToCodepoint.push_back(cpIdx);
            // Skip UTF-8 continuation bytes
            const uint8_t c = static_cast<uint8_t>(text[i]);
            if ((c & 0x80) == 0) i += 1;
            else if ((c & 0xE0) == 0xC0) i += 2;
            else if ((c & 0xF0) == 0xE0) i += 3;
            else if ((c & 0xF8) == 0xF0) i += 4;
            else i += 1; // invalid, advance 1
            ++cpIdx;
        }
        byteToCodepoint.push_back(cpIdx); // sentinel at end
        
        // Convert textColors from byte positions to codepoint positions
        std::vector<std::pair<size_t, Color>> cpColors;
        cpColors.reserve(textColors.size());
        for (const auto& [bytePos, color] : textColors) {
            const size_t safePos = std::min(static_cast<size_t>(bytePos), byteToCodepoint.size() - 1);
            cpColors.emplace_back(byteToCodepoint[safePos], color);
        }
        
        // Calculate total width for alignment
        const float totalWidth = m_ttf->measureTextWidth(text32, sp);
        const int ascentPx = std::max(0, m_ttf->ascent());
        const int descentPx = std::max(0, m_ttf->descent());
        const int lineHeightPx = std::max({ m_ttf->lineHeight(), m_glyphHeight, ascentPx + descentPx });
        const float h = static_cast<float>(lineHeightPx);
        
        // Calculate baseline position
        float baseX = static_cast<float>(screenCoords.left());
        float baseY = static_cast<float>(screenCoords.top()) + static_cast<float>(ascentPx);
        
        // Vertical align
        if (align & Fw::AlignBottom) {
            baseY = static_cast<float>(screenCoords.bottom()) - static_cast<float>(descentPx);
        } else if (align & Fw::AlignVerticalCenter) {
            baseY = static_cast<float>(screenCoords.top()) + (screenCoords.height() - h) * 0.5f + static_cast<float>(ascentPx);
        }
        
        // Horizontal align
        if (align & Fw::AlignRight) {
            baseX = static_cast<float>(screenCoords.right()) - totalWidth;
        } else if (align & Fw::AlignHorizontalCenter) {
            baseX = static_cast<float>(screenCoords.left()) + (screenCoords.width() - totalWidth) * 0.5f;
        }
        
        // Render each color segment
        float penX = baseX;
        size_t segmentStart = 0;
        Color currentColor = defaultColor;
        
        // Sort colors by position
        auto sortedColors = cpColors;
        std::sort(sortedColors.begin(), sortedColors.end(), [](const auto& a, const auto& b) {
            return a.first < b.first;
        });
        
        for (size_t ci = 0; ci <= sortedColors.size(); ++ci) {
            const size_t segmentEnd = (ci < sortedColors.size()) ? sortedColors[ci].first : text32.size();
            
            if (segmentEnd > segmentStart) {
                const auto segment = text32.substr(segmentStart, segmentEnd - segmentStart);
                m_ttf->drawText(segment, penX, baseY, sp, currentColor);
                penX += m_ttf->measureTextWidth(segment, sp);
            }
            
            if (ci < sortedColors.size()) {
                currentColor = sortedColors[ci].second;
                segmentStart = sortedColors[ci].first;
            }
        }
        return;
    }
    
    // Bitmap font path - just use the existing fillTextColorCoords
    Size textBoxSize;
    calculateGlyphsPositions(text, align, s_glyphsPositions, &textBoxSize);
    for (const auto& [dest, src] : getDrawTextCoords(text, textBoxSize, align, screenCoords, s_glyphsPositions)) {
        // This is a simplified fallback; proper colored bitmap path uses fillTextColorCoords
        g_drawPool.addTexturedRect(dest, m_texture, src, defaultColor);
    }
}

std::vector<std::pair<Rect, Rect>> BitmapFont::getDrawTextCoords(const std::string_view text, const Size& textBoxSize, const Fw::AlignmentFlag align, const Rect& screenCoords, const std::vector<Point>& glyphsPositions) const
{
    std::vector<std::pair<Rect, Rect>> list;
    // prevent glitches from invalid rects
    if (!screenCoords.isValid() || !m_texture)
        return list;

    const int textLength = text.length();

    for (int i = 0; i < textLength; ++i) {
        const int glyph = static_cast<uint8_t>(text[i]);

        // skip invalid glyphs
        if (glyph < 32)
            continue;

        // calculate initial glyph rect and texture coords
        Rect glyphScreenCoords(glyphsPositions[i], m_glyphsSize[glyph]);
        Rect glyphTextureCoords = m_glyphsTextureCoords[glyph];

        // first translate to align position
        if (align & Fw::AlignBottom) {
            glyphScreenCoords.translate(0, screenCoords.height() - textBoxSize.height());
        } else if (align & Fw::AlignVerticalCenter) {
            glyphScreenCoords.translate(0, (screenCoords.height() - textBoxSize.height()) / 2);
        } else { // AlignTop
            // nothing to do
        }

        if (align & Fw::AlignRight) {
            glyphScreenCoords.translate(screenCoords.width() - textBoxSize.width(), 0);
        } else if (align & Fw::AlignHorizontalCenter) {
            glyphScreenCoords.translate((screenCoords.width() - textBoxSize.width()) / 2, 0);
        } else { // AlignLeft
            // nothing to do
        }

        // only render glyphs that are after 0, 0
        if (glyphScreenCoords.bottom() < 0 || glyphScreenCoords.right() < 0)
            continue;

        // bound glyph topLeft to 0,0 if needed
        if (glyphScreenCoords.top() < 0) {
            glyphTextureCoords.setTop(glyphTextureCoords.top() - glyphScreenCoords.top());
            glyphScreenCoords.setTop(0);
        }
        if (glyphScreenCoords.left() < 0) {
            glyphTextureCoords.setLeft(glyphTextureCoords.left() - glyphScreenCoords.left());
            glyphScreenCoords.setLeft(0);
        }

        // translate rect to screen coords
        glyphScreenCoords.translate(screenCoords.topLeft());

        // only render if glyph rect is visible on screenCoords
        if (!screenCoords.intersects(glyphScreenCoords))
            continue;

        // bound glyph bottomRight to screenCoords bottomRight
        if (glyphScreenCoords.bottom() > screenCoords.bottom()) {
            glyphTextureCoords.setBottom(glyphTextureCoords.bottom() + (screenCoords.bottom() - glyphScreenCoords.bottom()));
            glyphScreenCoords.setBottom(screenCoords.bottom());
        }
        if (glyphScreenCoords.right() > screenCoords.right()) {
            glyphTextureCoords.setRight(glyphTextureCoords.right() + (screenCoords.right() - glyphScreenCoords.right()));
            glyphScreenCoords.setRight(screenCoords.right());
        }

        // add glyph
        list.emplace_back(glyphScreenCoords, glyphTextureCoords);
    }

    return list;
}

void BitmapFont::fillTextCoords(const CoordsBufferPtr& coords, const std::string_view text,
                                const Size& textBoxSize, const Fw::AlignmentFlag align, const Rect& screenCoords,
                                const std::vector<Point>& glyphsPositions) const
{
    coords->clear();

    // prevent glitches from invalid rects
    if (!screenCoords.isValid() || !m_texture)
        return;

    const int textLength = text.length();

    for (int i = 0; i < textLength; ++i) {
        const int glyph = static_cast<uint8_t>(text[i]);

        // skip invalid glyphs
        if (glyph < 32)
            continue;

        // calculate initial glyph rect and texture coords
        Rect glyphScreenCoords(glyphsPositions[i], m_glyphsSize[glyph]);
        Rect glyphTextureCoords = m_glyphsTextureCoords[glyph];

        // first translate to align position
        if (align & Fw::AlignBottom) {
            glyphScreenCoords.translate(0, screenCoords.height() - textBoxSize.height());
        } else if (align & Fw::AlignVerticalCenter) {
            glyphScreenCoords.translate(0, (screenCoords.height() - textBoxSize.height()) / 2);
        } else { // AlignTop
            // nothing to do
        }

        if (align & Fw::AlignRight) {
            glyphScreenCoords.translate(screenCoords.width() - textBoxSize.width(), 0);
        } else if (align & Fw::AlignHorizontalCenter) {
            glyphScreenCoords.translate((screenCoords.width() - textBoxSize.width()) / 2, 0);
        } else { // AlignLeft
            // nothing to do
        }

        // only render glyphs that are after 0, 0
        if (glyphScreenCoords.bottom() < 0 || glyphScreenCoords.right() < 0)
            continue;

        // bound glyph topLeft to 0,0 if needed
        if (glyphScreenCoords.top() < 0) {
            glyphTextureCoords.setTop(glyphTextureCoords.top() - glyphScreenCoords.top());
            glyphScreenCoords.setTop(0);
        }
        if (glyphScreenCoords.left() < 0) {
            glyphTextureCoords.setLeft(glyphTextureCoords.left() - glyphScreenCoords.left());
            glyphScreenCoords.setLeft(0);
        }

        // translate rect to screen coords
        glyphScreenCoords.translate(screenCoords.topLeft());

        // only render if glyph rect is visible on screenCoords
        if (!screenCoords.intersects(glyphScreenCoords))
            continue;

        // bound glyph bottomRight to screenCoords bottomRight
        if (glyphScreenCoords.bottom() > screenCoords.bottom()) {
            glyphTextureCoords.setBottom(glyphTextureCoords.bottom() + (screenCoords.bottom() - glyphScreenCoords.bottom()));
            glyphScreenCoords.setBottom(screenCoords.bottom());
        }
        if (glyphScreenCoords.right() > screenCoords.right()) {
            glyphTextureCoords.setRight(glyphTextureCoords.right() + (screenCoords.right() - glyphScreenCoords.right()));
            glyphScreenCoords.setRight(screenCoords.right());
        }

        if (const auto region = m_texture->getAtlasRegion())
            glyphTextureCoords.translate(region->x, region->y);

        // add glyph
        coords->addRect(glyphScreenCoords, glyphTextureCoords);
    }
}

void BitmapFont::fillTextColorCoords(std::vector<std::pair<Color, CoordsBufferPtr>>& colorCoords, const std::string_view text,
                        const std::vector<std::pair<int, Color>> textColors,
                        const Size& textBoxSize, const Fw::AlignmentFlag align,
                        const Rect& screenCoords, const std::vector<Point>& glyphsPositions) const
{
    colorCoords.clear();

    // prevent glitches from invalid rects
    if (!screenCoords.isValid() || !m_texture)
        return;

    const int textLength = text.length();
    const int textColorsSize = textColors.size();

    std::map<uint32_t, CoordsBufferPtr> colorCoordsMap;
    uint32_t curColorRgba;
    int32_t nextColorIndex = 0;
    int32_t colorIndex = -1;
    CoordsBufferPtr coords;
    for (int i = 0; i < textLength; ++i) {
        if (i >= nextColorIndex) {
            colorIndex = colorIndex + 1;
            if (colorIndex < textColorsSize) {
                curColorRgba = textColors[colorIndex].second.rgba();
            }
            if (colorIndex + 1 < textColorsSize) {
                nextColorIndex = textColors[colorIndex + 1].first;
            } else {
                nextColorIndex = textLength;
            }

            if (colorCoordsMap.find(curColorRgba) == colorCoordsMap.end()) {
                colorCoordsMap.insert(std::make_pair(curColorRgba, std::make_shared<CoordsBuffer>()));
            }

            coords = colorCoordsMap[curColorRgba];
        }

        const int glyph = static_cast<uint8_t>(text[i]);

        // skip invalid glyphs
        if (glyph < 32)
            continue;

        // calculate initial glyph rect and texture coords
        Rect glyphScreenCoords(glyphsPositions[i], m_glyphsSize[glyph]);
        Rect glyphTextureCoords = m_glyphsTextureCoords[glyph];

        // first translate to align position
        if (align & Fw::AlignBottom) {
            glyphScreenCoords.translate(0, screenCoords.height() - textBoxSize.height());
        } else if (align & Fw::AlignVerticalCenter) {
            glyphScreenCoords.translate(0, (screenCoords.height() - textBoxSize.height()) / 2);
        } else { // AlignTop
            // nothing to do
        }

        if (align & Fw::AlignRight) {
            glyphScreenCoords.translate(screenCoords.width() - textBoxSize.width(), 0);
        } else if (align & Fw::AlignHorizontalCenter) {
            glyphScreenCoords.translate((screenCoords.width() - textBoxSize.width()) / 2, 0);
        } else { // AlignLeft
            // nothing to do
        }

        // only render glyphs that are after 0, 0
        if (glyphScreenCoords.bottom() < 0 || glyphScreenCoords.right() < 0)
            continue;

        // bound glyph topLeft to 0,0 if needed
        if (glyphScreenCoords.top() < 0) {
            glyphTextureCoords.setTop(glyphTextureCoords.top() - glyphScreenCoords.top());
            glyphScreenCoords.setTop(0);
        }
        if (glyphScreenCoords.left() < 0) {
            glyphTextureCoords.setLeft(glyphTextureCoords.left() - glyphScreenCoords.left());
            glyphScreenCoords.setLeft(0);
        }

        // translate rect to screen coords
        glyphScreenCoords.translate(screenCoords.topLeft());

        // only render if glyph rect is visible on screenCoords
        if (!screenCoords.intersects(glyphScreenCoords))
            continue;

        // bound glyph bottomRight to screenCoords bottomRight
        if (glyphScreenCoords.bottom() > screenCoords.bottom()) {
            glyphTextureCoords.setBottom(glyphTextureCoords.bottom() + (screenCoords.bottom() - glyphScreenCoords.bottom()));
            glyphScreenCoords.setBottom(screenCoords.bottom());
        }
        if (glyphScreenCoords.right() > screenCoords.right()) {
            glyphTextureCoords.setRight(glyphTextureCoords.right() + (screenCoords.right() - glyphScreenCoords.right()));
            glyphScreenCoords.setRight(screenCoords.right());
        }

        if (const auto region = m_texture->getAtlasRegion())
            glyphTextureCoords.translate(region->x, region->y);

        // add glyph to color
        coords->addRect(glyphScreenCoords, glyphTextureCoords);
    }

    for (auto& [rgba, crds] : colorCoordsMap) {
        colorCoords.emplace_back(Color(rgba), crds);
    }
}

void BitmapFont::calculateGlyphsPositions(const std::string_view text, const Fw::AlignmentFlag align, std::vector<Point>& glyphsPositions, Size* textBoxSize) const
{
    const int textLength = text.length();
    int maxLineWidth = 0;
    int lines = 0;
    int glyph;

    // return if there is no text
    if (textLength == 0) {
        if (textBoxSize)
            textBoxSize->resize(0, m_glyphHeight);
    }

    // resize s_glyphsPositions vector when needed
    if (textLength > static_cast<int>(glyphsPositions.size()))
        glyphsPositions.resize(textLength);

    // calculate lines width
    if ((align & Fw::AlignRight || align & Fw::AlignHorizontalCenter) || textBoxSize) {
        s_lineWidths[0] = 0;
        for (int i = 0; i < textLength; ++i) {
            glyph = static_cast<uint8_t>(text[i]);

            if (glyph == static_cast<uint8_t>('\n')) {
                ++lines;
                // resize s_lineWidths vector when needed
                if (lines + 1 > static_cast<int>(s_lineWidths.size()))
                    s_lineWidths.resize(lines + 1);
                s_lineWidths[lines] = 0;
            } else if (glyph >= 32) {
                s_lineWidths[lines] += m_glyphsSize[glyph].width();
                // only add space if letter is not the last or before a \n
                if ((i + 1 != textLength && text[i + 1] != '\n'))
                    s_lineWidths[lines] += m_glyphSpacing.width();
                maxLineWidth = std::max<int>(maxLineWidth, s_lineWidths[lines]);
            }
        }
    }

    Point virtualPos(0, m_yOffset);

    lines = 0;
    for (int i = 0; i < textLength; ++i) {
        glyph = static_cast<uint8_t>(text[i]);

        // new line or first glyph
        if (glyph == static_cast<uint8_t>('\n') || i == 0) {
            if (glyph == static_cast<uint8_t>('\n')) {
                virtualPos.y += m_glyphHeight + m_glyphSpacing.height();
                ++lines;
            }

            // calculate start x pos
            if (align & Fw::AlignRight) {
                virtualPos.x = (maxLineWidth - s_lineWidths[lines]);
            } else if (align & Fw::AlignHorizontalCenter) {
                virtualPos.x = (maxLineWidth - s_lineWidths[lines]) / 2;
            } else { // AlignLeft
                virtualPos.x = 0;
            }
        }

        // store current glyph topLeft
        glyphsPositions[i] = virtualPos;

        // render only if the glyph is valid
        if (glyph >= 32 && glyph != static_cast<uint8_t>('\n')) {
            virtualPos.x += m_glyphsSize[glyph].width() + m_glyphSpacing.width();
        }
    }

    if (textBoxSize) {
        textBoxSize->setWidth(maxLineWidth);
        textBoxSize->setHeight(virtualPos.y + m_glyphHeight);
    }
}

Size BitmapFont::calculateTextRectSize(const std::string_view text)
{
    if (m_isTTF && m_ttf) {
        const auto text32 = otc::text::utf8ToU32(text);
        const auto sp = otc::text::LocaleShaping::paramsFromUtf8(text, otc::text::LocaleShaping::getDefaultLocaleTag());
        
        // Handle multiline text: split by \n and calculate max width + total height
        int maxWidth = 0;
        int lineCount = 0;
        std::u32string currentLine;
        
        for (const char32_t cp : text32) {
            if (cp == U'\n') {
                // Measure current line
                if (!currentLine.empty()) {
                    const int lineWidth = static_cast<int>(std::lround(m_ttf->measureTextWidth(currentLine, sp)));
                    maxWidth = std::max(maxWidth, lineWidth);
                }
                currentLine.clear();
                ++lineCount;
            } else {
                currentLine += cp;
            }
        }
        
        // Measure last line (or only line if no newlines)
        if (!currentLine.empty()) {
            const int lineWidth = static_cast<int>(std::lround(m_ttf->measureTextWidth(currentLine, sp)));
            maxWidth = std::max(maxWidth, lineWidth);
        }
        ++lineCount; // Count last line
        
        // Handle empty text edge case
        if (lineCount == 0) lineCount = 1;
        if (maxWidth == 0 && !text32.empty()) {
            // Single line without newlines
            maxWidth = static_cast<int>(std::lround(m_ttf->measureTextWidth(text32, sp)));
        }

        const int lh = std::max(m_ttf->lineHeight(), m_glyphHeight);
        return Size(maxWidth, lh * lineCount);
    }

    Size size;
    calculateGlyphsPositions(text, Fw::AlignTopLeft, s_glyphsPositions, &size);
    return size;
}

void BitmapFont::calculateGlyphsWidthsAutomatically(const ImagePtr& image, const Size& glyphSize)
{
    if (!image)
        return;

    const auto& imageSize = image->getSize();
    const auto& texturePixels = image->getPixels();
    const int numHorizontalGlyphs = imageSize.width() / glyphSize.width();

    // small AI to auto calculate pixels widths
    for (int glyph = m_firstGlyph; glyph < 256; ++glyph) {
        Rect glyphCoords(((glyph - m_firstGlyph) % numHorizontalGlyphs) * glyphSize.width(),
                         ((glyph - m_firstGlyph) / numHorizontalGlyphs) * glyphSize.height(),
                         glyphSize.width(),
                         m_glyphHeight);
        int width = glyphSize.width();
        for (int x = glyphCoords.left(); x <= glyphCoords.right(); ++x) {
            int filledPixels = 0;
            // check if all vertical pixels are alpha
            for (int y = glyphCoords.top(); y <= glyphCoords.bottom(); ++y) {
                if (texturePixels[(y * imageSize.width() * 4) + (x * 4) + 3] != 0)
                    ++filledPixels;
            }
            if (filledPixels > 0)
                width = x - glyphCoords.left() + 1;
        }
        // store glyph size
        m_glyphsSize[glyph].resize(width, m_glyphHeight);
    }
}

std::string BitmapFont::wrapText(const std::string_view text, const int maxWidth, std::vector<std::pair<int, Color>>* colors)
{
    if (text.empty())
        return "";

    std::string outText;
    std::vector<std::string> words;
    const std::vector<std::string> wordsSplit = stdext::split(text);

    auto currentSize = 0;
    // break huge words into small ones
    for (const auto& word : wordsSplit) {
        const int wordWidth = calculateTextRectSize(word).width();
        if (wordWidth > maxWidth) {
            // For TTF fonts: iterate by codepoints, not bytes
            if (m_isTTF) {
                const std::u32string word32 = otc::text::utf8ToU32(word);
                std::u32string newWord32;
                for (size_t j = 0; j < word32.size(); ++j) {
                    std::u32string candidate32 = newWord32;
                    candidate32 += word32[j];
                    if (j != word32.size() - 1)
                        candidate32 += U'-';

                    const std::string candidateUtf8 = otc::text::u32ToUtf8(candidate32);
                    const int candidateWidth = calculateTextRectSize(candidateUtf8).width();
                    if (candidateWidth > maxWidth) {
                        newWord32 += U'-';
                        const std::string newWordUtf8 = otc::text::u32ToUtf8(newWord32);
                        words.push_back(newWordUtf8);
                        currentSize += newWordUtf8.size() + 2;
                        newWord32.clear();

                        updateColors(colors, currentSize - 2, 2);
                    }

                    newWord32 += word32[j];
                }

                const std::string finalWordUtf8 = otc::text::u32ToUtf8(newWord32);
                words.push_back(finalWordUtf8);
                currentSize += finalWordUtf8.size() + 1;
            } else {
                // Bitmap font: iterate by bytes (original code)
                std::string newWord;
                for (uint32_t j = 0; j < word.length(); ++j) {
                    std::string candidate = newWord + word[j];
                    if (j != word.length() - 1)
                        candidate += '-';

                    const int candidateWidth = calculateTextRectSize(candidate).width();
                    if (candidateWidth > maxWidth) {
                        newWord += '-';
                        words.push_back(newWord);
                        currentSize += newWord.size() + 2;
                        newWord.clear();

                        updateColors(colors, currentSize - 2, 2);
                    }

                    newWord += word[j];
                }

                words.push_back(newWord);
                currentSize += newWord.size() + 1;
            }
        } else {
            words.push_back(word);
            currentSize += word.size() + 1;
        }
    }

    // compose lines
    std::string line(words[0]);
    for (size_t i = 1; i < words.size(); ++i) {
        const auto& word = words[i];

        line.push_back(' ');
        const size_t lineSize = line.size();
        line.append(word);

        if (calculateTextRectSize(line).width() > maxWidth) {
            line.resize(lineSize);
            line.back() = '\n';
            outText.append(line);
            line.assign(word);
        }
    }
    outText.append(line);

    return outText;
}

void BitmapFont::updateColors(std::vector<std::pair<int, Color>>* colors, const int pos, const int newTextLen)
{
    if (!colors) return;
    for (auto& it : *colors) {
        if (it.first > pos) {
            it.first += newTextLen;
        }
    }
}

/**
 * @brief Retrieves the texture atlas region used by this font, if any.
 *
 * @return const AtlasRegion* Pointer to the atlas region associated with the font's texture, or `nullptr` if the font has no texture or the texture has no atlas region.
 */
const AtlasRegion* BitmapFont::getAtlasRegion() const {
    return m_texture ? m_texture->getAtlasRegion() : nullptr;
}
