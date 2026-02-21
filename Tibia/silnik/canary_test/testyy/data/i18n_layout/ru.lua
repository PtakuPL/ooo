-- ============================================================================
-- I18N Layout Overrides — Russian (ru)
-- ============================================================================
-- Russian uses Cyrillic script. Text may be slightly wider due to character
-- widths, and translations are often 10-40% longer than English.
-- Example: "Please wait" → "Пожалуйста, подождите" (91% longer)
--
-- Run `i18nLayout.measureLanguage("ru")` in console to find worst offenders.
-- ============================================================================

return {
    ["client_options/options"] = {
        ["optionsWindow"] = { ["min-width"] = 735, ["max-width"] = 1110 },
        ["optionsTabBar"] = { ["min-width"] = 174 },
    },

    ["styles/controls/general"] = {
        ["hotkeysButton"] = { ["min-width"] = 184 },
    },
}
