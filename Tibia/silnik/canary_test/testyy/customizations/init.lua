-- this is the first file executed when the application starts
-- we have to load the first modules form here

-- updater
Services = {
    --updater = "http://localhost/api/updater.php", --./updater
    --status = "http://localhost/login.php", --./client_entergame | ./client_topmenu
    --websites = "http://localhost/?subtopic=accountmanagement", --./client_entergame "Forgot password and/or email"
    --createAccount = "http://localhost/clientcreateaccount.php", --./client_entergame -- createAccount.lua
}

-- ============================================================
-- KONFIGURACJA KLIENTA — BLOKADA + TRYBY GRY
-- ============================================================

local function getNativeClientLocked()
    if g_configs and g_configs.isClientLocked then
        return g_configs.isClientLocked()
    end
    return true
end

local function getNativeDevMode()
    if g_configs and g_configs.isDevMode then
        return g_configs.isDevMode()
    end
    return (os.getenv("OTC_DEV_MODE") or "") == "1"
end

local function getStartupGameModeHint()
    if g_configs and g_configs.getStartupGameMode then
        return g_configs.getStartupGameMode() or ""
    end
    return os.getenv("OTC_GAME_MODE") or ""
end

-- Native runtime policy jest source-of-truth. Lua ma byc tylko read-only consumerem.
CLIENT_LOCKED = getNativeClientLocked()
local DEV_MODE = getNativeDevMode()

-- LUA-003: Funkcja budująca GameModes z C++ ConfigManager.
-- W player mode dane serwerów i feature flags pochodzą z binarki C++,
-- NIE z edytowalnego pliku Lua. Gracz nie może zmodyfikować adresów.
local function buildGameModesFromNative()
    if not g_configs or not g_configs.hasGameMode then
        return nil
    end

    -- Sprawdź znane klucze trybu gry
    local knownKeys = { "classic74", "modern" }
    local modes = {}
    local count = 0

    for _, key in ipairs(knownKeys) do
        if g_configs.hasGameMode(key) then
            -- Parsowanie allowedWorldIds z CSV stringa
            local worldIdsStr = g_configs.getGameModeAllowedWorldIds(key)
            local worldIds = {}
            if worldIdsStr and #worldIdsStr > 0 then
                for id in worldIdsStr:gmatch("[^,]+") do
                    local numId = tonumber(id)
                    if numId then table.insert(worldIds, numId) end
                end
            end

            -- Budowanie feature flags z C++
            local featureNames = {
                "hotkeys_items", "hotkeys_spells", "quick_loot", "auto_loot",
                "market", "action_bar", "smart_equip", "prey", "bestiary",
                "wheel", "analytics"
            }
            local features = {}
            for _, feat in ipairs(featureNames) do
                features[feat] = g_configs.getGameModeFeature(key, feat)
            end

            modes[key] = {
                name = g_configs.getGameModeName(key),
                description = g_configs.getGameModeDescription(key),
                allowedWorldIds = worldIds,
                server = {
                    host = g_configs.getGameModeHost(key),
                    port = g_configs.getGameModePort(key),
                    protocol = g_configs.getGameModeProtocol(key),
                    httpLogin = g_configs.getGameModeHttpLogin(key),
                    httpLoginUrl = g_configs.getGameModeHttpLoginUrl(key),
                },
                features = features,
            }
            count = count + 1
        end
    end

    if count > 0 then
        return modes
    end
    return nil
end

-- Tryby gry — źródło danych zależy od trybu:
-- Player mode (CLIENT_LOCKED=true): C++ ConfigManager (sealed, nieedytowalny)
-- Dev mode: Lua fallback table (edytowalny do testów)
GameModes = nil

if CLIENT_LOCKED then
    GameModes = buildGameModesFromNative()
    if GameModes then
        g_logger.info("[CONFIG] GameModes loaded from C++ ConfigManager (sealed)")
    else
        g_logger.warning("[CONFIG] C++ GameModes unavailable — falling back to Lua defaults")
    end
end

-- Fallback: hardcoded Lua table (używane w dev mode lub gdy C++ binding niedostępny)
if not GameModes then
    GameModes = {
        classic74 = {
            name = "Classic 7.4",
            description = "Serwer w stylu Tibia 7.4 — ograniczenia hotkeyów na runy/itemy (styl walki 7.4).",
            allowedWorldIds = { 0 },
            server = {
                host = "tibia.reddaxe.pl",
                port = 443,
                protocol = 1412,
                httpLogin = true,
                httpLoginUrl = "https://tibia.reddaxe.pl/apik/v1/login.php",
            },
            features = {
                hotkeys_items    = false,
                hotkeys_spells   = true,
                quick_loot       = true,
                auto_loot        = true,
                market           = true,
                action_bar       = true,
                smart_equip      = true,
                prey             = true,
                bestiary         = true,
                wheel            = true,
                analytics        = true,
            },
        },
        modern = {
            name = "Modern 14.20+",
            description = "Pełna wersja Tibia — wszystkie nowoczesne funkcje.",
            allowedWorldIds = { 1 },
            server = {
                host = "tibia.reddaxe.pl",
                port = 443,
                protocol = 1412,
                httpLogin = true,
                httpLoginUrl = "https://tibia.reddaxe.pl/apik/v1/login.php",
            },
            features = {
                hotkeys_items    = true,
                hotkeys_spells   = true,
                quick_loot       = true,
                auto_loot        = true,
                market           = true,
                action_bar       = true,
                smart_equip      = true,
                prey             = true,
                bestiary         = true,
                wheel            = true,
                analytics        = true,
            },
        },
    }
    g_logger.info("[CONFIG] GameModes loaded from Lua fallback table")
end

-- Aktualnie wybrany tryb gry (nil = gracz jeszcze nie wybrał).
-- Ustawiany przez ekran wyboru trybu (Faza A2/A3) LUB przez env var OTC_GAME_MODE z launchera.
CurrentGameMode = nil

-- OTC_GAME_MODE: launcher moze przekazac jednorazowy hint startowy dla sesji.
-- Nie jest to trwale ustawienie instalki; user dalej moze zmienic tryb w kliencie.
do
    local envGameMode = getStartupGameModeHint()
    if envGameMode ~= "" and GameModes[envGameMode] then
        CurrentGameMode = envGameMode
        g_logger.info("[CONFIG] OTC_GAME_MODE=" .. envGameMode .. " — startowy hint trybu z launchera")
    end
end

-- E10: Token z launchera — przekazywany przez zmienną środowiskową OTC_LAUNCH_TOKEN.
-- Launcher ustawia ją tuż przed uruchomieniem klienta (subprocess env).
-- Login.php waliduje ten token (E11) aby upewnić się, że klient przeszedł przez launcher.
G.launchToken = os.getenv("OTC_LAUNCH_TOKEN") or ""

-- Kontekst startowy z launchera.
-- Email jest opcjonalny (UI/autofill), a sesja launchera przechodzi jako token zamiast hasla.
G.launcherAccount      = os.getenv("OTC_ACCOUNT") or ""
G.launcherSessionToken = os.getenv("OTC_SESSION_TOKEN") or ""

-- Helper: szybki dostęp do feature flags aktualnego trybu.
-- Użycie: if isFeatureEnabled("quick_loot") then ...
function isFeatureEnabled(featureName)
    if not CurrentGameMode then return false end  -- fail-closed: brak trybu = blokuj
    local mode = GameModes[CurrentGameMode]
    if not mode or not mode.features then return false end  -- fail-closed: brak config = blokuj
    local val = mode.features[featureName]
    if val == nil then return false end  -- fail-closed: nieznana flaga = wyłączona
    return val
end

-- Helper: pobierz konfigurację serwera dla aktualnego trybu.
function getCurrentServerConfig()
    if not CurrentGameMode then return nil end
    local mode = GameModes[CurrentGameMode]
    if not mode then return nil end
    return mode.server
end

-- Helper: twarda walidacja mapowania mode -> world.
-- W CLIENT_LOCKED fail-closed: brak mapowania = brak dostepu.
function isWorldAllowedForMode(modeKey, worldId, worldName)
    if not CLIENT_LOCKED then
        return true
    end

    local mode = GameModes and GameModes[modeKey]
    if not mode then
        return false
    end

    local allowedWorldIds = mode.allowedWorldIds
    if type(allowedWorldIds) ~= "table" or #allowedWorldIds == 0 then
        g_logger.warning("[MODE-GATE] Missing allowedWorldIds for mode=" .. tostring(modeKey))
        return false
    end

    local worldIdNum = tonumber(worldId)
    if worldIdNum == nil then
        g_logger.warning("[MODE-GATE] Missing/invalid worldId for mode=" .. tostring(modeKey) .. " worldName=" .. tostring(worldName))
        return false
    end

    worldIdNum = math.floor(worldIdNum)
    for _, allowedId in ipairs(allowedWorldIds) do
        if worldIdNum == tonumber(allowedId) then
            return true
        end
    end

    return false
end

-- Walidacja placeholderów — ostrzeż natychmiast jeśli adresy nie zostały zmienione.
-- Dzięki temu fail widać od razu w logu, nie dopiero przy próbie logowania.
do
    local PLACEHOLDER = "ZMIEN_NA_ADRES"
    for key, mode in pairs(GameModes) do
        if mode.server and mode.server.host and mode.server.host:find(PLACEHOLDER) then
            g_logger.warning("[CONFIG] GameModes." .. key .. ".server.host zawiera placeholder! Zmień na prawdziwy adres.")
        end
        if mode.server and mode.server.httpLoginUrl and mode.server.httpLoginUrl:find(PLACEHOLDER) then
            g_logger.warning("[CONFIG] GameModes." .. key .. ".server.httpLoginUrl zawiera placeholder! Zmień na prawdziwy URL.")
        end
    end
end

-- INS-66/67: Load MANAGED_SERVER_LIST from launcher-generated file.
MANAGED_SERVER_LIST = nil
do
    local serverlistPath = g_resources.getWorkDir() .. "init_serverlist.lua"
    local f = io.open(serverlistPath, "r")
    if f then
        f:close()
        local ok, err = pcall(dofile, serverlistPath)
        if ok and MANAGED_SERVER_LIST then
            g_logger.info("[CONFIG] Loaded MANAGED_SERVER_LIST with " .. #MANAGED_SERVER_LIST .. " servers from launcher")
            for _, srv in ipairs(MANAGED_SERVER_LIST) do
                local mode = srv.gameMode
                if mode and GameModes[mode] and GameModes[mode].server then
                    GameModes[mode].server.host = srv.host
                    GameModes[mode].server.port = srv.loginPort or srv.port
                    local currentUrl = GameModes[mode].server.httpLoginUrl or ""
                    if currentUrl:find("127%.0%.0%.1") or currentUrl:find("localhost") then
                        GameModes[mode].server.httpLoginUrl = "https://" .. srv.host .. "/apik/v1/login.php"
                    end
                    g_logger.info("[CONFIG] Updated GameModes." .. mode .. " server from launcher: " .. srv.host .. ":" .. tostring(srv.port))
                end
            end
        elseif err then
            g_logger.warning("[CONFIG] Failed to load init_serverlist.lua: " .. tostring(err))
        end
    else
        g_logger.info("[CONFIG] No init_serverlist.lua found — using GameModes defaults")
    end
end

g_app.setName("OTClient");
g_app.setCompactName("otclient");
g_app.setOrganizationName("otcr");

g_app.hasUpdater = function()
    return (Services.updater and Services.updater ~= "" and g_modules.getModule("updater"))
end

-- setup logger
g_logger.setLogFile(g_resources.getWorkDir() .. g_app.getCompactName() .. '.log')
g_logger.info(os.date('== application started at %b %d %Y %X'))
g_logger.info("== operating system: " .. g_platform.getOSName())

-- print first terminal message
g_logger.info(g_app.getName() .. ' ' .. g_app.getVersion() .. ' rev ' .. g_app.getBuildRevision() .. ' (' ..
    g_app.getBuildCommit() .. ') built on ' .. g_app.getBuildDate() .. ' for arch ' ..
    g_app.getBuildArch())

-- Log konfiguracji - ułatwia debugowanie
g_logger.info("[CONFIG] CLIENT_LOCKED=" .. tostring(CLIENT_LOCKED) .. " DEV_MODE=" .. tostring(DEV_MODE))

-- setup lua debugger
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
    g_logger.debug("Started LUA debugger.")
else
    g_logger.debug("LUA debugger not started (not launched with VSCode local-lua).")
end

-- Debug: Print working directory
local workDir = g_resources.getWorkDir()
g_logger.info("Working directory: " .. tostring(workDir))

-- add data directory to the search path
local dataPath = workDir .. 'data'
g_logger.info("Adding data path: " .. dataPath)
if not g_resources.addSearchPath(dataPath, true) then
    g_logger.fatal('Unable to add data directory to the search path.')
end

-- add modules directory to the search path
local modulesPath = workDir .. 'modules'
g_logger.info("Adding modules path: " .. modulesPath)
if not g_resources.addSearchPath(modulesPath, true) then
    g_logger.fatal('Unable to add modules directory to the search path.')
end

-- try to add mods path too
local modsPath = workDir .. 'mods'
g_logger.info("Adding mods path: " .. modsPath)
g_resources.addSearchPath(modsPath, true)

-- setup directory for saving configurations
g_resources.setupUserWriteDir(('%s/'):format(g_app.getCompactName()))

-- search all packages
g_resources.searchAndAddPackages('/', '.otpkg', true)

-- load settings
g_configs.loadSettings('/config.otml')

g_modules.discoverModules()

-- libraries modules 0-99
g_modules.autoLoadModules(99)
g_modules.ensureModuleLoaded('corelib')
g_modules.ensureModuleLoaded('gamelib')
g_modules.ensureModuleLoaded('modulelib')
g_modules.ensureModuleLoaded("startup")

g_modules.autoLoadModules(999)
g_modules.ensureModuleLoaded('game_shaders') -- pre load

local function loadModules()
    -- client modules 100-499
    g_modules.autoLoadModules(499)
    g_modules.ensureModuleLoaded('client')

    -- game modules 500-999
    g_modules.autoLoadModules(999)
    g_modules.ensureModuleLoaded('game_interface')

    -- mods 1000-9999
    g_modules.autoLoadModules(9999)
    g_modules.ensureModuleLoaded('client_mods')

    local script = '/' .. g_app.getCompactName() .. 'rc.lua'

    if g_resources.fileExists(script) then
        dofile(script)
    end

    -- uncomment the line below so that modules are reloaded when modified. (Note: Use only mod dev)
    -- g_modules.enableAutoReload()
end

-- run updater, must use data.zip
if g_app.hasUpdater() then
    g_modules.ensureModuleLoaded("updater")
    return Updater.init(loadModules)
end

loadModules()
