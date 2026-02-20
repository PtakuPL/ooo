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

// Split from client/luafunctions.cpp to reduce template instantiation pressure
// per translation unit and avoid MSVC ICE C1001.
// This file contains entity class bindings: ProtocolGame, Container,
// AttachableObject, Thing, Creature, Player, LocalPlayer, Item, Effect,
// Missile, AttachedEffect, StaticText, AnimatedText, Tile, ThingType,
// ItemType, House, Spawn, Town, CreatureType.

#include "animatedtext.h"
#include "attachedeffect.h"
#include "attachableobject.h"
#include "container.h"
#include "creature.h"
#include "effect.h"
#include "item.h"
#include "localplayer.h"
#include "missile.h"
#include "player.h"
#include "protocolgame.h"
#include "statictext.h"
#include "thingtypemanager.h"
#include "tile.h"

#ifdef FRAMEWORK_EDITOR
#include "houses.h"
#include "towns.h"
#endif

#include <framework/luaengine/luainterface.h>

void registerLuaFunctions_ClientEntities()
{
    g_lua.registerClass<ProtocolGame, Protocol>();
    g_lua.bindClassStaticFunction<ProtocolGame>("create", [] { return std::make_shared<ProtocolGame>(); });
    g_lua.bindClassMemberFunction<ProtocolGame>("sendExtendedOpcode", &ProtocolGame::sendExtendedOpcode);

    g_lua.registerClass<Container>();
    g_lua.bindClassMemberFunction<Container>("getItem", &Container::getItem);
    g_lua.bindClassMemberFunction<Container>("getItems", &Container::getItems);
    g_lua.bindClassMemberFunction<Container>("getItemsCount", &Container::getItemsCount);
    g_lua.bindClassMemberFunction<Container>("getSlotPosition", &Container::getSlotPosition);
    g_lua.bindClassMemberFunction<Container>("getName", &Container::getName);
    g_lua.bindClassMemberFunction<Container>("getId", &Container::getId);
    g_lua.bindClassMemberFunction<Container>("getCapacity", &Container::getCapacity);
    g_lua.bindClassMemberFunction<Container>("getContainerItem", &Container::getContainerItem);
    g_lua.bindClassMemberFunction<Container>("hasParent", &Container::hasParent);
    g_lua.bindClassMemberFunction<Container>("isClosed", &Container::isClosed);
    g_lua.bindClassMemberFunction<Container>("isUnlocked", &Container::isUnlocked);
    g_lua.bindClassMemberFunction<Container>("hasPages", &Container::hasPages);
    g_lua.bindClassMemberFunction<Container>("getSize", &Container::getSize);
    g_lua.bindClassMemberFunction<Container>("getFirstIndex", &Container::getFirstIndex);

    g_lua.registerClass<AttachableObject>();
    g_lua.bindClassMemberFunction<AttachableObject>("getAttachedEffects", &AttachableObject::getAttachedEffects);
    g_lua.bindClassMemberFunction<AttachableObject>("attachEffect", &AttachableObject::attachEffect);
    g_lua.bindClassMemberFunction<AttachableObject>("detachEffect", &AttachableObject::detachEffect);
    g_lua.bindClassMemberFunction<AttachableObject>("detachEffectById", &AttachableObject::detachEffectById);
    g_lua.bindClassMemberFunction<AttachableObject>("getAttachedEffectById", &AttachableObject::getAttachedEffectById);
    g_lua.bindClassMemberFunction<AttachableObject>("clearAttachedEffects", &AttachableObject::clearAttachedEffects);
    g_lua.bindClassMemberFunction<AttachableObject>("attachParticleEffect", &AttachableObject::attachParticleEffect);
    g_lua.bindClassMemberFunction<AttachableObject>("detachParticleEffectByName", &AttachableObject::detachParticleEffectByName);
    g_lua.bindClassMemberFunction<AttachableObject>("clearAttachedParticlesEffect", &AttachableObject::clearAttachedParticlesEffect);
    g_lua.bindClassMemberFunction<AttachableObject>("getAttachedWidgets", &AttachableObject::getAttachedWidgets);
    g_lua.bindClassMemberFunction<AttachableObject>("attachWidget", &AttachableObject::attachWidget);
    g_lua.bindClassMemberFunction<AttachableObject>("detachWidget", &AttachableObject::detachWidget);
    g_lua.bindClassMemberFunction<AttachableObject>("detachWidgetById", &AttachableObject::detachWidgetById);
    g_lua.bindClassMemberFunction<AttachableObject>("getAttachedWidgetById", &AttachableObject::getAttachedWidgetById);

    g_lua.registerClass<Thing, AttachableObject>();
    g_lua.bindClassMemberFunction<Thing>("setId", &Thing::setId);
    g_lua.bindClassMemberFunction<Thing>("setShader", &Thing::setShader);
    g_lua.bindClassMemberFunction<Thing>("setPosition", &Thing::setPosition);
    g_lua.bindClassMemberFunction<Thing>("setMarked", &Thing::lua_setMarked);
    g_lua.bindClassMemberFunction<Thing>("setAnimate", &Thing::setAnimate);
    g_lua.bindClassMemberFunction<Thing>("isMarked", &Thing::isMarked);
    g_lua.bindClassMemberFunction<Thing>("getId", &Thing::getId);
    g_lua.bindClassMemberFunction<Thing>("getTile", &Thing::getTile);
    g_lua.bindClassMemberFunction<Thing>("getPosition", &Thing::getPosition);
    g_lua.bindClassMemberFunction<Thing>("getStackPos", &Thing::getStackPos);
    g_lua.bindClassMemberFunction<Thing>("getMarketData", &Thing::getMarketData);
    g_lua.bindClassMemberFunction<Thing>("getNpcSaleData", &Thing::getNpcSaleData);
    g_lua.bindClassMemberFunction<Thing>("getMeanPrice", &Thing::getMeanPrice);
    g_lua.bindClassMemberFunction<Thing>("getStackPriority", &Thing::getStackPriority);
    g_lua.bindClassMemberFunction<Thing>("getParentContainer", &Thing::getParentContainer);
    g_lua.bindClassMemberFunction<Thing>("isItem", &Thing::isItem);
    g_lua.bindClassMemberFunction<Thing>("isMonster", &Thing::isMonster);
    g_lua.bindClassMemberFunction<Thing>("isNpc", &Thing::isNpc);
    g_lua.bindClassMemberFunction<Thing>("isCreature", &Thing::isCreature);
    g_lua.bindClassMemberFunction<Thing>("isEffect", &Thing::isEffect);
    g_lua.bindClassMemberFunction<Thing>("isMissile", &Thing::isMissile);
    g_lua.bindClassMemberFunction<Thing>("isPlayer", &Thing::isPlayer);
    g_lua.bindClassMemberFunction<Thing>("isLocalPlayer", &Thing::isLocalPlayer);
    g_lua.bindClassMemberFunction<Thing>("isGround", &Thing::isGround);
    g_lua.bindClassMemberFunction<Thing>("isGroundBorder", &Thing::isGroundBorder);
    g_lua.bindClassMemberFunction<Thing>("isOnBottom", &Thing::isOnBottom);
    g_lua.bindClassMemberFunction<Thing>("isOnTop", &Thing::isOnTop);
    g_lua.bindClassMemberFunction<Thing>("isContainer", &Thing::isContainer);
    g_lua.bindClassMemberFunction<Thing>("isForceUse", &Thing::isForceUse);
    g_lua.bindClassMemberFunction<Thing>("isMultiUse", &Thing::isMultiUse);
    g_lua.bindClassMemberFunction<Thing>("isRotateable", &Thing::isRotateable);
    g_lua.bindClassMemberFunction<Thing>("isNotMoveable", &Thing::isNotMoveable);
    g_lua.bindClassMemberFunction<Thing>("isPickupable", &Thing::isPickupable);
    g_lua.bindClassMemberFunction<Thing>("isIgnoreLook", &Thing::isIgnoreLook);
    g_lua.bindClassMemberFunction<Thing>("isStackable", &Thing::isStackable);
    g_lua.bindClassMemberFunction<Thing>("isHookSouth", &Thing::isHookSouth);
    g_lua.bindClassMemberFunction<Thing>("isTranslucent", &Thing::isTranslucent);
    g_lua.bindClassMemberFunction<Thing>("isFullGround", &Thing::isFullGround);
    g_lua.bindClassMemberFunction<Thing>("isMarketable", &Thing::isMarketable);
    g_lua.bindClassMemberFunction<Thing>("isUsable", &Thing::isUsable);
    g_lua.bindClassMemberFunction<Thing>("isWrapable", &Thing::isWrapable);
    g_lua.bindClassMemberFunction<Thing>("isUnwrapable", &Thing::isUnwrapable);
    g_lua.bindClassMemberFunction<Thing>("isTopEffect", &Thing::isTopEffect);
    g_lua.bindClassMemberFunction<Thing>("isLyingCorpse", &Thing::isLyingCorpse);
    g_lua.bindClassMemberFunction<Thing>("getDefaultAction", &Thing::getDefaultAction);
    g_lua.bindClassMemberFunction<Thing>("getClassification", &Thing::getClassification);
    g_lua.bindClassMemberFunction<Thing>("setHighlight", &Thing::lua_setHighlight);
    g_lua.bindClassMemberFunction<Thing>("isHighlighted", &Thing::isHighlighted);
    g_lua.bindClassMemberFunction<Thing>("getExactSize", &Thing::getExactSize);
    g_lua.bindClassMemberFunction<Thing>("getScaleFactor", &Thing::getScaleFactor);
    g_lua.bindClassMemberFunction<Thing>("setScaleFactor", &Thing::setScaleFactor);
    g_lua.bindClassMemberFunction<Thing>("canAnimate", &Thing::canAnimate);

#ifdef FRAMEWORK_EDITOR
    g_lua.registerClass<House>();
    g_lua.bindClassStaticFunction<House>("create", [] { return std::make_shared<House>(); });
    g_lua.bindClassMemberFunction<House>("setId", &House::setId);
    g_lua.bindClassMemberFunction<House>("getId", &House::getId);
    g_lua.bindClassMemberFunction<House>("setName", &House::setName);
    g_lua.bindClassMemberFunction<House>("getName", &House::getName);
    g_lua.bindClassMemberFunction<House>("setTownId", &House::setTownId);
    g_lua.bindClassMemberFunction<House>("getTownId", &House::getTownId);
    g_lua.bindClassMemberFunction<House>("setTile", &House::setTile);
    g_lua.bindClassMemberFunction<House>("getTile", &House::getTile);
    g_lua.bindClassMemberFunction<House>("setEntry", &House::setEntry);
    g_lua.bindClassMemberFunction<House>("getEntry", &House::getEntry);
    g_lua.bindClassMemberFunction<House>("addDoor", &House::addDoor);
    g_lua.bindClassMemberFunction<House>("removeDoor", &House::removeDoor);
    g_lua.bindClassMemberFunction<House>("removeDoorById", &House::removeDoorById);
    g_lua.bindClassMemberFunction<House>("setSize", &House::setSize);
    g_lua.bindClassMemberFunction<House>("getSize", &House::getSize);
    g_lua.bindClassMemberFunction<House>("setRent", &House::setRent);
    g_lua.bindClassMemberFunction<House>("getRent", &House::getRent);

    g_lua.registerClass<Spawn>();
    g_lua.bindClassStaticFunction<Spawn>("create", [] { return std::make_shared<Spawn>(); });
    g_lua.bindClassMemberFunction<Spawn>("setRadius", &Spawn::setRadius);
    g_lua.bindClassMemberFunction<Spawn>("getRadius", &Spawn::getRadius);
    g_lua.bindClassMemberFunction<Spawn>("setCenterPos", &Spawn::setCenterPos);
    g_lua.bindClassMemberFunction<Spawn>("getCenterPos", &Spawn::getCenterPos);
    g_lua.bindClassMemberFunction<Spawn>("addCreature", &Spawn::addCreature);
    g_lua.bindClassMemberFunction<Spawn>("removeCreature", &Spawn::removeCreature);
    g_lua.bindClassMemberFunction<Spawn>("getCreatures", &Spawn::getCreatures);

    g_lua.registerClass<Town>();
    g_lua.bindClassStaticFunction<Town>("create", [] { return std::make_shared<Town>(); });
    g_lua.bindClassMemberFunction<Town>("setId", &Town::setId);
    g_lua.bindClassMemberFunction<Town>("setName", &Town::setName);
    g_lua.bindClassMemberFunction<Town>("setPos", &Town::setPos);
    g_lua.bindClassMemberFunction<Town>("setTemplePos", &Town::setPos); // alternative method
    g_lua.bindClassMemberFunction<Town>("getId", &Town::getId);
    g_lua.bindClassMemberFunction<Town>("getName", &Town::getName);
    g_lua.bindClassMemberFunction<Town>("getPos", &Town::getPos);
    g_lua.bindClassMemberFunction<Town>("getTemplePos", &Town::getPos); // alternative method

    g_lua.registerClass<CreatureType>();
    g_lua.bindClassStaticFunction<CreatureType>("create", [] { return std::make_shared<CreatureType>(); });
    g_lua.bindClassMemberFunction<CreatureType>("setName", &CreatureType::setName);
    g_lua.bindClassMemberFunction<CreatureType>("setOutfit", &CreatureType::setOutfit);
    g_lua.bindClassMemberFunction<CreatureType>("setSpawnTime", &CreatureType::setSpawnTime);
    g_lua.bindClassMemberFunction<CreatureType>("getName", &CreatureType::getName);
    g_lua.bindClassMemberFunction<CreatureType>("getOutfit", &CreatureType::getOutfit);
    g_lua.bindClassMemberFunction<CreatureType>("getSpawnTime", &CreatureType::getSpawnTime);
    g_lua.bindClassMemberFunction<CreatureType>("cast", &CreatureType::cast);
#endif

    g_lua.registerClass<Creature, Thing>();
    g_lua.bindClassStaticFunction<Creature>("create", [] { return std::make_shared<Creature>(); });
    g_lua.bindClassMemberFunction<Creature>("getId", &Creature::getId);
    g_lua.bindClassMemberFunction<Creature>("getMasterId", &Creature::getMasterId);
    g_lua.bindClassMemberFunction<Creature>("getName", &Creature::getName);
    g_lua.bindClassMemberFunction<Creature>("getHealthPercent", &Creature::getHealthPercent);
    g_lua.bindClassMemberFunction<Creature>("getManaPercent", &Creature::getManaPercent);
    g_lua.bindClassMemberFunction<Creature>("getSpeed", &Creature::getSpeed);
    g_lua.bindClassMemberFunction<Creature>("getBaseSpeed", &Creature::getBaseSpeed);
    g_lua.bindClassMemberFunction<Creature>("getSkull", &Creature::getSkull);
    g_lua.bindClassMemberFunction<Creature>("getShield", &Creature::getShield);
    g_lua.bindClassMemberFunction<Creature>("getEmblem", &Creature::getEmblem);
    g_lua.bindClassMemberFunction<Creature>("getType", &Creature::getType);
    g_lua.bindClassMemberFunction<Creature>("getIcon", &Creature::getIcon);
    g_lua.bindClassMemberFunction<Creature>("getIcons", &Creature::getIcons);
    g_lua.bindClassMemberFunction<Creature>("setOutfit", &Creature::setOutfit);
    g_lua.bindClassMemberFunction<Creature>("getOutfit", &Creature::getOutfit);
    g_lua.bindClassMemberFunction<Creature>("getDirection", &Creature::getDirection);
    g_lua.bindClassMemberFunction<Creature>("getStepDuration", &Creature::getStepDuration);
    g_lua.bindClassMemberFunction<Creature>("getStepProgress", &Creature::getStepProgress);
    g_lua.bindClassMemberFunction<Creature>("getWalkTicksElapsed", &Creature::getWalkTicksElapsed);
    g_lua.bindClassMemberFunction<Creature>("getStepTicksLeft", &Creature::getStepTicksLeft);
    g_lua.bindClassMemberFunction<Creature>("setDirection", &Creature::setDirection);
    g_lua.bindClassMemberFunction<Creature>("setSkullTexture", &Creature::setSkullTexture);
    g_lua.bindClassMemberFunction<Creature>("setShieldTexture", &Creature::setShieldTexture);
    g_lua.bindClassMemberFunction<Creature>("setEmblemTexture", &Creature::setEmblemTexture);
    g_lua.bindClassMemberFunction<Creature>("setTypeTexture", &Creature::setTypeTexture);
    g_lua.bindClassMemberFunction<Creature>("setIconTexture", &Creature::setIconTexture);
    g_lua.bindClassMemberFunction<Creature>("setIconsTexture", &Creature::setIconsTexture);
    g_lua.bindClassMemberFunction<Creature>("setStaticWalking", &Creature::setStaticWalking);
    g_lua.bindClassMemberFunction<Creature>("setManaPercent", &Creature::setManaPercent);
    g_lua.bindClassMemberFunction<Creature>("showStaticSquare", &Creature::showStaticSquare);
    g_lua.bindClassMemberFunction<Creature>("hideStaticSquare", &Creature::hideStaticSquare);
    g_lua.bindClassMemberFunction<Creature>("isWalking", &Creature::isWalking);
    g_lua.bindClassMemberFunction<Creature>("isInvisible", &Creature::isInvisible);
    g_lua.bindClassMemberFunction<Creature>("isDead", &Creature::isDead);
    g_lua.bindClassMemberFunction<Creature>("isRemoved", &Creature::isRemoved);
    g_lua.bindClassMemberFunction<Creature>("canBeSeen", &Creature::canBeSeen);
    g_lua.bindClassMemberFunction<Creature>("jump", &Creature::jump);
    g_lua.bindClassMemberFunction<Creature>("setMountShader", &Creature::setMountShader);
    g_lua.bindClassMemberFunction<Creature>("setDrawOutfitColor", &Creature::setDrawOutfitColor);
    g_lua.bindClassMemberFunction<Creature>("setDisableWalkAnimation", &Creature::setDisableWalkAnimation);
    g_lua.bindClassMemberFunction<Creature>("isDisabledWalkAnimation", &Creature::isDisabledWalkAnimation);
    g_lua.bindClassMemberFunction<Creature>("isTimedSquareVisible", &Creature::isTimedSquareVisible);
    g_lua.bindClassMemberFunction<Creature>("getTimedSquareColor", &Creature::getTimedSquareColor);
    g_lua.bindClassMemberFunction<Creature>("isStaticSquareVisible", &Creature::isStaticSquareVisible);
    g_lua.bindClassMemberFunction<Creature>("getStaticSquareColor", &Creature::getStaticSquareColor);
    g_lua.bindClassMemberFunction<Creature>("setBounce", &Creature::setBounce);

    g_lua.bindClassMemberFunction<Creature>("setTyping", &Creature::setTyping);
    g_lua.bindClassMemberFunction<Creature>("getTyping", &Creature::getTyping);
    g_lua.bindClassMemberFunction<Creature>("sendTyping", &Creature::sendTyping);
    g_lua.bindClassMemberFunction<Creature>("setTypingIconTexture", &Creature::setTypingIconTexture);
    g_lua.bindClassMemberFunction<Creature>("getWidgetInformation", &Creature::getWidgetInformation);
    g_lua.bindClassMemberFunction<Creature>("setWidgetInformation", &Creature::setWidgetInformation);
    g_lua.bindClassMemberFunction<Creature>("isFullHealth", &Creature::isFullHealth);
    g_lua.bindClassMemberFunction<Creature>("isCovered", &Creature::isCovered);

    g_lua.bindClassMemberFunction<Creature>("setText", &Creature::setText);
    g_lua.bindClassMemberFunction<Creature>("getText", &Creature::getText);
    g_lua.bindClassMemberFunction<Creature>("clearText", &Creature::clearText);
    g_lua.bindClassMemberFunction<Creature>("canShoot", &Creature::canShoot);

#ifdef FRAMEWORK_EDITOR
    g_lua.registerClass<ItemType>();
    g_lua.bindClassMemberFunction<ItemType>("getServerId", &ItemType::getServerId);
    g_lua.bindClassMemberFunction<ItemType>("getClientId", &ItemType::getClientId);
    g_lua.bindClassMemberFunction<ItemType>("isWritable", &ItemType::isWritable);
#endif

    g_lua.registerClass<ThingType>();
    g_lua.bindClassStaticFunction<ThingType>("create", [] { return std::make_shared<ThingType>(); });
    g_lua.bindClassMemberFunction<ThingType>("getId", &ThingType::getId);
    g_lua.bindClassMemberFunction<ThingType>("getClothSlot", &ThingType::getClothSlot);
    g_lua.bindClassMemberFunction<ThingType>("getCategory", &ThingType::getCategory);
    g_lua.bindClassMemberFunction<ThingType>("getSize", &ThingType::getSize);
    g_lua.bindClassMemberFunction<ThingType>("getWidth", &ThingType::getWidth);
    g_lua.bindClassMemberFunction<ThingType>("getHeight", &ThingType::getHeight);
    g_lua.bindClassMemberFunction<ThingType>("getDisplacement", &ThingType::getDisplacement);
    g_lua.bindClassMemberFunction<ThingType>("getDisplacementX", &ThingType::getDisplacementX);
    g_lua.bindClassMemberFunction<ThingType>("getDisplacementY", &ThingType::getDisplacementY);
    g_lua.bindClassMemberFunction<ThingType>("getRealSize", &ThingType::getRealSize);
    g_lua.bindClassMemberFunction<ThingType>("getLayers", &ThingType::getLayers);
    g_lua.bindClassMemberFunction<ThingType>("getNumPatternX", &ThingType::getNumPatternX);
    g_lua.bindClassMemberFunction<ThingType>("getNumPatternY", &ThingType::getNumPatternY);
    g_lua.bindClassMemberFunction<ThingType>("getNumPatternZ", &ThingType::getNumPatternZ);
    g_lua.bindClassMemberFunction<ThingType>("getAnimationPhases", &ThingType::getAnimationPhases);
    g_lua.bindClassMemberFunction<ThingType>("getGroundSpeed", &ThingType::getGroundSpeed);
    g_lua.bindClassMemberFunction<ThingType>("getMaxTextLength", &ThingType::getMaxTextLength);
    g_lua.bindClassMemberFunction<ThingType>("getLight", &ThingType::getLight);
    g_lua.bindClassMemberFunction<ThingType>("getMinimapColor", &ThingType::getMinimapColor);
    g_lua.bindClassMemberFunction<ThingType>("getLensHelp", &ThingType::getLensHelp);
    g_lua.bindClassMemberFunction<ThingType>("getElevation", &ThingType::getElevation);
    g_lua.bindClassMemberFunction<ThingType>("isGround", &ThingType::isGround);
    g_lua.bindClassMemberFunction<ThingType>("isGroundBorder", &ThingType::isGroundBorder);
    g_lua.bindClassMemberFunction<ThingType>("isOnBottom", &ThingType::isOnBottom);
    g_lua.bindClassMemberFunction<ThingType>("isOnTop", &ThingType::isOnTop);
    g_lua.bindClassMemberFunction<ThingType>("isContainer", &ThingType::isContainer);
    g_lua.bindClassMemberFunction<ThingType>("isStackable", &ThingType::isStackable);
    g_lua.bindClassMemberFunction<ThingType>("isForceUse", &ThingType::isForceUse);
    g_lua.bindClassMemberFunction<ThingType>("isMultiUse", &ThingType::isMultiUse);
    g_lua.bindClassMemberFunction<ThingType>("isWritable", &ThingType::isWritable);
    g_lua.bindClassMemberFunction<ThingType>("isChargeable", &ThingType::isChargeable);
    g_lua.bindClassMemberFunction<ThingType>("isWritableOnce", &ThingType::isWritableOnce);
    g_lua.bindClassMemberFunction<ThingType>("isFluidContainer", &ThingType::isFluidContainer);
    g_lua.bindClassMemberFunction<ThingType>("isSplash", &ThingType::isSplash);
    g_lua.bindClassMemberFunction<ThingType>("isNotWalkable", &ThingType::isNotWalkable);
    g_lua.bindClassMemberFunction<ThingType>("isNotMoveable", &ThingType::isNotMoveable);
    g_lua.bindClassMemberFunction<ThingType>("blockProjectile", &ThingType::blockProjectile);
    g_lua.bindClassMemberFunction<ThingType>("isNotPathable", &ThingType::isNotPathable);
    g_lua.bindClassMemberFunction<ThingType>("setPathable", &ThingType::setPathable);
    g_lua.bindClassMemberFunction<ThingType>("isPickupable", &ThingType::isPickupable);
    g_lua.bindClassMemberFunction<ThingType>("isHangable", &ThingType::isHangable);
    g_lua.bindClassMemberFunction<ThingType>("isHookSouth", &ThingType::isHookSouth);
    g_lua.bindClassMemberFunction<ThingType>("isHookEast", &ThingType::isHookEast);
    g_lua.bindClassMemberFunction<ThingType>("isRotateable", &ThingType::isRotateable);
    g_lua.bindClassMemberFunction<ThingType>("hasLight", &ThingType::hasLight);
    g_lua.bindClassMemberFunction<ThingType>("isDontHide", &ThingType::isDontHide);
    g_lua.bindClassMemberFunction<ThingType>("isTranslucent", &ThingType::isTranslucent);
    g_lua.bindClassMemberFunction<ThingType>("hasDisplacement", &ThingType::hasDisplacement);
    g_lua.bindClassMemberFunction<ThingType>("hasElevation", &ThingType::hasElevation);
    g_lua.bindClassMemberFunction<ThingType>("isLyingCorpse", &ThingType::isLyingCorpse);
    g_lua.bindClassMemberFunction<ThingType>("isAnimateAlways", &ThingType::isAnimateAlways);
    g_lua.bindClassMemberFunction<ThingType>("hasMiniMapColor", &ThingType::hasMiniMapColor);
    g_lua.bindClassMemberFunction<ThingType>("hasLensHelp", &ThingType::hasLensHelp);
    g_lua.bindClassMemberFunction<ThingType>("isFullGround", &ThingType::isFullGround);
    g_lua.bindClassMemberFunction<ThingType>("isIgnoreLook", &ThingType::isIgnoreLook);
    g_lua.bindClassMemberFunction<ThingType>("isCloth", &ThingType::isCloth);
    g_lua.bindClassMemberFunction<ThingType>("isMarketable", &ThingType::isMarketable);
    g_lua.bindClassMemberFunction<ThingType>("getMarketData", &ThingType::getMarketData);
    g_lua.bindClassMemberFunction<ThingType>("getNpcSaleData", &ThingType::getNpcSaleData);
    g_lua.bindClassMemberFunction<ThingType>("getMeanPrice", &ThingType::getMeanPrice);
    g_lua.bindClassMemberFunction<ThingType>("isUsable", &ThingType::isUsable);
    g_lua.bindClassMemberFunction<ThingType>("isWrapable", &ThingType::isWrapable);
    g_lua.bindClassMemberFunction<ThingType>("isUnwrapable", &ThingType::isUnwrapable);
    g_lua.bindClassMemberFunction<ThingType>("isTopEffect", &ThingType::isTopEffect);
    g_lua.bindClassMemberFunction<ThingType>("getSprites", &ThingType::getSprites);
    g_lua.bindClassMemberFunction<ThingType>("hasAttribute", &ThingType::hasAttr);
    g_lua.bindClassMemberFunction<ThingType>("getClassification", &ThingType::getClassification);
    g_lua.bindClassMemberFunction<ThingType>("hasWearOut", &ThingType::hasWearOut);
    g_lua.bindClassMemberFunction<ThingType>("hasClockExpire", &ThingType::hasClockExpire);
    g_lua.bindClassMemberFunction<ThingType>("hasExpire", &ThingType::hasExpire);
    g_lua.bindClassMemberFunction<ThingType>("hasExpireStop", &ThingType::hasExpireStop);
    g_lua.bindClassMemberFunction<ThingType>("isPodium", &ThingType::isPodium);
    g_lua.bindClassMemberFunction<ThingType>("getDefaultAction", &ThingType::getDefaultAction);
    g_lua.bindClassMemberFunction<ThingType>("getName", &ThingType::getName);
    g_lua.bindClassMemberFunction<ThingType>("getDescription", &ThingType::getDescription);
#ifdef FRAMEWORK_EDITOR
    g_lua.bindClassMemberFunction<ThingType>("exportImage", &ThingType::exportImage);
#endif

    g_lua.registerClass<Item, Thing>();
    g_lua.bindClassStaticFunction<Item>("create", &Item::create);
    g_lua.bindClassMemberFunction<Item>("clone", &Item::clone);

    g_lua.bindClassMemberFunction<Item>("setCount", &Item::setCount);
    g_lua.bindClassMemberFunction<Item>("setTooltip", &Item::setTooltip);
    g_lua.bindClassMemberFunction<Item>("setTier", &Item::setTier);

    g_lua.bindClassMemberFunction<Item>("getCount", &Item::getCount);
    g_lua.bindClassMemberFunction<Item>("getSubType", &Item::getSubType);
    g_lua.bindClassMemberFunction<Item>("getCountOrSubType", &Item::getCountOrSubType);
    g_lua.bindClassMemberFunction<Item>("getId", &Item::getId);
    g_lua.bindClassMemberFunction<Item>("getTooltip", &Item::getTooltip);
    g_lua.bindClassMemberFunction<Item>("getDurationTime", &Item::getDurationTime);
    g_lua.bindClassMemberFunction<Item>("getTier", &Item::getTier);
    g_lua.bindClassMemberFunction<Item>("getCharges", &Item::getCharges);

    g_lua.bindClassMemberFunction<Item>("isStackable", &Item::isStackable);
    g_lua.bindClassMemberFunction<Item>("isMarketable", &Item::isMarketable);
    g_lua.bindClassMemberFunction<Item>("isFluidContainer", &Item::isFluidContainer);
    g_lua.bindClassMemberFunction<Item>("getMarketData", &Item::getMarketData);
    g_lua.bindClassMemberFunction<Item>("getNpcSaleData", &Item::getNpcSaleData);
    g_lua.bindClassMemberFunction<Item>("getMeanPrice", &Item::getMeanPrice);
    g_lua.bindClassMemberFunction<Item>("getClothSlot", &Item::getClothSlot);
    g_lua.bindClassMemberFunction<Item>("hasWearOut", &ThingType::hasWearOut);
    g_lua.bindClassMemberFunction<Item>("hasClockExpire", &ThingType::hasClockExpire);
    g_lua.bindClassMemberFunction<Item>("hasExpire", &ThingType::hasExpire);
    g_lua.bindClassMemberFunction<Item>("hasExpireStop", &ThingType::hasExpireStop);
#ifdef FRAMEWORK_EDITOR
    g_lua.bindClassMemberFunction<Item>("getName", &Item::getName);
    g_lua.bindClassMemberFunction<Item>("getServerId", &Item::getServerId);
    g_lua.bindClassStaticFunction<Item>("createOtb", &Item::createFromOtb);

    g_lua.bindClassMemberFunction<Item>("getContainerItems", &Item::getContainerItems);
    g_lua.bindClassMemberFunction<Item>("getContainerItem", &Item::getContainerItem);
    g_lua.bindClassMemberFunction<Item>("addContainerItem", &Item::addContainerItem);
    g_lua.bindClassMemberFunction<Item>("addContainerItemIndexed", &Item::addContainerItemIndexed);
    g_lua.bindClassMemberFunction<Item>("removeContainerItem", &Item::removeContainerItem);
    g_lua.bindClassMemberFunction<Item>("clearContainerItems", &Item::clearContainerItems);
    g_lua.bindClassMemberFunction<Item>("getContainerItem", &Item::getContainerItem);

    g_lua.bindClassMemberFunction<Item>("getDescription", &Item::getDescription);
    g_lua.bindClassMemberFunction<Item>("getText", &Item::getText);
    g_lua.bindClassMemberFunction<Item>("setDescription", &Item::setDescription);
    g_lua.bindClassMemberFunction<Item>("setText", &Item::setText);
    g_lua.bindClassMemberFunction<Item>("getUniqueId", &Item::getUniqueId);
    g_lua.bindClassMemberFunction<Item>("getActionId", &Item::getActionId);
    g_lua.bindClassMemberFunction<Item>("setUniqueId", &Item::setUniqueId);
    g_lua.bindClassMemberFunction<Item>("setActionId", &Item::setActionId);
    g_lua.bindClassMemberFunction<Item>("getTeleportDestination", &Item::getTeleportDestination);
    g_lua.bindClassMemberFunction<Item>("setTeleportDestination", &Item::setTeleportDestination);
#endif

    g_lua.registerClass<Effect, Thing>();
    g_lua.bindClassStaticFunction<Effect>("create", [] { return std::make_shared<Effect>(); });
    g_lua.bindClassMemberFunction<Effect>("setId", &Effect::setId);

    g_lua.registerClass<Missile, Thing>();
    g_lua.bindClassStaticFunction<Missile>("create", [] { return std::make_shared<Missile>(); });
    g_lua.bindClassMemberFunction<Missile>("setId", &Missile::setId);
    g_lua.bindClassMemberFunction<Missile>("setPath", &Missile::setPath);

    g_lua.registerClass<AttachedEffect>();
    g_lua.bindClassStaticFunction<AttachedEffect>("create", &AttachedEffect::create);
    g_lua.bindClassMemberFunction<AttachedEffect>("clone", &AttachedEffect::clone);
    g_lua.bindClassMemberFunction<AttachedEffect>("getId", &AttachedEffect::getId);
    g_lua.bindClassMemberFunction<AttachedEffect>("getSpeed", &AttachedEffect::getSpeed);
    g_lua.bindClassMemberFunction<AttachedEffect>("setOnTop", &AttachedEffect::setOnTop);
    g_lua.bindClassMemberFunction<AttachedEffect>("setSpeed", &AttachedEffect::setSpeed);
    g_lua.bindClassMemberFunction<AttachedEffect>("setDisableWalkAnimation", &AttachedEffect::setDisableWalkAnimation);
    g_lua.bindClassMemberFunction<AttachedEffect>("setOpacity", &AttachedEffect::setOpacity);
    g_lua.bindClassMemberFunction<AttachedEffect>("setDuration", &AttachedEffect::setDuration);
    g_lua.bindClassMemberFunction<AttachedEffect>("getDuration", &AttachedEffect::getDuration);
    g_lua.bindClassMemberFunction<AttachedEffect>("setHideOwner", &AttachedEffect::setHideOwner);
    g_lua.bindClassMemberFunction<AttachedEffect>("setLoop", &AttachedEffect::setLoop);
    g_lua.bindClassMemberFunction<AttachedEffect>("setPermanent", &AttachedEffect::setPermanent);
    g_lua.bindClassMemberFunction<AttachedEffect>("isPermanent", &AttachedEffect::isPermanent);
    g_lua.bindClassMemberFunction<AttachedEffect>("setTransform", &AttachedEffect::setTransform);
    g_lua.bindClassMemberFunction<AttachedEffect>("setOffset", &AttachedEffect::setOffset);
    g_lua.bindClassMemberFunction<AttachedEffect>("setDirOffset", &AttachedEffect::setDirOffset);
    g_lua.bindClassMemberFunction<AttachedEffect>("setOnTopByDir", &AttachedEffect::setOnTopByDir);
    g_lua.bindClassMemberFunction<AttachedEffect>("setShader", &AttachedEffect::setShader);
    g_lua.bindClassMemberFunction<AttachedEffect>("setSize", &AttachedEffect::setSize);
    g_lua.bindClassMemberFunction<AttachedEffect>("canDrawOnUI", &AttachedEffect::canDrawOnUI);
    g_lua.bindClassMemberFunction<AttachedEffect>("setCanDrawOnUI", &AttachedEffect::setCanDrawOnUI);
    g_lua.bindClassMemberFunction<AttachedEffect>("attachEffect", &AttachedEffect::attachEffect);
    g_lua.bindClassMemberFunction<AttachedEffect>("setDrawOrder", &AttachedEffect::setDrawOrder);
    g_lua.bindClassMemberFunction<AttachedEffect>("setLight", &AttachedEffect::setLight);
    g_lua.bindClassMemberFunction<AttachedEffect>("setBounce", &AttachedEffect::setBounce);
    g_lua.bindClassMemberFunction<AttachedEffect>("setPulse", &AttachedEffect::setPulse);
    g_lua.bindClassMemberFunction<AttachedEffect>("setFade", &AttachedEffect::setFade);

    g_lua.bindClassMemberFunction<AttachedEffect>("setDirection", &AttachedEffect::setDirection);
    g_lua.bindClassMemberFunction<AttachedEffect>("getDirection", &AttachedEffect::getDirection);
    g_lua.bindClassMemberFunction<AttachedEffect>("move", &AttachedEffect::move);

    g_lua.registerClass<StaticText>();
    g_lua.bindClassStaticFunction<StaticText>("create", [] { return std::make_shared<StaticText>(); });
    g_lua.bindClassMemberFunction<StaticText>("addMessage", &StaticText::addMessage);
    g_lua.bindClassMemberFunction<StaticText>("setText", &StaticText::setText);
    g_lua.bindClassMemberFunction<StaticText>("setFont", &StaticText::setFont);
    g_lua.bindClassMemberFunction<StaticText>("setColor", &StaticText::setColor);
    g_lua.bindClassMemberFunction<StaticText>("getColor", &StaticText::getColor);

    g_lua.registerClass<AnimatedText>();
    g_lua.bindClassMemberFunction<AnimatedText>("getText", &AnimatedText::getText);
    g_lua.bindClassMemberFunction<AnimatedText>("getOffset", &AnimatedText::getOffset);
    g_lua.bindClassMemberFunction<AnimatedText>("getColor", &AnimatedText::getColor);

    g_lua.registerClass<Player, Creature>();
    g_lua.registerClass<Npc, Creature>();
    g_lua.registerClass<Monster, Creature>();

    g_lua.registerClass<LocalPlayer, Player>();
    g_lua.bindClassMemberFunction<LocalPlayer>("unlockWalk", &LocalPlayer::unlockWalk);
    g_lua.bindClassMemberFunction<LocalPlayer>("lockWalk", &LocalPlayer::lockWalk);
    g_lua.bindClassMemberFunction<LocalPlayer>("isWalkLocked", &LocalPlayer::isWalkLocked);
    g_lua.bindClassMemberFunction<LocalPlayer>("canWalk", &LocalPlayer::canWalk);
    g_lua.bindClassMemberFunction<LocalPlayer>("setStates", &LocalPlayer::setStates);
    g_lua.bindClassMemberFunction<LocalPlayer>("setSkill", &LocalPlayer::setSkill);
    g_lua.bindClassMemberFunction<LocalPlayer>("setHealth", &LocalPlayer::setHealth);
    g_lua.bindClassMemberFunction<LocalPlayer>("setTotalCapacity", &LocalPlayer::setTotalCapacity);
    g_lua.bindClassMemberFunction<LocalPlayer>("setFreeCapacity", &LocalPlayer::setFreeCapacity);
    g_lua.bindClassMemberFunction<LocalPlayer>("setExperience", &LocalPlayer::setExperience);
    g_lua.bindClassMemberFunction<LocalPlayer>("setLevel", &LocalPlayer::setLevel);
    g_lua.bindClassMemberFunction<LocalPlayer>("setMana", &LocalPlayer::setMana);
    g_lua.bindClassMemberFunction<LocalPlayer>("setMagicLevel", &LocalPlayer::setMagicLevel);
    g_lua.bindClassMemberFunction<LocalPlayer>("setSoul", &LocalPlayer::setSoul);
    g_lua.bindClassMemberFunction<LocalPlayer>("setStamina", &LocalPlayer::setStamina);
    g_lua.bindClassMemberFunction<LocalPlayer>("setKnown", &LocalPlayer::setKnown);
    g_lua.bindClassMemberFunction<LocalPlayer>("setInventoryItem", &LocalPlayer::setInventoryItem);
    g_lua.bindClassMemberFunction<LocalPlayer>("getStates", &LocalPlayer::getStates);
    g_lua.bindClassMemberFunction<LocalPlayer>("getSkillLevel", &LocalPlayer::getSkillLevel);
    g_lua.bindClassMemberFunction<LocalPlayer>("getSkillBaseLevel", &LocalPlayer::getSkillBaseLevel);
    g_lua.bindClassMemberFunction<LocalPlayer>("getSkillLevelPercent", &LocalPlayer::getSkillLevelPercent);
    g_lua.bindClassMemberFunction<LocalPlayer>("getHealth", &LocalPlayer::getHealth);
    g_lua.bindClassMemberFunction<LocalPlayer>("getMaxHealth", &LocalPlayer::getMaxHealth);
    g_lua.bindClassMemberFunction<LocalPlayer>("getFreeCapacity", &LocalPlayer::getFreeCapacity);
    g_lua.bindClassMemberFunction<LocalPlayer>("getExperience", &LocalPlayer::getExperience);
    g_lua.bindClassMemberFunction<LocalPlayer>("getLevel", &LocalPlayer::getLevel);
    g_lua.bindClassMemberFunction<LocalPlayer>("getLevelPercent", &LocalPlayer::getLevelPercent);
    g_lua.bindClassMemberFunction<LocalPlayer>("getMana", &LocalPlayer::getMana);
    g_lua.bindClassMemberFunction<LocalPlayer>("getMaxMana", &LocalPlayer::getMaxMana);
    g_lua.bindClassMemberFunction<LocalPlayer>("getMagicLevel", &LocalPlayer::getMagicLevel);
    g_lua.bindClassMemberFunction<LocalPlayer>("getMagicLevelPercent", &LocalPlayer::getMagicLevelPercent);
    g_lua.bindClassMemberFunction<LocalPlayer>("getSoul", &LocalPlayer::getSoul);
    g_lua.bindClassMemberFunction<LocalPlayer>("getStamina", &LocalPlayer::getStamina);
    g_lua.bindClassMemberFunction<LocalPlayer>("getOfflineTrainingTime", &LocalPlayer::getOfflineTrainingTime);
    g_lua.bindClassMemberFunction<LocalPlayer>("getStoreExpBoostTime", &LocalPlayer::getStoreExpBoostTime);
    g_lua.bindClassMemberFunction<LocalPlayer>("getRegenerationTime", &LocalPlayer::getRegenerationTime);
    g_lua.bindClassMemberFunction<LocalPlayer>("getBaseMagicLevel", &LocalPlayer::getBaseMagicLevel);
    g_lua.bindClassMemberFunction<LocalPlayer>("getTotalCapacity", &LocalPlayer::getTotalCapacity);
    g_lua.bindClassMemberFunction<LocalPlayer>("getInventoryItem", &LocalPlayer::getInventoryItem);
    g_lua.bindClassMemberFunction<LocalPlayer>("getVocation", &LocalPlayer::getVocation);
    g_lua.bindClassMemberFunction<LocalPlayer>("getBlessings", &LocalPlayer::getBlessings);
    g_lua.bindClassMemberFunction<LocalPlayer>("isPremium", &LocalPlayer::isPremium);
    g_lua.bindClassMemberFunction<LocalPlayer>("isKnown", &LocalPlayer::isKnown);
    g_lua.bindClassMemberFunction<LocalPlayer>("preWalk", &LocalPlayer::preWalk);
    g_lua.bindClassMemberFunction<LocalPlayer>("hasSight", &LocalPlayer::hasSight);
    g_lua.bindClassMemberFunction<LocalPlayer>("isAutoWalking", &LocalPlayer::isAutoWalking);
    g_lua.bindClassMemberFunction<LocalPlayer>("stopAutoWalk", &LocalPlayer::stopAutoWalk);
    g_lua.bindClassMemberFunction<LocalPlayer>("isServerWalking", &LocalPlayer::isServerWalking);
    g_lua.bindClassMemberFunction<LocalPlayer>("isPreWalking", &LocalPlayer::isPreWalking);
    g_lua.bindClassMemberFunction<LocalPlayer>("autoWalk", &LocalPlayer::autoWalk);
    g_lua.bindClassMemberFunction<LocalPlayer>("getResourceBalance", &LocalPlayer::getResourceBalance);
    g_lua.bindClassMemberFunction<LocalPlayer>("setResourceBalance", &LocalPlayer::setResourceBalance);
    g_lua.bindClassMemberFunction<LocalPlayer>("getTotalMoney", &LocalPlayer::getTotalMoney);

    g_lua.registerClass<Tile, AttachableObject>();
    g_lua.bindClassMemberFunction<Tile>("clean", &Tile::clean);
    g_lua.bindClassMemberFunction<Tile>("addThing", &Tile::addThing);
    g_lua.bindClassMemberFunction<Tile>("getThing", &Tile::getThing);
    g_lua.bindClassMemberFunction<Tile>("getThings", &Tile::getThings);
    g_lua.bindClassMemberFunction<Tile>("getItems", &Tile::getItems);
    g_lua.bindClassMemberFunction<Tile>("getThingStackPos", &Tile::getThingStackPos);
    g_lua.bindClassMemberFunction<Tile>("getThingCount", &Tile::getThingCount);
    g_lua.bindClassMemberFunction<Tile>("getTopThing", &Tile::getTopThing);
    g_lua.bindClassMemberFunction<Tile>("removeThing", &Tile::removeThing);
    g_lua.bindClassMemberFunction<Tile>("getTopLookThing", &Tile::getTopLookThing);
    g_lua.bindClassMemberFunction<Tile>("getTopUseThing", &Tile::getTopUseThing);
    g_lua.bindClassMemberFunction<Tile>("getTopCreature", &Tile::getTopCreature);
    g_lua.bindClassMemberFunction<Tile>("getTopMoveThing", &Tile::getTopMoveThing);
    g_lua.bindClassMemberFunction<Tile>("getTopMultiUseThing", &Tile::getTopMultiUseThing);
    g_lua.bindClassMemberFunction<Tile>("getPosition", &Tile::getPosition);
    g_lua.bindClassMemberFunction<Tile>("getCreatures", &Tile::getCreatures);
    g_lua.bindClassMemberFunction<Tile>("getGround", &Tile::getGround);
    g_lua.bindClassMemberFunction<Tile>("isWalkable", &Tile::isWalkable);
    g_lua.bindClassMemberFunction<Tile>("hasElevation", &Tile::hasElevation);

    g_lua.bindClassMemberFunction<Tile>("isFullGround", &Tile::isFullGround);
    g_lua.bindClassMemberFunction<Tile>("isFullyOpaque", &Tile::isFullyOpaque);
    g_lua.bindClassMemberFunction<Tile>("isLookPossible", &Tile::isLookPossible);
    g_lua.bindClassMemberFunction<Tile>("hasCreatures", &Tile::hasCreatures);
    g_lua.bindClassMemberFunction<Tile>("isEmpty", &Tile::isEmpty);
    g_lua.bindClassMemberFunction<Tile>("isClickable", &Tile::isClickable);
    g_lua.bindClassMemberFunction<Tile>("isPathable", &Tile::isPathable);

    g_lua.bindClassMemberFunction<Tile>("select", &Tile::select);
    g_lua.bindClassMemberFunction<Tile>("unselect", &Tile::unselect);
    g_lua.bindClassMemberFunction<Tile>("isSelected", &Tile::isSelected);
    g_lua.bindClassMemberFunction<Tile>("isCovered", &Tile::isCovered);
    g_lua.bindClassMemberFunction<Tile>("isCompletelyCovered", &Tile::isCompletelyCovered);

    g_lua.bindClassMemberFunction<Tile>("setText", &Tile::setText);
    g_lua.bindClassMemberFunction<Tile>("getText", &Tile::getText);
    g_lua.bindClassMemberFunction<Tile>("setTimer", &Tile::setTimer);
    g_lua.bindClassMemberFunction<Tile>("getTimer", &Tile::getTimer);
    g_lua.bindClassMemberFunction<Tile>("setFill", &Tile::setFill);
    g_lua.bindClassMemberFunction<Tile>("canShoot", &Tile::canShoot);

#ifdef FRAMEWORK_EDITOR
    g_lua.bindClassMemberFunction<Tile>("isHouseTile", &Tile::isHouseTile);
    g_lua.bindClassMemberFunction<Tile>("overwriteMinimapColor", &Tile::overwriteMinimapColor);
    g_lua.bindClassMemberFunction<Tile>("remFlag", &Tile::remFlag);
    g_lua.bindClassMemberFunction<Tile>("setFlag", &Tile::setFlag);
    g_lua.bindClassMemberFunction<Tile>("setFlags", &Tile::setFlags);
    g_lua.bindClassMemberFunction<Tile>("getFlags", &Tile::getFlags);
    g_lua.bindClassMemberFunction<Tile>("hasFlag", &Tile::hasFlag);
#endif
}
