local internalNpcName = "Ortheus"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 153,
	lookHead = 40,
	lookBody = 121,
	lookLegs = 121,
	lookFeet = 116,
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

local BloodBrothers = Storage.Quest.U8_4.BloodBrothers
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()
	if message == "cookie" then
		if player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission02) == 1 and player:getItemCount(8199) > 0 and player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Ortheus) < 0 then
			npcHandler:sayLocalized("npc.ortheus.a_cookie_well_1", npc, creature)
			npcHandler:setTopic(playerId, 1)
		else
			npcHandler:sayLocalized("npc.ortheus.itd_be_better_2", npc, creature)
		end
	elseif message == "yes" then
		if npcHandler:getTopic(playerId) == 1 and player:removeItem(8199, 1) then -- garlic cookie
			npcHandler:sayLocalized("npc.ortheus.well_thanks_it_3", npc, creature)
			player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Ortheus, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:removeItem(2880, 17) then -- mug of tea
				npcHandler:sayLocalized("npc.ortheus.wow_these_polite_4", npc, creature)
				npcHandler:setTopic(playerId, 0)
			else
				npcHandler:sayLocalized("npc.ortheus.hmmm_you_dont_5", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif message == "tea" then
		npcHandler:sayLocalized("npc.ortheus.have_you_actually_6", npc, creature)
		npcHandler:setTopic(playerId, 2)
	elseif message == "no" then
		if npcHandler:getTopic(playerId) == 2 then
			npcHandler:sayLocalized("npc.ortheus.what_a_pity_7", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	end
end
--Basic
keywordHandler:addKeyword({ "magicians" }, StdModule.say, { npcHandler = npcHandler, text = "I can't imagine a better place to live." })
keywordHandler:addKeyword({ "live" }, StdModule.say, { npcHandler = npcHandler, text = "Though the city has seen better days, the quality of life is still much better than in most other cities." })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, text = "Hm, good question. Maybe old, wise man?" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, text = "I'm used to being called old man. Simple as that." })
keywordHandler:addKeyword({ "vampire" }, StdModule.say, { npcHandler = npcHandler, text = "I don't know what you're talking about." })
keywordHandler:addKeyword({ "blood" }, StdModule.say, { npcHandler = npcHandler, text = "Yes, it's a bit messy down there. Sorry." })
keywordHandler:addKeyword({ "julius" }, StdModule.say, { npcHandler = npcHandler, text = "Doesn't ring a bell." })
keywordHandler:addKeyword({ "armenius" }, StdModule.say, { npcHandler = npcHandler, text = "He rarely comes here." })
keywordHandler:addKeyword({ "maris" }, StdModule.say, { npcHandler = npcHandler, text = "A man of the seas." })
keywordHandler:addKeyword({ "lisander" }, StdModule.say, { npcHandler = npcHandler, text = "He used to visit me for a chat, but ever since that new tavern opened I haven't seen him much anymore." })
keywordHandler:addKeyword({ "serafin" }, StdModule.say, { npcHandler = npcHandler, text = "He sometimes delivers fruit and vegetables to this quarter." })
keywordHandler:addKeyword({ "yalahar" }, StdModule.say, { npcHandler = npcHandler, text = "Though the city has seen better days, the quality of life is still much better than in most other cities." })
keywordHandler:addKeyword({ "quarter" }, StdModule.say, { npcHandler = npcHandler, text = "I can't imagine a better place to live" })
keywordHandler:addKeyword({ "alori mort" }, StdModule.say, { npcHandler = npcHandler, text = "Whatever that's supposed to mean." }, function(player)
	return player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission03) == 1
end)
keywordHandler:addKeyword({ "reward" }, StdModule.say, { npcHandler = npcHandler, text = "I don't have anything that I could give you as a reward. Guess you aren't so selfless after all, huh?" })
keywordHandler:addKeyword({ "augur" }, StdModule.say, { npcHandler = npcHandler, text = "They try to protect the city and do a decent job. Well - no, a poor job, I mean a poor job." })
keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, text = "You can bring me a mug of tea if you want to." })
keywordHandler:addAliasKeyword({ "quest" })

npcHandler:setMessage(MESSAGE_GREET, "What's your business here with the {magicians}, |PLAYERNAME|?")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
