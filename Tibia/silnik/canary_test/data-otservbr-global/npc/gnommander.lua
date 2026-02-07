local internalNpcName = "Gnommander"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 493,
	lookHead = 59,
	lookBody = 57,
	lookLegs = 39,
	lookFeet = 38,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

local talkState = {}
local speech = {
	"npc.gnommander.speech_1",
	"npc.gnommander.speech_2",
	"npc.gnommander.speech_3",
	"npc.gnommander.speech_4",
	"npc.gnommander.speech_5",
	"npc.gnommander.speech_6",
	"npc.gnommander.speech_7",
}
npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if MsgContains(message, "commander") then
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_1")
	end

	if MsgContains(message, "reward") then
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_2")
	end

	if MsgContains(message, "spike") then
		return NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, speech, 4000)
	end

	if MsgContains(message, "worthy") then
		if player:getFamePoints() < 100 then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_3")
		end

		talkState[playerId] = "worthy"
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_4")
	end

	if talkState[playerId] == "worthy" then
		if MsgContains(message, "basic") then
			if getPlayerLevel(creature) < 25 then
				talkState[playerId] = nil
				return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_5")
			end

			if player:hasOutfit(player:getSex() == 0 and 575 or 574) then
				talkState[playerId] = nil
				return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_6")
			end

			talkState[playerId] = "basic"
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_7")
		elseif MsgContains(message, "first") then
			if getPlayerLevel(creature) < 50 then
				talkState[playerId] = nil
				return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_8")
			end

			if not player:hasOutfit(player:getSex() == 0 and 575 or 574) then
				talkState[playerId] = nil
				return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_9")
			end

			if player:hasOutfit(player:getSex() == 0 and 575 or 574, 1) then
				talkState[playerId] = nil
				return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_10")
			end

			talkState[playerId] = "first"
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_11")
		elseif MsgContains(message, "second") then
			if getPlayerLevel(creature) < 80 then
				talkState[playerId] = nil
				return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_12")
			end

			if not player:hasOutfit(player:getSex() == 0 and 575 or 574) then
				talkState[playerId] = nil
				return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_13")
			end

			if player:hasOutfit(player:getSex() == 0 and 575 or 574, 2) then
				talkState[playerId] = nil
				return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_14")
			end

			talkState[playerId] = "second"
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_15")
		end
	end

	if talkState[playerId] == "basic" then
		if MsgContains(message, "yes") then
			if not player:removeMoney(1000) then
				talkState[playerId] = nil
				return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_16")
			end
		end
		player:removeFamePoints(100)
		player:addOutfit(player:getSex() == 0 and 575 or 574)
		talkState[playerId] = nil
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_17")
	elseif talkState[playerId] == "first" then
		if MsgContains(message, "yes") then
			if not player:removeMoney(2000) then
				talkState[playerId] = nil
				return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_18")
			end
		end
		player:removeFamePoints(100)
		player:addOutfitAddon(player:getSex() == 0 and 575 or 574, 1)
		talkState[playerId] = nil
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_19")
	elseif talkState[playerId] == "second" then
		if MsgContains(message, "yes") then
			if not player:removeMoney(3000) then
				talkState[playerId] = nil
				return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_20")
			end
		end
		player:removeFamePoints(100)
		player:addOutfitAddon(player:getSex() == 0 and 575 or 574, 2)
		talkState[playerId] = nil
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnommander.say_21")
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gnommander.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
