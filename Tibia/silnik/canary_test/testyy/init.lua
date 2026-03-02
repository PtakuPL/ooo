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

-- Gdy true: klient jest przypisany do naszych serwerów.
-- Gracz NIE może dodawać/usuwać/edytować serwerów.
-- Lista serwerów pochodzi WYŁĄCZNIE z GameModes poniżej.
-- ⚠ FIX16 SYNC: Ta wartość MUSI być zsynchronizowana z CLIENT_LOCKED w .env (API).
--   init.lua CLIENT_LOCKED = true  →  .env CLIENT_LOCKED=true
--   init.lua CLIENT_LOCKED = false →  .env CLIENT_LOCKED=false
--   Dryft powoduje, że klient jest zablokowany ale login.php nie wymaga launchToken (lub odwrotnie).
CLIENT_LOCKED = true

-- Tryby gry — każdy definiuje serwer i dozwolone funkcje.
-- Klucze: "classic74", "modern" (matchują gameMode w tickecie HMAC)
GameModes = {
    classic74 = {
        name = "Classic 7.4",
        description = "Serwer w stylu Tibia 7.4 — bez hotkey na runy, bez market, bez quick loot.",
        server = {
            host = "127.0.0.1",   -- FIX25: adres serwera (dev: WSL localhost)
            port = 443,            -- Port API (HTTPS). Game port (7172) jest w login.php response.
            protocol = 1420,
            httpLogin = true,
            httpLoginUrl = "https://127.0.0.1/apik/v1/login.php",  -- FIX25: prawdziwy URL API
        },
        features = {
            hotkeys_items    = false,  -- blokada hotkey na itemy/runy
            hotkeys_spells   = true,   -- hotkey na spelle dozwolone
            quick_loot       = false,
            auto_loot        = false,
            market           = false,
            action_bar       = false,
            smart_equip      = false,  -- ctrl+klik auto-equip
            prey             = false,
            bestiary         = false,
            wheel            = false,  -- koło umiejętności
            analytics        = false,
        },
    },
    modern = {
        name = "Modern 14.20+",
        description = "Pełna wersja Tibia — wszystkie nowoczesne funkcje.",
        server = {
            host = "127.0.0.1",   -- FIX25: adres serwera (dev: WSL localhost)
            port = 443,            -- Port API (HTTPS). Game port (7172) jest w login.php response.
            protocol = 1420,
            httpLogin = true,
            httpLoginUrl = "https://127.0.0.1/apik/v1/login.php",  -- FIX25: prawdziwy URL API
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

-- Aktualnie wybrany tryb gry (nil = gracz jeszcze nie wybrał).
-- Ustawiany przez ekran wyboru trybu (Faza A2/A3).
CurrentGameMode = nil

-- E10: Token z launchera — przekazywany przez zmienną środowiskową OTC_LAUNCH_TOKEN.
-- Launcher ustawia ją tuż przed uruchomieniem klienta (subprocess env).
-- Login.php waliduje ten token (E11) aby upewnić się, że klient przeszedł przez launcher.
G.launchToken = os.getenv("OTC_LAUNCH_TOKEN") or ""

-- Helper: szybki dostęp do feature flags aktualnego trybu.
-- Użycie: if isFeatureEnabled("quick_loot") then ...
function isFeatureEnabled(featureName)
    if not CurrentGameMode then return true end  -- domyślnie: włączone
    local mode = GameModes[CurrentGameMode]
    if not mode or not mode.features then return true end
    local val = mode.features[featureName]
    if val == nil then return true end  -- nieznana flaga = włączona
    return val
end

-- Helper: pobierz konfigurację serwera dla aktualnego trybu.
function getCurrentServerConfig()
    if not CurrentGameMode then return nil end
    local mode = GameModes[CurrentGameMode]
    if not mode then return nil end
    return mode.server
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
