-- Arena PvP TalkAction
-- Commands: !arena [join|leave|stats|ranking|help] [mode]
-- Modes: 1v1, 2v2, 3v3, ffa, ctf, koth, lms, tournament
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

local arena = TalkAction("!arena")

local modeMap = {
["1v1"] = Arena.MODE_1V1,
["2v2"] = Arena.MODE_2V2,
["3v3"] = Arena.MODE_3V3,
["ffa"] = Arena.MODE_FFA,
["ctf"] = Arena.MODE_CTF,
["koth"] = Arena.MODE_KOTH,
["lms"] = Arena.MODE_LMS,
["tournament"] = Arena.MODE_TOURNAMENT,
}

-- i18n keys for mode names (resolved per player language)
local modeI18nKeys = {
[Arena.MODE_1V1] = "arena.mode.1v1",
[Arena.MODE_2V2] = "arena.mode.2v2",
[Arena.MODE_3V3] = "arena.mode.3v3",
[Arena.MODE_FFA] = "arena.mode.ffa",
[Arena.MODE_CTF] = "arena.mode.ctf",
[Arena.MODE_KOTH] = "arena.mode.koth",
[Arena.MODE_LMS] = "arena.mode.lms",
[Arena.MODE_TOURNAMENT] = "arena.mode.tournament",
}

local function getModeName(player, modeId)
local key = modeI18nKeys[modeId]
if key then
 player:getTranslation(key)
end
return "?"
end

local function showHelp(player)
local msg = player:getTranslation("arena.cmd.help.header") .. "\n"
msg = msg .. player:getTranslation("arena.cmd.help.join") .. "\n"
msg = msg .. player:getTranslation("arena.cmd.help.leave") .. "\n"
msg = msg .. player:getTranslation("arena.cmd.help.stats") .. "\n"
msg = msg .. player:getTranslation("arena.cmd.help.ranking") .. "\n"
msg = msg .. player:getTranslation("arena.cmd.help.history") .. "\n"
msg = msg .. player:getTranslation("arena.cmd.help.modes") .. "\n"
msg = msg .. player:getTranslation("arena.cmd.help.status")
player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

local function showModes(player)
local msg = player:getTranslation("arena.cmd.modes.header") .. "\n"
for name, id in pairs(modeMap) do
Size = Arena.getQueueSize(id)
ame = getModeName(player, id)
slation("arena.cmd.modes.entry", {name, modeName, tostring(qSize)}) .. "\n"
end
player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

local function showStats(player)
local stats = player:arenaGetStats()
if not stats then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.stats.no_profile")

end

local wr = (stats.wins + stats.losses > 0) and math.floor(stats.wins / (stats.wins + stats.losses) * 100) or 0
local kdr = (stats.totalDeaths > 0) and string.format("%.2f", stats.totalKills / stats.totalDeaths) or tostring(stats.totalKills)

local msg = player:getTranslation("arena.cmd.stats.header") .. "\n"
msg = msg .. player:getTranslation("arena.cmd.stats.mmr_line", {tostring(stats.mmr), tostring(stats.arenaPoints)}) .. "\n"
msg = msg .. player:getTranslation("arena.cmd.stats.record_line", {tostring(stats.wins), tostring(stats.losses), tostring(stats.draws), tostring(wr)}) .. "\n"
msg = msg .. player:getTranslation("arena.cmd.stats.streak_line", {tostring(stats.winStreak), tostring(stats.bestStreak)}) .. "\n"
msg = msg .. player:getTranslation("arena.cmd.stats.kd_line", {tostring(stats.totalKills), tostring(stats.totalDeaths), kdr}) .. "\n"
msg = msg .. player:getTranslation("arena.cmd.stats.damage_line", {tostring(stats.totalDamage), tostring(stats.totalHealing)})
player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

local function showRanking(player)
local entries = Arena.getTopRanking(20, 0)
if not entries or #entries == 0 then
dLocalizedTextMessage(MESSAGE_HOTKEY_PRESSED, "arena.cmd.ranking.empty")

end

local msg = player:getTranslation("arena.cmd.ranking.header") .. "\n"
msg = msg .. player:getTranslation("arena.cmd.ranking.columns") .. "\n"
for i, entry in ipairs(entries) do
g.format("%-4d %-20s %-6d %-5d %-5d %-6d\n",
try.name, entry.mmr, entry.wins, entry.losses, entry.bestStreak)
end
player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

local function showHistory(player)
local history = Arena.getPlayerHistory(player:getGuid(), 10)
if not history or #history == 0 then
dLocalizedTextMessage(MESSAGE_HOTKEY_PRESSED, "arena.cmd.history.empty")

end

local msg = player:getTranslation("arena.cmd.history.header") .. "\n"
for _, match in ipairs(history) do
nerTeam == match.playerTeam) and "arena.cmd.history.win" or "arena.cmd.history.loss"
slation(resultKey)
 = (match.mmrChange >= 0) and "+" or ""
g.format("[%s] %s | K/D: %d/%d | MMR: %s%d | %s\n",
ame, result, match.kills, match.deaths, sign, match.mmrChange,
d
player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

function arena.onSay(player, words, param)
if not player then
 false
end

local args = param:lower():split(" ")
local action = args[1] or "help"

if action == "join" then
ame = args[2]
ot modeName then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.join.usage")
 true
d

ame]
ot modeId then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.join.unknown_mode", {modeName})
 true
d

aIsInArena() then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.join.already_in_match")
 true
d

aIsInQueue() then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.join.already_in_queue")
 true
d


dLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.join.level_required", {"50"})
 true
d

aJoinQueue(modeId)

slatedMode = getModeName(player, modeId)
dLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "arena.cmd.join.success", {translatedMode})
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.join.failed")
d

elseif action == "leave" then
ot player:arenaIsInQueue() then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.leave.not_in_queue")
 true
d

aLeaveQueue()

dLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "arena.cmd.leave.success")
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.leave.failed")
d

elseif action == "stats" then
 == "ranking" or action == "rank" or action == "top" then
king(player)

elseif action == "history" then
 == "modes" then
 == "status" then
aSendStatus()

else
d

return true
end

arena:groupType("normal")
arena:register()
