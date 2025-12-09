local internalNpcName = "Aruda"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 140,
	lookHead = 96,
	lookBody = 81,
	lookLegs = 79,
	lookFeet = 95,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Hey there, up for a chat?" },
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

local price = {}

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	if Player(creature):getSex() == PLAYERSEX_FEMALE then
		npcHandler:setMessage(MESSAGE_GREET, "Oh, hello |PLAYERNAME|, your hair looks great! Who did it for you?")
		npcHandler:setTopic(playerId, 1)
	else
		npcHandler:setMessage(MESSAGE_GREET, "Oh, hello, handsome! It's a pleasure to meet you, |PLAYERNAME|. Gladly I have the time to {chat} a bit.")
		npcHandler:setTopic(playerId, nil)
	end
	price[playerId] = nil
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local Sex = player:getSex()
	if npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_1")
		npcHandler:setTopic(playerId, nil)
	elseif npcHandler:getTopic(playerId) == 2 then
		if player:removeMoneyBank(price[playerId]) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_2")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_3")
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		end
		npcHandler:setTopic(playerId, nil)
		price[playerId] = nil
	elseif npcHandler:getTopic(playerId) == 3 and player:removeItem(2906, 1) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_4")
		npcHandler:setTopic(playerId, nil)
	elseif npcHandler:getTopic(playerId) == 4 and (MsgContains(message, "spouse") or MsgContains(message, "girlfriend")) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_5")
		npcHandler:setTopic(playerId, 5)
	elseif npcHandler:getTopic(playerId) == 5 and MsgContains(message, "fruit") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_6")
		npcHandler:setTopic(playerId, nil)
	elseif MsgContains(message, "how") and MsgContains(message, "are") and MsgContains(message, "you") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_7")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "sell") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_8")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "job") or MsgContains(message, "chat") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_9")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "name") then
		if Sex == PLAYERSEX_FEMALE then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_10")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_11")
		end
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "aruda") then
		if Sex == PLAYERSEX_FEMALE then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_12")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_13")
		end
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "time") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_14")
		npcHandler:setTopic(playerId, 3)
	elseif MsgContains(message, "help") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_15")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "monster") or MsgContains(message, "dungeon") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_16")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "sewer") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_17")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "god") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_18")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "king") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_19")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 10
	elseif MsgContains(message, "sam") then
		if Sex == PLAYERSEX_FEMALE then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_20")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_21")
		end
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "benjamin") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_22")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "gorn") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_23")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "quentin") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_24")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "bozo") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_25")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "oswald") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_26")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "rumour") or MsgContains(message, "rumor") or MsgContains(message, "gossip") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_27")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "kiss") and Sex == PLAYERSEX_MALE then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_28")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 20
	elseif MsgContains(message, "weapon") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_29")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "magic") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_30")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "thief") or MsgContains(message, "theft") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_31")
		npcHandler:setTopic(playerId, nil)
		price[playerId] = nil
		npcHandler:removeInteraction(npc, creature)
		npcHandler:resetNpc(creature)
	elseif MsgContains(message, "tibia") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_32")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "castle") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_33")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "muriel") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_34")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "elane") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_35")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "marvik") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_36")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "gregor") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_37")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "noodles") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_38")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "dog") or MsgContains(message, "poodle") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_39")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "excalibug") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_40")
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 10
	elseif MsgContains(message, "partos") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_41")
		npcHandler:setTopic(playerId, 4)
		price[playerId] = nil
	elseif MsgContains(message, "yenny") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aruda.say_42")
		npcHandler:setTopic(playerId, nil)
		price[playerId] = nil
		npcHandler:removeInteraction(npc, creature)
		npcHandler:resetNpc(creature)
	end
	return true
end

npcHandler:setMessage(MESSAGE_WALKAWAY, "I hope to see you soon.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye, |PLAYERNAME|. I really hope we'll talk again soon.")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
