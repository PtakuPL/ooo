local internalNpcName = "King Tibianus"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 332,
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

local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "farmine") and player:getStorageValue(TheNewFrontier.Questline) == 14 then
		if player:getStorageValue(TheNewFrontier.Mission05.KingTibianus) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_1")
			npcHandler:setTopic(playerId, 10)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_2")
			npcHandler:setTopic(playerId, 6)
		end
	elseif MsgContains(message, "flatter") and player:getStorageValue(TheNewFrontier.Mission05.KingTibianus) == 1 then
		if npcHandler:getTopic(playerId) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_3")
			player:setStorageValue(TheNewFrontier.Mission05.KingTibianus, 3)
		end
	elseif (MsgContains(message, "outfit")) or (MsgContains(message, "addon")) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_4")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		-- Vamos tratar todas condições para YES aqui
		if npcHandler:getTopic(playerId) == 1 then
			-- Para o primeiro Yes, o npc deve explicar como obter o outfit
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.multi_3")
			npcHandler:setTopic(playerId, 2)
			-- O NPC só vai oferecer os addons se o player já tiver escolhido.
		elseif npcHandler:getTopic(playerId) == 2 then
			-- caso o player repita o yes, resetamos o tópico para começar de novo?
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_5")
			npcHandler:setTopic(playerId, 0)
			-- Inicio do outfit
		elseif npcHandler:getTopic(playerId) == 3 then -- ARMOR/OUTFIT
			if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) < 1 then
				if player:getMoney() + player:getBankBalance() >= 500000000 then
					local inbox = player:getStoreInbox()
					local inboxItems = inbox:getItems()
					if inbox and #inboxItems < inbox:getMaxCapacity() then
						local decoKit = inbox:addItem(ITEM_DECORATION_KIT, 1)
						local decoItemName = ItemType(31510):getName()
						decoKit:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Unwrap it in your own house to create a " .. decoItemName .. ".")
						decoKit:setCustomAttribute("unWrapId", 31510)
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_6")
						player:removeMoneyBank(500000000)
						player:addOutfit(1211)
						player:addOutfit(1210)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.Quest.U12_15.GoldenOutfits, 1)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_7")
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_8")
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_9")
			end
			npcHandler:setTopic(playerId, 2)
			-- Fim do outfit
			-- Inicio do helmet
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) == 1 then
				if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) < 2 then
					if player:getMoney() + player:getBankBalance() >= 250000000 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_10")
						player:removeMoneyBank(250000000)
						player:addOutfitAddon(1210, 2)
						player:addOutfitAddon(1211, 2)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.Quest.U12_15.GoldenOutfits, 2)
						npcHandler:setTopic(playerId, 2)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_11")
						npcHandler:setTopic(playerId, 2)
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_12")
					npcHandler:setTopic(playerId, 2)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_13")
				npcHandler:setTopic(playerId, 2)
			end
			npcHandler:setTopic(playerId, 2)
			-- Fim do helmet
			-- Inicio da boots
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) == 2 then
				if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) < 3 then
					if player:getMoney() + player:getBankBalance() >= 250000000 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_14")
						player:removeMoneyBank(250000000)
						player:addOutfitAddon(1210, 1)
						player:addOutfitAddon(1211, 1)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.Quest.U12_15.GoldenOutfits, 3)
						npcHandler:setTopic(playerId, 2)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_15")
						npcHandler:setTopic(playerId, 2)
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_16")
					npcHandler:setTopic(playerId, 2)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_17")
				npcHandler:setTopic(playerId, 2)
			end
			-- Fim da boots
			npcHandler:setTopic(playerId, 2)
			-- Reseting word The New Frontier: Mission 5
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:getStorageValue(TheNewFrontier.Questline) == 14 and player:getStorageValue(TheNewFrontier.Mission05.KingTibianus) == 2 and player:removeItem(10009, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_18")
				player:setStorageValue(TheNewFrontier.Mission05.KingTibianus, 1)
				npcHandler:setTopic(playerId, 10)
			end
		end
		-- inicio das opções armor/helmet/boots
		-- caso o player não diga YES, dirá alguma das seguintes palavras:
	elseif (MsgContains(message, "armor")) and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_19")
		npcHandler:setTopic(playerId, 3) -- alterando o tópico para que no próximo YES ele faça o outfit
	elseif (MsgContains(message, "helmet")) and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_20")
		npcHandler:setTopic(playerId, 4) -- alterando o tópico para que no próximo YES ele faça o helmet
	elseif (MsgContains(message, "boots")) and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_21")
		npcHandler:setTopic(playerId, 5) -- alterando o tópico para que no próximo YES ele faça a boots
	else
		if player:getStorageValue(TheNewFrontier.Questline) == 14 and player:getStorageValue(TheNewFrontier.Mission05.KingTibianus) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.king_tibianus.say_22")
			player:setStorageValue(TheNewFrontier.Mission05.KingTibianus, 2)
		end
	end
	-- fim das opções armor/helmet/boots
end
-- Promotion
local node1 = keywordHandler:addKeyword({ "promot" }, StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	i18nKey = "npc.king_tibianus.stdmod_1",
})
node1:addChildKeyword({ "yes" }, StdModule.promotePlayer, {
	npcHandler = npcHandler,
	cost = 20000,
	level = 20,
	text = "Congratulations! You are now promoted.",
})
node1:addChildKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	onlyFocus = true,
	i18nKey = "npc.king_tibianus.stdmod_2",
	reset = true,
})
-- Basic
keywordHandler:addKeyword({ "eremo" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_3",
})
keywordHandler:addKeyword({ "otbr" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_4",
})
keywordHandler:addKeyword({ "baah" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_5",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_6",
})
keywordHandler:addKeyword({ "justice" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_7",
})
keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_8",
})
keywordHandler:addKeyword({ "news" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_9",
})
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_10",
})
keywordHandler:addKeyword({ "castle" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_11",
})
keywordHandler:addKeyword({ "sell" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_12",
})
keywordHandler:addKeyword({ "god" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_13",
})
keywordHandler:addKeyword({ "zathroth" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_14",
})
keywordHandler:addKeyword({ "citizen" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_15",
})
keywordHandler:addKeyword({ "sam" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_16",
})
keywordHandler:addKeyword({ "frodo" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_17",
})
keywordHandler:addKeyword({ "gorn" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_18",
})
keywordHandler:addKeyword({ "benjamin" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_19",
})
keywordHandler:addKeyword({ "noodles" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_20",
})
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_21",
})
keywordHandler:addKeyword({ "bozo" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_22",
})
keywordHandler:addKeyword({ "treasure" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_23",
})
keywordHandler:addKeyword({ "monster" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_24",
})
keywordHandler:addKeyword({ "help" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_25",
})
keywordHandler:addKeyword({ "sewer" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_26",
})
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_27",
})
keywordHandler:addKeyword({ "equipment" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_28",
})
keywordHandler:addKeyword({ "food" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_29",
})
keywordHandler:addKeyword({ "tax collector" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_30",
})
keywordHandler:addKeyword({ "king" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_31",
})
keywordHandler:addKeyword({ "army" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_32",
})
keywordHandler:addKeyword({ "shop" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_33",
})
keywordHandler:addKeyword({ "guild" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_34",
})
keywordHandler:addKeyword({ "minotaur" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_35",
})
keywordHandler:addKeyword({ "good" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_36",
})
keywordHandler:addKeyword({ "evil" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_37",
})
keywordHandler:addKeyword({ "order" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_38",
})
keywordHandler:addKeyword({ "chaos" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_39",
})
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_40",
})
keywordHandler:addKeyword({ "reward" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_41",
})
keywordHandler:addKeyword({ "chester" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_42",
})
keywordHandler:addKeyword({ "tbi" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_43",
})
keywordHandler:addKeyword({ "tibia" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_44",
})
keywordHandler:addAliasKeyword({ "land" })
keywordHandler:addKeyword({ "harkath" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_45",
})
keywordHandler:addAliasKeyword({ "bloodblade" })
keywordHandler:addAliasKeyword({ "general" })
keywordHandler:addKeyword({ "quest" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_46",
})
keywordHandler:addAliasKeyword({ "mission" })
keywordHandler:addKeyword({ "gold" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_47",
})
keywordHandler:addAliasKeyword({ "money" })
keywordHandler:addAliasKeyword({ "tax" })
keywordHandler:addAliasKeyword({ "collector" })
keywordHandler:addKeyword({ "time" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_48",
})
keywordHandler:addAliasKeyword({ "hero" })
keywordHandler:addAliasKeyword({ "adventurer" })
keywordHandler:addKeyword({ "enemy" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_49",
})
keywordHandler:addAliasKeyword({ "enemies" })
keywordHandler:addKeyword({ "carlin" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_50",
})
keywordHandler:addKeyword({ "thais" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_51",
})
keywordHandler:addAliasKeyword({ "city" })
keywordHandler:addKeyword({ "merchant" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_52",
})
keywordHandler:addAliasKeyword({ "craftsmen" })
keywordHandler:addKeyword({ "paladin" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_53",
})
keywordHandler:addAliasKeyword({ "elane" })
keywordHandler:addKeyword({ "knight" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_54",
})
keywordHandler:addAliasKeyword({ "gregor" })
keywordHandler:addKeyword({ "sorcerer" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_55",
})
keywordHandler:addAliasKeyword({ "muriel" })
keywordHandler:addKeyword({ "druid" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.king_tibianus.stdmod_56",
})
keywordHandler:addAliasKeyword({ "marvik" })

-- Greeting message
keywordHandler:addGreetKeyword({ "hail king" }, {
	npcHandler = npcHandler,
	text = "I greet thee, my loyal subject |PLAYERNAME|.", i18nKey = "npc.king_tibianus.greet_1",
})
keywordHandler:addGreetKeyword({ "salutations king" }, {
	npcHandler = npcHandler,
	text = "I greet thee, my loyal subject |PLAYERNAME|.", i18nKey = "npc.king_tibianus.greet_2",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.king_tibianus.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
