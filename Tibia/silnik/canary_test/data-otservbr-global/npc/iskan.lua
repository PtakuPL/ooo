local internalNpcName = "Iskan"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 143,
	lookHead = 38,
	lookBody = 116,
	lookLegs = 38,
	lookFeet = 19,
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

local function greetCallback(npc, player)
	if player:getStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline) < 8 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.iskan.greet_msg_1")
	elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKill) >= 1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.iskan.greet_msg_2")
	elseif player:hasAchievement("Warlord of Svargrond") then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.iskan.greet_msg_3")
	elseif player:getStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline) == 8 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.iskan.greet_msg_4")
	end
	return true
end
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end
	if player:getStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline) < 8 then
		return true
	end
	if MsgContains(message, "passage") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) >= 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.say_1")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.say_2")
		end
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline) >= 8 then -- if Barbarian Test absolved
			if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.multi_4")
				npcHandler:setTopic(playerId, 1)
			elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.say_3")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 3)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission01, 3) -- Questlog The Ice Islands Quest, Befriending the Musher
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.say_4")
				npcHandler:setTopic(playerId, 0)
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.say_5")
		end
	elseif MsgContains(message, "yes") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKill) >= 1 then
			if player:removeMoneyBank(500) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.say_6")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKillStatus, 0)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKill, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.say_7")
			end
		elseif npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.multi_2")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 1)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission01, 1) -- Questlog The Ice Islands Quest, Befriending the Musher
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) >= 3 then
				player:teleportTo(Position(32325, 31049, 7))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.say_8")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "no") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKill) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.iskan.say_9")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKillStatus, 1)
		end
	end
	return true
end
--Basic
keywordHandler:addKeyword({ "do for you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_1" })
keywordHandler:addAliasKeyword({ "job" })
keywordHandler:addAliasKeyword({ "shop" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_2" })
keywordHandler:addKeyword({ "nibelor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_3" })
keywordHandler:addKeyword({ "city" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_4" })
keywordHandler:addAliasKeyword({ "svargrond" })
keywordHandler:addKeyword({ "barbarian" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_5" })
keywordHandler:addKeyword({ "rumours" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_6" })
keywordHandler:addKeyword({ "chakoya" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_7" })
keywordHandler:addKeyword({ "monsters" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_8" })
keywordHandler:addKeyword({ "cult" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_9" })
keywordHandler:addKeyword({ "yeti" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_10" })
keywordHandler:addKeyword({ "test" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_11" })
keywordHandler:addKeyword({ "camps" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_12" })
keywordHandler:addKeyword({ "raiders" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_13" })
keywordHandler:addKeyword({ "enemies" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_14" })
keywordHandler:addKeyword({ "bonelords" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"I'll tell you something. I have seen such a creature once, far on the ice to the east. It was the coldest winter I can remember and the chakoyas were roaming the ice almost everywhere. ...",
		"To evade them, me and the boys had to walk a long way to a spot where the ice was treacherous and thin. ...",
		"And there I've seen such a creature. The boys went almost mad and I turned my sled immediately. No idea how we made it home. True story.",
	},
})
keywordHandler:addKeyword({ "edron" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_15" })
keywordHandler:addAliasKeyword({ "thais" })
keywordHandler:addAliasKeyword({ "carlin" })
keywordHandler:addAliasKeyword({ "venore" })
keywordHandler:addAliasKeyword({ "port hope" })
keywordHandler:addKeyword({ "druids" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_16" })
keywordHandler:addKeyword({ "shamans" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_17" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_18" })
keywordHandler:addAliasKeyword({ "queen" })
keywordHandler:addKeyword({ "leader" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_19" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_20" })
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_21" })
keywordHandler:addKeyword({ "gods" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_22" })
keywordHandler:addAliasKeyword({ "uman" })
keywordHandler:addAliasKeyword({ "zathroth" })
keywordHandler:addAliasKeyword({ "banor" })
keywordHandler:addKeyword({ "chyll" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.iskan.stdmod_23" })

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
