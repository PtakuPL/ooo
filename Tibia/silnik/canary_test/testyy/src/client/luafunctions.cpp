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

// Includes needed only for singleton registrations (g_things, g_map, g_game, etc.)
#include "attachedeffectmanager.h"
#include "client.h"
#include "game.h"
#include "gameconfig.h"
#include "luavaluecasts_client.h"
#include "map.h"
#include "minimap.h"
#include "outfit.h"
#include "localplayer.h"
#include "protocolgame.h"
#include "spriteappearances.h"
#include "spritemanager.h"
#include "thingtypemanager.h"

#include <framework/luaengine/luainterface.h>

// Forward declarations for split TU functions
extern void registerLuaFunctions_ClientEntities();
extern void registerLuaFunctions_ClientUI();

void Client::registerLuaFunctions()
{
    g_lua.registerSingletonClass("g_things");
    g_lua.bindSingletonFunction("g_things", "loadAppearances", &ThingTypeManager::loadAppearances, &g_things);
    g_lua.bindSingletonFunction("g_things", "loadStaticData", &ThingTypeManager::loadStaticData, &g_things);
    g_lua.bindSingletonFunction("g_things", "loadDat", &ThingTypeManager::loadDat, &g_things);
    g_lua.bindSingletonFunction("g_things", "loadOtml", &ThingTypeManager::loadOtml, &g_things);
    g_lua.bindSingletonFunction("g_things", "isDatLoaded", &ThingTypeManager::isDatLoaded, &g_things);
    g_lua.bindSingletonFunction("g_things", "getDatSignature", &ThingTypeManager::getDatSignature, &g_things);
    g_lua.bindSingletonFunction("g_things", "getContentRevision", &ThingTypeManager::getContentRevision, &g_things);
    g_lua.bindSingletonFunction("g_things", "getThingType", &ThingTypeManager::getThingType, &g_things);
    g_lua.bindSingletonFunction("g_things", "getThingTypes", &ThingTypeManager::getThingTypes, &g_things);
    g_lua.bindSingletonFunction("g_things", "findThingTypeByAttr", &ThingTypeManager::findThingTypeByAttr, &g_things);
    g_lua.bindSingletonFunction("g_things", "getRaceData", &ThingTypeManager::getRaceData, &g_things);
    g_lua.bindSingletonFunction("g_things", "getRacesByName", &ThingTypeManager::getRacesByName, &g_things);

#ifdef FRAMEWORK_EDITOR
    g_lua.bindSingletonFunction("g_things", "getItemType", &ThingTypeManager::getItemType, &g_things);
    g_lua.bindSingletonFunction("g_things", "findItemTypeByClientId", &ThingTypeManager::findItemTypeByClientId, &g_things);
    g_lua.bindSingletonFunction("g_things", "findItemTypeByName", &ThingTypeManager::findItemTypeByName, &g_things);
    g_lua.bindSingletonFunction("g_things", "findItemTypesByName", &ThingTypeManager::findItemTypesByName, &g_things);
    g_lua.bindSingletonFunction("g_things", "findItemTypesByString", &ThingTypeManager::findItemTypesByString, &g_things);
    g_lua.bindSingletonFunction("g_things", "findItemTypeByCategory", &ThingTypeManager::findItemTypeByCategory, &g_things);
    g_lua.bindSingletonFunction("g_things", "saveDat", &ThingTypeManager::saveDat, &g_things);
    g_lua.bindSingletonFunction("g_things", "loadOtb", &ThingTypeManager::loadOtb, &g_things);
    g_lua.bindSingletonFunction("g_things", "loadXml", &ThingTypeManager::loadXml, &g_things);
    g_lua.bindSingletonFunction("g_things", "isOtbLoaded", &ThingTypeManager::isOtbLoaded, &g_things);

    g_lua.registerSingletonClass("g_houses");
    g_lua.bindSingletonFunction("g_houses", "clear", &HouseManager::clear, &g_houses);
    g_lua.bindSingletonFunction("g_houses", "load", &HouseManager::load, &g_houses);
    g_lua.bindSingletonFunction("g_houses", "save", &HouseManager::save, &g_houses);
    g_lua.bindSingletonFunction("g_houses", "getHouse", &HouseManager::getHouse, &g_houses);
    g_lua.bindSingletonFunction("g_houses", "getHouseByName", &HouseManager::getHouseByName, &g_houses);
    g_lua.bindSingletonFunction("g_houses", "addHouse", &HouseManager::addHouse, &g_houses);
    g_lua.bindSingletonFunction("g_houses", "removeHouse", &HouseManager::removeHouse, &g_houses);
    g_lua.bindSingletonFunction("g_houses", "getHouseList", &HouseManager::getHouseList, &g_houses);
    g_lua.bindSingletonFunction("g_houses", "filterHouses", &HouseManager::filterHouses, &g_houses);
    g_lua.bindSingletonFunction("g_houses", "sort", &HouseManager::sort, &g_houses);

    g_lua.registerSingletonClass("g_towns");
    g_lua.bindSingletonFunction("g_towns", "getTown", &TownManager::getTown, &g_towns);
    g_lua.bindSingletonFunction("g_towns", "getTownByName", &TownManager::getTownByName, &g_towns);
    g_lua.bindSingletonFunction("g_towns", "addTown", &TownManager::addTown, &g_towns);
    g_lua.bindSingletonFunction("g_towns", "removeTown", &TownManager::removeTown, &g_towns);
    g_lua.bindSingletonFunction("g_towns", "getTowns", &TownManager::getTowns, &g_towns);
    g_lua.bindSingletonFunction("g_towns", "sort", &TownManager::sort, &g_towns);
#endif

    g_lua.registerSingletonClass("g_sprites");
    g_lua.bindSingletonFunction("g_sprites", "loadSpr", &SpriteManager::loadSpr, &g_sprites);

    g_lua.bindSingletonFunction("g_sprites", "unload", &SpriteManager::unload, &g_sprites);
    g_lua.bindSingletonFunction("g_sprites", "isLoaded", &SpriteManager::isLoaded, &g_sprites);
    g_lua.bindSingletonFunction("g_sprites", "getSprSignature", &SpriteManager::getSignature, &g_sprites);
    g_lua.bindSingletonFunction("g_sprites", "getSpritesCount", &SpriteManager::getSpritesCount, &g_sprites);

#ifdef FRAMEWORK_EDITOR
    g_lua.bindSingletonFunction("g_sprites", "saveSpr", &SpriteManager::saveSpr, &g_sprites);
#endif

    g_lua.registerSingletonClass("g_spriteAppearances");
    g_lua.bindSingletonFunction("g_spriteAppearances", "saveSpriteToFile", &SpriteAppearances::saveSpriteToFile, &g_spriteAppearances);
    g_lua.bindSingletonFunction("g_spriteAppearances", "saveSheetToFileBySprite", &SpriteAppearances::saveSheetToFileBySprite, &g_spriteAppearances);

    g_lua.registerSingletonClass("g_map");
    g_lua.bindSingletonFunction("g_map", "isLookPossible", &Map::isLookPossible, &g_map);
    g_lua.bindSingletonFunction("g_map", "isCovered", &Map::isCovered, &g_map);
    g_lua.bindSingletonFunction("g_map", "isCompletelyCovered", &Map::isCompletelyCovered, &g_map);
    g_lua.bindSingletonFunction("g_map", "addThing", &Map::addThing, &g_map);
    g_lua.bindSingletonFunction("g_map", "addStaticText", &Map::addStaticText, &g_map);
    g_lua.bindSingletonFunction("g_map", "addAnimatedText", &Map::addAnimatedText, &g_map);
    g_lua.bindSingletonFunction("g_map", "getThing", &Map::getThing, &g_map);
    g_lua.bindSingletonFunction("g_map", "removeThingByPos", &Map::removeThingByPos, &g_map);
    g_lua.bindSingletonFunction("g_map", "removeThing", &Map::removeThing, &g_map);
    g_lua.bindSingletonFunction("g_map", "removeThingColor", &Map::removeThingColor, &g_map);
    g_lua.bindSingletonFunction("g_map", "colorizeThing", &Map::colorizeThing, &g_map);
    g_lua.bindSingletonFunction("g_map", "clean", &Map::clean, &g_map);
    g_lua.bindSingletonFunction("g_map", "cleanTile", &Map::cleanTile, &g_map);
    g_lua.bindSingletonFunction("g_map", "cleanTexts", &Map::cleanTexts, &g_map);
    g_lua.bindSingletonFunction("g_map", "getTile", &Map::getTile, &g_map);
    g_lua.bindSingletonFunction("g_map", "getTiles", &Map::getTiles, &g_map);
    g_lua.bindSingletonFunction("g_map", "setCentralPosition", &Map::setCentralPosition, &g_map);
    g_lua.bindSingletonFunction("g_map", "getCentralPosition", &Map::getCentralPosition, &g_map);
    g_lua.bindSingletonFunction("g_map", "getCreatureById", &Map::getCreatureById, &g_map);
    g_lua.bindSingletonFunction("g_map", "removeCreatureById", &Map::removeCreatureById, &g_map);
    g_lua.bindSingletonFunction("g_map", "getSpectators", &Map::getSpectators, &g_map);
    g_lua.bindSingletonFunction("g_map", "getSpectatorsInRange", &Map::getSpectatorsInRange, &g_map);
    g_lua.bindSingletonFunction("g_map", "getSpectatorsInRangeEx", &Map::getSpectatorsInRangeEx, &g_map);
    g_lua.bindSingletonFunction("g_map", "findPath", &Map::findPath, &g_map);
    g_lua.bindSingletonFunction("g_map", "createTile", &Map::createTile, &g_map);
    g_lua.bindSingletonFunction("g_map", "setWidth", &Map::setWidth, &g_map);
    g_lua.bindSingletonFunction("g_map", "setHeight", &Map::setHeight, &g_map);
    g_lua.bindSingletonFunction("g_map", "getSize", &Map::getSize, &g_map);

#ifdef FRAMEWORK_EDITOR
    g_lua.bindSingletonFunction("g_map", "loadOtbm", &Map::loadOtbm, &g_map);
    g_lua.bindSingletonFunction("g_map", "saveOtbm", &Map::saveOtbm, &g_map);
    g_lua.bindSingletonFunction("g_map", "loadOtcm", &Map::loadOtcm, &g_map);
    g_lua.bindSingletonFunction("g_map", "saveOtcm", &Map::saveOtcm, &g_map);
    g_lua.bindSingletonFunction("g_map", "getHouseFile", &Map::getHouseFile, &g_map);
    g_lua.bindSingletonFunction("g_map", "setHouseFile", &Map::setHouseFile, &g_map);
    g_lua.bindSingletonFunction("g_map", "getSpawnFile", &Map::getSpawnFile, &g_map);
    g_lua.bindSingletonFunction("g_map", "setSpawnFile", &Map::setSpawnFile, &g_map);
    g_lua.bindSingletonFunction("g_map", "setDescription", &Map::setDescription, &g_map);
    g_lua.bindSingletonFunction("g_map", "getDescriptions", &Map::getDescriptions, &g_map);
    g_lua.bindSingletonFunction("g_map", "clearDescriptions", &Map::clearDescriptions, &g_map);
    g_lua.bindSingletonFunction("g_map", "setShowZone", &Map::setShowZone, &g_map);
    g_lua.bindSingletonFunction("g_map", "setShowZones", &Map::setShowZones, &g_map);
    g_lua.bindSingletonFunction("g_map", "setZoneColor", &Map::setZoneColor, &g_map);
    g_lua.bindSingletonFunction("g_map", "setZoneOpacity", &Map::setZoneOpacity, &g_map);
    g_lua.bindSingletonFunction("g_map", "getZoneOpacity", &Map::getZoneOpacity, &g_map);
    g_lua.bindSingletonFunction("g_map", "getZoneColor", &Map::getZoneColor, &g_map);
    g_lua.bindSingletonFunction("g_map", "showZones", &Map::showZones, &g_map);
    g_lua.bindSingletonFunction("g_map", "showZone", &Map::showZone, &g_map);
    g_lua.bindSingletonFunction("g_map", "setForceShowAnimations", &Map::setForceShowAnimations, &g_map);
    g_lua.bindSingletonFunction("g_map", "isForcingAnimations", &Map::isForcingAnimations, &g_map);
    g_lua.bindSingletonFunction("g_map", "isShowingAnimations", &Map::isShowingAnimations, &g_map);
    g_lua.bindSingletonFunction("g_map", "setShowAnimations", &Map::setShowAnimations, &g_map);
#endif
    g_lua.bindSingletonFunction("g_map", "beginGhostMode", &Map::beginGhostMode, &g_map);
    g_lua.bindSingletonFunction("g_map", "endGhostMode", &Map::endGhostMode, &g_map);
    g_lua.bindSingletonFunction("g_map", "findItemsById", &Map::findItemsById, &g_map);
    g_lua.bindSingletonFunction("g_map", "setFloatingEffect", &Map::setFloatingEffect, &g_map);
    g_lua.bindSingletonFunction("g_map", "isDrawingFloatingEffects", &Map::isDrawingFloatingEffects, &g_map);

    g_lua.bindSingletonFunction("g_map", "getMinimapColor", &Map::getMinimapColor, &g_map);
    g_lua.bindSingletonFunction("g_map", "isSightClear", &Map::isSightClear, &g_map);

    g_lua.bindSingletonFunction("g_map", "findEveryPath", &Map::findEveryPath, &g_map);
    g_lua.bindSingletonFunction("g_map", "getSpectatorsByPattern", &Map::getSpectatorsByPattern, &g_map);

    g_lua.registerSingletonClass("g_minimap");
    g_lua.bindSingletonFunction("g_minimap", "clean", &Minimap::clean, &g_minimap);
    g_lua.bindSingletonFunction("g_minimap", "loadImage", &Minimap::loadImage, &g_minimap);
    g_lua.bindSingletonFunction("g_minimap", "saveImage", &Minimap::saveImage, &g_minimap);
    g_lua.bindSingletonFunction("g_minimap", "loadOtmm", &Minimap::loadOtmm, &g_minimap);
    g_lua.bindSingletonFunction("g_minimap", "saveOtmm", &Minimap::saveOtmm, &g_minimap);

#ifdef FRAMEWORK_EDITOR
    g_lua.registerSingletonClass("g_creatures");
    g_lua.bindSingletonFunction("g_creatures", "getCreatures", &CreatureManager::getCreatures, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "getCreatureByName", &CreatureManager::getCreatureByName, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "getCreatureByLook", &CreatureManager::getCreatureByLook, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "getSpawn", &CreatureManager::getSpawn, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "getSpawnForPlacePos", &CreatureManager::getSpawnForPlacePos, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "addSpawn", &CreatureManager::addSpawn, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "loadMonsters", &CreatureManager::loadMonsters, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "loadNpcs", &CreatureManager::loadNpcs, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "loadSingleCreature", &CreatureManager::loadSingleCreature, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "loadSpawns", &CreatureManager::loadSpawns, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "saveSpawns", &CreatureManager::saveSpawns, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "isLoaded", &CreatureManager::isLoaded, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "isSpawnLoaded", &CreatureManager::isSpawnLoaded, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "clear", &CreatureManager::clear, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "clearSpawns", &CreatureManager::clearSpawns, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "getSpawns", &CreatureManager::getSpawns, &g_creatures);
    g_lua.bindSingletonFunction("g_creatures", "deleteSpawn", &CreatureManager::deleteSpawn, &g_creatures);
#endif

    g_lua.registerSingletonClass("g_game");
    g_lua.bindSingletonFunction("g_game", "loginWorld", &Game::loginWorld, &g_game);
    g_lua.bindSingletonFunction("g_game", "playRecord", &Game::playRecord, &g_game);
    g_lua.bindSingletonFunction("g_game", "cancelLogin", &Game::cancelLogin, &g_game);
    g_lua.bindSingletonFunction("g_game", "forceLogout", &Game::forceLogout, &g_game);
    g_lua.bindSingletonFunction("g_game", "safeLogout", &Game::safeLogout, &g_game);
    g_lua.bindSingletonFunction("g_game", "walk", &Game::walk, &g_game);
    g_lua.bindSingletonFunction("g_game", "autoWalk", &Game::autoWalk, &g_game);
    g_lua.bindSingletonFunction("g_game", "forceWalk", &Game::forceWalk, &g_game);
    g_lua.bindSingletonFunction("g_game", "turn", &Game::turn, &g_game);
    g_lua.bindSingletonFunction("g_game", "stop", &Game::stop, &g_game);
    g_lua.bindSingletonFunction("g_game", "look", &Game::look, &g_game);
    g_lua.bindSingletonFunction("g_game", "move", &Game::move, &g_game);
    g_lua.bindSingletonFunction("g_game", "moveToParentContainer", &Game::moveToParentContainer, &g_game);
    g_lua.bindSingletonFunction("g_game", "rotate", &Game::rotate, &g_game);
    g_lua.bindSingletonFunction("g_game", "wrap", &Game::wrap, &g_game);
    g_lua.bindSingletonFunction("g_game", "use", &Game::use, &g_game);
    g_lua.bindSingletonFunction("g_game", "useWith", &Game::useWith, &g_game);
    g_lua.bindSingletonFunction("g_game", "useInventoryItem", &Game::useInventoryItem, &g_game);
    g_lua.bindSingletonFunction("g_game", "useInventoryItemWith", &Game::useInventoryItemWith, &g_game);
    g_lua.bindSingletonFunction("g_game", "findItemInContainers", &Game::findItemInContainers, &g_game);
    g_lua.bindSingletonFunction("g_game", "open", &Game::open, &g_game);
    g_lua.bindSingletonFunction("g_game", "openParent", &Game::openParent, &g_game);
    g_lua.bindSingletonFunction("g_game", "close", &Game::close, &g_game);
    g_lua.bindSingletonFunction("g_game", "refreshContainer", &Game::refreshContainer, &g_game);
    g_lua.bindSingletonFunction("g_game", "attack", &Game::attack, &g_game);
    g_lua.bindSingletonFunction("g_game", "cancelAttack", &Game::cancelAttack, &g_game);
    g_lua.bindSingletonFunction("g_game", "follow", &Game::follow, &g_game);
    g_lua.bindSingletonFunction("g_game", "cancelFollow", &Game::cancelFollow, &g_game);
    g_lua.bindSingletonFunction("g_game", "cancelAttackAndFollow", &Game::cancelAttackAndFollow, &g_game);
    g_lua.bindSingletonFunction("g_game", "talk", &Game::talk, &g_game);
    g_lua.bindSingletonFunction("g_game", "talkChannel", &Game::talkChannel, &g_game);
    g_lua.bindSingletonFunction("g_game", "talkPrivate", &Game::talkPrivate, &g_game);
    g_lua.bindSingletonFunction("g_game", "openPrivateChannel", &Game::openPrivateChannel, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestChannels", &Game::requestChannels, &g_game);
    g_lua.bindSingletonFunction("g_game", "joinChannel", &Game::joinChannel, &g_game);
    g_lua.bindSingletonFunction("g_game", "leaveChannel", &Game::leaveChannel, &g_game);
    g_lua.bindSingletonFunction("g_game", "closeNpcChannel", &Game::closeNpcChannel, &g_game);
    g_lua.bindSingletonFunction("g_game", "openOwnChannel", &Game::openOwnChannel, &g_game);
    g_lua.bindSingletonFunction("g_game", "inviteToOwnChannel", &Game::inviteToOwnChannel, &g_game);
    g_lua.bindSingletonFunction("g_game", "excludeFromOwnChannel", &Game::excludeFromOwnChannel, &g_game);
    g_lua.bindSingletonFunction("g_game", "partyInvite", &Game::partyInvite, &g_game);
    g_lua.bindSingletonFunction("g_game", "partyJoin", &Game::partyJoin, &g_game);
    g_lua.bindSingletonFunction("g_game", "partyRevokeInvitation", &Game::partyRevokeInvitation, &g_game);
    g_lua.bindSingletonFunction("g_game", "partyPassLeadership", &Game::partyPassLeadership, &g_game);
    g_lua.bindSingletonFunction("g_game", "partyLeave", &Game::partyLeave, &g_game);
    g_lua.bindSingletonFunction("g_game", "partyShareExperience", &Game::partyShareExperience, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestOutfit", &Game::requestOutfit, &g_game);
    g_lua.bindSingletonFunction("g_game", "changeOutfit", &Game::changeOutfit, &g_game);
    g_lua.bindSingletonFunction("g_game", "addVip", &Game::addVip, &g_game);
    g_lua.bindSingletonFunction("g_game", "removeVip", &Game::removeVip, &g_game);
    g_lua.bindSingletonFunction("g_game", "editVip", &Game::editVip, &g_game);
    g_lua.bindSingletonFunction("g_game", "editVipGroups", &Game::editVipGroups, &g_game);
    g_lua.bindSingletonFunction("g_game", "setChaseMode", &Game::setChaseMode, &g_game);
    g_lua.bindSingletonFunction("g_game", "setFightMode", &Game::setFightMode, &g_game);
    g_lua.bindSingletonFunction("g_game", "setPVPMode", &Game::setPVPMode, &g_game);
    g_lua.bindSingletonFunction("g_game", "setSafeFight", &Game::setSafeFight, &g_game);
    g_lua.bindSingletonFunction("g_game", "getChaseMode", &Game::getChaseMode, &g_game);
    g_lua.bindSingletonFunction("g_game", "getFightMode", &Game::getFightMode, &g_game);
    g_lua.bindSingletonFunction("g_game", "getPVPMode", &Game::getPVPMode, &g_game);
    g_lua.bindSingletonFunction("g_game", "getUnjustifiedPoints", &Game::getUnjustifiedPoints, &g_game);
    g_lua.bindSingletonFunction("g_game", "getOpenPvpSituations", &Game::getOpenPvpSituations, &g_game);
    g_lua.bindSingletonFunction("g_game", "isSafeFight", &Game::isSafeFight, &g_game);
    g_lua.bindSingletonFunction("g_game", "inspectNpcTrade", &Game::inspectNpcTrade, &g_game);
    g_lua.bindSingletonFunction("g_game", "buyItem", &Game::buyItem, &g_game);
    g_lua.bindSingletonFunction("g_game", "sellItem", &Game::sellItem, &g_game);
    g_lua.bindSingletonFunction("g_game", "closeNpcTrade", &Game::closeNpcTrade, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestTrade", &Game::requestTrade, &g_game);
    g_lua.bindSingletonFunction("g_game", "inspectTrade", &Game::inspectTrade, &g_game);
    g_lua.bindSingletonFunction("g_game", "acceptTrade", &Game::acceptTrade, &g_game);
    g_lua.bindSingletonFunction("g_game", "rejectTrade", &Game::rejectTrade, &g_game);
    g_lua.bindSingletonFunction("g_game", "openRuleViolation", &Game::openRuleViolation, &g_game);
    g_lua.bindSingletonFunction("g_game", "closeRuleViolation", &Game::closeRuleViolation, &g_game);
    g_lua.bindSingletonFunction("g_game", "cancelRuleViolation", &Game::cancelRuleViolation, &g_game);
    g_lua.bindSingletonFunction("g_game", "reportBug", &Game::reportBug, &g_game);
    g_lua.bindSingletonFunction("g_game", "reportRuleViolation", &Game::reportRuleViolation, &g_game);
    g_lua.bindSingletonFunction("g_game", "debugReport", &Game::debugReport, &g_game);
    g_lua.bindSingletonFunction("g_game", "editText", &Game::editText, &g_game);
    g_lua.bindSingletonFunction("g_game", "editList", &Game::editList, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestQuestLog", &Game::requestQuestLog, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestQuestLine", &Game::requestQuestLine, &g_game);
    g_lua.bindSingletonFunction("g_game", "equipItem", &Game::equipItem, &g_game);
    g_lua.bindSingletonFunction("g_game", "mount", &Game::mount, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestItemInfo", &Game::requestItemInfo, &g_game);
    g_lua.bindSingletonFunction("g_game", "ping", &Game::ping, &g_game);
    g_lua.bindSingletonFunction("g_game", "setPingDelay", &Game::setPingDelay, &g_game);
    g_lua.bindSingletonFunction("g_game", "changeMapAwareRange", &Game::changeMapAwareRange, &g_game);
    g_lua.bindSingletonFunction("g_game", "canReportBugs", &Game::canReportBugs, &g_game);
    g_lua.bindSingletonFunction("g_game", "isOnline", &Game::isOnline, &g_game);
    g_lua.bindSingletonFunction("g_game", "isLogging", &Game::isLogging, &g_game);
    g_lua.bindSingletonFunction("g_game", "isDead", &Game::isDead, &g_game);
    g_lua.bindSingletonFunction("g_game", "isAttacking", &Game::isAttacking, &g_game);
    g_lua.bindSingletonFunction("g_game", "isFollowing", &Game::isFollowing, &g_game);
    g_lua.bindSingletonFunction("g_game", "isConnectionOk", &Game::isConnectionOk, &g_game);
    g_lua.bindSingletonFunction("g_game", "getPing", &Game::getPing, &g_game);
    g_lua.bindSingletonFunction("g_game", "getContainer", &Game::getContainer, &g_game);
    g_lua.bindSingletonFunction("g_game", "getContainers", &Game::getContainers, &g_game);
    g_lua.bindSingletonFunction("g_game", "getVips", &Game::getVips, &g_game);
    g_lua.bindSingletonFunction("g_game", "getAttackingCreature", &Game::getAttackingCreature, &g_game);
    g_lua.bindSingletonFunction("g_game", "getFollowingCreature", &Game::getFollowingCreature, &g_game);
    g_lua.bindSingletonFunction("g_game", "getServerBeat", &Game::getServerBeat, &g_game);
    g_lua.bindSingletonFunction("g_game", "getLocalPlayer", &Game::getLocalPlayer, &g_game);
    g_lua.bindSingletonFunction("g_game", "getProtocolGame", &Game::getProtocolGame, &g_game);
    g_lua.bindSingletonFunction("g_game", "getProtocolVersion", &Game::getProtocolVersion, &g_game);
    g_lua.bindSingletonFunction("g_game", "setProtocolVersion", &Game::setProtocolVersion, &g_game);
    g_lua.bindSingletonFunction("g_game", "getClientVersion", &Game::getClientVersion, &g_game);
    g_lua.bindSingletonFunction("g_game", "setClientVersion", &Game::setClientVersion, &g_game);
    g_lua.bindSingletonFunction("g_game", "setCustomOs", &Game::setCustomOs, &g_game);
    g_lua.bindSingletonFunction("g_game", "getOs", &Game::getOs, &g_game);
    g_lua.bindSingletonFunction("g_game", "getCharacterName", &Game::getCharacterName, &g_game);
    g_lua.bindSingletonFunction("g_game", "getWorldName", &Game::getWorldName, &g_game);
    g_lua.bindSingletonFunction("g_game", "getGMActions", &Game::getGMActions, &g_game);
    g_lua.bindSingletonFunction("g_game", "getFeature", &Game::getFeature, &g_game);
    g_lua.bindSingletonFunction("g_game", "setFeature", &Game::setFeature, &g_game);
    g_lua.bindSingletonFunction("g_game", "enableFeature", &Game::enableFeature, &g_game);
    g_lua.bindSingletonFunction("g_game", "disableFeature", &Game::disableFeature, &g_game);
    g_lua.bindSingletonFunction("g_game", "isGM", &Game::isGM, &g_game);
    g_lua.bindSingletonFunction("g_game", "answerModalDialog", &Game::answerModalDialog, &g_game);
    g_lua.bindSingletonFunction("g_game", "browseField", &Game::browseField, &g_game);
    g_lua.bindSingletonFunction("g_game", "seekInContainer", &Game::seekInContainer, &g_game);
    g_lua.bindSingletonFunction("g_game", "buyStoreOffer", &Game::buyStoreOffer, &g_game);
    g_lua.bindSingletonFunction("g_game", "sendRequestStoreSearch", &Game::sendRequestStoreSearch, &g_game);
    g_lua.bindSingletonFunction("g_game", "sendRequestStoreOfferById", &Game::sendRequestStoreOfferById, &g_game);
    g_lua.bindSingletonFunction("g_game", "sendRequestStorePremiumBoost", &Game::sendRequestStorePremiumBoost, &g_game);
    g_lua.bindSingletonFunction("g_game", "sendRequestUsefulThings", &Game::sendRequestUsefulThings, &g_game);
    g_lua.bindSingletonFunction("g_game", "sendRequestStoreHome", &Game::sendRequestStoreHome, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestTransactionHistory", &Game::requestTransactionHistory, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestStoreOffers", &Game::requestStoreOffers, &g_game);
    g_lua.bindSingletonFunction("g_game", "openStore", &Game::openStore, &g_game);
    g_lua.bindSingletonFunction("g_game", "transferCoins", &Game::transferCoins, &g_game);
    g_lua.bindSingletonFunction("g_game", "openTransactionHistory", &Game::openTransactionHistory, &g_game);
    g_lua.bindSingletonFunction("g_game", "leaveMarket", &Game::leaveMarket, &g_game);
    g_lua.bindSingletonFunction("g_game", "browseMarket", &Game::browseMarket, &g_game);
    g_lua.bindSingletonFunction("g_game", "createMarketOffer", &Game::createMarketOffer, &g_game);
    g_lua.bindSingletonFunction("g_game", "cancelMarketOffer", &Game::cancelMarketOffer, &g_game);
    g_lua.bindSingletonFunction("g_game", "acceptMarketOffer", &Game::acceptMarketOffer, &g_game);
    g_lua.bindSingletonFunction("g_game", "preyAction", &Game::preyAction, &g_game);
    g_lua.bindSingletonFunction("g_game", "preyRequest", &Game::preyRequest, &g_game);
    g_lua.bindSingletonFunction("g_game", "applyImbuement", &Game::applyImbuement, &g_game);
    g_lua.bindSingletonFunction("g_game", "clearImbuement", &Game::clearImbuement, &g_game);
    g_lua.bindSingletonFunction("g_game", "closeImbuingWindow", &Game::closeImbuingWindow, &g_game);
    g_lua.bindSingletonFunction("g_game", "isUsingProtobuf", &Game::isUsingProtobuf, &g_game);
    g_lua.bindSingletonFunction("g_game", "enableTileThingLuaCallback", &Game::enableTileThingLuaCallback, &g_game);
    g_lua.bindSingletonFunction("g_game", "isTileThingLuaCallbackEnabled", &Game::isTileThingLuaCallbackEnabled, &g_game);
    g_lua.bindSingletonFunction("g_game", "stashWithdraw", &Game::stashWithdraw, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestHighscore", &Game::requestHighscore, &g_game);
    g_lua.bindSingletonFunction("g_game", "imbuementDurations", &Game::imbuementDurations, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestBless", &Game::requestBless, &g_game);
    g_lua.bindSingletonFunction("g_game", "sendQuickLoot", &Game::sendQuickLoot, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestQuickLootBlackWhiteList", &Game::requestQuickLootBlackWhiteList, &g_game);
    g_lua.bindSingletonFunction("g_game", "openContainerQuickLoot", &Game::openContainerQuickLoot, &g_game);
    g_lua.bindSingletonFunction("g_game", "sendGmTeleport", &Game::sendGmTeleport, &g_game);
    g_lua.bindSingletonFunction("g_game", "inspectionNormalObject", &Game::inspectionNormalObject, &g_game);
    g_lua.bindSingletonFunction("g_game", "inspectionObject", &Game::inspectionObject, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestBestiary", &Game::requestBestiary, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestBestiaryOverview", &Game::requestBestiaryOverview, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestBestiarySearch", &Game::requestBestiarySearch, &g_game);
    g_lua.bindSingletonFunction("g_game", "BuyCharmRune", &Game::requestSendBuyCharmRune, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestCharacterInfo", &Game::requestSendCharacterInfo, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestBosstiaryInfo", &Game::requestBosstiaryInfo, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestBossSlootInfo", &Game::requestBossSlootInfo, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestBossSlotAction", &Game::requestBossSlotAction, &g_game);
    g_lua.bindSingletonFunction("g_game", "sendStatusTrackerBestiary", &Game::sendStatusTrackerBestiary, &g_game);
    g_lua.bindSingletonFunction("g_game", "sendCyclopediaHouseAuction", &Game::requestSendCyclopediaHouseAuction, &g_game);
    g_lua.bindSingletonFunction("g_game", "getWalkMaxSteps", &Game::getWalkMaxSteps, &g_game);
    g_lua.bindSingletonFunction("g_game", "setWalkMaxSteps", &Game::setWalkMaxSteps, &g_game);
    g_lua.bindSingletonFunction("g_game", "sendOpenRewardWall", &Game::sendOpenRewardWall, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestOpenRewardHistory", &Game::requestOpenRewardHistory, &g_game);
    g_lua.bindSingletonFunction("g_game", "requestGetRewardDaily", &Game::requestGetRewardDaily, &g_game);
    g_lua.bindSingletonFunction("g_game", "sendRequestTrackerQuestLog", &Game::sendRequestTrackerQuestLog, &g_game);

    g_lua.registerSingletonClass("g_gameConfig");
    g_lua.bindSingletonFunction("g_gameConfig", "loadFonts", &GameConfig::loadFonts, &g_gameConfig);
    g_lua.bindSingletonFunction("g_gameConfig", "getSpriteSize", &GameConfig::getSpriteSize, &g_gameConfig);
    g_lua.bindSingletonFunction("g_gameConfig", "isDrawingInformationByWidget", &GameConfig::isDrawingInformationByWidget, &g_gameConfig);
    g_lua.bindSingletonFunction("g_gameConfig", "isAdjustCreatureInformationBasedCropSize", &GameConfig::isAdjustCreatureInformationBasedCropSize, &g_gameConfig);

    g_lua.bindSingletonFunction("g_gameConfig", "getShieldBlinkTicks", &GameConfig::getShieldBlinkTicks, &g_gameConfig);
    g_lua.bindSingletonFunction("g_gameConfig", "getCreatureNameFontName", &GameConfig::getCreatureNameFontName, &g_gameConfig);
    g_lua.bindSingletonFunction("g_gameConfig", "getAnimatedTextFontName", &GameConfig::getAnimatedTextFontName, &g_gameConfig);
    g_lua.bindSingletonFunction("g_gameConfig", "getStaticTextFontName", &GameConfig::getStaticTextFontName, &g_gameConfig);
    g_lua.bindSingletonFunction("g_gameConfig", "getWidgetTextFontName", &GameConfig::getWidgetTextFontName, &g_gameConfig);

    g_lua.registerSingletonClass("g_client");
    g_lua.bindSingletonFunction("g_client", "setEffectAlpha", &Client::setEffectAlpha, &g_client);
    g_lua.bindSingletonFunction("g_client", "setMissileAlpha", &Client::setMissileAlpha, &g_client);

    g_lua.registerSingletonClass("g_attachedEffects");
    g_lua.bindSingletonFunction("g_attachedEffects", "getById", &AttachedEffectManager::getById, &g_attachedEffects);
    g_lua.bindSingletonFunction("g_attachedEffects", "registerByThing", &AttachedEffectManager::registerByThing, &g_attachedEffects);
    g_lua.bindSingletonFunction("g_attachedEffects", "registerByImage", &AttachedEffectManager::registerByImage, &g_attachedEffects);
    g_lua.bindSingletonFunction("g_attachedEffects", "remove", &AttachedEffectManager::remove, &g_attachedEffects);
    g_lua.bindSingletonFunction("g_attachedEffects", "clear", &AttachedEffectManager::clear, &g_attachedEffects);

    g_lua.bindGlobalFunction("getOutfitColor", Outfit::getColor);
    g_lua.bindGlobalFunction("getAngleFromPos", Position::getAngleFromPositions);
    g_lua.bindGlobalFunction("getDirectionFromPos", Position::getDirectionFromPositions);

    // Entity and UI class bindings are in separate TUs to reduce
    // template pressure and avoid MSVC ICE C1001.
    registerLuaFunctions_ClientEntities();
    registerLuaFunctions_ClientUI();
}
