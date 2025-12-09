local internalNpcName = "The Bone Master"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 145,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
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

	if MsgContains(message, "join") then
		if player:getStorageValue(Storage.Quest.U7_9.NightmareOutfits.Outfits) < 1 and player:getStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Outfits) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.multi_9")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "advancement") or MsgContains(message, "demonic") or MsgContains(message, "essence") then
		if player:getStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Outfits) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.say_1")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Outfits) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.say_2")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Outfits) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.say_3")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.multi_5")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.multi_3")
			player:setStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Outfits, 1)
			player:addAchievement("Bone Brother")
			npcHandler:setTopic(playerId, 0)
			player:addItem(768, 1)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(6499, 500) then
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Outfits, 2)
				player:addItem(769, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.say_4")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.say_5")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(6499, 1000) then
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Outfits, 3)
				player:addItem(770, 1)
				player:addItem(6432, 1)
				player:addAchievement("Skull and Bones")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.say_6")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.say_7")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(6499, 1500) then
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Outfits, 4)
				player:setStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Door, 1)
				player:setStorageValue(Storage.Quest.U7_9.NightmareOutfits.KnightwatchTowerDoor, 1)
				player:addAchievement("Dread Lord")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.say_8")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_bone_master.say_9")
			end
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Welcome to my little realm.")
npcHandler:setMessage(MESSAGE_FAREWELL, "We will meet again.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
