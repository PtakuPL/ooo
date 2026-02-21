local internalNpcName = "Arena Master"
local npcType = Game.createNpcType("Arena Master")
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 0

npcConfig.outfit = {
lookType = 160,
lookHead = 114,
lookBody = 119,
lookLegs = 114,
lookFeet = 114,
lookAddons = 3,
}

npcConfig.flags = {
floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
npcHandler:onCloseChannel(npc, creature)
end

-- Arena mode info table
local modeInfo = {
{ name = "1v1", id = Arena.MODE_1V1, i18nKey = "arena.mode.1v1", descKey = "arena.mode.1v1.desc" },
{ name = "2v2", id = Arena.MODE_2V2, i18nKey = "arena.mode.2v2", descKey = "arena.mode.2v2.desc" },
{ name = "3v3", id = Arena.MODE_3V3, i18nKey = "arena.mode.3v3", descKey = "arena.mode.3v3.desc" },
{ name = "ffa", id = Arena.MODE_FFA, i18nKey = "arena.mode.ffa", descKey = "arena.mode.ffa.desc" },
{ name = "lms", id = Arena.MODE_LMS, i18nKey = "arena.mode.lms", descKey = "arena.mode.lms.desc" },
}

local function creatureSayCallback(npc, creature, type, message)
local player = Player(creature)
local playerId = player:getId()

if not npcHandler:checkInteraction(npc, creature) then
 false
end

-- Greeting response
if MsgContains(message, "arena") or MsgContains(message, "fight") then
PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.welcome")
pcHandler:setTopic(playerId, 1)
 true
end

-- Show available modes
if MsgContains(message, "modes") or MsgContains(message, "list") then
slation("arena.npc.modes.header") .. "\n"
 ipairs(modeInfo) do
Size = Arena.getQueueSize(mode.id)
ame = player:getTranslation(mode.i18nKey)
mode.name .. "}: " .. modeName .. " (" .. qSize .. " in queue)\n"
d
slation("arena.npc.modes.join_hint")
pcHandler:say(msg, npc, creature)
 true
end

-- Join queue
if MsgContains(message, "join") then
il
 ipairs(modeInfo) do
tains(message, mode.name) then
d
d

ot selectedMode then
PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.join.which_mode")
 true
d

aIsInArena() then
PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.join.already_in_match")
 true
d

aIsInQueue() then
PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.join.already_in_queue")
 true
d


PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.join.level_required", {"50"})
 true
d

aJoinQueue(selectedMode.id)

ame = player:getTranslation(selectedMode.i18nKey)
PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.join.success", {modeName})
PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.join.failed")
d
 true
end

-- Leave queue
if MsgContains(message, "leave") or MsgContains(message, "quit") then
ot player:arenaIsInQueue() then
PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.leave.not_in_queue")
 true
d

aLeaveQueue()

PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.leave.success")
PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.leave.failed")
d
 true
end

-- Show stats
if MsgContains(message, "stats") or MsgContains(message, "score") then
aGetStats()
ot stats then
PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.stats.empty")
 true
d

s + stats.losses > 0) and math.floor(stats.wins / (stats.wins + stats.losses) * 100) or 0
slation("arena.npc.stats.header") .. "\n"
slation("arena.npc.stats.mmr_line", {tostring(stats.mmr), tostring(stats.arenaPoints)}) .. "\n"
slation("arena.npc.stats.record_line", {tostring(stats.wins), tostring(stats.losses), tostring(stats.draws), tostring(wr)}) .. "\n"
slation("arena.npc.stats.streak_line", {tostring(stats.winStreak), tostring(stats.bestStreak)}) .. "\n"
slation("arena.npc.stats.kd_line", {tostring(stats.totalKills), tostring(stats.totalDeaths)})
pcHandler:say(msg, npc, creature)
 true
end

-- Show ranking
if MsgContains(message, "ranking") or MsgContains(message, "rank") or MsgContains(message, "top") then
tries = Arena.getTopRanking(10, 0)
ot entries or #entries == 0 then
PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.ranking.empty")
 true
d

slation("arena.npc.ranking.header") .. "\n"
try in ipairs(entries) do
" .. entry.name .. " - MMR: " .. entry.mmr .. " (" .. entry.wins .. "W/" .. entry.losses .. "L)\n"
d
pcHandler:say(msg, npc, creature)
 true
end

-- Show status
if MsgContains(message, "status") then
aGetState()
a.npc.status.idle"
a.STATE_IN_QUEUE then
a.npc.status.in_queue"
a.STATE_IN_MATCH then
a.npc.status.in_match"
d

slation(stateKey)
a.getActiveMatchCount()
slation("arena.npc.status.your_status", {stateStr}) .. "\n"
slation("arena.npc.status.active_matches", {tostring(activeMatches)})
pcHandler:say(msg, npc, creature)
 true
end

-- Job/info
if MsgContains(message, "job") or MsgContains(message, "help") then
PC_LIB.i18n.npcSay(npcHandler, npc, creature, "arena.npc.job")
 true
end

return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "arena.npc.greet_msg")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "arena.npc.farewell_msg")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "arena.npc.walkaway_msg")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcType:register(npcConfig)
