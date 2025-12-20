local internalNpcName = "Oswald"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 115,
	lookBody = 0,
	lookLegs = 67,
	lookFeet = 114,
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

keywordHandler:addKeyword({ "gods" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_1" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_2" })
keywordHandler:addKeyword({ "important" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_3" })
keywordHandler:addKeyword({ "assistant" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_4" })
keywordHandler:addKeyword({ "annoying" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_5" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_6" })
keywordHandler:addKeyword({ "magic" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_7" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_8" })
keywordHandler:addKeyword({ "sell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_9" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_10" })
keywordHandler:addKeyword({ "weapon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_11" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_12" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_13" })
keywordHandler:addKeyword({ "necromants nectar" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_14" })
keywordHandler:addKeyword({ "benjamin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_15" })
keywordHandler:addKeyword({ "bozo" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_16" })
keywordHandler:addKeyword({ "Chester Kahs" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_17" })
keywordHandler:addKeyword({ "elane" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_18" })
keywordHandler:addKeyword({ "gamel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_19" })
keywordHandler:addKeyword({ "sinister strangers" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_20" })
keywordHandler:addKeyword({ "gorn" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_21" })
keywordHandler:addKeyword({ "gregor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_22" })
keywordHandler:addKeyword({ "muriel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_23" })
keywordHandler:addKeyword({ "rumours" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_24" })
keywordHandler:addKeyword({ "anything" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_25" })
keywordHandler:addKeyword({ "quentin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_26" })
keywordHandler:addKeyword({ "sam" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_27" })
keywordHandler:addKeyword({ "goshnar" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_28" })
keywordHandler:addKeyword({ "lugri" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_29" })
keywordHandler:addKeyword({ "partos" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_30" })
keywordHandler:addKeyword({ "durin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_31" })
keywordHandler:addKeyword({ "monsters" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oswald.stdmod_32" })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "invitation") then
		if player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission03) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oswald.say_33")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oswald.say_34")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeMoneyBank(1000) then
				player:addItem(7933, 1)
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission03, 2)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oswald.say_35")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oswald.say_36")
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "gold") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oswald.say_37")
			npcHandler:setTopic(playerId, 2)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Oh, hello |PLAYERNAME|. What is it?")
npcHandler:setMessage(MESSAGE_FAREWELL, "Finally!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye, and don't come back too soon.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
