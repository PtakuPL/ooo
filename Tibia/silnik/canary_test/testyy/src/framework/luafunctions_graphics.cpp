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
// This file contains GraphicalApplication and PlatformWindow bindings.
// Mouse, Graphics, UI, Fonts, Particles, Shaders are in luafunctions_gfx_singletons.cpp.

#include <framework/core/application.h>
#include <framework/core/eventdispatcher.h>
#include <framework/core/graphicalapplication.h>
#include <framework/luaengine/luainterface.h>

#ifdef FRAMEWORK_GRAPHICS
#include "framework/platform/platformwindow.h"
#endif

#if defined(_MSC_VER) && !defined(__clang__)
#pragma optimize("", off)
#endif

void registerLuaFunctions_Graphics()
{
#ifdef FRAMEWORK_GRAPHICS
    // GraphicalApplication
    g_lua.bindSingletonFunction("g_app", "isOnInputEvent", &GraphicalApplication::isOnInputEvent, &g_app);

    g_lua.bindSingletonFunction("g_app", "optimize", &GraphicalApplication::optimize, &g_app);
    g_lua.bindSingletonFunction("g_app", "forceEffectOptimization", &GraphicalApplication::forceEffectOptimization, &g_app);
    g_lua.bindSingletonFunction("g_app", "setDrawEffectOnTop", &GraphicalApplication::setDrawEffectOnTop, &g_app);

    g_lua.bindSingletonFunction("g_app", "getFps", &GraphicalApplication::getFps, &g_app);
    g_lua.bindSingletonFunction("g_app", "getMaxFps", &GraphicalApplication::getMaxFps, &g_app);
    g_lua.bindSingletonFunction("g_app", "setMaxFps", &GraphicalApplication::setMaxFps, &g_app);
    g_lua.bindSingletonFunction("g_app", "getTargetFps", &GraphicalApplication::getTargetFps, &g_app);
    g_lua.bindSingletonFunction("g_app", "setTargetFps", &GraphicalApplication::setTargetFps, &g_app);
    g_lua.bindSingletonFunction("g_app", "resetTargetFps", &GraphicalApplication::resetTargetFps, &g_app);

    g_lua.bindSingletonFunction("g_app", "isDrawingTexts", &GraphicalApplication::isDrawingTexts, &g_app);
    g_lua.bindSingletonFunction("g_app", "setDrawTexts", &GraphicalApplication::setDrawTexts, &g_app);
    g_lua.bindSingletonFunction("g_app", "setLoadingAsyncTexture", &GraphicalApplication::setLoadingAsyncTexture, &g_app);
    g_lua.bindSingletonFunction("g_app", "isEncrypted", &GraphicalApplication::isEncrypted, &g_app);
    g_lua.bindSingletonFunction("g_app", "isScaled", &GraphicalApplication::isScaled, &g_app);

    g_lua.bindSingletonFunction("g_app", "setHUDScale", &GraphicalApplication::setHUDScale, &g_app);
    g_lua.bindSingletonFunction("g_app", "setCreatureInformationScale", &GraphicalApplication::setCreatureInformationScale, &g_app);
    g_lua.bindSingletonFunction("g_app", "setAnimatedTextScale", &GraphicalApplication::setAnimatedTextScale, &g_app);
    g_lua.bindSingletonFunction("g_app", "setStaticTextScale", &GraphicalApplication::setStaticTextScale, &g_app);
    g_lua.bindSingletonFunction("g_app", "doScreenshot", &GraphicalApplication::doScreenshot, &g_app);
    g_lua.bindSingletonFunction("g_app", "doMapScreenshot", &GraphicalApplication::doMapScreenshot, &g_app);

    // PlatformWindow
    g_lua.registerSingletonClass("g_window");
    g_lua.bindSingletonFunction("g_window", "move", &PlatformWindow::move, &g_window);
    g_lua.bindSingletonFunction("g_window", "resize", &PlatformWindow::resize, &g_window);
    g_lua.bindSingletonFunction("g_window", "show", &PlatformWindow::show, &g_window);
    g_lua.bindSingletonFunction("g_window", "hide", &PlatformWindow::hide, &g_window);
    g_lua.bindSingletonFunction("g_window", "poll", &PlatformWindow::poll, &g_window);
    g_lua.bindSingletonFunction("g_window", "maximize", &PlatformWindow::maximize, &g_window);
    g_lua.bindSingletonFunction("g_window", "restoreMouseCursor", &PlatformWindow::restoreMouseCursor, &g_window);
    g_lua.bindSingletonFunction("g_window", "showMouse", &PlatformWindow::showMouse, &g_window);
    g_lua.bindSingletonFunction("g_window", "hideMouse", &PlatformWindow::hideMouse, &g_window);
    g_lua.bindSingletonFunction("g_window", "setTitle", &PlatformWindow::setTitle, &g_window);
    g_lua.bindSingletonFunction("g_window", "setMouseCursor", &PlatformWindow::setMouseCursor, &g_window);
    g_lua.bindSingletonFunction("g_window", "setMinimumSize", &PlatformWindow::setMinimumSize, &g_window);
    g_lua.bindSingletonFunction("g_window", "setFullscreen", &PlatformWindow::setFullscreen, &g_window);
    g_lua.bindSingletonFunction("g_window", "setVerticalSync", &PlatformWindow::setVerticalSync, &g_window);
    g_lua.bindSingletonFunction("g_window", "setIcon", &PlatformWindow::setIcon, &g_window);
    g_lua.bindSingletonFunction("g_window", "setClipboardText", &PlatformWindow::setClipboardText, &g_window);
    g_lua.bindSingletonFunction("g_window", "getDisplaySize", &PlatformWindow::getDisplaySize, &g_window);
    g_lua.bindSingletonFunction("g_window", "getClipboardText", &PlatformWindow::getClipboardText, &g_window);
    g_lua.bindSingletonFunction("g_window", "getPlatformType", &PlatformWindow::getPlatformType, &g_window);
    g_lua.bindSingletonFunction("g_window", "getDisplayWidth", &PlatformWindow::getDisplayWidth, &g_window);
    g_lua.bindSingletonFunction("g_window", "getDisplayHeight", &PlatformWindow::getDisplayHeight, &g_window);
    g_lua.bindSingletonFunction("g_window", "getUnmaximizedSize", &PlatformWindow::getUnmaximizedSize, &g_window);
    g_lua.bindSingletonFunction("g_window", "getSize", &PlatformWindow::getSize, &g_window);
    g_lua.bindSingletonFunction("g_window", "getWidth", &PlatformWindow::getWidth, &g_window);
    g_lua.bindSingletonFunction("g_window", "getHeight", &PlatformWindow::getHeight, &g_window);
    g_lua.bindSingletonFunction("g_window", "getUnmaximizedPos", &PlatformWindow::getUnmaximizedPos, &g_window);
    g_lua.bindSingletonFunction("g_window", "getPosition", &PlatformWindow::getPosition, &g_window);
    g_lua.bindSingletonFunction("g_window", "getX", &PlatformWindow::getX, &g_window);
    g_lua.bindSingletonFunction("g_window", "getY", &PlatformWindow::getY, &g_window);
    g_lua.bindSingletonFunction("g_window", "getMousePosition", &PlatformWindow::getMousePosition, &g_window);
    g_lua.bindSingletonFunction("g_window", "getKeyboardModifiers", &PlatformWindow::getKeyboardModifiers, &g_window);
    g_lua.bindSingletonFunction("g_window", "isKeyPressed", &PlatformWindow::isKeyPressed, &g_window);
    g_lua.bindSingletonFunction("g_window", "isMouseButtonPressed", &PlatformWindow::isMouseButtonPressed, &g_window);
    g_lua.bindSingletonFunction("g_window", "isVisible", &PlatformWindow::isVisible, &g_window);
    g_lua.bindSingletonFunction("g_window", "isFullscreen", &PlatformWindow::isFullscreen, &g_window);
    g_lua.bindSingletonFunction("g_window", "isMaximized", &PlatformWindow::isMaximized, &g_window);
    g_lua.bindSingletonFunction("g_window", "hasFocus", &PlatformWindow::hasFocus, &g_window);
    g_lua.bindSingletonFunction("g_window", "getDisplayDensity", &PlatformWindow::getDisplayDensity, &g_window);
    g_lua.bindSingletonFunction("g_window", "setKeyDelay", &PlatformWindow::setKeyDelay, &g_window);

    // Mouse, Graphics, Textures, UI, Fonts, Particles, Shaders
    extern void registerLuaFunctions_GfxSingletons();
    registerLuaFunctions_GfxSingletons();
#endif
}

#if defined(_MSC_VER) && !defined(__clang__)
#pragma optimize("", on)
#endif
