-- ═══════════════════════════════════════════════════════════════════════════════
-- I18N LOADER - Moduł Lua do ładowania i używania tłumaczeń
-- ═══════════════════════════════════════════════════════════════════════════════
-- Status: SZKIC - NIE ZAIMPLEMENTOWANY
-- Wersja: 1.0-draft
-- ═══════════════════════════════════════════════════════════════════════════════

-- Konfiguracja
local I18N_DIR = "i18n/"
local DEFAULT_LANGUAGE = "en"
local FALLBACK_LANGUAGE = "en"
local CACHE_ENABLED = true

-- Wewnętrzny cache
local translationCache = {}
local playerLanguages = {}
local loadedLanguages = {}

-- Moduł I18n
I18n = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- FUNKCJE PODSTAWOWE
-- ═══════════════════════════════════════════════════════════════════════════════

--- Ładuje plik JSON z tłumaczeniami
-- @param lang Kod języka (np. "pl", "de")
-- @param category Kategoria (np. "npc", "items", "scripts")
-- @return Tabela z tłumaczeniami lub nil
local function loadTranslationFile(lang, category)
    local filePath = I18N_DIR .. lang .. "/" .. category .. ".json"
    
    -- Sprawdź cache
    local cacheKey = lang .. ":" .. category
    if CACHE_ENABLED and translationCache[cacheKey] then
        return translationCache[cacheKey]
    end
    
    -- Próba otwarcia pliku
    local file = io.open(filePath, "r")
    if not file then
        print("[I18n] Warning: File not found: " .. filePath)
        return nil
    end
    
    local content = file:read("*all")
    file:close()
    
    -- Parsowanie JSON (wymaga biblioteki JSON)
    local success, translations = pcall(function()
        -- Użyj dostępnej biblioteki JSON
        if json and json.decode then
            return json.decode(content)
        elseif cjson and cjson.decode then
            return cjson.decode(content)
        else
            -- Prosty parser dla podstawowych przypadków
            return parseSimpleJson(content)
        end
    end)
    
    if not success then
        print("[I18n] Error parsing: " .. filePath .. " - " .. tostring(translations))
        return nil
    end
    
    -- Zapisz do cache
    if CACHE_ENABLED then
        translationCache[cacheKey] = translations
    end
    
    loadedLanguages[lang] = loadedLanguages[lang] or {}
    loadedLanguages[lang][category] = true
    
    return translations
end

--- Prosty parser JSON (fallback)
local function parseSimpleJson(str)
    -- Usuń whitespace
    str = str:gsub("^%s+", ""):gsub("%s+$", "")
    
    -- Parsuj obiekt JSON
    if str:sub(1, 1) == "{" then
        local result = {}
        local inner = str:sub(2, -2)
        
        for key, value in inner:gmatch('"([^"]+)"%s*:%s*"([^"]*)"') do
            result[key] = value
        end
        
        return result
    end
    
    return {}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- API PUBLICZNE
-- ═══════════════════════════════════════════════════════════════════════════════

--- Inicjalizuje system i18n
-- @param config Opcjonalna konfiguracja
function I18n.init(config)
    config = config or {}
    
    I18N_DIR = config.dir or I18N_DIR
    DEFAULT_LANGUAGE = config.defaultLanguage or DEFAULT_LANGUAGE
    FALLBACK_LANGUAGE = config.fallbackLanguage or FALLBACK_LANGUAGE
    CACHE_ENABLED = config.cacheEnabled ~= false
    
    print("[I18n] Initialized - Default: " .. DEFAULT_LANGUAGE)
    
    -- Preload common categories
    local preloadCategories = config.preload or {"npc", "items", "scripts"}
    for _, category in ipairs(preloadCategories) do
        loadTranslationFile(DEFAULT_LANGUAGE, category)
        loadTranslationFile(FALLBACK_LANGUAGE, category)
    end
end

--- Pobiera tłumaczenie dla klucza
-- @param key Klucz tłumaczenia (np. "npc.john.greeting")
-- @param lang Kod języka (opcjonalnie, domyślnie DEFAULT_LANGUAGE)
-- @param params Parametry do podstawienia (opcjonalnie)
-- @return Przetłumaczony tekst
function I18n.translate(key, lang, params)
    lang = lang or DEFAULT_LANGUAGE
    params = params or {}
    
    -- Parsuj klucz (category.subkey)
    local category, subkey = key:match("^([^.]+)%.(.+)$")
    if not category then
        -- Jeśli brak kategorii, użyj domyślnej
        category = "general"
        subkey = key
    end
    
    -- Załaduj tłumaczenia
    local translations = loadTranslationFile(lang, category)
    
    -- Szukaj tłumaczenia
    local translation = translations and translations[key]
    
    -- Fallback do języka EN
    if not translation and lang ~= FALLBACK_LANGUAGE then
        translations = loadTranslationFile(FALLBACK_LANGUAGE, category)
        translation = translations and translations[key]
    end
    
    -- Jeśli brak tłumaczenia, zwróć klucz
    if not translation then
        print("[I18n] Missing: " .. key .. " (" .. lang .. ")")
        return key
    end
    
    -- Podstaw parametry
    if next(params) then
        translation = I18n.format(translation, params)
    end
    
    return translation
end

--- Alias dla translate
function I18n.t(key, lang, params)
    return I18n.translate(key, lang, params)
end

--- Formatuje string z parametrami
-- @param str String z placeholderami
-- @param params Tabela parametrów
-- @return Sformatowany string
function I18n.format(str, params)
    -- Obsługa {name} style
    str = str:gsub("{([^}]+)}", function(key)
        return tostring(params[key] or "{" .. key .. "}")
    end)
    
    -- Obsługa %s, %d style (kolejność)
    local i = 0
    str = str:gsub("%%([sd])", function(type)
        i = i + 1
        local value = params[i]
        if type == "d" then
            return tostring(tonumber(value) or 0)
        else
            return tostring(value or "")
        end
    end)
    
    return str
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- FUNKCJE DLA GRACZY
-- ═══════════════════════════════════════════════════════════════════════════════

--- Ustawia język gracza
-- @param player Obiekt gracza lub ID
-- @param lang Kod języka
function I18n.setPlayerLanguage(player, lang)
    local playerId = type(player) == "number" and player or player:getId()
    playerLanguages[playerId] = lang
    
    -- Opcjonalnie: zapisz do bazy danych
    -- db.query("UPDATE players SET language = " .. db.escapeString(lang) .. " WHERE id = " .. playerId)
    
    print("[I18n] Player " .. playerId .. " language set to: " .. lang)
end

--- Pobiera język gracza
-- @param player Obiekt gracza lub ID
-- @return Kod języka
function I18n.getPlayerLanguage(player)
    local playerId = type(player) == "number" and player or player:getId()
    return playerLanguages[playerId] or DEFAULT_LANGUAGE
end

--- Tłumaczy dla konkretnego gracza
-- @param player Obiekt gracza
-- @param key Klucz tłumaczenia
-- @param params Parametry
-- @return Przetłumaczony tekst
function I18n.translateForPlayer(player, key, params)
    local lang = I18n.getPlayerLanguage(player)
    return I18n.translate(key, lang, params)
end

--- Alias dla translateForPlayer
function I18n.tp(player, key, params)
    return I18n.translateForPlayer(player, key, params)
end

--- Wysyła przetłumaczoną wiadomość do gracza
-- @param player Obiekt gracza
-- @param messageType Typ wiadomości
-- @param key Klucz tłumaczenia
-- @param params Parametry
function I18n.sendMessage(player, messageType, key, params)
    local message = I18n.translateForPlayer(player, key, params)
    player:sendTextMessage(messageType, message)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- FUNKCJE POMOCNICZE
-- ═══════════════════════════════════════════════════════════════════════════════

--- Przeładowuje cache tłumaczeń
function I18n.reload()
    translationCache = {}
    loadedLanguages = {}
    print("[I18n] Cache cleared")
end

--- Pobiera listę dostępnych języków
-- @return Tabela kodów języków
function I18n.getAvailableLanguages()
    local languages = {}
    
    -- Skanuj katalog i18n
    -- (wymaga dostępu do systemu plików)
    local defaultLanguages = {
        "en", "pl", "de", "es", "pt", "fr", "it", "nl", "ru", "uk"
    }
    
    for _, lang in ipairs(defaultLanguages) do
        if loadTranslationFile(lang, "npc") then
            table.insert(languages, lang)
        end
    end
    
    return languages
end

--- Sprawdza czy klucz istnieje
-- @param key Klucz
-- @param lang Język
-- @return boolean
function I18n.hasKey(key, lang)
    lang = lang or DEFAULT_LANGUAGE
    local category = key:match("^([^.]+)%.")
    local translations = loadTranslationFile(lang, category or "general")
    return translations and translations[key] ~= nil
end

--- Pobiera statystyki
-- @return Tabela statystyk
function I18n.getStats()
    local stats = {
        cachedCategories = 0,
        cachedKeys = 0,
        loadedLanguages = {}
    }
    
    for cacheKey, translations in pairs(translationCache) do
        stats.cachedCategories = stats.cachedCategories + 1
        for _ in pairs(translations) do
            stats.cachedKeys = stats.cachedKeys + 1
        end
    end
    
    for lang, categories in pairs(loadedLanguages) do
        local count = 0
        for _ in pairs(categories) do
            count = count + 1
        end
        stats.loadedLanguages[lang] = count
    end
    
    return stats
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- PRZYKŁADY UŻYCIA (DO USUNIĘCIA W PRODUKCJI)
-- ═══════════════════════════════════════════════════════════════════════════════

--[[
-- Inicjalizacja
I18n.init({
    dir = "i18n/",
    defaultLanguage = "en",
    preload = {"npc", "items", "scripts"}
})

-- Podstawowe tłumaczenie
local greeting = I18n.t("npc.john.greeting", "pl")

-- Z parametrami
local msg = I18n.t("npc.banker.balance", "pl", {gold = 1000})

-- Dla gracza
local player = Player(1)
I18n.setPlayerLanguage(player, "de")
I18n.sendMessage(player, MESSAGE_INFO_DESCR, "npc.shop.welcome")

-- Sprawdzenie
if I18n.hasKey("items.sword_of_valor.description") then
    -- ...
end
]]

return I18n
