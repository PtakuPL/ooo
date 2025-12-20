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
	i18nKey = "npc.oressa.stdmod_1",
})
keywordHandler:addKeyword({ "healer" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_2",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_3",
})
keywordHandler:addKeyword({ "doors" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_4",
	"When you have reached level 8, you can choose your definite vocation. You have to talk to me to receive it, \z
		and then you may open one of the doors, take up your vocation's gear, and leave the island. But be aware: ...",
	"Once you have chosen your vocation and stepped through a door, you cannot go back or choose a different vocation. \z
		So choose well!",
})
keywordHandler:addKeyword({ "inigo" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_5",
})
keywordHandler:addKeyword({ "richard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_6",
})
keywordHandler:addKeyword({ "coltrayne" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_7",
})
keywordHandler:addKeyword({ "morris" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_8",
})
keywordHandler:addKeyword({ "hamish" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_9",
})
keywordHandler:addKeyword({ "dawnport" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"This is a strange place. Many beings are called to it. I dreamed of it long before I came here. ...",
		"Something spoke to me, telling me I had to be its voice; a voice of the Oracle here for the sake of \z
			the adventurers that would come to defend {World} against evil and need to {choose} their destiny.",
	},
})
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.oressa.stdmod_10",
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

	local vocationDefaultMessages = {
		"A vocation is your profession and destiny, determining your skills and way of fighting. \z
			There are four vocations in Tibia: {knight}, {sorcerer}, {paladin} or {druid}. \z
			Each one has its unique special abilities. ... ",
		"When you leave the outpost through one of the four gates upstairs, you will be equipped with \z
			training gear of a specific vocation in order to defend yourself against the monsters outside. ... ",
		"You can try them out as often as you wish to. When you have gained enough experience to reach level 8, \z
			you are ready to choose the definite vocation that is to become your destiny. ... ",
		"Think carefully, as you can't change your vocation later on! You will have to choose your vocation in order \z
			to leave Dawnport for the main continent through one of these {doors} behind me. ... ",
		"Talk to me again when you are ready to choose your vocation, and I will set you on your way. ",
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
		npcHandler:say(vocationDefaultMessages, npc, creature, 10)
		npcHandler:setTopic(playerId, 0)
		-- Choosing dialog start
	elseif MsgContains(message, "choosing") or MsgContains(message, "choose") and npcHandler:getTopic(playerId) == 0 then
		if player:getLevel() >= 8 then
			npcHandler:say(
				"I'll help you decide. \z
				Tell me: Do you like to keep your {distance}, or do you like {close} combat?",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 2)
		else
			npcHandler:say(vocationDefaultMessages, npc, creature, 10)
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
		npcHandler:say(
			"Tell me: Do you prefer to {heal} and cast the power of nature and ice, or do you want to rain \z
			fire and {death} on your foes?",
			npc,
			creature
		)
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
		local message = {
			"Sorcerers are powerful casters of death, energy and fire magic. \z
				They can do a little ice or earth damage as well. ...",
			"Sorcerers cannot take much damage or carry many items, but they deal more damage than paladins or knights, \z
				and can target several enemies. ...",
			"If you wish to be a caster of fire and energy, hurling death magic at your foes, \z
				you should consider choosing the sorcerer vocation.",
		}

		if player:getLevel() >= 8 then
			table.insert(message, "So tell me: DO YOU WISH TO BECOME A POWERFUL SORCERER?" .. " Answer with a proud {YES} if that is your choice!")
			npcHandler:setTopic(playerId, 8)
		else
			npcHandler:setTopic(playerId, 0)
		end

		npcHandler:say(message, npc, creature, 10)
	elseif MsgContains(message, "druid") and npcHandler:getTopic(playerId) == 0 then
		local message = {
			"Druids are healers and powerful masters of ice and earth magic. \z
				They can also do a little energy, fire or death damage as well. ... ",
			"Druids cannot take much damage or carry many items, but they deal more damage than paladins or knights, \z
				and can target several enemies. ... ",
			"If you wish to be a healer and wielder of powerful natural magic, \z
				you should consider choosing the druid vocation.",
		}

		if player:getLevel() >= 8 then
			table.insert(message, "So tell me: DO YOU WISH TO BECOME A SAGACIOUS DRUID?" .. " Answer with a proud {YES} if that is your choice!")
			npcHandler:setTopic(playerId, 7)
		else
			npcHandler:setTopic(playerId, 0)
		end

		npcHandler:say(message, npc, creature, 10)
	elseif MsgContains(message, "paladin") and npcHandler:getTopic(playerId) == 0 then
		local message = {
			"Paladins are sturdy distance fighters. They are tougher than druids or sorcerers and can carry more items, \z
				but they are less tough than a knight. ... ",
			"Paladins have the longest attack range, and can deal the most damage on a single target. ... ",
			"They can also use holy magic to slay the unholy and undead in particular. ... ",
			"If you like to keep a distance to your enemy, shooting while you outdistance him, \z
				you should consider choosing the paladin vocation.",
		}

		if player:getLevel() >= 8 then
			table.insert(message, "So tell me: DO YOU WISH TO BECOME A DARING PALADIN?" .. " Answer with a proud {YES} if that is your choice!")
			npcHandler:setTopic(playerId, 6)
		else
			npcHandler:setTopic(playerId, 0)
		end

		npcHandler:say(message, npc, creature, 10)
	elseif MsgContains(message, "knight") and npcHandler:getTopic(playerId) == 0 then
		local message = {
			"Knights are stalwart melee fighters, the toughest of all vocations. They can take more damage and carry \z
				more items than the other vocations, but they will deal less damage than paladins, druids or sorcerers. ... ",
			"Knights can wield one- or two-handed swords, axes and clubs, and they can cast a few spells to draw a \z
				monster's attention to them. ... ",
			"If you want to be a tough melee fighter who can resist much longer than anyone else, \z
				you should consider choosing the knight vocation.",
		}

		if player:getLevel() >= 8 then
			table.insert(message, "DO YOU WISH TO BECOME A VALIANT KNIGHT? Answer with a proud {YES} if that is your choice!")
			npcHandler:setTopic(playerId, 5)
		else
			npcHandler:setTopic(playerId, 0)
		end

		npcHandler:say(message, npc, creature, 10)
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
