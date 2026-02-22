-- Arena Master NPC
-- Provides arena information, queue management, and shop via dialog
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

local internalNpcName = "Arena Master"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 150
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 131,
	lookHead = 95,
	lookBody = 116,
	lookLegs = 114,
	lookFeet = 95,
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

-- Greet / Farewell / Walkaway
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "arena.npc.greet")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "arena.npc.farewell")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "arena.npc.walkaway")

-- Mode info table
local modeInfo = {
	{ keyword = "1v1",        modeId = Arena.MODE_1V1,        descKey = "arena.mode.1v1.desc" },
	{ keyword = "2v2",        modeId = Arena.MODE_2V2,        descKey = "arena.mode.2v2.desc" },
	{ keyword = "3v3",        modeId = Arena.MODE_3V3,        descKey = "arena.mode.3v3.desc" },
	{ keyword = "ffa",        modeId = Arena.MODE_FFA,        descKey = "arena.mode.ffa.desc" },
	{ keyword = "ctf",        modeId = Arena.MODE_CTF,        descKey = "arena.mode.ctf.desc" },
	{ keyword = "koth",       modeId = Arena.MODE_KOTH,       descKey = "arena.mode.koth.desc" },
	{ keyword = "lms",        modeId = Arena.MODE_LMS,        descKey = "arena.mode.lms.desc" },
	{ keyword = "tournament", modeId = Arena.MODE_TOURNAMENT, descKey = "arena.mode.tournament.desc" },
}

-- "arena" keyword - main info
keywordHandler:addKeyword({ "arena" }, function(npc, player)
	if not npcHandler:checkInteraction(npc, player) then return false end
	NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.info")
	return true
end, {})

-- "modes" keyword - list all modes
keywordHandler:addKeyword({ "modes" }, function(npc, player)
	if not npcHandler:checkInteraction(npc, player) then return false end
	NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.modes_header")
	return true
end, {})

-- Per-mode keywords
for _, info in ipairs(modeInfo) do
	local descKey = info.descKey
	keywordHandler:addKeyword({ info.keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = descKey })
end

-- "join" keyword
keywordHandler:addKeyword({ "join" }, function(npc, player)
	if not npcHandler:checkInteraction(npc, player) then return false end
	local mode = Arena.MODE_1V1
	local canJoin, reason = ArenaConfig.canPlayerJoin(player)
	if not canJoin then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.cannot_join")
		return true
	end
	local success = player:arenaJoinQueue(mode)
	if success then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.joined_queue")
		ArenaLog.logQueueJoin(player, mode, player:arenaGetMMR())
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.join_failed")
	end
	return true
end, {})

-- "stats" keyword
keywordHandler:addKeyword({ "stats" }, function(npc, player)
	if not npcHandler:checkInteraction(npc, player) then return false end
	local stats = player:arenaGetStats()
	if not stats then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.no_stats")
		return true
	end
	NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.stats_header")
	local titleKey = ArenaConfig.getTitleI18nKey(ArenaConfig.getTitleForMMR(stats.mmr))
	NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.stats_mmr",
		{ tostring(stats.mmr), player:getTranslation(titleKey) })
	NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.stats_record",
		{ tostring(stats.wins), tostring(stats.losses), tostring(stats.draws) })
	NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.stats_points",
		{ tostring(stats.arenaPoints) })
	return true
end, {})

-- "ranking" keyword
keywordHandler:addKeyword({ "ranking" }, function(npc, player)
	if not npcHandler:checkInteraction(npc, player) then return false end
	local ranking = Arena.getTopRanking(10)
	if not ranking or #ranking == 0 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.ranking_empty")
		return true
	end
	NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.ranking_header")
	for i, entry in ipairs(ranking) do
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.ranking_entry",
			{ tostring(i), entry.playerName, tostring(entry.mmr) })
	end
	return true
end, {})

-- "shop" keyword
keywordHandler:addKeyword({ "shop" }, function(npc, player)
	if not npcHandler:checkInteraction(npc, player) then return false end
	NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.shop_header")
	for i, item in ipairs(ArenaConfig.shop) do
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.shop_entry",
			{ tostring(i), item.name, tostring(item.cost) })
	end
	NPC_LIB.i18n.npcSay(npcHandler, npc, player, "arena.npc.shop_hint")
	return true
end, {})

-- "help" keyword
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "arena.npc.help" })

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)
npcType:register(npcConfig)
