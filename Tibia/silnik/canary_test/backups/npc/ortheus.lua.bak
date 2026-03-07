local internalNpcName = "Ortheus"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 153,
	lookHead = 40,
	lookBody = 121,
	lookLegs = 121,
	lookFeet = 116,
	lookAddons = 0,
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

local BloodBrothers = Storage.Quest.U8_4.BloodBrothers
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()
	if message == "cookie" then
		if player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission02) == 1 and player:getItemCount(8199) > 0 and player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Ortheus) < 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ortheus.say_1")
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ortheus.say_2")
		end
	elseif message == "yes" then
		if npcHandler:getTopic(playerId) == 1 and player:removeItem(8199, 1) then -- garlic cookie
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ortheus.say_3")
			player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Ortheus, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:removeItem(2880, 17) then -- mug of tea
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ortheus.say_4")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ortheus.say_5")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif message == "tea" then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ortheus.say_6")
		npcHandler:setTopic(playerId, 2)
	elseif message == "no" then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ortheus.say_7")
			npcHandler:setTopic(playerId, 0)
		end
	end
end
--Basic
keywordHandler:addKeyword({ "magicians" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_1" })
keywordHandler:addKeyword({ "live" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_2" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_3" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_4" })
keywordHandler:addKeyword({ "vampire" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_5" })
keywordHandler:addKeyword({ "blood" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_6" })
keywordHandler:addKeyword({ "julius" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_7" })
keywordHandler:addKeyword({ "armenius" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_8" })
keywordHandler:addKeyword({ "maris" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_9" })
keywordHandler:addKeyword({ "lisander" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_10" })
keywordHandler:addKeyword({ "serafin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_11" })
keywordHandler:addKeyword({ "yalahar" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_12" })
keywordHandler:addKeyword({ "quarter" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_13" })
keywordHandler:addKeyword({ "alori mort" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_14" }, function(player)
	return player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission03) == 1
end)
keywordHandler:addKeyword({ "reward" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_15" })
keywordHandler:addKeyword({ "augur" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_16" })
keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ortheus.stdmod_17" })
keywordHandler:addAliasKeyword({ "quest" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.ortheus.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
