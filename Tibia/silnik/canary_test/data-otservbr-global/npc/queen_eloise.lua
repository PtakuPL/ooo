local internalNpcName = "Queen Eloise"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 331,
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

	if (MsgContains(message, "outfit")) or (MsgContains(message, "addon")) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		-- vamos tratar todas condições para YES aqui
		if npcHandler:getTopic(playerId) == 1 then
			-- para o primeiro Yes, o npc deve explicar como obter o outfit
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.multi_3")
			npcHandler:setTopic(playerId, 2)
			-- O NPC só vai oferecer os addons se o player já tiver escolhido.
		elseif npcHandler:getTopic(playerId) == 2 then
			-- caso o player repita o yes, resetamos o tópico para começar de novo?
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_2")
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
						decoKit:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "You bought this item in the Store.\nUnwrap it in your own house to create a " .. decoItemName .. ".")
						decoKit:setActionId(36345)
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_3")
						player:removeMoneyBank(500000000)
						player:addOutfit(1211)
						player:addOutfit(1210)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.Quest.U12_15.GoldenOutfits, 1)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_4")
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_5")
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_6")
			end
			npcHandler:setTopic(playerId, 2)
			-- Fim do outfit
			-- Inicio do helmet
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) == 1 then
				if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) < 2 then
					if player:getMoney() + player:getBankBalance() >= 250000000 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_7")
						player:removeMoneyBank(250000000)
						player:addOutfitAddon(1210, 1)
						player:addOutfitAddon(1211, 1)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.Quest.U12_15.GoldenOutfits, 2)
						npcHandler:setTopic(playerId, 2)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_8")
						npcHandler:setTopic(playerId, 2)
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_9")
					npcHandler:setTopic(playerId, 2)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_10")
				npcHandler:setTopic(playerId, 2)
			end
			npcHandler:setTopic(playerId, 2)
			-- Fim do helmet
			-- Inicio da boots
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) == 2 then
				if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) < 3 then
					if player:getMoney() + player:getBankBalance() >= 250000000 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_11")
						player:removeMoneyBank(250000000)
						player:addOutfitAddon(1210, 2)
						player:addOutfitAddon(1211, 2)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.Quest.U12_15.GoldenOutfits, 3)
						npcHandler:setTopic(playerId, 2)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_12")
						npcHandler:setTopic(playerId, 2)
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_13")
					npcHandler:setTopic(playerId, 2)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_14")
				npcHandler:setTopic(playerId, 2)
			end
			-- Fim da boots
			npcHandler:setTopic(playerId, 2)
		end
		--inicio das opções armor/helmet/boots
		-- caso o player não diga YES, dirá alguma das seguintes palavras:
	elseif (MsgContains(message, "armor")) and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_15")
		npcHandler:setTopic(playerId, 3) -- alterando o tópico para que no próximo YES ele faça o outfit
	elseif (MsgContains(message, "helmet")) and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_16")
		npcHandler:setTopic(playerId, 4) -- alterando o tópico para que no próximo YES ele faça o helmet
	elseif (MsgContains(message, "boots")) and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.queen_eloise.say_17")
		npcHandler:setTopic(playerId, 5) -- alterando o tópico para que no próximo YES ele faça a boots
	end
	-- fim das opções armor/helmet/boots
end

-- Promotion
local node1 = keywordHandler:addKeyword({ "promot" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, i18nKey = "npc.queen_eloise.stdmod_1" })
node1:addChildKeyword({ "yes" }, StdModule.promotePlayer, { npcHandler = npcHandler, cost = 20000, level = 20, i18nKey = "npc.queen_eloise.promote_success" })
node1:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, i18nKey = "npc.queen_eloise.stdmod_2", reset = true })
-- Postman
keywordHandler:addKeyword({ "uniforms" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_3" }, function(player)
	return player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 5
end, function(player)
	player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 6)
end)

-- Greeting
keywordHandler:addGreetKeyword({ "hail queen" }, { npcHandler = npcHandler, text = "I greet thee, my loyal {subject}.", i18nKey = "npc.queen_eloise.greet_1" })
keywordHandler:addGreetKeyword({ "salutations queen" }, { npcHandler = npcHandler, text = "I greet thee, my loyal {subject}.", i18nKey = "npc.queen_eloise.greet_2" })

keywordHandler:addKeyword({ "uniforms" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_4" })

-- Basic
keywordHandler:addKeyword({ "subject" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_5" })
keywordHandler:addAliasKeyword({ "job" })
keywordHandler:addKeyword({ "justice" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_6" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_7" })
keywordHandler:addKeyword({ "news" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_8" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_9" })
keywordHandler:addAliasKeyword({ "land" })
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_10" })
keywordHandler:addKeyword({ "castle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_11" })
keywordHandler:addKeyword({ "sell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_12" })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_13" })
keywordHandler:addKeyword({ "citizen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_14" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_15" })
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_16" })
keywordHandler:addKeyword({ "treasure" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_17" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_18" })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_19" })
keywordHandler:addKeyword({ "quest" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_20" })
keywordHandler:addAliasKeyword({ "mission" })
keywordHandler:addKeyword({ "gold" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_21" })
keywordHandler:addAliasKeyword({ "money" })
keywordHandler:addAliasKeyword({ "tax" })
keywordHandler:addKeyword({ "sewer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_22" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_23" })
keywordHandler:addKeyword({ "equipment" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_24" })
keywordHandler:addAliasKeyword({ "food" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_25" })
keywordHandler:addKeyword({ "hero" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_26" })
keywordHandler:addAliasKeyword({ "adventure" })
keywordHandler:addKeyword({ "collector" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_27" })
keywordHandler:addKeyword({ "queen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_28" })
keywordHandler:addKeyword({ "army" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_29" })
keywordHandler:addKeyword({ "enemy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_30" })
keywordHandler:addAliasKeyword({ "enemies" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_31" })
keywordHandler:addAliasKeyword({ "south" })
keywordHandler:addKeyword({ "carlin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_32" })
keywordHandler:addAliasKeyword({ "city" })
keywordHandler:addKeyword({ "shop" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_33" })
keywordHandler:addKeyword({ "merchant" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_34" })
keywordHandler:addAliasKeyword({ "craftsmen" })
keywordHandler:addKeyword({ "guild" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_35" })
keywordHandler:addKeyword({ "minotaur" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_36" })
keywordHandler:addKeyword({ "paladin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_37" })
keywordHandler:addAliasKeyword({ "legola" })
keywordHandler:addKeyword({ "elane" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_38" })
keywordHandler:addKeyword({ "knight" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_39" })
keywordHandler:addAliasKeyword({ "trisha" })
keywordHandler:addKeyword({ "sorc" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_40" })
keywordHandler:addAliasKeyword({ "lea" })
keywordHandler:addKeyword({ "druid" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_41" })
keywordHandler:addAliasKeyword({ "padreia" })
keywordHandler:addKeyword({ "good" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_42" })
keywordHandler:addKeyword({ "evil" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_43" })
keywordHandler:addKeyword({ "order" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_44" })
keywordHandler:addKeyword({ "chaos" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_45" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_46" })
keywordHandler:addKeyword({ "reward" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_47" })
keywordHandler:addKeyword({ "tbi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_48" })
keywordHandler:addKeyword({ "eremo" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.queen_eloise.stdmod_49" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.queen_eloise.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
