local internalNpcName = "Maelyrra"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 989,
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

local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(ThreatenedDreams.Mission02[1]) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) >= 1 and player:getStorageValue(ThreatenedDreams.Mission02[1]) <= 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) >= 3 and player:getStorageValue(ThreatenedDreams.Mission02[1]) <= 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_3")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) == 5 and player:getStorageValue(ThreatenedDreams.Mission03[1]) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_4")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_5")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_6")
			npcHandler:setTopic(playerId, 8)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_7")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_8")
			player:setStorageValue(ThreatenedDreams.Mission02[1], 1)
			player:setStorageValue(ThreatenedDreams.Mission02.KroazurAccess, 1)
			player:setStorageValue(ThreatenedDreams.Mission02.EnfeebledCount, 0)
			player:setStorageValue(ThreatenedDreams.Mission02.FrazzlemawsCount, 0)
			player:setStorageValue(ThreatenedDreams.QuestLine, 2)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			local enfeebledKills = player:getStorageValue(ThreatenedDreams.Mission02.EnfeebledCount)
			local frazzlemawsKills = player:getStorageValue(ThreatenedDreams.Mission02.FrazzlemawsCount)
			local kroazurKill = player:getStorageValue(ThreatenedDreams.Mission02.KroazurKill)
			if player:getStorageValue(ThreatenedDreams.Mission02[1]) == 1 and kroazurKill >= 1 and (enfeebledKills + frazzlemawsKills) >= 200 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_9")
				npcHandler:setTopic(playerId, 3)
				player:setStorageValue(ThreatenedDreams.Mission02[1], 2)
			elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_10")
				npcHandler:setTopic(playerId, 3)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_11")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 3 then
			npcHandler:say({
				"Some of our siblings are tainted by the destructive energies that threaten Feyrist. They are darker now, more aggressive, twisted ... I'm sure you already met them. ...",
				"They are living in tunnels and caves but at night they surface, even attacking their own siblings. They kidnapped some fairies, holding them prisoner in their mouldy dens. ...",
				"And as if this wasn't enough they stole an ancient and precious artefact, the moon mirror. Please seek out the tainted fae, retrieve the artefact and free the captured fairies. ...",
				"You may discover the entrance to the tainted caves somewhere in the deep forest. The tainted fae like to hide their treasures in hollow logs or trumps, so have a closer look at them.",
			}, npc, creature)
			player:setStorageValue(ThreatenedDreams.Mission02[1], 3)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:getStorageValue(ThreatenedDreams.Mission02.FairiesCounter) == 5 and player:getStorageValue(ThreatenedDreams.Mission02.DarkMoonMirror) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_12")
				npcHandler:setTopic(playerId, 5)
				player:setStorageValue(ThreatenedDreams.Mission02[1], 4)
			elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) == 4 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_13")
				npcHandler:setTopic(playerId, 5)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_14")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 5 then
			npcHandler:say({
				"You have to find three vessels that are able to hold three different types of light: starlight, sunlight and moon rays. You have already found the moon mirror but we also need the starlight vial and the sun catcher. ...",
				"Ask the mermaid Aurita for the starlight vial and the faun Taegen for the sun catcher.",
			}, npc, creature)
			player:setStorageValue(ThreatenedDreams.Mission02[1], 5)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			npcHandler:say({
				"Very good, mortal being! Now you have to catch the respective light and store it in the corresponding vessel. You can gather moon rays by night but this will only work on one special sacred glade on Feyrist. ...",
				"You can find this glade in the deep forest, east of our village. The starlight must also be gathered by night. There is a rock plateau high in the mountains at the border to Roshamuul where you can catch the starlight in the vial. ...",
				"You will recognise the place by the elemental energy shrine there. You have to gather the sunlight by day, of course. There is a beach in the north of Feyrist, shaped like a snake's head. There you may gather Suon's light with the sun catcher.",
			}, npc, creature)
			player:setStorageValue(ThreatenedDreams.Mission02[1], 6)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			if player:getItemCount(25734) >= 1 and player:getItemCount(25732) >= 1 and player:getItemCount(25730) >= 1 then
				npcHandler:say({
					"That's wonderful! Now you will be able to repair the magical barrier. You have to strengthen the arcane sources that power this mystic shield. There are three different arcane sources: the moon sculptures, the dream bird trees and the sun mosaics. ...",
					"There are five of each of them and you have to find them all to repair the barrier. Spread the gathered moon rays on the moon sculptures. Pour out the starlight over the dream bird trees and let the sunlight shine on the mosaics. ...",
					"If you charge all fifteen arcane sources with the respective light, Feyrist's protection will be ensured again.",
				}, npc, creature)
				player:setStorageValue(ThreatenedDreams.Mission02[1], 7)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_15")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:getStorageValue(ThreatenedDreams.Mission02.ChargedMoonMirror) == 0 and player:getStorageValue(ThreatenedDreams.Mission02.ChargedStarlightVial) == 0 and player:getStorageValue(ThreatenedDreams.Mission02.ChargedSunCatcher) == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_16")
				player:addItem(25780, 1)
				player:setStorageValue(ThreatenedDreams.Mission02[1], 8)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_17")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_18")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Nature's blessings! Welcome to the land of dreams.")
npcHandler:setMessage(MESSAGE_FAREWELL, "May your path always be even.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "May your path always be even.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
