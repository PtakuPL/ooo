--[[
  Transliteration module — optional conversion of non-Latin scripts to Latin alphabet.

  This does NOT translate text — it converts the script/alphabet only.
  Example: "Привет" → "Privet" (Cyrillic to Latin)

  Players can enable/disable this per-script in client options.
  Supported scripts: Cyrillic, Greek, Arabic (basic), Japanese Katakana (basic).
]]

Transliteration = {}

-- ═══════════════════════════════════════════════════════════════════
-- Transliteration tables — each maps Unicode codepoints to Latin strings
-- ═══════════════════════════════════════════════════════════════════

-- Cyrillic → Latin (ISO 9 simplified, practical transliteration)
local cyrillicToLatin = {
  -- Uppercase
  [0x0410] = "A",   [0x0411] = "B",   [0x0412] = "V",   [0x0413] = "G",
  [0x0414] = "D",   [0x0415] = "E",   [0x0416] = "Zh",  [0x0417] = "Z",
  [0x0418] = "I",   [0x0419] = "Y",   [0x041A] = "K",   [0x041B] = "L",
  [0x041C] = "M",   [0x041D] = "N",   [0x041E] = "O",   [0x041F] = "P",
  [0x0420] = "R",   [0x0421] = "S",   [0x0422] = "T",   [0x0423] = "U",
  [0x0424] = "F",   [0x0425] = "Kh",  [0x0426] = "Ts",  [0x0427] = "Ch",
  [0x0428] = "Sh",  [0x0429] = "Shch",[0x042A] = "",    [0x042B] = "Y",
  [0x042C] = "",    [0x042D] = "E",   [0x042E] = "Yu",  [0x042F] = "Ya",
  -- Lowercase
  [0x0430] = "a",   [0x0431] = "b",   [0x0432] = "v",   [0x0433] = "g",
  [0x0434] = "d",   [0x0435] = "e",   [0x0436] = "zh",  [0x0437] = "z",
  [0x0438] = "i",   [0x0439] = "y",   [0x043A] = "k",   [0x043B] = "l",
  [0x043C] = "m",   [0x043D] = "n",   [0x043E] = "o",   [0x043F] = "p",
  [0x0440] = "r",   [0x0441] = "s",   [0x0442] = "t",   [0x0443] = "u",
  [0x0444] = "f",   [0x0445] = "kh",  [0x0446] = "ts",  [0x0447] = "ch",
  [0x0448] = "sh",  [0x0449] = "shch",[0x044A] = "",    [0x044B] = "y",
  [0x044C] = "",    [0x044D] = "e",   [0x044E] = "yu",  [0x044F] = "ya",
  -- Ukrainian extras
  [0x0490] = "G",   [0x0491] = "g",   -- Ґ ґ
  [0x0404] = "Ye",  [0x0454] = "ye",  -- Є є
  [0x0406] = "I",   [0x0456] = "i",   -- І і
  [0x0407] = "Yi",  [0x0457] = "yi",  -- Ї ї
  -- Common extra
  [0x0401] = "Yo",  [0x0451] = "yo",  -- Ё ё
}

-- Greek → Latin (simplified phonetic)
local greekToLatin = {
  -- Uppercase
  [0x0391] = "A",   [0x0392] = "B",   [0x0393] = "G",   [0x0394] = "D",
  [0x0395] = "E",   [0x0396] = "Z",   [0x0397] = "I",   [0x0398] = "Th",
  [0x0399] = "I",   [0x039A] = "K",   [0x039B] = "L",   [0x039C] = "M",
  [0x039D] = "N",   [0x039E] = "X",   [0x039F] = "O",   [0x03A0] = "P",
  [0x03A1] = "R",   [0x03A3] = "S",   [0x03A4] = "T",   [0x03A5] = "Y",
  [0x03A6] = "F",   [0x03A7] = "Ch",  [0x03A8] = "Ps",  [0x03A9] = "O",
  -- Lowercase
  [0x03B1] = "a",   [0x03B2] = "b",   [0x03B3] = "g",   [0x03B4] = "d",
  [0x03B5] = "e",   [0x03B6] = "z",   [0x03B7] = "i",   [0x03B8] = "th",
  [0x03B9] = "i",   [0x03BA] = "k",   [0x03BB] = "l",   [0x03BC] = "m",
  [0x03BD] = "n",   [0x03BE] = "x",   [0x03BF] = "o",   [0x03C0] = "p",
  [0x03C1] = "r",   [0x03C3] = "s",   [0x03C2] = "s",   [0x03C4] = "t",
  [0x03C5] = "y",   [0x03C6] = "f",   [0x03C7] = "ch",  [0x03C8] = "ps",
  [0x03C9] = "o",
}

-- Arabic → Latin (very simplified, practical romanization)
local arabicToLatin = {
  [0x0627] = "a",   -- ا alef
  [0x0628] = "b",   -- ب
  [0x062A] = "t",   -- ت
  [0x062B] = "th",  -- ث
  [0x062C] = "j",   -- ج
  [0x062D] = "h",   -- ح
  [0x062E] = "kh",  -- خ
  [0x062F] = "d",   -- د
  [0x0630] = "dh",  -- ذ
  [0x0631] = "r",   -- ر
  [0x0632] = "z",   -- ز
  [0x0633] = "s",   -- س
  [0x0634] = "sh",  -- ش
  [0x0635] = "s",   -- ص
  [0x0636] = "d",   -- ض
  [0x0637] = "t",   -- ط
  [0x0638] = "z",   -- ظ
  [0x0639] = "'",   -- ع
  [0x063A] = "gh",  -- غ
  [0x0641] = "f",   -- ف
  [0x0642] = "q",   -- ق
  [0x0643] = "k",   -- ك
  [0x0644] = "l",   -- ل
  [0x0645] = "m",   -- م
  [0x0646] = "n",   -- ن
  [0x0647] = "h",   -- ه
  [0x0648] = "w",   -- و
  [0x064A] = "y",   -- ي
  -- Hamza variants
  [0x0621] = "'",   -- ء
  [0x0623] = "a",   -- أ
  [0x0625] = "i",   -- إ
  [0x0624] = "u",   -- ؤ
  [0x0626] = "'",   -- ئ
  -- Taa marbuta, alef maqsura
  [0x0629] = "a",   -- ة
  [0x0649] = "a",   -- ى
  -- Common diacritics (skip — they're combining marks)
  [0x064B] = "",    -- fathatan
  [0x064C] = "",    -- dammatan
  [0x064D] = "",    -- kasratan
  [0x064E] = "",    -- fatha
  [0x064F] = "",    -- damma
  [0x0650] = "",    -- kasra
  [0x0651] = "",    -- shadda
  [0x0652] = "",    -- sukun
}

-- Japanese Katakana → Latin (simplified romaji)
local katakanaToLatin = {
  [0x30A2] = "a",   [0x30A4] = "i",   [0x30A6] = "u",   [0x30A8] = "e",   [0x30AA] = "o",
  [0x30AB] = "ka",  [0x30AD] = "ki",  [0x30AF] = "ku",  [0x30B1] = "ke",  [0x30B3] = "ko",
  [0x30B5] = "sa",  [0x30B7] = "shi", [0x30B9] = "su",  [0x30BB] = "se",  [0x30BD] = "so",
  [0x30BF] = "ta",  [0x30C1] = "chi", [0x30C4] = "tsu", [0x30C6] = "te",  [0x30C8] = "to",
  [0x30CA] = "na",  [0x30CB] = "ni",  [0x30CC] = "nu",  [0x30CD] = "ne",  [0x30CE] = "no",
  [0x30CF] = "ha",  [0x30D2] = "hi",  [0x30D5] = "fu",  [0x30D8] = "he",  [0x30DB] = "ho",
  [0x30DE] = "ma",  [0x30DF] = "mi",  [0x30E0] = "mu",  [0x30E1] = "me",  [0x30E2] = "mo",
  [0x30E4] = "ya",                     [0x30E6] = "yu",                     [0x30E8] = "yo",
  [0x30E9] = "ra",  [0x30EA] = "ri",  [0x30EB] = "ru",  [0x30EC] = "re",  [0x30ED] = "ro",
  [0x30EF] = "wa",                                                          [0x30F2] = "wo",
  [0x30F3] = "n",
  -- Long vowel mark
  [0x30FC] = "-",
}

-- ═══════════════════════════════════════════════════════════════════
-- Script detection ranges and option keys
-- ═══════════════════════════════════════════════════════════════════

local scriptDefs = {
  { name = "cyrillic",  optionKey = "transliterateCyrillic",  rangeStart = 0x0400, rangeEnd = 0x04FF, table = cyrillicToLatin },
  { name = "greek",     optionKey = "transliterateGreek",     rangeStart = 0x0370, rangeEnd = 0x03FF, table = greekToLatin },
  { name = "arabic",    optionKey = "transliterateArabic",    rangeStart = 0x0600, rangeEnd = 0x06FF, table = arabicToLatin },
  { name = "katakana",  optionKey = "transliterateKatakana",  rangeStart = 0x30A0, rangeEnd = 0x30FF, table = katakanaToLatin },
}

-- ═══════════════════════════════════════════════════════════════════
-- UTF-8 decoding helper
-- ═══════════════════════════════════════════════════════════════════

--- Iterate over UTF-8 codepoints in a string
--- Yields (startByte, endByte, codepoint) for each character
local function utf8codepoints(str)
  local i = 1
  local len = #str
  return function()
    if i > len then return nil end
    local b = str:byte(i)
    local cp, size
    if b < 0x80 then
      cp = b; size = 1
    elseif b < 0xC0 then
      -- continuation byte (shouldn't happen at start) — skip
      cp = b; size = 1
    elseif b < 0xE0 then
      size = 2
      if i + 1 > len then cp = b; size = 1
      else cp = (b - 0xC0) * 64 + (str:byte(i+1) - 0x80) end
    elseif b < 0xF0 then
      size = 3
      if i + 2 > len then cp = b; size = 1
      else cp = (b - 0xE0) * 4096 + (str:byte(i+1) - 0x80) * 64 + (str:byte(i+2) - 0x80) end
    else
      size = 4
      if i + 3 > len then cp = b; size = 1
      else cp = (b - 0xF0) * 262144 + (str:byte(i+1) - 0x80) * 4096 + (str:byte(i+2) - 0x80) * 64 + (str:byte(i+3) - 0x80) end
    end
    local startPos = i
    i = i + size
    return startPos, startPos + size - 1, cp
  end
end

-- ═══════════════════════════════════════════════════════════════════
-- Core transliteration function
-- ═══════════════════════════════════════════════════════════════════

--- Transliterate non-Latin characters in a UTF-8 string to Latin equivalents.
--- Only converts scripts that the user has enabled in options.
--- Characters without a mapping are kept as-is (e.g., CJK ideographs, emoji).
--- @param text string UTF-8 input text
--- @return string transliterated text
function Transliteration.process(text)
  if not text or #text == 0 then return text end

  -- Quick ASCII check — if all bytes are < 128, nothing to do
  local hasNonAscii = false
  for i = 1, #text do
    if text:byte(i) >= 0x80 then
      hasNonAscii = true
      break
    end
  end
  if not hasNonAscii then return text end

  -- Check which scripts are enabled
  local enabledScripts = {}
  for _, sd in ipairs(scriptDefs) do
    if modules.client_options.getOption(sd.optionKey) then
      enabledScripts[#enabledScripts + 1] = sd
    end
  end
  if #enabledScripts == 0 then return text end

  -- Process character by character
  local result = {}
  for startPos, endPos, cp in utf8codepoints(text) do
    local replaced = false
    for _, sd in ipairs(enabledScripts) do
      if cp >= sd.rangeStart and cp <= sd.rangeEnd then
        local mapped = sd.table[cp]
        if mapped ~= nil then
          result[#result + 1] = mapped
          replaced = true
        end
        break  -- codepoint is in this range, no need to check others
      end
    end
    if not replaced then
      result[#result + 1] = text:sub(startPos, endPos)
    end
  end

  return table.concat(result)
end

--- Check if transliteration is active (any script enabled)
function Transliteration.isActive()
  for _, sd in ipairs(scriptDefs) do
    if modules.client_options.getOption(sd.optionKey) then
      return true
    end
  end
  return false
end

-- ═══════════════════════════════════════════════════════════════════
-- Module lifecycle
-- ═══════════════════════════════════════════════════════════════════

function init()
  -- Module loaded — transliteration tables are ready.
  -- The actual processing is called from game_console when messages arrive.
end

function terminate()
  Transliteration = nil
end
