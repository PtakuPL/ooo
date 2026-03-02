ServerList = {}

-- private variables
local serverListWindow = nil
local serverTextList = nil
local removeWindow = nil
local servers = {}

-- public functions
function ServerList.init()
    serverListWindow = g_ui.displayUI('serverlist')
    serverTextList = serverListWindow:getChildById('serverList')
    local processedServers = {}

    -- Przy CLIENT_LOCKED serwery pochodzą wyłącznie z GameModes
    if CLIENT_LOCKED then
        servers = {}
        -- FIX14: Wypełnij ServerList z GameModes, żeby lista nie była pusta
        -- FIX-AUD7: Klucz = host:port (unikamy nadpisania gdy 2 GameModes współdzielą host)
        if GameModes then
            for modeKey, mode in pairs(GameModes) do
                if mode.server and mode.server.host then
                    local host = mode.server.host
                    local port = mode.server.port or 7171
                    local protocol = mode.server.protocol or 1420
                    local httpLogin = mode.server.httpLoginUrl ~= nil
                    local serverKey = host .. ':' .. tostring(port)
                    servers[serverKey] = {
                        host = host,
                        port = port,
                        protocol = protocol,
                        account = '',
                        password = '',
                        httpLogin = httpLogin,
                        gameMode = modeKey,
                    }
                end
            end
        end
    else
        servers = g_settings.getNode('ServerList') or {}
        if Servers_init then
            for key, value in pairs(Servers_init) do
                if not servers[key] then
                    servers[key] = value
                    if not processedServers[key] then
                        processedServers[key] = true
                    end
                end
            end
        end
    end

    if servers then
        ServerList.load()
    end
end

function ServerList.terminate()
    ServerList.destroy()

    -- Przy CLIENT_LOCKED nie zapisujemy do g_settings — brak persystencji listy
    if not CLIENT_LOCKED then
        g_settings.setNode('ServerList', servers)
    end

    ServerList = nil
    serverListWindow = nil
    serverTextList = nil
end

function ServerList.load()
    for key, server in pairs(servers) do
        -- FIX-AUD7: W lock mode klucz to host:port, serwer ma pole .host
        local host = server.host or key
        ServerList.add(host, server.port, server.protocol, server.httpLogin, true)
    end
end

function ServerList.select()
    local selected = serverTextList:getFocusedChild()
    if selected then
        local serverKey = selected:getId()
        local server = servers[serverKey]
        if server then
            -- FIX-AUD7: Użyj .host jeśli dostępne (lock mode), inaczej klucz = host
            local host = server.host or serverKey
            EnterGame.setDefaultServer(host, server.port, server.protocol)
            EnterGame.setAccountName(server.account)
            EnterGame.setPassword(server.password)
            EnterGame.setHttpLogin(server.httpLogin)
            ServerList.hide()
        end
    end
end

function ServerList.add(host, port, protocol, httpLogin, load)
    -- A4: blokada dodawania serwerów przez użytkownika gdy klient jest zablokowany
    -- load=true oznacza wewnętrzne ładowanie (ServerList.load) — to przepuszczamy
    if CLIENT_LOCKED and not load then
        return false, 'Client is locked — server list is read-only'
    end

    if not host or not port or not protocol then
        return false, 'Failed to load settings'
    elseif not load and servers[host .. ':' .. tostring(port)] then
        return false, 'Server already exists'
    elseif host == '' or port == '' then
        return false, 'Required fields are missing'
    elseif httpLogin == nil then
        httpLogin = false
    end
    -- FIX-AUD7: Widget ID = host:port (unikalne), display = host:port
    local serverKey = host .. ':' .. tostring(port)
    local widget = g_ui.createWidget('ServerWidget', serverTextList)
    widget:setId(serverKey)

    if not load then
        servers[serverKey] = {
            host = host,
            port = port,
            protocol = protocol,
            account = '',
            password = '',
            httpLogin = httpLogin
        }
    end

    local details = widget:getChildById('details')
    details:setText(host .. ':' .. port)

    local proto = widget:getChildById('protocol')
    proto:setText(protocol)

    connect(widget, {
        onDoubleClick = function()
            ServerList.select()
            return true
        end
    })
    return true
end

function ServerList.remove(widget)
    -- A4: blokada usuwania serwerów gdy klient jest zablokowany
    if CLIENT_LOCKED then
        return
    end

    -- FIX-AUD7: getId() zwraca teraz host:port
    local host = widget:getId()

    if removeWindow then
        return
    end

    local yesCallback = function()
        widget:destroy()
        servers[host] = nil
        removeWindow:destroy()
        removeWindow = nil
    end
    local noCallback = function()
        removeWindow:destroy()
        removeWindow = nil
    end

    removeWindow = displayGeneralBox(tr("otclient_modules.serverlist.tr_3"), tr('Remove ' .. host .. '?'), {
        {
            text = tr("otclient_modules.serverlist.tr_2"),
            callback = yesCallback
        },
        {
            text = tr("otclient_modules.serverlist.tr_1"),
            callback = noCallback
        },
        anchor = AnchorHorizontalCenter
    }, yesCallback, noCallback)
end

function ServerList.destroy()
    if serverListWindow then
        serverTextList = nil
        serverListWindow:destroy()
        serverListWindow = nil
    end
end

function ServerList.show()
    -- FIX8: Lista serwerów jest widoczna w trybie read-only gdy CLIENT_LOCKED.
    -- Dodawanie/usuwanie/wybór serwera jest zablokowane (A4).
    -- Nowe serwery dodawane są przez launcher.
    if g_game.isOnline() then
        return
    end

    -- Ukryj/pokaż elementy zależnie od CLIENT_LOCKED
    local buttonAdd = serverListWindow:getChildById('buttonAdd')
    local buttonOk = serverListWindow:getChildById('buttonOk')
    if buttonAdd then
        buttonAdd:setVisible(not CLIENT_LOCKED)
    end
    if buttonOk then
        buttonOk:setVisible(not CLIENT_LOCKED)
    end

    -- Ukryj przyciski "x" (remove) na każdym wpisie serwera
    if CLIENT_LOCKED and serverTextList then
        for _, child in ipairs(serverTextList:getChildren()) do
            local removeBtn = child:getChildById('remove')
            if removeBtn then
                removeBtn:setVisible(false)
            end
        end
    end

    serverListWindow:show()
    serverListWindow:raise()
    serverListWindow:focus()
end

function ServerList.hide()
    serverListWindow:hide()
end

function ServerList.setServerAccount(host, account)
    -- FIX-AUD7: Szukaj po host lub host:port
    for key, server in pairs(servers) do
        local srvHost = server.host or key
        if srvHost == host or key == host then
            servers[key].account = account
            return
        end
    end
end

function ServerList.setServerPassword(host, password)
    -- FIX-AUD7: Szukaj po host lub host:port
    for key, server in pairs(servers) do
        local srvHost = server.host or key
        if srvHost == host or key == host then
            servers[key].password = password
            return
        end
    end
end
