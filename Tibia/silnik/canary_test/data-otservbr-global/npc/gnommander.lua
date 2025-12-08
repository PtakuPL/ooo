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
	"I'm the operating commander of the Spike, the latest great accomplishment of the gnomish race.",
	"The Spike is a crystal structure, created by our greatest crystal experts. It has grown from a crystal the size of my fist to the structure you see here and now.",
	"Of course this did not happen from one day to the other. It's the fruit of the work of several gnomish generations. Its purpose has changed in the course of time.",
	"At first it was conceived as a fast growing resource node. Then it was planned to become the prototype of a new type of high security base.",
	"Now it has become a military base and a weapon. With our foes occupied elsewhere, we can prepare our strike into the depths of the earth.",
	"This crystal can withstand extreme pressure and temperature, and it's growing deeper and deeper even as we speak.",
	"The times of the fastest growth have come to an end, however, and we have to slow down in order not to risk the structural integrity of the Spike. But we are on our way and have to do everything possible to defend the Spike.",
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
		return npcHandler:sayLocalized("npc.gnommander.im_responsible_for_1", npc, creature)
	end

	if MsgContains(message, "reward") then
		return npcHandler:sayLocalized("npc.gnommander.i_can_sell_2", npc, creature)
	end

	if MsgContains(message, "spike") then
		return npcHandler:say(speech, npc, creature)
	end

	if MsgContains(message, "worthy") then
		if player:getFamePoints() < 100 then
			return npcHandler:sayLocalized("npc.gnommander.you_are_not_3", npc, creature)
		end

		talkState[playerId] = "worthy"
		return npcHandler:sayLocalized("npc.gnommander.you_can_acquire_4", npc, creature)
	end

	if talkState[playerId] == "worthy" then
		if MsgContains(message, "basic") then
			if getPlayerLevel(creature) < 25 then
				talkState[playerId] = nil
				return npcHandler:sayLocalized("npc.gnommander.you_do_not_5", npc, creature)
			end

			if player:hasOutfit(player:getSex() == 0 and 575 or 574) then
				talkState[playerId] = nil
				return npcHandler:sayLocalized("npc.gnommander.you_already_have_6", npc, creature)
			end

			talkState[playerId] = "basic"
			return npcHandler:sayLocalized("npc.gnommander.do_you_want_7", npc, creature)
		elseif MsgContains(message, "first") then
			if getPlayerLevel(creature) < 50 then
				talkState[playerId] = nil
				return npcHandler:sayLocalized("npc.gnommander.you_do_not_8", npc, creature)
			end

			if not player:hasOutfit(player:getSex() == 0 and 575 or 574) then
				talkState[playerId] = nil
				return npcHandler:sayLocalized("npc.gnommander.you_do_not_9", npc, creature)
			end

			if player:hasOutfit(player:getSex() == 0 and 575 or 574, 1) then
				talkState[playerId] = nil
				return npcHandler:sayLocalized("npc.gnommander.you_already_have_10", npc, creature)
			end

			talkState[playerId] = "first"
			return npcHandler:sayLocalized("npc.gnommander.do_you_want_11", npc, creature)
		elseif MsgContains(message, "second") then
			if getPlayerLevel(creature) < 80 then
				talkState[playerId] = nil
				return npcHandler:sayLocalized("npc.gnommander.you_do_not_12", npc, creature)
			end

			if not player:hasOutfit(player:getSex() == 0 and 575 or 574) then
				talkState[playerId] = nil
				return npcHandler:sayLocalized("npc.gnommander.you_do_not_13", npc, creature)
			end

			if player:hasOutfit(player:getSex() == 0 and 575 or 574, 2) then
				talkState[playerId] = nil
				return npcHandler:sayLocalized("npc.gnommander.you_already_have_14", npc, creature)
			end

			talkState[playerId] = "second"
			return npcHandler:sayLocalized("npc.gnommander.do_you_want_15", npc, creature)
		end
	end

	if talkState[playerId] == "basic" then
		if MsgContains(message, "yes") then
			if not player:removeMoney(1000) then
				talkState[playerId] = nil
				return npcHandler:sayLocalized("npc.gnommander.you_do_not_16", npc, creature)
			end
		end
		player:removeFamePoints(100)
		player:addOutfit(player:getSex() == 0 and 575 or 574)
		talkState[playerId] = nil
		return npcHandler:sayLocalized("npc.gnommander.here_it_is_17", npc, creature)
	elseif talkState[playerId] == "first" then
		if MsgContains(message, "yes") then
			if not player:removeMoney(2000) then
				talkState[playerId] = nil
				return npcHandler:sayLocalized("npc.gnommander.you_do_not_18", npc, creature)
			end
		end
		player:removeFamePoints(100)
		player:addOutfitAddon(player:getSex() == 0 and 575 or 574, 1)
		talkState[playerId] = nil
		return npcHandler:sayLocalized("npc.gnommander.here_it_is_19", npc, creature)
	elseif talkState[playerId] == "second" then
		if MsgContains(message, "yes") then
			if not player:removeMoney(3000) then
				talkState[playerId] = nil
				return npcHandler:sayLocalized("npc.gnommander.you_do_not_20", npc, creature)
			end
		end
		player:removeFamePoints(100)
		player:addOutfitAddon(player:getSex() == 0 and 575 or 574, 2)
		talkState[playerId] = nil
		return npcHandler:sayLocalized("npc.gnommander.here_it_is_21", npc, creature)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hi there! Welcome to the spike.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
