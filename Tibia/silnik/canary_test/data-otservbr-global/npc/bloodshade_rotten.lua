local npcType = Game.createNpcType("Bloodshade Rotten")
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
	if access == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bloodshade_rotten.say_1")
		npcHandler:setTopic(playerId, 0)
		return true
	end

	message = message:lower()
	if MsgContains(message, "quest") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bloodshade_rotten.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bloodshade_rotten.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bloodshade_rotten.multi_3")
		player:kv():scoped("rotten-blood-quest"):set("access", 5)
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Mortal! If you are on a {quest} to serve the blood god, my master - be greeted!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Bye.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Bye, |PLAYERNAME|.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
