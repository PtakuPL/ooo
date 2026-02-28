dofile 'neededtranslations'
dofile 'i18n_layout'

-- private variables
local defaultLocaleName = 'en'
local installedLocales
local currentLocale
local localesWindow

local localeDisplayNameOverrides = {
  es = "Español",
  pt = "Português",
  zh = "Chinese",
  zh_tw = "Chinese (Traditional)",
  ja = "Japanese",
  ko = "Korean",
}

local function normalizeLocaleCode(code)
  if not code then
    return ''
  end
  return tostring(code):lower():gsub('-', '_')
end

local function getLocaleDisplayName(localeCode, localeData)
  local normalizedCode = normalizeLocaleCode(localeCode)
  local overrideName = localeDisplayNameOverrides[normalizedCode]
  if overrideName then
    return overrideName
  end

  local languageName = localeData and localeData.languageName or normalizedCode
  if type(languageName) ~= 'string' then
    return normalizedCode
  end

  if languageName:find('�', 1, true) then
    local cleaned = languageName:gsub('�', '')
    if cleaned ~= '' then
      return cleaned
    end
  end

  return languageName
end

local function resolveFlagSource(localeCode)
  local normalizedCode = normalizeLocaleCode(localeCode)
  local shortCode = normalizedCode:match('^([a-z][a-z])[_]?[a-z]*$')
  local candidates = { normalizedCode, shortCode }

  for _, candidate in ipairs(candidates) do
    if candidate and candidate ~= '' then
      local src = '/images/flags/' .. candidate
      if g_resources.fileExists(src .. '.png') or g_resources.fileExists(src) then
        return src
      end
    end
  end

  -- Fallback avoids broken/blank icons when a locale flag asset is missing.
  return '/images/flags/en'
end

-- send current locale to server (extended opcode)
local function sendLocale(localeName)
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(ExtendedIds.Locale, localeName)
    return true
  end
  return false
end

-- UI: create language picker window
local function createWindow()
  localesWindow = g_ui.displayUI('locales')
  local localesPanel = localesWindow:getChildById('localesPanel')

  -- Sort locales alphabetically by language name for clean display
  local sortedLocales = {}
  for name, locale in pairs(installedLocales) do
    sortedLocales[#sortedLocales + 1] = {
      code = name,
      locale = locale,
      displayName = getLocaleDisplayName(name, locale),
    }
  end
  table.sort(sortedLocales, function(a, b) return a.displayName < b.displayName end)

  for _, entry in ipairs(sortedLocales) do
    local widget = g_ui.createWidget('LocalesButton', localesPanel)
    widget:setImageSource(resolveFlagSource(entry.code))
    widget:setText(entry.displayName)
    widget:setTooltip((entry.displayName or entry.code) .. ' [' .. entry.code .. ']')
    widget.onClick = function()
      selectFirstLocale(entry.code)
    end
  end

  addEvent(function()
    addEvent(function()
      localesWindow:raise()
      localesWindow:focus()
    end)
  end)
end

function selectFirstLocale(name)
  if localesWindow then
    localesWindow:destroy()
    localesWindow = nil
  end
  if setLocale(name) then
    g_modules.reloadModules()
  end
end

-- hooks
local function onGameStart()
  if currentLocale then
    sendLocale(currentLocale.name)
  end
end

local function onExtendedLocales(protocol, opcode, buffer)
  local locale = installedLocales[buffer]
  if locale and setLocale(locale.name) then
    g_modules.reloadModules()
  end
end

-- helper to open the locales window from UI buttons/commands
function openLanguagePicker()
  if not localesWindow or not localesWindow:isVisible() then
    createWindow()
  else
    localesWindow:raise()
    localesWindow:focus()
  end
end

-- public functions
function init()
  installedLocales = {}
  -- Reset i18n load tracking so game_i18n files are reloaded for fresh locale objects
  -- (this global persists across g_modules.reloadModules() calls)
  _G.__gameI18nLoaded = {}
  installLocales('/locales')

  local savedLocale = g_settings.get('locale', 'false')
  if savedLocale ~= 'false' then
    setLocale(savedLocale)
  else
    setLocale(defaultLocaleName)
  end

  -- Always connect the language picker so it can be opened from topmenu.
  -- Also show it automatically on first run when no locale has been saved yet.
  if g_app.hasUpdater() then
    if savedLocale == 'false' then
      connect(g_app, { onUpdateFinished = createWindow })
    end
  else
    if savedLocale == 'false' then
      connect(g_app, { onRun = createWindow })
    end
  end

  -- Register Ctrl+L keyboard shortcut to open language picker anytime
  g_keyboard.bindKeyDown('Ctrl+L', openLanguagePicker)

  ProtocolGame.registerExtendedOpcode(ExtendedIds.Locale, onExtendedLocales)
  connect(g_game, { onGameStart = onGameStart })

  -- export helper for other modules (e.g., topmenu button)
  modules = modules or {}
  modules.client_locales = modules.client_locales or {}
  modules.client_locales.openLanguagePicker = openLanguagePicker
  modules.client_locales.createWindow = createWindow

  -- Initialize I18N layout override system
  if i18nLayout and i18nLayout.init then
    i18nLayout.init()
  end
end

function terminate()
  -- Terminate I18N layout override system
  if i18nLayout and i18nLayout.terminate then
    i18nLayout.terminate()
  end

  installedLocales = nil
  currentLocale = nil

  ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Locale)
  -- Unbind keyboard shortcut
  g_keyboard.unbindKeyDown('Ctrl+L')
  if g_app.hasUpdater() then
    pcall(disconnect, g_app, { onUpdateFinished = createWindow })
  else
    pcall(disconnect, g_app, { onRun = createWindow })
  end
  disconnect(g_game, { onGameStart = onGameStart })
end

function generateNewTranslationTable(localename)
  local locale = installedLocales[localename]
  for _i, k in pairs(neededTranslations) do
    local trans = locale.translation[k]
    k = k:gsub('\n', '\\n'):gsub('\t', '\\t'):gsub('\"', '\\\"')
    if trans then
      trans = trans:gsub('\n', '\\n'):gsub('\t', '\\t'):gsub('\"', '\\\"')
    end
    if not trans then
      print('    ["' .. k .. '"] = false,')
    else
      print('    ["' .. k .. '"] = "' .. trans .. '",')
    end
  end
end

function installLocale(locale)
  if not locale or not locale.name then
    error('Unable to install locale.')
  end

  if _G.allowedLocales and not _G.allowedLocales[locale.name] then
    return
  end

  if locale.name ~= defaultLocaleName then
    local updatesNamesMissing = {}
    for _, k in pairs(neededTranslations) do
      if locale.translation[k] == nil then
        updatesNamesMissing[#updatesNamesMissing + 1] = k
      end
    end
    if #updatesNamesMissing > 0 then
      pdebug("Locale '" .. locale.name .. "' is missing " .. #updatesNamesMissing .. " translations.")
      for _, name in pairs(updatesNamesMissing) do
        pdebug('["' .. name .. '"] = "",')
      end
    end
  end

  local installedLocale = installedLocales[locale.name]
  if installedLocale then
    for word, translation in pairs(locale.translation) do
      installedLocale.translation[word] = translation
    end
  else
    installedLocales[locale.name] = locale
  end

  -- Auto-load game i18n dictionaries (semantic + compact) for this locale.
  -- This keeps all locales consistent without editing every data/locales/<lang>.lua file.
  if loadGameI18nForLocale then
    loadGameI18nForLocale(locale)
  end
end

function loadGameI18nForLocale(locale)
  if not locale or not locale.name then
    return
  end

  _G.__gameI18nLoaded = _G.__gameI18nLoaded or {}
  if _G.__gameI18nLoaded[locale.name] then
    return
  end
  _G.__gameI18nLoaded[locale.name] = true

  local prevGlobalLocale = rawget(_G, 'locale')
  _G.locale = locale

  -- Count translations before loading to verify merge worked
  local countBefore = 0
  if locale.translation then
    for _ in pairs(locale.translation) do countBefore = countBefore + 1 end
  end

  -- Use absolute paths so dofile resolves correctly regardless of calling context.
  -- Log errors instead of silently swallowing them via pcall.
  local path1 = '/locales/game_i18n_' .. locale.name
  local ok1, err1 = pcall(dofile, path1)
  if not ok1 and err1 then
    pwarning('[i18n] Failed to load ' .. path1 .. ': ' .. tostring(err1))
  end

  local path2 = '/locales/game_i18n_' .. locale.name .. '_compact'
  local ok2, err2 = pcall(dofile, path2)
  if not ok2 and err2 then
    -- compact files are optional, only debug-log
    pdebug('[i18n] No compact file for ' .. locale.name .. ' (ok)')
  end

  local countAfter = 0
  if locale.translation then
    for _ in pairs(locale.translation) do countAfter = countAfter + 1 end
  end
  local loaded = countAfter - countBefore
  if loaded > 0 then
    pdebug('[i18n] Loaded ' .. loaded .. ' game translations for ' .. locale.name)
  elseif ok1 then
    pwarning('[i18n] game_i18n_' .. locale.name .. ' loaded but 0 translations merged!')
  end

  _G.locale = prevGlobalLocale
end

function installLocales(directory)
  -- Only load base locale files (2-5 letter code .lua files).
  -- Skip game_i18n_* files — those are loaded per-locale by loadGameI18nForLocale()
  -- or by explicit dofile() calls in the base locale files themselves.
  -- Loading them via dofiles() caused _G.locale pollution: compact files would
  -- merge their translations into whichever locale was last set by a base file,
  -- leading to e.g. Japanese translations overwriting English, etc.
  local files = g_resources.listDirectoryFiles(directory)
  for _, file in ipairs(files) do
    if g_resources.isFileType(file, "lua") and not file:find("^game_i18n_") then
      local ok, err = pcall(dofile, directory .. '/' .. file)
      if not ok then
        pwarning('[i18n] Failed to load locale file: ' .. file .. ': ' .. tostring(err))
      end
    end
  end
end

function setLocale(name)
  local locale = installedLocales[name]
  if locale == currentLocale then
    g_settings.set('locale', name)
    return
  end
  if not locale then
    pwarning('Locale ' .. name .. ' does not exist.')
    return false
  end
  if currentLocale then
    sendLocale(locale.name)
  end
  currentLocale = locale
  g_settings.set('locale', name)
  
  -- Update HarfBuzz shaping locale tag (e.g. "en", "de", "pl")
  if g_fonts.setLocaleTag then
    g_fonts.setLocaleTag(locale.languageTag or name)
  end

  -- Clear TTF font/shape caches when locale changes (different glyphs may be needed)
  if g_fonts.clearGlyphCaches then
    g_fonts.clearGlyphCaches()
  end
  
  if onLocaleChanged then
    onLocaleChanged(name)
  end
  return true
end

function getInstalledLocales()
  return installedLocales
end

function getCurrentLocale()
  return currentLocale
end

-- Helper to apply format patterns to a translated string.
local function applyFormat(translation, ...)
  if translation:find("{}", 1, true) then
    local args = {...}
    local idx = 0
    return (translation:gsub("%{%}", function()
      idx = idx + 1
      local v = args[idx]
      if v == nil then
        return "{}"
      end
      return tostring(v)
    end))
  end
  local ok, result = pcall(string.format, translation, ...)
  if ok then
    return result
  end
  return translation
end

-- global function used to translate texts
function _G.tr(text, ...)
  if currentLocale then
    if tostring(text) then
      local translation = currentLocale.translation[text]
      if translation then
        return applyFormat(translation, ...)
      end

      -- Fallback for semantic keys (e.g. "otclient_modules.entergame.tr_14"):
      -- Look up the English value for the key, then search for THAT human-readable
      -- string in the current locale's translation table.
      -- Example flow for PL locale:
      --   tr("otclient_modules.entergame.tr_14")
      --   → PL doesn't have this key
      --   → EN has: "otclient_modules.entergame.tr_14" = "Enter Game"
      --   → PL has: "Enter Game" = "Wejdz do gry"
      --   → returns "Wejdz do gry"
      if currentLocale.name ~= defaultLocaleName and installedLocales then
        local enLocale = installedLocales[defaultLocaleName]
        if enLocale then
          local enValue = enLocale.translation[text]
          if enValue then
            -- Try finding the English value in the current locale
            local localTranslation = currentLocale.translation[enValue]
            if localTranslation then
              return applyFormat(localTranslation, ...)
            end
            -- English value not translated either — return English as fallback
            return applyFormat(enValue, ...)
          end
        end
      end

      -- If there is no translation, we can still format numbers (kept for legacy usage).
      if tonumber(text) and currentLocale.formatNumbers then
        local number = tostring(text):split('.')
        local out = ''
        local reverseNumber = number[1]:reverse()
        for i = 1, #reverseNumber do
          out = out .. reverseNumber:sub(i, i)
          if i % 3 == 0 and i ~= #number then
            out = out .. currentLocale.thousandsSeperator
          end
        end
        if number[2] then
          out = number[2] .. currentLocale.decimalSeperator .. out
        end
        return out:reverse()
      end

      if currentLocale.name ~= defaultLocaleName then
        pdebug('Unable to translate: "' .. text .. '"')
      end
      return string.format(text, ...)
    end
  end
  return text
end
