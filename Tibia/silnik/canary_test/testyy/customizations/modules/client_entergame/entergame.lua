EnterGame = {}

-- private variables
local loadBox
local enterGame
local motdWindow
local enterGameButton
local clientBox
local protocolLogin
local motdEnabled = true
local gameModeSelected = false  -- czy gracz wybrał tryb gry
local noCharactersWindow
local launcherContextWindow
local pendingAccountContextRefresh = false
local launcherAutoLoginAttempted = false
local launcherContextState = nil

local function isPlayerMode()
    if g_game and g_game.isPlayerMode then
        return g_game.isPlayerMode()
    end
    return CLIENT_LOCKED
end

local function clearNoCharactersWindow()
    if noCharactersWindow then
        noCharactersWindow:destroy()
        noCharactersWindow = nil
    end
end

local function clearLauncherContextWindow()
    if launcherContextWindow then
        launcherContextWindow:destroy()
        launcherContextWindow = nil
    end
end

local function hasLaunchTokenContext()
    return #tostring(G.launchToken or "") > 0
end

local function dropLauncherRuntimeContext(reason)
    launcherContextState = reason or launcherContextState or "token_rejected"
    launcherAutoLoginAttempted = true
    pendingAccountContextRefresh = false
    G.launchToken = ""
    G.launcherSessionToken = ""
    G.sessionKey = nil
    G.legacySessionKey = nil
end

local function closeClientFromLauncherGate()
    clearLauncherContextWindow()
    if g_app and g_app.close then
        g_app.close()
    end
end

local function showLauncherRequiredScreen(reason)
    launcherContextState = reason or launcherContextState or "no_context"

    clearNoCharactersWindow()
    clearLauncherContextWindow()

    if loadBox then
        loadBox:destroy()
        loadBox = nil
    end

    if CharacterList and CharacterList.isVisible and CharacterList.isVisible() and CharacterList.hide then
        CharacterList.hide(false)
    end

    if enterGame then
        enterGame:hide()
    end

    local title = "Uruchom gre przez launcher"
    local text = "Ten klient w trybie gracza dziala tylko z oficjalnego launchera.\nUruchom gre ponownie z launchera."
    if launcherContextState == "token_rejected" then
        title = "Wymagane ponowne logowanie"
        text = "Token startowy wygasl albo zostal odrzucony.\nZaloguj sie ponownie w launcherze i uruchom gre jeszcze raz."
    end

    launcherContextWindow = displayGeneralBox(title, text, {
        {
            text = "Zamknij",
            callback = closeClientFromLauncherGate
        },
        anchor = AnchorHorizontalCenter
    }, closeClientFromLauncherGate, clearLauncherContextWindow)
end

local function shouldForceLauncherRelogin(message, errorCode)
    local code = tonumber(errorCode) or 0
    local launchToken = tostring(G.launchToken or "")
    local msg = tostring(message or ""):lower()

    if (code == 401 or code == 403) and (isPlayerMode() or #launchToken > 0) then
        return true
    end

    if msg:find("launch", 1, true) and msg:find("token", 1, true) then
        return true
    end

    if msg:find("session", 1, true) and
        (msg:find("expired", 1, true) or msg:find("invalid", 1, true) or msg:find("wygas", 1, true)) then
        return true
    end

    if msg:find("token", 1, true) and
        (msg:find("expired", 1, true) or msg:find("invalid", 1, true) or msg:find("reject", 1, true)) then
        return true
    end

    return false
end

local function shouldAutoLoginFromLauncher()
    if not isPlayerMode() then
        return false
    end

    if not hasLaunchTokenContext() then
        return false
    end

    if g_game.isOnline() or g_game.isLogging() then
        return false
    end

    if not gameModeSelected or not CurrentGameMode then
        return false
    end

    return true
end

local function triggerLauncherAutoLogin()
    if launcherAutoLoginAttempted then
        return
    end

    if not shouldAutoLoginFromLauncher() then
        return
    end

    launcherAutoLoginAttempted = true
    addEvent(function()
        if shouldAutoLoginFromLauncher() then
            EnterGame.doLogin()
        end
    end)
end

local function normalizeWorldId(worldId)
    local n = tonumber(worldId)
    if n == nil then
        return nil
    end
    return math.floor(n)
end

local function isWorldAllowedForActiveMode(characterInfo)
    if not isPlayerMode() then
        return true
    end

    if not CurrentGameMode or not isWorldAllowedForMode then
        return false
    end

    return isWorldAllowedForMode(CurrentGameMode, characterInfo and characterInfo.worldId, characterInfo and characterInfo.worldName)
end

local function buildCreateCharacterUrl(modeKey)
    if not modeKey then
        return nil
    end

    local srv = getCurrentServerConfig()
    if not srv or not srv.httpLoginUrl then
        return nil
    end

    local loginUrl = tostring(srv.httpLoginUrl)
    local origin = loginUrl:match("^(https?://[^/]+)")
    if not origin then
        return nil
    end

    local websiteBase = loginUrl:gsub("/apik/v1/login%.php.*$", ""):gsub("/login%.php.*$", "")
    if websiteBase == loginUrl then
        websiteBase = origin
    end

    return websiteBase .. "/account/createcharacter?source=installer&mode=" .. tostring(modeKey)
end

local function openCreateCharacterFlow(modeKey)
    local url = buildCreateCharacterUrl(modeKey)
    if not url then
        displayErrorBox("Create Character", "Brak konfiguracji URL tworzenia postaci. Skontaktuj sie z administratorem.")
        return
    end

    pendingAccountContextRefresh = true
    g_platform.openUrl(url)
end

-- LOG-009: Otwórz stronę rejestracji konta w przeglądarce
function EnterGame.openCreateAccount()
    local srv = getCurrentServerConfig()
    local websiteBase = "http://localhost"

    if srv and srv.httpLoginUrl then
        local loginUrl = tostring(srv.httpLoginUrl)
        local base = loginUrl:gsub("/apik/v1/login%.php.*$", ""):gsub("/login%.php.*$", "")
        local origin = loginUrl:match("^(https?://[^/]+)")
        if base ~= loginUrl then
            websiteBase = base
        elseif origin then
            websiteBase = origin
        end
    end

    g_platform.openUrl(websiteBase .. "/account/register")
end

-- OTC-009: Fetch account-context.php po loginie — odświeża dane konta (postacie, profil, uprawnienia)
local function buildAccountContextUrl()
    local srv = getCurrentServerConfig()
    if not srv or not srv.httpLoginUrl then return nil end
    -- login.php → account-context.php (ten sam katalog API)
    return tostring(srv.httpLoginUrl):gsub("login%.php", "account-context.php")
end

local function fetchAccountContext()
    if not G.sessionKey or G.sessionKey == "" then return end
    local url = buildAccountContextUrl()
    if not url then return end

    HTTP.postJSON(url, { sessionKey = G.sessionKey }, function(data, err)
        if err or not data then
            g_logger.warning("[OTC-009] account-context fetch failed: " .. tostring(err))
            return
        end
        -- Zapisz kontekst konta globalnie — dostępny dla UI (dashboard, character list)
        G.accountContext = data
        g_logger.info("[OTC-009] account-context refreshed")
    end)
end

local function showNoCharactersGate()
    clearNoCharactersWindow()

    local mode = GameModes and GameModes[CurrentGameMode] or nil
    local modeName = mode and mode.name or tostring(CurrentGameMode or "unknown")
    noCharactersWindow = displayGeneralBox(
        "Brak postaci na wybranym serwerze",
        "Konto nie ma postaci dla trybu: " .. modeName ..
        "\n\nUtworz postac na WWW i wroc do launchera.\nPo powrocie odswiez kontekst konta.",
        {
            {
                text = "Zamknij",
                callback = clearNoCharactersWindow
            },
            {
                text = "Odswiez konto",
                callback = function()
                    clearNoCharactersWindow()
                    EnterGame.doLogin()
                end
            },
            {
                text = "Utworz postac",
                callback = function()
                    clearNoCharactersWindow()
                    openCreateCharacterFlow(CurrentGameMode)
                end
            },
            anchor = AnchorHorizontalCenter
        },
        function()
            clearNoCharactersWindow()
            EnterGame.doLogin()
        end,
        clearNoCharactersWindow
    )
end

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

    local title = tr("otclient_modules.entergame.tr_21")
    local text = message
    if shouldForceLauncherRelogin(message, errorCode) then
        dropLauncherRuntimeContext("token_rejected")
        showLauncherRequiredScreen("token_rejected")
        return
    end

    local errorBox = displayErrorBox(title, text)
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
    clearNoCharactersWindow()

    local httpLoginBox = getEnterGameWidget('httpLoginBox')
    local httpLogin = httpLoginBox and httpLoginBox:isChecked() or false

    -- Try add server to the server list (skip when client is locked — A4)
    if not isPlayerMode() then
        ServerList.add(G.host, G.port, g_game.getClientVersion(), httpLogin)
    end

    -- Save 'Stay logged in' setting
    local stayLoggedBox = getEnterGameWidget('stayLoggedBox')
    g_settings.set('staylogged', stayLoggedBox and stayLoggedBox:isChecked() or false)
    g_settings.set('httpLogin', httpLogin)

    local rememberEmailBox = getEnterGameWidget('rememberEmailBox')
    if rememberEmailBox and rememberEmailBox:isChecked() then
        local encAccount = g_crypt.encrypt(G.account)   -- FIX64: renamed to avoid shadowing parameter
        local encPassword = g_crypt.encrypt(G.password)  -- FIX64: renamed to avoid shadowing parameter

        g_settings.set('account', encAccount)
        g_settings.set('password', encPassword)

        ServerList.setServerAccount(G.host, encAccount)
        ServerList.setServerPassword(G.host, encPassword)

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
        characterInfo.worldId = normalizeWorldId(characterInfo.worldId)
        if characterInfo.previewState and characterInfo.previewState ~= PreviewState.Default then
            characterInfo.worldName = characterInfo.worldName .. ', Preview'
        end
    end

    if isPlayerMode() then
        local filteredCharacters = {}
        for _, characterInfo in ipairs(characters) do
            if isWorldAllowedForActiveMode(characterInfo) then
                table.insert(filteredCharacters, characterInfo)
            else
                g_logger.warning(string.format("[MODE-GATE] Rejected world '%s' (id=%s) for mode '%s'", tostring(characterInfo.worldName), tostring(characterInfo.worldId), tostring(CurrentGameMode)))
            end
        end
        characters = filteredCharacters
    end

    if isPlayerMode() and CurrentGameMode and #characters == 0 then
        pendingAccountContextRefresh = false
        EnterGame.show()
        showNoCharactersGate()
        return
    end

    -- OTC-013: Jeśli konto jest zbanowane, pokaż komunikat bana zamiast listy postaci
    if account.banned then
        local banMsg = "Twoje konto jest zablokowane.\n"
        local reason = account.banReason or ""
        if #reason > 0 then
            banMsg = banMsg .. "Powod: " .. reason .. "\n"
        end
        if account.banPermanent then
            banMsg = banMsg .. "Blokada: na stale"
        else
            local banUntil = tonumber(account.banExpiresAt) or 0
            local hoursLeft = math.max(0, math.floor((banUntil - os.time()) / 3600))
            if hoursLeft > 24 then
                local daysLeft = math.floor(hoursLeft / 24)
                banMsg = banMsg .. "Wygasa za: " .. daysLeft .. " dni"
            elseif hoursLeft > 0 then
                banMsg = banMsg .. "Wygasa za: " .. hoursLeft .. "h"
            else
                banMsg = banMsg .. "Wygasa wkrotce"
            end
        end
        local banBox = displayErrorBox("Konto zablokowane", banMsg)
        connect(banBox, { onOk = EnterGame.show })
        return
    end

    CharacterList.create(characters, account, otui)
    CharacterList.show()

    -- OTC-009: Po zalogowaniu pobierz świeży kontekst konta z API
    fetchAccountContext()

    if motdEnabled then
        local lastMotdNumber = g_settings.getNumber('motd')
        if G.motdNumber and G.motdNumber ~= lastMotdNumber then
            g_settings.set('motd', G.motdNumber)
            motdWindow = displayInfoBox(tr("otclient_modules.entergame.tr_20"), G.motdMessage)
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
        local errorBox = displayErrorBox(tr("otclient_modules.entergame.tr_19"), tr("otclient_modules.entergame.tr_18"))
        connect(errorBox, {
            onOk = EnterGame.show
        })
    end
end

local function updateLabelText()
    local clientComboBox = getEnterGameWidget('clientComboBox')
    if clientComboBox and tonumber(clientComboBox:getText()) > 1080 then
        enterGame:setText(tr("otclient_modules.entergame.tr_17"))
        local emailLabel = getEnterGameWidget('emailLabel')
        if emailLabel then
            emailLabel:setText(tr("otclient_modules.entergame.tr_16"))
        end
        local rememberEmailBox = getEnterGameWidget('rememberEmailBox')
        if rememberEmailBox then
            rememberEmailBox:setText(tr("otclient_modules.entergame.tr_15"))
        end
    else
        enterGame:setText(tr("otclient_modules.entergame.tr_14"))
        local emailLabel = getEnterGameWidget('emailLabel')
        if emailLabel then
            emailLabel:setText(tr("otclient_modules.entergame.tr_13"))
        end
        local rememberEmailBox = getEnterGameWidget('rememberEmailBox')
        if rememberEmailBox then
            rememberEmailBox:setText(tr("otclient_modules.entergame.tr_12"))
        end
    end
end

-- public functions
function EnterGame.init()
    -- FIX55: Seed PRNG raz przy starcie modułu (nie per-request, bo os.time() ma sekundową granulację)
    math.randomseed(os.time() * 256 + (os.clock() * 1000) % 256)
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
        clientVersion = 1412  -- MUSI zgadzać się z data/setup.otml last-supported-version
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

    if GameModes then
        -- Jeśli tryb przyszedl jako hint z launchera, ustawiamy startowy tryb sesji.
        -- User nadal moze uzyc "Zmien tryb" w instalce/kliencie.
        if CurrentGameMode and GameModes[CurrentGameMode] then
            EnterGame.selectGameMode(CurrentGameMode)
        -- LOG-007: W dev mode zapamiętaj ostatni tryb między restartami
        elseif not isPlayerMode() then
            local saved = g_settings.get('lastGameMode')
            if saved and saved ~= "" and GameModes[saved] then
                EnterGame.selectGameMode(saved)
            else
                EnterGame.showGameModeSelection()
            end
        else
            -- === Pokaż panel wyboru trybu gry (GameModes zdefiniowane) ===
            -- Działa zarówno w trybie CLIENT_LOCKED jak i DEV (CLIENT_LOCKED=false)
            EnterGame.showGameModeSelection()
        end
    elseif Servers_init then
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
        EnterGame.show()
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
    if isPlayerMode() and not hasLaunchTokenContext() then
        showLauncherRequiredScreen("no_context")
        return
    end

    EnterGame.show()

    -- LOG-001: Jeśli tryb gry nie jest jeszcze wybrany, nie próbuj logowania.
    -- Panel wyboru trybu jest już widoczny (ustawiony w init()).
    -- Gracz najpierw musi wybrać tryb — selectGameMode() odpali triggerLauncherAutoLogin().
    if GameModes and not gameModeSelected then
        return
    end

    local account = g_crypt.decrypt(g_settings.get('account'))
    local password = g_crypt.decrypt(g_settings.get('password'))
    local host = g_settings.get('host')
    local autologin = g_settings.getBoolean('autologin')

    -- Launcher startup context: higher priority than saved settings.
    -- Launcher przekazuje opcjonalny email i session token przez env.
    local launcherAccount = G.launcherAccount or ""
    local launcherSessionToken = G.launcherSessionToken or ""
    local hasLauncherSession = #launcherSessionToken > 0

    -- LOG-002: W bloku launcherowym tylko ustawiamy pola konta.
    -- Nie wywołujemy doLogin() — triggerLauncherAutoLogin() na końcu firstShow
    -- zadba o jednokrotne wywołanie loginu (z guardem launcherAutoLoginAttempted).
    if hasLauncherSession then
        if #launcherAccount > 0 then
            EnterGame.setAccountName(launcherAccount)
        end
        EnterGame.setPassword("")
        G.launcherAccount = nil
    elseif #host > 0 and #password > 0 and #account > 0 and autologin then
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

    triggerLauncherAutoLogin()
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

    if isPlayerMode() and not hasLaunchTokenContext() then
        showLauncherRequiredScreen(launcherContextState or "no_context")
        return
    end

    enterGame:show()
    enterGame:raise()
    enterGame:focus()

    if pendingAccountContextRefresh and not g_game.isLogging() then
        pendingAccountContextRefresh = false
        addEvent(function()
            if not g_game.isOnline() and not g_game.isLogging() then
                EnterGame.doLogin()
            end
        end)
    end
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
        authenticatorTokenLabel:setVisible(enabled)
    end
    local authenticatorTokenTextEdit = getEnterGameWidget('authenticatorTokenTextEdit')
    if authenticatorTokenTextEdit then
        authenticatorTokenTextEdit:setOn(enabled)
        authenticatorTokenTextEdit:setVisible(enabled)
    end

    enterGame.authenticatorEnabled = enabled
    -- LOG-005: Automatyczne dopasowanie zamiast ręcznego przeliczania
    recalculateWindowSize()
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
        stayLoggedBox:setVisible(enabled)
    end

    enterGame.stayLoggedBoxEnabled = enabled
    -- LOG-005: Automatyczne dopasowanie zamiast ręcznego przeliczania
    recalculateWindowSize()
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

        local errorBox = displayErrorBox(tr("otclient_modules.entergame.tr_11"), string.format("Things are not loaded, please put assets in things/%d/<assets>.", clientVersion))
        connect(errorBox, {
            onOk = EnterGame.show
        })
        return
    end

    -- CR-1: Użyj httpLoginUrl z konfiguracji trybu gry gdy dostępne (działa zarówno w CLIENT_LOCKED jak i DEV)
    -- (G.host to sam hostname, nie zawiera ścieżki /login.php)
    local host, path
    local srv = getCurrentServerConfig()
    if srv and srv.httpLoginUrl then
        host = srv.httpLoginUrl:match("https?://([^/:]+)")
        path = srv.httpLoginUrl:match("https?://[^/]+(/.+)") or "/"
        -- Port z httpLoginUrl lub z config serwera
        local urlPort = srv.httpLoginUrl:match(":(%d+)")
        if urlPort then
            G.port = tonumber(urlPort)
        elseif not G.port or G.port == 0 then
            G.port = 443
        end
    else
        -- Fallback: parsuj G.host jak dotychczas (brak GameModes / brak httpLoginUrl)
        host, path = G.host:match("([^/]+)/([^/].*)")
    end

    if not G.port then
        -- FIX-W1: Poprawiona logika — CLIENT_LOCKED zawsze używa HTTPS (443).
        -- W trybie non-locked host nigdy nie zawiera schematu (jest parsowany z pola),
        -- więc domyślnie ustawiamy 443 (HTTPS) jako bezpieczne domyślne.
        G.port = 443
    end

    if not path then
        path = ""
    elseif path:sub(1, 1) ~= '/' then
        -- FIX22: Tylko dodaj '/' jeśli path jeszcze nie zaczyna się od '/'
        -- Zapobiega podwójnemu slash (np. //login.php)
        path = '/' .. path
    end

    if not host then
        loadBox = displayCancelBox(tr("otclient_modules.entergame.tr_10"), tr("otclient_modules.entergame.tr_9"))
    else
        loadBox = displayCancelBox(tr("otclient_modules.entergame.tr_8"), tr("otclient_modules.entergame.tr_7", host .. ":" .. tostring(G.port) .. path))
    end

    connect(loadBox, {
        onCancel = function(msgbox)
            loadBox = nil
            G.requestId = 0
            EnterGame.show()
        end
    })

    -- FIX55: randomseed przeniesiony do EnterGame.init(), tu tylko generujemy
    G.requestId = math.random(1000000)  -- FIX27: math.random(1) zawsze zwraca 1

    local http = LoginHttp.create()
    -- E10: Przekaż launchToken z launchera (env OTC_LAUNCH_TOKEN) do C++ → JSON body
    http:setLaunchToken(G.launchToken or "")
    http:setSessionToken(G.launcherSessionToken or "")
    G.launcherSessionToken = nil
    -- FIX18: Przekaż gameMode (classic74/modern) do C++ → JSON body login
    http:setGameMode(CurrentGameMode or "")
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
    launcherContextState = nil

    local worlds = {}
    for _, world in ipairs(json.decode(jsonWorlds)) do
        worlds[world.id] = {
            name = world.name,
            ip = world.externaladdressprotected or world.externaladdress,
            port = world.externalportprotected or world.externalport,
            previewState = world.previewstate == 1,
            onlinePlayers = world.online_players or 0  -- OTC-014: status serwera
        }
    end

    local characters = {}
    for index, character in ipairs(json.decode(jsonCharacters)) do
        local world = worlds[character.worldid]
        characters[index] = {
            name = character.name,
            worldId = character.worldid,
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
            previewState = world.previewState,  -- FIX63: camelCase (world table uses previewState)
            onlinePlayers = world.onlinePlayers  -- OTC-014
        }
    end

    local ok, session = pcall(json.decode, jsonSession)
    if not ok or type(session) ~= "table" then
        g_logger.error("[loginSuccess] Invalid session JSON from server")
        onError(nil, "Serwer zwrocil nieprawidlowa odpowiedz. Sprobuj ponownie.", nil)
        return
    end

    local premiumUntil = tonumber(session.premiumuntil)

    local account = {
        status = '',
        premDays = math.floor((premiumUntil - os.time()) / 86400),
        subStatus = premiumUntil > os.time() and SubscriptionStatus.Premium or SubscriptionStatus.Free
    }

    -- OTC-013: Sprawdź ban konta z session response
    if session.accountBan then
        local banExpires = tonumber(session.accountBan.expiresAt) or 0
        if banExpires == 0 or banExpires > os.time() then
            account.banned = true
            account.banReason = session.accountBan.reason or ""
            account.banExpiresAt = banExpires
            account.banPermanent = (banExpires == 0)
        end
    end

    -- set session key
    G.sessionKey = session.sessionkey
    -- FIX28: Legacy key (account\npassword) do połączenia bez ticket-gate
    G.legacySessionKey = session.key or G.sessionKey

    -- LUA-006: Populate C++ allowed worlds list (loginWorld() validates against it)
    if isPlayerMode() and g_game.clearAllowedWorlds then
        g_game.clearAllowedWorlds()
        for _, world in pairs(worlds) do
            if world.ip and world.port then
                g_game.addAllowedWorld(world.ip, world.port)
            end
        end
    end

    onCharacterList(nil, characters, account)
end

function EnterGame.loginFailed(requestId, msg, result)
    if G.requestId ~= requestId then
        return
    end
    onError(nil, msg, result)
end

-- ============================================================
-- B5: TICKET FLOW — żądanie ticketu HMAC przed połączeniem z game serverem
-- ============================================================

-- Dane ticketu (globalne — używane przez characterlist.lua)
G.ticketToken = nil        -- otrzymany ticket HMAC
G.ticketRequestId = 0      -- ID bieżącego żądania ticketu
G.pendingCharInfo = nil    -- charInfo czekający na ticket

-- Żądaj ticket od ticket.php (wywoływane z characterlist.lua przed g_game.loginWorld)
function EnterGame.requestTicket(charInfo)
    if not isPlayerMode() or not CurrentGameMode then
        -- Brak ticket flow — połącz bezpośrednio
        EnterGame.onTicketBypassed(charInfo)
        return
    end

    local srv = getCurrentServerConfig()
    if not srv or not srv.httpLoginUrl then
        -- FIX6: fail-closed — brak konfiguracji = błąd, nie bypass
        g_logger.warning("[TICKET] Brak httpLoginUrl w konfiguracji serwera")
        EnterGame.onTicketConfigError("Brak httpLoginUrl w konfiguracji serwera. Skontaktuj się z administratorem.")
        return
    end

    -- Parsuj host/path z httpLoginUrl (np. "https://example.com/login.php" → host="example.com", ticketPath="/ticket.php")
    -- FIX-AUD9: Rozdziel host i port — regex [^/:] zamiast [^/] aby nie przechwycić "host:port" jako jednego stringa
    local urlHost = srv.httpLoginUrl:match("https?://([^/:]+)")
    local urlPortStr = srv.httpLoginUrl:match("https?://[^/:]+:(%d+)")
    local urlPort = urlPortStr and tonumber(urlPortStr) or nil
    if not urlHost then
        -- FIX6: fail-closed — nie można sparsować URL = błąd
        g_logger.warning("[TICKET] Nie można sparsować hosta z httpLoginUrl: " .. tostring(srv.httpLoginUrl))
        EnterGame.onTicketConfigError("Nieprawidłowy format httpLoginUrl: " .. tostring(srv.httpLoginUrl))
        return
    end

    -- ticket.php jest obok login.php
    local basePath = srv.httpLoginUrl:match("https?://[^/]+(/.+)") or "/"
    local ticketPath = basePath:gsub("[^/]+$", "ticket.php")

    G.pendingCharInfo = charInfo
    G.ticketToken = nil
    -- FIX55: randomseed przeniesiony do EnterGame.init(), tu tylko generujemy
    G.ticketRequestId = math.random(1000000)

    local http = LoginHttp.create()
    -- FIX30+FIX-AUD9: Priorytet portów: urlPort (z httpLoginUrl) > G.port > srv.port > 443
    local ticketPort = urlPort or G.port or srv.port or 443
    http:requestTicket(urlHost, ticketPath, ticketPort, G.sessionKey or "",
                       charInfo.characterName, CurrentGameMode,
                       charInfo.worldName or "", G.ticketRequestId)

    g_logger.info("[TICKET] Requesting ticket for " .. charInfo.characterName ..
                  " mode=" .. CurrentGameMode .. " world=" .. (charInfo.worldName or "?") ..
                  " from " .. urlHost .. ticketPath)
end

-- Callback C++: ticket otrzymany pomyślnie
function EnterGame.onTicketSuccess(requestId, ticket)
    if G.ticketRequestId ~= requestId then
        return
    end

    G.ticketToken = ticket
    g_logger.info("[TICKET] Ticket received, connecting to game server...")

    if G.pendingCharInfo then
        local charInfo = G.pendingCharInfo
        G.pendingCharInfo = nil
        -- Połącz z game serverem — ticket jest w G.ticketToken
        -- CharacterList wie że ma użyć ticketu
        EnterGame.connectWithTicket(charInfo)
    end
end

-- Callback C++: ticket nie powiódł się
function EnterGame.onTicketFailed(requestId, msg, status)
    if G.ticketRequestId ~= requestId then
        return
    end

    G.pendingCharInfo = nil
    G.ticketToken = nil

    g_logger.warning("[TICKET] Failed: " .. tostring(msg) .. " (status: " .. tostring(status) .. ")")

    -- Pokaz błąd i wróć do listy postaci
    if CharacterList then
        CharacterList.destroyLoadBox()
    end
    local errorBox = displayErrorBox("Ticket Error", "Nie udało się uzyskać ticketu: " .. tostring(msg))
    connect(errorBox, {
        onOk = function()
            if CharacterList then
                CharacterList.show()
            end
        end
    })
end

-- Brak ticket flow (stary tryb / brak CLIENT_LOCKED) — połącz bezpośrednio
function EnterGame.onTicketBypassed(charInfo)
    -- FIX28: Bez ticket-gate serwer oczekuje authType=password → legacy key (account\npassword)
    -- G.sessionKey to UUID (dla ticket.php), G.legacySessionKey to "account\npassword" (dla protocolgame)
    local sessionKey = G.legacySessionKey or G.sessionKey
    g_game.loginWorld(G.account, G.password, charInfo.worldName, charInfo.worldHost,
                      charInfo.worldPort, charInfo.characterName, G.authenticatorToken,
                      sessionKey)
end

-- Połącz z game serverem z ticketem HMAC
function EnterGame.connectWithTicket(charInfo)
    -- FIX6: fail-closed — jeśli ticket jest nil, nie łącz się
    if not G.ticketToken or G.ticketToken == "" then
        g_logger.warning("[TICKET] connectWithTicket called but ticketToken is nil/empty")
        EnterGame.onTicketConfigError("Brak ticketu — nie można połączyć z serwerem.")
        return
    end
    g_game.loginWorld(G.account, G.password, charInfo.worldName, charInfo.worldHost,
                      charInfo.worldPort, charInfo.characterName, G.authenticatorToken,
                      G.ticketToken)
end

-- FIX6: Błąd konfiguracji ticket flow (CLIENT_LOCKED ale brak URL/config)
function EnterGame.onTicketConfigError(msg)
    G.pendingCharInfo = nil
    G.ticketToken = nil
    if CharacterList then
        CharacterList.destroyLoadBox()
    end
    local errorBox = displayErrorBox("Ticket Configuration Error",
                                     msg or "Błąd konfiguracji ticket flow.")
    connect(errorBox, {
        onOk = function()
            if CharacterList then
                CharacterList.show()
            end
        end
    })
end

function EnterGame.doLogin()
    -- A3: Sprawdź czy wybrany tryb gry (gdy GameModes zdefiniowane)
    if GameModes and not gameModeSelected then
        EnterGame.showGameModeSelection()
        return
    end

    if CurrentGameMode == "all" then
        displayErrorBox("Wybierz konkretny tryb", "Dla opcji all musisz wybrac konkretny serwer (classic74 lub modern) przed startem.")
        EnterGame.showGameModeSelection()
        return
    end

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

    local clientVersion = tonumber((clientBox and clientBox:getText()) or '') or 1412

    local httpLoginBox = getEnterGameWidget('httpLoginBox')
    local httpLogin = httpLoginBox and httpLoginBox:isChecked() or false
    EnterGame.hide()

    if g_game.isOnline() then
        local errorBox = displayErrorBox(tr("otclient_modules.entergame.tr_6"), tr("otclient_modules.entergame.tr_5"))
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

        loadBox = displayCancelBox(tr("otclient_modules.entergame.tr_4"), tr("otclient_modules.entergame.tr_3"))
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

            local errorBox = displayErrorBox(tr("otclient_modules.entergame.tr_2"), string.format("Things are not loaded, please put spr and dat in things/%d/<here>.", clientVersion))
            connect(errorBox, {
               onOk = EnterGame.show
            })
            return
        end
    end
end

function EnterGame.displayMotd()
    if not motdWindow then
        motdWindow = displayInfoBox(tr("otclient_modules.entergame.tr_1"), G.motdMessage)
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

    -- FIX8: serverListButton pozostaje widoczny — lista jest read-only gdy CLIENT_LOCKED
    -- Przycisk otwiera listę serwerów w trybie podglądu (bez add/remove/select).
    -- Nowe serwery dodawane są przez launcher.
    -- local serverListButton = getEnterGameWidget('serverListButton')
    -- if serverListButton then
    --     serverListButton:setVisible(false)
    --     serverListButton:setHeight(0)
    --     serverListButton:setWidth(0)
    -- end

    local rememberEmailBox = getEnterGameWidget('rememberEmailBox')
    if rememberEmailBox then
        rememberEmailBox:setMarginTop(5)
    end

    if not windowWidth then
        windowWidth = 380
    end
    enterGame:setWidth(windowWidth)

    -- LOG-005: Wysokość przeliczana automatycznie zamiast hardcoded
    enterGame.disableToken = true
    recalculateWindowSize()

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

-- ============================================================
-- A2/A3: WYBÓR TRYBU GRY (GameMode)
-- ============================================================

-- LOG-003: Sortowanie kluczy GameModes (pairs() jest niedeterministyczny w Lua)
local function getSortedGameModeKeys()
    local keys = {}
    if not GameModes then return keys end
    for k, _ in pairs(GameModes) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

-- LOG-003: Wyczyść dynamicznie utworzone przyciski trybów z kontenera
local function clearGameModeButtons()
    local container = getEnterGameWidget('gameModeButtonsContainer')
    if not container then return end
    local children = {}
    for i = 1, container:getChildCount() do
        table.insert(children, container:getChildByIndex(i))
    end
    for _, child in ipairs(children) do
        child:destroy()
    end
end

-- LOG-005: Automatyczne dopasowywanie rozmiaru okna logowania.
-- Zamiast hardcoded setHeight() — przelicz z sumy widocznych dzieci.
-- Używa addEvent() żeby layouty (fit-children itp.) zdążyły się przeliczyć.
local recalcPending = false
local function recalculateWindowSize()
    if not enterGame then return end
    if recalcPending then return end
    recalcPending = true
    addEvent(function()
        recalcPending = false
        if not enterGame then return end

        -- Najpierw przelicz panel trybów gry (jeśli widoczny)
        local panel = getEnterGameWidget('gameModePanel')
        if panel and panel:isVisible() then
            local panelH = 0
            for i = 1, panel:getChildCount() do
                local child = panel:getChildByIndex(i)
                if child and child:isVisible() then
                    panelH = panelH + child:getHeight() + child:getMarginTop() + child:getMarginBottom()
                end
            end
            panel:setHeight(math.max(panelH + 10, 30))
        end

        -- Przelicz wysokość okna
        local totalH = 0
        local padding = 20
        for i = 1, enterGame:getChildCount() do
            local child = enterGame:getChildByIndex(i)
            if child and child:isVisible() and child:getHeight() > 0 then
                totalH = totalH + child:getHeight() + child:getMarginTop() + child:getMarginBottom()
            end
        end
        enterGame:setHeight(math.max(totalH + padding, 180))
    end)
end

-- Pokaż panel wyboru trybu gry (ukryj formularz logowania)
function EnterGame.showGameModeSelection()
    gameModeSelected = false
    CurrentGameMode = nil

    local panel = getEnterGameWidget('gameModePanel')
    if not panel then return end

    -- Wyczyść stare dynamiczne przyciski
    clearGameModeButtons()

    -- LOG-003: Dynamicznie generuj przyciski z tabeli GameModes
    local container = getEnterGameWidget('gameModeButtonsContainer')
    if container and GameModes then
        local sortedKeys = getSortedGameModeKeys()
        for _, modeKey in ipairs(sortedKeys) do
            local mode = GameModes[modeKey]

            -- Przycisk trybu
            local btn = g_ui.createWidget('Button', container)
            btn:setId('dynBtn_' .. modeKey)
            btn:setText(mode.name or modeKey)
            btn:setHeight(28)
            btn:setMarginTop(8)
            btn.onClick = function()
                EnterGame.selectGameMode(modeKey)
            end

            -- Opis trybu
            if mode.description and #mode.description > 0 then
                local desc = g_ui.createWidget('Label', container)
                desc:setId('dynDesc_' .. modeKey)
                desc:setText(mode.description)
                desc:setMarginTop(2)
                desc:setTextAlign(AlignCenter)
                desc:setColor('#aaaaaa')
                desc:setFont('noto-12')
                desc:setTextAutoResize(true)
            end
        end
    end

    -- Pokaż panel, ukryj "Zmień tryb"
    panel:setVisible(true)

    local btnChange = getEnterGameWidget('btnChangeMode')
    if btnChange then btnChange:setVisible(false) end

    local modeLabel = getEnterGameWidget('selectedModeLabel')
    if modeLabel then modeLabel:setVisible(false) end

    local sep = getEnterGameWidget('gameModeSep')
    if sep then sep:setVisible(true) end

    -- Ukryj formularz logowania gdy tryb nie jest wybrany
    EnterGame.setLoginFormVisible(false)

    -- LOG-005: Automatyczne dopasowanie rozmiaru
    recalculateWindowSize()
end

local function showLauncherAutoLoginUi()
    if not enterGame then return end

    for i = 1, enterGame:getChildCount() do
        local child = enterGame:getChildByIndex(i)
        if child then
            local childId = child:getId()
            if childId == 'selectedModeLabel' or childId == 'serverInfoLabel' then
                child:setVisible(true)
            elseif childId ~= 'enterGame' then
                child:setVisible(false)
            end
        end
    end
end

-- Gracz wybrał tryb gry
function EnterGame.selectGameMode(modeKey)
    if not GameModes or not GameModes[modeKey] then
        g_logger.warning("EnterGame.selectGameMode: unknown mode: " .. tostring(modeKey))
        return
    end

    CurrentGameMode = modeKey
    gameModeSelected = true
    local mode = GameModes[modeKey]

    -- Skonfiguruj serwer z trybu
    local srv = mode.server
    if srv then
        EnterGame.setUniqueServer(srv.host, srv.port, srv.protocol)
        EnterGame.setHttpLogin(srv.httpLogin or false)
    end

    -- LOG-003: Ukryj dynamiczne przyciski trybów
    clearGameModeButtons()

    -- Zaktualizuj panel — pokaż "Zmień tryb" + label
    local panel = getEnterGameWidget('gameModePanel')

    local sep = getEnterGameWidget('gameModeSep')
    if sep then sep:setVisible(false) end

    local btnChange = getEnterGameWidget('btnChangeMode')
    -- LOG-006: W player mode tryb jest jednorazowy na sesję — "Zmień tryb" ukryty.
    if btnChange then btnChange:setVisible(not isPlayerMode()) end

    -- LOG-009: W player mode Create Account jest ukryty (rejestracja przez launcher/WWW)
    local btnCreate = getEnterGameWidget('btnCreateNewAccount')
    if btnCreate then btnCreate:setVisible(not isPlayerMode()) end

    local modeLabel = getEnterGameWidget('selectedModeLabel')
    if modeLabel then
        modeLabel:setText(tr("otclient_modules.entergame.mode_prefix") .. mode.name)
        modeLabel:setVisible(true)
    end

    -- Pokaż formularz logowania
    EnterGame.setLoginFormVisible(true)

    -- OTC-005: W player mode z launch tokenem, ukryj pola email/hasło
    -- (auto-login nastapi natychmiast, gracz nie musi ich widzieć)
    if isPlayerMode() and hasLaunchTokenContext() then
        showLauncherAutoLoginUi()
        local infoLabel = getEnterGameWidget('serverInfoLabel')
        if infoLabel then
            infoLabel:setText(tr("otclient_modules.entergame.auto_login_msg"))
            infoLabel:setVisible(true)
        end
    end

    -- LOG-005: Automatyczne dopasowanie rozmiaru
    recalculateWindowSize()

    -- LOG-007: Zapamiętaj tryb w dev mode (żeby nie wybierać po restarcie)
    if not isPlayerMode() then
        g_settings.set('lastGameMode', modeKey)
    end

    g_logger.info("GameMode selected: " .. modeKey .. " (" .. mode.name .. ")")
    triggerLauncherAutoLogin()
end

-- Pokaż/ukryj formularz logowania (email, hasło, przyciski)
function EnterGame.setLoginFormVisible(visible)
    local ids = {
        'emailLabel', 'accountNameTextEdit',
        'passwordLabel', 'accountPasswordTextEdit',
        'authenticatorTokenLabel', 'authenticatorTokenTextEdit',
        'rememberEmailBox', 'autoLoginBox', 'stayLoggedBox',
        'httpLoginBox', 'serverInfoLabel',
        -- pola serwera (ukrywane też przez setUniqueServer, ale tu dla spójności)
        'serverHostTextEdit', 'serverPortTextEdit',
        'serverLabel', 'portLabel', 'clientLabel',
        'serverListButton'
    }

    for _, id in ipairs(ids) do
        local w = getEnterGameWidget(id)
        if w then
            w:setVisible(visible)
        end
    end

    -- Hasło label (szukamy po tekście "Password" — jest bezpośrednio w OTUI)
    -- Separatory i przyciski Login/Create
    -- Przejdźmy po dzieciach i ukryjmy/pokażmy separatory i panel z przyciskami
    if enterGame then
        for i = 1, enterGame:getChildCount() do
            local child = enterGame:getChildByIndex(i)
            if child then
                local childId = child:getId()
                -- Nie ukrywaj panelu gameModePanel ani selectedModeLabel
                if childId ~= 'gameModePanel' and childId ~= 'selectedModeLabel'
                   and childId ~= 'enterGame' then
                    -- Ukryj separatory i niezidentyfikowane elementy (panel z przyciskami)
                    -- FIX50: child.getStyleName (dot=field access) nie child:getStyleName (colon=call, parse error bez args)
                    local style = child.getStyleName and child:getStyleName() or ''
                    if style == 'HorizontalSeparator' or (childId == '' and child:getHeight() == 26) then
                        child:setVisible(visible)
                    end
                end
            end
        end
    end

    -- Hasło MenuLabel (jest tuż przed passwordEdit — nie ma id, szukamy po pozycji)
    -- Tak naprawdę pola bez id (label "Password") będą ukryte razem z formularzem
    -- bo są zakotwiczone do emailLabel/prev
end

function EnterGame.disableMotd()
    motdEnabled = false
end

function ensableBtnCreateNewAccount()
    enterGame.btnCreateNewAccount:enable()
end
