local UI = nil
local TypeCharmRadioGroup = nil
Cyclopedia.Charms = {}
local charmCategory_t = {
    CHARM_ALL = 0,
    CHARM_MAJOR = 1,
    CHARM_MINOR = 2
};

local charm_t = {
    CHARM_UNDEFINED = 0,
    CHARM_OFFENSIVE = 1,
    CHARM_DEFENSIVE = 2,
    CHARM_PASSIVE = 3
};
local charmRune_t = {
    CHARM_WOUND = 0,
    CHARM_ENFLAME = 1,
    CHARM_POISON = 2,
    CHARM_FREEZE = 3,
    CHARM_ZAP = 4,
    CHARM_CURSE = 5,
    CHARM_CRIPPLE = 6,
    CHARM_PARRY = 7,
    CHARM_DODGE = 8,
    CHARM_ADRENALINE = 9,
    CHARM_NUMB = 10,
    CHARM_CLEANSE = 11,
    CHARM_BLESS = 12,
    CHARM_SCAVENGE = 13,
    CHARM_GUT = 14,
    CHARM_LOW = 15,
    CHARM_DIVINE = 16,
    CHARM_VAMP = 17,
    CHARM_VOID = 18,
    CHARM_SAVAGE = 19,
    CHARM_FATAL = 20,
    CHARM_VOIDINVERSION = 21,
    CHARM_CARNAGE = 22,
    CHARM_OVERPOWER = 23,
    CHARM_OVERFLUX = 24
}

local charms = {
    [charmRune_t.CHARM_WOUND] = {
        name = tr("otclient_modules.charms.tr_74"),
        description = tr("otclient_modules.charms.tr_73"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_OFFENSIVE,
        percent = 5,
        chance = {5, 10, 11},
        points = {240, 360, 1200}
    },
    [charmRune_t.CHARM_ENFLAME] = {
        name = tr("otclient_modules.charms.tr_72"),
        description = tr("otclient_modules.charms.tr_71"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_OFFENSIVE,
        percent = 5,
        chance = {5, 10, 11},
        points = {400, 600, 2000}
    },
    [charmRune_t.CHARM_POISON] = {
        name = tr("otclient_modules.charms.tr_70"),
        description = tr("otclient_modules.charms.tr_69"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_OFFENSIVE,
        percent = 5,
        chance = {5, 10, 11},
        points = {240, 360, 1200}
    },
    [charmRune_t.CHARM_FREEZE] = {
        name = tr("otclient_modules.charms.tr_68"),
        description = tr("otclient_modules.charms.tr_67"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_OFFENSIVE,
        percent = 5,
        chance = {5, 10, 11},
        points = {320, 480, 1600}
    },
    [charmRune_t.CHARM_ZAP] = {
        name = tr("otclient_modules.charms.tr_66"),
        description = tr("otclient_modules.charms.tr_65"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_OFFENSIVE,
        percent = 5,
        chance = {5, 10, 11},
        points = {320, 480, 1600}
    },
    [charmRune_t.CHARM_CURSE] = {
        name = tr("otclient_modules.charms.tr_64"),
        description = tr("otclient_modules.charms.tr_63"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_OFFENSIVE,
        percent = 5,
        chance = {5, 10, 11},
        points = {360, 540, 1800}
    },
    [charmRune_t.CHARM_CRIPPLE] = {
        name = tr("otclient_modules.charms.tr_62"),
        description = tr("otclient_modules.charms.tr_61"),
        category = charmCategory_t.CHARM_MINOR,
        type = charm_t.CHARM_OFFENSIVE,
        chance = {6, 9, 12},
        messageCancel = "You crippled a monster. (cripple charm)",
        points = {100, 150, 225}
    },
    [charmRune_t.CHARM_PARRY] = {
        name = tr("otclient_modules.charms.tr_60"),
        description = tr("otclient_modules.charms.tr_59"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_DEFENSIVE,
        chance = {5, 10, 11},
        messageCancel = "You parried an attack. (parry charm)",
        points = {400, 600, 2000}
    },
    [charmRune_t.CHARM_DODGE] = {
        name = tr("otclient_modules.charms.tr_58"),
        description = tr("otclient_modules.charms.tr_57"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_DEFENSIVE,
        chance = {5, 10, 11},
        messageCancel = "You dodged an attack. (dodge charm)",
        points = {240, 360, 1200}
    },
    [charmRune_t.CHARM_ADRENALINE] = {
        name = tr("otclient_modules.charms.tr_56"),
        description = tr("otclient_modules.charms.tr_55"),
        category = charmCategory_t.CHARM_MINOR,
        type = charm_t.CHARM_DEFENSIVE,
        chance = {6, 9, 12},
        messageCancel = "Your movements where bursted. (adrenaline burst charm)",
        points = {100, 150, 225}
    },
    [charmRune_t.CHARM_NUMB] = {
        name = tr("otclient_modules.charms.tr_54"),
        description = tr("otclient_modules.charms.tr_53"),
        category = charmCategory_t.CHARM_MINOR,
        type = charm_t.CHARM_DEFENSIVE,
        chance = {6, 9, 12},
        messageCancel = "You numbed a monster. (numb charm)",
        points = {100, 150, 225}
    },
    [charmRune_t.CHARM_CLEANSE] = {
        name = tr("otclient_modules.charms.tr_52"),
        description = tr("otclient_modules.charms.tr_51"),
        category = charmCategory_t.CHARM_MINOR,
        type = charm_t.CHARM_DEFENSIVE,
        chance = {6, 9, 12},
        messageCancel = "You purified an attack. (cleanse charm)",
        points = {100, 150, 225}
    },
    [charmRune_t.CHARM_BLESS] = {
        name = tr("otclient_modules.charms.tr_50"),
        description = tr("otclient_modules.charms.tr_49"),
        category = charmCategory_t.CHARM_MINOR,
        type = charm_t.CHARM_PASSIVE,
        percent = 10,
        chance = {6, 9, 12},
        points = {100, 150, 225}
    },
    [charmRune_t.CHARM_SCAVENGE] = {
        name = tr("otclient_modules.charms.tr_48"),
        description = tr("otclient_modules.charms.tr_47"),
        category = charmCategory_t.CHARM_MINOR,
        type = charm_t.CHARM_PASSIVE,
        chance = {60, 90, 120},
        points = {100, 150, 225}
    },
    [charmRune_t.CHARM_GUT] = {
        name = tr("otclient_modules.charms.tr_46"),
        description = tr("otclient_modules.charms.tr_45"),
        category = charmCategory_t.CHARM_MINOR,
        type = charm_t.CHARM_PASSIVE,
        chance = {6, 9, 12},
        points = {100, 150, 225}
    },
    [charmRune_t.CHARM_LOW] = {
        name = tr("otclient_modules.charms.tr_44"),
        description = tr("otclient_modules.charms.tr_43"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_PASSIVE,
        chance = {4, 8, 9},
        points = {800, 1200, 4000}
    },
    [charmRune_t.CHARM_DIVINE] = {
        name = tr("otclient_modules.charms.tr_42"),
        description = tr("otclient_modules.charms.tr_41"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_OFFENSIVE,
        percent = 5,
        chance = {5, 10, 11},
        points = {600, 900, 3000}
    },
    [charmRune_t.CHARM_VAMP] = {
        name = tr("otclient_modules.charms.tr_40"),
        description = tr("otclient_modules.charms.tr_39"),
        category = charmCategory_t.CHARM_MINOR,
        type = charm_t.CHARM_PASSIVE,
        chance = {1.6, 2.4, 3.2},
        points = {100, 150, 225}
    },
    [charmRune_t.CHARM_VOID] = {
        name = tr("otclient_modules.charms.tr_38"),
        description = tr("otclient_modules.charms.tr_37"),
        category = charmCategory_t.CHARM_MINOR,
        type = charm_t.CHARM_PASSIVE,
        chance = {0.8, 1.2, 1.6},
        points = {100, 150, 225}
    },
    [charmRune_t.CHARM_SAVAGE] = {
        name = tr("otclient_modules.charms.tr_36"),
        description = tr("otclient_modules.charms.tr_35"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_PASSIVE,
        chance = {20, 40, 44},
        points = {800, 1200, 4000}
    },
    [charmRune_t.CHARM_FATAL] = {
        name = tr("otclient_modules.charms.tr_34"),
        description = tr("otclient_modules.charms.tr_33"),
        category = charmCategory_t.CHARM_MINOR,
        type = charm_t.CHARM_PASSIVE,
        chance = {30, 45, 60},
        messageCancel = "Your enemy is not able to flee now for 30 seconds. (fatal hold charm)",
        points = {100, 150, 225}
    },
    [charmRune_t.CHARM_VOIDINVERSION] = {
        name = tr("otclient_modules.charms.tr_32"),
        description = tr("otclient_modules.charms.tr_31"),
        category = charmCategory_t.CHARM_MINOR,
        type = charm_t.CHARM_PASSIVE,
        chance = {20, 30, 40},
        points = {100, 150, 225}
    },
    [charmRune_t.CHARM_CARNAGE] = {
        name = tr("otclient_modules.charms.tr_30"),
        description = tr("otclient_modules.charms.tr_29"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_OFFENSIVE,
        percent = 15,
        chance = {10, 20, 22},
        points = {600, 900, 3000}
    },
    [charmRune_t.CHARM_OVERPOWER] = {
        name = tr("otclient_modules.charms.tr_28"),
        description = tr("otclient_modules.charms.tr_27"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_OFFENSIVE,
        percent = 5,
        chance = {5, 10, 11},
        points = {600, 900, 3000}
    },
    [charmRune_t.CHARM_OVERFLUX] = {
        name = tr("otclient_modules.charms.tr_26"),
        description = tr("otclient_modules.charms.tr_25"),
        category = charmCategory_t.CHARM_MAJOR,
        type = charm_t.CHARM_OFFENSIVE,
        percent = 2.5,
        chance = {5, 10, 11},
        points = {600, 900, 3000}
    }
}

local isModernUI = false
function showCharms()
    isModernUI = g_game.getClientVersion() >= 1410
    local UIUX = isModernUI and "charms1410" or "charms"
    UI = g_ui.loadUI(UIUX, contentContainer)
    UI:show()
    g_game.requestBestiary()
    controllerCyclopedia.ui.CharmsBase:setVisible(true)
    controllerCyclopedia.ui.GoldBase:setVisible(true)
    controllerCyclopedia.ui.BestiaryTrackerButton:setVisible(false)
    if isModernUI then
        controllerCyclopedia.ui.CharmsBase1410:setVisible(true)
        TypeCharmRadioGroup = UIRadioGroup.create()
        TypeCharmRadioGroup:addWidget(UI.mainPanelCharmsType.typeCharmPanel.MajorCharms)
        TypeCharmRadioGroup:addWidget(UI.mainPanelCharmsType.typeCharmPanel.MinorCharms)
        TypeCharmRadioGroup:selectWidget(TypeCharmRadioGroup:getFirstWidget())
        connect(TypeCharmRadioGroup, {
            onSelectionChange = onTypeCharmRadioGroup
        })
    end
end

function onTerminateCharm()
    if TypeCharmRadioGroup then
        disconnect(TypeCharmRadioGroup, {
            onSelectionChange = onTypeCharmRadioGroup
        })
        TypeCharmRadioGroup:destroy()
        TypeCharmRadioGroup = nil
    end
end

function Cyclopedia.CreateCharmItem(data)
    local CharmList = isModernUI and UI.mainPanelCharmsType.panelCharmList.CharmList or UI.CharmList
    local widget = g_ui.createWidget("CharmItem", CharmList)
    local value = widget.PriceBase.Value

    widget:setId(data.id)
    widget.charmBase.image:setImageSource("/game_cyclopedia/images/charms/monster-bonus-effects")

    if data.id ~= nil then
        widget.charmBase.image:setImageClip((data.id * 32) .. ' 0 32 32')
    else
        g_logger.error(string.format("Cyclopedia.CreateCharmItem - charm %s is nil", data.id))
        return
    end

    local charmData = charms[data.id]
    widget:setText(isModernUI and charmData.name or data.name)
    widget.data = data

    if data.asignedStatus then
        if data.raceId then
            local raceData = g_things.getRaceData(data.raceId)
            widget.InfoBase.Sprite:setOutfit(raceData.outfit)
            widget.InfoBase.Sprite:getCreature():setStaticWalking(1000)
        else
            g_logger.error("Cyclopedia.CreateCharmItem - no race id provided")
        end
    end

    local isUnlocked = data.tier > 0 or data.unlocked
    if not isModernUI then
        widget.PriceBase.Charm:setVisible(not isUnlocked)
        widget.PriceBase.Gold:setVisible(isUnlocked)
    end
    widget.charmBase.lockedMask:setVisible(not isUnlocked)
    widget.icon = isUnlocked and 1 or 0

    if isUnlocked then
        widget.PriceBase.Value:setText(data.asignedStatus and comma_value(data.removeRuneCost) or 0)
    else
        widget.PriceBase.Value:setText(comma_value(data.unlockPrice))
    end

    local player = g_game.getLocalPlayer()
    if widget.icon == 1 and player:getResourceBalance(ResourceTypes.GOLD_EQUIPPED) then
        local canAfford = data.removeRuneCost <= player:getResourceBalance(ResourceTypes.GOLD_EQUIPPED)
        value:setColor(canAfford and "#C0C0C0" or "#D33C3C")
    elseif widget.icon == 0 then
        local canAfford = data.unlockPrice <= UI.CharmsPoints
        value:setColor(canAfford and "#C0C0C0" or "#D33C3C")
    end

    widget.category = charmData.category

    if isModernUI and data.tier > 0 then
        widget.charmBase.border:setImageSource("/game_cyclopedia/images/charms/border/backdrop_charmgrade" .. data.tier)
    end
end

function Cyclopedia.loadCharms(charmsData)
    if not UI then
        return
    end
    if isModernUI and not UI.mainPanelCharmsType then
        return
    end
    local CharmList = isModernUI and UI.mainPanelCharmsType.panelCharmList.CharmList or UI.CharmList
    local player = g_game.getLocalPlayer()

    if isModernUI then
        local formatResourceBalance = function(resourceType, maxResourceType)
            return string.format("%d/%d", player:getResourceBalance(resourceType),
                player:getResourceBalance(maxResourceType))
        end

        controllerCyclopedia.ui.CharmsBase.Value:setText(formatResourceBalance(ResourceTypes.CHARM,
            ResourceTypes.MAX_CHARM))
        controllerCyclopedia.ui.CharmsBase1410.Value:setText(
            formatResourceBalance(ResourceTypes.MINOR_CHARM, ResourceTypes.MAX_MINOR_CHARM))
    else
        controllerCyclopedia.ui.CharmsBase.Value:setText(Cyclopedia.formatGold(charmsData.points))
    end

    UI.CharmsPoints = charmsData.points

    Cyclopedia.Charms.Monsters = {}
    local raceIdNamePairs = {}

    for _, raceId in ipairs(charmsData.finishedMonsters) do
        local raceData = g_things.getRaceData(raceId)
        local raceName = raceData.name ~= "" and raceData.name or string.format("unnamed_%d", raceId)
        table.insert(raceIdNamePairs, {
            raceId = raceId,
            name = raceName
        })
    end

    table.sort(raceIdNamePairs, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    for _, pair in ipairs(raceIdNamePairs) do
        table.insert(Cyclopedia.Charms.Monsters, pair.raceId)
    end

    CharmList:destroyChildren()

    local formattedData = {}
    for _, charmData in pairs(charmsData.charms) do
        local internalId = charmData.id
        if internalId and charms[internalId] then
            local charm = charms[internalId]
            charmData.name = charmData.name ~= "" and charmData.name or charm.name
            charmData.description = charmData.description ~= "" and charmData.description or charm.description
            charmData.internalId = internalId
            charmData.typePriority = charm.type
            charmData.category = charm.category
            table.insert(formattedData, charmData)
        end
    end

    if isModernUI then
        table.sort(formattedData, function(a, b)
            local tierA, tierB = a.tier or 0, b.tier or 0
            if tierA ~= tierB then
                return tierA > tierB
            end
            return a.name:lower() < b.name:lower()
        end)
    else
        table.sort(formattedData, function(a, b)
            if a.unlocked ~= b.unlocked then
                return a.unlocked and not b.unlocked
            end
            return a.name:lower() < b.name:lower()
        end)
    end

    for _, value in ipairs(formattedData) do
        if value and value.name and value.description and value.internalId and value.typePriority then
            local success, error = pcall(Cyclopedia.CreateCharmItem, value)
            if not success then
                g_logger.error(string.format("Error creating charm item: %s for charm ID: %s (%s)", error,
                    tostring(value.internalId), tostring(value.name)))
            end
        else
            g_logger.error(string.format("Incomplete charm data: ID: %s",
                value and tostring(value.internalId or "unknown") or "nil"))
        end
    end

    if isModernUI then
        local selectedWidget = TypeCharmRadioGroup:getSelectedWidget()
        if selectedWidget then
            local charmCategory = selectedWidget:getId() == "MajorCharms" and charmCategory_t.CHARM_MAJOR or
                                      charmCategory_t.CHARM_MINOR

            for _, widget in ipairs(CharmList:getChildren()) do
                widget:setVisible(widget.category == charmCategory)
            end

            CharmList:getLayout():update()
        end
    end

    local firstCharm = Cyclopedia.Charms.redirect and CharmList:getChildById(Cyclopedia.Charms.redirect) or
                           CharmList:getChildByIndex(1)

    if firstCharm then
        Cyclopedia.selectCharm(firstCharm, firstCharm:isChecked())
        Cyclopedia.Charms.redirect = nil
    end
end

local function getUIBase()
    if isModernUI then
        return {
            CreatureList = UI.InformationBase.PanelCreatureList.CreaturesBase.CreatureList,
            InfoBase = UI.InformationBase.panelSelectCreature.InfoBase,
            TextBase = UI.InformationBase.TextBase,
            ItemBase = UI.InformationBase.ItemBase,
            PriceBase = UI.InformationBase.verticalPanelUnLockClearChram.PriceBaseGold,
            UnlockButton = UI.InformationBase.verticalPanelUnLockClearChram.UnlockButton,
            SearchEdit = UI.InformationBase.PanelCreatureList.SearchEdit.SearchEdit,
            SearchLabel = UI.InformationBase.SearchLabel,
            CreaturesBase = UI.InformationBase.PanelCreatureList.CreaturesBase,
            CreaturesLabel = UI.InformationBase.panelSelectCreature.CreaturesLabel
        }
    else
        return {
            CreatureList = UI.InformationBase.CreaturesBase.CreatureList,
            InfoBase = UI.InformationBase.InfoBase,
            TextBase = UI.InformationBase.TextBase,
            ItemBase = UI.InformationBase.ItemBase,
            PriceBase = UI.InformationBase.PriceBase,
            UnlockButton = UI.InformationBase.UnlockButton,
            SearchEdit = UI.InformationBase.SearchEdit,
            SearchLabel = UI.InformationBase.SearchLabel,
            CreaturesBase = UI.InformationBase.CreaturesBase,
            CreaturesLabel = UI.InformationBase.CreaturesLabel
        }
    end
end

local function formatCreatureName(text)
    local capitalizedText = text:gsub("(%l)(%w*)", function(first, rest)
        return first:upper() .. rest
    end)
    return #capitalizedText > 19 and capitalizedText:sub(1, 16) .. "..." or capitalizedText
end

local function updateUIColors(widget, UI_BASE)
    local player = g_game.getLocalPlayer()
    local priceValue = UI_BASE.PriceBase.Value
    if isModernUI then
        local charmEntry = charms[widget.data.id]
        if charmEntry and charmEntry.points and charmEntry.points[widget.data.tier + 1] then
            local selectedWidget = TypeCharmRadioGroup:getSelectedWidget()
            if selectedWidget then
                local charmCategory = selectedWidget:getId() == "MajorCharms" and ResourceTypes.CHARM or
                                          ResourceTypes.MINOR_CHARM
                local pointsValue = charmEntry.points[widget.data.tier + 1]
                local canAfford = pointsValue <= player:getResourceBalance(charmCategory)
                UI.InformationBase.verticalPanelUnLockClearChram.PriceBaseCharm.Value:setColor(
                    canAfford and "#C0C0C0" or "#D33C3C")
                UI.InformationBase.verticalPanelUnLockClearChram.UnlockButton:setEnabled(canAfford)
            end
        else
            UI.InformationBase.verticalPanelUnLockClearChram.PriceBaseCharm.Value:setColor("#C0C0C0")
            UI.InformationBase.verticalPanelUnLockClearChram.UnlockButton:setEnabled(false)
        end
        if not widget.data.asignedStatus then
            priceValue:setText(0)
        end
    else
        if widget.icon == 1 and player:getResourceBalance(ResourceTypes.GOLD_EQUIPPED) then
            local canAfford = widget.data.removeRuneCost <= player:getResourceBalance(ResourceTypes.GOLD_EQUIPPED)
            priceValue:setColor(canAfford and "#C0C0C0" or "#D33C3C")
            UI_BASE.UnlockButton:setEnabled(canAfford)

            local priceText = (widget.data.unlocked and not widget.data.asignedStatus) and 0 or
                                  comma_value(widget.data.removeRuneCost)
            priceValue:setText(priceText)
        elseif widget.icon == 0 then
            local canAfford = widget.data.unlockPrice <= UI.CharmsPoints
            priceValue:setColor(canAfford and "#C0C0C0" or "#D33C3C")
            UI_BASE.UnlockButton:setEnabled(canAfford)
            priceValue:setText(widget.data.unlockPrice)
        end
    end
end

-- Populate the creature list for a charm and configure related UI controls when the charm can be assigned.
-- Creates a list entry for each race in `Cyclopedia.Charms.Monsters` (alternating row colors), sets the unlock button text to "Select",
-- disables the unlock button, and enables search and creature-related labels.
-- This runs only if the charm is unlocked and not already assigned, or if the modern UI is active.
-- @param widget UI widget representing the charm item. Expected to have `data.unlocked` and `data.asignedStatus` boolean fields.
-- @param UI_BASE Table of UI element handles used by the function. Expected keys: `UnlockButton`, `CreatureList`, `SearchEdit`, optional `SearchLabel`, and `CreaturesLabel`.
local function setupCreatureList(widget, UI_BASE)
    if (widget.data.unlocked and not widget.data.asignedStatus) or isModernUI then
        UI_BASE.UnlockButton:setText(tr("otclient_modules.charms.tr_24"))

        local color = "#484848"
        for index, raceId in ipairs(Cyclopedia.Charms.Monsters) do
            local creatureWidget = g_ui.createWidget("CharmCreatureName", UI_BASE.CreatureList)
            creatureWidget:setId(index)
            creatureWidget:setText(formatCreatureName(g_things.getRaceData(raceId).name))
            creatureWidget.raceId = raceId
            creatureWidget:setBackgroundColor(color)
            creatureWidget.color = color
            color = color == "#484848" and "#414141" or "#484848"
        end

        UI_BASE.UnlockButton:setEnabled(false)
        UI_BASE.SearchEdit:setEnabled(true)
        if UI_BASE.SearchLabel then
            UI_BASE.SearchLabel:setEnabled(true)
        end
        UI_BASE.CreaturesLabel:setEnabled(true)
    end
end

local function setupModernVersionUpgrade(widget, UI_BASE)
    if not isModernUI then
        return
    end

    local charmId = widget.data.id
    local tier = widget.data.tier or 0
    local charmEntry = charms[charmId]

    if charmEntry and charmEntry.points and charmEntry.points[tier + 1] then
        local pointsValue = charmEntry.points[tier + 1]
        local chanceValue = charmEntry.chance and charmEntry.chance[tier + 1] or 0

        UI.InformationBase.verticalPanelUnLockClearChram.PriceBaseCharm.Value:setText(comma_value(pointsValue))
        local tierButtons = {
            [3] = "Fully Unlocked",
            [2] = string.format("Upgrade to %d%%", charmEntry.chance[3] or 0),
            [1] = string.format("Upgrade to %d%%", charmEntry.chance[2] or 0),
            [0] = "Unlock"
        }
        UI_BASE.UnlockButton:setText(tierButtons[tier])
        if tier >= 0 and tier < 3 then
            UI_BASE.UnlockButton:setEnabled(true)
        end
        UI_BASE.UnlockButton:getParent().data = widget.data
    else
        UI_BASE.UnlockButton:setText(tr("otclient_modules.charms.tr_23"))
        UI.InformationBase.verticalPanelUnLockClearChram.PriceBaseCharm.Value:setText(comma_value(0))
    end
end

-- Selects a charm item and updates the Cyclopedia UI to reflect that selection.
-- Updates description text, item image/clip, price visibility, assigned creature sprite, affordability indicators, creature list, and unlock/upgrade controls.
-- Also deselects other charm widgets in the same parent and ensures the provided widget is checked.
-- @param widget The charm item widget to select; expected to include `.data` and associated UI fields used by the Cyclopedia.
-- @param isChecked Boolean indicating whether the widget was already checked; if `false`, the function forces the widget to become checked.
function Cyclopedia.selectCharm(widget, isChecked)
    local UI_BASE = getUIBase()
    UI_BASE.CreatureList:destroyChildren()

    local parent = widget:getParent()
    UI.InformationBase.data = widget.data
    for i = 1, parent:getChildCount() do
        local internalWidget = parent:getChildByIndex(i)
        if internalWidget:isChecked() and widget:getId() ~= internalWidget:getId() then
            internalWidget:setChecked(false)
        end
    end

    if not isChecked then
        widget:setChecked(true)
    end

    UI_BASE.TextBase:setText(widget.data.description)
    UI_BASE.ItemBase.image:setImageSource(widget.charmBase.image:getImageSource())
    UI_BASE.ItemBase.image:setImageClip(widget.charmBase.image:getImageClip())

    if isModernUI then
        UI.InformationBase:setText(widget:getText())
        if widget.data.tier > 0 then
            UI_BASE.ItemBase.border:setImageSource("/game_cyclopedia/images/charms/border/backdrop_charmgrade" ..
                                                       widget.data.tier)
            UI_BASE.ItemBase.lockedMask:setVisible(false)
        else
            UI_BASE.ItemBase.lockedMask:setVisible(true)
            UI_BASE.ItemBase.border:setImageSource("")
        end
    end

    if widget.data.asignedStatus then
        local sprite = UI_BASE.InfoBase.sprite
        sprite:setVisible(true)
        sprite:setOutfit(g_things.getRaceData(widget.data.raceId).outfit)
        sprite:getCreature():setStaticWalking(1000)
        sprite:setOpacity(1)
    else
        UI_BASE.InfoBase.sprite:setVisible(false)
    end

    if not isModernUI then
        UI_BASE.PriceBase.Gold:setVisible(widget.icon == 1)
        UI_BASE.PriceBase.Charm:setVisible(widget.icon == 0)
    end

    updateUIColors(widget, UI_BASE)

    setupCreatureList(widget, UI_BASE)

    if widget.data.asignedStatus then
        UI_BASE.UnlockButton:setText(tr("otclient_modules.charms.tr_22"))
        local creatureWidget = g_ui.createWidget("CharmCreatureName", UI_BASE.CreatureList)
        creatureWidget:setText(formatCreatureName(g_things.getRaceData(widget.data.raceId).name))
        creatureWidget:setEnabled(false)
        creatureWidget:setColor("#707070")

        UI_BASE.SearchEdit:setEnabled(false)
        if UI_BASE.SearchLabel then
            UI_BASE.SearchLabel:setEnabled(false)
        end
        UI_BASE.CreaturesLabel:setEnabled(false)
    end

    if not widget.data.unlocked then
        UI_BASE.UnlockButton:setText(tr("otclient_modules.charms.tr_21"))
        UI_BASE.SearchEdit:setEnabled(false)
        if UI_BASE.SearchLabel then
            UI_BASE.SearchLabel:setEnabled(false)
        end
        if not isModernUI then
            UI_BASE.CreaturesLabel:setEnabled(false)
        end
    end

    setupModernVersionUpgrade(widget, UI_BASE)
end

function Cyclopedia.selectCreatureCharm(widget, isChecked)
    local UI_BASE = {}

    if isModernUI then
        UI_BASE.InfoBase = UI.InformationBase.panelSelectCreature.InfoBase
        UI_BASE.UnlockButton = UI.InformationBase.verticalPanelUnLockClearChram.UnlockButton
    else
        UI_BASE.InfoBase = UI.InformationBase.InfoBase
        UI_BASE.UnlockButton = UI.InformationBase.UnlockButton
    end
    local parent = widget:getParent()

    for i = 1, parent:getChildCount() do
        local internalWidget = parent:getChildByIndex(i)

        if internalWidget:isChecked() and widget:getId() ~= internalWidget:getId() then
            internalWidget:setChecked(false)
            internalWidget:setBackgroundColor(internalWidget.color)
        end
    end

    if not isChecked then
        widget:setChecked(true)
    end

    UI_BASE.InfoBase.sprite:setVisible(true)
    UI_BASE.InfoBase.sprite:setOutfit(g_things.getRaceData(widget.raceId).outfit)
    UI_BASE.InfoBase.sprite:getCreature():setStaticWalking(1000)
    UI_BASE.InfoBase.sprite:setOpacity(0.5)
    UI_BASE.UnlockButton:setEnabled(true)

    Cyclopedia.Charms.SelectedCreature = widget.raceId
end

function Cyclopedia.searchCharmMonster(text)
    local UI_BASE = {}

    if isModernUI then
        UI_BASE.CreaturesBase = UI.InformationBase.PanelCreatureList.CreaturesBase
    else
        UI_BASE.CreaturesBase = UI.InformationBase.CreaturesBase
    end

    UI_BASE.CreaturesBase.CreatureList:destroyChildren()

    local function format(string)
        local capitalizedText = string:gsub("(%l)(%w*)", function(first, rest)
            return first:upper() .. rest
        end)

        if #capitalizedText > 19 then
            return capitalizedText:sub(1, 16) .. "..."
        else
            return capitalizedText
        end
    end

    local function getColor(currentColor)
        return currentColor == "#484848" and "#414141" or "#484848"
    end

    local searchedMonsters = {}

    if text ~= "" then
        for _, raceId in ipairs(Cyclopedia.Charms.Monsters) do
            local name = g_things.getRaceData(raceId).name
            if string.find(name:lower(), text:lower()) then
                table.insert(searchedMonsters, raceId)
            end
        end
    else
        searchedMonsters = Cyclopedia.Charms.Monsters
    end

    local color = "#484848"

    for _, raceId in ipairs(searchedMonsters) do
        local internalWidget = g_ui.createWidget("CharmCreatureName", UI_BASE.CreaturesBase.CreatureList)
        internalWidget:setId(raceId)
        internalWidget:setText(format(g_things.getRaceData(raceId).name))
        internalWidget.raceId = raceId
        internalWidget:setBackgroundColor(color)
        internalWidget.color = color
        color = getColor(color)
    end
end

function Cyclopedia.actionCharmButton(widget)
    local confirmWindow
    local type = widget:getText()
    local data = widget:getParent().data

    if type == "Unlock" then
        local function yesCallback()
            if isModernUI then
                g_game.BuyCharmRune(0, data.id, 0)
            else
                g_game.BuyCharmRune(data.id)
            end
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
                -- Cyclopedia.Toggle(true, false, 3)
            end

            Cyclopedia.Charms.redirect = data.id
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("otclient_modules.charms.tr_20"), tr("otclient_modules.charms.tr_19", data.name, data.unlockPrice),
                {
                    {
                        text = tr("otclient_modules.charms.tr_18"),
                        callback = yesCallback
                    },
                    {
                        text = tr("otclient_modules.charms.tr_17"),
                        callback = noCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback, noCallback)
        end
    end
    if type == "Select" or type == "Select Creature" then
        local function yesCallback()
            if isModernUI then
                g_game.BuyCharmRune(1, data.id, Cyclopedia.Charms.SelectedCreature)
            else
                g_game.BuyCharmRune(data.id, 1, Cyclopedia.Charms.SelectedCreature)
            end
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
            end
            Cyclopedia.Charms.redirect = data.id
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("otclient_modules.charms.tr_16"),
                tr("otclient_modules.charms.tr_15", data.name), {
                    {
                        text = tr("otclient_modules.charms.tr_14"),
                        callback = yesCallback
                    },
                    {
                        text = tr("otclient_modules.charms.tr_13"),
                        callback = noCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback, noCallback)
        end
    end

    if type == "Remove" then
        local function yesCallback()
            g_game.BuyCharmRune(data.id, 2)
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
            end

            Cyclopedia.Charms.redirect = data.id
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("otclient_modules.charms.tr_12"),
                tr("otclient_modules.charms.tr_11", data.name, comma_value(data.removeRuneCost)), {
                    {
                        text = tr("otclient_modules.charms.tr_10"),
                        callback = yesCallback
                    },
                    {
                        text = tr("otclient_modules.charms.tr_9"),
                        callback = noCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback, noCallback)
        end
    end
    if isModernUI and type:match("^Upgrade") then
        local function yesCallback()
            g_game.BuyCharmRune(0, data.id, 0)
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
            end
            Cyclopedia.Charms.redirect = data.id
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("otclient_modules.charms.tr_8"), tr("otclient_modules.charms.tr_7", data.name, data.unlockPrice),
                {
                    {
                        text = tr("otclient_modules.charms.tr_6"),
                        callback = yesCallback
                    },
                    {
                        text = tr("otclient_modules.charms.tr_5"),
                        callback = noCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback, noCallback)
        end
    end
end

function onTypeCharmRadioGroup(radioGroup, selectedWidget)
    local charmCategory = selectedWidget:getId() == "MajorCharms" and charmCategory_t.CHARM_MAJOR or
                              charmCategory_t.CHARM_MINOR
    local CharmList = UI.mainPanelCharmsType.panelCharmList.CharmList
    if charmCategory == charmCategory_t.CHARM_MAJOR then
        UI.InformationBase.verticalPanelUnLockClearChram.PriceBaseCharm.Charm:setImageSource(
            "/game_cyclopedia/images/monster-icon-bonuspoints")
    else
        UI.InformationBase.verticalPanelUnLockClearChram.PriceBaseCharm.Charm:setImageSource(
            "/game_cyclopedia/images/minor-charm-echoes")
    end
    for _, widget in ipairs(CharmList:getChildren()) do
        if widget.category == charmCategory then
            widget:setVisible(true)
        else
            widget:setVisible(false)
        end
    end

    CharmList:getLayout():update()
end

function Cyclopedia.actionSelectCharmButton(widget)
    local confirmWindow
    local type = widget:getText()
    local data = UI.InformationBase.data
    if type == "Select" or type == "Select Creature" then
        local function yesCallback()
            if isModernUI then
                g_game.BuyCharmRune(1, data.id, Cyclopedia.Charms.SelectedCreature)
            else
                g_game.BuyCharmRune(data.id, 1, Cyclopedia.Charms.SelectedCreature)
            end
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
            end
            Cyclopedia.Charms.redirect = data.id
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()
                confirmWindow = nil
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("otclient_modules.charms.tr_4"),
                tr("otclient_modules.charms.tr_3", data.name), {
                    {
                        text = tr("otclient_modules.charms.tr_2"),
                        callback = yesCallback
                    },
                    {
                        text = tr("otclient_modules.charms.tr_1"),
                        callback = noCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback, noCallback)
        end
    end
end