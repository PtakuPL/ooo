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
-- game_i18n_en and game_i18n_en_compact are loaded automatically
-- by loadGameI18nForLocale() inside installLocale() — no manual dofile needed
