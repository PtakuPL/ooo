local npcType = Game.createNpcType("Bloodshade Sacrifice")
local npcConfig = {}

local npcName = "A Bloodshade"
npcConfig.name = npcName
npcConfig.description = npcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 0

npcConfig.outfit = {
	lookType = 1414,
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

	local access = player:kv():scoped("rotten-blood-quest"):get("access") or 0
	if access > 2 then
		npcHandler:sayLocalized("npc.bloodshade_sacrifice.you_already_have_1", npc, creature)
		npcHandler:setTopic(playerId, 0)
		return true
	end

	message = message:lower()
	if MsgContains(message, "quest") then
		npcHandler:say({
			"To enter the realm of the sanguine master and destroy its spawn, a sufficient sacrifice is imperative. ...",
			"Find and slay the keeper of blooded tears and bring the nectar of his eyes before the blood god. Present your gift on the sacrificial altar. ...",
			"After - and under no circumstances before - you have completed this procedure, you can enter the sacred fluid. You can, of course also take a slightly faster... {detour}.",
		}, npc, creature)
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "detour") and npcHandler:getTopic(playerId) == 1 then
		npcHandler:say({
			"Hm. I see. Well, I will be frank. Every blood sacrifice has its price. Blood money will please the blood god... just as well. ...",
			"The sum would be five million gold pieces and I... my master will be pleased. Are you prepared for a sacrifice such as this?",
		}, npc, creature)
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 2 then
		npcHandler:sayLocalized("npc.bloodshade_sacrifice.you_are_willing_2", npc, creature)
		npcHandler:setTopic(playerId, 3)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 3 then
		if not player:removeMoneyBank(5000000) then
			npcHandler:sayLocalized("npc.bloodshade_sacrifice.sorry_you_dont_3", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
		npcHandler:sayLocalized("npc.bloodshade_sacrifice.the_bargain_has_4", npc, creature)
		npcHandler:setTopic(playerId, 0)
		player:kv():scoped("rotten-blood-quest"):set("access", 4)
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 1 then
		npcHandler:setTopic(playerId, 0)
		npcHandler:sayLocalized("npc.bloodshade_sacrifice.ok_then_not_5", npc, creature)
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Mortal! If you are on a {quest} to serve the blood god, my master - be greeted!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Bye.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Bye, |PLAYERNAME|.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
