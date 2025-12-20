rvreasons = {}
rvreasons[1] = tr("otclient_modules.ruleviolation.tr_36")
rvreasons[2] = tr("otclient_modules.ruleviolation.tr_35")
rvreasons[3] = tr("otclient_modules.ruleviolation.tr_34")
rvreasons[4] = tr("otclient_modules.ruleviolation.tr_33")
rvreasons[5] = tr("otclient_modules.ruleviolation.tr_32")
rvreasons[6] = tr("otclient_modules.ruleviolation.tr_31")
rvreasons[7] = tr("otclient_modules.ruleviolation.tr_30")
rvreasons[8] = tr("otclient_modules.ruleviolation.tr_29")
rvreasons[9] = tr("otclient_modules.ruleviolation.tr_28")
rvreasons[10] = tr("otclient_modules.ruleviolation.tr_27")
rvreasons[11] = tr("otclient_modules.ruleviolation.tr_26")
rvreasons[12] = tr("otclient_modules.ruleviolation.tr_25")
rvreasons[13] = tr("otclient_modules.ruleviolation.tr_24")
rvreasons[14] = tr("otclient_modules.ruleviolation.tr_23")
rvreasons[15] = tr("otclient_modules.ruleviolation.tr_22")
rvreasons[16] = tr("otclient_modules.ruleviolation.tr_21")
rvreasons[17] = tr("otclient_modules.ruleviolation.tr_20")
rvreasons[18] = tr("otclient_modules.ruleviolation.tr_19")
rvreasons[19] = tr("otclient_modules.ruleviolation.tr_18")
rvreasons[20] = tr("otclient_modules.ruleviolation.tr_17")
rvreasons[21] = tr("otclient_modules.ruleviolation.tr_16")

rvactions = {}
rvactions[0] = tr("otclient_modules.ruleviolation.tr_15")
rvactions[1] = tr("otclient_modules.ruleviolation.tr_14")
rvactions[2] = tr("otclient_modules.ruleviolation.tr_13")
rvactions[3] = tr("otclient_modules.ruleviolation.tr_12")
rvactions[4] = tr("otclient_modules.ruleviolation.tr_11")
rvactions[5] = tr("otclient_modules.ruleviolation.tr_10")
rvactions[6] = tr("otclient_modules.ruleviolation.tr_9")

ruleViolationWindow = nil
reasonsTextList = nil
actionsTextList = nil

function init()
    connect(g_game, {
        onGMActions = loadReasons
    })

    ruleViolationWindow = g_ui.displayUI('ruleviolation')
    ruleViolationWindow:setVisible(false)

    reasonsTextList = ruleViolationWindow:getChildById('reasonList')
    actionsTextList = ruleViolationWindow:getChildById('actionList')

    g_keyboard.bindKeyDown('Ctrl+U', function()
        show()
    end)

    if g_game.isOnline() then
        loadReasons()
    end
end

function terminate()
    disconnect(g_game, {
        onGMActions = loadReasons
    })
    g_keyboard.unbindKeyDown('Ctrl+U')

    ruleViolationWindow:destroy()
end

function hasWindowAccess()
    return reasonsTextList:getChildCount() > 0
end

function loadReasons()
    reasonsTextList:destroyChildren()
    actionsTextList:destroyChildren()

    local actions = g_game.getGMActions()
    for reason, actionFlags in pairs(actions) do
        local label = g_ui.createWidget('RVListLabel', reasonsTextList)
        label.onFocusChange = onSelectReason
        label:setText(rvreasons[reason])
        label.reasonId = reason
        label.actionFlags = actionFlags
    end

    if not hasWindowAccess() and ruleViolationWindow:isVisible() then
        hide()
    end
end

function show(target, statement)
    if g_game.isOnline() and hasWindowAccess() then
        if target then
            ruleViolationWindow:getChildById('nameText'):setText(target)
        end

        if statement then
            ruleViolationWindow:getChildById('statementText'):setText(statement)
        end

        ruleViolationWindow:show()
        ruleViolationWindow:raise()
        ruleViolationWindow:focus()
        ruleViolationWindow:getChildById('commentText'):focus()
    end
end

function hide()
    ruleViolationWindow:hide()
    clearForm()
end

function onSelectReason(reasonLabel, focused)
    if reasonLabel.actionFlags and focused then
        actionsTextList:destroyChildren()
        for actionBaseFlag = 0, #rvactions do
            local actionFlagString = rvactions[actionBaseFlag]
            if bit.band(reasonLabel.actionFlags, math.pow(2, actionBaseFlag)) > 0 then
                local label = g_ui.createWidget('RVListLabel', actionsTextList)
                label:setText(actionFlagString)
                label.actionId = actionBaseFlag
            end
        end
    end
end

function report()
    local reasonLabel = reasonsTextList:getFocusedChild()
    if not reasonLabel then
        displayErrorBox(tr("otclient_modules.ruleviolation.tr_8"), tr("otclient_modules.ruleviolation.tr_7"))
        return
    end

    local actionLabel = actionsTextList:getFocusedChild()
    if not actionLabel then
        displayErrorBox(tr("otclient_modules.ruleviolation.tr_6"), tr("otclient_modules.ruleviolation.tr_5"))
        return
    end

    local target = ruleViolationWindow:getChildById('nameText'):getText()
    local reason = reasonLabel.reasonId
    local action = actionLabel.actionId
    local comment = ruleViolationWindow:getChildById('commentText'):getText()
    local statement = ruleViolationWindow:getChildById('statementText'):getText()
    local statementId = 0 -- TODO: message unique id ?
    local ipBanishment = ruleViolationWindow:getChildById('ipBanCheckBox'):isChecked()
    if action == 6 and statement == '' then
        displayErrorBox(tr("otclient_modules.ruleviolation.tr_4"), tr("otclient_modules.ruleviolation.tr_3"))
    elseif comment == '' then
        displayErrorBox(tr("otclient_modules.ruleviolation.tr_2"), tr("otclient_modules.ruleviolation.tr_1"))
    else
        g_game.reportRuleViolation(target, reason, action, comment, statement, statementId, ipBanishment)
        hide()
    end
end

function clearForm()
    ruleViolationWindow:getChildById('nameText'):clearText()
    ruleViolationWindow:getChildById('commentText'):clearText()
    ruleViolationWindow:getChildById('statementText'):clearText()
    ruleViolationWindow:getChildById('ipBanCheckBox'):setChecked(false)
end
