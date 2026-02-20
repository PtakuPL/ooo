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

// Split from client/luafunctions.cpp to reduce template instantiations
// per translation unit and avoid MSVC ICE C1001.
// This file registers client-specific UI widget Lua bindings:
// UIItem, UIEffect, UIMissile, UISprite, UICreature, UIMap, UIMinimap,
// UIProgressRect, UIGraph, UIMapAnchorLayout.

#include "uicreature.h"
#include "uieffect.h"
#include "uiitem.h"
#include "uimissile.h"
#include "uigraph.h"
#include "uimap.h"
#include "uimapanchorlayout.h"
#include "uiminimap.h"
#include "uiprogressrect.h"
#include "uisprite.h"

#include <framework/luaengine/luainterface.h>

void registerLuaFunctions_ClientUI()
{
    g_lua.registerClass<UIItem, UIWidget>();
    g_lua.bindClassStaticFunction<UIItem>("create", [] { return std::make_shared<UIItem>(); });
    g_lua.bindClassMemberFunction<UIItem>("setItemId", &UIItem::setItemId);
    g_lua.bindClassMemberFunction<UIItem>("setItemCount", &UIItem::setItemCount);
    g_lua.bindClassMemberFunction<UIItem>("setItemSubType", &UIItem::setItemSubType);
    g_lua.bindClassMemberFunction<UIItem>("setItemVisible", &UIItem::setItemVisible);
    g_lua.bindClassMemberFunction<UIItem>("setItem", &UIItem::setItem);
    g_lua.bindClassMemberFunction<UIItem>("setVirtual", &UIItem::setVirtual);
    g_lua.bindClassMemberFunction<UIItem>("setShowCount", &UIItem::setShowCount);
    g_lua.bindClassMemberFunction<UIItem>("clearItem", &UIItem::clearItem);
    g_lua.bindClassMemberFunction<UIItem>("getItemId", &UIItem::getItemId);
    g_lua.bindClassMemberFunction<UIItem>("getItemCount", &UIItem::getItemCount);
    g_lua.bindClassMemberFunction<UIItem>("getItemSubType", &UIItem::getItemSubType);
    g_lua.bindClassMemberFunction<UIItem>("getItemCountOrSubType", &UIItem::getItemCountOrSubType);
    g_lua.bindClassMemberFunction<UIItem>("getItem", &UIItem::getItem);
    g_lua.bindClassMemberFunction<UIItem>("isVirtual", &UIItem::isVirtual);
    g_lua.bindClassMemberFunction<UIItem>("isItemVisible", &UIItem::isItemVisible);

    g_lua.registerClass<UIEffect, UIWidget>();
    g_lua.bindClassStaticFunction<UIEffect>("create", [] { return std::make_shared<UIEffect>(); });
    g_lua.bindClassMemberFunction<UIEffect>("setEffectId", &UIEffect::setEffectId);
    g_lua.bindClassMemberFunction<UIEffect>("setEffectVisible", &UIEffect::setEffectVisible);
    g_lua.bindClassMemberFunction<UIEffect>("setEffect", &UIEffect::setEffect);
    g_lua.bindClassMemberFunction<UIEffect>("setVirtual", &UIEffect::setVirtual);
    g_lua.bindClassMemberFunction<UIEffect>("clearEffect", &UIEffect::clearEffect);
    g_lua.bindClassMemberFunction<UIEffect>("getEffectId", &UIEffect::getEffectId);
    g_lua.bindClassMemberFunction<UIEffect>("getEffect", &UIEffect::getEffect);
    g_lua.bindClassMemberFunction<UIEffect>("isVirtual", &UIEffect::isVirtual);
    g_lua.bindClassMemberFunction<UIEffect>("isEffectVisible", &UIEffect::isEffectVisible);

    g_lua.registerClass<UIMissile, UIWidget>();
    g_lua.bindClassStaticFunction<UIMissile>("create", [] { return std::make_shared<UIMissile>(); });
    g_lua.bindClassMemberFunction<UIMissile>("setMissileId", &UIMissile::setMissileId);
    g_lua.bindClassMemberFunction<UIMissile>("setMissileVisible", &UIMissile::setMissileVisible);
    g_lua.bindClassMemberFunction<UIMissile>("setMissile", &UIMissile::setMissile);
    g_lua.bindClassMemberFunction<UIMissile>("setVirtual", &UIMissile::setVirtual);
    g_lua.bindClassMemberFunction<UIMissile>("clearMissile", &UIMissile::clearMissile);
    g_lua.bindClassMemberFunction<UIMissile>("getMissileId", &UIMissile::getMissileId);
    g_lua.bindClassMemberFunction<UIMissile>("getMissile", &UIMissile::getMissile);
    g_lua.bindClassMemberFunction<UIMissile>("isVirtual", &UIMissile::isVirtual);
    g_lua.bindClassMemberFunction<UIMissile>("isMissileVisible", &UIMissile::isMissileVisible);
    g_lua.bindClassMemberFunction<UIMissile>("setDirection", &UIMissile::setDirection);
    g_lua.bindClassMemberFunction<UIMissile>("getDirection", &UIMissile::getDirection);

    g_lua.registerClass<UISprite, UIWidget>();
    g_lua.bindClassStaticFunction<UISprite>("create", [] { return std::make_shared<UISprite>(); });
    g_lua.bindClassMemberFunction<UISprite>("setSpriteId", &UISprite::setSpriteId);
    g_lua.bindClassMemberFunction<UISprite>("clearSprite", &UISprite::clearSprite);
    g_lua.bindClassMemberFunction<UISprite>("getSpriteId", &UISprite::getSpriteId);
    g_lua.bindClassMemberFunction<UISprite>("setSpriteColor", &UISprite::setSpriteColor);
    g_lua.bindClassMemberFunction<UISprite>("hasSprite", &UISprite::hasSprite);

    g_lua.registerClass<UICreature, UIWidget>();
    g_lua.bindClassStaticFunction<UICreature>("create", [] { return std::make_shared<UICreature>(); });
    g_lua.bindClassMemberFunction<UICreature>("setCreature", &UICreature::setCreature);
    g_lua.bindClassMemberFunction<UICreature>("setOutfit", &UICreature::setOutfit);
    g_lua.bindClassMemberFunction<UICreature>("setCreatureSize", &UICreature::setCreatureSize);
    g_lua.bindClassMemberFunction<UICreature>("getCreature", &UICreature::getCreature);
    g_lua.bindClassMemberFunction<UICreature>("getCreatureSize", &UICreature::getCreatureSize);
    // note: check function
    g_lua.bindClassMemberFunction<UICreature>("getDirection", &UICreature::getDirection);
    g_lua.bindClassMemberFunction<UICreature>("setCenter", &UICreature::setCenter);
    g_lua.bindClassMemberFunction<UICreature>("isCentered", &UICreature::isCentered);

    g_lua.registerClass<UIMap, UIWidget>();
    g_lua.bindClassStaticFunction<UIMap>("create", [] { return std::make_shared<UIMap>(); });
    g_lua.bindClassMemberFunction<UIMap>("drawSelf", &UIMap::drawSelf);
    g_lua.bindClassMemberFunction<UIMap>("movePixels", &UIMap::movePixels);
    g_lua.bindClassMemberFunction<UIMap>("setZoom", &UIMap::setZoom);
    g_lua.bindClassMemberFunction<UIMap>("zoomIn", &UIMap::zoomIn);
    g_lua.bindClassMemberFunction<UIMap>("zoomOut", &UIMap::zoomOut);
    g_lua.bindClassMemberFunction<UIMap>("followCreature", &UIMap::followCreature);
    g_lua.bindClassMemberFunction<UIMap>("setCameraPosition", &UIMap::setCameraPosition);
    g_lua.bindClassMemberFunction<UIMap>("setMaxZoomIn", &UIMap::setMaxZoomIn);
    g_lua.bindClassMemberFunction<UIMap>("setMaxZoomOut", &UIMap::setMaxZoomOut);
    g_lua.bindClassMemberFunction<UIMap>("lockVisibleFloor", &UIMap::lockVisibleFloor);
    g_lua.bindClassMemberFunction<UIMap>("unlockVisibleFloor", &UIMap::unlockVisibleFloor);
    g_lua.bindClassMemberFunction<UIMap>("setVisibleDimension", &UIMap::setVisibleDimension);
    g_lua.bindClassMemberFunction<UIMap>("setFloorViewMode", &UIMap::setFloorViewMode);
    g_lua.bindClassMemberFunction<UIMap>("setDrawNames", &UIMap::setDrawNames);
    g_lua.bindClassMemberFunction<UIMap>("setDrawHealthBars", &UIMap::setDrawHealthBars);
    g_lua.bindClassMemberFunction<UIMap>("setDrawLights", &UIMap::setDrawLights);
    g_lua.bindClassMemberFunction<UIMap>("setLimitVisibleDimension", &UIMap::setLimitVisibleDimension);
    g_lua.bindClassMemberFunction<UIMap>("setDrawManaBar", &UIMap::setDrawManaBar);
    g_lua.bindClassMemberFunction<UIMap>("setKeepAspectRatio", &UIMap::setKeepAspectRatio);
    g_lua.bindClassMemberFunction<UIMap>("setShader", &UIMap::setShader);
    g_lua.bindClassMemberFunction<UIMap>("getShader", &UIMap::getShader);
    g_lua.bindClassMemberFunction<UIMap>("getNextShader", &UIMap::getNextShader);
    g_lua.bindClassMemberFunction<UIMap>("isSwitchingShader", &UIMap::isSwitchingShader);
    g_lua.bindClassMemberFunction<UIMap>("setMinimumAmbientLight", &UIMap::setMinimumAmbientLight);
    g_lua.bindClassMemberFunction<UIMap>("setShadowFloorIntensity", &UIMap::setShadowFloorIntensity);
    g_lua.bindClassMemberFunction<UIMap>("setLimitVisibleRange", &UIMap::setLimitVisibleRange);
    g_lua.bindClassMemberFunction<UIMap>("setDrawViewportEdge", &UIMap::setDrawViewportEdge);
    g_lua.bindClassMemberFunction<UIMap>("isDrawingNames", &UIMap::isDrawingNames);
    g_lua.bindClassMemberFunction<UIMap>("isDrawingHealthBars", &UIMap::isDrawingHealthBars);
    g_lua.bindClassMemberFunction<UIMap>("isDrawingLights", &UIMap::isDrawingLights);
    g_lua.bindClassMemberFunction<UIMap>("isLimitedVisibleDimension", &UIMap::isLimitedVisibleDimension);
    g_lua.bindClassMemberFunction<UIMap>("isDrawingManaBar", &UIMap::isDrawingManaBar);
    g_lua.bindClassMemberFunction<UIMap>("isLimitVisibleRangeEnabled", &UIMap::isLimitVisibleRangeEnabled);
    g_lua.bindClassMemberFunction<UIMap>("isKeepAspectRatioEnabled", &UIMap::isKeepAspectRatioEnabled);
    g_lua.bindClassMemberFunction<UIMap>("isInRange", &UIMap::isInRange);
    g_lua.bindClassMemberFunction<UIMap>("getVisibleDimension", &UIMap::getVisibleDimension);
    g_lua.bindClassMemberFunction<UIMap>("getFloorViewMode", &UIMap::getFloorViewMode);
    g_lua.bindClassMemberFunction<UIMap>("getFollowingCreature", &UIMap::getFollowingCreature);
    g_lua.bindClassMemberFunction<UIMap>("getCameraPosition", &UIMap::getCameraPosition);
    g_lua.bindClassMemberFunction<UIMap>("getPosition", &UIMap::getPosition);
    g_lua.bindClassMemberFunction<UIMap>("getTile", &UIMap::getTile);
    g_lua.bindClassMemberFunction<UIMap>("getMaxZoomIn", &UIMap::getMaxZoomIn);
    g_lua.bindClassMemberFunction<UIMap>("getMaxZoomOut", &UIMap::getMaxZoomOut);
    g_lua.bindClassMemberFunction<UIMap>("getZoom", &UIMap::getZoom);
    g_lua.bindClassMemberFunction<UIMap>("getMinimumAmbientLight", &UIMap::getMinimumAmbientLight);
    g_lua.bindClassMemberFunction<UIMap>("getSpectators", &UIMap::getSpectators);
    g_lua.bindClassMemberFunction<UIMap>("getSightSpectators", &UIMap::getSightSpectators);
    g_lua.bindClassMemberFunction<UIMap>("setCrosshairTexture", &UIMap::setCrosshairTexture);
    g_lua.bindClassMemberFunction<UIMap>("setDrawHighlightTarget", &UIMap::setDrawHighlightTarget);
    g_lua.bindClassMemberFunction<UIMap>("setAntiAliasingMode", &UIMap::setAntiAliasingMode);
    g_lua.bindClassMemberFunction<UIMap>("setFloorFading", &UIMap::setFloorFading);
    g_lua.bindClassMemberFunction<UIMap>("clearTiles", &UIMap::clearTiles);

    g_lua.registerClass<UIMinimap, UIWidget>();
    g_lua.bindClassStaticFunction<UIMinimap>("create", [] { return std::make_shared<UIMinimap>(); });
    g_lua.bindClassMemberFunction<UIMinimap>("zoomIn", &UIMinimap::zoomIn);
    g_lua.bindClassMemberFunction<UIMinimap>("zoomOut", &UIMinimap::zoomOut);
    g_lua.bindClassMemberFunction<UIMinimap>("setZoom", &UIMinimap::setZoom);
    g_lua.bindClassMemberFunction<UIMinimap>("setMixZoom", &UIMinimap::setMinZoom);
    g_lua.bindClassMemberFunction<UIMinimap>("setMaxZoom", &UIMinimap::setMaxZoom);
    g_lua.bindClassMemberFunction<UIMinimap>("setCameraPosition", &UIMinimap::setCameraPosition);
    g_lua.bindClassMemberFunction<UIMinimap>("floorUp", &UIMinimap::floorUp);
    g_lua.bindClassMemberFunction<UIMinimap>("floorDown", &UIMinimap::floorDown);
    g_lua.bindClassMemberFunction<UIMinimap>("getTilePoint", &UIMinimap::getTilePoint);
    g_lua.bindClassMemberFunction<UIMinimap>("getTilePosition", &UIMinimap::getTilePosition);
    g_lua.bindClassMemberFunction<UIMinimap>("getTileRect", &UIMinimap::getTileRect);
    g_lua.bindClassMemberFunction<UIMinimap>("getCameraPosition", &UIMinimap::getCameraPosition);
    g_lua.bindClassMemberFunction<UIMinimap>("getMinZoom", &UIMinimap::getMinZoom);
    g_lua.bindClassMemberFunction<UIMinimap>("getMaxZoom", &UIMinimap::getMaxZoom);
    g_lua.bindClassMemberFunction<UIMinimap>("getZoom", &UIMinimap::getZoom);
    g_lua.bindClassMemberFunction<UIMinimap>("getScale", &UIMinimap::getScale);
    g_lua.bindClassMemberFunction<UIMinimap>("anchorPosition", &UIMinimap::anchorPosition);
    g_lua.bindClassMemberFunction<UIMinimap>("fillPosition", &UIMinimap::fillPosition);
    g_lua.bindClassMemberFunction<UIMinimap>("centerInPosition", &UIMinimap::centerInPosition);

    g_lua.registerClass<UIProgressRect, UIWidget>();
    g_lua.bindClassStaticFunction<UIProgressRect>("create", [] { return std::make_shared<UIProgressRect>(); });
    g_lua.bindClassMemberFunction<UIProgressRect>("setPercent", &UIProgressRect::setPercent);
    g_lua.bindClassMemberFunction<UIProgressRect>("getPercent", &UIProgressRect::getPercent);

#ifndef __EMSCRIPTEN__
    g_lua.registerClass<UIGraph, UIWidget>();
    g_lua.bindClassStaticFunction<UIGraph>("create", [] { return std::make_shared<UIGraph>(); });
    g_lua.bindClassMemberFunction<UIGraph>("clear", &UIGraph::clear);
    g_lua.bindClassMemberFunction<UIGraph>("createGraph", &UIGraph::createGraph);
    g_lua.bindClassMemberFunction<UIGraph>("getGraphsCount", &UIGraph::getGraphsCount);
    g_lua.bindClassMemberFunction<UIGraph>("addValue", &UIGraph::addValue);
    g_lua.bindClassMemberFunction<UIGraph>("setCapacity", &UIGraph::setCapacity);
    g_lua.bindClassMemberFunction<UIGraph>("setTitle", &UIGraph::setTitle);
    g_lua.bindClassMemberFunction<UIGraph>("setShowLabels", &UIGraph::setShowLabels);
    g_lua.bindClassMemberFunction<UIGraph>("setShowInfo", &UIGraph::setShowInfo);
    g_lua.bindClassMemberFunction<UIGraph>("setLineWidth", &UIGraph::setLineWidth);
    g_lua.bindClassMemberFunction<UIGraph>("setLineColor", &UIGraph::setLineColor);
    g_lua.bindClassMemberFunction<UIGraph>("setInfoText", &UIGraph::setInfoText);
    g_lua.bindClassMemberFunction<UIGraph>("setInfoLineColor", &UIGraph::setInfoLineColor);
    g_lua.bindClassMemberFunction<UIGraph>("setTextBackground", &UIGraph::setTextBackground);
    g_lua.bindClassMemberFunction<UIGraph>("setGraphVisible", &UIGraph::setGraphVisible);
#endif

    g_lua.registerClass<UIMapAnchorLayout, UIAnchorLayout>();
}
