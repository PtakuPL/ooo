local internalNpcName = "Zumtah"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 51,
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

local condition = Condition(CONDITION_OUTFIT)
condition:setOutfit({ lookType = 348 })
condition:setTicks(-1)

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "exit") then
		if player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.ZumtahStatus) ~= 1 then
			if npcHandler:getTopic(playerId) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_1")
				npcHandler:setTopic(playerId, 1)
			elseif npcHandler:getTopic(playerId) == 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_2")
				npcHandler:setTopic(playerId, 4)
			elseif npcHandler:getTopic(playerId) == 6 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_3")
				npcHandler:setTopic(playerId, 7)
			elseif npcHandler:getTopic(playerId) == 10 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_4")
				npcHandler:setTopic(playerId, 11)
			elseif npcHandler:getTopic(playerId) == 11 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_5")
				npcHandler:setTopic(playerId, 12)
			elseif npcHandler:getTopic(playerId) == 12 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_6")
				npcHandler:setTopic(playerId, 13)
			elseif npcHandler:getTopic(playerId) == 13 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.multi_3")
				npcHandler:setTopic(playerId, 14)
			elseif npcHandler:getTopic(playerId) == 14 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_7")
				npcHandler:setTopic(playerId, 0)
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.ZumtahStatus, 1)
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.PrisonReleaseStatus, 1)
				player:addCondition(condition)
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_8")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.PrisonReleaseStatus, 1)
			player:addCondition(condition)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_9")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_10")
			npcHandler:setTopic(playerId, 5)
		elseif npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_11")
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_12")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_13")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_14")
			npcHandler:setTopic(playerId, 9)
		end
	elseif MsgContains(message, "278") and npcHandler:getTopic(playerId) == 9 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_15")
		npcHandler:setTopic(playerId, 10)
	elseif (MsgContains(message, "164") or MsgContains(message, "89")) and npcHandler:getTopic(playerId) == 9 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zumtah.say_16")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end
--Basic
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, text = "I wait. I wait for someone like you to come here. I wait for them to grow disconsolate. I wait for them to despair. And I wait for them to die. Muhahaha." })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, text = "I am Zumtah, Zumtah the impeccable, Zumtah the marvellous, Zumtah the... the... eternal." })
keywordHandler:addAliasKeyword({ "djinn" })
keywordHandler:addAliasKeyword({ "zumtah" })
keywordHandler:addKeyword({ "zao" }, StdModule.say, { npcHandler = npcHandler, text = "The land you are currently dwelling in, human. Don't you have any sense of your surroundings?" })
keywordHandler:addKeyword({ "humans" }, StdModule.say, { npcHandler = npcHandler, text = "I have seen many of them. I have seen many of them die. In here, with me. Perhaps you will be pleased to meet them. Not long and you will join their ranks. Muhaha." })
keywordHandler:addKeyword({ "lizard" }, StdModule.say, { npcHandler = npcHandler, text = "Pesky creatures. Many of them have been brought here, many of them died here. Humans, lizards, beasts, they all die the same. Down here, with me. Muhahaha." })
keywordHandler:addKeyword({ "zalamon" }, StdModule.say, { npcHandler = npcHandler, text = "What? What do you mean by that?" })
keywordHandler:addKeyword({ "emperor" }, StdModule.say, { npcHandler = npcHandler, text = "Hmm, an old one. I don't care much about politics or power, as here, he has none. Here, only I have power. Muhaha." })
keywordHandler:addKeyword({ "resistance" }, StdModule.say, { npcHandler = npcHandler, text = "What are you talking about, such things do not matter down here. Down here alone, isolated and broken. Muhaha." })
npcHandler:setMessage(MESSAGE_GREET, "Another visitor to this constricted, cosy, calm realm, perfect except for an {exit}. Muhaha.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Muhahaha.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
