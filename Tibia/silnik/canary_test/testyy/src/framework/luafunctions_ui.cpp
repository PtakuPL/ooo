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

 // Split from luafunctions.cpp to avoid MSVC ICE C1001 caused by too many
 // template instantiations (luabinder.h) in a single translation unit.
 // This file contains UI widget, layout, text edit, QR code, shader,
 // particle, network, and sound Lua bindings.

#include <framework/luaengine/luainterface.h>

#ifdef FRAMEWORK_GRAPHICS
#include "framework/graphics/fontmanager.h"
#include "framework/graphics/particleeffect.h"
#include "framework/graphics/particlemanager.h"
#include "framework/graphics/shadermanager.h"
#include "framework/ui/ui.h"
#endif

#ifdef FRAMEWORK_SOUND
#include <framework/sound/combinedsoundsource.h>
#include <framework/sound/soundchannel.h>
#include <framework/sound/soundeffect.h>
#include <framework/sound/soundmanager.h>
#include <framework/sound/soundsource.h>
#include <framework/sound/streamsoundsource.h>
#endif

#ifdef FRAMEWORK_NET
#include <framework/net/protocol.h>
#include <framework/net/server.h>
#endif

#include "net/inputmessage.h"
#include "net/outputmessage.h"

void registerLuaFunctions_UI()
{
#ifdef FRAMEWORK_GRAPHICS
    // UIWidget
    g_lua.registerClass<UIWidget>();
    g_lua.bindClassStaticFunction<UIWidget>("create", [] { return std::make_shared<UIWidget>(); });
    g_lua.bindClassMemberFunction<UIWidget>("addChild", &UIWidget::addChild);
    g_lua.bindClassMemberFunction<UIWidget>("insertChild", &UIWidget::insertChild);
    g_lua.bindClassMemberFunction<UIWidget>("removeChild", &UIWidget::removeChild);
    g_lua.bindClassMemberFunction<UIWidget>("focusChild", &UIWidget::focusChild);
    g_lua.bindClassMemberFunction<UIWidget>("focusNextChild", &UIWidget::focusNextChild);
    g_lua.bindClassMemberFunction<UIWidget>("focusPreviousChild", &UIWidget::focusPreviousChild);
    g_lua.bindClassMemberFunction<UIWidget>("lowerChild", &UIWidget::lowerChild);
    g_lua.bindClassMemberFunction<UIWidget>("raiseChild", &UIWidget::raiseChild);
    g_lua.bindClassMemberFunction<UIWidget>("moveChildToIndex", &UIWidget::moveChildToIndex);
    g_lua.bindClassMemberFunction<UIWidget>("reorderChildren", &UIWidget::reorderChildren);
    g_lua.bindClassMemberFunction<UIWidget>("lockChild", &UIWidget::lockChild);
    g_lua.bindClassMemberFunction<UIWidget>("unlockChild", &UIWidget::unlockChild);
    g_lua.bindClassMemberFunction<UIWidget>("mergeStyle", &UIWidget::mergeStyle);
    g_lua.bindClassMemberFunction<UIWidget>("applyStyle", &UIWidget::applyStyle);
    g_lua.bindClassMemberFunction<UIWidget>("addAnchor", &UIWidget::addAnchor);
    g_lua.bindClassMemberFunction<UIWidget>("removeAnchor", &UIWidget::removeAnchor);
    g_lua.bindClassMemberFunction<UIWidget>("fill", &UIWidget::fill);
    g_lua.bindClassMemberFunction<UIWidget>("centerIn", &UIWidget::centerIn);
    g_lua.bindClassMemberFunction<UIWidget>("breakAnchors", &UIWidget::breakAnchors);
    g_lua.bindClassMemberFunction<UIWidget>("updateParentLayout", &UIWidget::updateParentLayout);
    g_lua.bindClassMemberFunction<UIWidget>("updateLayout", &UIWidget::updateLayout);
    g_lua.bindClassMemberFunction<UIWidget>("lock", &UIWidget::lock);
    g_lua.bindClassMemberFunction<UIWidget>("unlock", &UIWidget::unlock);
    g_lua.bindClassMemberFunction<UIWidget>("focus", &UIWidget::focus);
    g_lua.bindClassMemberFunction<UIWidget>("lower", &UIWidget::lower);
    g_lua.bindClassMemberFunction<UIWidget>("raise", &UIWidget::raise);
    g_lua.bindClassMemberFunction<UIWidget>("grabMouse", &UIWidget::grabMouse);
    g_lua.bindClassMemberFunction<UIWidget>("ungrabMouse", &UIWidget::ungrabMouse);
    g_lua.bindClassMemberFunction<UIWidget>("grabKeyboard", &UIWidget::grabKeyboard);
    g_lua.bindClassMemberFunction<UIWidget>("ungrabKeyboard", &UIWidget::ungrabKeyboard);
    g_lua.bindClassMemberFunction<UIWidget>("bindRectToParent", &UIWidget::bindRectToParent);
    g_lua.bindClassMemberFunction<UIWidget>("destroy", &UIWidget::destroy);
    g_lua.bindClassMemberFunction<UIWidget>("destroyChildren", &UIWidget::destroyChildren);
    g_lua.bindClassMemberFunction<UIWidget>("removeChildren", &UIWidget::removeChildren);
    g_lua.bindClassMemberFunction<UIWidget>("hideChildren", &UIWidget::hideChildren);
    g_lua.bindClassMemberFunction<UIWidget>("showChildren", &UIWidget::showChildren);
    g_lua.bindClassMemberFunction<UIWidget>("setId", &UIWidget::setId);
    g_lua.bindClassMemberFunction<UIWidget>("setParent", &UIWidget::setParent);
    g_lua.bindClassMemberFunction<UIWidget>("setLayout", &UIWidget::setLayout);
    g_lua.bindClassMemberFunction<UIWidget>("setRect", &UIWidget::setRect);
    g_lua.bindClassMemberFunction<UIWidget>("setStyle", &UIWidget::setStyle);
    g_lua.bindClassMemberFunction<UIWidget>("setStyleFromNode", &UIWidget::setStyleFromNode);
    g_lua.bindClassMemberFunction<UIWidget>("setEnabled", &UIWidget::setEnabled);
    g_lua.bindClassMemberFunction<UIWidget>("setVisible", &UIWidget::setVisible);
    g_lua.bindClassMemberFunction<UIWidget>("setOn", &UIWidget::setOn);
    g_lua.bindClassMemberFunction<UIWidget>("setChecked", &UIWidget::setChecked);
    g_lua.bindClassMemberFunction<UIWidget>("setFocusable", &UIWidget::setFocusable);
    g_lua.bindClassMemberFunction<UIWidget>("setPhantom", &UIWidget::setPhantom);
    g_lua.bindClassMemberFunction<UIWidget>("setDraggable", &UIWidget::setDraggable);
    g_lua.bindClassMemberFunction<UIWidget>("setFixedSize", &UIWidget::setFixedSize);
    g_lua.bindClassMemberFunction<UIWidget>("setAutoFitParent", &UIWidget::setAutoFitParent);
    g_lua.bindClassMemberFunction<UIWidget>("setAutoFitParentWidth", &UIWidget::setAutoFitParentWidth);
    g_lua.bindClassMemberFunction<UIWidget>("setAutoFitParentHeight", &UIWidget::setAutoFitParentHeight);
    g_lua.bindClassMemberFunction<UIWidget>("isAutoFitParent", &UIWidget::isAutoFitParent);
    g_lua.bindClassMemberFunction<UIWidget>("setClipping", &UIWidget::setClipping);
    g_lua.bindClassMemberFunction<UIWidget>("setLastFocusReason", &UIWidget::setLastFocusReason);
    g_lua.bindClassMemberFunction<UIWidget>("setAutoFocusPolicy", &UIWidget::setAutoFocusPolicy);
    g_lua.bindClassMemberFunction<UIWidget>("setAutoRepeatDelay", &UIWidget::setAutoRepeatDelay);
    g_lua.bindClassMemberFunction<UIWidget>("setVirtualOffset", &UIWidget::setVirtualOffset);
    g_lua.bindClassMemberFunction<UIWidget>("isVisible", &UIWidget::isVisible);
    g_lua.bindClassMemberFunction<UIWidget>("isChildLocked", &UIWidget::isChildLocked);
    g_lua.bindClassMemberFunction<UIWidget>("hasChild", &UIWidget::hasChild);
    g_lua.bindClassMemberFunction<UIWidget>("getChildIndex", &UIWidget::getChildIndex);
    g_lua.bindClassMemberFunction<UIWidget>("getMarginRect", &UIWidget::getMarginRect);
    g_lua.bindClassMemberFunction<UIWidget>("getPaddingRect", &UIWidget::getPaddingRect);
    g_lua.bindClassMemberFunction<UIWidget>("getChildrenRect", &UIWidget::getChildrenRect);
    g_lua.bindClassMemberFunction<UIWidget>("getAnchoredLayout", &UIWidget::getAnchoredLayout);
    g_lua.bindClassMemberFunction<UIWidget>("getAnchors", &UIWidget::getAnchors);
    g_lua.bindClassMemberFunction<UIWidget>("getAnchorType", &UIWidget::getAnchorType);
    g_lua.bindClassMemberFunction<UIWidget>("getRootParent", &UIWidget::getRootParent);
    g_lua.bindClassMemberFunction<UIWidget>("getChildAfter", &UIWidget::getChildAfter);
    g_lua.bindClassMemberFunction<UIWidget>("getChildBefore", &UIWidget::getChildBefore);
    g_lua.bindClassMemberFunction<UIWidget>("getChildById", &UIWidget::getChildById);
    g_lua.bindClassMemberFunction<UIWidget>("getChildByPos", &UIWidget::getChildByPos);
    g_lua.bindClassMemberFunction<UIWidget>("getChildByIndex", &UIWidget::getChildByIndex);
    g_lua.bindClassMemberFunction<UIWidget>("getChildByState", &UIWidget::getChildByState);
    g_lua.bindClassMemberFunction<UIWidget>("getChildByStyleName", &UIWidget::getChildByStyleName);
    g_lua.bindClassMemberFunction<UIWidget>("recursiveGetChildById", &UIWidget::recursiveGetChildById);
    g_lua.bindClassMemberFunction<UIWidget>("recursiveGetChildByPos", &UIWidget::recursiveGetChildByPos);
    g_lua.bindClassMemberFunction<UIWidget>("recursiveGetChildByState", &UIWidget::recursiveGetChildByState);
    g_lua.bindClassMemberFunction<UIWidget>("recursiveGetChildren", &UIWidget::recursiveGetChildren);
    g_lua.bindClassMemberFunction<UIWidget>("recursiveGetChildrenByPos", &UIWidget::recursiveGetChildrenByPos);
    g_lua.bindClassMemberFunction<UIWidget>("recursiveGetChildrenByMarginPos", &UIWidget::recursiveGetChildrenByMarginPos);
    g_lua.bindClassMemberFunction<UIWidget>("recursiveGetChildrenByState", &UIWidget::recursiveGetChildrenByState);
    g_lua.bindClassMemberFunction<UIWidget>("recursiveGetChildrenByStyleName", &UIWidget::recursiveGetChildrenByStyleName);
    g_lua.bindClassMemberFunction<UIWidget>("backwardsGetWidgetById", &UIWidget::backwardsGetWidgetById);
    g_lua.bindClassMemberFunction<UIWidget>("resize", &UIWidget::resize);
    g_lua.bindClassMemberFunction<UIWidget>("move", &UIWidget::move);
    g_lua.bindClassMemberFunction<UIWidget>("rotate", &UIWidget::rotate);
    g_lua.bindClassMemberFunction<UIWidget>("hide", &UIWidget::hide);
    g_lua.bindClassMemberFunction<UIWidget>("show", &UIWidget::show);
    g_lua.bindClassMemberFunction<UIWidget>("disable", &UIWidget::disable);
    g_lua.bindClassMemberFunction<UIWidget>("enable", &UIWidget::enable);
    g_lua.bindClassMemberFunction<UIWidget>("isActive", &UIWidget::isActive);
    g_lua.bindClassMemberFunction<UIWidget>("isEnabled", &UIWidget::isEnabled);
    g_lua.bindClassMemberFunction<UIWidget>("isDisabled", &UIWidget::isDisabled);
    g_lua.bindClassMemberFunction<UIWidget>("isFocused", &UIWidget::isFocused);
    g_lua.bindClassMemberFunction<UIWidget>("isHovered", &UIWidget::isHovered);
    g_lua.bindClassMemberFunction<UIWidget>("isChildHovered", &UIWidget::isChildHovered);
    g_lua.bindClassMemberFunction<UIWidget>("isPressed", &UIWidget::isPressed);
    g_lua.bindClassMemberFunction<UIWidget>("isFirst", &UIWidget::isFirst);
    g_lua.bindClassMemberFunction<UIWidget>("isMiddle", &UIWidget::isMiddle);
    g_lua.bindClassMemberFunction<UIWidget>("isLast", &UIWidget::isLast);
    g_lua.bindClassMemberFunction<UIWidget>("isAlternate", &UIWidget::isAlternate);
    g_lua.bindClassMemberFunction<UIWidget>("isChecked", &UIWidget::isChecked);
    g_lua.bindClassMemberFunction<UIWidget>("isOn", &UIWidget::isOn);
    g_lua.bindClassMemberFunction<UIWidget>("isDragging", &UIWidget::isDragging);
    g_lua.bindClassMemberFunction<UIWidget>("isHidden", &UIWidget::isHidden);
    g_lua.bindClassMemberFunction<UIWidget>("isExplicitlyEnabled", &UIWidget::isExplicitlyEnabled);
    g_lua.bindClassMemberFunction<UIWidget>("isExplicitlyVisible", &UIWidget::isExplicitlyVisible);
    g_lua.bindClassMemberFunction<UIWidget>("isFocusable", &UIWidget::isFocusable);
    g_lua.bindClassMemberFunction<UIWidget>("isPhantom", &UIWidget::isPhantom);
    g_lua.bindClassMemberFunction<UIWidget>("isDraggable", &UIWidget::isDraggable);
    g_lua.bindClassMemberFunction<UIWidget>("isFixedSize", &UIWidget::isFixedSize);
    g_lua.bindClassMemberFunction<UIWidget>("isClipping", &UIWidget::isClipping);
    g_lua.bindClassMemberFunction<UIWidget>("isDestroyed", &UIWidget::isDestroyed);
    g_lua.bindClassMemberFunction<UIWidget>("isFirstOnStyle", &UIWidget::isFirstOnStyle);
    g_lua.bindClassMemberFunction<UIWidget>("isTextWrap", &UIWidget::isTextWrap);
    g_lua.bindClassMemberFunction<UIWidget>("hasChildren", &UIWidget::hasChildren);
    g_lua.bindClassMemberFunction<UIWidget>("containsMarginPoint", &UIWidget::containsMarginPoint);
    g_lua.bindClassMemberFunction<UIWidget>("containsPaddingPoint", &UIWidget::containsPaddingPoint);
    g_lua.bindClassMemberFunction<UIWidget>("containsPoint", &UIWidget::containsPoint);
    g_lua.bindClassMemberFunction<UIWidget>("intersects", &UIWidget::intersects);
    g_lua.bindClassMemberFunction<UIWidget>("intersectsMargin", &UIWidget::intersectsMargin);
    g_lua.bindClassMemberFunction<UIWidget>("intersectsPadding", &UIWidget::intersectsPadding);
    g_lua.bindClassMemberFunction<UIWidget>("getId", &UIWidget::getId);
    g_lua.bindClassMemberFunction<UIWidget>("getSource", &UIWidget::getSource);
    g_lua.bindClassMemberFunction<UIWidget>("getParent", &UIWidget::getParent);
    g_lua.bindClassMemberFunction<UIWidget>("getFocusedChild", &UIWidget::getFocusedChild);
    g_lua.bindClassMemberFunction<UIWidget>("getHoveredChild", &UIWidget::getHoveredChild);
    g_lua.bindClassMemberFunction<UIWidget>("getChildren", &UIWidget::getChildren);
    g_lua.bindClassMemberFunction<UIWidget>("getFirstChild", &UIWidget::getFirstChild);
    g_lua.bindClassMemberFunction<UIWidget>("getLastChild", &UIWidget::getLastChild);
    g_lua.bindClassMemberFunction<UIWidget>("getLayout", &UIWidget::getLayout);
    g_lua.bindClassMemberFunction<UIWidget>("getStyle", &UIWidget::getStyle);
    g_lua.bindClassMemberFunction<UIWidget>("getChildCount", &UIWidget::getChildCount);
    g_lua.bindClassMemberFunction<UIWidget>("getLastFocusReason", &UIWidget::getLastFocusReason);
    g_lua.bindClassMemberFunction<UIWidget>("getAutoFocusPolicy", &UIWidget::getAutoFocusPolicy);
    g_lua.bindClassMemberFunction<UIWidget>("getAutoRepeatDelay", &UIWidget::getAutoRepeatDelay);
    g_lua.bindClassMemberFunction<UIWidget>("getVirtualOffset", &UIWidget::getVirtualOffset);
    g_lua.bindClassMemberFunction<UIWidget>("getStyleName", &UIWidget::getStyleName);
    g_lua.bindClassMemberFunction<UIWidget>("getLastClickPosition", &UIWidget::getLastClickPosition);
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

    // UILayout
    g_lua.registerClass<UILayout>();
    g_lua.bindClassMemberFunction<UILayout>("update", &UILayout::update);
    g_lua.bindClassMemberFunction<UILayout>("updateLater", &UILayout::updateLater);
    g_lua.bindClassMemberFunction<UILayout>("applyStyle", &UILayout::applyStyle);
    g_lua.bindClassMemberFunction<UILayout>("addWidget", &UILayout::addWidget);
    g_lua.bindClassMemberFunction<UILayout>("removeWidget", &UILayout::removeWidget);
    g_lua.bindClassMemberFunction<UILayout>("disableUpdates", &UILayout::disableUpdates);
    g_lua.bindClassMemberFunction<UILayout>("enableUpdates", &UILayout::enableUpdates);
    g_lua.bindClassMemberFunction<UILayout>("setParent", &UILayout::setParent);
    g_lua.bindClassMemberFunction<UILayout>("getParentWidget", &UILayout::getParentWidget);
    g_lua.bindClassMemberFunction<UILayout>("isUpdateDisabled", &UILayout::isUpdateDisabled);
    g_lua.bindClassMemberFunction<UILayout>("isUpdating", &UILayout::isUpdating);
    g_lua.bindClassMemberFunction<UILayout>("isUIAnchorLayout", &UILayout::isUIAnchorLayout);
    g_lua.bindClassMemberFunction<UILayout>("isUIBoxLayout", &UILayout::isUIBoxLayout);
    g_lua.bindClassMemberFunction<UILayout>("isUIHorizontalLayout", &UILayout::isUIHorizontalLayout);
    g_lua.bindClassMemberFunction<UILayout>("isUIVerticalLayout", &UILayout::isUIVerticalLayout);
    g_lua.bindClassMemberFunction<UILayout>("isUIGridLayout", &UILayout::isUIGridLayout);

    // UIBoxLayout
    g_lua.registerClass<UIBoxLayout, UILayout>();
    g_lua.bindClassMemberFunction<UIBoxLayout>("setSpacing", &UIBoxLayout::setSpacing);
    g_lua.bindClassMemberFunction<UIBoxLayout>("setFitChildren", &UIBoxLayout::setFitChildren);

    // UIVerticalLayout
    g_lua.registerClass<UIVerticalLayout, UIBoxLayout>();
    g_lua.bindClassStaticFunction<UIVerticalLayout>("create", [](const UIWidgetPtr& parent) { return std::make_shared<UIVerticalLayout>(parent); });
    g_lua.bindClassMemberFunction<UIVerticalLayout>("setAlignBottom", &UIVerticalLayout::setAlignBottom);
    g_lua.bindClassMemberFunction<UIVerticalLayout>("isAlignBottom", &UIVerticalLayout::isAlignBottom);

    // UIHorizontalLayout
    g_lua.registerClass<UIHorizontalLayout, UIBoxLayout>();
    g_lua.bindClassStaticFunction<UIHorizontalLayout>("create", [](const UIWidgetPtr& parent) { return std::make_shared<UIHorizontalLayout>(parent); });
    g_lua.bindClassMemberFunction<UIHorizontalLayout>("setAlignRight", &UIHorizontalLayout::setAlignRight);

    // UIGridLayout
    g_lua.registerClass<UIGridLayout, UILayout>();
    g_lua.bindClassStaticFunction<UIGridLayout>("create", [](const UIWidgetPtr& parent) { return std::make_shared<UIGridLayout>(parent); });
    g_lua.bindClassMemberFunction<UIGridLayout>("setCellSize", &UIGridLayout::setCellSize);
    g_lua.bindClassMemberFunction<UIGridLayout>("setCellWidth", &UIGridLayout::setCellWidth);
    g_lua.bindClassMemberFunction<UIGridLayout>("setCellHeight", &UIGridLayout::setCellHeight);
    g_lua.bindClassMemberFunction<UIGridLayout>("setCellSpacing", &UIGridLayout::setCellSpacing);
    g_lua.bindClassMemberFunction<UIGridLayout>("setFlow", &UIGridLayout::setFlow);
    g_lua.bindClassMemberFunction<UIGridLayout>("setNumColumns", &UIGridLayout::setNumColumns);
    g_lua.bindClassMemberFunction<UIGridLayout>("setNumLines", &UIGridLayout::setNumLines);
    g_lua.bindClassMemberFunction<UIGridLayout>("getNumColumns", &UIGridLayout::getNumColumns);
    g_lua.bindClassMemberFunction<UIGridLayout>("getNumLines", &UIGridLayout::getNumLines);
    g_lua.bindClassMemberFunction<UIGridLayout>("getCellSize", &UIGridLayout::getCellSize);
    g_lua.bindClassMemberFunction<UIGridLayout>("getCellSpacing", &UIGridLayout::getCellSpacing);
    g_lua.bindClassMemberFunction<UIGridLayout>("isUIGridLayout", &UIGridLayout::isUIGridLayout);

    // UIAnchorLayout
    g_lua.registerClass<UIAnchorLayout, UILayout>();
    g_lua.bindClassStaticFunction<UIAnchorLayout>("create", [](const UIWidgetPtr& parent) { return std::make_shared<UIAnchorLayout>(parent); });
    g_lua.bindClassMemberFunction<UIAnchorLayout>("removeAnchors", &UIAnchorLayout::removeAnchors);
    g_lua.bindClassMemberFunction<UIAnchorLayout>("centerIn", &UIAnchorLayout::centerIn);
    g_lua.bindClassMemberFunction<UIAnchorLayout>("fill", &UIAnchorLayout::fill);

    // UITextEdit
    g_lua.registerClass<UITextEdit, UIWidget>();
    g_lua.bindClassStaticFunction<UITextEdit>("create", [] { return std::make_shared<UITextEdit>(); });
    g_lua.bindClassMemberFunction<UITextEdit>("setCursorPos", &UITextEdit::setCursorPos);
    g_lua.bindClassMemberFunction<UITextEdit>("setSelection", &UITextEdit::setSelection);
    g_lua.bindClassMemberFunction<UITextEdit>("setCursorVisible", &UITextEdit::setCursorVisible);
    g_lua.bindClassMemberFunction<UITextEdit>("setChangeCursorImage", &UITextEdit::setChangeCursorImage);
    g_lua.bindClassMemberFunction<UITextEdit>("setTextHidden", &UITextEdit::setTextHidden);
    g_lua.bindClassMemberFunction<UITextEdit>("setValidCharacters", &UITextEdit::setValidCharacters);
    g_lua.bindClassMemberFunction<UITextEdit>("setShiftNavigation", &UITextEdit::setShiftNavigation);
    g_lua.bindClassMemberFunction<UITextEdit>("setMultiline", &UITextEdit::setMultiline);
    g_lua.bindClassMemberFunction<UITextEdit>("setEditable", &UITextEdit::setEditable);
    g_lua.bindClassMemberFunction<UITextEdit>("setSelectable", &UITextEdit::setSelectable);
    g_lua.bindClassMemberFunction<UITextEdit>("setSelectionColor", &UITextEdit::setSelectionColor);
    g_lua.bindClassMemberFunction<UITextEdit>("setSelectionBackgroundColor", &UITextEdit::setSelectionBackgroundColor);
    g_lua.bindClassMemberFunction<UITextEdit>("setMaxLength", &UITextEdit::setMaxLength);
    g_lua.bindClassMemberFunction<UITextEdit>("setTextVirtualOffset", &UITextEdit::setTextVirtualOffset);
    g_lua.bindClassMemberFunction<UITextEdit>("getTextVirtualOffset", &UITextEdit::getTextVirtualOffset);
    g_lua.bindClassMemberFunction<UITextEdit>("getTextVirtualSize", &UITextEdit::getTextVirtualSize);
    g_lua.bindClassMemberFunction<UITextEdit>("getTextTotalSize", &UITextEdit::getTextTotalSize);
    g_lua.bindClassMemberFunction<UITextEdit>("moveCursorHorizontally", &UITextEdit::moveCursorHorizontally);
    g_lua.bindClassMemberFunction<UITextEdit>("moveCursorVertically", &UITextEdit::moveCursorVertically);
    g_lua.bindClassMemberFunction<UITextEdit>("appendText", &UITextEdit::appendText);
    g_lua.bindClassMemberFunction<UITextEdit>("wrapText", &UITextEdit::wrapText);
    g_lua.bindClassMemberFunction<UITextEdit>("removeCharacter", &UITextEdit::removeCharacter);
    g_lua.bindClassMemberFunction<UITextEdit>("blinkCursor", &UITextEdit::blinkCursor);
    g_lua.bindClassMemberFunction<UITextEdit>("del", &UITextEdit::del);
    g_lua.bindClassMemberFunction<UITextEdit>("paste", &UITextEdit::paste);
    g_lua.bindClassMemberFunction<UITextEdit>("copy", &UITextEdit::copy);
    g_lua.bindClassMemberFunction<UITextEdit>("cut", &UITextEdit::cut);
    g_lua.bindClassMemberFunction<UITextEdit>("selectAll", &UITextEdit::selectAll);
    g_lua.bindClassMemberFunction<UITextEdit>("clearSelection", &UITextEdit::clearSelection);
    g_lua.bindClassMemberFunction<UITextEdit>("getDisplayedText", &UITextEdit::getDisplayedText);
    g_lua.bindClassMemberFunction<UITextEdit>("getSelection", &UITextEdit::getSelection);
    g_lua.bindClassMemberFunction<UITextEdit>("getTextPos", &UITextEdit::getTextPos);
    g_lua.bindClassMemberFunction<UITextEdit>("getCursorPos", &UITextEdit::getCursorPos);
    g_lua.bindClassMemberFunction<UITextEdit>("getMaxLength", &UITextEdit::getMaxLength);
    g_lua.bindClassMemberFunction<UITextEdit>("getSelectionStart", &UITextEdit::getSelectionStart);
    g_lua.bindClassMemberFunction<UITextEdit>("getSelectionEnd", &UITextEdit::getSelectionEnd);
    g_lua.bindClassMemberFunction<UITextEdit>("getSelectionColor", &UITextEdit::getSelectionColor);
    g_lua.bindClassMemberFunction<UITextEdit>("getSelectionBackgroundColor", &UITextEdit::getSelectionBackgroundColor);
    g_lua.bindClassMemberFunction<UITextEdit>("hasSelection", &UITextEdit::hasSelection);
    g_lua.bindClassMemberFunction<UITextEdit>("isEditable", &UITextEdit::isEditable);
    g_lua.bindClassMemberFunction<UITextEdit>("isSelectable", &UITextEdit::isSelectable);
    g_lua.bindClassMemberFunction<UITextEdit>("isCursorVisible", &UITextEdit::isCursorVisible);
    g_lua.bindClassMemberFunction<UITextEdit>("isChangingCursorImage", &UITextEdit::isChangingCursorImage);
    g_lua.bindClassMemberFunction<UITextEdit>("isTextHidden", &UITextEdit::isTextHidden);
    g_lua.bindClassMemberFunction<UITextEdit>("isShiftNavigation", &UITextEdit::isShiftNavigation);
    g_lua.bindClassMemberFunction<UITextEdit>("isMultiline", &UITextEdit::isMultiline);

    // UIQrCode
    g_lua.registerClass<UIQrCode, UIWidget>();
    g_lua.bindClassStaticFunction<UIQrCode>("create", [] { return std::make_shared<UIQrCode>(); });
    g_lua.bindClassMemberFunction<UIQrCode>("getCode", &UIQrCode::getCode);
    g_lua.bindClassMemberFunction<UIQrCode>("getCodeBorder", &UIQrCode::getCodeBorder);
    g_lua.bindClassMemberFunction<UIQrCode>("setCode", &UIQrCode::setCode);
    g_lua.bindClassMemberFunction<UIQrCode>("setCodeBorder", &UIQrCode::setCodeBorder);

    // Shader
    g_lua.registerClass<ShaderProgram>();
    g_lua.registerClass<PainterShaderProgram, ShaderProgram>();
    g_lua.bindClassMemberFunction<PainterShaderProgram>("addMultiTexture", &PainterShaderProgram::addMultiTexture);

    // ParticleEffect
    g_lua.registerClass<ParticleEffectType>();
    g_lua.bindClassStaticFunction<ParticleEffectType>("create", [] { return std::make_shared<ParticleEffectType>(); });
    g_lua.bindClassMemberFunction<ParticleEffectType>("getName", &ParticleEffectType::getName);
    g_lua.bindClassMemberFunction<ParticleEffectType>("getDescription", &ParticleEffectType::getDescription);

    // UIParticles
    g_lua.registerClass<UIParticles, UIWidget>();
    g_lua.bindClassStaticFunction<UIParticles>("create", [] { return std::make_shared<UIParticles>(); });
    g_lua.bindClassMemberFunction<UIParticles>("addEffect", &UIParticles::addEffect);
    g_lua.bindClassMemberFunction<UIParticles>("setEffect", &UIParticles::setEffect);
    g_lua.bindClassMemberFunction<UIParticles>("clearEffects", &UIParticles::clearEffects);
#endif

#ifdef FRAMEWORK_NET
#ifndef __EMSCRIPTEN__
    // Server
    g_lua.registerClass<Server>();
    g_lua.bindClassStaticFunction<Server>("create", &Server::create);
    g_lua.bindClassMemberFunction<Server>("close", &Server::close);
    g_lua.bindClassMemberFunction<Server>("isOpen", &Server::isOpen);
    g_lua.bindClassMemberFunction<Server>("acceptNext", &Server::acceptNext);
#endif

    // Connection
#ifdef __EMSCRIPTEN__
    g_lua.registerClass<WebConnection>();
    g_lua.bindClassMemberFunction<WebConnection>("getIp", &WebConnection::getIp);
#else
    g_lua.registerClass<Connection>();
    g_lua.bindClassMemberFunction<Connection>("getIp", &Connection::getIp);
#endif

    // Protocol
    g_lua.registerClass<Protocol>();
    g_lua.bindClassStaticFunction<Protocol>("create", [] { return std::make_shared<Protocol>(); });
    g_lua.bindClassMemberFunction<Protocol>("connect", &Protocol::connect);
    g_lua.bindClassMemberFunction<Protocol>("disconnect", &Protocol::disconnect);
    g_lua.bindClassMemberFunction<Protocol>("isConnected", &Protocol::isConnected);
    g_lua.bindClassMemberFunction<Protocol>("isConnecting", &Protocol::isConnecting);
    g_lua.bindClassMemberFunction<Protocol>("getConnection", &Protocol::getConnection);
    g_lua.bindClassMemberFunction<Protocol>("setConnection", &Protocol::setConnection);
    g_lua.bindClassMemberFunction<Protocol>("send", &Protocol::send);
    g_lua.bindClassMemberFunction<Protocol>("recv", &Protocol::recv);
    g_lua.bindClassMemberFunction<Protocol>("setXteaKey", &Protocol::setXteaKey);
    g_lua.bindClassMemberFunction<Protocol>("getXteaKey", &Protocol::getXteaKey);
    g_lua.bindClassMemberFunction<Protocol>("generateXteaKey", &Protocol::generateXteaKey);
    g_lua.bindClassMemberFunction<Protocol>("enableXteaEncryption", &Protocol::enableXteaEncryption);
    g_lua.bindClassMemberFunction<Protocol>("enabledSequencedPackets", &Protocol::enabledSequencedPackets);
    g_lua.bindClassMemberFunction<Protocol>("enableChecksum", &Protocol::enableChecksum);

    // InputMessage
    g_lua.registerClass<InputMessage>();
    g_lua.bindClassStaticFunction<InputMessage>("create", [] { return std::make_shared<InputMessage>(); });
    g_lua.bindClassMemberFunction<InputMessage>("setBuffer", &InputMessage::setBuffer);
    g_lua.bindClassMemberFunction<InputMessage>("getBuffer", &InputMessage::getBuffer);
    g_lua.bindClassMemberFunction<InputMessage>("skipBytes", &InputMessage::skipBytes);
    g_lua.bindClassMemberFunction<InputMessage>("getU8", &InputMessage::getU8);
    g_lua.bindClassMemberFunction<InputMessage>("getU16", &InputMessage::getU16);
    g_lua.bindClassMemberFunction<InputMessage>("getU32", &InputMessage::getU32);
    g_lua.bindClassMemberFunction<InputMessage>("getU64", &InputMessage::getU64);
    g_lua.bindClassMemberFunction<InputMessage>("getString", &InputMessage::getString);
    g_lua.bindClassMemberFunction<InputMessage>("peekU8", &InputMessage::peekU8);
    g_lua.bindClassMemberFunction<InputMessage>("peekU16", &InputMessage::peekU16);
    g_lua.bindClassMemberFunction<InputMessage>("peekU32", &InputMessage::peekU32);
    g_lua.bindClassMemberFunction<InputMessage>("peekU64", &InputMessage::peekU64);
    g_lua.bindClassMemberFunction<InputMessage>("decryptRsa", &InputMessage::decryptRsa);
    g_lua.bindClassMemberFunction<InputMessage>("getReadSize", &InputMessage::getReadSize);
    g_lua.bindClassMemberFunction<InputMessage>("getUnreadSize", &InputMessage::getUnreadSize);
    g_lua.bindClassMemberFunction<InputMessage>("getMessageSize", &InputMessage::getMessageSize);
    g_lua.bindClassMemberFunction<InputMessage>("eof", &InputMessage::eof);

    // OutputMessage
    g_lua.registerClass<OutputMessage>();
    g_lua.bindClassStaticFunction<OutputMessage>("create", [] { return std::make_shared<OutputMessage>(); });
    g_lua.bindClassMemberFunction<OutputMessage>("setBuffer", &OutputMessage::setBuffer);
    g_lua.bindClassMemberFunction<OutputMessage>("getBuffer", &OutputMessage::getBuffer);
    g_lua.bindClassMemberFunction<OutputMessage>("reset", &OutputMessage::reset);
    g_lua.bindClassMemberFunction<OutputMessage>("addU8", &OutputMessage::addU8);
    g_lua.bindClassMemberFunction<OutputMessage>("addU16", &OutputMessage::addU16);
    g_lua.bindClassMemberFunction<OutputMessage>("addU32", &OutputMessage::addU32);
    g_lua.bindClassMemberFunction<OutputMessage>("addU64", &OutputMessage::addU64);
    g_lua.bindClassMemberFunction<OutputMessage>("addString", &OutputMessage::addString);
    g_lua.bindClassMemberFunction<OutputMessage>("addPaddingBytes", &OutputMessage::addPaddingBytes);
    g_lua.bindClassMemberFunction<OutputMessage>("encryptRsa", &OutputMessage::encryptRsa);
    g_lua.bindClassMemberFunction<OutputMessage>("getMessageSize", &OutputMessage::getMessageSize);
    g_lua.bindClassMemberFunction<OutputMessage>("setMessageSize", &OutputMessage::setMessageSize);
    g_lua.bindClassMemberFunction<OutputMessage>("getWritePos", &OutputMessage::getWritePos);
    g_lua.bindClassMemberFunction<OutputMessage>("setWritePos", &OutputMessage::setWritePos);
#endif

#ifdef FRAMEWORK_SOUND
    // SoundManager
    g_lua.registerSingletonClass("g_sounds");
    g_lua.bindSingletonFunction("g_sounds", "preload", &SoundManager::preload, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "play", &SoundManager::play, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "getChannel", &SoundManager::getChannel, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "stopAll", &SoundManager::stopAll, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "enableAudio", &SoundManager::enableAudio, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "disableAudio", &SoundManager::disableAudio, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "setAudioEnabled", &SoundManager::setAudioEnabled, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "isAudioEnabled", &SoundManager::isAudioEnabled, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "setPosition", &SoundManager::setPosition, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "createSoundEffect", &SoundManager::createSoundEffect, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "isEaxEnabled", &SoundManager::isEaxEnabled, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "loadClientFiles", &SoundManager::loadClientFiles, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "getAudioFileNameById", &SoundManager::getAudioFileNameById, &g_sounds);

    g_lua.registerClass<SoundSource>();
    g_lua.bindClassStaticFunction<SoundSource>("create", [] { return std::make_shared<SoundSource>(); });
    g_lua.bindClassMemberFunction<SoundSource>("setName", &SoundSource::setName);
    g_lua.bindClassMemberFunction<SoundSource>("play", &SoundSource::play);
    g_lua.bindClassMemberFunction<SoundSource>("stop", &SoundSource::stop);
    g_lua.bindClassMemberFunction<SoundSource>("isPlaying", &SoundSource::isPlaying);
    g_lua.bindClassMemberFunction<SoundSource>("setGain", &SoundSource::setGain);
    g_lua.bindClassMemberFunction<SoundSource>("setPosition", &SoundSource::setPosition);
    g_lua.bindClassMemberFunction<SoundSource>("setVelocity", &SoundSource::setVelocity);
    g_lua.bindClassMemberFunction<SoundSource>("setFading", &SoundSource::setFading);
    g_lua.bindClassMemberFunction<SoundSource>("setLooping", &SoundSource::setLooping);
    g_lua.bindClassMemberFunction<SoundSource>("setRelative", &SoundSource::setRelative);
    g_lua.bindClassMemberFunction<SoundSource>("setReferenceDistance", &SoundSource::setReferenceDistance);
    g_lua.bindClassMemberFunction<SoundSource>("setEffect", &SoundSource::setEffect);
    g_lua.bindClassMemberFunction<SoundSource>("removeEffect", &SoundSource::removeEffect);
    g_lua.registerClass<CombinedSoundSource, SoundSource>();
    g_lua.registerClass<StreamSoundSource, SoundSource>();

    g_lua.registerClass<SoundEffect>();
    g_lua.bindClassMemberFunction<SoundEffect>("setPreset", &SoundEffect::setPreset);

    g_lua.registerClass<SoundChannel>();
    g_lua.bindClassMemberFunction<SoundChannel>("play", &SoundChannel::play);
    g_lua.bindClassMemberFunction<SoundChannel>("stop", &SoundChannel::stop);
    g_lua.bindClassMemberFunction<SoundChannel>("enqueue", &SoundChannel::enqueue);
    g_lua.bindClassMemberFunction<SoundChannel>("enable", &SoundChannel::enable);
    g_lua.bindClassMemberFunction<SoundChannel>("disable", &SoundChannel::disable);
    g_lua.bindClassMemberFunction<SoundChannel>("setGain", &SoundChannel::setGain);
    g_lua.bindClassMemberFunction<SoundChannel>("getGain", &SoundChannel::getGain);
    g_lua.bindClassMemberFunction<SoundChannel>("setEnabled", &SoundChannel::setEnabled);
    g_lua.bindClassMemberFunction<SoundChannel>("isEnabled", &SoundChannel::isEnabled);
    g_lua.bindClassMemberFunction<SoundChannel>("getId", &SoundChannel::getId);
#endif
}
