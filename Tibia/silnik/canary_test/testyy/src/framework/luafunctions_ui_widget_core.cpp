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
// This file contains the first half of UIWidget bindings.

#include <framework/luaengine/luainterface.h>

#ifdef FRAMEWORK_GRAPHICS
#include "framework/ui/ui.h"
#endif

#if defined(_MSC_VER) && !defined(__clang__)
#pragma optimize("", off)
#endif

void registerLuaFunctions_UIWidgetCore()
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
#endif
}

#if defined(_MSC_VER) && !defined(__clang__)
#pragma optimize("", on)
#endif
