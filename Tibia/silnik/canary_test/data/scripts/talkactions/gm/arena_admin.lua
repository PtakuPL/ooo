-- Arena PvP - GM Commands
-- Admin/GM commands for arena management
-- Usage: !arena-admin <subcommand> [args]
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

local arenaAdmin = TalkAction("!arena-admin")

function arenaAdmin.onSay(player, words, param)
if not player then
 false
end

-- GM only
if player:getAccountType() < ACCOUNT_TYPE_GAMEMASTER then
 false
end

local args = param:lower():split(" ")
local action = args[1] or "help"

if action == "info" then
a system status
a.getActiveMatchCount()
slation("arena.admin.info.header") .. "\n"
slation("arena.admin.info.active_matches", {tostring(activeMatches)}) .. "\n"

a.MODE_1V1, Arena.MODE_2V2, Arena.MODE_3V3,
a.MODE_FFA, Arena.MODE_LMS
slation("arena.admin.info.queue") .. "\n"
Keys = {
a.MODE_1V1] = "arena.mode.1v1",
a.MODE_2V2] = "arena.mode.2v2",
a.MODE_3V3] = "arena.mode.3v3",
a.MODE_FFA] = "arena.mode.ffa",
a.MODE_LMS] = "arena.mode.lms",
 ipairs(modes) do
t = Arena.getQueueSize(mode)
ame = player:getTranslation(modeI18nKeys[mode])
.. modeName .. ": " .. count .. "\n"
d

dTextMessage(MESSAGE_HOTKEY_PRESSED, msg)

elseif action == "stats" then
ame = args[2]
ot targetName then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.stats.usage")
 true
d

ame)
ot target then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.stats.not_found", {targetName})
 true
d

aGetStats()
ot stats then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.stats.no_profile", {targetName})
 true
d

ame = ArenaConfig.getTitleForMMR(stats.mmr)
aConfig.getTitleI18nKey(titleName)
slatedTitle = player:getTranslation(titleKey)

slation("arena.admin.stats.header", {target:getName()}) .. "\n"
slation("arena.admin.stats.mmr_line", {tostring(stats.mmr), translatedTitle}) .. "\n"
slation("arena.record.format", {tostring(stats.wins), tostring(stats.losses), tostring(stats.draws), tostring(ArenaConfig.getWinRate(stats))}) .. "\n"
slation("arena.admin.stats.kd_line", {tostring(stats.totalKills), tostring(stats.totalDeaths), ArenaConfig.formatKDR(stats.totalKills, stats.totalDeaths)}) .. "\n"
slation("arena.admin.stats.points", {tostring(stats.arenaPoints)}) .. "\n"
slation("arena.admin.stats.streak", {tostring(stats.winStreak), tostring(stats.bestStreak)})
dTextMessage(MESSAGE_HOTKEY_PRESSED, msg)

elseif action == "setmmr" then
testing)
ame = args[2]
ewMMR = tonumber(args[3])
ot targetName or not newMMR then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.setmmr.usage")
 true
d

ame)
ot target then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.player_not_online")
 true
d

g.format(
a_players` SET `mmr` = %d WHERE `player_id` = %d",
ewMMR, target:getGuid()
dLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
a.admin.setmmr.success", {target:getName(), tostring(newMMR)})

elseif action == "addpoints" then
a points
ame = args[2]
ts = tonumber(args[3])
ot targetName or not points then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.addpoints.usage")
 true
d

ame)
ot target then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.player_not_online")
 true
d

g.format(
a_players` SET `arena_points` = `arena_points` + %d WHERE `player_id` = %d",
ts, target:getGuid()
dLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
a.admin.addpoints.success", {tostring(points), target:getName()})

elseif action == "reset" then
a stats
ame = args[2]
ot targetName then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.reset.usage")
 true
d

ame)
ot target then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.player_not_online")
 true
d

g.format(
a_players` SET `mmr` = 1000, `wins` = 0, `losses` = 0, `draws` = 0, " ..
_streak` = 0, `best_streak` = 0, `total_damage` = 0, `total_healing` = 0, " ..
a_points` = 0 WHERE `player_id` = %d",
dLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
a.admin.reset.success", {target:getName()})

elseif action == "broadcast" then
d arena announcement
"broadcast "
d message ~= "" then
aPvP.broadcast("[Arena] " .. message)
dLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "arena.admin.broadcast.sent")
d

else
slation("arena.admin.help.header") .. "\n"
slation("arena.admin.help.info") .. "\n"
slation("arena.admin.help.stats") .. "\n"
slation("arena.admin.help.setmmr") .. "\n"
slation("arena.admin.help.addpoints") .. "\n"
slation("arena.admin.help.reset") .. "\n"
slation("arena.admin.help.broadcast")
dTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

return true
end

arenaAdmin:groupType("gamemaster")
arenaAdmin:register()
