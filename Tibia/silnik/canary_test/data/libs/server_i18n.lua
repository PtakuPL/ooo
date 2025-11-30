
-- data/libs/i18n.lua (Szkic)
-- Użycie: t("KEY", {name="Nick"}, player)  -> "Witaj Nick!" (wg języka gracza)
-- Wymaga: plików w data/locales_server/<lang>.lua z tabelą L = { KEY = "tekst" }

local STORAGE_LANG = 90001
local DEFAULT_LANG = "en"

local cache = {}

local function loadLang(lang)
  if cache[lang] then return cache[lang] end
  local ok, mod = pcall(dofile, string.format("%s/%s.lua", "data/locales_server", lang))
  if ok and type(mod) == "table" and mod.L then
    cache[lang] = mod.L
    return mod.L
  end
  cache[lang] = {}
  return cache[lang]
end

local function fmt(s, vars)
  if not vars then return s end
  for k,v in pairs(vars) do
    s = s:gsub("{"..k.."}", tostring(v))
  end
  return s
end

function getPlayerLang(player)
  local lang = player:getStorageValue(STORAGE_LANG)
  if type(lang) ~= "string" or #lang == 0 then
    return DEFAULT_LANG
  end
  return lang
end

function setPlayerLang(player, lang)
  player:setStorageValue(STORAGE_LANG, lang)
end

function t(key, vars, player)
  local lang = DEFAULT_LANG
  if player then lang = getPlayerLang(player) end
  local L = loadLang(lang)
  local text = L[key]
  if not text then
    -- fallback do en
    local Len = loadLang("en")
    text = Len[key] or key
  end
  return fmt(text, vars)
end

-- Helper: sendTextMessage z tłumaczeniem klucza
function sendTextMessageEx(player, msgType, key, vars)
  player:sendTextMessage(msgType, t(key, vars, player))
end

return {
  t = t,
  setPlayerLang = setPlayerLang,
  getPlayerLang = getPlayerLang,
  sendTextMessageEx = sendTextMessageEx
}
