EnterGame = {}

-- private variables
local loadBox
local enterGame
local motdWindow
local enterGameButton
local clientBox
local protocolLogin
local motdEnabled = true

local function getEnterGameWidget(id)
    if not enterGame then
        return nil
    end

    if enterGame.recursiveGetChildById then
        return enterGame:recursiveGetChildById(id) or enterGame:getChildById(id)
    end

    return enterGame:getChildById(id)
end

-- private functions
local function onError(protocol, message, errorCode)
    if loadBox then
        loadBox:destroy()
        loadBox = nil
    end

    if not errorCode then
        EnterGame.clearAccountFields()
    end

    local errorBox = displayErrorBox(tr('Login Error'), message)
    connect(errorBox, {
        onOk = EnterGame.show
    })
end

local function onMotd(protocol, motd)
    G.motdNumber = tonumber(motd:sub(0, motd:find('\n')))
    G.motdMessage = motd:sub(motd:find('\n') + 1, #motd)
end

local function onSessionKey(protocol, sessionKey)
    G.sessionKey = sessionKey
end

local function onCharacterList(protocol, characters, account, otui)
    local httpLoginBox = getEnterGameWidget('httpLoginBox')
    local httpLogin = httpLoginBox and httpLoginBox:isChecked() or false

    -- Try add server to the server list
    ServerList.add(G.host, G.port, g_game.getClientVersion(), httpLogin)

    -- Save 'Stay logged in' setting
    local stayLoggedBox = getEnterGameWidget('stayLoggedBox')
    g_settings.set('staylogged', stayLoggedBox and stayLoggedBox:isChecked() or false)
    g_settings.set('httpLogin', httpLogin)

    local rememberEmailBox = getEnterGameWidget('rememberEmailBox')
    if rememberEmailBox and rememberEmailBox:isChecked() then
        local account = g_crypt.encrypt(G.account)
        local password = g_crypt.encrypt(G.password)

        g_settings.set('account', account)
        g_settings.set('password', password)

        ServerList.setServerAccount(G.host, account)
        ServerList.setServerPassword(G.host, password)

        local autoLoginBox = getEnterGameWidget('autoLoginBox')
        g_settings.set('autologin', autoLoginBox and autoLoginBox:isChecked() or false)
    else
        -- reset server list account/password
        ServerList.setServerAccount(G.host, '')
        ServerList.setServerPassword(G.host, '')

        EnterGame.clearAccountFields()
    end

    if loadBox then
        loadBox:destroy()
        loadBox = nil
    end

    for _, characterInfo in pairs(characters) do
        if characterInfo.previewState and characterInfo.previewState ~= PreviewState.Default then
            characterInfo.worldName = characterInfo.worldName .. ', Preview'
        end
    end

    CharacterList.create(characters, account, otui)
    CharacterList.show()

    if motdEnabled then
        local lastMotdNumber = g_settings.getNumber('motd')
        if G.motdNumber and G.motdNumber ~= lastMotdNumber then
            g_settings.set('motd', G.motdNumber)
            motdWindow = displayInfoBox(tr('Message of the day'), G.motdMessage)
            connect(motdWindow, {
                onOk = function()
                    CharacterList.show()
                    motdWindow = nil
                end
            })
            CharacterList.hide()
        end
    end
end

local function onUpdateNeeded(protocol, signature)
    if loadBox then
        loadBox:destroy()
        loadBox = nil
    end

    if EnterGame.updateFunc then
        local continueFunc = EnterGame.show
        local cancelFunc = EnterGame.show
        EnterGame.updateFunc(signature, continueFunc, cancelFunc)
    else
        local errorBox = displayErrorBox(tr('Update needed'), tr('Your client needs updating, try redownloading it.'))
        connect(errorBox, {
            onOk = EnterGame.show
        })
    end
end

local function updateLabelText()
    local clientComboBox = getEnterGameWidget('clientComboBox')
    if clientComboBox and tonumber(clientComboBox:getText()) > 1080 then
        enterGame:setText(tr("Journey Onwards"))
        local emailLabel = getEnterGameWidget('emailLabel')
        if emailLabel then
            emailLabel:setText(tr("Email:"))
        end
        local rememberEmailBox = getEnterGameWidget('rememberEmailBox')
        if rememberEmailBox then
            rememberEmailBox:setText(tr("Remember Email:"))
        end
    else
        enterGame:setText(tr("Enter Game"))
        local emailLabel = getEnterGameWidget('emailLabel')
        if emailLabel then
            emailLabel:setText(tr("Acc Name:"))
        end
        local rememberEmailBox = getEnterGameWidget('rememberEmailBox')
        if rememberEmailBox then
            rememberEmailBox:setText(tr("Remember password:"))
        end
    end
end

-- public functions
function EnterGame.init()
    enterGame = g_ui.displayUI('entergame')
    Keybind.new("Misc.", "Change Character", "Ctrl+G", "")
    Keybind.bind("Misc.", "Change Character", {
      {
        type = KEY_DOWN,
        callback = EnterGame.openWindow,
      }
    })

    local account = g_settings.get('account')
    local password = g_settings.get('password')
    local host = g_settings.get('host')
    local port = g_settings.get('port')
    local stayLogged = g_settings.getBoolean('staylogged')
    local autologin = g_settings.getBoolean('autologin')
    local httpLogin = g_settings.getBoolean('httpLogin')
    local clientVersion = g_settings.getInteger('client-version')

    if not clientVersion or clientVersion == 0 then
        clientVersion = 1420
    end

    if not port or port == 0 then
        port = 80
    end

    EnterGame.setAccountName(account)
    EnterGame.setPassword(password)

    local serverHostTextEdit = getEnterGameWidget('serverHostTextEdit')
    if serverHostTextEdit then
        serverHostTextEdit:setText(host)
    end

    local serverPortTextEdit = getEnterGameWidget('serverPortTextEdit')
    if serverPortTextEdit then
        serverPortTextEdit:setText(port)
    end

    local autoLoginBox = getEnterGameWidget('autoLoginBox')
    if autoLoginBox then
        autoLoginBox:setChecked(autologin)
    end

    local stayLoggedBox = getEnterGameWidget('stayLoggedBox')
    if stayLoggedBox then
        stayLoggedBox:setChecked(stayLogged)
    end

    local httpLoginBox = getEnterGameWidget('httpLoginBox')
    if httpLoginBox then
        httpLoginBox:setChecked(httpLogin)
    end

    local installedClients = {}
    local amountInstalledClients = 0
    for _, dirItem in ipairs(g_resources.listDirectoryFiles('/data/things/')) do
        if tonumber(dirItem) then
            installedClients[dirItem] = true
            amountInstalledClients = amountInstalledClients + 1
        end
    end

    clientBox = getEnterGameWidget('clientComboBox')
    if not clientBox then
        print('Warning: client_entergame: clientComboBox not found in entergame UI; using configured client-version without UI selector.')
    else
        for _, proto in pairs(g_game.getSupportedClients()) do
            local protoStr = tostring(proto)
            if installedClients[protoStr] or amountInstalledClients == 0 then
                installedClients[protoStr] = nil
                clientBox:addOption(proto)
            end
        end

        for protoStr, status in pairs(installedClients) do
            if status then
                print(string.format('Warning: %s recognized as an installed client, but not supported.', protoStr))
            end
        end

        clientBox:setCurrentOption(clientVersion)

        connect(clientBox, {
            onOptionChange = EnterGame.onClientVersionChange
        })
    end

    if Servers_init then
        if table.size(Servers_init) == 1 then
            local hostInit, valuesInit = next(Servers_init)
            EnterGame.setUniqueServer(hostInit, valuesInit.port, valuesInit.protocol)
            EnterGame.setHttpLogin(valuesInit.httpLogin)
        elseif not host or host == "" then
            local hostInit, valuesInit = next(Servers_init)
            EnterGame.setDefaultServer(hostInit, valuesInit.port, valuesInit.protocol)
            EnterGame.setHttpLogin(valuesInit.httpLogin)
        end
    else
        EnterGame.toggleAuthenticatorToken(clientVersion, true)
        EnterGame.toggleStayLoggedBox(clientVersion, true)
    end

    updateLabelText()

    enterGame:hide()

    connect(g_game, {
        onGameStart = EnterGame.hidePanels
    })

    connect(g_game, {
        onGameEnd = EnterGame.showPanels
    })

    if g_app.isRunning() and not g_game.isOnline() then
        enterGame:show()
    end
end

function EnterGame.hidePanels()
    if g_modules.getModule("client_bottommenu"):isLoaded()  then
        modules.client_bottommenu.hide()
    end
    modules.client_topmenu.hide()
end

function EnterGame.showPanels()
    if g_modules.getModule("client_bottommenu"):isLoaded()  then
        modules.client_bottommenu.show()
    end
    modules.client_topmenu.show()
end

function EnterGame.firstShow()
    EnterGame.show()

    local account = g_crypt.decrypt(g_settings.get('account'))
    local password = g_crypt.decrypt(g_settings.get('password'))
    local host = g_settings.get('host')
    local autologin = g_settings.getBoolean('autologin')
    if #host > 0 and #password > 0 and #account > 0 and autologin then
        addEvent(function()
            if not g_settings.getBoolean('autologin') then
                return
            end
            EnterGame.doLogin()
        end)
    end

    if Services and Services.status then
        if g_modules.getModule("client_bottommenu"):isLoaded()  then
            EnterGame.postCacheInfo()
            EnterGame.postEventScheduler()
            -- EnterGame.postShowOff() -- myacc/znote no send login.php
            EnterGame.postShowCreatureBoost()
        end
    end
end

function EnterGame.terminate()
    Keybind.delete("Misc.", "Change Character")

    if clientBox then
        pcall(function()
            disconnect(clientBox, {
                onOptionChange = EnterGame.onClientVersionChange
            })
        end)
    end
    disconnect(g_game, {
        onGameStart = EnterGame.hidePanels
    })
    disconnect(g_game, {
        onGameEnd = EnterGame.showPanels
    })

    if enterGame then
        enterGame:destroy()
        enterGame = nil
    end

    if clientBox then
        clientBox = nil
    end

    if motdWindow then
        motdWindow:destroy()
        motdWindow = nil
    end

    if loadBox then
        loadBox:destroy()
        loadBox = nil
    end

    if protocolLogin then
        protocolLogin:cancelLogin()
        protocolLogin = nil
    end

    EnterGame = nil
end

local function reportRequestWarning(requestType, msg, errorCode)
    g_logger.warning(("[Webscraping - %s] %s"):format(requestType, msg), errorCode)
end

function EnterGame.postCacheInfo()
    local requestType = 'cacheinfo'
    local onRecvInfo = function(message, err)

        if err then
            -- onError(nil, 'Bad Request. Game_entergame postCacheInfo1 ', 400)
            reportRequestWarning(requestType, "Bad Request. Game_entergame postCacheInfo1")
            return
        end

        local jsonString = message:match("{.*}")
        if not jsonString then
            reportRequestWarning(requestType, "Invalid JSON response format")
            return
        end

        local success, response = pcall(function() return json.decode(jsonString) end)
        if not success or not response then
            reportRequestWarning(requestType, "Failed to parse JSON response")
            return
        end

        if response.errorMessage then
            reportRequestWarning(requestType, response.errorMessage, response.errorCode)
            return
        end

        modules.client_topmenu.setPlayersOnline(response.playersonline)
        modules.client_topmenu.setDiscordStreams(response.discord_online)
        modules.client_topmenu.setYoutubeStreams(response.gamingyoutubestreams)
        modules.client_topmenu.setYoutubeViewers(response.gamingyoutubeviewer)
        modules.client_topmenu.setLinkYoutube(response.youtube_link)
        modules.client_topmenu.setLinkDiscord(response.discord_link)

    end

    HTTP.post(Services.status, json.encode({
        type = requestType
    }), onRecvInfo, false)
end

function EnterGame.postEventScheduler()
    local requestType = 'eventschedule'
    local onRecvInfo = function(message, err)
        if err then
            reportRequestWarning(requestType, "Bad Request.Game_entergame postEventScheduler1")
            return
        end

        local jsonString = message:match("{.*}")
        if not jsonString then
            reportRequestWarning(requestType, "Invalid JSON response format")
            return
        end

        local success, response = pcall(function() return json.decode(jsonString) end)
        if not success or not response then
            reportRequestWarning(requestType, "Failed to parse JSON response")
            return
        end

        if response.errorMessage then
            reportRequestWarning(requestType, response.errorMessage, response.errorCode)
            return
        end
        modules.client_bottommenu.setEventsSchedulerTimestamp(response.lastupdatetimestamp)
        modules.client_bottommenu.setEventsSchedulerCalender(response.eventlist)
    end

    HTTP.post(Services.status, json.encode({
        type = requestType
    }), onRecvInfo, false)
end

function EnterGame.postShowOff()
    local requestType = 'showoff'
    local onRecvInfo = function(message, err)
        if err then
            reportRequestWarning(requestType, "Bad Request.Game_entergame postShowOff")
            return
        end

        local jsonString = message:match("{.*}")
        if not jsonString then
            reportRequestWarning(requestType, "Invalid JSON response format")
            return
        end

        local success, response = pcall(function() return json.decode(jsonString) end)
        if not success or not response then
            reportRequestWarning(requestType, "Failed to parse JSON response")
            return
        end

        if response.errorMessage then
            reportRequestWarning(requestType, response.errorMessage, response.errorCode)
            return
        end

        modules.client_bottommenu.setShowOffData(response)
    end

    HTTP.post(Services.status, json.encode({
        type = requestType
    }), onRecvInfo, false)
end

function EnterGame.postShowCreatureBoost()
    local requestType = 'boostedcreature'
    local onRecvInfo = function(message, err)
        if err then
            -- onError(nil, 'Bad Request. 1 Game_entergame postShowCreatureBoost', 400)
            reportRequestWarning(requestType, "Bad Request.Game_entergame postShowCreatureBoost1")
            return
        end

        local jsonString = message:match("{.*}")
        if not jsonString then
            reportRequestWarning(requestType, "Invalid JSON response format")
            return
        end

        local success, response = pcall(function() return json.decode(jsonString) end)
        if not success or not response then
            reportRequestWarning(requestType, "Failed to parse JSON response")
            return
        end

        if response.errorMessage then
            reportRequestWarning(requestType, response.errorMessage, response.errorCode)
            return
        end

        modules.client_bottommenu.setBoostedCreatureAndBoss(response)
    end

    HTTP.post(Services.status, json.encode({
        type = requestType
    }), onRecvInfo, false)
end

function EnterGame.show()
    if g_game.isOnline() or CharacterList.isVisible() then -- fix login quickly error (http post)
        return
    end

    if loadBox then
        return
    end

    enterGame:show()
    enterGame:raise()
    enterGame:focus()
end

function EnterGame.hide()
    enterGame:hide()
end

function EnterGame.openWindow()
    if g_game.isOnline() then
        CharacterList.show()
    elseif not g_game.isLogging() and not CharacterList.isVisible() then
        EnterGame.show()
    end
end

function EnterGame.setAccountName(account)
    local account = g_crypt.decrypt(account)
    local accountNameTextEdit = getEnterGameWidget('accountNameTextEdit')
    if accountNameTextEdit then
        accountNameTextEdit:setText(account)
        accountNameTextEdit:setCursorPos(-1)
    end

    local rememberEmailBox = getEnterGameWidget('rememberEmailBox')
    if rememberEmailBox then
        rememberEmailBox:setChecked(#account > 0)
    end
end

function EnterGame.setPassword(password)
    local password = g_crypt.decrypt(password)
    local accountPasswordTextEdit = getEnterGameWidget('accountPasswordTextEdit')
    if accountPasswordTextEdit then
        accountPasswordTextEdit:setText(password)
    end
end

function EnterGame.setHttpLogin(httpLogin)
    local httpLoginBox = getEnterGameWidget('httpLoginBox')
    if not httpLoginBox then
        return
    end

    if type(httpLogin) == "boolean" then
        httpLoginBox:setChecked(httpLogin)
    else
        httpLoginBox:setChecked(#httpLogin > 0)
    end
end

function EnterGame.clearAccountFields()
    local accountNameTextEdit = getEnterGameWidget('accountNameTextEdit')
    if accountNameTextEdit then
        accountNameTextEdit:clearText()
        accountNameTextEdit:focus()
    end

    local accountPasswordTextEdit = getEnterGameWidget('accountPasswordTextEdit')
    if accountPasswordTextEdit then
        accountPasswordTextEdit:clearText()
    end

    local authenticatorTokenTextEdit = getEnterGameWidget('authenticatorTokenTextEdit')
    if authenticatorTokenTextEdit then
        authenticatorTokenTextEdit:clearText()
    end
    g_settings.remove('account')
    g_settings.remove('password')
end

function EnterGame.toggleAuthenticatorToken(clientVersion, init)
    if not enterGame.disableToken then
        return
    end

    local enabled = (clientVersion >= 1072)
    if enabled == enterGame.authenticatorEnabled then
        return
    end

    local authenticatorTokenLabel = getEnterGameWidget('authenticatorTokenLabel')
    if authenticatorTokenLabel then
        authenticatorTokenLabel:setOn(enabled)
    end
    local authenticatorTokenTextEdit = getEnterGameWidget('authenticatorTokenTextEdit')
    if authenticatorTokenTextEdit then
        authenticatorTokenTextEdit:setOn(enabled)
    end

    local newHeight = enterGame:getHeight()
    local newY = enterGame:getY()
    if enabled then
        newY = newY - enterGame.authenticatorHeight
        newHeight = newHeight + enterGame.authenticatorHeight
    else
        newY = newY + enterGame.authenticatorHeight
        newHeight = newHeight - enterGame.authenticatorHeight
    end

    if not init then
        enterGame:breakAnchors()
        enterGame:setY(newY)
        enterGame:bindRectToParent()
    end

    enterGame:setHeight(newHeight)
    enterGame.authenticatorEnabled = enabled
end

function EnterGame.toggleStayLoggedBox(clientVersion, init)
    if not enterGame.disableToken then
        return
    end
    local enabled = (clientVersion >= 1074)
    if enabled == enterGame.stayLoggedBoxEnabled then
        return
    end

    local stayLoggedBox = getEnterGameWidget('stayLoggedBox')
    if stayLoggedBox then
        stayLoggedBox:setOn(enabled)
    end

    local newHeight = enterGame:getHeight()
    local newY = enterGame:getY()
    if enabled then
        newY = newY - enterGame.stayLoggedBoxHeight
        newHeight = newHeight + enterGame.stayLoggedBoxHeight
    else
        newY = newY + enterGame.stayLoggedBoxHeight
        newHeight = newHeight - enterGame.stayLoggedBoxHeight
    end

    if not init then
        enterGame:breakAnchors()
        enterGame:setY(newY)
        enterGame:bindRectToParent()
    end

    enterGame:setHeight(newHeight)
    enterGame.stayLoggedBoxEnabled = enabled
end

function EnterGame.onClientVersionChange(comboBox, text, data)
    local clientVersion = tonumber(text)
    EnterGame.toggleAuthenticatorToken(clientVersion)
    EnterGame.toggleStayLoggedBox(clientVersion)
    updateLabelText()
end

function EnterGame.tryHttpLogin(clientVersion, httpLogin)
    g_game.setClientVersion(clientVersion)
    g_game.setProtocolVersion(g_game.getClientProtocolVersion(clientVersion))
    g_game.chooseRsa(G.host)
    if not modules.game_things.isLoaded() then
        if loadBox then
            loadBox:destroy()
            loadBox = nil
        end

        local errorBox = displayErrorBox(tr("Login Error"), string.format("Things are not loaded, please put assets in things/%d/<assets>.", clientVersion))
        connect(errorBox, {
            onOk = EnterGame.show
        })
        return
    end

    local host, path = G.host:match("([^/]+)/([^/].*)")
    local url = G.host

    if not G.port then
        local isHttps, _ = string.find(host, "https")
        if not isHttps then
            G.port = 443
        else -- http
            G.port = 80
        end
    end

    if not path then
        path = ""
    else
        path = '/' .. path
    end

    if not host then
        loadBox = displayCancelBox(tr('Please wait'), tr('ERROR , try adding \n- ip/login.php \n- Enable HTTP login'))
    else
        loadBox = displayCancelBox(tr('Please wait'), tr('Connecting to login server...\nServer: [%s]',
            host .. ":" .. tostring(G.port) .. path))
    end

    connect(loadBox, {
        onCancel = function(msgbox)
            loadBox = nil
            G.requestId = 0
            EnterGame.show()
        end
    })

    math.randomseed(os.time())
    G.requestId = math.random(1)

    local http = LoginHttp.create()
    http:httpLogin(host, path, G.port, G.account, G.password, G.requestId, httpLogin)
end

function printTable(t)
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(string.format("%q: {", k))
            printTable(v)
            print("}")
        else
            print(string.format("%q:", k) .. tostring(v) .. ",")
        end
    end
end

function EnterGame.loginSuccess(requestId, jsonSession, jsonWorlds, jsonCharacters)
    if G.requestId ~= requestId then
        return
    end

    local worlds = {}
    for _, world in ipairs(json.decode(jsonWorlds)) do
        worlds[world.id] = {
            name = world.name,
            ip = world.externaladdressprotected or world.externaladdress,
            port = world.externalportprotected or world.externalport,
            previewState = world.previewstate == 1
        }
    end

    local characters = {}
    for index, character in ipairs(json.decode(jsonCharacters)) do
        local world = worlds[character.worldid]
        characters[index] = {
            name = character.name,
            level = character.level,
            main = character.ismaincharacter,
            dailyreward = character.dailyrewardstate,
            hidden = character.ishidden,
            vocation = character.vocation,
            outfitid = character.outfitid,
            headcolor = character.headcolor,
            torsocolor = character.torsocolor,
            legscolor = character.legscolor,
            detailcolor = character.detailcolor,
            addonsflags = character.addonsflags,
            worldName = world.name,
            worldIp = world.ip,
            worldPort = world.port,
            previewState = world.previewstate
        }
    end

    local session = json.decode(jsonSession)

    local premiumUntil = tonumber(session.premiumuntil)

    local account = {
        status = '',
        premDays = math.floor((premiumUntil - os.time()) / 86400),
        subStatus = premiumUntil > os.time() and SubscriptionStatus.Premium or SubscriptionStatus.Free
    }

    -- set session key
    G.sessionKey = session.sessionkey

    onCharacterList(nil, characters, account)
end

function EnterGame.loginFailed(requestId, msg, result)
    if G.requestId ~= requestId then
        return
    end
    onError(nil, msg, result)
end

function EnterGame.doLogin()
    local accountNameTextEdit = getEnterGameWidget('accountNameTextEdit')
    G.account = accountNameTextEdit and accountNameTextEdit:getText() or ''

    local accountPasswordTextEdit = getEnterGameWidget('accountPasswordTextEdit')
    G.password = accountPasswordTextEdit and accountPasswordTextEdit:getText() or ''

    local authenticatorTokenTextEdit = getEnterGameWidget('authenticatorTokenTextEdit')
    G.authenticatorToken = authenticatorTokenTextEdit and authenticatorTokenTextEdit:getText() or ''

    local stayLoggedBox = getEnterGameWidget('stayLoggedBox')
    G.stayLogged = stayLoggedBox and stayLoggedBox:isChecked() or false

    local serverHostTextEdit = getEnterGameWidget('serverHostTextEdit')
    G.host = serverHostTextEdit and serverHostTextEdit:getText() or ''

    local serverPortTextEdit = getEnterGameWidget('serverPortTextEdit')
    G.port = tonumber(serverPortTextEdit and serverPortTextEdit:getText() or '') or 0

    local clientVersion = tonumber((clientBox and clientBox:getText()) or '') or 1420

    local httpLoginBox = getEnterGameWidget('httpLoginBox')
    local httpLogin = httpLoginBox and httpLoginBox:isChecked() or false
    EnterGame.hide()

    if g_game.isOnline() then
        local errorBox = displayErrorBox(tr('Login Error'), tr('Cannot login while already in game.'))
        connect(errorBox, {
            onOk = EnterGame.show
        })
        return
    end

    g_settings.set('host', G.host)
    g_settings.set('port', G.port)
    g_settings.set('client-version', clientVersion)

    if clientVersion >= 1281 and G.port ~= 7171 then
        EnterGame.tryHttpLogin(clientVersion, httpLogin)
    else
        protocolLogin = ProtocolLogin.create()
        protocolLogin.onLoginError = onError
        protocolLogin.onMotd = onMotd
        protocolLogin.onSessionKey = onSessionKey
        protocolLogin.onCharacterList = onCharacterList
        protocolLogin.onUpdateNeeded = onUpdateNeeded

        loadBox = displayCancelBox(tr('Please wait'), tr('Connecting to login server...'))
        connect(loadBox, {
            onCancel = function(msgbox)
                loadBox = nil
                protocolLogin:cancelLogin()
                EnterGame.show()
            end
        })

        g_game.setClientVersion(clientVersion)
        g_game.setProtocolVersion(g_game.getClientProtocolVersion(clientVersion))
        g_game.chooseRsa(G.host)

        if modules.game_things.isLoaded() then
            protocolLogin:login(G.host, G.port, G.account, G.password, G.authenticatorToken, G.stayLogged)
        else
            if loadBox then
                loadBox:destroy()
                loadBox = nil
            end

            local errorBox = displayErrorBox(tr("Login Error"), string.format("Things are not loaded, please put spr and dat in things/%d/<here>.", clientVersion))
            connect(errorBox, {
               onOk = EnterGame.show
            })
            return
        end
    end
end

function EnterGame.displayMotd()
    if not motdWindow then
        motdWindow = displayInfoBox(tr('Message of the day'), G.motdMessage)
        motdWindow.onOk = function()
            motdWindow = nil
        end
    end
end

function EnterGame.setDefaultServer(host, port, protocol)
    local hostTextEdit = getEnterGameWidget('serverHostTextEdit')
    local portTextEdit = getEnterGameWidget('serverPortTextEdit')
    local accountTextEdit = getEnterGameWidget('accountNameTextEdit')
    local passwordTextEdit = getEnterGameWidget('accountPasswordTextEdit')
    local authenticatorTokenTextEdit = getEnterGameWidget('authenticatorTokenTextEdit')

    if not hostTextEdit then
        return
    end

    if hostTextEdit:getText() ~= host then
        hostTextEdit:setText(host)
        if portTextEdit then
            portTextEdit:setText(port)
        end
        if clientBox then
            clientBox:setCurrentOption(protocol)
        end
        if accountTextEdit then
            accountTextEdit:setText('')
        end
        if passwordTextEdit then
            passwordTextEdit:setText('')
        end
        if authenticatorTokenTextEdit then
            authenticatorTokenTextEdit:setText('')
        end
    end
end

function EnterGame.setUniqueServer(host, port, protocol, windowWidth, windowHeight)
    local hostTextEdit = getEnterGameWidget('serverHostTextEdit')
    if hostTextEdit then
        hostTextEdit:setText(host)
        hostTextEdit:setVisible(false)
        hostTextEdit:setHeight(0)
    end

    local portTextEdit = getEnterGameWidget('serverPortTextEdit')
    if portTextEdit then
        portTextEdit:setText(port)
        portTextEdit:setVisible(false)
        portTextEdit:setHeight(0)
    end

    local authenticatorTokenTextEdit = getEnterGameWidget('authenticatorTokenTextEdit')
    if authenticatorTokenTextEdit then
        authenticatorTokenTextEdit:setText('')
        authenticatorTokenTextEdit:setOn(false)
    end

    local authenticatorTokenLabel = getEnterGameWidget('authenticatorTokenLabel')
    if authenticatorTokenLabel then
        authenticatorTokenLabel:setOn(false)
    end

    local stayLoggedBox = getEnterGameWidget('stayLoggedBox')
    if stayLoggedBox then
        stayLoggedBox:setChecked(false)
        stayLoggedBox:setOn(false)
    end

    local clientVersion = tonumber(protocol)
    if clientBox then
        clientBox:setCurrentOption(clientVersion)
        clientBox:setVisible(false)
        clientBox:setHeight(0)
    end

    local serverLabel = getEnterGameWidget('serverLabel')
    if serverLabel then
        serverLabel:setVisible(false)
        serverLabel:setHeight(0)
    end

    local portLabel = getEnterGameWidget('portLabel')
    if portLabel then
        portLabel:setVisible(false)
        portLabel:setHeight(0)
    end

    local clientLabel = getEnterGameWidget('clientLabel')
    if clientLabel then
        clientLabel:setVisible(false)
        clientLabel:setHeight(0)
    end

    local httpLoginBox = getEnterGameWidget('httpLoginBox')
    if httpLoginBox then
        httpLoginBox:setVisible(false)
        httpLoginBox:setHeight(0)
    end

    local serverListButton = getEnterGameWidget('serverListButton')
    if serverListButton then
        serverListButton:setVisible(false)
        serverListButton:setHeight(0)
        serverListButton:setWidth(0)
    end

    local rememberEmailBox = getEnterGameWidget('rememberEmailBox')
    if rememberEmailBox then
        rememberEmailBox:setMarginTop(5)
    end

    if not windowWidth then
        windowWidth = 380
    end
    enterGame:setWidth(windowWidth)
    if not windowHeight then
        windowHeight = 210
    end

    enterGame:setHeight(windowHeight)
    enterGame.disableToken = true

    -- preload the assets
    -- this is for the client_bottommenu module
    -- it needs images of outfits
    -- so it can display the boosted creature
    g_game.setClientVersion(clientVersion)
    g_game.setProtocolVersion(g_game.getClientProtocolVersion(clientVersion))
end

function EnterGame.setServerInfo(message)
    local label = getEnterGameWidget('serverInfoLabel')
    if label then
        label:setText(message)
    end
end

function EnterGame.disableMotd()
    motdEnabled = false
end

function ensableBtnCreateNewAccount()
    enterGame.btnCreateNewAccount:enable()
end
