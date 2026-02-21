-- ============================================================================
-- I18N Layout Overrides — French (fr)
-- ============================================================================
-- French translations are often 20-50% longer than English.
-- Typical problems: "Remember password:" → "Se souvenir du mot de passe :"
--
-- Run `i18nLayout.measureLanguage("fr")` in console to find worst offenders.
-- ============================================================================

return {
    ["client_options/options"] = {
        ["optionsWindow"] = { ["min-width"] = 730, ["max-width"] = 1100 },
        ["optionsTabBar"] = { ["min-width"] = 170 },
    },

    ["styles/controls/general"] = {
        ["hotkeysButton"] = { ["min-width"] = 180 },
    },
}
