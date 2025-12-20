local internalNpcName = "Morgan"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 134,
	lookHead = 78,
	lookBody = 120,
	lookLegs = 122,
	lookFeet = 132,
	lookAddons = 2,
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

	if MsgContains(message, "firebird") then
		if player:getStorageValue(Storage.Quest.U7_8.PirateOutfits.PirateSabreAddon) == 4 then
			player:setStorageValue(Storage.Quest.U7_8.PirateOutfits.PirateSabreAddon, 5)
			player:addOutfitAddon(151, 1)
			player:addOutfitAddon(155, 1)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.say_1")
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.multi_3")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.say_2")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 9)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "warrior's sword") then
		if player:hasOutfit(player:getSex() == PLAYERSEX_FEMALE and 142 or 134, 2) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.say_3")
			return true
		end

		if player:getStorageValue(Storage.Quest.U7_8.WarriorOutfits.WarriorSwordAddon) < 1 then
			player:setStorageValue(Storage.Quest.U7_8.WarriorOutfits.WarriorSwordAddon, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.say_4")
		elseif player:getStorageValue(Storage.Quest.U7_8.WarriorOutfits.WarriorSwordAddon) == 1 and npcHandler:getTopic(playerId) == 1 then
			if player:getItemCount(5887) > 0 and player:getItemCount(5880) > 99 then
				player:removeItem(5887, 1)
				player:removeItem(5880, 100)
				player:addOutfitAddon(134, 2)
				player:addOutfitAddon(142, 2)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U7_8.WarriorOutfits.WarriorSwordAddon, 2)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:addAchievementProgress("Wild Warrior", 2)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.say_5")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.say_6")
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "knight's sword") then
		if player:hasOutfit(player:getSex() == PLAYERSEX_FEMALE and 139 or 131, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.say_7")
			return true
		end

		if player:getStorageValue(Storage.Quest.U7_8.KnightOutfits.AddonSword) < 1 then
			player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.AddonSword, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.say_8")
		elseif player:getStorageValue(Storage.Quest.U7_8.KnightOutfits.AddonSword) == 1 and npcHandler:getTopic(playerId) == 1 then
			if player:getItemCount(5892) > 0 and player:getItemCount(5880) > 99 then
				player:removeItem(5892, 1)
				player:removeItem(5880, 100)
				player:addOutfitAddon(131, 1)
				player:addOutfitAddon(139, 1)
				player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.AddonSword, 2)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.say_9")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.say_10")
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "forge") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.say_11")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 6 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.morgan.say_12")
				player:addItem(3506, 1)
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 7)
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

keywordHandler:addKeyword({ "addon" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.morgan.stdmod_1",
})
keywordHandler:addKeyword({ "weapons" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.morgan.stdmod_2",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.morgan.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.morgan.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
