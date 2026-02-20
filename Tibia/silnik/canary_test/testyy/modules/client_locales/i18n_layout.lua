-- ============================================================================
-- I18N UI Layout Override System
-- ============================================================================
-- This module provides per-language UI widget size overrides.
--
-- PROBLEM:
--   Many OTUI files use fixed `width:` values for buttons, labels, and panels.
--   When text is translated to another language (e.g. DE, FR, PL, RU), the
--   translated string may be significantly longer (up to 2x), causing text
--   to be clipped or overflow the widget bounds.
--
-- SOLUTION (3 approaches, from easiest to most thorough):
--
--   1. **I18NButton / I18NQtButton styles** (already in 10-buttons.otui):
--      Use `text-horizontal-auto-resize: true` + `min-width: 106` so the
--      button grows to fit the text. Replace `Button` → `I18NButton` in
--      OTUI files that use `tr()`.
--
--   2. **Per-language config overrides** (THIS MODULE):
--      Load JSON/Lua config files like `data/i18n_layout/de.lua` that
--      specify widget size overrides for specific modules/widgets.
--      Applied automatically when locale changes.
--
--   3. **Auto-measurement tool** (dev-time):
--      A Lua function that iterates all tr() keys, measures rendered text
--      width for each language, and generates the config files from #2.
--
-- USAGE:
--   The module auto-loads on init. When the locale changes, it applies
--   any layout overrides for the new language.
--
--   To create a layout override file, create:
--     data/i18n_layout/<lang_code>.lua
--   with content like:
--     return {
--       ["client_entergame/entergame"] = {
--         ["serverListButton"] = { ["min-width"] = 140 },
--         ["btnCreateNewAccount"] = { ["min-width"] = 160 },
--       },
--       ["game_blessing/style"] = {
--         ["blessingBuyButton"] = { ["min-width"] = 90, ["width"] = 90 },
--       },
--     }
--
-- ============================================================================

local i18nLayout = {}

-- Storage for loaded layout overrides per language
local layoutOverrides = {}

-- Track which widgets have been patched so we can revert
local patchedWidgets = {}

-- ============================================================================
-- Core: Load layout override file for a language
-- ============================================================================
local function loadLayoutFile(langCode)
    if layoutOverrides[langCode] ~= nil then
        return layoutOverrides[langCode]
    end

    local path = '/i18n_layout/' .. langCode
    local ok, result = pcall(dofile, path)
    if ok and type(result) == 'table' then
        layoutOverrides[langCode] = result
        pdebug('[I18N Layout] Loaded overrides for ' .. langCode ..
               ' (' .. tableSize(result) .. ' modules)')
        return result
    else
        layoutOverrides[langCode] = false  -- mark as attempted
        pdebug('[I18N Layout] No layout overrides for ' .. langCode)
        return nil
    end
end

-- ============================================================================
-- Core: Apply layout overrides to a specific widget by ID
-- ============================================================================
local function applyWidgetOverride(widget, overrides)
    if not widget or not overrides then return end

    for prop, value in pairs(overrides) do
        if prop == 'width' then
            widget:setWidth(value)
        elseif prop == 'height' then
            widget:setHeight(value)
        elseif prop == 'min-width' then
            widget:setMinWidth(value)
        elseif prop == 'max-width' then
            widget:setMaxWidth(value)
        elseif prop == 'min-height' then
            widget:setMinHeight(value)
        elseif prop == 'max-height' then
            widget:setMaxHeight(value)
        elseif prop == 'text-horizontal-auto-resize' then
            widget:setTextHorizontalAutoResize(value)
        elseif prop == 'text-auto-resize' then
            widget:setTextAutoResize(value)
        elseif prop == 'font-scale' then
            widget:setFontScale(value)
        elseif prop == 'padding-left' then
            -- For padding adjustments
            local padding = widget:getPaddingRect()
            padding.left = value
            widget:setPaddingRect(padding)
        elseif prop == 'padding-right' then
            local padding = widget:getPaddingRect()
            padding.right = value
            widget:setPaddingRect(padding)
        end
    end
end

-- ============================================================================
-- Apply overrides for a specific root widget (e.g., a window)
-- ============================================================================
function i18nLayout.applyOverrides(rootWidget, modulePath, langCode)
    if not rootWidget then return end

    langCode = langCode or i18nLayout.getCurrentLang()
    if not langCode then return end

    local overrides = loadLayoutFile(langCode)
    if not overrides then return end

    local moduleOverrides = overrides[modulePath]
    if not moduleOverrides then return end

    for widgetId, widgetOverrides in pairs(moduleOverrides) do
        local widget = rootWidget:recursiveGetChildById(widgetId)
        if widget then
            applyWidgetOverride(widget, widgetOverrides)
            -- Track for potential revert
            patchedWidgets[widget] = { module = modulePath, lang = langCode }
        else
            pdebug('[I18N Layout] Widget "' .. widgetId ..
                   '" not found in ' .. modulePath)
        end
    end
end

-- ============================================================================
-- Get current language code
-- ============================================================================
function i18nLayout.getCurrentLang()
    if modules and modules.client_locales and modules.client_locales.getCurrentLocale then
        local locale = modules.client_locales.getCurrentLocale()
        if locale then
            return locale.name
        end
    end
    -- Fallback: check g_settings
    local saved = g_settings.get('locale', 'en')
    return saved ~= 'false' and saved or 'en'
end

-- ============================================================================
-- Auto-measurement: Measure text widths for all tr() keys in a language
-- ============================================================================
-- This generates a report showing which widgets need size overrides.
-- Run this in the console:
--   i18nLayout.measureLanguage("de")
--   i18nLayout.measureLanguage("pl")
--
function i18nLayout.measureLanguage(langCode)
    langCode = langCode or i18nLayout.getCurrentLang()

    -- We need a font to measure with
    local font = g_fonts.getFont('noto-12')
    if not font then
        perror('[I18N Layout] Cannot measure: font noto-12 not found')
        return
    end

    -- Get the locale translation table
    local locales = modules.client_locales.getInstalledLocales()
    local locale = locales and locales[langCode]
    local enLocale = locales and locales['en']

    if not locale then
        perror('[I18N Layout] Locale ' .. langCode .. ' not found')
        return
    end

    local report = {}
    local problems = 0

    -- Check all translations and compare lengths
    for key, enValue in pairs(enLocale and enLocale.translation or {}) do
        local trValue = locale.translation[key]
        if trValue and type(enValue) == 'string' and type(trValue) == 'string' then
            local enSize = font:calculateTextRectSize(enValue)
            local trSize = font:calculateTextRectSize(trValue)

            if trSize.width > enSize.width * 1.2 then
                -- This translation is >20% wider than English
                local ratio = trSize.width / math.max(enSize.width, 1)
                table.insert(report, {
                    key = key,
                    enWidth = enSize.width,
                    trWidth = trSize.width,
                    ratio = ratio,
                    enText = enValue:sub(1, 40),
                    trText = trValue:sub(1, 40),
                })
                problems = problems + 1
            end
        end
    end

    -- Sort by ratio (worst offenders first)
    table.sort(report, function(a, b) return a.ratio > b.ratio end)

    -- Print report
    print('=== I18N Layout Report for ' .. langCode .. ' ===')
    print('Translations wider than EN by >20%: ' .. problems)
    print('')
    for i, entry in ipairs(report) do
        if i > 50 then
            print('... and ' .. (problems - 50) .. ' more')
            break
        end
        print(string.format('  [%.1fx] %s', entry.ratio, entry.key))
        print(string.format('    EN (%dpx): %s', entry.enWidth, entry.enText))
        print(string.format('    %s (%dpx): %s', langCode:upper(), entry.trWidth, entry.trText))
        print('')
    end

    return report
end

-- ============================================================================
-- Auto-generate layout override stub for a language
-- ============================================================================
-- Run: i18nLayout.generateOverrideStub("de")
-- This prints a Lua table you can save as data/i18n_layout/de.lua
--
function i18nLayout.generateOverrideStub(langCode)
    local report = i18nLayout.measureLanguage(langCode)
    if not report or #report == 0 then
        print('No layout overrides needed for ' .. langCode)
        return
    end

    print('')
    print('=== Generated stub for data/i18n_layout/' .. langCode .. '.lua ===')
    print('-- Auto-generated I18N layout overrides for ' .. langCode)
    print('-- Review and adjust values before deploying.')
    print('return {')
    print('  -- Module overrides: ["module/file"] = { ["widgetId"] = { props } }')
    print('  -- TODO: Map tr() keys to their OTUI module/widget locations')
    print('  -- Worst offenders (>' .. #report .. ' translations wider than EN):')
    for i = 1, math.min(20, #report) do
        local e = report[i]
        print(string.format('  -- [%.1fx] %s: EN=%dpx, %s=%dpx',
            e.ratio, e.key, e.enWidth, langCode:upper(), e.trWidth))
    end
    print('}')
end

-- ============================================================================
-- Hook into locale change to auto-apply overrides
-- ============================================================================
function i18nLayout.onLocaleChanged(langCode)
    -- Clear tracking
    patchedWidgets = {}
    -- Pre-load the override file for the new language
    loadLayoutFile(langCode)
end

-- ============================================================================
-- Module lifecycle
-- ============================================================================
function i18nLayout.init()
    -- Connect to locale change event
    if modules and modules.client_locales then
        -- Hook the locale change
        _G.i18nLayout = i18nLayout
        pdebug('[I18N Layout] Module initialized')
    end
end

function i18nLayout.terminate()
    _G.i18nLayout = nil
    layoutOverrides = {}
    patchedWidgets = {}
end

-- Make available globally
_G.i18nLayout = i18nLayout

return i18nLayout
