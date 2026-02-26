local internalNpcName = "Halvar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 143,
	lookHead = 3,
	lookBody = 77,
	lookLegs = 78,
	lookFeet = 39,
	lookAddons = 1,
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

keywordHandler:addKeyword({ "rules" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.halvar.stdmod_1" })
keywordHandler:addKeyword({ "difficulties" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.halvar.stdmod_2" })
keywordHandler:addKeyword({ "levels" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.halvar.stdmod_3" })
keywordHandler:addKeyword({ "difficulty" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.halvar.stdmod_4" })
keywordHandler:addKeyword({ "greenhorn" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.halvar.stdmod_5" })
keywordHandler:addKeyword({ "scrapper" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.halvar.stdmod_6" })
keywordHandler:addKeyword({ "warlord" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.halvar.stdmod_7" })
keywordHandler:addKeyword({ "fee" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.halvar.stdmod_8" })
keywordHandler:addKeyword({ "die" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.halvar.stdmod_9" })
keywordHandler:addKeyword({ "general" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.halvar.stdmod_10" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.halvar.stdmod_11" })
keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.halvar.stdmod_12" })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local arenaId = player:getStorageValue(Storage.Quest.U8_0.BarbarianArena.Arena)
	if MsgContains(message, "fight") or MsgContains(message, "pit") or MsgContains(message, "challenge") or MsgContains(message, "arena") then
		if player:getStorageValue(Storage.Quest.U8_0.BarbarianArena.PitDoor) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.halvar.say_13")
			return true
		end

		if arenaId < 1 then
			arenaId = 1
			player:setStorageValue(Storage.Quest.U8_0.BarbarianArena.Arena, arenaId)
		end

		if ARENA[arenaId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.halvar.say_1", { ARENA[arenaId].name, ARENA[arenaId].price })
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.halvar.say_15")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			if not ARENA[arenaId] then
				npcHandler:setTopic(playerId, 0)
				return true
			end

			if player:removeMoneyBank(ARENA[arenaId].price) then
				player:setStorageValue(Storage.Quest.U8_0.BarbarianArena.PitDoor, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.halvar.say_16")

				local cStorage = ARENA[arenaId].questLog
				if player:getStorageValue(cStorage) ~= 1 then
					player:setStorageValue(cStorage, 1)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.halvar.say_17")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.halvar.say_18")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.halvar.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
