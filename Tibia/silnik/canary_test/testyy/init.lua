-- this is the first file executed when the application starts
-- we have to load the first modules form here

-- updater
Services = {
    --updater = "http://localhost/api/updater.php", --./updater
    --status = "http://localhost/login.php", --./client_entergame | ./client_topmenu
    --websites = "http://localhost/?subtopic=accountmanagement", --./client_entergame "Forgot password and/or email"
    --createAccount = "http://localhost/clientcreateaccount.php", --./client_entergame -- createAccount.lua
}

--[[
Servers_init = {
    ["http://127.0.0.1/login.php"] = {
        ["port"] = 80,
        ["protocol"] = 1420,
        ["httpLogin"] = true
    },
    ["ip.net"] = {
        ["port"] = 7171,
        ["protocol"] = 860,
        ["httpLogin"] = false
    },
}
]]

-- ── Server categories & restrictions ──────────────────────────────────
-- Each server in Servers_init can have a 'category' field.
-- ServerCategories defines per-category restrictions enforced by the client.
ServerCategories = {
    ["current"] = {
        label = "Aktualny",
        restrictions = {},
    },
    ["retro74"] = {
        label = "Retro 7.4",
        restrictions = {
            blockItemHotkeys = true,  -- block ALL item hotkeys (spells via text OK)
        },
    },
}

-- Active server category (set when a server is selected from the list)
_G.activeServerCategory = nil

-- Check if a restriction is active for the current server category
function _G.isRestricted(restrictionName)
    if not _G.activeServerCategory then return false end
    local cat = ServerCategories and ServerCategories[_G.activeServerCategory]
    if not cat or not cat.restrictions then return false end
    return cat.restrictions[restrictionName] == true
end

-- Get the label of the current server category
function _G.getActiveCategoryLabel()
    if not _G.activeServerCategory then return nil end
    local cat = ServerCategories and ServerCategories[_G.activeServerCategory]
    return cat and cat.label or _G.activeServerCategory
end

-- Set category from a server host key (lookup in Servers_init)
function _G.setServerCategoryFromHost(host)
    if Servers_init and Servers_init[host] then
        _G.activeServerCategory = Servers_init[host].category or "current"
    else
        _G.activeServerCategory = "current"
    end
end

g_app.setName("OTClient - Redemption");
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
