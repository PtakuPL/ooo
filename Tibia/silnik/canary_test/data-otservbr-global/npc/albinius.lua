local internalNpcName = "Albinius"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 634,
	lookHead = 0,
	lookBody = 19,
	lookLegs = 86,
	lookFeet = 60,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.shop = {
	{ itemName = "heavy old tome", clientId = 23986, sell = 30 },
}
-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end
-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

local talkState = {}
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

local runes = {
	{ runeid = 24954 },
	{ runeid = 24955 },
	{ runeid = 24956 },
	{ runeid = 24957 },
	{ runeid = 24958 },
	{ runeid = 24959 },
}

local function getTable()
	local itemsList = {
		{ name = "heavy old tome", id = 23986, sell = 30 },
	}
	return itemsList
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "shapers") then
		npcHandler:say({
			"The {Shapers} were an advanced civilisation, well versed in art, construction, language and exploration of our world in their time. ...",
			"The foundations of this {temple} are testament to their genius and advanced understanding of complex problems. They were master craftsmen and excelled in magic.",
		}, npc, creature)
	end

	if MsgContains(message, "temple") then
		npcHandler:sayLocalized("npc.albinius.the_temple_has_1", npc, creature)
		npcHandler:setTopic(playerId, 1)
	end
	if MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Tomes) == 1 then
			npcHandler:sayLocalized("npc.albinius.you_already_offered_2", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			if player:getItemCount(23986) >= 5 then
				player:removeItem(23986, 5)
				npcHandler:sayLocalized("npc.albinius.thank_you_very_3", npc, creature)
				player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Tomes, 1)
			else
				npcHandler:sayLocalized("npc.albinius.you_need_heavy_4", npc, creature)
			end
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 1 then
		npcHandler:sayLocalized("npc.albinius.i_understand_return_5", npc, creature)
		npcHandler:removeInteraction(npc, creature)
	end

	if MsgContains(message, "tomes") and player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Tomes) < 1 then
		npcHandler:sayLocalized("npc.albinius.if_you_have_6", npc, creature)
		npcHandler:setTopic(playerId, 7)
	end

	if MsgContains(message, "buy") then
		npcHandler:sayLocalized("npc.albinius.im_sorry_i_7", npc, creature)
		npc:openShopWindow(creature)
	end

	--- ##Astral Shaper Rune##
	if MsgContains(message, "astral shaper rune") then
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.LastLoreKilled) >= 1 then
			npcHandler:sayLocalized("npc.albinius.do_you_wish_8", npc, creature)
			npcHandler:setTopic(playerId, 8)
		else
			npcHandler:sayLocalized("npc.albinius.im_sorry_but_9", npc, creature)
		end
	end

	if MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 8 then
		local haveParts = false
		for k = 1, #runes do
			if player:removeItem(runes[k].runeid, 1) then
				haveParts = true
			end
		end
		if haveParts then
			npcHandler:sayLocalized("npc.albinius.as_you_wish_10", npc, creature)
			player:addItem(24960, 1)
			npcHandler:removeInteraction(npc, creature)
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 8 then
		npcHandler:say("ok.", npc, creature)
		npcHandler:removeInteraction(npc, creature)
	end

	--- ####PORTALS###
	-- Ice Portal
	if MsgContains(message, "ice portal") then
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Tomes) == 1 and player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.FormorgarMinesDoor) == 1 then
			npcHandler:sayLocalized("npc.albinius.you_may_pass_11", npc, creature)
			npcHandler:setTopic(playerId, 2)
		else
			npcHandler:sayLocalized("npc.albinius.sorry_you_first_12", npc, creature)
		end
	end

	if MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 2 then
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessIce) < 1 and player:getItemCount(3578) >= 50 then
			player:removeItem(3578, 50)
			npcHandler:sayLocalized("npc.albinius.thank_you_for_13", npc, creature)
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessIce, 1)
		else
			npcHandler:sayLocalized("npc.albinius.im_sorry_you_14", npc, creature)
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 2 then
		npcHandler:sayLocalized("npc.albinius.in_this_case_15", npc, creature)
	end

	-- Holy Portal
	if MsgContains(message, "holy portal") then
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Tomes) == 1 then
			npcHandler:sayLocalized("npc.albinius.you_may_pass_16", npc, creature)
			npcHandler:setTopic(playerId, 3)
		else
			npcHandler:sayLocalized("npc.albinius.sorry_first_you_17", npc, creature)
		end
	end

	if MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 3 then
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessGolden) < 1 and player:getItemCount(18929) >= 50 then
			player:removeItem(18929, 50)
			npcHandler:sayLocalized("npc.albinius.thank_you_for_18", npc, creature)
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessGolden, 1)
		else
			npcHandler:sayLocalized("npc.albinius.im_sorry_you_19", npc, creature)
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 3 then
		npcHandler:sayLocalized("npc.albinius.in_this_case_20", npc, creature)
	end

	-- Energy Portal
	if MsgContains(message, "energy portal") then
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Tomes) == 1 then
			npcHandler:sayLocalized("npc.albinius.you_may_pass_21", npc, creature)
			npcHandler:setTopic(playerId, 4)
		else
			npcHandler:sayLocalized("npc.albinius.sorry_first_you_22", npc, creature)
		end
	end

	if MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 4 then
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessViolet) < 1 and player:getItemCount(17462) >= 50 then
			player:removeItem(17462, 50)
			npcHandler:sayLocalized("npc.albinius.thank_you_for_23", npc, creature)
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessViolet, 1)
		else
			npcHandler:sayLocalized("npc.albinius.im_sorry_you_24", npc, creature)
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 4 then
		npcHandler:sayLocalized("npc.albinius.in_this_case_25", npc, creature)
	end

	-- Earth Portal
	if MsgContains(message, "earth portal") then
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Tomes) == 1 then
			npcHandler:sayLocalized("npc.albinius.you_may_pass_26", npc, creature)
			npcHandler:setTopic(playerId, 5)
		else
			npcHandler:sayLocalized("npc.albinius.sorry_first_you_27", npc, creature)
		end
	end

	if MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 5 then
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessEarth) < 1 and player:getItemCount(10296) >= 50 then
			player:removeItem(10296, 50)
			npcHandler:sayLocalized("npc.albinius.thank_you_for_28", npc, creature)
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessEarth, 1)
		else
			npcHandler:sayLocalized("npc.albinius.im_sorry_you_29", npc, creature)
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 5 then
		npcHandler:sayLocalized("npc.albinius.in_this_case_30", npc, creature)
	end

	-- Death Portal
	if MsgContains(message, "death portal") then
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Tomes) == 1 then
			npcHandler:sayLocalized("npc.albinius.you_may_pass_31", npc, creature)
			npcHandler:setTopic(playerId, 6)
		else
			npcHandler:sayLocalized("npc.albinius.sorry_first_you_32", npc, creature)
		end
	end

	if MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 6 then
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessDeath) < 1 and player:getItemCount(11481) >= 50 then
			player:removeItem(11481, 50)
			npcHandler:sayLocalized("npc.albinius.thank_you_for_33", npc, creature)
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessDeath, 1)
		else
			npcHandler:sayLocalized("npc.albinius.im_sorry_you_34", npc, creature)
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 6 then
		npcHandler:sayLocalized("npc.albinius.in_this_case_35", npc, creature)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings, pilgrim. Welcome to the halls of hope. We are the keepers of this {temple} and welcome everyone willing to contribute.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Oh... farewell, child.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, text = "I am Albinius, a worshipper of the {Astral Shapers}." })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, text = "Precisely time." })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, text = "I find ways to unveil the secrets of the stars. Judging by this question, I doubt you follow my weekly publications concerning this research." })

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
