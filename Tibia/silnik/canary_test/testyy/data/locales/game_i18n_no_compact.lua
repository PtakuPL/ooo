-- Compact key translations for NO
-- Server sends short IDs that map to translations.
-- These are loaded dynamically by the server protocol.
-- Stub file to prevent OTClient constant-pool overflow.

local compactTranslations = {}

if locale and locale.translation then
  for key, value in pairs(compactTranslations) do
    locale.translation[key] = value
  end
end
