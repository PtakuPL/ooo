local UI = nil

function showBossSlot()
    UI = g_ui.loadUI("boss_slots", contentContainer)
    UI:show()
    UI.RightBase.LockLabel:setText(tr("otclient_modules.boss_slots.tr_6"))
    g_game.requestBossSlootInfo()
    controllerCyclopedia.ui.CharmsBase:setVisible(false)
    controllerCyclopedia.ui.GoldBase:setVisible(true)
    controllerCyclopedia.ui.BestiaryTrackerButton:setVisible(false)
    if g_game.getClientVersion() >= 1410 then
        controllerCyclopedia.ui.CharmsBase1410:hide()
    end
    Cyclopedia.BossSlots.UnlockBosses = {}
end

local CATEGORY = {
    BANE = 0,
    NEMESIS = 2,
    ARCHFOE = 1
}

local SLOT_STATE = {
    EMPTY = 1,
    LOCKED = 0,
    ACTIVE = 2
}

local ICONS = {
    [CATEGORY.BANE] = "/game_cyclopedia/images/boss/icon_bane",
    [CATEGORY.ARCHFOE] = "/game_cyclopedia/images/boss/icon_archfoe",
    [CATEGORY.NEMESIS] = "/game_cyclopedia/images/boss/icon_nemesis"
}

local SLOTS = {
    [1] = "LeftBase",
    [2] = "RightBase"
}

local CONFIG = {
    [0] = {
        EXPERTISE = 100,
        PROWESS = 25,
        MASTERY = 300
    },
    {
        EXPERTISE = 20,
        PROWESS = 5,
        MASTERY = 60
    },
    {
        EXPERTISE = 3,
        PROWESS = 1,
        MASTERY = 5
    }
}

local function getBossCategoryTooltip(category)
    if category == CATEGORY.ARCHFOE then
        return tr("otclient_modules.boss_slots.tr_4")
    end
    if category == CATEGORY.NEMESIS then
        return tr("otclient_modules.boss_slots.tr_3")
    end
    return tr("otclient_modules.boss_slots.tr_2")
end

Cyclopedia.BossSlots = {}

function Cyclopedia.loadBossSlots(data)
    if not UI or not UI.Sprite then
        return
    end

    local raceData = g_things.getRaceData(data.boostedBossId)
    UI.Sprite:setOutfit(raceData.outfit)

    UI.Sprite:getCreature():setStaticWalking(1000)
    UI.TopBase.InfoLabel:setText(string.format(tr("otclient_modules.boss_slots.tr_7"), data.currentBonus,
        data.nextBonus))

    local fullText = ""
    if data.playerPoints >= CONFIG[data.todaySlotData.bossRace].MASTERY then
        fullText = tr("otclient_modules.boss_slots.tr_1")
    end

    local progress = UI.BoostedProgress
    progress.ProgressBorder1:setTooltip(string.format(" %d / %d %s", data.playerPoints,
        CONFIG[data.todaySlotData.bossRace].PROWESS, fullText))
    progress.ProgressBorder2:setTooltip(string.format(" %d / %d %s", data.playerPoints,
        CONFIG[data.todaySlotData.bossRace].EXPERTISE, fullText))
    progress.ProgressBorder3:setTooltip(string.format(" %d / %d %s", data.playerPoints,
        CONFIG[data.todaySlotData.bossRace].MASTERY, fullText))

    if data.playerPoints >= CONFIG[data.todaySlotData.bossRace].PROWESS then
        progress.bronzeStar:setImageSource("/game_cyclopedia/images/boss/icon_star_bronze")
    else
        progress.bronzeStar:setImageSource("/game_cyclopedia/images/boss/icon_star_dark")
    end

    if data.playerPoints >= CONFIG[data.todaySlotData.bossRace].EXPERTISE then
        progress.silverStar:setImageSource("/game_cyclopedia/images/boss/icon_star_silver")
    else
        progress.silverStar:setImageSource("/game_cyclopedia/images/boss/icon_star_dark")
    end

    if data.playerPoints >= CONFIG[data.todaySlotData.bossRace].MASTERY then
        progress.goldStar:setImageSource("/game_cyclopedia/images/boss/icon_star_gold")
    else
        progress.goldStar:setImageSource("/game_cyclopedia/images/boss/icon_star_dark")
    end

    UI.MainLabel:setText(string.format(tr("otclient_modules.boss_slots.tr_8"), data.todaySlotData.lootBonus,
        data.todaySlotData.killBonus))

    Cyclopedia.setBosstiarySlotsProgress(data.playerPoints, data.totalPointsNextBonus)

    local function format(string)
        if #string > 18 then
            return string:sub(1, 15) .. "..."
        else
            return string
        end
    end

    local unlockedBosses = data.bossIdSlotTwo

    UI.MidTitle:setText(string.format(tr("otclient_modules.boss_slots.tr_9"), format(raceData.name)))
    Cyclopedia.setBosstiarySlotsBossProgress(UI.BoostedProgress, data.todaySlotData.killCount,
        CONFIG[data.todaySlotData.bossRace].MASTERY)
    UI.TypeIcon:setImageSource(ICONS[data.todaySlotData.bossRace])

    UI.TypeIcon:setTooltip(getBossCategoryTooltip(data.todaySlotData.bossRace))
    -- UI.TypeIcon:setTooltipAlign(AlignTopLeft)

    for i, unlockData in ipairs(data.bossesUnlockedData) do
        if not unlockData then
            break
        end

        local uRaceData = g_things.getRaceData(unlockData.bossId)
        local data_t = {
            visible = true,
            bossId = unlockData.bossId,
            category = unlockData.bossRace,
            name = uRaceData.name
        }

        table.insert(Cyclopedia.BossSlots.UnlockBosses, data_t)
    end

    if Cyclopedia.BossSlots.UnlockBosses then
        table.sort(Cyclopedia.BossSlots.UnlockBosses, function(a, b)
            return a.name < b.name
        end)

        if data.isSlotOneUnlocked or data.isSlotTwoUnlocked then
            Cyclopedia.BossSlotChangeSlot(data, unlockedBosses)
        end
    end
end

function Cyclopedia.BossSlotChangeSlot(data, unlockedBosses)
    local slots = {{
        isUnlocked = data.isSlotOneUnlocked,
        slotNumber = 1,
        slotData = data.slotOneData,
        bossId = data.bossIdSlotOne
    }, {
        isUnlocked = data.isSlotTwoUnlocked,
        slotNumber = 2,
        slotData = data.slotTwoData,
        bossId = data.bossIdSlotTwo
    }}

    for _, slotInfo in ipairs(slots) do
        if slotInfo.isUnlocked then
            local widget = UI[SLOTS[slotInfo.slotNumber]]

            if slotInfo.slotData then
                Cyclopedia.setActiveSlot(widget, slotInfo.slotNumber, slotInfo.slotData, data, slotInfo.bossId)
            elseif data.bossesUnlocked and #data.bossesUnlockedData > 0 then
                Cyclopedia.setLockedSlot(widget, slotInfo.slotNumber, unlockedBosses)
            else
                Cyclopedia.setEmptySlot(widget, slotInfo.slotNumber, slotInfo.bossId)
            end
        end
    end
end

function Cyclopedia.setEmptySlot(widget, slot, bossIdSlotTwo)
    widget.LockLabel:setVisible(true)
    widget.SelectBoss:setVisible(false)
    widget.ActivedBoss:setVisible(false)
    widget:setText(string.format(tr("otclient_modules.boss_slots.tr_10"), slot))
    widget.LockLabel:setText(string.format(tr("otclient_modules.boss_slots.tr_11"), bossIdSlotTwo))
end

function Cyclopedia.setLockedSlot(widget, slot, unlockedBosses)
    widget.LockLabel:setVisible(false)
    widget.SelectBoss:setVisible(true)
    widget.ActivedBoss:setVisible(false)
    widget:setText(string.format(tr("otclient_modules.boss_slots.tr_12"), slot))
    widget.SelectBoss.ListBase.List:destroyChildren()

    local function format(string)
        if #string > 12 then
            return string:sub(1, 9) .. "..."
        else
            return string
        end
    end

    for _, internalData in ipairs(Cyclopedia.BossSlots.UnlockBosses) do
        local raceData = g_things.getRaceData(internalData.bossId)
        local internalWidget = g_ui.createWidget("SelectBossBossSlots", widget.SelectBoss.ListBase.List)
        internalWidget:setId(internalData.bossId)
        internalWidget.Sprite:setOutfit(raceData.outfit)
        internalWidget:setText(format(raceData.name))
        internalWidget.Sprite:getCreature():setStaticWalking(1000)
        internalWidget.TypeIcon:setImageSource(ICONS[internalData.category])

        internalWidget.TypeIcon:setTooltip(getBossCategoryTooltip(internalData.category))
    end

    widget.SelectBoss.SelectButton:setEnabled(false)
    widget.SelectBoss.SelectButton.onClick = function()
        g_game.requestBossSlotAction(slot, Cyclopedia.BossSlots.lastSelected:getId())
        Cyclopedia.BossSlots.UnlockBosses = {}
    end
end

function Cyclopedia.setActiveSlot(widget, slot, slotData, data, bossId)
    local raceData = g_things.getRaceData(bossId)
    widget.LockLabel:setVisible(false)
    widget.SelectBoss:setVisible(false)
    widget.ActivedBoss:setVisible(true)
    widget:setText(string.format(tr("otclient_modules.boss_slots.tr_5"), slot, raceData.name))
    widget.ActivedBoss.TypeIcon:setImageSource(ICONS[slotData.bossRace])

    Cyclopedia.setBosstiarySlotsBossProgress(widget.ActivedBoss.Progress, slotData.killBonus,
        CONFIG[slotData.bossRace].MASTERY)

    widget.ActivedBoss.TypeIcon:setTooltip(getBossCategoryTooltip(slotData.bossRace))
    widget.ActivedBoss.Progress.ProgressBorder1:setTooltip()

    local fullText = slotData.killBonus >= CONFIG[slotData.bossRace].MASTERY and tr("otclient_modules.boss_slots.tr_1") or ""

    local progress = widget.ActivedBoss.Progress
    progress.ProgressBorder1:setTooltip(string.format(" %d / %d %s", slotData.killBonus,
        CONFIG[slotData.bossRace].PROWESS, fullText))
    progress.ProgressBorder2:setTooltip(string.format(" %d / %d %s", slotData.killBonus,
        CONFIG[slotData.bossRace].EXPERTISE, fullText))
    progress.ProgressBorder3:setTooltip(string.format(" %d / %d %s", slotData.killBonus,
        CONFIG[slotData.bossRace].MASTERY, fullText))

    progress.bronzeStar:setImageSource(slotData.killBonus >= CONFIG[slotData.bossRace].PROWESS and
                                           "/game_cyclopedia/images/boss/icon_star_bronze" or
                                           "/game_cyclopedia/images/boss/icon_star_dark")
    progress.silverStar:setImageSource(slotData.killBonus >= CONFIG[slotData.bossRace].EXPERTISE and
                                           "/game_cyclopedia/images/boss/icon_star_silver" or
                                           "/game_cyclopedia/images/boss/icon_star_dark")
    progress.goldStar:setImageSource(slotData.killBonus >= CONFIG[slotData.bossRace].MASTERY and
                                         "/game_cyclopedia/images/boss/icon_star_gold" or
                                         "/game_cyclopedia/images/boss/icon_star_dark")

    widget.ActivedBoss.Sprite:setOutfit(raceData.outfit)
    widget.ActivedBoss.Sprite:getCreature():setStaticWalking(1000)
    widget.ActivedBoss.EquipmentLabel:setText(string.format(tr("otclient_modules.boss_slots.tr_13"), slotData.lootBonus))
    widget.ActivedBoss.Value:setText(comma_value(slotData.removePrice))

    if g_game.getLocalPlayer():getResourceBalance(1) ~= nil then
        if slotData.removePrice > g_game.getLocalPlayer():getResourceBalance(1) then
            widget.ActivedBoss.Value:setColor("#D33C3C")
            widget.ActivedBoss.RemoveButton:setEnabled(false)
        else
            widget.ActivedBoss.Value:setColor("#C0C0C0")
            widget.ActivedBoss.RemoveButton:setEnabled(true)
        end
    end

    widget.ActivedBoss.RemoveButton.onClick = function()
        g_game.requestBossSlotAction(slot, 0)
    end

    widget.ActivedBoss.RemoveButton:setTooltip(string.format(
        tr("otclient_modules.boss_slots.tr_14"), comma_value(slotData.removePrice)))
end

function Cyclopedia.setBosstiarySlotsProgress(value, maxValue)
    local rect = {
        height = 18,
        x = 0,
        y = 0,
        width = (maxValue < value and maxValue or value) / maxValue * 278
    }

    if value >= 0 and rect.width < 1 then
        rect.width = 1
    end

    UI.TopBase.PointsBar.fill:setImageRect(rect)
    UI.TopBase.PointsBar.Value:setText(string.format("%d/%d", value, maxValue))
end

function Cyclopedia.setBosstiarySlotsBossProgress(object, value, maxValue)
    local rect = {
        height = 12,
        x = 0,
        y = 0,
        width = (maxValue < value and maxValue or value) / maxValue * 126
    }

    if value >= 0 and rect.width < 1 then
        object.fill:setVisible(false)
    else
        object.fill:setVisible(true)
    end

    object.fill:setImageRect(rect)
    object.ProgressValue:setText(value)

    if maxValue <= value then
        object.fill:setImageSource("/game_cyclopedia/images/bestiary/fill")
    end
end

function Cyclopedia.bossSlotSelectBoss(widget)
    local button = widget:getParent():getParent():getParent().SelectButton

    for i = 1, widget:getParent():getChildCount() do
        local child = widget:getParent():getChildByIndex(i)
        child:setChecked(false)
    end

    widget:setChecked(true)
    Cyclopedia.BossSlots.lastSelected = widget
    button:setEnabled(true)
end

function Cyclopedia.readjustSelectBoss()
    local slot = 1
    if not UI.LeftBase.SelectBoss:isVisible() then
        slot = 2
    end

    local icons = {
        [CATEGORY.BANE] = "/game_cyclopedia/images/boss/icon_bane",
        [CATEGORY.ARCHFOE] = "/game_cyclopedia/images/boss/icon_archfoe",
        [CATEGORY.NEMESIS] = "/game_cyclopedia/images/boss/icon_nemesis"
    }

    local function format(string)
        if #string > 12 then
            return string:sub(1, 9) .. "..."
        else
            return string
        end
    end

    local widget = UI[SLOTS[slot]]
    widget.SelectBoss.ListBase.List:destroyChildren()

    for _, internalData in ipairs(Cyclopedia.BossSlots.UnlockBosses) do
        if internalData.visible then
            local raceData = g_things.getRaceData(internalData.bossId)
            local internalWidget = g_ui.createWidget("SelectBossBossSlots", widget.SelectBoss.ListBase.List)
            internalWidget.Sprite:setOutfit(raceData.outfit)
            internalWidget:setText(format(raceData.name))
            internalWidget.Sprite:getCreature():setStaticWalking(1000)
            internalWidget.TypeIcon:setImageSource(icons[internalData.category])

            internalWidget.TypeIcon:setTooltip(getBossCategoryTooltip(internalData.category))
        end
    end

    widget.SelectBoss.SelectButton:setEnabled(false)
end

function Cyclopedia.SelectBossSearchText(text, clear, widget)
    if clear then
        widget:getParent().SearchEdit:setText("")
    end

    if text ~= "" then
        for _, creature in ipairs(Cyclopedia.BossSlots.UnlockBosses) do
            if string.find(creature.name:lower(), text:lower()) == nil then
                creature.visible = false
            else
                creature.visible = true
            end
        end
    else
        for _, creature in ipairs(Cyclopedia.BossSlots.UnlockBosses) do
            creature.visible = true
        end
    end

    Cyclopedia.readjustSelectBoss()
end
