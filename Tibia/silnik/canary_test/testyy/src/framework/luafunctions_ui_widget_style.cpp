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

// Split from luafunctions_ui.cpp to reduce template instantiation pressure
// in a single translation unit (MSVC ICE C1001 mitigation).
// This file contains the second half of UIWidget bindings.

#include <framework/luaengine/luainterface.h>

#ifdef FRAMEWORK_GRAPHICS
#include "framework/ui/ui.h"
#endif

#if defined(_MSC_VER) && !defined(__clang__)
#pragma optimize("", off)
#endif

void registerLuaFunctions_UIWidgetStyle()
{
#ifdef FRAMEWORK_GRAPHICS
    g_lua.bindClassMemberFunction<UIWidget>("setX", &UIWidget::setX);
    g_lua.bindClassMemberFunction<UIWidget>("setY", &UIWidget::setY);
    g_lua.bindClassMemberFunction<UIWidget>("setWidth", &UIWidget::setWidth);
    g_lua.bindClassMemberFunction<UIWidget>("setHeight", &UIWidget::setHeight);
    g_lua.bindClassMemberFunction<UIWidget>("setSize", &UIWidget::setSize);
    g_lua.bindClassMemberFunction<UIWidget>("setMinWidth", &UIWidget::setMinWidth);
    g_lua.bindClassMemberFunction<UIWidget>("setMaxWidth", &UIWidget::setMaxWidth);
    g_lua.bindClassMemberFunction<UIWidget>("setMinHeight", &UIWidget::setMinHeight);
    g_lua.bindClassMemberFunction<UIWidget>("setMaxHeight", &UIWidget::setMaxHeight);
    g_lua.bindClassMemberFunction<UIWidget>("setMinSize", &UIWidget::setMinSize);
    g_lua.bindClassMemberFunction<UIWidget>("setMaxSize", &UIWidget::setMaxSize);
    g_lua.bindClassMemberFunction<UIWidget>("setPosition", &UIWidget::setPosition);
    g_lua.bindClassMemberFunction<UIWidget>("setColor", &UIWidget::setColor);
    g_lua.bindClassMemberFunction<UIWidget>("setBackgroundColor", &UIWidget::setBackgroundColor);
    g_lua.bindClassMemberFunction<UIWidget>("setBackgroundOffsetX", &UIWidget::setBackgroundOffsetX);
    g_lua.bindClassMemberFunction<UIWidget>("setBackgroundOffsetY", &UIWidget::setBackgroundOffsetY);
    g_lua.bindClassMemberFunction<UIWidget>("setBackgroundOffset", &UIWidget::setBackgroundOffset);
    g_lua.bindClassMemberFunction<UIWidget>("setBackgroundWidth", &UIWidget::setBackgroundWidth);
    g_lua.bindClassMemberFunction<UIWidget>("setBackgroundHeight", &UIWidget::setBackgroundHeight);
    g_lua.bindClassMemberFunction<UIWidget>("setBackgroundSize", &UIWidget::setBackgroundSize);
    g_lua.bindClassMemberFunction<UIWidget>("setBackgroundRect", &UIWidget::setBackgroundRect);
    g_lua.bindClassMemberFunction<UIWidget>("setIcon", &UIWidget::setIcon);
    g_lua.bindClassMemberFunction<UIWidget>("setIconColor", &UIWidget::setIconColor);
    g_lua.bindClassMemberFunction<UIWidget>("setIconOffsetX", &UIWidget::setIconOffsetX);
    g_lua.bindClassMemberFunction<UIWidget>("setIconOffsetY", &UIWidget::setIconOffsetY);
    g_lua.bindClassMemberFunction<UIWidget>("setIconOffset", &UIWidget::setIconOffset);
    g_lua.bindClassMemberFunction<UIWidget>("setIconWidth", &UIWidget::setIconWidth);
    g_lua.bindClassMemberFunction<UIWidget>("setIconHeight", &UIWidget::setIconHeight);
    g_lua.bindClassMemberFunction<UIWidget>("setIconSize", &UIWidget::setIconSize);
    g_lua.bindClassMemberFunction<UIWidget>("setIconRect", &UIWidget::setIconRect);
    g_lua.bindClassMemberFunction<UIWidget>("setIconClip", &UIWidget::setIconClip);
    g_lua.bindClassMemberFunction<UIWidget>("setIconAlign", &UIWidget::setIconAlign);
    g_lua.bindClassMemberFunction<UIWidget>("setBorderWidth", &UIWidget::setBorderWidth);
    g_lua.bindClassMemberFunction<UIWidget>("setBorderWidthTop", &UIWidget::setBorderWidthTop);
    g_lua.bindClassMemberFunction<UIWidget>("setBorderWidthRight", &UIWidget::setBorderWidthRight);
    g_lua.bindClassMemberFunction<UIWidget>("setBorderWidthBottom", &UIWidget::setBorderWidthBottom);
    g_lua.bindClassMemberFunction<UIWidget>("setBorderWidthLeft", &UIWidget::setBorderWidthLeft);
    g_lua.bindClassMemberFunction<UIWidget>("setBorderColor", &UIWidget::setBorderColor);
    g_lua.bindClassMemberFunction<UIWidget>("setBorderColorTop", &UIWidget::setBorderColorTop);
    g_lua.bindClassMemberFunction<UIWidget>("setBorderColorRight", &UIWidget::setBorderColorRight);
    g_lua.bindClassMemberFunction<UIWidget>("setBorderColorBottom", &UIWidget::setBorderColorBottom);
    g_lua.bindClassMemberFunction<UIWidget>("setBorderColorLeft", &UIWidget::setBorderColorLeft);
    g_lua.bindClassMemberFunction<UIWidget>("setMargin", &UIWidget::setMargin);
    g_lua.bindClassMemberFunction<UIWidget>("setMarginHorizontal", &UIWidget::setMarginHorizontal);
    g_lua.bindClassMemberFunction<UIWidget>("setMarginVertical", &UIWidget::setMarginVertical);
    g_lua.bindClassMemberFunction<UIWidget>("setMarginTop", &UIWidget::setMarginTop);
    g_lua.bindClassMemberFunction<UIWidget>("setMarginRight", &UIWidget::setMarginRight);
    g_lua.bindClassMemberFunction<UIWidget>("setMarginBottom", &UIWidget::setMarginBottom);
    g_lua.bindClassMemberFunction<UIWidget>("setMarginLeft", &UIWidget::setMarginLeft);
    g_lua.bindClassMemberFunction<UIWidget>("setPadding", &UIWidget::setPadding);
    g_lua.bindClassMemberFunction<UIWidget>("setPaddingHorizontal", &UIWidget::setPaddingHorizontal);
    g_lua.bindClassMemberFunction<UIWidget>("setPaddingVertical", &UIWidget::setPaddingVertical);
    g_lua.bindClassMemberFunction<UIWidget>("setPaddingTop", &UIWidget::setPaddingTop);
    g_lua.bindClassMemberFunction<UIWidget>("setPaddingRight", &UIWidget::setPaddingRight);
    g_lua.bindClassMemberFunction<UIWidget>("setPaddingBottom", &UIWidget::setPaddingBottom);
    g_lua.bindClassMemberFunction<UIWidget>("setPaddingLeft", &UIWidget::setPaddingLeft);
    g_lua.bindClassMemberFunction<UIWidget>("setOpacity", &UIWidget::setOpacity);
    g_lua.bindClassMemberFunction<UIWidget>("setRotation", &UIWidget::setRotation);
    g_lua.bindClassMemberFunction<UIWidget>("getX", &UIWidget::getX);
    g_lua.bindClassMemberFunction<UIWidget>("getY", &UIWidget::getY);
    g_lua.bindClassMemberFunction<UIWidget>("getPosition", &UIWidget::getPosition);
    g_lua.bindClassMemberFunction<UIWidget>("getCenter", &UIWidget::getCenter);
    g_lua.bindClassMemberFunction<UIWidget>("getWidth", &UIWidget::getWidth);
    g_lua.bindClassMemberFunction<UIWidget>("getHeight", &UIWidget::getHeight);
    g_lua.bindClassMemberFunction<UIWidget>("getSize", &UIWidget::getSize);
    g_lua.bindClassMemberFunction<UIWidget>("getRect", &UIWidget::getRect);
    g_lua.bindClassMemberFunction<UIWidget>("getMinWidth", &UIWidget::getMinWidth);
    g_lua.bindClassMemberFunction<UIWidget>("getMaxWidth", &UIWidget::getMaxWidth);
    g_lua.bindClassMemberFunction<UIWidget>("getMinHeight", &UIWidget::getMinHeight);
    g_lua.bindClassMemberFunction<UIWidget>("getMaxHeight", &UIWidget::getMaxHeight);
    g_lua.bindClassMemberFunction<UIWidget>("getMinSize", &UIWidget::getMinSize);
    g_lua.bindClassMemberFunction<UIWidget>("getMaxSize", &UIWidget::getMaxSize);
    g_lua.bindClassMemberFunction<UIWidget>("getColor", &UIWidget::getColor);
    g_lua.bindClassMemberFunction<UIWidget>("getBackgroundColor", &UIWidget::getBackgroundColor);
    g_lua.bindClassMemberFunction<UIWidget>("getBackgroundOffsetX", &UIWidget::getBackgroundOffsetX);
    g_lua.bindClassMemberFunction<UIWidget>("getBackgroundOffsetY", &UIWidget::getBackgroundOffsetY);
    g_lua.bindClassMemberFunction<UIWidget>("getBackgroundOffset", &UIWidget::getBackgroundOffset);
    g_lua.bindClassMemberFunction<UIWidget>("getBackgroundWidth", &UIWidget::getBackgroundWidth);
    g_lua.bindClassMemberFunction<UIWidget>("getBackgroundHeight", &UIWidget::getBackgroundHeight);
    g_lua.bindClassMemberFunction<UIWidget>("getBackgroundSize", &UIWidget::getBackgroundSize);
    g_lua.bindClassMemberFunction<UIWidget>("getBackgroundRect", &UIWidget::getBackgroundRect);
    g_lua.bindClassMemberFunction<UIWidget>("getIconColor", &UIWidget::getIconColor);
    g_lua.bindClassMemberFunction<UIWidget>("getIconOffsetX", &UIWidget::getIconOffsetX);
    g_lua.bindClassMemberFunction<UIWidget>("getIconOffsetY", &UIWidget::getIconOffsetY);
    g_lua.bindClassMemberFunction<UIWidget>("getIconOffset", &UIWidget::getIconOffset);
    g_lua.bindClassMemberFunction<UIWidget>("getIconWidth", &UIWidget::getIconWidth);
    g_lua.bindClassMemberFunction<UIWidget>("getIconHeight", &UIWidget::getIconHeight);
    g_lua.bindClassMemberFunction<UIWidget>("getIconSize", &UIWidget::getIconSize);
    g_lua.bindClassMemberFunction<UIWidget>("getIconRect", &UIWidget::getIconRect);
    g_lua.bindClassMemberFunction<UIWidget>("getIconClip", &UIWidget::getIconClip);
    g_lua.bindClassMemberFunction<UIWidget>("getIconAlign", &UIWidget::getIconAlign);
    g_lua.bindClassMemberFunction<UIWidget>("getBorderTopColor", &UIWidget::getBorderTopColor);
    g_lua.bindClassMemberFunction<UIWidget>("getBorderRightColor", &UIWidget::getBorderRightColor);
    g_lua.bindClassMemberFunction<UIWidget>("getBorderBottomColor", &UIWidget::getBorderBottomColor);
    g_lua.bindClassMemberFunction<UIWidget>("getBorderLeftColor", &UIWidget::getBorderLeftColor);
    g_lua.bindClassMemberFunction<UIWidget>("getBorderTopWidth", &UIWidget::getBorderTopWidth);
    g_lua.bindClassMemberFunction<UIWidget>("getBorderRightWidth", &UIWidget::getBorderRightWidth);
    g_lua.bindClassMemberFunction<UIWidget>("getBorderBottomWidth", &UIWidget::getBorderBottomWidth);
    g_lua.bindClassMemberFunction<UIWidget>("getBorderLeftWidth", &UIWidget::getBorderLeftWidth);
    g_lua.bindClassMemberFunction<UIWidget>("getImageSource", &UIWidget::getImageSource);
    g_lua.bindClassMemberFunction<UIWidget>("getMarginTop", &UIWidget::getMarginTop);
    g_lua.bindClassMemberFunction<UIWidget>("getMarginRight", &UIWidget::getMarginRight);
    g_lua.bindClassMemberFunction<UIWidget>("getMarginBottom", &UIWidget::getMarginBottom);
    g_lua.bindClassMemberFunction<UIWidget>("getMarginLeft", &UIWidget::getMarginLeft);
    g_lua.bindClassMemberFunction<UIWidget>("getPaddingTop", &UIWidget::getPaddingTop);
    g_lua.bindClassMemberFunction<UIWidget>("getPaddingRight", &UIWidget::getPaddingRight);
    g_lua.bindClassMemberFunction<UIWidget>("getPaddingBottom", &UIWidget::getPaddingBottom);
    g_lua.bindClassMemberFunction<UIWidget>("getPaddingLeft", &UIWidget::getPaddingLeft);
    g_lua.bindClassMemberFunction<UIWidget>("getOpacity", &UIWidget::getOpacity);
    g_lua.bindClassMemberFunction<UIWidget>("getRotation", &UIWidget::getRotation);
    g_lua.bindClassMemberFunction<UIWidget>("setImageSource", &UIWidget::setImageSource);
    g_lua.bindClassMemberFunction<UIWidget>("setImageClip", &UIWidget::setImageClip);
    g_lua.bindClassMemberFunction<UIWidget>("setImageOffsetX", &UIWidget::setImageOffsetX);
    g_lua.bindClassMemberFunction<UIWidget>("setImageOffsetY", &UIWidget::setImageOffsetY);
    g_lua.bindClassMemberFunction<UIWidget>("setImageOffset", &UIWidget::setImageOffset);
    g_lua.bindClassMemberFunction<UIWidget>("setImageWidth", &UIWidget::setImageWidth);
    g_lua.bindClassMemberFunction<UIWidget>("setImageHeight", &UIWidget::setImageHeight);
    g_lua.bindClassMemberFunction<UIWidget>("setImageSize", &UIWidget::setImageSize);
    g_lua.bindClassMemberFunction<UIWidget>("setImageRect", &UIWidget::setImageRect);
    g_lua.bindClassMemberFunction<UIWidget>("setImageColor", &UIWidget::setImageColor);
    g_lua.bindClassMemberFunction<UIWidget>("setImageFixedRatio", &UIWidget::setImageFixedRatio);
    g_lua.bindClassMemberFunction<UIWidget>("setImageRepeated", &UIWidget::setImageRepeated);
    g_lua.bindClassMemberFunction<UIWidget>("setImageSmooth", &UIWidget::setImageSmooth);
    g_lua.bindClassMemberFunction<UIWidget>("setImageAutoResize", &UIWidget::setImageAutoResize);
    g_lua.bindClassMemberFunction<UIWidget>("setImageBorderTop", &UIWidget::setImageBorderTop);
    g_lua.bindClassMemberFunction<UIWidget>("setImageBorderRight", &UIWidget::setImageBorderRight);
    g_lua.bindClassMemberFunction<UIWidget>("setImageBorderBottom", &UIWidget::setImageBorderBottom);
    g_lua.bindClassMemberFunction<UIWidget>("setImageBorderLeft", &UIWidget::setImageBorderLeft);
    g_lua.bindClassMemberFunction<UIWidget>("setImageBorder", &UIWidget::setImageBorder);
    g_lua.bindClassMemberFunction<UIWidget>("getImageClip", &UIWidget::getImageClip);
    g_lua.bindClassMemberFunction<UIWidget>("getImageOffsetX", &UIWidget::getImageOffsetX);
    g_lua.bindClassMemberFunction<UIWidget>("getImageOffsetY", &UIWidget::getImageOffsetY);
    g_lua.bindClassMemberFunction<UIWidget>("getImageOffset", &UIWidget::getImageOffset);
    g_lua.bindClassMemberFunction<UIWidget>("getImageWidth", &UIWidget::getImageWidth);
    g_lua.bindClassMemberFunction<UIWidget>("getImageHeight", &UIWidget::getImageHeight);
    g_lua.bindClassMemberFunction<UIWidget>("getImageSize", &UIWidget::getImageSize);
    g_lua.bindClassMemberFunction<UIWidget>("getImageRect", &UIWidget::getImageRect);
    g_lua.bindClassMemberFunction<UIWidget>("getImageColor", &UIWidget::getImageColor);
    g_lua.bindClassMemberFunction<UIWidget>("isImageFixedRatio", &UIWidget::isImageFixedRatio);
    g_lua.bindClassMemberFunction<UIWidget>("isImageSmooth", &UIWidget::isImageSmooth);
    g_lua.bindClassMemberFunction<UIWidget>("isImageAutoResize", &UIWidget::isImageAutoResize);
    g_lua.bindClassMemberFunction<UIWidget>("getImageBorderTop", &UIWidget::getImageBorderTop);
    g_lua.bindClassMemberFunction<UIWidget>("getImageBorderRight", &UIWidget::getImageBorderRight);
    g_lua.bindClassMemberFunction<UIWidget>("getImageBorderBottom", &UIWidget::getImageBorderBottom);
    g_lua.bindClassMemberFunction<UIWidget>("getImageBorderLeft", &UIWidget::getImageBorderLeft);
    g_lua.bindClassMemberFunction<UIWidget>("getImageTextureWidth", &UIWidget::getImageTextureWidth);
    g_lua.bindClassMemberFunction<UIWidget>("getImageTextureHeight", &UIWidget::getImageTextureHeight);
    g_lua.bindClassMemberFunction<UIWidget>("resizeToText", &UIWidget::resizeToText);
    g_lua.bindClassMemberFunction<UIWidget>("clearText", &UIWidget::clearText);
    g_lua.bindClassMemberFunction<UIWidget>("setText", &UIWidget::setText);
    g_lua.bindClassMemberFunction<UIWidget>("setColoredText", &UIWidget::setColoredText);
    g_lua.bindClassMemberFunction<UIWidget>("setTextAlign", &UIWidget::setTextAlign);
    g_lua.bindClassMemberFunction<UIWidget>("setTextOffset", &UIWidget::setTextOffset);
    g_lua.bindClassMemberFunction<UIWidget>("setTextWrap", &UIWidget::setTextWrap);
    g_lua.bindClassMemberFunction<UIWidget>("setTextAutoResize", &UIWidget::setTextAutoResize);
    g_lua.bindClassMemberFunction<UIWidget>("setTextVerticalAutoResize", &UIWidget::setTextVerticalAutoResize);
    g_lua.bindClassMemberFunction<UIWidget>("setTextHorizontalAutoResize", &UIWidget::setTextHorizontalAutoResize);
    g_lua.bindClassMemberFunction<UIWidget>("setFont", &UIWidget::setFont);
    g_lua.bindClassMemberFunction<UIWidget>("setFontScale", &UIWidget::setFontScale);
    g_lua.bindClassMemberFunction<UIWidget>("setShader", &UIWidget::setShader);
    g_lua.bindClassMemberFunction<UIWidget>("getText", &UIWidget::getText);
    g_lua.bindClassMemberFunction<UIWidget>("getDrawText", &UIWidget::getDrawText);
    g_lua.bindClassMemberFunction<UIWidget>("getTextAlign", &UIWidget::getTextAlign);
    g_lua.bindClassMemberFunction<UIWidget>("getTextOffset", &UIWidget::getTextOffset);
    g_lua.bindClassMemberFunction<UIWidget>("getFont", &UIWidget::getFont);
    g_lua.bindClassMemberFunction<UIWidget>("getTextSize", &UIWidget::getTextSize);
    g_lua.bindClassMemberFunction<UIWidget>("hasShader", &UIWidget::hasShader);
    g_lua.bindClassMemberFunction<UIWidget>("disableUpdateTemporarily", &UIWidget::disableUpdateTemporarily);
    g_lua.bindClassMemberFunction<UIWidget>("getNextWidget", &UIWidget::getNextWidget);
    g_lua.bindClassMemberFunction<UIWidget>("getPrevWidget", &UIWidget::getPrevWidget);
    g_lua.bindClassMemberFunction<UIWidget>("hasAnchoredLayout", &UIWidget::hasAnchoredLayout);
    g_lua.bindClassMemberFunction<UIWidget>("setOnHtml", &UIWidget::setOnHtml);
    g_lua.bindClassMemberFunction<UIWidget>("isOnHtml", &UIWidget::isOnHtml);

    g_lua.bindClassMemberFunction<UIWidget>("setBackgroundDrawOrder", &UIWidget::setBackgroundDrawOrder);
    g_lua.bindClassMemberFunction<UIWidget>("setImageDrawOrder", &UIWidget::setImageDrawOrder);
    g_lua.bindClassMemberFunction<UIWidget>("setIconDrawOrder", &UIWidget::setIconDrawOrder);
    g_lua.bindClassMemberFunction<UIWidget>("setTextDrawOrder", &UIWidget::setTextDrawOrder);
    g_lua.bindClassMemberFunction<UIWidget>("setBorderDrawOrder", &UIWidget::setBorderDrawOrder);
#endif
}

#if defined(_MSC_VER) && !defined(__clang__)
#pragma optimize("", on)
#endif
