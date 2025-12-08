local internalNpcName = "A Beggar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 153,
	lookHead = 39,
	lookBody = 39,
	lookLegs = 39,
	lookFeet = 76,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
local npcI18n = NPC_LIB and NPC_LIB.i18n

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
	if MsgContains(message, "want") then
		if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission01) == 1 then
			npcHandler:setTopic(playerId, 1)
		end
		if npcI18n then
			npcI18n.sayLocalized(player, "npc.a_beggar.want", nil, MESSAGE_NPC_FROM)
		else
			player:sendTextMessage(MESSAGE_NPC_FROM, "The guys from the magistrate sent you here, didn't they?")
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if npcI18n then
				npcI18n.npcSayMultiple(
					npcHandler,
					npc,
					creature,
					{
						"npc.a_beggar.yes_audience",
						"npc.a_beggar.yes_help",
						"npc.a_beggar.yes_subjects",
						"npc.a_beggar.yes_dedication",
						"npc.a_beggar.yes_palace",
					},
					100
				)
			else
				npcHandler:say({
					"Thought so. You'll have to talk to the king though. The beggar king that is. The king does not grant an audience to just everyone. You know how those kings are, don't you?",
					"However, to get an audience with the king, you'll have to help his subjects a bit.",
					"His subjects that would be us, the poor, you know?",
					"So why don't you show your dedication to the poor? Go and help Chavis at the poor house. He's collecting food for people like us.",
					"If you brought enough of the stuff you'll see that the king will grant you entrance in his {palace}.",
				}, npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission01, 2) -- Mission 1 end
			player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission02, 1) -- Mission 2 start
		end
	end
	return true
end

-- Localized greet callback
local function greetCallback(npc, creature)
	local player = Player(creature)
	if player then
		if npcI18n then
			npcI18n.sayLocalized(player, "npc.a_beggar.greet", nil, MESSAGE_NPC_FROM)
		else
			player:sendTextMessage(MESSAGE_NPC_FROM, "Hi! What is it, what d'ye {want}?")
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
