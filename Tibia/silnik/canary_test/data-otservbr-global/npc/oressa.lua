local internalNpcName = "Oressa"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 148,
	lookHead = 114,
	lookBody = 78,
	lookLegs = 96,
	lookFeet = 114,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{
		i18nKey = "npc.oressa.voice_1",
	},
	{ i18nKey = "npc.oressa.voice_2" },
	{ i18nKey = "npc.oressa.voice_3" },
	{ i18nKey = "npc.oressa.voice_4" },
	{ i18nKey = "npc.oressa.voice_5" },
	{ i18nKey = "npc.oressa.voice_6" },
	{ i18nKey = "npc.oressa.voice_7" },
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

-- Basic keywords
keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_8",
})
keywordHandler:addKeyword({ "healer" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_9",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_10",
})
keywordHandler:addKeyword({ "doors" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_11",
})
keywordHandler:addKeyword({ "inigo" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_12",
})
keywordHandler:addKeyword({ "richard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_13",
})
keywordHandler:addKeyword({ "coltrayne" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_14",
})
keywordHandler:addKeyword({ "morris" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_15",
})
keywordHandler:addKeyword({ "hamish" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_16",
})
keywordHandler:addKeyword({ "dawnport" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_18",
})
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_17",
})

--From topic of vocation to topic of the "yes" message (choosing vocation)
local topicTable = {
	[5] = VOCATION.ID.KNIGHT,
	[6] = VOCATION.ID.PALADIN,
	[7] = VOCATION.ID.DRUID,
	[8] = VOCATION.ID.SORCERER,
}

local vocationRoomPositions = {
	[5] = { x = 32068, y = 31884, z = 6 },
	[6] = { x = 32059, y = 31884, z = 6 },
	[7] = { x = 32073, y = 31884, z = 6 },
	[8] = { x = 32054, y = 31884, z = 6 },
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local health = player:getHealth()

	local vocationDefaultMessageKeys = {
		"npc.oressa.vocation_default_1",
		"npc.oressa.vocation_default_2",
		"npc.oressa.vocation_default_3",
		"npc.oressa.vocation_default_4",
		"npc.oressa.vocation_default_5",
	}

	-- Heal and help dialog
	if MsgContains(message, "healing") and npcHandler:getTopic(playerId) == 0 then
		if player:getLevel() < 8 then
			if health < 40 or player:getCondition(CONDITION_POISON) then
				if health < 40 then
					player:addHealth(40 - health)
					player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
				end
				if player:getCondition(CONDITION_POISON) then
					player:removeCondition(CONDITION_POISON)
					player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
				end
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oressa.say_1")
				npcHandler:setTopic(playerId, 0)
			else
				return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oressa.say_2")
			end
		end
	elseif MsgContains(message, "help") and npcHandler:getTopic(playerId) == 0 then
		if player:getCondition(CONDITION_POISON) == nil or health > 40 then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oressa.say_3")
		end
		if health < 40 or player:getCondition(CONDITION_POISON) then
			if health < 40 then
				player:addHealth(40 - health)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			end
			if player:getCondition(CONDITION_POISON) then
				player:removeCondition(CONDITION_POISON)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oressa.say_4")
			npcHandler:setTopic(playerId, 0)
		end
		-- Vocation dialog
	elseif npcHandler:getTopic(playerId) == 0 and MsgContains(message, "vocation") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, vocationDefaultMessageKeys, 10)
		npcHandler:setTopic(playerId, 0)
		-- Choosing dialog start
	elseif MsgContains(message, "choosing") or MsgContains(message, "choose") and npcHandler:getTopic(playerId) == 0 then
		if player:getLevel() >= 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oressa.choose_prompt_1")
			npcHandler:setTopic(playerId, 2)
		else
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, vocationDefaultMessageKeys, 10)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "distance") and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oressa.say_5")
		npcHandler:setTopic(playerId, 3)
		-- knight
	elseif MsgContains(message, "close") and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.oressa.say_1", "npc.oressa.say_2", "npc.oressa.say_3", "npc.oressa.say_4"}, 10)
		npcHandler:setTopic(playerId, 5)
		-- Paladin
	elseif MsgContains(message, "bow") or MsgContains(message, "spear") and npcHandler:getTopic(playerId) == 3 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.oressa.say_5", "npc.oressa.say_6", "npc.oressa.say_7", "npc.oressa.say_8", "npc.oressa.say_9"}, 10)
		npcHandler:setTopic(playerId, 6)
		-- Mage
	elseif MsgContains(message, "magic") and npcHandler:getTopic(playerId) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oressa.magic_prompt_1")
		npcHandler:setTopic(playerId, 4)
		-- Druid
	elseif MsgContains(message, "heal") and npcHandler:getTopic(playerId) == 4 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.oressa.say_10", "npc.oressa.say_11", "npc.oressa.say_12", "npc.oressa.say_13"}, 10)
		npcHandler:setTopic(playerId, 7)
		-- Sorcerer
	elseif MsgContains(message, "death") and npcHandler:getTopic(playerId) == 4 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.oressa.say_14", "npc.oressa.say_15", "npc.oressa.say_16", "npc.oressa.say_17"}, 10)
		npcHandler:setTopic(playerId, 8)
		-- Choosing dialog start
	elseif MsgContains(message, "decided") and npcHandler:getTopic(playerId) == 0 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oressa.say_6")
		-- Say vocations name
	elseif MsgContains(message, "sorcerer") and npcHandler:getTopic(playerId) == 0 then
		local sorcererMessageKeys = {
			"npc.oressa.sorcerer_info_1",
			"npc.oressa.sorcerer_info_2",
			"npc.oressa.sorcerer_info_3",
		}

		if player:getLevel() >= 8 then
			table.insert(sorcererMessageKeys, "npc.oressa.sorcerer_confirm_1")
			npcHandler:setTopic(playerId, 8)
		else
			npcHandler:setTopic(playerId, 0)
		end

		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, sorcererMessageKeys, 10)
	elseif MsgContains(message, "druid") and npcHandler:getTopic(playerId) == 0 then
		local druidMessageKeys = {
			"npc.oressa.druid_info_1",
			"npc.oressa.druid_info_2",
			"npc.oressa.druid_info_3",
		}

		if player:getLevel() >= 8 then
			table.insert(druidMessageKeys, "npc.oressa.druid_confirm_1")
			npcHandler:setTopic(playerId, 7)
		else
			npcHandler:setTopic(playerId, 0)
		end

		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, druidMessageKeys, 10)
	elseif MsgContains(message, "paladin") and npcHandler:getTopic(playerId) == 0 then
		local paladinMessageKeys = {
			"npc.oressa.paladin_info_1",
			"npc.oressa.paladin_info_2",
			"npc.oressa.paladin_info_3",
			"npc.oressa.paladin_info_4",
		}

		if player:getLevel() >= 8 then
			table.insert(paladinMessageKeys, "npc.oressa.paladin_confirm_1")
			npcHandler:setTopic(playerId, 6)
		else
			npcHandler:setTopic(playerId, 0)
		end

		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, paladinMessageKeys, 10)
	elseif MsgContains(message, "knight") and npcHandler:getTopic(playerId) == 0 then
		local knightMessageKeys = {
			"npc.oressa.knight_info_1",
			"npc.oressa.knight_info_2",
			"npc.oressa.knight_info_3",
		}

		if player:getLevel() >= 8 then
			table.insert(knightMessageKeys, "npc.oressa.knight_confirm_1")
			npcHandler:setTopic(playerId, 5)
		else
			npcHandler:setTopic(playerId, 0)
		end

		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, knightMessageKeys, 10)
	elseif (npcHandler:getTopic(playerId) >= 5) and (npcHandler:getTopic(playerId) <= 8) then
		if MsgContains(message, "yes") then
			for index, value in pairs(topicTable) do
				if npcHandler:getTopic(playerId) == index then
					if player:getStorageValue(Storage.Dawnport.DoorVocation) == -1 then
						-- Change to new vocation, convert magic level and skills and set proper stats
						player:changeVocation(value)
						player:setStorageValue(Storage.Dawnport.DoorVocation, value)
						if configManager.getBoolean(configKeys.TELEPORT_PLAYER_TO_VOCATION_ROOM) then
							local position = vocationRoomPositions[index]
							player:teleportTo(Position(position.x, position.y, position.z))
							player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
						end
					else
						npcHandler:setTopic(playerId, 0)
						return true
					end
				end
			end
			-- Remove Mainland smuggling items
			removeMainlandSmugglingItems(player)
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.oressa.say_18", "npc.oressa.say_19", "npc.oressa.say_20", "npc.oressa.say_21"}, 10)
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			local vocationMessage = {
				[5] = "{paladin}, {sorcerer} or {druid}",
				[6] = "{knight}, {sorcerer} or {druid}",
				[7] = "{knight}, {paladin} or {sorcerer}",
				[8] = "{knight}, {paladin} or {druid}",
			}
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.oressa.say_22", "npc.oressa.say_23"}, 10)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getLevel() >= 8 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.oressa.greet_msg_1")
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.oressa.greet_msg_2")
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.oressa.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
