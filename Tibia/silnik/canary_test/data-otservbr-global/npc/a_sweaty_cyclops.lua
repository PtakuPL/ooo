local internalNpcName = "A Sweaty Cyclops"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 22,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Hum hum, huhum" },
	{ text = "Silly lil' human" },
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
local npcI18n = NPC_LIB and NPC_LIB.i18n
local questStorage = Storage.Quest.U7_8.FriendsandTraders.TheSweatyCyclops

local function sayToPlayer(npc, player, key, fallback)
	if not player then
		return false
	end

	if npcI18n then
		npcI18n.sayLocalized(player, key)
	else
		npcHandler:say(fallback, npc, player)
	end
	return true
end

local function addKeywordResponse(keywords, key, fallback)
	keywordHandler:addKeyword(keywords, function(npc, creature)
		local player = Player(creature)
		return sayToPlayer(npc, player, key, fallback)
	end)
end

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

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local questValue = player:getStorageValue(questStorage)
	if questValue < 0 then
		questValue = 0
	end

	if MsgContains(message, "uth'lokr") then
		if questValue < 1 then
			sayToPlayer(npc, player, "npc.a_sweaty_cyclops.quest_uth_lokr_offer", "Firy steel it is. Need green ones' breath to melt. Or red even better. Me can make from shield. Lil' one want to trade?")
			npcHandler:setTopic(playerId, 1)
		elseif questValue == 2 then
			sayToPlayer(npc, player, "npc.a_sweaty_cyclops.quest_uth_lokr_offer", "Firy steel it is. Need green ones' breath to melt. Or red even better. Me can make from shield. Lil' one want to trade?")
			npcHandler:setTopic(playerId, 6)
		end
	elseif MsgContains(message, "yes") then
		local topic = npcHandler:getTopic(playerId)
		if topic == 1 then
			sayToPlayer(npc, player, "npc.a_sweaty_cyclops.quest_bast_wait", "Wait. Me work no cheap is. Do favour for me first, yes?")
			npcHandler:setTopic(playerId, 2)
		elseif topic == 2 then
			sayToPlayer(npc, player, "npc.a_sweaty_cyclops.quest_bast_request", "Me need gift for woman. We dance, so me want to give her bast skirt. But she big is. So I need many to make big one. Bring three okay? Me wait.")
			if player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.DefaultStart) ~= 1 then
				player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.DefaultStart, 1)
			end
			player:setStorageValue(questStorage, 1)
			npcHandler:setTopic(playerId, 3)
		elseif topic == 4 then
			if player:removeItem(3560, 3) then
				sayToPlayer(npc, player, "npc.a_sweaty_cyclops.quest_bast_complete", "Good good! Woman happy will be. Now me happy too and help you.")
				player:setStorageValue(questStorage, 2)
				npcHandler:setTopic(playerId, 0)
			else
				sayToPlayer(npc, player, "npc.a_sweaty_cyclops.quest_bast_reminder", "Lil' one bring three bast skirts.")
				npcHandler:setTopic(playerId, 3)
			end
		elseif topic == 5 then
			if player:removeItem(3381, 1) then
				sayToPlayer(npc, player, "npc.a_sweaty_cyclops.response_cling_clang", "Cling clang!")
				player:addItem(5887, 1)
				npcHandler:setTopic(playerId, 0)
			end
		elseif topic == 6 then
			if player:removeItem(3416, 1) then
				sayToPlayer(npc, player, "npc.a_sweaty_cyclops.response_cling_clang", "Cling clang!")
				player:addItem(5889, 1)
				npcHandler:setTopic(playerId, 0)
			end
		elseif topic == 7 then
			if player:removeItem(3356, 1) then
				sayToPlayer(npc, player, "npc.a_sweaty_cyclops.response_cling_clang", "Cling clang!")
				player:addItem(5888, 1)
				npcHandler:setTopic(playerId, 0)
			end
		elseif topic == 8 then
			if player:removeItem(3281, 1) then
				sayToPlayer(npc, player, "npc.a_sweaty_cyclops.response_cling_clang", "Cling clang!")
				player:addItem(5892, 1)
				npcHandler:setTopic(playerId, 0)
			end
		elseif topic == 9 then
			local orbCount = player:getItemCount(5944)
			if orbCount > 0 then
				for i = 1, orbCount do
					player:removeItem(5944, 1)
					if math.random(100) <= 1 then
						player:addItem(6528, 6)
						sayToPlayer(npc, player, "npc.a_sweaty_cyclops.response_cling_clang_bonus", "Cling clang! Me done good work today! Li'l one gets double bolts!")
					else
						player:addItem(6528, 3)
						sayToPlayer(npc, player, "npc.a_sweaty_cyclops.response_cling_clang", "Cling clang!")
					end
				end
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "bast skirt") and questValue == 1 then
		if npcHandler:getTopic(playerId) == 3 then
			sayToPlayer(npc, player, "npc.a_sweaty_cyclops.quest_bast_check", "Lil' one bring three bast skirts?")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "uth'kean") and questValue == 2 then
		sayToPlayer(npc, player, "npc.a_sweaty_cyclops.quest_uth_kean_offer", "Very noble. Shiny. Me like. But breaks so fast. Me can make from shiny armour. Lil' one want to trade?")
		npcHandler:setTopic(playerId, 5)
	elseif MsgContains(message, "za'ralator") and questValue == 2 then
		sayToPlayer(npc, player, "npc.a_sweaty_cyclops.quest_za_ralator_offer", "Hellsteel is. Cursed and evil. Dangerous to work with. Me can make from evil helmet. Lil' one want to trade?")
		npcHandler:setTopic(playerId, 7)
	elseif MsgContains(message, "uth'prta") and questValue == 2 then
		sayToPlayer(npc, player, "npc.a_sweaty_cyclops.quest_uth_prta_offer", "Good iron is. Me friends use it much for fight. Me can make from weapon. Lil' one want to trade?")
		npcHandler:setTopic(playerId, 8)
	elseif MsgContains(message, "soul orb") and questValue == 2 then
		sayToPlayer(npc, player, "npc.a_sweaty_cyclops.quest_soul_orb_offer", "Uh. Me can make some nasty lil' bolt from soul orbs. Lil' one want to trade all?")
		npcHandler:setTopic(playerId, 9)
	end

	return true
end

addKeywordResponse({ "job" }, "npc.a_sweaty_cyclops.job", "I am smith.")
addKeywordResponse({ "smith" }, "npc.a_sweaty_cyclops.smith", "Working steel is my profession.")
addKeywordResponse({ "steel" }, "npc.a_sweaty_cyclops.steel", "Manny kinds of. Like {Mesh Kaha Rogh'}, {Za'Kalortith}, {Uth'Byth}, {Uth'Morc}, {Uth'Amon}, {Uth'Maer}, {Uth'Doon}, and {Zatragil}.")
addKeywordResponse({ "zatragil" }, "npc.a_sweaty_cyclops.zatragil", "Most ancients use dream silver for different stuff. Now ancients most gone. Most not know about.")
addKeywordResponse({ "uth'doon" }, "npc.a_sweaty_cyclops.uth_doon", "It's high steel called. Only lil' lil' ones know how make.")
addKeywordResponse({ "za'kalortith" }, "npc.a_sweaty_cyclops.za_kalortith", "It's evil. Demon iron is. No good cyclops goes where you can find and need evil flame to melt.")
addKeywordResponse({ "mesh kaha rogh" }, "npc.a_sweaty_cyclops.mesh_kaha_rogh", "Steel that is singing when forged. No one knows where find today.")
addKeywordResponse({ "uth'byth" }, "npc.a_sweaty_cyclops.uth_byth", "Not good to make stuff off. Bad steel it is. But eating magic, so useful is.")
addKeywordResponse({ "uth'maer" }, "npc.a_sweaty_cyclops.uth_maer", "Brightsteel is. Much art made with it. Sorcerers too lazy and afraid to enchant much.")
addKeywordResponse({ "uth'amon" }, "npc.a_sweaty_cyclops.uth_amon", "Heartiron from heart of big old mountain, found very deep. Lil' lil ones fiercely defend. Not wanting to have it used for stuff but holy stuff.")
addKeywordResponse({ "ab'dendriel" }, "npc.a_sweaty_cyclops.ab_dendriel", "Me parents live here before town was. Me not care about lil' ones.")
addKeywordResponse({ "lil' lil'" }, "npc.a_sweaty_cyclops.lil_lil", "Lil' lil' ones are so fun. We often chat.")
addKeywordResponse({ "tibia" }, "npc.a_sweaty_cyclops.tibia", "One day I'll go and look.")
addKeywordResponse({ "teshial" }, "npc.a_sweaty_cyclops.teshial", "Is one of elven family or such thing. Me not understand lil' ones and their business.")
addKeywordResponse({ "cenath" }, "npc.a_sweaty_cyclops.cenath", "Is one of elven family or such thing. Me not understand lil' ones and their business.")
addKeywordResponse({ "name" }, "npc.a_sweaty_cyclops.name", "I called Bencthyclthrtrprr by me people. Lil' ones me call Big Ben.")
addKeywordResponse({ "god" }, "npc.a_sweaty_cyclops.god", "You shut up. Me not want to hear.")
addKeywordResponse({ "fire sword" }, "npc.a_sweaty_cyclops.fire_sword", "Do lil' one want to trade a fire sword?")
addKeywordResponse({ "dragon shield" }, "npc.a_sweaty_cyclops.dragon_shield", "Do lil' one want to trade a dragon shield?")
addKeywordResponse({ "sword of valor" }, "npc.a_sweaty_cyclops.sword_valor", "Do lil' one want to trade a sword of valor?")
addKeywordResponse({ "warlord sword" }, "npc.a_sweaty_cyclops.warlord_sword", "Do lil' one want to trade a warlord sword?")
addKeywordResponse({ "minotaurs" }, "npc.a_sweaty_cyclops.minotaurs", "They were friend with me parents. Long before elves here, they often made visit. No longer come here.")
addKeywordResponse({ "elves" }, "npc.a_sweaty_cyclops.elves", "Me not fight them, they not fight me.")
addKeywordResponse({ "excalibug" }, "npc.a_sweaty_cyclops.excalibug", "Me wish I could make weapon like it.")
addKeywordResponse({ "cyclops" }, "npc.a_sweaty_cyclops.cyclops", "Me people not live here much. Most are far away.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

if npcI18n and npcHandler.setLocalizedMessage then
	npcI18n.setLocalizedGreet(npcHandler, "npc.a_sweaty_cyclops.greet")
	npcI18n.setLocalizedFarewell(npcHandler, "npc.a_sweaty_cyclops.farewell")
	npcI18n.setLocalizedWalkaway(npcHandler, "npc.a_sweaty_cyclops.walkaway")
else
	npcHandler:setMessage(MESSAGE_GREET, "Hum Humm! Welcume lil' |PLAYERNAME|.")
	npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye lil' one.")
	npcHandler:setMessage(MESSAGE_WALKAWAY, "Don't leave lil' one waiting!")
end

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
