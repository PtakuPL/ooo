local internalNpcName = "The Dream Master"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 19,
	lookBody = 39,
	lookLegs = 20,
	lookFeet = 58,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "join") then
		if player:getStorageValue(Storage.Quest.U7_9.BrotherhoodOutfits.Outfits) < 1 and player:getStorageValue(Storage.Quest.U7_9.NightmareOutfits.Outfits) < 1 then
			npcHandler:say({
				"The Nightmare Knights are almost extinct now, and as far as I know I am the only teacher that is left. But you might beright and its time to accept new disciples ...",
				"After all you have passed the Dream Challenge to reach this place, which used to be the process of initiation in the past...",
				"So I ask you: do you wish to become a member of the ancient order of the Nightmare Knights, |PLAYERNAME|?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "advancement") or MsgContains(message, "demonic") or MsgContains(message, "essence") then
		if player:getStorageValue(Storage.Quest.U7_9.NightmareOutfits.Outfits) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_dream_master.say_1")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U7_9.NightmareOutfits.Outfits) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_dream_master.say_2")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U7_9.NightmareOutfits.Outfits) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_dream_master.say_3")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_dream_master.say_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_dream_master.say_5")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			npcHandler:say({
				"So I welcome you as the latest member of the order of the Nightmare Knights. You entered this place as a stranger, butyou will leave this place as a friend ...",
				"You can always ask me about your current rank and about the privileges the ranks grant to those who hold them.",
			}, npc, creature)
			player:addItem(768, 1)
			player:setStorageValue(Storage.Quest.U7_9.NightmareOutfits.Outfits, 1)
			player:addAchievement("Nightmare Knight")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(6499, 500) then
				player:addItem(769, 1)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U7_9.NightmareOutfits.Outfits, 2)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_dream_master.say_6")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_dream_master.say_7")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(6499, 1000) then
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U7_9.NightmareOutfits.Outfits, 3)
				player:addItem(770, 1)
				player:addItem(6390, 1)
				player:addAchievement("Nightmare Walker")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_dream_master.say_8")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_dream_master.say_9")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(6499, 1500) then
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U7_9.NightmareOutfits.Outfits, 4)
				player:setStorageValue(Storage.Quest.U7_9.NightmareOutfits.Door, 1)
				player:setStorageValue(Storage.Quest.U7_9.NightmareOutfits.KnightwatchTowerDoor, 1)
				player:addAchievement("Lord Protector")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_dream_master.say_10")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_dream_master.say_11")
			end
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Be greeted, visitor.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye. May the gods watch over your path.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
