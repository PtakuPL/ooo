-- ============================================================================
-- I18N Layout Overrides — Spanish (es)
-- ============================================================================
-- Spanish is typically 15-30% longer than English.
-- Example: "Enter Game" → "Entrar al Juego" (50% longer)
--          "Login Error" → "Error de inicio de sesión" (127% longer)
--
-- Run `i18nLayout.measureLanguage("es")` in console to find worst offenders.
-- ============================================================================

return {
    ["client_options/options"] = {
        ["optionsWindow"] = { ["min-width"] = 715, ["max-width"] = 1080 },
        ["optionsTabBar"] = { ["min-width"] = 162 },
    },

    ["styles/controls/general"] = {
        ["hotkeysButton"] = { ["min-width"] = 172 },
    },
}
