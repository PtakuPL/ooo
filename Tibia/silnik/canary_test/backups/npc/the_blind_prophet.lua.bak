local internalNpcName = "The Blind Prophet"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 117,
	lookHead = 10,
	lookBody = 20,
	lookLegs = 30,
	lookFeet = 40,
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

-- Don't forget npcHandler = npcHandler in the parameters. It is required for all StdModule functions!
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_blind_prophet.stdmod_1" })
keywordHandler:addKeyword({ "blind prophet" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_blind_prophet.stdmod_2" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_blind_prophet.stdmod_3" })
keywordHandler:addKeyword({ "prophet" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_blind_prophet.stdmod_4" })
keywordHandler:addKeyword({ "guardian" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_blind_prophet.stdmod_5" })
keywordHandler:addKeyword({ "forbidden land" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_blind_prophet.stdmod_6" })
keywordHandler:addKeyword({ "hairycles" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_blind_prophet.stdmod_7" })
keywordHandler:addKeyword({ "bong" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_blind_prophet.stdmod_8" })
keywordHandler:addKeyword({ "lizards" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_blind_prophet.stdmod_9" })
keywordHandler:addKeyword({ "ape" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_blind_prophet.stdmod_10" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_blind_prophet.stdmod_11" })
keywordHandler:addKeyword({ "port hope" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_blind_prophet.stdmod_12" })

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.the_blind_prophet.greet_msg_1")
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "transport") or MsgContains(message, "passage") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_blind_prophet.say_13")
		npcHandler:setTopic(playerId, 1)
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			local questlineValue = player:getStorageValue(Storage.Quest.U7_6.TheApeCity.Questline)
			if questlineValue >= 15 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_blind_prophet.say_14")
				local destination = Position(33025, 32580, 6)
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				player:teleportTo(destination)
				destination:sendMagicEffect(CONST_ME_TELEPORT)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_blind_prophet.say_15")
			end
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_blind_prophet.say_16")
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
