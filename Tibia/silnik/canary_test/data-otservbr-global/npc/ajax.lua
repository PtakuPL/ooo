local internalNpcName = "Ajax"
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
	lookHead = 78,
	lookBody = 101,
	lookLegs = 120,
	lookFeet = 94,
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

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 2 and player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddonWaitTimer) < os.time() then
		npcHandler:setMessage(MESSAGE_GREET, "You back. You know, you right. Brother is right. Fist not always good. Tell him that!")
		player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 3)
	else
		npcHandler:setMessage(MESSAGE_GREET, "Whatcha do in my place?")
	end

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- PREQUEST
	if MsgContains(message, "mine") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 1 then
			npcHandler:sayLocalized("npc.ajax.yours_what_is_1", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:sayLocalized("npc.ajax.you_stupid_stubborn_2", npc, creature)
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			npcHandler:sayLocalized("npc.ajax.arrrrrrrrrr_you_me_3", npc, creature)
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			npcHandler:sayLocalized("npc.ajax.i_give_you_4", npc, creature)
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "say please") then
		if npcHandler:getTopic(playerId) == 4 then
			npcHandler:sayLocalized("npc.ajax.please_what_you_5", npc, creature)
			npcHandler:setTopic(playerId, 5)
		end
		-- OUTFIT
	elseif MsgContains(message, "gelagos") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 4 then
			npcHandler:sayLocalized("npc.ajax.annoying_kid_bro_6", npc, creature)
			npcHandler:setTopic(playerId, 6)
		end
	elseif MsgContains(message, "fighting spirit") then
		if npcHandler:getTopic(playerId) == 6 then
			npcHandler:sayLocalized("npc.ajax.if_you_want_7", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 5)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "present") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 11 then
			npcHandler:sayLocalized("npc.ajax.bron_gave_me_8", npc, creature)
			npcHandler:setTopic(playerId, 6)
		end
	elseif MsgContains(message, "iron ore") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 12 then
			npcHandler:sayLocalized("npc.ajax.you_bring_iron_9", npc, creature)
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "crude iron") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 13 then
			npcHandler:sayLocalized("npc.ajax.you_bring_crude_10", npc, creature)
			npcHandler:setTopic(playerId, 9)
		end
	elseif MsgContains(message, "behemoth fangs") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 14 then
			npcHandler:sayLocalized("npc.ajax.you_bring_behemoth_11", npc, creature)
			npcHandler:setTopic(playerId, 10)
		end
	elseif MsgContains(message, "lizard leather") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 15 then
			npcHandler:sayLocalized("npc.ajax.you_bring_lizard_12", npc, creature)
			npcHandler:setTopic(playerId, 11)
		end
	elseif MsgContains(message, "axe") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 16 and player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddonWaitTimer) < os.time() then
			npcHandler:sayLocalized("npc.ajax.axe_is_done_13", npc, creature)
			player:addOutfitAddon(147, 1)
			player:addOutfitAddon(143, 1)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 17)
			player:addAchievement("Brutal Politeness")
		else
			npcHandler:sayLocalized("npc.ajax.axe_is_not_14", npc, creature)
		end
		-- OUTFIT
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 5 then
			npcHandler:sayLocalized("npc.ajax.oh_easy_okay_15", npc, creature)
			local condition = Condition(CONDITION_FIRE)
			condition:setParameter(CONDITION_PARAM_DELAYED, 1)
			condition:addDamage(10, 2000, -10)
			player:addCondition(condition)
			player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 2)
			player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddonWaitTimer, os.time() + 60 * 60) -- 1 hour
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		elseif npcHandler:getTopic(playerId) == 6 then
			npcHandler:say({
				"Good! Me make shiny weapon. If you help me, I make one for you too. Like axe I wear. I need stuff. Listen. ...",
				"Me need 100 iron ore. Then need crude iron. Then after that 50 behemoth fangs. And 50 lizard leather. You understand?",
				"Help me yes or no?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 7)
		elseif npcHandler:getTopic(playerId) == 7 then
			npcHandler:sayLocalized("npc.ajax.good_you_get_16", npc, creature)
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 12)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeItem(5880, 100) then
				npcHandler:sayLocalized("npc.ajax.good_now_bring_17", npc, creature)
				player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 13)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 9 then
			if player:removeItem(5892, 1) then
				npcHandler:sayLocalized("npc.ajax.good_now_bring_18", npc, creature)
				player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 14)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 10 then
			if player:removeItem(5893, 50) then
				npcHandler:sayLocalized("npc.ajax.good_now_bring_19", npc, creature)
				player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 15)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 11 then
			if player:removeItem(5876, 50) then
				npcHandler:sayLocalized("npc.ajax.ah_all_stuff_20", npc, creature)
				player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 16)
				player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddonWaitTimer, os.time() + 2 * 60 * 60) -- 2 hours
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
