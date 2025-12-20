local internalNpcName = "Emma"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 139,
	lookHead = 79,
	lookBody = 90,
	lookLegs = 52,
	lookFeet = 15,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
local fire = Condition(CONDITION_FIRE)
fire:setParameter(CONDITION_PARAM_DELAYED, true)
fire:setParameter(CONDITION_PARAM_FORCEUPDATE, true)
fire:addDamage(25, 9000, -10)
npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 1)
			player:addAchievement("Secret Agent")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_1")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:removeItem(648, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.CGBMission01, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 3)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_2")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_3")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(652, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.CGBMission02, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 5)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_4")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_5")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.CGBMission03, 3)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 7)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_6")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(399, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.CGBMission04, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 9)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_7")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_8")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:removeItem(400, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.CGBMission05, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 11)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_9")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_10")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			if player:removeItem(401, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.CGBMission06, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 13)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_11")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_12")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeItem(396, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Mission07, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 15)
				player:addAchievement("Top CGB Agent")
				player:addItem(898, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_24")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_25")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_26")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_13")
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_14")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "join") then
		if player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) < 1 then
			if player:getSex() == PLAYERSEX_FEMALE then
				npcHandler:say(
					"The girls brigade is the foremost front on which we fight the numerous enemies of our city ... It's a constant race to stay ahead of our enemies. Absolute loyalty and the willingness to put ones life at stake are attributes that are vital for this brigade ... If you join, you dedicate your service to Carlin alone! Do you truly think that you are girl enough to join the brigade?",
					npc,
					creature
				)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_15")
			end
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission01) > 0 or player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission01) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_16")
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 1 and player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission01) < 1 and player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission01) < 1 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 2)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.CGBMission01, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_22")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_23")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission01) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_17")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission01) == 2 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 3 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 4)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.CGBMission02, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_20")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission02) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_18")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission02) == 2 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 5 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 6)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.CGBMission03, 1)
			player:addItem(350, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_13")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission03) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_19")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission03) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 7 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 8)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.CGBMission04, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_10")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission04) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_20")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission04) == 2 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 9 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 10)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.CGBMission05, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_8")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission05) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_21")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission05) == 2 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 11 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 12)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.CGBMission06, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_5")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission06) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_22")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission06) == 2 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 13 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 14)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Mission07, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.multi_2")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission06) == 2 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Mission07) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emma.say_23")
			npcHandler:setTopic(playerId, 8)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)
-- basic
keywordHandler:addKeyword({ "queen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.emma.stdmod_1" })
keywordHandler:addKeyword({ "carlin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.emma.stdmod_2" })
keywordHandler:addKeyword({ "service" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.emma.stdmod_3" })
keywordHandler:addKeyword({ "cgb" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The CGB is a patriotic organisation that fights our numerous enemies with means that guards or army do not have at their disposal. ...",
		"We work secretly and covertly. We uncover secret plots and we are both the first line of defence of our city and the last. We are joined only by the best of the best.",
	},
})
keywordHandler:addKeyword({ "avin" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The AVIN is rather a crime syndicate than anything else. If there is something dirty and illegal, they are most likely involved. ...",
		"They are unscrupulous and also do not back away from blackmailing and assassination.",
	},
})
keywordHandler:addKeyword({ "tbi" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The TBI is as old-fashioned, stubborn and inflexible as only males can be. What makes this bureaucracy somewhat dangerous, is the money they have at their disposal. ...",
		"They buy spies and traitors - all of them weak-willed or greedy individuals.",
	},
})
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.emma.stdmod_4" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.emma.stdmod_5" })
keywordHandler:addKeyword({ "ab'dendriel" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The elves of Ab'Dendriel are our allies. Our druids contribute most to keeping such a good relation. ...",
		"They seem to understand the elves a bit better than we ordinary people do.",
	},
})
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.emma.stdmod_6" })
keywordHandler:addKeyword({ "venore" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.emma.stdmod_7" })
keywordHandler:addKeyword({ "svargrond" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.emma.stdmod_8" })
keywordHandler:addKeyword({ "ankrahmun" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.emma.stdmod_9" })
keywordHandler:addKeyword({ "darashia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.emma.stdmod_10" })
keywordHandler:addKeyword({ "liberty bay" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The name of the city is a cruel joke. The people there are oppressed by Thais and Venore who slowly bleed the isle and its people white. ...",
		"It shows what would have happened to us if our rebellion had failed.",
	},
})
keywordHandler:addKeyword({ "port hope" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.emma.stdmod_11" })
keywordHandler:addKeyword({ "kazordoon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.emma.stdmod_12" })
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.emma.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.emma.farewell_msg_1")
-- npcType registering the npcConfig table
npcType:register(npcConfig)
