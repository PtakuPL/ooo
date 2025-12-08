local internalNpcName = "Oldrak"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 150
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 57,
	lookHead = 115,
	lookBody = 113,
	lookLegs = 31,
	lookFeet = 38,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

-- Load NPC helper library
dofile(CORE_DIRECTORY .. "/libs/npc/i18n.lua")

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

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, text = "I guard this humble temple as a monument for the order of the {nightmare knights}." })
keywordHandler:addAliasKeyword({ "visitors" })

keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, text = "My name is Oldrak." })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, text = "These plains are not safe for ordinary travellers. It will take heroes to survive here." })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, text = "I can't help you, sorry!" })
keywordHandler:addKeyword({ "goshnar" }, StdModule.say, { npcHandler = npcHandler, text = "The greatest necromant who ever cursed our land with the steps of his feet. He was defeated by the nightmare knights." })
keywordHandler:addKeyword({ "nightmare" }, StdModule.say, { npcHandler = npcHandler, text = "This ancient order was created by a circle of wise humans who were called 'The {Dreamers}'. The order became {extinct} a long time ago." })
keywordHandler:addKeyword({ "extinct" }, StdModule.say, { npcHandler = npcHandler, text = "Many perished in their battles against evil, some went mad, not able to stand their nightmares any longer. Others were seduced by the darkness." })
keywordHandler:addKeyword({ "dreamers" }, StdModule.say, { npcHandler = npcHandler, text = "They learned the ancient art of {dreamwalking} from some elves they befriended." })
keywordHandler:addKeyword({ "dreamwalking" }, StdModule.say, { npcHandler = npcHandler, text = "While the dreamwalkers of the elves experienenced the brightest dreams of pleasure, the humans strangely had dreams of {dark omen}." })
keywordHandler:addKeyword({ "omen" }, StdModule.say, { npcHandler = npcHandler, text = "They dreamed of doom, destruction, talked to dead, tormented souls, and gained unwanted insight into the {schemes of darkness}." })
keywordHandler:addKeyword({ "schemes of darkness" }, StdModule.say, { npcHandler = npcHandler, text = "They figured out how to interpret their dark dreams and so could foresee the plans of the dark gods and their minions." })
keywordHandler:addKeyword({ "plan" }, StdModule.say, { npcHandler = npcHandler, text = "Using this knowledge they formed an order to thwart these plans, and because they battled their nightmares as brave as knights, they named their order accordingly." })
keywordHandler:addKeyword({ "necromant" }, StdModule.say, { npcHandler = npcHandler, text = "It is rumoured to open the entrance to the pits of inferno, also called the nightmare pits. Even if I knew about this secret I wouldn't tell you." })
keywordHandler:addKeyword({ "havok" }, StdModule.say, { npcHandler = npcHandler, text = "Before the battles raged across them, they were called the fair plains." })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, text = "That's where we are. The world of Tibia." })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, text = "They created Tibia and all life on it ... and unlife, too." })
keywordHandler:addKeyword({ "unlife" }, StdModule.say, { npcHandler = npcHandler, text = "Beware the foul undead!" })
keywordHandler:addKeyword({ "undead" }, StdModule.say, { npcHandler = npcHandler, text = "Beware the foul undead!" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, text = "A weapon of myth and legend. It was lost in ancient times ... perhaps lost forever." })
keywordHandler:addKeyword({ "yenny the gentle" }, StdModule.say, { npcHandler = npcHandler, text = "Yenny, known as the Gentle, was one of most powerfull magicwielders in ancient times and known throughout the world for her mercy and kindness." })
keywordHandler:addKeyword({ "offer" }, StdModule.say, { npcHandler = npcHandler, text = "I can offer you the holy tible for a small fee." })
keywordHandler:addKeyword({ "trade" }, StdModule.say, { npcHandler = npcHandler, text = "I can offer you the holy tible for a small fee." })
keywordHandler:addKeyword({ "sell" }, StdModule.say, { npcHandler = npcHandler, text = "I can offer you the holy tible for a small fee." })
keywordHandler:addKeyword({ "buy" }, StdModule.say, { npcHandler = npcHandler, text = "I can offer you the holy tible for a small fee." })
keywordHandler:addKeyword({ "have" }, StdModule.say, { npcHandler = npcHandler, text = "I can offer you the holy tible for a small fee." })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, text = "Now, it is |TIME|." })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- Demon oak quest
	if MsgContains(message, "mission") or MsgContains(message, "demon oak") then
		if player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Done) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.mission_ask")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Progress) == 2 and player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Done) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.mission_wait")
		elseif player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Done) == 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
				"npc.oldrak.mission_done_1",
				"npc.oldrak.mission_done_2",
				"npc.oldrak.mission_done_3",
			})
			player:setStorageValue(Storage.Quest.U8_2.TheDemonOak.Done, 2)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		player:setStorageValue(Storage.Quest.U8_2.TheDemonOak.Progress, 1)
		if player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Progress) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.mission_yes")
			player:setStorageValue(Storage.Quest.U8_2.TheDemonOak.Progress, 2)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.mission_lie")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "axe") then
		if player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Progress) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.axe_ask")
			npcHandler:setTopic(playerId, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.axe_first")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 2 then
		if player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Progress) == 2 then
			if player:getMoney() + player:getBankBalance() >= 1000 then
				if player:removeItem(3274, 1) and player:removeMoneyBank(1000) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.axe_done")
					player:addItem(919, 1)
					npc:getPosition():sendMagicEffect(CONST_ME_YELLOWENERGY)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.axe_missing")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.money_missing")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.mission_no")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.axe_no")
		npcHandler:setTopic(playerId, 0)
	end

	-- The paradox tower quest
	if MsgContains(message, "hugo") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.hugo")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "myth") then
		if player:getStorageValue(Storage.Quest.U7_24.TheParadoxTower.TheFearedHugo) < 1 then
			-- Questlog: The Paradox Tower
			player:setStorageValue(Storage.Quest.U7_24.TheParadoxTower.QuestLine, 1)
			-- Questlog: The Feared Hugo (Zoltan)
			player:setStorageValue(Storage.Quest.U7_24.TheParadoxTower.TheFearedHugo, 1)
		end
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.myth")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "yenny the gentle") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.yenny")
		npcHandler:setTopic(playerId, 0)
	end

	if MsgContains(message, "holy") or MsgContains(message, "tible") then
		if player:getStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ChestTible) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.tible_ask")
			npcHandler:setTopic(playerId, 3)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.tible_quest_first")
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 3 then
		if player:removeMoney(1000) then
			player:addItem(2836, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.tible_done")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.not_enough_money")
		end
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, NPC_LIB.i18n.get("npc.oldrak.greet", "{playername}"))
npcHandler:setMessage(MESSAGE_WALKAWAY, NPC_LIB.i18n.get("npc.oldrak.walkaway"))
npcHandler:setMessage(MESSAGE_FAREWELL, NPC_LIB.i18n.get("npc.oldrak.farewell", "{playername}"))

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
