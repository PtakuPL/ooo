-- ============================================================================
-- I18N Layout Overrides — German (de)
-- ============================================================================
-- German translations tend to be 30-60% longer than English.
-- This file provides widget size overrides for German locale.
--
-- Format:
--   ["module_path/otui_file_without_ext"] = {
--       ["widget_id"] = { ["property"] = value, ... },
--   }
--
-- Supported properties:
--   width, height, min-width, max-width, min-height, max-height,
--   text-horizontal-auto-resize (true/false),
--   text-auto-resize (true/false),
--   font-scale (float)
--
-- To generate initial values, run in game console:
--   i18nLayout.measureLanguage("de")
-- ============================================================================

return {
    -- Options root loaded by Controller: g_ui.loadUI('/client_options/options', ...)
    ["client_options/options"] = {
        ["optionsWindow"] = { ["min-width"] = 740, ["max-width"] = 1120 },
        ["optionsTabBar"] = { ["min-width"] = 178 },
    },

    -- Options subpanel loaded by g_ui.loadUI('styles/controls/general', ...)
    ["styles/controls/general"] = {
        ["hotkeysButton"] = { ["min-width"] = 188 },
    },
}
