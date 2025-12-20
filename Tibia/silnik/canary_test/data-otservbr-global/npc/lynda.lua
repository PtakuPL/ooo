local internalNpcName = "Lynda"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 138,
	lookHead = 79,
	lookBody = 81,
	lookLegs = 67,
	lookFeet = 95,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "angelina") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWand) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.multi_10")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "wand") or MsgContains(message, "rod") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWand) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_1")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "sulphur") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWand) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_2")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "soul stone") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWand) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_3")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "ankh") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWand) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_4")
			npcHandler:setTopic(playerId, 6)
		end
	elseif MsgContains(message, "ritual") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWand) == 6 then
			if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWandTimer) < os.time() then
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWand, 7)
				player:addOutfitAddon(138, 1) --female mage addon
				player:addOutfitAddon(141, 1) --female summoner addon
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_5")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_6")
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.multi_7")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_7")
			player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWand, 2)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:getItemCount(3065) > 0 and player:getItemCount(3066) > 0 and player:getItemCount(3067) > 0 and player:getItemCount(3069) > 0 and player:getItemCount(3070) > 0 and player:getItemCount(3071) > 0 and player:getItemCount(3072) > 0 and player:getItemCount(3073) > 0 and player:getItemCount(3074) > 0 and player:getItemCount(3075) > 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_8")
				player:removeItem(3065, 1)
				player:removeItem(3066, 1)
				player:removeItem(3067, 1)
				player:removeItem(3069, 1)
				player:removeItem(3070, 1)
				player:removeItem(3071, 1)
				player:removeItem(3072, 1)
				player:removeItem(3073, 1)
				player:removeItem(3074, 1)
				player:removeItem(3075, 1)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWand, 3)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(5904, 10) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_9")
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWand, 4)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(5809, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_10")
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWand, 5)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:removeItem(3077, 20) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_11")
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWand, 6)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonWandTimer, os.time() + 10800)
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
end

local function tryEngage(npc, creature, message, keywords, parameters, node)
	local player = Player(creature)
	local playerStatus = getPlayerMarriageStatus(player:getGuid())
	local playerSpouse = getPlayerSpouse(player:getGuid())
	if playerStatus == MARRIED_STATUS then -- check if the player is already married
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_1", { player:getName() })
	elseif playerStatus == PROPOSED_STATUS then --check if the player already made a proposal to some1 else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_2", { player:getName() })
	else
		local candidate = getPlayerGUIDByName(message)
		if candidate == 0 then -- check if there is actually a player called like this
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_12")
		elseif candidate == player:getGuid() then -- if it's himself, cannot marry
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_13")
		else
			if player:getItemCount(ITEM_WEDDING_RING) == 0 or player:getItemCount(9586) == 0 then -- check for items (wedding ring and outfit box)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_14")
			else
				local candidateStatus = getPlayerMarriageStatus(candidate)
				local candidateSpouse = getPlayerSpouse(candidate)
				if candidateStatus == MARRIED_STATUS then -- if the player you want to marry is already married and to whom
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_3", { getPlayerNameById(candidate), getPlayerNameById(candidateSpouse) })
				elseif candidateStatus == PROPACCEPT_STATUS then -- if the player you want to marry is already going to marry some1 else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_4", { getPlayerNameById(candidate), getPlayerNameById(candidateSpouse) })
				elseif candidateStatus == PROPOSED_STATUS then -- if he/she already made a proposal to some1
					if candidateSpouse == player:getGuid() then -- if this someone is you.
						-- if this some1 is not you
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_15")
						player:removeItem(ITEM_WEDDING_RING, 1)
						player:removeItem(9586, 1) -- wedding outfit box
						player:addOutfit(329) --Wife
						player:addOutfit(328) --Husb
						setPlayerMarriageStatus(player:getGuid(), PROPACCEPT_STATUS)
						setPlayerMarriageStatus(candidate, PROPACCEPT_STATUS)
						setPlayerSpouse(player:getGuid(), candidate)
						local player = Player(getPlayerNameById(candidate))
						player:addOutfit(329)
						player:addOutfit(328)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_5", { getPlayerNameById(candidate), getPlayerNameById(candidateSpouse) })
					end
				else -- if the player i want to propose doesn't have other proposal
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_6", { getPlayerNameById(candidate), getPlayerNameById(candidate) })
					player:removeItem(ITEM_WEDDING_RING, 1)
					player:removeItem(9586, 1)
					setPlayerMarriageStatus(player:getGuid(), PROPOSED_STATUS)
					setPlayerSpouse(player:getGuid(), candidate)
				end
			end
		end
	end
	keywordHandler:moveUp(player, 1)
	return false
end

local function confirmWedding(npc, creature, message, keywords, parameters, node)
	local player = Player(creature)
	local playerStatus = getPlayerMarriageStatus(player:getGuid())
	local candidate = getPlayerSpouse(player:getGuid())
	if playerStatus == PROPACCEPT_STATUS then
		--  local item3 = Item(doPlayerAddItem(creature,ITEM_Meluna_Ticket,2))
		setPlayerMarriageStatus(player:getGuid(), MARRIED_STATUS)
		setPlayerMarriageStatus(candidate, MARRIED_STATUS)
		setPlayerSpouse(player:getGuid(), candidate)
		setPlayerSpouse(candidate, player:getGuid())
		local itemAttribute = Item(doPlayerAddItem(creature, ITEM_ENGRAVED_WEDDING_RING, 1))
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { { "npc.lynda.say_7", { getPlayerNameById(candidate), player:getName() } }, "npc.lynda.say_8", "npc.lynda.say_9", { "npc.lynda.say_10", { player:getName() } }, "npc.lynda.say_11" }, 10000)
		itemAttribute:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, player:getName() .. " & " .. getPlayerNameById(candidate) .. " forever - married on " .. os.date("%B %d, %Y."))
		itemAttribute:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, player:getName() .. " & " .. getPlayerNameById(candidate) .. " forever - married on " .. os.date("%B %d, %Y."))
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_16")
	end
	return true
end
-- END --

local function confirmRemoveEngage(npc, creature, message, keywords, parameters, node)
	local player = Player(creature)
	local playerStatus = getPlayerMarriageStatus(player:getGuid())
	local playerSpouse = getPlayerSpouse(player:getGuid())
	if playerStatus == PROPOSED_STATUS then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_12", { getPlayerNameById(playerSpouse) })
		node:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, moveup = 3, i18nKey = "npc.lynda.stdmod_1" })

		local function removeEngage(creature, message, keywords, parameters, node)
			doPlayerAddItem(creature, ITEM_WEDDING_RING, 1)
			doPlayerAddItem(creature, 9586, 1)
			setPlayerMarriageStatus(player:getGuid(), 0)
			setPlayerSpouse(player:getGuid(), -1)
			npcHandler:say(parameters.text, npc, creature)
			keywordHandler:moveUp(player, parameters.moveup)
		end
		node:addChildKeyword({ "yes" }, removeEngage, { moveup = 3, i18nKey = "npc.lynda.keyword_1" .. getPlayerNameById(playerSpouse) .. "} has been removed. Take your wedding ring back." })
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_18")
		keywordHandler:moveUp(player, 2)
	end
	return true
end

local function confirmDivorce(npc, creature, message, keywords, parameters, node)
	local player = Player(creature)
	local playerStatus = getPlayerMarriageStatus(player:getGuid())
	local playerSpouse = getPlayerSpouse(player:getGuid())
	if playerStatus == MARRIED_STATUS then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_13", { getPlayerNameById(playerSpouse) })
		node:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, moveup = 3, i18nKey = "npc.lynda.stdmod_2" })

		local function divorce(creature, message, keywords, parameters, node)
			local player = Player(creature)
			local spouse = getPlayerSpouse(player:getGuid())
			setPlayerMarriageStatus(player:getGuid(), 0)
			setPlayerSpouse(player:getGuid(), -1)
			setPlayerMarriageStatus(spouse, 0)
			setPlayerSpouse(spouse, -1)
			npcHandler:say(parameters.text, npc, creature)
			keywordHandler:moveUp(player, parameters.moveup)
		end
		node:addChildKeyword({ "yes" }, divorce, { moveup = 3, i18nKey = "npc.lynda.keyword_2" .. getPlayerNameById(playerSpouse) .. "}. Think better next time after marrying someone." })
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lynda.say_20")
		keywordHandler:moveUp(player, 2)
	end
	return true
end

local node1 = keywordHandler:addKeyword({ "marry" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, i18nKey = "npc.lynda.stdmod_3" })
node1:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, moveup = 1, i18nKey = "npc.lynda.stdmod_4" })
local node2 = node1:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, i18nKey = "npc.lynda.stdmod_5" })
node2:addChildKeyword({ "[%w]" }, tryEngage, {})

local node3 = keywordHandler:addKeyword({ "celebration" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, i18nKey = "npc.lynda.stdmod_6" })
node3:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, moveup = 1, i18nKey = "npc.lynda.stdmod_7" })
local node4 = node3:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, i18nKey = "npc.lynda.stdmod_8" }) --, confirmWedding, {})
node4:addChildKeyword({ "begin" }, confirmWedding, {})

keywordHandler:addKeyword({ "remove" }, confirmRemoveEngage, {})

keywordHandler:addKeyword({ "divorce" }, confirmDivorce, {})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.lynda.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.lynda.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.lynda.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
