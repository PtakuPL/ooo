local internalNpcName = "Emperor Kruzak"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 66,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
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

	if (MsgContains(message, "outfit")) or (MsgContains(message, "addon")) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		-- vamos tratar todas condições para YES aqui
		if npcHandler:getTopic(playerId) == 1 then
			-- para o primeiro Yes, o npc deve explicar como obter o outfit
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.multi_3")
			npcHandler:setTopic(playerId, 2)
			-- O NPC só vai oferecer os addons se o player já tiver escolhido.
		elseif npcHandler:getTopic(playerId) == 2 then
			-- caso o player repita o yes, resetamos o tópico para começar de novo?
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_2")
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
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_3")
						player:removeMoneyBank(500000000)
						player:addOutfit(1211)
						player:addOutfit(1210)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.Quest.U12_15.GoldenOutfits, 1)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_4")
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_5")
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_6")
			end
			npcHandler:setTopic(playerId, 2)
			-- Fim do outfit
			-- Inicio do helmet
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) == 1 then
				if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) < 2 then
					if player:getMoney() + player:getBankBalance() >= 250000000 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_7")
						player:removeMoneyBank(250000000)
						player:addOutfitAddon(1210, 1)
						player:addOutfitAddon(1211, 1)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.Quest.U12_15.GoldenOutfits, 2)
						npcHandler:setTopic(playerId, 2)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_8")
						npcHandler:setTopic(playerId, 2)
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_9")
					npcHandler:setTopic(playerId, 2)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_10")
				npcHandler:setTopic(playerId, 2)
			end
			npcHandler:setTopic(playerId, 2)
			-- Fim do helmet
			-- Inicio da boots
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) == 2 then
				if player:getStorageValue(Storage.Quest.U12_15.GoldenOutfits) < 3 then
					if player:getMoney() + player:getBankBalance() >= 250000000 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_11")
						player:removeMoneyBank(250000000)
						player:addOutfitAddon(1210, 2)
						player:addOutfitAddon(1211, 2)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.Quest.U12_15.GoldenOutfits, 3)
						npcHandler:setTopic(playerId, 2)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_12")
						npcHandler:setTopic(playerId, 2)
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_13")
					npcHandler:setTopic(playerId, 2)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_14")
				npcHandler:setTopic(playerId, 2)
			end
			-- Fim da boots
			npcHandler:setTopic(playerId, 2)
		end
		--inicio das opções armor/helmet/boots
		-- caso o player não diga YES, dirá alguma das seguintes palavras:
	elseif (MsgContains(message, "armor")) and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_15")
		npcHandler:setTopic(playerId, 3) -- alterando o tópico para que no próximo YES ele faça o outfit
	elseif (MsgContains(message, "helmet")) and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_16")
		npcHandler:setTopic(playerId, 4) -- alterando o tópico para que no próximo YES ele faça o helmet
	elseif (MsgContains(message, "boots")) and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_kruzak.say_17")
		npcHandler:setTopic(playerId, 5) -- alterando o tópico para que no próximo YES ele faça a boots
	end
	-- fim das opções armor/helmet/boots
end

-- Promotion
local node1 = keywordHandler:addKeyword({ "promot" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, i18nKey = "npc.emperor_kruzak.stdmod_1" })
node1:addChildKeyword({ "yes" }, StdModule.promotePlayer, { npcHandler = npcHandler, cost = 20000, level = 20, i18nKey = "npc.emperor_kruzak.promote_success" })
node1:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, i18nKey = "npc.emperor_kruzak.stdmod_2", reset = true })

-- Greeting message
keywordHandler:addGreetKeyword({ "hail emperor" }, { npcHandler = npcHandler, i18nKey = "npc.emperor_kruzak.greet_1" })
keywordHandler:addGreetKeyword({ "salutations emperor" }, { npcHandler = npcHandler, i18nKey = "npc.emperor_kruzak.greet_2" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.emperor_kruzak.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
