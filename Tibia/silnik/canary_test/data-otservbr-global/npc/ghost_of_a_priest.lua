local internalNpcName = "Ghost Of A Priest"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 355,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") or MsgContains(message, "sceptre") then
		if player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 10 then
			if player:getPosition().z == 12 and player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.GhostOfAPriest01) < 1 and npcHandler:getTopic(playerId) ~= 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.multi_7")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.multi_8")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.multi_9")
				npcHandler:setTopic(playerId, 1)
			elseif npcHandler:getTopic(playerId) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.multi_5")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.multi_6")
				npcHandler:setTopic(playerId, 2)
			elseif player:getPosition().z == 13 and player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.GhostOfAPriest02) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.multi_4")
				npcHandler:setTopic(playerId, 3)
			elseif player:getPosition().z == 14 and player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.GhostOfAPriest03) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.multi_2")
				npcHandler:setTopic(playerId, 4)
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			if player:getMoney() + player:getBankBalance() >= 5000 then
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.GhostOfAPriest01, 1)
				player:removeMoneyBank(5000)
				player:addItem(11368, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.say_1")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:getMoney() + player:getBankBalance() >= 5000 then
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.GhostOfAPriest02, 1)
				player:removeMoneyBank(5000)
				player:addItem(11369, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.say_2")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:getMoney() + player:getBankBalance() >= 5000 then
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.GhostOfAPriest03, 1)
				player:removeMoneyBank(5000)
				player:addItem(11370, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.say_3")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ghost_of_a_priest.say_4")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end
--Basic
keywordHandler:addKeyword({ "mortal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_1" })
keywordHandler:addKeyword({ "guardians" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_2" })
keywordHandler:addKeyword({ "secrets" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_3" })
keywordHandler:addKeyword({ "lore" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_4" })
keywordHandler:addKeyword({ "relics" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_5" })
keywordHandler:addKeyword({ "left" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ghost_of_a_priest.stdmod_20",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_6" })
keywordHandler:addKeyword({ "banuta" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_7" })
keywordHandler:addKeyword({ "apes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_8" })
keywordHandler:addKeyword({ "redeem" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ghost_of_a_priest.stdmod_21",
})
keywordHandler:addKeyword({ "dragon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_9" })
keywordHandler:addKeyword({ "corruption" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_10" })
keywordHandler:addKeyword({ "zalamon" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ghost_of_a_priest.stdmod_22",
})
keywordHandler:addKeyword({ "snake" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ghost_of_a_priest.stdmod_23",
})
keywordHandler:addAliasKeyword({ "gods" })
keywordHandler:addKeyword({ "egg stealers" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_11" })
keywordHandler:addKeyword({ "birthright" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ghost_of_a_priest.stdmod_24",
})
keywordHandler:addKeyword({ "decline" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_12" })
keywordHandler:addKeyword({ "false born" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_13" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_14" })
keywordHandler:addKeyword({ "serpent spawn" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_15" })
keywordHandler:addKeyword({ "lizard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_16" })
keywordHandler:addKeyword({ "worthy" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ghost_of_a_priest.stdmod_25",
})
keywordHandler:addKeyword({ "creatures" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_17" })
keywordHandler:addKeyword({ "temple" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_18" })
keywordHandler:addKeyword({ "zao" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ghost_of_a_priest.stdmod_19" })
keywordHandler:addKeyword({ "left" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ghost_of_a_priest.stdmod_26",
})
keywordHandler:addKeyword({ "slumber" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ghost_of_a_priest.stdmod_27",
})
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.ghost_of_a_priest.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.ghost_of_a_priest.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
