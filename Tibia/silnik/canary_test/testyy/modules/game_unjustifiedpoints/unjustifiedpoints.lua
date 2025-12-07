unjustifiedPointsWindow = nil
unjustifiedPointsButton = nil
contentsPanel = nil

openPvpSituationsLabel = nil
currentSkullWidget = nil
skullTimeLabel = nil

dayProgressBar = nil
weekProgressBar = nil
monthProgressBar = nil

daySkullWidget = nil
weekSkullWidget = nil
monthSkullWidget = nil

function init()
    connect(g_game, {
        onGameStart = online,
        onGameEnd = offline,
        onUnjustifiedPointsChange = onUnjustifiedPointsChange,
        onOpenPvpSituationsChange = onOpenPvpSituationsChange
    })
    connect(LocalPlayer, {
        onSkullChange = onSkullChange
    })

    unjustifiedPointsWindow = g_ui.loadUI('unjustifiedpoints')
    unjustifiedPointsWindow:disableResize()
    unjustifiedPointsWindow:setup()

    contentsPanel = unjustifiedPointsWindow:getChildById('contentsPanel')

    openPvpSituationsLabel = contentsPanel:getChildById('openPvpSituationsLabel')
    currentSkullWidget = contentsPanel:getChildById('currentSkullWidget')
    skullTimeLabel = contentsPanel:getChildById('skullTimeLabel')

    dayProgressBar = contentsPanel:getChildById('dayProgressBar')
    weekProgressBar = contentsPanel:getChildById('weekProgressBar')
    monthProgressBar = contentsPanel:getChildById('monthProgressBar')
    daySkullWidget = contentsPanel:getChildById('daySkullWidget')
    weekSkullWidget = contentsPanel:getChildById('weekSkullWidget')
    monthSkullWidget = contentsPanel:getChildById('monthSkullWidget')

    if g_game.isOnline() then
        online()
    end
end

function terminate()
    disconnect(g_game, {
        onGameStart = online,
        onGameEnd = offline,
        onUnjustifiedPointsChange = onUnjustifiedPointsChange,
        onOpenPvpSituationsChange = onOpenPvpSituationsChange
    })
    disconnect(LocalPlayer, {
        onSkullChange = onSkullChange
    })

    unjustifiedPointsWindow:destroy()
    if unjustifiedPointsButton then
        unjustifiedPointsButton:destroy()
        unjustifiedPointsButton = nil
    end
end

function onMiniWindowOpen()
    if unjustifiedPointsButton then
        unjustifiedPointsButton:setOn(true)
    end
end

function onMiniWindowClose()
    if unjustifiedPointsButton then
        unjustifiedPointsButton:setOn(false)
    end
end

function toggle()
    if unjustifiedPointsButton:isOn() then
        unjustifiedPointsWindow:close()
        unjustifiedPointsButton:setOn(false)
    else
        if not unjustifiedPointsWindow:getParent() then
            local panel = modules.game_interface.findContentPanelAvailable(unjustifiedPointsWindow, unjustifiedPointsWindow:getMinimumHeight())
            if not panel then
                return
            end

            panel:addChild(unjustifiedPointsWindow)
        end
        unjustifiedPointsWindow:open()
        unjustifiedPointsButton:setOn(true)
    end
end

function online()
    if g_game.getFeature(GameUnjustifiedPoints) and not unjustifiedPointsButton then
        unjustifiedPointsWindow:setupOnStart() -- load character window configuration
        unjustifiedPointsButton = modules.game_mainpanel.addToggleButton('unjustifiedPointsButton',
            tr('Unjustified Points'), '/images/options/button_frags', toggle)
        unjustifiedPointsButton:setOn(false)
    end

    refresh()
end

function offline()
    if g_game.getFeature(GameUnjustifiedPoints) then
        unjustifiedPointsWindow:setParent(nil, true)
    end
end

function refresh()
    local localPlayer = g_game.getLocalPlayer()

    local unjustifiedPoints = g_game.getUnjustifiedPoints()
    onUnjustifiedPointsChange(unjustifiedPoints)

    onSkullChange(localPlayer, localPlayer:getSkull())
    onOpenPvpSituationsChange(g_game.getOpenPvpSituations())
end

-- Update skull-related UI widgets for the local player.
-- Updates the current skull icon and tooltip (shows remaining skull time for red/black skulls, otherwise indicates no skull)
-- and sets the day, week, and month skull widgets to the next skull icon.
-- @param localPlayer The player instance whose skull state is reported; ignored if not the local player.
-- @param skull The skull identifier (enum or id) representing the player's current skull state.
function onSkullChange(localPlayer, skull)
    if not localPlayer:isLocalPlayer() then
        return
    end

    if skull == SkullRed or skull == SkullBlack then
        currentSkullWidget:setIcon(getSkullImagePath(skull))
        currentSkullWidget:setTooltip(tr('Remaining skull time'))
    else
        currentSkullWidget:setIcon('')
        currentSkullWidget:setTooltip(tr('You have no skull'))
    end

    daySkullWidget:setIcon(getSkullImagePath(getNextSkullId(skull)))
    weekSkullWidget:setIcon(getSkullImagePath(getNextSkullId(skull)))
    monthSkullWidget:setIcon(getSkullImagePath(getNextSkullId(skull)))
end

function onOpenPvpSituationsChange(amount)
    openPvpSituationsLabel:setText(amount)
end

local function getColorByKills(kills)
    if kills < 2 then
        return 'red'
    elseif kills < 3 then
        return 'yellow'
    end

    return 'green'
end

-- Update the unjustified points UI: skull time label and the 24h/7d/30d progress bars.
-- @param unjustifiedPoints Table with current unjustified points data:
--   - skullTime (number): remaining skull time in days; zero means no skull.
--   - killsDay (number): current progress value for the last 24 hours.
--   - killsDayRemaining (number): kills remaining until next skull for the 24-hour window.
--   - killsWeek (number): current progress value for the last 7 days.
--   - killsWeekRemaining (number): kills remaining until next skull for the 7-day window.
--   - killsMonth (number): current progress value for the last 30 days.
--   - killsMonthRemaining (number): kills remaining until next skull for the 30-day window.
function onUnjustifiedPointsChange(unjustifiedPoints)
    if unjustifiedPoints.skullTime == 0 then
        skullTimeLabel:setText(tr('No skull'))
        skullTimeLabel:setTooltip(tr('You have no skull'))
    else
        skullTimeLabel:setText(unjustifiedPoints.skullTime .. ' ' .. tr('days'))
        skullTimeLabel:setTooltip(tr('Remaining skull time'))
    end

    dayProgressBar:setValue(unjustifiedPoints.killsDay, 0, 100)
    dayProgressBar:setBackgroundColor(getColorByKills(unjustifiedPoints.killsDayRemaining))
    dayProgressBar:setTooltip(string.format('Unjustified points gained during the last 24 hours.\n%i kill%s left.',
                                            unjustifiedPoints.killsDayRemaining,
                                            (unjustifiedPoints.killsDayRemaining == 1 and '' or 's')))
    dayProgressBar:setText(string.format('%i kill%s left', unjustifiedPoints.killsDayRemaining,
                                         (unjustifiedPoints.killsDayRemaining == 1 and '' or 's')))

    weekProgressBar:setValue(unjustifiedPoints.killsWeek, 0, 100)
    weekProgressBar:setBackgroundColor(getColorByKills(unjustifiedPoints.killsWeekRemaining))
    weekProgressBar:setTooltip(string.format('Unjustified points gained during the last 7 days.\n%i kill%s left.',
                                             unjustifiedPoints.killsWeekRemaining,
                                             (unjustifiedPoints.killsWeekRemaining == 1 and '' or 's')))
    weekProgressBar:setText(string.format('%i kill%s left', unjustifiedPoints.killsWeekRemaining,
                                          (unjustifiedPoints.killsWeekRemaining == 1 and '' or 's')))

    monthProgressBar:setValue(unjustifiedPoints.killsMonth, 0, 100)
    monthProgressBar:setBackgroundColor(getColorByKills(unjustifiedPoints.killsMonthRemaining))
    monthProgressBar:setTooltip(string.format('Unjustified points gained during the last 30 days.\n%i kill%s left.',
                                              unjustifiedPoints.killsMonthRemaining,
                                              (unjustifiedPoints.killsMonthRemaining == 1 and '' or 's')))
    monthProgressBar:setText(string.format('%i kill%s left', unjustifiedPoints.killsMonthRemaining,
                                           (unjustifiedPoints.killsMonthRemaining == 1 and '' or 's')))
end