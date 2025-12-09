local internalNpcName = "Alkestios"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 400,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
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

local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(ThreatenedDreams.Mission01[1]) == 1 and player:getStorageValue(ThreatenedDreams.Mission01.PoacherChest) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.say_1")
		elseif player:getStorageValue(ThreatenedDreams.Mission01[1]) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.say_2")
		elseif player:getStorageValue(ThreatenedDreams.Mission01[1]) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.multi_11")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(ThreatenedDreams.Mission01[1]) == 15 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.multi_9")
			player:setStorageValue(ThreatenedDreams.Mission01[1], 16)
		end
	elseif MsgContains(message, "help") and player:getStorageValue(ThreatenedDreams.Mission01[1]) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.multi_7")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:getStorageValue(ThreatenedDreams.QuestLine) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.say_3")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.multi_5")
				player:setStorageValue(ThreatenedDreams.QuestLine, 1)
				player:setStorageValue(ThreatenedDreams.Mission01[1], 1)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.multi_2")
			player:setStorageValue(ThreatenedDreams.Mission01[1], 4)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alkestios.say_4")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "deer" }, StdModule.say, { npcHandler = npcHandler, text = "Outside of our secret {realm} my siblings and I can't keep our true shape. If we want to travel other parts of the world, we must take over the bodies of animals. But we are causing them no harm and we just take control if necessary." })
keywordHandler:addKeyword({ "realm" }, StdModule.say, { npcHandler = npcHandler, text = "We call it Feyrist and it is a secret, hidden place. Just few mortals get permission to enter it. A long time ago, we learned how to hide our realm from the outside world. Only if you gain our trust I will tell you how to reach it." })
keywordHandler:addKeyword({ "siblings" }, StdModule.say, { npcHandler = npcHandler, text = "We call ourselves the fae. Some name us nature spirits or peri but we prefer the former term. Most of us are rather reclusive and live peaceful lives in our secret realm. We only leave it in order to {protect} our home. ..." })
keywordHandler:addKeyword({ "kind" }, StdModule.say, { npcHandler = npcHandler, text = "We call ourselves the fae. Some name us nature spirits or peri but we prefer the former term. Most of us are rather reclusive and live peaceful lives in our secret realm. We only leave it in order to {protect} our home. ..." })
keywordHandler:addKeyword({ "protect" }, StdModule.say, { npcHandler = npcHandler, text = "I can sense a kind of dark energy lately. It is pervading this world, more and more every day. Yet I don't know where it arises from nor what we could do to dispel it." })
keywordHandler:addKeyword({ "energy" }, StdModule.say, { npcHandler = npcHandler, text = "It is rather subversive, so most creatures won't sense it ... yet. But its corrosive power has already begun to affect my kind and our hidden realm in unpleasant ways." })
keywordHandler:addKeyword({ "fae" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Some call us nature spirits or peri but we prefer the term fae. Most of us are rather reclusive and live peaceful lives in our secret realm. We only leave it in order to protect our home. ...",
		"We tend to be secretive about our true nature, but I guess there was once an elven sage who visited our realm and put his experiences down on paper. There might be a book about the fae in the library of Ab'Dendriel.",
	},
})

npcHandler:setMessage(MESSAGE_GREET, "Nature's blessing, traveller! May you not be affected by any sinister force.")
npcHandler:setMessage(MESSAGE_FAREWELL, "May your path always be even.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "May your path always be even.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
