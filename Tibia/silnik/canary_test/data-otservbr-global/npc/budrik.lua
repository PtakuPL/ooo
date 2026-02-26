local internalNpcName = "Budrik"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 160,
	lookHead = 94,
	lookBody = 95,
	lookLegs = 58,
	lookFeet = 114,
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

	if table.contains({ "mission", "quest" }, message:lower()) then
		if player:getStorageValue(Storage.Quest.U8_1.ToOutfoxAFoxQuest.Questline) < 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.budrik.say_11", "npc.budrik.say_12" })
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_1.ToOutfoxAFoxQuest.Questline) == 1 then
			if player:removeItem(139, 1) then
				player:setStorageValue(Storage.Quest.U8_1.ToOutfoxAFoxQuest.Questline, 2)
				player:addItem(875, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_13")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_14")
			end
		elseif player:getStorageValue(Storage.Quest.U8_1.ToOutfoxAFoxQuest.Questline) == 2 and player:getLevel() <= 40 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BudrikMinos) < 0 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.budrik.say_15", "npc.budrik.say_16" })
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BudrikMinos) == 0 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.MinotaurCount) >= 5000 then
				NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.budrik.say_17", "npc.budrik.say_18" })
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BudrikMinos, 1)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.FoxCount, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_19")
			end
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BudrikMinos) == 2 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.FoxCount) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_20")
		elseif player:getLevel() > 40 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BudrikMinos) < 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_21")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_22")
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_23")
			npcHandler:setTopic(playerId, 0)
			if player:getStorageValue(Storage.Quest.U8_1.TibiaTales.DefaultStart) <= 0 then
				player:setStorageValue(Storage.Quest.U8_1.TibiaTales.DefaultStart, 1)
			end
			player:setStorageValue(Storage.Quest.U8_1.ToOutfoxAFoxQuest.Questline, 1)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_24")
			player:setStorageValue(JOIN_STOR, 1)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BudrikMinos, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.MinotaurCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.MinotaurCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.MinotaurGuardCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.MinotaurMageCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.MinotaurArcherCount, 0)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_25")
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) > 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_26")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

-- Basic
keywordHandler:addKeyword({ "disturb" }, StdModule.say, { npcHandler = npcHandler, text = "I'm the foreman of this {mine}." , i18nKey = "npc.budrik.stdmod_12"})
keywordHandler:addAliasKeyword({ "job" })
keywordHandler:addAliasKeyword({ "shop" })
keywordHandler:addKeyword({ "dwarfs" }, StdModule.say, { npcHandler = npcHandler, text = "We understand the ways of the earth like nobody else." , i18nKey = "npc.budrik.stdmod_13"})
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, text = "I'm a miner, not your mother. Go ask someone else." , i18nKey = "npc.budrik.stdmod_14"})
keywordHandler:addKeyword({ "hideout" }, StdModule.say, { npcHandler = npcHandler, text = "The hideout of the Horned Fox is probably a dangerous if not lethal place for inexperienced adventurers. It is the source of all the {trouble} around here." , i18nKey = "npc.budrik.stdmod_15"})
keywordHandler:addKeyword({ "horned fox" }, StdModule.say, { npcHandler = npcHandler, text = "He is a minotaur who was kicked out of Mintwallin. He must have some kind of {hideout} nearby." , i18nKey = "npc.budrik.stdmod_16"})
keywordHandler:addKeyword({ "mine" }, StdModule.say, { npcHandler = npcHandler, text = "This is not an amusement park! Leave the miners and their drilling-worms alone and get out! We've already got enough {trouble} without you." , i18nKey = "npc.budrik.stdmod_17"})
keywordHandler:addAliasKeyword({ "dungeon" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, text = "We occasionally come across nasty beasts in the deepest mines." , i18nKey = "npc.budrik.stdmod_18"})
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, text = "My name is Budrik Deepdigger, Son of Earth, from the Molten Rock." , i18nKey = "npc.budrik.stdmod_19"})
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, text = { "Precisely " .. getFormattedWorldTime() .. ", young one." } })
keywordHandler:addKeyword({ "trouble" }, StdModule.say, { npcHandler = npcHandler, text = "The {Horned Fox} is leading his bandits in sneak attacks and raids on us." , i18nKey = "npc.budrik.stdmod_20"})
keywordHandler:addKeyword({ "shearton softbeard" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Yes, I remember him well. It was a tragedy. An earthquake led to a cave-in and many of our brave miners died. ...",
		"Their ghosts still haunt the Grothmok tunnel in which they died, so we had to seal it off.",
	},
})
keywordHandler:addKeyword({ "grothmok" }, StdModule.say, { npcHandler = npcHandler, text = "You may enter the tunnel." , i18nKey = "npc.budrik.stdmod_21"})
keywordHandler:addKeyword({ "deeper mines" }, StdModule.say, { npcHandler = npcHandler, text = "This is no funhouse. Leave the miners and their drilling-worms alone and get out! We have already enough trouble without you." , i18nKey = "npc.budrik.stdmod_22"})
npcHandler:setMessage(MESSAGE_WALKAWAY, "Bye, bye.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Bye, bye.")
npcHandler:setMessage(MESSAGE_GREET, "Hiho, hiho |PLAYERNAME|. Why do you {disturb} me?")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
