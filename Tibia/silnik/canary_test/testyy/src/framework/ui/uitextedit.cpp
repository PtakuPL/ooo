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

#include "uitextedit.h"
#include <framework/core/clock.h>
#include <framework/graphics/bitmapfont.h>
#include <framework/graphics/graphics.h>
#include <framework/input/mouse.h>
#include <framework/text/Utf8.h>  // for otc::text::utf8ToU32, u32ToUtf8
#include <cmath>
#include <framework/otml/otmlnode.h>
#include <framework/platform/platformwindow.h>

#include "framework/graphics/drawpoolmanager.h"
#include "uitranslator.h"
#include <framework/graphics/fontmanager.h>
#include <framework/graphics/textureatlas.h>

#ifdef __EMSCRIPTEN__
#include <emscripten/emscripten.h>
#endif

UITextEdit::UITextEdit()
{
    setProp(PropCursorInRange, true);
    setProp(PropCursorVisible, true);
    setProp(PropEditable, true);
    setProp(PropChangeCursorImage, true);
    setProp(PropUpdatesEnabled, true);
    setProp(PropAutoScroll, true);
    setProp(PropSelectable, true);
    setProp(PropGlyphsMustRecache, true);

    m_textAlign = Fw::AlignTopLeft;
    m_placeholder = "";
    m_placeholderColor = Color::gray;
    m_placeholderFont = g_fonts.getDefaultFont();
    m_placeholderAlign = Fw::AlignLeftCenter;
    blinkCursor();
}

void UITextEdit::drawSelf(const DrawPoolType drawPane)
{
    if (drawPane != DrawPoolType::FOREGROUND)
        return;

    drawBackground(m_rect);
    drawBorder(m_rect);
    drawImage(m_rect);
    drawIcon(m_rect);

    const auto& texture = m_font->getTexture();
    // Allow TTF fonts to render even if getTexture() returns null (TTF uses atlas textures internally)
    if (!m_font->isTTF() && !texture)
        return;

    const bool glyphsMustRecache = getProp(PropGlyphsMustRecache);
    if (glyphsMustRecache)
        setProp(PropGlyphsMustRecache, false);

    // Hack to fix font rendering in atlas
    if (m_font->getAtlasRegion() != m_atlasRegion) {
        m_atlasRegion = m_font->getAtlasRegion();
        update(false, true);
    }

    // For TTF: use codepoint count; for bitmap: use byte length capped by glyph coords
    const int textLength = m_font->isTTF() 
        ? static_cast<int>(m_text32.size())
        : std::min<int>(m_glyphsCoords.size(), m_text.length());
    if (textLength == 0) {
        if (m_placeholderColor != Color::alpha && !m_placeholder.empty()) {
            m_placeholderFont->drawText(m_placeholder, m_drawArea, m_placeholderColor, m_placeholderAlign);
        }
    }

    if (m_color != Color::alpha) {
        g_drawPool.setDrawOrder(m_textDrawOrder);
        if (m_font->isTTF()) {
            // For TTF fonts we draw via the font drawText path (it handles shaping + atlas batching)
            m_font->drawText(m_drawText, m_drawArea, m_color, m_textAlign);
        } else {
            if (m_drawTextColors.empty() || m_colorCoordsBuffer.empty()) {
                g_drawPool.addTexturedCoordsBuffer(texture, m_coordsBuffer, m_color);
            } else {
                for (const auto& [color, coordsBuffer] : m_colorCoordsBuffer) {
                    g_drawPool.addTexturedCoordsBuffer(texture, coordsBuffer, color);
                }
            }
        }
        g_drawPool.resetDrawOrder();
    }

    if (hasSelection()) {
        if (glyphsMustRecache) {
            m_glyphsSelectRectCache.clear();
            if (!m_font->isTTF()) {
                for (int i = m_selectionStart; i < m_selectionEnd; ++i)
                    m_glyphsSelectRectCache.emplace_back(m_glyphsCoords[i].first, m_glyphsCoords[i].second);
            } else {
                // For TTF fonts, calculate selection rectangle using substring widths (approximation)
                const std::string fullText = m_drawText;
                const int totalW = m_font->calculateTextRectSize(fullText).width();
                const int preW = m_font->calculateTextRectSize(fullText.substr(0, std::max(0, m_selectionStart))).width();
                const int selW = m_font->calculateTextRectSize(fullText.substr(m_selectionStart, m_selectionEnd - m_selectionStart)).width();

                // Compute horizontal alignment the same way BitmapFont does
                // Correct: call left() accessor, not refer to overloaded function pointer
                float bx = static_cast<float>(m_drawArea.left());
                if (m_textAlign & Fw::AlignRight) {
                    bx = static_cast<float>(m_drawArea.right()) - totalW;
                } else if (m_textAlign & Fw::AlignHorizontalCenter) {
                    bx = static_cast<float>(m_drawArea.left()) + (m_drawArea.width() - totalW) * 0.5f;
                }

                const Rect selRect(static_cast<int>(std::lround(bx + preW)), m_drawArea.top(), selW, m_font->getGlyphHeight());
                m_glyphsSelectRectCache.emplace_back(selRect, Rect());
            }
        }
        for (const auto& [dest, src] : m_glyphsSelectRectCache)
            g_drawPool.addFilledRect(dest, m_selectionBackgroundColor);

        if (!m_font->isTTF()) {
            for (const auto& [dest, src] : m_glyphsSelectRectCache)
                g_drawPool.addTexturedRect(dest, texture, src, m_selectionColor);
        } else {
            // For TTF fonts, we don't have per-glyph texture coords; filled rect is sufficient for selection
            // Optionally, compute per-substring widths and draw a precise selection rectangle in future refinements.
        }
    }

    // render cursor
    if (isExplicitlyEnabled() && getProp(PropCursorVisible) && getProp(PropCursorInRange) && isActive() && m_cursorPos >= 0) {
        assert(m_cursorPos <= textLength);
        // draw every 333ms
        constexpr int delay = 333;
        const ticks_t elapsed = g_clock.millis() - m_cursorTicks;
        if (elapsed <= delay) {
            auto cursorRect = [&]() -> Rect {
                if (m_font->isTTF()) {
                    // Compute cursor x using substring width and alignment
                    const std::string fullText = m_drawText;
                    const int totalW = m_font->calculateTextRectSize(fullText).width();
                    const int preW = m_font->calculateTextRectSize(fullText.substr(0, m_cursorPos)).width();
                    float bx = static_cast<float>(m_drawArea.left());
                    if (m_textAlign & Fw::AlignRight) {
                        bx = static_cast<float>(m_drawArea.right()) - totalW;
                    } else if (m_textAlign & Fw::AlignHorizontalCenter) {
                        bx = static_cast<float>(m_drawArea.left()) + (m_drawArea.width() - totalW) * 0.5f;
                    }
                    const int x = static_cast<int>(std::lround(bx + preW));
                    return Rect(x, m_drawArea.top(), 1, m_font->getGlyphHeight());
                } else {
                    return m_cursorPos > 0 ?
                        Rect(m_glyphsCoords[m_cursorPos - 1].first.right(), m_glyphsCoords[m_cursorPos - 1].first.top(), 1, m_font->getGlyphHeight())
                        : Rect(m_rect.left() + m_padding.left, m_rect.top() + m_padding.top, 1, m_font->getGlyphHeight());
                }
            }();

            const bool useSelectionColor = hasSelection() && m_cursorPos >= m_selectionStart && m_cursorPos <= m_selectionEnd;
            const auto& color = useSelectionColor ? m_selectionColor : m_color;
            g_drawPool.addFilledRect(cursorRect, color);
        } else if (elapsed >= 2 * delay) {
            m_cursorTicks = g_clock.millis();
        }
    }
}

void UITextEdit::update(const bool focusCursor, bool disableAreaUpdate)
{
    if (!getProp(PropUpdatesEnabled))
        return;

    std::string text = getDisplayedText();
    if (m_text.ends_with(" "))
        text += " ";

    m_drawText = text;
    const int textLength = text.length();

    // prevent glitches
    if (m_rect.isEmpty())
        return;

    // recache coords buffers
    if (!m_font->isTTF())
        recacheGlyphs();

    // map glyphs positions or compute bounding size
    Size textBoxSize;
    if (!m_font->isTTF()) {
        m_font->calculateGlyphsPositions(text, m_textAlign, m_glyphsPositionsCache, &textBoxSize);
    } else {
        // TTF font branch: we do not cache per-glyph positions here; calculate bounding size instead.
        textBoxSize = m_font->calculateTextRectSize(text);
        // Clear caches used for bitmap glyphs so that bitmap-specific code doesn't run
        m_glyphsPositionsCache.clear();
        m_glyphsCoords.clear();
    }
    const Rect* glyphsTextureCoords = m_font->getGlyphsTextureCoords();
    const Size* glyphsSize = m_font->getGlyphsSize();
    int glyph;

    // update rect size
    if (!m_rect.isValid() || hasProp(PropTextHorizontalAutoResize) || hasProp(PropTextVerticalAutoResize)) {
        textBoxSize += Size(m_padding.left + m_padding.right, m_padding.top + m_padding.bottom) + m_textOffset.toSize();
        Size size = getSize();
        if (size.width() <= 0 || (hasProp(PropTextHorizontalAutoResize) && !isTextWrap()))
            size.setWidth(textBoxSize.width());
        if (size.height() <= 0 || hasProp(PropTextVerticalAutoResize))
            size.setHeight(textBoxSize.height());
        setSize(size);
    }

    // resize just on demand
    if (textLength > static_cast<int>(m_glyphsCoords.size())) {
        m_glyphsCoords.resize(textLength);
    }

    const Point oldTextAreaOffset = m_textVirtualOffset;

    if (textBoxSize.width() <= getPaddingRect().width())
        m_textVirtualOffset.x = 0;
    if (textBoxSize.height() <= getPaddingRect().height())
        m_textVirtualOffset.y = 0;

    // readjust start view area based on cursor position
    setProp(PropCursorInRange, false);
    if (focusCursor && getProp(PropAutoScroll)) {
        if (m_font->isTTF()) {
            // For TTF fonts, we skip detailed glyph-based scrolling
            // The cursor is always considered in range since TTF rendering handles clipping
            m_textVirtualOffset = {};
            setProp(PropCursorInRange, true);
        } else if (m_cursorPos > 0 && textLength > 0) {
            // Bitmap font path: m_cursorPos is byte-based for compatibility
            assert(m_cursorPos <= textLength);
            const Rect virtualRect(m_textVirtualOffset, m_rect.size() - Size(m_padding.left + m_padding.right, 0)); // previous rendered virtual rect
            int pos = m_cursorPos - 1; // element before cursor
            glyph = static_cast<uint8_t>(text[pos]); // glyph of the element before cursor
            Rect glyphRect(m_glyphsPositionsCache[pos], glyphsSize[glyph]);

            // if the cursor is not on the previous rendered virtual rect we need to update it
            if (!virtualRect.contains(glyphRect.topLeft()) || !virtualRect.contains(glyphRect.bottomRight())) {
                // calculate where is the first glyph visible
                Point startGlyphPos;
                startGlyphPos.y = std::max<int>(glyphRect.bottom() - virtualRect.height(), 0);
                startGlyphPos.x = std::max<int>(glyphRect.right() - virtualRect.width(), 0);

                // find that glyph
                for (pos = 0; pos < textLength; ++pos) {
                    glyph = static_cast<uint8_t>(text[pos]);
                    glyphRect = Rect(m_glyphsPositionsCache[pos], glyphsSize[glyph]);
                    glyphRect.setTop(std::max<int>(glyphRect.top() - m_font->getYOffset() - m_font->getGlyphSpacing().height(), 0));
                    glyphRect.setLeft(std::max<int>(glyphRect.left() - m_font->getGlyphSpacing().width(), 0));

                    // first glyph entirely visible found
                    if (glyphRect.topLeft() >= startGlyphPos) {
                        m_textVirtualOffset.x = m_glyphsPositionsCache[pos].x;
                        m_textVirtualOffset.y = m_glyphsPositionsCache[pos].y - m_font->getYOffset();
                        break;
                    }
                }
            }
            setProp(PropCursorInRange, true);
        } else {
            m_textVirtualOffset = {};
            setProp(PropCursorInRange, true);
        }
    } else {
        if (m_font->isTTF()) {
            // TTF fonts: cursor is always in range
            setProp(PropCursorInRange, true);
        } else if (m_cursorPos > 0 && textLength > 0) {
            const Rect virtualRect(m_textVirtualOffset, m_rect.size() - Size(2 * m_padding.left + m_padding.right, 0)); // previous rendered virtual rect
            const int pos = m_cursorPos - 1; // element before cursor
            glyph = static_cast<uint8_t>(text[pos]); // glyph of the element before cursor
            const Rect glyphRect(m_glyphsPositionsCache[pos], glyphsSize[glyph]);
            if (virtualRect.contains(glyphRect.topLeft()) && virtualRect.contains(glyphRect.bottomRight()))
                setProp(PropCursorInRange, true);
        } else {
            setProp(PropCursorInRange, true);
        }
    }

    bool fireAreaUpdate = false;
    if (oldTextAreaOffset != m_textVirtualOffset)
        fireAreaUpdate = true;

    Rect textScreenCoords = m_rect;
    textScreenCoords.expandLeft(-m_padding.left);
    textScreenCoords.expandRight(-m_padding.right);
    textScreenCoords.expandBottom(-m_padding.bottom);
    textScreenCoords.expandTop(-m_padding.top);
    m_drawArea = textScreenCoords;

    if (textScreenCoords.size() != m_textVirtualSize) {
        m_textVirtualSize = textScreenCoords.size();
        fireAreaUpdate = true;
    }

    Size totalSize = textBoxSize;
    if (totalSize.width() < m_textVirtualSize.width())
        totalSize.setWidth(m_textVirtualSize.height());
    if (totalSize.height() < m_textVirtualSize.height())
        totalSize.setHeight(m_textVirtualSize.height());
    if (m_textTotalSize != totalSize) {
        m_textTotalSize = totalSize;
        fireAreaUpdate = true;
    }

    if (m_textAlign & Fw::AlignBottom) {
        m_drawArea.translate(0, textScreenCoords.height() - textBoxSize.height());
    } else if (m_textAlign & Fw::AlignVerticalCenter) {
        m_drawArea.translate(0, (textScreenCoords.height() - textBoxSize.height()) / 2);
    } else { // AlignTop
    }

    if (m_textAlign & Fw::AlignRight) {
        m_drawArea.translate(textScreenCoords.width() - textBoxSize.width(), 0);
    } else if (m_textAlign & Fw::AlignHorizontalCenter) {
        m_drawArea.translate((textScreenCoords.width() - textBoxSize.width()) / 2, 0);
    } else { // AlignLeft
    }

    // Bitmap font rendering path - TTF fonts skip this entirely
    // TTF fonts render via drawText() in drawSelf() which handles shaping internally
    if (!m_font->isTTF()) {
        std::map<uint32_t, CoordsBufferPtr> colorCoordsMap;
        uint32_t curColorRgba;
        int32_t nextColorIndex = 0;
        int32_t colorIndex = -1;
        CoordsBufferPtr coords;

        const int textColorsSize = m_drawTextColors.size();
        m_colorCoordsBuffer.clear();
        m_coordsBuffer->clear();

        for (int i = 0; i < textLength; ++i) {
            if (i >= nextColorIndex) {
                colorIndex = colorIndex + 1;
                if (colorIndex < textColorsSize) {
                    curColorRgba = m_drawTextColors[colorIndex].second.rgba();
                }
                if (colorIndex + 1 < textColorsSize) {
                    nextColorIndex = m_drawTextColors[colorIndex + 1].first;
                } else {
                    nextColorIndex = textLength;
                }

                if (!colorCoordsMap.contains(curColorRgba)) {
                    colorCoordsMap.insert(std::make_pair(curColorRgba, std::make_shared<CoordsBuffer>()));
                }

                coords = colorCoordsMap[curColorRgba];
            }

            glyph = static_cast<uint8_t>(text[i]);
            m_glyphsCoords[i].first.clear();

            // skip invalid glyphs
            if (glyph < 32)
                continue;

            // calculate initial glyph rect and texture coords
            Rect glyphScreenCoords(m_glyphsPositionsCache[i], glyphsSize[glyph]);
            Rect glyphTextureCoords = glyphsTextureCoords[glyph];

            // first translate to align position
            if (m_textAlign & Fw::AlignBottom) {
                glyphScreenCoords.translate(0, textScreenCoords.height() - textBoxSize.height());
            } else if (m_textAlign & Fw::AlignVerticalCenter) {
                glyphScreenCoords.translate(0, (textScreenCoords.height() - textBoxSize.height()) / 2);
            } else { // AlignTop
                // nothing to do
            }

            if (m_textAlign & Fw::AlignRight) {
                glyphScreenCoords.translate(textScreenCoords.width() - textBoxSize.width(), 0);
            } else if (m_textAlign & Fw::AlignHorizontalCenter) {
                glyphScreenCoords.translate((textScreenCoords.width() - textBoxSize.width()) / 2, 0);
            } else { // AlignLeft
                // nothing to do
            }

            // only render glyphs that are after startRenderPosition
            if (glyphScreenCoords.bottom() < m_textVirtualOffset.y || glyphScreenCoords.right() < m_textVirtualOffset.x)
                continue;

            // bound glyph topLeft to startRenderPosition
            if (glyphScreenCoords.top() < m_textVirtualOffset.y) {
                glyphTextureCoords.setTop(glyphTextureCoords.top() + (m_textVirtualOffset.y - glyphScreenCoords.top()));
                glyphScreenCoords.setTop(m_textVirtualOffset.y);
            }
            if (glyphScreenCoords.left() < m_textVirtualOffset.x) {
                glyphTextureCoords.setLeft(glyphTextureCoords.left() + (m_textVirtualOffset.x - glyphScreenCoords.left()));
                glyphScreenCoords.setLeft(m_textVirtualOffset.x);
            }

            // subtract startInternalPos
            glyphScreenCoords.translate(-m_textVirtualOffset);

            // translate rect to screen coords
            glyphScreenCoords.translate(textScreenCoords.topLeft());

            // only render if glyph rect is visible on screenCoords
            if (!textScreenCoords.intersects(glyphScreenCoords))
                continue;

            // bound glyph bottomRight to screenCoords bottomRight
            if (glyphScreenCoords.bottom() > textScreenCoords.bottom()) {
                glyphTextureCoords.setBottom(glyphTextureCoords.bottom() + (textScreenCoords.bottom() - glyphScreenCoords.bottom()));
                glyphScreenCoords.setBottom(textScreenCoords.bottom());
            }
            if (glyphScreenCoords.right() > textScreenCoords.right()) {
                glyphTextureCoords.setRight(glyphTextureCoords.right() + (textScreenCoords.right() - glyphScreenCoords.right()));
                glyphScreenCoords.setRight(textScreenCoords.right());
            }

            // render glyph
            m_glyphsCoords[i].first = glyphScreenCoords;
            m_glyphsCoords[i].second = glyphTextureCoords;

            if (m_atlasRegion)
                glyphTextureCoords.translate(m_atlasRegion->x, m_atlasRegion->y);

            if (textColorsSize > 0) {
                coords->addRect(glyphScreenCoords, glyphTextureCoords);
            } else {
                m_coordsBuffer->addRect(glyphScreenCoords, glyphTextureCoords);
            }
        }

        for (auto& [rgba, crds] : colorCoordsMap) {
            m_colorCoordsBuffer.emplace_back(Color(rgba), crds);
        }
    }

    if (!disableAreaUpdate && fireAreaUpdate)
        onTextAreaUpdate(m_textVirtualOffset, m_textVirtualSize, m_textTotalSize);

    repaint();
}

void UITextEdit::setCursorPos(int pos)
{
    if (pos < 0)
        pos = static_cast<int>(m_text32.size());

    if (pos == m_cursorPos)
        return;

    // Clamp cursor position to valid codepoint range
    if (pos < 0)
        m_cursorPos = 0;
    else if (static_cast<size_t>(pos) >= m_text32.size())
        m_cursorPos = static_cast<int>(m_text32.size());
    else
        m_cursorPos = pos;

    update(true);
}

void UITextEdit::setSelection(int start, int end)
{
    if (start == m_selectionStart && end == m_selectionEnd)
        return;

    if (start > end)
        std::swap(start, end);

    if (end == -1)
        end = static_cast<int>(m_text32.size());

    // Clamp selection to valid codepoint range
    m_selectionStart = std::clamp<int>(start, 0, static_cast<int>(m_text32.size()));
    m_selectionEnd = std::clamp<int>(end, 0, static_cast<int>(m_text32.size()));
    recacheGlyphs();

    repaint();
}

void UITextEdit::setTextHidden(const bool hidden)
{
    if (getProp(PropTextHidden) == hidden)
        return;

    setProp(PropTextHidden, hidden);
    updateText();
}

void UITextEdit::setTextVirtualOffset(const Point& offset)
{
    m_textVirtualOffset = offset;
    update();
}

void UITextEdit::appendText(const std::string_view txt)
{
    std::string text{ txt.data(), txt.size() };

    if (hasSelection())
        del();

    if (m_cursorPos >= 0) {
        // replace characters that are not allowed
        if (!getProp(PropMultiline))
            stdext::replace_all(text, "\n", " ");
        stdext::replace_all(text, "\r", "");
        stdext::replace_all(text, "\t", "    ");

        if (text.empty())
            return;
            
        // Convert input UTF-8 to codepoints
        const std::u32string inputCodepoints = otc::text::utf8ToU32(text);
        if (inputCodepoints.empty())
            return;

        // Check max length in codepoints (not bytes!)
        if (m_maxLength > 0 && m_text32.size() + inputCodepoints.size() > m_maxLength)
            return;

        // Check valid characters (ASCII only for now - validCharacters is legacy)
        if (!m_validCharacters.empty()) {
            for (const char32_t cp : inputCodepoints) {
                // Only check ASCII range against validCharacters
                if (cp < 128 && m_validCharacters.find(static_cast<char>(cp)) == std::string::npos)
                    return;
            }
        }

        // Insert codepoints at cursor position (which is now a codepoint index)
        m_text32.insert(m_text32.begin() + m_cursorPos, inputCodepoints.begin(), inputCodepoints.end());
        m_cursorPos += static_cast<int>(inputCodepoints.size());
        
        // Sync m_text (UTF-8) from m_text32 (codepoints)
        setText(otc::text::u32ToUtf8(m_text32));
    }
}

void UITextEdit::appendCharacter(const char32_t codepoint)
{
    // Check newline/carriage return (they have same codepoints as ASCII)
    if ((codepoint == U'\n' && !getProp(PropMultiline)) || codepoint == U'\r')
        return;

    if (hasSelection())
        del();

    // Note: removed the "m_cursorPos == 0" check - it was a bug
    // You should be able to type at position 0

    // Check max length in codepoints
    if (m_maxLength > 0 && m_text32.size() + 1 > m_maxLength)
        return;

    // Check valid characters (ASCII only for legacy support)
    if (!m_validCharacters.empty() && codepoint < 128) {
        if (m_validCharacters.find(static_cast<char>(codepoint)) == std::string::npos)
            return;
    }

    // Insert single codepoint at cursor position
    m_text32.insert(m_text32.begin() + m_cursorPos, codepoint);
    ++m_cursorPos;
    
    // Sync m_text (UTF-8) from m_text32 (codepoints)
    setText(otc::text::u32ToUtf8(m_text32));
}

void UITextEdit::removeCharacter(const bool right)
{
    // Work with codepoints, not bytes - this fixes backspace for Polish characters
    if (m_text32.empty())
        return;
        
    if (right) {
        // Delete key - remove character at cursor
        if (static_cast<size_t>(m_cursorPos) < m_text32.size()) {
            m_text32.erase(m_text32.begin() + m_cursorPos);
        }
    } else {
        // Backspace - remove character before cursor
        if (m_cursorPos > 0) {
            --m_cursorPos;
            m_text32.erase(m_text32.begin() + m_cursorPos);
        }
    }
    
    // Sync m_text (UTF-8) from m_text32 (codepoints)
    setText(otc::text::u32ToUtf8(m_text32));
}

void UITextEdit::blinkCursor()
{
    m_cursorTicks = g_clock.millis();
    repaint();
}

void UITextEdit::deleteSelection()
{
    if (!hasSelection())
        return;

    // Work with codepoints - selection indices are codepoint indices
    m_text32.erase(m_text32.begin() + m_selectionStart, 
                   m_text32.begin() + m_selectionEnd);

    setCursorPos(m_selectionStart);
    clearSelection();
    
    // Sync m_text (UTF-8) from m_text32 (codepoints)
    setText(otc::text::u32ToUtf8(m_text32));
}

void UITextEdit::del(const bool right)
{
    if (hasSelection()) {
        deleteSelection();
    } else
        removeCharacter(right);
}

void UITextEdit::paste(const std::string_view text)
{
    if (hasSelection())
        del();

    appendText(text);
}

std::string UITextEdit::copy()
{
    std::string text;
    if (hasSelection()) {
        text = getSelection();
        g_window.setClipboardText(text);
    }
    return text;
}

std::string UITextEdit::cut()
{
    std::string text = copy();
    del();
    return text;
}

void UITextEdit::wrapText()
{
    setText(m_font->wrapText(m_text, getPaddingRect().width() - m_textOffset.x));
}

void UITextEdit::moveCursorHorizontally(const bool right)
{
    // Move cursor by one codepoint, not byte
    if (right) {
        if (static_cast<size_t>(m_cursorPos) < m_text32.size())
            ++m_cursorPos;
        else
            m_cursorPos = 0;  // wrap to beginning
    } else {
        if (m_cursorPos > 0)
            --m_cursorPos;
        else
            m_cursorPos = static_cast<int>(m_text32.size());  // wrap to end
    }

    blinkCursor();
    update(true);
}

void UITextEdit::moveCursorVertically(bool)
{
    //TODO
}

int UITextEdit::getTextPos(const Point& pos)
{
    // For TTF fonts: use width-based approximation since we don't have per-glyph coords
    if (m_font->isTTF()) {
        const int codepointCount = static_cast<int>(m_text32.size());
        if (codepointCount == 0)
            return 0;
        
        // Calculate total text width and alignment offset
        const std::string fullText = m_drawText;
        const int totalW = m_font->calculateTextRectSize(fullText).width();
        
        float bx = static_cast<float>(m_drawArea.left());
        if (m_textAlign & Fw::AlignRight) {
            bx = static_cast<float>(m_drawArea.right()) - totalW;
        } else if (m_textAlign & Fw::AlignHorizontalCenter) {
            bx = static_cast<float>(m_drawArea.left()) + (m_drawArea.width() - totalW) * 0.5f;
        }
        
        // If click is before text start
        if (pos.x < static_cast<int>(bx))
            return 0;
        
        // If click is after text end
        if (pos.x >= static_cast<int>(bx) + totalW)
            return codepointCount;
        
        // Binary search for position (find codepoint where click falls)
        // Convert position to UTF-8 bytes for substring measurement
        const int clickX = pos.x - static_cast<int>(bx);
        int bestPos = 0;
        int prevWidth = 0;
        
        for (int i = 1; i <= codepointCount; ++i) {
            // Get UTF-8 byte offset for i codepoints
            const size_t byteOffset = otc::text::utf8ByteOffset(m_text, i);
            const int width = m_font->calculateTextRectSize(m_text.substr(0, byteOffset)).width();
            
            // Check if click is between prevWidth and width
            if (clickX < width) {
                // Decide if closer to previous or current position
                if (clickX - prevWidth < width - clickX)
                    return bestPos;
                else
                    return i;
            }
            
            prevWidth = width;
            bestPos = i;
        }
        
        return codepointCount;
    }
    
    // Bitmap font path (unchanged)
    const int textLength = std::min<int>(m_glyphsCoords.size(), m_text.length());

    // find any glyph that is actually on the
    int candidatePos = -1;
    Rect firstGlyphRect, lastGlyphRect;
    for (int i = 0; i < textLength; ++i) {
        Rect clickGlyphRect = m_glyphsCoords[i].first;
        if (!clickGlyphRect.isValid())
            continue;
        if (!firstGlyphRect.isValid())
            firstGlyphRect = clickGlyphRect;
        lastGlyphRect = clickGlyphRect;
        clickGlyphRect.expandTop(m_font->getYOffset() + m_font->getGlyphSpacing().height());
        clickGlyphRect.expandLeft(m_font->getGlyphSpacing().width() + 1);
        if (clickGlyphRect.contains(pos)) {
            candidatePos = i;
            break;
        }
        if (pos.y >= clickGlyphRect.top() && pos.y <= clickGlyphRect.bottom()) {
            if (pos.x <= clickGlyphRect.left()) {
                candidatePos = i;
                break;
            }
            if (pos.x >= clickGlyphRect.right())
                candidatePos = i + 1;
        }
    }

    if (textLength > 0) {
        if (pos.y < firstGlyphRect.top())
            return 0;
        if (pos.y > lastGlyphRect.bottom())
            return textLength;
    }

    return candidatePos;
}

void UITextEdit::updateDisplayedText()
{
    std::string text;
    if (getProp(PropTextHidden)) {
        // For password fields: show asterisks for each CODEPOINT, not each byte
        text = std::string(m_text32.size(), '*');
    } else {
        text = m_text;
    }

    m_drawTextColors = m_textColors;

    if (isTextWrap() && m_rect.isValid()) {
        text = m_font->wrapText(text, getPaddingRect().width() - m_textOffset.x);
    }

    m_displayedText = text;
}

std::string UITextEdit::getSelection()
{
    if (!hasSelection())
        return {};
    
    // Convert selected codepoints back to UTF-8
    const std::u32string selected(m_text32.begin() + m_selectionStart, 
                                  m_text32.begin() + m_selectionEnd);
    return otc::text::u32ToUtf8(selected);
}

void UITextEdit::updateText()
{
    // Sync m_text32 from m_text when text is set externally (via setText())
    const std::u32string newText32 = otc::text::utf8ToU32(m_text);
    if (m_text32 != newText32) {
        m_text32 = newText32;
    }
    
    // Clamp cursor to valid codepoint range
    if (m_cursorPos > static_cast<int>(m_text32.size()))
        m_cursorPos = static_cast<int>(m_text32.size());

    // any text changes reset the selection
    if (getProp(PropSelectable)) {
        m_selectionEnd = 0;
        m_selectionStart = 0;
    }

    blinkCursor();

    updateDisplayedText();
    update(true);
}

void UITextEdit::onHoverChange(const bool hovered)
{
    if (getProp(PropChangeCursorImage)) {
        if (hovered && !g_mouse.isCursorChanged())
            g_mouse.pushCursor("text");
        else
            g_mouse.popCursor("text");
    }
}

void UITextEdit::onStyleApply(const std::string_view styleName, const OTMLNodePtr& styleNode)
{
    UIWidget::onStyleApply(styleName, styleNode);

    for (const auto& node : styleNode->children()) {
        if (node->tag() == "text") {
            setText(node->value());
            setCursorPos(static_cast<int>(m_text32.size()));
        } else if (node->tag() == "text-hidden")
            setTextHidden(node->value<bool>());
        else if (node->tag() == "shift-navigation")
            setShiftNavigation(node->value<bool>());
        else if (node->tag() == "multiline")
            setMultiline(node->value<bool>());
        else if (node->tag() == "max-length")
            setMaxLength(node->value<int>());
        else if (node->tag() == "editable")
            setEditable(node->value<bool>());
        else if (node->tag() == "selectable")
            setSelectable(node->value<bool>());
        else if (node->tag() == "selection-color")
            setSelectionColor(node->value<Color>());
        else if (node->tag() == "selection-background-color")
            setSelectionBackgroundColor(node->value<Color>());
        else if (node->tag() == "selection") {
            const auto& selectionRange = node->value<Point>();
            setSelection(selectionRange.x, selectionRange.y);
        } else if (node->tag() == "cursor-visible")
            setCursorVisible(node->value<bool>());
        else if (node->tag() == "change-cursor-image")
            setChangeCursorImage(node->value<bool>());
        else if (node->tag() == "auto-scroll")
            setAutoScroll(node->value<bool>());
        else if (node->tag() == "placeholder")
            setPlaceholder(node->value());
        else if (node->tag() == "placeholder-color")
            setPlaceholderColor(node->value<Color>());
        else if (node->tag() == "placeholder-align")
            setPlaceholderAlign(Fw::translateAlignment(node->value()));
        else if (node->tag() == "placeholder-font")
            setPlaceholderFont(node->value());
    }
}

void UITextEdit::onGeometryChange(const Rect& oldRect, const Rect& newRect)
{
    update(true);
    UIWidget::onGeometryChange(oldRect, newRect);
}

void UITextEdit::onFocusChange(const bool focused, const Fw::FocusReason reason)
{
    if (focused) {
        if (reason == Fw::KeyboardFocusReason)
            setCursorPos(static_cast<int>(m_text32.size()));
        else
            blinkCursor();
        update(true);
#ifdef ANDROID
        g_androidManager.showKeyboardSoft();
#endif
    } else if (getProp(PropSelectable))
        clearSelection();
    UIWidget::onFocusChange(focused, reason);
}

bool UITextEdit::onKeyPress(const uint8_t keyCode, const int keyboardModifiers, const int autoRepeatTicks)
{
    if (UIWidget::onKeyPress(keyCode, keyboardModifiers, autoRepeatTicks))
        return true;

    if (keyboardModifiers == Fw::KeyboardNoModifier) {
        if (keyCode == Fw::KeyDelete && getProp(PropEditable)) { // erase right character
            if (hasSelection() || !m_text32.empty()) {
                del(true);
                return true;
            }
        } else if (keyCode == Fw::KeyBackspace && getProp(PropEditable)) { // erase left character
            if (hasSelection() || !m_text32.empty()) {
                del(false);
                return true;
            }
        } else if (keyCode == Fw::KeyRight && !getProp(PropShiftNavigation)) { // move cursor right
            clearSelection();
            moveCursorHorizontally(true);
            return true;
        } else if (keyCode == Fw::KeyLeft && !getProp(PropShiftNavigation)) { // move cursor left
            clearSelection();
            moveCursorHorizontally(false);
            return true;
        } else if (keyCode == Fw::KeyHome) { // move cursor to first character
            if (m_cursorPos != 0) {
                clearSelection();
                setCursorPos(0);
                return true;
            }
        } else if (keyCode == Fw::KeyEnd) { // move cursor to last character
            const int textLen = static_cast<int>(m_text32.size());
            if (m_cursorPos != textLen) {
                clearSelection();
                setCursorPos(textLen);
                return true;
            }
        } else if (keyCode == Fw::KeyTab && !getProp(PropShiftNavigation)) {
            clearSelection();
            if (const auto& parent = getParent())
                parent->focusNextChild(Fw::KeyboardFocusReason, true);
            return true;
        } else if (keyCode == Fw::KeyEnter && getProp(PropMultiline) && getProp(PropEditable)) {
            appendCharacter(U'\n');  // Unicode newline codepoint
            return true;
        } else if (keyCode == Fw::KeyUp && !getProp(PropShiftNavigation) && getProp(PropMultiline)) {
            moveCursorVertically(true);
            return true;
        } else if (keyCode == Fw::KeyDown && !getProp(PropShiftNavigation) && getProp(PropMultiline)) {
            moveCursorVertically(false);
            return true;
        }
    } else if (keyboardModifiers == Fw::KeyboardCtrlModifier) {
        if (keyCode == Fw::KeyV && getProp(PropEditable)) {
            paste(g_window.getClipboardText());
            return true;
        }

        if (keyCode == Fw::KeyX && getProp(PropEditable) && getProp(PropSelectable)) {
            if (hasSelection()) {
                cut();
                return true;
            }
        } else if (keyCode == Fw::KeyC && getProp(PropSelectable)) {
            if (hasSelection()) {
                copy();
                return true;
            }
        } else if (keyCode == Fw::KeyA && getProp(PropSelectable)) {
            if (!m_text32.empty()) {
                selectAll();
                return true;
            }
        } else if (keyCode == Fw::KeyBackspace) {
            if (hasSelection()) {
                deleteSelection();
            } else if (!m_text32.empty()) {
                // delete last word - work with codepoints
                if (m_cursorPos == 0) {
                    m_text32.erase(m_text32.begin());
                } else {
                    int pos = m_cursorPos;
                    // Skip trailing spaces
                    while (pos > 0 && m_text32[pos - 1] == U' ')
                        --pos;
                    // Skip word characters
                    while (pos > 0 && m_text32[pos - 1] != U' ')
                        --pos;
                    // Erase from pos to cursor
                    m_text32.erase(m_text32.begin() + pos, m_text32.begin() + m_cursorPos);
                    m_cursorPos = pos;
                }
                // Sync m_text (UTF-8) from m_text32 (codepoints)
                setText(otc::text::u32ToUtf8(m_text32));
                return true;
            }
        }
    } else if (keyboardModifiers == Fw::KeyboardShiftModifier) {
        if (keyCode == Fw::KeyTab && !getProp(PropShiftNavigation)) {
            if (const auto& parent = getParent())
                parent->focusPreviousChild(Fw::KeyboardFocusReason, true);
            return true;
        }
        if (keyCode == Fw::KeyRight || keyCode == Fw::KeyLeft) {
            const size_t oldCursorPos = m_cursorPos;

            if (keyCode == Fw::KeyRight) // move cursor right
                moveCursorHorizontally(true);
            else if (keyCode == Fw::KeyLeft) // move cursor left
                moveCursorHorizontally(false);

            if (getProp(PropShiftNavigation))
                clearSelection();
            else {
                if (!hasSelection())
                    m_selectionReference = oldCursorPos;
                setSelection(m_selectionReference, m_cursorPos);
            }
            return true;
        }
        if (keyCode == Fw::KeyHome) { // move cursor to first character
            if (m_cursorPos != 0) {
                setSelection(m_cursorPos, 0);
                setCursorPos(0);
                return true;
            }
        } else if (keyCode == Fw::KeyEnd) { // move cursor to last character
            const int textLen = static_cast<int>(m_text32.size());
            if (m_cursorPos != textLen) {
                setSelection(m_cursorPos, textLen);
                setCursorPos(textLen);
                return true;
            }
        }
    }

    return false;
}

bool UITextEdit::onKeyText(const std::string_view keyText)
{
    // ctrl + backspace inserts a special ASCII character
    if (keyText.length() == 1 && keyText.front() == Fw::KeyDel) {
        return false;
    }

    if (getProp(PropEditable)) {
        appendText(keyText.data());
        return true;
    }
    return false;
}

bool UITextEdit::onMousePress(const Point& mousePos, const Fw::MouseButton button)
{
    if (UIWidget::onMousePress(mousePos, button))
        return true;

    if (button == Fw::MouseLeftButton) {
        const int pos = getTextPos(mousePos);
        if (pos >= 0) {
            setCursorPos(pos);

            if (getProp(PropSelectable)) {
                m_selectionReference = pos;
                setSelection(pos, pos);
            }
        }
#ifdef __EMSCRIPTEN__
        if (g_window.isVisible()) {
            MAIN_THREAD_ASYNC_EM_ASM({
                if (navigator && "virtualKeyboard" in navigator) {
                    document.getElementById("title-text").focus();
                    navigator.virtualKeyboard.show();
                }
            });
        }
#endif
        return true;
    }
    return false;
}

bool UITextEdit::onMouseRelease(const Point& mousePos, const Fw::MouseButton button)
{
    return UIWidget::onMouseRelease(mousePos, button);
}

bool UITextEdit::onMouseMove(const Point& mousePos, const Point& mouseMoved)
{
    if (UIWidget::onMouseMove(mousePos, mouseMoved))
        return true;

    if (getProp(PropSelectable) && isPressed()) {
        const int pos = getTextPos(mousePos);
        if (pos >= 0) {
            setSelection(m_selectionReference, pos);
            setCursorPos(pos);
        }
        return true;
    }
    return false;
}

bool UITextEdit::onDoubleClick(const Point& mousePos)
{
    if (UIWidget::onDoubleClick(mousePos))
        return true;
    if (getProp(PropSelectable) && !m_text32.empty()) {
        selectAll();
        return true;
    }
    return false;
}

void UITextEdit::onTextAreaUpdate(const Point& offset, const Size& visibleSize, const Size& totalSize)
{
    callLuaField("onTextAreaUpdate", offset, visibleSize, totalSize);
}

void UITextEdit::setPlaceholderFont(const std::string_view fontName)
{
    m_placeholderFont = g_fonts.getFont(fontName);
}