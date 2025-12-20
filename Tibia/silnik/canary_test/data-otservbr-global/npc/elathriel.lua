local internalNpcName = "Elathriel"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 64,
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

keywordHandler:addKeyword({ "business" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_1",
})
keywordHandler:addKeyword({ "sheriff" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_2",
})
keywordHandler:addKeyword({ "executioner" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_3",
})
keywordHandler:addKeyword({ "avenger" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_4",
})
keywordHandler:addKeyword({ "hellgate" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_5",
})
keywordHandler:addKeyword({ "sealed" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_6",
})
keywordHandler:addKeyword({ "door" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_7",
})
keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_8",
})
keywordHandler:addKeyword({ "army" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_9",
})
keywordHandler:addKeyword({ "king" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_10",
})
keywordHandler:addKeyword({ "magic" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_11",
})
keywordHandler:addKeyword({ "time" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_12",
})
keywordHandler:addKeyword({ "eloise" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_13",
})
keywordHandler:addKeyword({ "tibianus" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_14",
})
keywordHandler:addKeyword({ "druid" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_15",
})
keywordHandler:addKeyword({ "sorcerer" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_16",
})
keywordHandler:addKeyword({ "dwarfs" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_17",
})
keywordHandler:addKeyword({ "trolls" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_18",
})
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_19",
})
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_20",
})
keywordHandler:addKeyword({ "elves" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_21",
})
keywordHandler:addKeyword({ "cenath" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_22",
})
keywordHandler:addKeyword({ "teshial" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_23",
})
keywordHandler:addKeyword({ "deraisim" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_24",
})
keywordHandler:addKeyword({ "kuridai" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_25",
})
keywordHandler:addKeyword({ "carlin" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_26",
})
keywordHandler:addKeyword({ "venore" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_27",
})
keywordHandler:addKeyword({ "thais" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_28",
})
keywordHandler:addKeyword({ "carlin" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "",
})
keywordHandler:addKeyword({ "offer" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_29",
})
keywordHandler:addKeyword({ "buy" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_30",
})
keywordHandler:addKeyword({ "sell" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.elathriel.stdmod_31",
})

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "key") then
		npcHandler:say(
			"If you are that curious, do you want to buy a key for 5000 gold? \z
						Don't blame me if you get sucked in.",
			npc,
			creature
		)
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			local player = Player(creature)
			if player:removeMoneyBank(5000) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elathriel.say_1")
				local key = player:addItem(2970, 1)
				if key then
					key:setActionId(3012)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elathriel.say_2")
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elathriel.say_3")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end
-- Greeting message
keywordHandler:addGreetKeyword({ "ashari" }, {
	npcHandler = npcHandler,
	text = "Be greeted |PLAYERNAME|. What is your {business} near the {hellgate}?", i18nKey = "npc.elathriel.greet_1",
})
--Farewell message
keywordHandler:addFarewellKeyword({ "asgha thrazi" }, {
	npcHandler = npcHandler,
	text = "Asha Thrazi, |PLAYERNAME|.", i18nKey = "npc.elathriel.farewell_1",
})

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.elathriel.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.elathriel.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.elathriel.farewell_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
