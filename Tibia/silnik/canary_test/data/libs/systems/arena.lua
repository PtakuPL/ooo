-- Arena PvP System - Configuration & Helpers
-- Loaded via data/libs/systems/load.lua
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

ArenaConfig = {
-- Minimum level to join arena
minLevel = 50,

-- Cooldown between arena joins (seconds)
joinCooldownSeconds = 30,

-- Storage keys
storage = {
aMatch = 960001,  -- timestamp of last match
aWins = 960002,
aTitle = 960003,      -- current arena title ID
alMMR = 960004,
},

-- Arena Points rewards per result
rewards = {
 = 25,
       -- extra for MVP (most kills/damage)
in match
gSpree = 3, -- per kill in spree (3+)
},

-- MMR settings
mmr = {
itial = 1000,
GainOnWin = 10,
Defeat = -30,
},

-- Mode i18n key mapping (internal name -> i18n key)
modeI18nKeys = {
a.MODE_1V1] = "arena.mode.1v1",
a.MODE_2V2] = "arena.mode.2v2",
a.MODE_3V3] = "arena.mode.3v3",
a.MODE_FFA] = "arena.mode.ffa",
a.MODE_CTF] = "arena.mode.ctf",
a.MODE_KOTH] = "arena.mode.koth",
a.MODE_LMS] = "arena.mode.lms",
a.MODE_TOURNAMENT] = "arena.mode.tournament",
},

-- Mode descriptions i18n keys
modeDescI18nKeys = {
a.MODE_1V1] = "arena.mode.1v1.desc",
a.MODE_2V2] = "arena.mode.2v2.desc",
a.MODE_3V3] = "arena.mode.3v3.desc",
a.MODE_FFA] = "arena.mode.ffa.desc",
a.MODE_CTF] = "arena.mode.ctf.desc",
a.MODE_KOTH] = "arena.mode.koth.desc",
a.MODE_LMS] = "arena.mode.lms.desc",
a.MODE_TOURNAMENT] = "arena.mode.tournament.desc",
},

-- Arena titles based on MMR (internal name maps to i18n key)
titles = {
MMR = 0,    name = "Novice",     i18nKey = "arena.title.novice" },
MMR = 1100, name = "Apprentice",  i18nKey = "arena.title.apprentice" },
MMR = 1200, name = "Contender",   i18nKey = "arena.title.contender" },
MMR = 1300, name = "Fighter",     i18nKey = "arena.title.fighter" },
MMR = 1400, name = "Warrior",     i18nKey = "arena.title.warrior" },
MMR = 1500, name = "Veteran",     i18nKey = "arena.title.veteran" },
MMR = 1600, name = "Elite",       i18nKey = "arena.title.elite" },
MMR = 1700, name = "Champion",    i18nKey = "arena.title.champion" },
MMR = 1800, name = "Gladiator",   i18nKey = "arena.title.gladiator" },
MMR = 2000, name = "Legend",      i18nKey = "arena.title.legend" },
MMR = 2200, name = "Mythic",      i18nKey = "arena.title.mythic" },
MMR = 2500, name = "Immortal",    i18nKey = "arena.title.immortal" },
},

-- Reward shop items (arena points cost) with i18n keys
shop = {
ame = "Arena Trophy (Small)", i18nKey = "arena.shop.item.trophy_small",    itemId = 5805, cost = 100, category = "decoration" },
ame = "Arena Trophy (Large)", i18nKey = "arena.shop.item.trophy_large",    itemId = 5806, cost = 250, category = "decoration" },
ame = "Gladiator Shield",     i18nKey = "arena.shop.item.gladiator_shield", itemId = 2536, cost = 500, category = "equipment" },
ame = "Arena Amulet",         i18nKey = "arena.shop.item.arena_amulet",     itemId = 2125, cost = 300, category = "equipment" },
},
}

-- ============================================
-- Helper functions
-- ============================================

--- Get arena title internal name for a given MMR
---@param mmr number
---@return string internal title name
function ArenaConfig.getTitleForMMR(mmr)
local title = "Novice"
for _, t in ipairs(ArenaConfig.titles) do
MMR then
ame
d
end
return title
end

--- Get i18n key for a title by its internal name
---@param titleName string internal name (e.g. "Novice", "Champion")
---@return string i18n key
function ArenaConfig.getTitleI18nKey(titleName)
for _, t in ipairs(ArenaConfig.titles) do
ame == titleName then
 t.i18nKey
d
end
return "arena.title.novice"
end

--- Get translated mode name for a player
---@param player Player
---@param modeId number
---@return string
function ArenaConfig.getModeName(player, modeId)
local key = ArenaConfig.modeI18nKeys[modeId]
if key and player then
 player:getTranslation(key)
end
-- Fallback for non-player context
local fallback = {
a.MODE_1V1] = "1v1 Duel",
a.MODE_2V2] = "2v2 Team",
a.MODE_3V3] = "3v3 Team",
a.MODE_FFA] = "Free For All",
a.MODE_CTF] = "Capture The Flag",
a.MODE_KOTH] = "King of the Hill",
a.MODE_LMS] = "Last Man Standing",
a.MODE_TOURNAMENT] = "Tournament",
}
return fallback[modeId] or "Unknown"
end

--- Get translated title for a player
---@param player Player
---@param mmr number
---@return string
function ArenaConfig.getTranslatedTitle(player, mmr)
local titleName = ArenaConfig.getTitleForMMR(mmr)
local key = ArenaConfig.getTitleI18nKey(titleName)
return player:getTranslation(key)
end

--- Calculate win rate
---@param stats table
---@return number
function ArenaConfig.getWinRate(stats)
if not stats then return 0 end
local total = stats.wins + stats.losses
return (total > 0) and math.floor(stats.wins / total * 100) or 0
end

--- Check if player meets requirements to join arena
--- Returns i18n key as error message for translation
---@param player Player
---@return boolean, string? -- success, i18n error key
---@return table? -- args for the error key
function ArenaConfig.canPlayerJoin(player)
if not player then
 false, player:getTranslation("arena.check.player_not_found")
end

if player:getLevel() < ArenaConfig.minLevel then
 false, player:getTranslation("arena.check.level_required", {tostring(ArenaConfig.minLevel)})
end

if player:arenaIsInArena() then
 false, player:getTranslation("arena.check.already_in_match")
end

if player:arenaIsInQueue() then
 false, player:getTranslation("arena.check.already_in_queue")
end

-- Cooldown check
local lastMatch = player:getStorageValue(ArenaConfig.storage.lastArenaMatch)
if lastMatch > 0 then
ce = os.time() - lastMatch
ce < ArenaConfig.joinCooldownSeconds then
ing = ArenaConfig.joinCooldownSeconds - timeSince
 false, player:getTranslation("arena.check.cooldown", {tostring(remaining)})
d
end

-- Can't join during combat
if player:getCondition(CONDITION_INFIGHT) then
 false, player:getTranslation("arena.check.in_combat")
end

return true
end

--- Format a win/loss record string (i18n)
---@param player Player
---@param stats table
---@return string
function ArenaConfig.formatRecord(player, stats)
if not stats then
 player:getTranslation("arena.check.no_stats")
end
local wr = ArenaConfig.getWinRate(stats)
return player:getTranslation("arena.record.format",
g(stats.wins), tostring(stats.losses), tostring(stats.draws), tostring(wr)})
end

--- Format KDR string
---@param kills number
---@param deaths number
---@return string
function ArenaConfig.formatKDR(kills, deaths)
if deaths > 0 then
 string.format("%.2f", kills / deaths)
end
return tostring(kills)
end
