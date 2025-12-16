locale = {
  name = "en",
  charset = "cp1252",
  languageName = "English",

  formatNumbers = true,
  decimalSeperator = '.',
  thousandsSeperator = ',',

  -- translations are not needed because everything is already in english
  translation = {}
}

modules.client_locales.installLocale(locale)

-- Load game i18n translations (NPC dialogs, monster voices, etc.)
dofile('game_i18n_en')

-- Load compact-key translations (server may send compact i18n IDs)
dofile('game_i18n_en_compact')
