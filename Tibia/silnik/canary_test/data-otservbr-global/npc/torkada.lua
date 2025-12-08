local internalNpcName = "Torkada"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 0

npcConfig.outfit = {
	lookType = 1243,
	lookHead = 59,
	lookBody = 78,
	lookLegs = 78,
	lookFeet = 57,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if player:getLevel() < 250 then
		npcHandler:sayLocalized("npc.torkada.you_need_at_1", npc, creature)
		return false
	end

	local access = player:kv():scoped("rotten-blood-quest"):get("access") or 0
	if access > 0 then
		if player:getStorageValue(Storage.Quest.U13_20.RottenBlood.AccessDoor) ~= 1 then
			player:setStorageValue(Storage.Quest.U13_20.RottenBlood.AccessDoor, 1)
		end
		npcHandler:sayLocalized("npc.torkada.you_already_have_2", npc, creature)
		npcHandler:setTopic(playerId, 0)
		return true
	end

	message = message:lower()
	if MsgContains(message, "time") then
		npcHandler:sayLocalized("npc.torkada.this_expedition_is_3", npc, creature)
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "mission") and npcHandler:getTopic(playerId) == 1 then
		npcHandler:sayLocalized("npc.torkada.are_you_willing_4", npc, creature)
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 2 then
		npcHandler:setTopic(playerId, 0)
		npcHandler:say({
			"So hereby receive the blessings of the gods, provided by me as the voice of the inquisition! ...",
			"Go now and search the ancient temple in the north-west part of the drefian ruins. Slay the evil that lurks there and cleanse the foul place from its taint!",
		}, npc, creature)
		player:kv():scoped("rotten-blood-quest"):set("access", 1)
		player:setStorageValue(Storage.Quest.U13_20.RottenBlood.AccessDoor, 1)
		player:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 1 then
		npcHandler:setTopic(playerId, 0)
		npcHandler:sayLocalized("npc.torkada.ok_then_not_5", npc, creature)
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings! This isn't the {time} to chitchat though.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Bye.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Bye, |PLAYERNAME|.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
