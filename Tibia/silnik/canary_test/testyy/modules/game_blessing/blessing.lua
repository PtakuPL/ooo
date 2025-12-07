BlessingController = Controller:new()

function BlessingController:onInit()
end

function BlessingController:onTerminate()
  --  BlessingController:findWidget("#main"):destroy()
end

-- Initializes and prepares the blessing UI when the game session starts.
-- This loads the UI style and HTML, centers the UI, registers the `onUpdateBlessDialog` event handler with the game, hides the UI, and sets the minipanel title.
function BlessingController:onGameStart()
    g_ui.importStyle("style.otui")
    BlessingController:loadHtml('blessing.html')
    BlessingController.ui:centerIn('parent')

    BlessingController:registerEvents(g_game, {
        onUpdateBlessDialog = onUpdateBlessDialog
    })
    BlessingController.ui:hide()
    BlessingController.ui.minipanel1:setText(tr("Record of Blessings")) -- Temp fix html/css system
end

-- Hides the blessing UI if it is currently visible.
function BlessingController:onGameEnd()
    if BlessingController.ui:isVisible() then
        BlessingController.ui:hide()
    end
end

function BlessingController:close()
    hide()
end

function BlessingController:showHistory()
    if BlessingController.ui.blessingHistory:isVisible() then
        setBlessing()
    else
        setHistory()
    end
end

-- Switches the blessing interface to the history view.
-- Hides the minipanel and promotion-status elements, shows the blessing history panel, and updates the history button text to the translated "Back".
function setHistory()
    local ui = BlessingController.ui
    ui.minipanel1:hide()
    ui.promotionStatus2:hide()
    ui.promotionStatus:hide()
    ui.blessingHistory:show()
    ui.historyButton:setText(tr("Back"))
end

-- Switches the UI to the blessing view.
-- Shows the main blessing panels and promotion status, hides the blessing history panel,
-- and sets the history button text to the translated "History".
function setBlessing()
    local ui = BlessingController.ui
    ui.minipanel1:show()
    ui.promotionStatus2:show()
    ui.promotionStatus:show()
    ui.blessingHistory:hide()
    ui.historyButton:setText(tr("History"))
end

-- Toggle the blessing UI between shown and hidden states.
-- Does nothing if the blessing UI is not initialized; hides the UI when visible, otherwise shows it.
function toggle()
    if not BlessingController.ui then
        return
    end

    if BlessingController.ui:isVisible() then
        return hide()
    end
    show()
end

function hide()
    if not BlessingController.ui then
        return
    end
    BlessingController.ui:hide()
end

function show()
    if not BlessingController.ui then
        return
    end
    g_game.requestBless()
    BlessingController.ui:show()
    BlessingController.ui:raise()
    BlessingController.ui:focus()
    setBlessing()
end

-- Rebuilds the blessing dialog UI from the provided data, updating blessing counts, promotion texts, XP/item loss descriptions, and the history table.
-- @param data Table containing blessing dialog state with the following fields:
--   blesses: array of tables with fields `playerBlessCount` (number) and `store` (number) for each blessing slot.
--   promotion: number indicating promotion status (0 = not promoted).
--   pvpMinXpLoss: number minimum PvP XP loss reduction percentage.
--   pvpMaxXpLoss: number maximum PvP XP loss reduction percentage.
--   pveExpLoss: number PvE XP loss reduction percentage.
--   equipPvpLoss: number chance (percentage) to lose equipped container on PvP death.
--   equipPveLoss: number chance (percentage) to lose items on PvE death.
--   logs: array of tables with fields `timestamp` (unix seconds) and `historyMessage` (string) to populate the history list.
function onUpdateBlessDialog(data)
    BlessingController.ui.minipanel1:destroyChildren()
    for i, entry in ipairs(data.blesses) do
        local label = g_ui.createWidget("blessingTEST", BlessingController.ui.minipanel1)
        local totalCount = entry.playerBlessCount + entry.store
        label.text:setText(entry.playerBlessCount .. " (" .. entry.store .. ")")
        if totalCount >= 1 then
            label.enabled:setImageSource("images/" .. i .. "_on")
        else
            label.enabled:setImageSource("images/" .. i)
        end
    end

    if (data.promotion ~= 0) then
        BlessingController.ui.promotionStatus2.premium_only:setOn(true)
        BlessingController.ui.promotionStatus2.rank:setColoredText(
            tr("Your character is promoted and your account has Premium\nstatus. As a result, your XP loss is reduced by") .. " {30%, #f75f5f}.")
    else
        BlessingController.ui.promotionStatus2.rank:setColoredText(
            tr("Your character is promoted and your account has Premium\nstatus. As a result, your XP loss is reduced by") .. " {0%, #f75f5f}.")
            BlessingController.ui.promotionStatus2.premium_only:setOn(false)
    end

    BlessingController.ui.promotionStatus.fightRules:setColoredText(
        tr("- Depending on the fair fight rules, you will lose between") .. " {" .. data.pvpMinXpLoss .. ", #f75f5f} " .. tr("and") .. " {" ..
            data.pvpMaxXpLoss .. "%, #f75f5f} " .. tr("less XP and skill points \nupon your next PvP death."))

    BlessingController.ui.promotionStatus.expLoss:setColoredText(
        tr("- You will lose") .. " {" .. data.pveExpLoss .. "%, #f75f5f}% " .. tr("less XP and skill points upon your next PvE death."))

    BlessingController.ui.promotionStatus.containerLoss:setColoredText(
        tr("- There is a") .. " {" .. data.equipPvpLoss ..
            "%, #f75f5f} " .. tr("chance that you will lose your equipped container on your next death."))

    BlessingController.ui.promotionStatus.equipmentLoss:setColoredText(
        tr("- There is a") .. " {" .. data.equipPveLoss .. "%, #f75f5f} " .. tr("chance that you will lose items upon your next death."))

    BlessingController.ui.blessingHistory:getChildByIndex(1):destroyChildren()
    local row2 = g_ui.createWidget("historyData", BlessingController.ui.blessingHistory:getChildByIndex(1))
    row2:setBackgroundColor("#363636")
    row2.rank:setText(tr("Date"))
    row2.name:setText(tr("Event"))
    row2.rank:setColor("#c0c0c0")
    row2.name:setColor("#c0c0c0")
    row2:setBorderColor("#00000077")
    row2:setBorderWidth(1)

    for index, entry in ipairs(data.logs) do
        local row = g_ui.createWidget("historyData", BlessingController.ui.blessingHistory:getChildByIndex(1))
        local date = os.date("%Y-%m-%d, %H:%M:%S", entry.timestamp)
        row:setBackgroundColor(index % 2 == 0 and "#ffffff12" or "#00000012")
        row.rank:setText(date)
        row.name:setText(entry.historyMessage)
    end
end