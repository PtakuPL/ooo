local internalNpcName = "Gnomerik"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 493,
	lookHead = 3,
	lookBody = 60,
	lookLegs = 3,
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

keywordHandler:addGreetKeyword({ "hi" }, { npcHandler = npcHandler, i18nKey = "npc.gnomerik.greet_1" }, function(player)
	if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 1 then
		player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 3)
	end
end)
keywordHandler:addAliasKeyword({ "hello" })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.NeedsBeer) == 1 then
		if MsgContains(message, "recruit") or MsgContains(message, "test") or MsgContains(message, "result") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_1")
		end
		return
	end

	if MsgContains(message, "recruit") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_2")
		elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_3")
			npcHandler:setTopic(playerId, 1)
		end

		-- TEST
	elseif MsgContains(message, "test") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 5 then
			if npcHandler:getTopic(playerId) < 1 then
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, 0)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_20")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_21")
				npcHandler:setTopic(playerId, 2)
			elseif npcHandler:getTopic(playerId) == 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_18")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_19")
				npcHandler:setTopic(playerId, 4)
			elseif npcHandler:getTopic(playerId) == 5 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_16")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_17")
				npcHandler:setTopic(playerId, 6)
			elseif npcHandler:getTopic(playerId) == 7 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_14")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_15")
				npcHandler:setTopic(playerId, 8)
			elseif npcHandler:getTopic(playerId) == 9 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_12")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_13")
				npcHandler:setTopic(playerId, 10)
			elseif npcHandler:getTopic(playerId) == 11 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_4")
				npcHandler:setTopic(playerId, 12)
			elseif npcHandler:getTopic(playerId) == 13 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_10")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_11")
				npcHandler:setTopic(playerId, 14)
			elseif npcHandler:getTopic(playerId) == 15 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_8")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_9")
				npcHandler:setTopic(playerId, 16)
			elseif npcHandler:getTopic(playerId) == 17 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_6")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_7")
				npcHandler:setTopic(playerId, 18)
			elseif npcHandler:getTopic(playerId) == 19 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_5")
				npcHandler:setTopic(playerId, 20)
			elseif npcHandler:getTopic(playerId) == 21 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_5")
				npcHandler:setTopic(playerId, 22)
			elseif npcHandler:getTopic(playerId) == 23 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_6")
				npcHandler:setTopic(playerId, 24)
			elseif npcHandler:getTopic(playerId) == 25 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_7")
				npcHandler:setTopic(playerId, 26)
			elseif npcHandler:getTopic(playerId) == 27 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_8")
				npcHandler:setTopic(playerId, 28)
			elseif npcHandler:getTopic(playerId) == 29 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_9")
				npcHandler:setTopic(playerId, 30)
			elseif npcHandler:getTopic(playerId) == 31 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_10")
				npcHandler:setTopic(playerId, 32)
			end
		end
		-- ANSWERS
	elseif message:lower() == "a" then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 5 then
			if (npcHandler:getTopic(playerId) % 2) == 0 then
				if npcHandler:getTopic(playerId) == 2 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_11")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 18 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_12")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 20 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_13")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 28 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_14")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 30 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_15")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				else
					if npcHandler:getTopic(playerId) < 33 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_16")
						npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
						if npcHandler:getTopic(playerId) >= 33 then
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_17")
						end
					end
				end
			end
		end
	elseif message:lower() == "b" then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 5 then
			if (npcHandler:getTopic(playerId) % 2) == 0 then
				if npcHandler:getTopic(playerId) == 6 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_18")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 14 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_19")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				else
					if npcHandler:getTopic(playerId) < 33 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_20")
						npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
						if npcHandler:getTopic(playerId) >= 33 then
							npcHandler:say("Stop it! The test is over, you can ask me for your {results}.")
						end
					end
				end
			end
		end
	elseif message:lower() == "c" then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 5 then
			if (npcHandler:getTopic(playerId) % 2) == 0 then
				if npcHandler:getTopic(playerId) == 4 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_21")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 22 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_22")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 24 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_23")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				else
					if npcHandler:getTopic(playerId) < 33 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_24")
						npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
						if npcHandler:getTopic(playerId) >= 33 then
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_25")
						end
					end
				end
			end
		end
	elseif message:lower() == "d" then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 5 then
			if (npcHandler:getTopic(playerId) % 2) == 0 then
				if npcHandler:getTopic(playerId) == 8 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_26")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 10 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_27")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 12 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_28")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 16 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_29")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 26 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_30")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 32 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_31")
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				else
					if npcHandler:getTopic(playerId) < 33 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_32")
						npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
						if npcHandler:getTopic(playerId) >= 33 then
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_33")
						end
					end
				end
			end
		end
		-- TEST
	elseif MsgContains(message, "result") then
		if npcHandler:getTopic(playerId) == 33 then
			if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) < 100 then
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.NeedsBeer, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.multi_3")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_1", { player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) })
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 6)
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomerik.say_34")
			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 5)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gnomerik.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
