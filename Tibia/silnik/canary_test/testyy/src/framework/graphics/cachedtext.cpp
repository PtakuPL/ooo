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

#include "cachedtext.h"
#include "fontmanager.h"

#include <framework/graphics/drawpoolmanager.h>
#include <framework/graphics/textureatlas.h>
#include <framework/text/TextShaper.h>
#include <framework/text/Utf8.h>
#include <framework/text/LocaleShaping.h>

#include <unordered_map>

CachedText::CachedText() : m_align(Fw::AlignCenter), m_coordsBuffer(std::make_shared<CoordsBuffer>()) {}

void CachedText::draw(const Rect& rect, const Color& color)
{
    if (!m_font)
        return;

    if (m_font->isTTF() && m_font->getTTFFont()) {
        drawTTF(rect, color);
        return;
    }

    // Hack to fix font rendering in atlas
    if (m_font->getAtlasRegion() != m_atlasRegion) {
        m_atlasRegion = m_font->getAtlasRegion();
        m_textScreenCoords = {};
    }

    if (m_textScreenCoords != rect) {
        m_textScreenCoords = rect;
        m_font->fillTextCoords(m_coordsBuffer, m_text, m_textSize, m_align, rect, m_glyphsPositions);
    }

    g_drawPool.addTexturedCoordsBuffer(m_font->getTexture(), m_coordsBuffer, color);
}

void CachedText::drawTTF(const Rect& rect, const Color& color)
{
    if (m_ttfGlyphs.empty())
        return;

    if (m_textScreenCoords != rect) {
        m_textScreenCoords = rect;
        rebuildTTFCoords(rect);
    }

    for (const auto& [texture, coords] : m_ttfBatches) {
        if (coords && coords->getVertexCount() > 0)
            g_drawPool.addTexturedCoordsBuffer(texture, coords, color);
    }
}

void CachedText::rebuildTTFCoords(const Rect& rect)
{
    m_ttfBatches.clear();
    if (m_ttfGlyphs.empty() || !rect.isValid())
        return;

    Point offset = rect.topLeft();

    if (m_align & Fw::AlignBottom) {
        offset = offset.translated(0, rect.height() - m_textSize.height());
    } else if (m_align & Fw::AlignVerticalCenter) {
        offset = offset.translated(0, (rect.height() - m_textSize.height()) / 2);
    }

    if (m_align & Fw::AlignRight) {
        offset = offset.translated(rect.width() - m_textSize.width(), 0);
    } else if (m_align & Fw::AlignHorizontalCenter) {
        offset = offset.translated((rect.width() - m_textSize.width()) / 2, 0);
    }

    std::vector<std::pair<TexturePtr, CoordsBufferPtr>> batches;
    std::unordered_map<const Texture*, size_t> batchIndex;
    batches.reserve(m_ttfGlyphs.size());

    const auto getCoords = [&](const TexturePtr& texture) -> CoordsBufferPtr {
        const auto raw = texture.get();
        const auto [it, inserted] = batchIndex.try_emplace(raw, batches.size());
        if (inserted) {
            batches.emplace_back(texture, std::make_shared<CoordsBuffer>());
            return batches.back().second;
        }
        return batches[it->second].second;
    };

    for (const auto& glyph : m_ttfGlyphs) {
        Rect dest = glyph.dest;
        dest.translate(offset);

        if (!rect.intersects(dest))
            continue;

        Rect src = glyph.src;

        if (dest.top() < rect.top()) {
            const int delta = rect.top() - dest.top();
            src.setTop(src.top() + delta);
            dest.setTop(rect.top());
        }
        if (dest.left() < rect.left()) {
            const int delta = rect.left() - dest.left();
            src.setLeft(src.left() + delta);
            dest.setLeft(rect.left());
        }
        if (dest.bottom() > rect.bottom()) {
            const int delta = dest.bottom() - rect.bottom();
            src.setBottom(src.bottom() - delta);
            dest.setBottom(rect.bottom());
        }
        if (dest.right() > rect.right()) {
            const int delta = dest.right() - rect.right();
            src.setRight(src.right() - delta);
            dest.setRight(rect.right());
        }

        getCoords(glyph.texture)->addRect(dest, src);
    }

    m_ttfBatches = std::move(batches);
}

void CachedText::update()
{
    m_ttfGlyphs.clear();

    if (m_font) {
        if (m_font->isTTF() && m_font->getTTFFont()) {
            const auto text32 = otc::text::utf8ToU32(m_text);
            const auto sp = otc::text::LocaleShaping::paramsFromUtf8(m_text, otc::text::LocaleShaping::getDefaultLocaleTag());

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
                lines.push_back(currentLine);
            }

            const auto* ttf = m_font->getTTFFont().get();
            const int ascentPx = std::max(0, ttf->ascent());
            const int descentPx = std::max(0, ttf->descent());
            const int lineHeightPx = std::max({ ttf->lineHeight(), m_font->getGlyphHeight(), ascentPx + descentPx });

            int maxLineWidth = 0;
            int totalHeight = lineHeightPx * static_cast<int>(lines.size());

            // Build quads for each line, offset by line number * lineHeight
            for (int lineIdx = 0; lineIdx < static_cast<int>(lines.size()); ++lineIdx) {
                const auto& line = lines[lineIdx];
                if (line.empty())
                    continue;

                std::vector<GlyphQuad> lineQuads;
                const Rect lineBounds = m_font->getTTFFont()->buildQuads(line, sp, lineQuads);
                if (lineQuads.empty())
                    continue;

                const int lineOffsetY = lineIdx * lineHeightPx;
                const Point lineTopLeft = lineBounds.topLeft();

                for (const auto& quad : lineQuads) {
                    CachedGlyph cached;
                    cached.texture = quad.texture;
                    cached.src = quad.src;
                    cached.dest = quad.dest;
                    cached.dest.translate(-lineTopLeft.x, -lineTopLeft.y + lineOffsetY);
                    m_ttfGlyphs.push_back(std::move(cached));
                }

                if (lineBounds.width() > maxLineWidth)
                    maxLineWidth = lineBounds.width();
            }

            m_textSize = Size(maxLineWidth, totalHeight);
        } else {
            m_font->calculateGlyphsPositions(m_text, m_align, m_glyphsPositions, &m_textSize);
        }
    } else {
        m_textSize = {};
    }

    m_textScreenCoords = {};
}

void CachedText::wrapText(const int maxWidth)
{
    if (!m_font)
        return;

    m_text = m_font->wrapText(m_text, maxWidth);
    update();
}

void CachedText::setFont(const BitmapFontPtr& font)
{
    if (m_font == font)
        return;

    m_font = font;
    update();
}
void CachedText::setText(const std::string_view text)
{
    if (m_text == text)
        return;

    m_text = text;
    update();
}
void CachedText::setAlign(const Fw::AlignmentFlag align)
{
    if (m_align == align)
        return;

    m_align = align;
    update();
}