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

// Split from luafunctions_graphics.cpp to further reduce MSVC template pressure.
// This file contains Mouse, Graphics, TextureManager, UIManager, FontManager,
// ParticleManager, and ShaderManager singleton bindings.

#include <framework/core/eventdispatcher.h>
#include <framework/luaengine/luainterface.h>

#ifdef FRAMEWORK_GRAPHICS
#include "framework/graphics/fontmanager.h"
#include "framework/graphics/graphics.h"
#include "framework/graphics/particleeffect.h"
#include "framework/graphics/particlemanager.h"
#include "framework/graphics/shadermanager.h"
#include "framework/graphics/texturemanager.h"
#include "framework/input/mouse.h"
#include "framework/ui/uimanager.h"
#endif

void registerLuaFunctions_GfxSingletons()
{
#ifdef FRAMEWORK_GRAPHICS
    // Input
    g_lua.registerSingletonClass("g_mouse");
    g_lua.bindSingletonFunction("g_mouse", "loadCursors", &Mouse::loadCursors, &g_mouse);
    g_lua.bindSingletonFunction("g_mouse", "addCursor", &Mouse::addCursor, &g_mouse);
    g_lua.bindSingletonFunction("g_mouse", "pushCursor", &Mouse::pushCursor, &g_mouse);
    g_lua.bindSingletonFunction("g_mouse", "popCursor", &Mouse::popCursor, &g_mouse);
    g_lua.bindSingletonFunction("g_mouse", "isCursorChanged", &Mouse::isCursorChanged, &g_mouse);
    g_lua.bindSingletonFunction("g_mouse", "isPressed", &Mouse::isPressed, &g_mouse);

    // Graphics
    g_lua.registerSingletonClass("g_graphics");
    g_lua.bindSingletonFunction("g_graphics", "getViewportSize", &Graphics::getViewportSize, &g_graphics);
    g_lua.bindSingletonFunction("g_graphics", "getVendor", &Graphics::getVendor, &g_graphics);
    g_lua.bindSingletonFunction("g_graphics", "getRenderer", &Graphics::getRenderer, &g_graphics);
    g_lua.bindSingletonFunction("g_graphics", "getVersion", &Graphics::getVersion, &g_graphics);

    // Textures
    g_lua.registerSingletonClass("g_textures");
    g_lua.bindSingletonFunction("g_textures", "preload", &TextureManager::preload, &g_textures);
    g_lua.bindSingletonFunction("g_textures", "clearCache", &TextureManager::clearCache, &g_textures);
    g_lua.bindSingletonFunction("g_textures", "liveReload", &TextureManager::liveReload, &g_textures);

    // UI
    g_lua.registerSingletonClass("g_ui");
    g_lua.bindSingletonFunction("g_ui", "clearStyles", &UIManager::clearStyles, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "importStyle", &UIManager::importStyle, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "getStyle", &UIManager::getStyle, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "getStyleName", &UIManager::getStyleName, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "getStyleClass", &UIManager::getStyleClass, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "loadUI", &UIManager::loadUI, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "loadUIFromString", &UIManager::loadUIFromString, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "displayUI", &UIManager::displayUI, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "createWidget", &UIManager::createWidget, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "createWidgetFromOTML", &UIManager::createWidgetFromOTML, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "getRootWidget", &UIManager::getRootWidget, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "getDraggingWidget", &UIManager::getDraggingWidget, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "getPressedWidget", &UIManager::getPressedWidget, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "setDebugBoxesDrawing", &UIManager::setDebugBoxesDrawing, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "isDrawingDebugBoxes", &UIManager::isDrawingDebugBoxes, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "isMouseGrabbed", &UIManager::isMouseGrabbed, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "isKeyboardGrabbed", &UIManager::isKeyboardGrabbed, &g_ui);

    // FontManager
    g_lua.registerSingletonClass("g_fonts");
    g_lua.bindSingletonFunction("g_fonts", "clearFonts", &FontManager::clearFonts, &g_fonts);
    g_lua.bindSingletonFunction("g_fonts", "clearGlyphCaches", &FontManager::clearGlyphCaches, &g_fonts);
    g_lua.bindSingletonFunction("g_fonts", "setLocaleTag", &FontManager::setLocaleTag, &g_fonts);
    g_lua.bindSingletonFunction("g_fonts", "getLocaleTag", &FontManager::getLocaleTag, &g_fonts);
    g_lua.bindSingletonFunction("g_fonts", "importFont", &FontManager::importFont, &g_fonts);
    g_lua.bindSingletonFunction("g_fonts", "fontExists", &FontManager::fontExists, &g_fonts);

    // ParticleManager
    g_lua.registerSingletonClass("g_particles");
    g_lua.bindSingletonFunction("g_particles", "importParticle", &ParticleManager::importParticle, &g_particles);
    g_lua.bindSingletonFunction("g_particles", "getEffectsTypes", &ParticleManager::getEffectsTypes, &g_particles);
    g_lua.bindSingletonFunction("g_particles", "terminate", &ParticleManager::terminate, &g_particles);

    // ShaderManager
    g_lua.registerSingletonClass("g_shaders");
    g_lua.bindSingletonFunction("g_shaders", "createShader", &ShaderManager::createShader, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "createFragmentShader", &ShaderManager::createFragmentShader, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "createFragmentShaderFromCode", &ShaderManager::createFragmentShaderFromCode, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "setupMapShader", &ShaderManager::setupMapShader, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "setupItemShader", &ShaderManager::setupItemShader, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "setupOutfitShader", &ShaderManager::setupOutfitShader, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "setupMountShader", &ShaderManager::setupMountShader, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "addMultiTexture", &ShaderManager::addMultiTexture, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "getShader", &ShaderManager::getShader, &g_shaders);
    g_lua.bindClassStaticFunction("g_shaders", "clear", [] {
        g_mainDispatcher.addEvent([] { g_shaders.clear(); });
    });
#endif
}
