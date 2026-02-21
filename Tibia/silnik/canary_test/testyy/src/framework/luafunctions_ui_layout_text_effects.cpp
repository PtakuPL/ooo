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
// This file contains layout, text edit, QR, shader, and particle bindings.

#include <framework/luaengine/luainterface.h>

#ifdef FRAMEWORK_GRAPHICS
#include "framework/graphics/particleeffect.h"
#include "framework/graphics/shadermanager.h"
#include "framework/ui/ui.h"
#endif

#if defined(_MSC_VER) && !defined(__clang__)
#pragma optimize("", off)
#endif

void registerLuaFunctions_UILayoutTextEffects()
{
#ifdef FRAMEWORK_GRAPHICS
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
}

#if defined(_MSC_VER) && !defined(__clang__)
#pragma optimize("", on)
#endif
