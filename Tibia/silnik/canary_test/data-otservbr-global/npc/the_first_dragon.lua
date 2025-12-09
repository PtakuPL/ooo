local internalNpcName = "The First Dragon"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 947,
	lookAddons = 3,
	lookHead = 113,
	lookBody = 117,
	lookLegs = 119,
	lookFeet = 80,
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

	if MsgContains(message, "reward") and player:getStorageValue(Storage.Quest.U11_02.TheFirstDragon.Feathers) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_28")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_29")
		player:addOutfit(929, 0)
		player:addOutfit(931, 0)
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		if player:getStorageValue(Storage.Quest.U11_02.TheFirstDragon.Feathers) < 2 then
			player:setStorageValue(Storage.Quest.U11_02.TheFirstDragon.Feathers, 2)
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "fight") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_27")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "retirement") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_25")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_26")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "memoirs") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_21")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_22")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_23")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_24")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "hassle") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_19")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_20")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "worthy") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_17")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_18")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "weaknesses") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_15")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_16")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "mists") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_13")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_14")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "world") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_11")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_12")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "books") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_10")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "invention") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_6")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "adapt") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_4")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "finer") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_first_dragon.multi_2")
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hello, my sparring buddy. We should have another fight sometimes. I think you may have earned a little reward.")

keywordHandler:addKeyword({ "times" }, StdModule.say, { npcHandler = npcHandler, text = "Times have changed <sigh>. In the past dragons were feared and respected. Only the {demons} rivalled our notoriety." })
keywordHandler:addKeyword({ "demons" }, StdModule.say, { npcHandler = npcHandler, text = "Those upstarts! I wonder why would anyone care about them. They lack our style. For them it is all about brute force and showing-off." })
keywordHandler:addKeyword({ "style" }, StdModule.say, { npcHandler = npcHandler, text = "Breathing fire is an art! Instead of setting everything on fire, you exhale a cone of fire to give a worthy opponent a chance to avoid it." })
keywordHandler:addKeyword({ "humans" }, StdModule.say, { npcHandler = npcHandler, text = "Your lives are so short and meaningless and yet you are here! And as a race you even have your own history and remember things with the help of {books}, which amazes me." })
keywordHandler:addKeyword({ "concept" }, StdModule.say, { npcHandler = npcHandler, text = "I like the idea of books so much that I acquired a human servant to record my memoirs. You find a copy somewhere in my lair." })
keywordHandler:addKeyword({ "lava" }, StdModule.say, { npcHandler = npcHandler, text = "Lava is only fun as long as it doesn't harden - then it turns into an annoyance." })

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
