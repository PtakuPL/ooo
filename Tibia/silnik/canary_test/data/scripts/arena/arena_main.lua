-- Arena PvP - Main Arena Logic
-- Manages arena flow from Lua side: pre-match checks, post-match rewards,
-- announcements, and integration with C++ ArenaSystem
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

ArenaPvP = {}

-- ============================================
-- Pre-match validation (called before C++ creates match)
-- ============================================

--- Validate all players in a match group before starting
---@param players table Array of player objects
---@param mode number ArenaMode enum
---@return boolean, string?
function ArenaPvP.validateMatchGroup(players, mode)
for _, player in ipairs(players) do
Join, reason = ArenaConfig.canPlayerJoin(player)
ot canJoin then
 false, player:getName() .. ": " .. reason
d
end
return true
end

-- ============================================
-- Post-match processing
-- ============================================

--- Process rewards after a match ends
--- Called from C++ via Lua callback or directly
---@param matchData table {matchId, mode, winnerTeam, players: [{id, team, kills, deaths, damage, healing}]}
function ArenaPvP.processMatchRewards(matchData)
if not matchData or not matchData.players then

end

local maxKills = 0
local maxDamage = 0
local mvpId = nil

-- Find MVP (most kills, tiebreak by damage)
for _, pData in ipairs(matchData.players) do
maxKills and pData.damage > maxDamage) then
d
end

-- Award bonus points
for _, pData in ipairs(matchData.players) do
er then
usPoints = 0
usParts = {}

us
d #matchData.players > 2 then
usPoints = bonusPoints + ArenaConfig.rewards.mvp
sert(bonusParts, player:getTranslation("arena.reward.mvp", {tostring(ArenaConfig.rewards.mvp)}))
d

g spree bonus (3+ kills)

us = (pData.kills - 2) * ArenaConfig.rewards.killingSpree
usPoints = bonusPoints + spreeBonus
sert(bonusParts, player:getTranslation("arena.reward.spree", {tostring(spreeBonus)}))
d

us points
usPoints > 0 then
g.format(
a_players` SET `arena_points` = `arena_points` + %d WHERE `player_id` = %d",
usPoints, pData.id
usMsg = table.concat(bonusParts, " ")
dLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
a.reward.bonus", {bonusMsg, tostring(bonusPoints)})
d

aConfig.storage.lastArenaMatch, os.time())
d
end
end

-- ============================================
-- Announcements
-- ============================================

--- Broadcast an arena event to all online players (already translated message)
---@param message string
function ArenaPvP.broadcast(message)
for _, player in ipairs(Game.getPlayers()) do
dTextMessage(MESSAGE_EVENT_ADVANCE, message)
end
end

--- Broadcast a localized arena event to all online players
---@param key string i18n key
---@param args table? arguments
function ArenaPvP.broadcastLocalized(key, args)
for _, player in ipairs(Game.getPlayers()) do
dLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, key, args)
end
end

--- Announce match result
---@param mode number
---@param winnerNames table
---@param loserNames table
function ArenaPvP.announceResult(mode, winnerNames, loserNames)
-- Use first player to resolve mode name (broadcast translated per-player)
local modeI18nKeys = {
a.MODE_1V1] = "arena.mode.1v1",
a.MODE_2V2] = "arena.mode.2v2",
a.MODE_3V3] = "arena.mode.3v3",
a.MODE_FFA] = "arena.mode.ffa",
a.MODE_CTF] = "arena.mode.ctf",
a.MODE_KOTH] = "arena.mode.koth",
a.MODE_LMS] = "arena.mode.lms",
a.MODE_TOURNAMENT] = "arena.mode.tournament",
}

local modeKey = modeI18nKeys[mode] or "arena.mode.1v1"
local winners = table.concat(winnerNames, ", ")
local losers = table.concat(loserNames, ", ")

for _, player in ipairs(Game.getPlayers()) do
ame = player:getTranslation(modeKey)
dLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
a.result.announcement", {modeName, winners, losers})
end
end

--- Announce when a player achieves a new title
---@param player Player
---@param oldMMR number
---@param newMMR number
function ArenaPvP.checkTitlePromotion(player, oldMMR, newMMR)
local oldTitle = ArenaConfig.getTitleForMMR(oldMMR)
local newTitle = ArenaConfig.getTitleForMMR(newMMR)

if oldTitle ~= newTitle then
 key for the new title
aConfig.getTitleI18nKey(newTitle)
slatedTitle = player:getTranslation(titleKey)

dLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
a.title.promotion", {translatedTitle})

dex = 0
 ipairs(ArenaConfig.titles) do
ame == newTitle then
dex = i
d
d
aConfig.storage.arenaTitle, titleIndex)

 for high titles (per-player translated)
ewMMR >= 1800 then
 ipairs(Game.getPlayers()) do
slation(titleKey)
dLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
a.title.broadcast", {player:getName(), tTitle, tostring(newMMR)})
d
d
end
end

-- ============================================
-- Utility
-- ============================================

--- Get arena queue summary for display (for a specific player's language)
---@param player Player
---@return string
function ArenaPvP.getQueueSummary(player)
local modes = {
a.MODE_1V1, Arena.MODE_2V2, Arena.MODE_3V3,
a.MODE_FFA, Arena.MODE_LMS,
}

local modeI18nKeys = {
a.MODE_1V1] = "arena.mode.1v1",
a.MODE_2V2] = "arena.mode.2v2",
a.MODE_3V3] = "arena.mode.3v3",
a.MODE_FFA] = "arena.mode.ffa",
a.MODE_LMS] = "arena.mode.lms",
}

local lines = {}
local totalQueue = 0
for _, mode in ipairs(modes) do
t = Arena.getQueueSize(mode)
ueue + count
t > 0 then
ame = player:getTranslation(modeI18nKeys[mode])
sert(lines, string.format("  %s: %d", modeName, count))
d
end

local activeMatches = Arena.getActiveMatchCount()
local msg = player:getTranslation("arena.queue.summary", {tostring(totalQueue), tostring(activeMatches)}) .. "\n"
if #lines > 0 then
cat(lines, "\n")
else
slation("arena.queue.empty")
end

return msg
end
