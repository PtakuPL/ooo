local internalNpcName = "Dedoras"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 146,
	lookHead = 76,
	lookBody = 57,
	lookLegs = 78,
	lookFeet = 77,
	lookAddons = 2,
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

local quests = {
	[1] = { stg = Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.Questline, value = 4 },
	[2] = { stg = Storage.Quest.U11_80.TheSecretLibrary.LiquidDeath.Questline, value = 8 },
	[3] = { stg = Storage.Quest.U11_80.TheSecretLibrary.Asuras.Questline, value = 7 },
	[4] = { stg = Storage.Quest.U11_80.TheSecretLibrary.FalconBastion.Questline, value = 3 },
	[5] = { stg = Storage.Quest.U11_80.TheSecretLibrary.Darashia.Questline, value = 9 },
	[6] = { stg = Storage.Quest.U11_80.TheSecretLibrary.MoTA.Questline, value = 8 },
}

local function startMission(pid, storage, value)
	local player = Player(pid)
	if player then
		if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Questlog) < 1 then
			player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Questlog, 1)
		end
		if player:getStorageValue(storage) < value then
			player:setStorageValue(storage, value)
		end
	end
end

local function isQuestDone(pid)
	local player = Player(pid)
	if player then
		for i = 1, #quests do
			if player:getStorageValue(quests[i].stg) ~= quests[i].value then
				return false
			end
		end
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local currentStorage = player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.LibraryPermission)
	if currentStorage < 0 then
		currentStorage = 0
	end

	if MsgContains(message, "search") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_18")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_19")
	elseif MsgContains(message, "museum") then
		if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.MoTA.Questline) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_17")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.LibraryPermission, currentStorage + 1)
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.MoTA.Questline, 8)
		elseif player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.MoTA.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_1")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.MoTA.Questline, 1)
		end
	elseif MsgContains(message, "desert") then
		if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Darashia.Questline) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_2")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.LibraryPermission, currentStorage + 1)
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.Darashia.Questline, 9)
		elseif player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Darashia.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_3")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.Darashia.Questline, 1)
		end
	elseif MsgContains(message, "fishmen") then
		if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.LiquidDeath.Questline) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_4")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.LibraryPermission, currentStorage + 1)
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.LiquidDeath.Questline, 8)
		elseif player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.LiquidDeath.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_15")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.LiquidDeath.Questline, 1)
		end
	elseif MsgContains(message, "order") then
		if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.FalconBastion.Questline) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_5")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.LibraryPermission, currentStorage + 1)
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.FalconBastion.Questline, 3)
		elseif player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.FalconBastion.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_13")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.FalconBastion.Questline, 1)
		end
	elseif MsgContains(message, "asuri") then
		if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Asuras.Questline) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_6")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.LibraryPermission, currentStorage + 1)
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.Asuras.Questline, 7)
		elseif player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Asuras.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_11")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.Asuras.Questline, 1)
		end
	elseif MsgContains(message, "isle") then
		if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.Questline) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_7")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.LibraryPermission, currentStorage + 1)
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.Questline, 4)
		elseif player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_8")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.Questline, 1)
		end
	elseif MsgContains(message, "progress") then
		if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.LibraryPermission) < 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_9")
		end
	elseif MsgContains(message, "check") then
		if isQuestDone(player:getId()) and player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.LibraryPermission) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.multi_7")
			player:addOutfit(1069, 0)
			player:addOutfit(1070, 0)
			player:addAchievement("Battle Mage")
			startMission(player:getId(), Storage.Quest.U11_80.TheSecretLibrary.LibraryPermission, 7)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_9")
		end
	end

	if MsgContains(message, "addon") and player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.LibraryPermission) == 7 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_10")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "book") and npcHandler:getTopic(playerId) == 3 then
		if player:getStorageValue(Storage.Quest.U11_80.BattleMageOutfits.Addon1) < 1 and player:getItemCount(28792) > 5 then
			player:removeItem(28792, 5)
			player:addOutfit(1069, 1)
			player:addOutfit(1070, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_11")
			startMission(player:getId(), Storage.Quest.U11_80.BattleMageOutfits.Addon1, 1)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U11_80.BattleMageOutfits.Addon2) < 1 and player:getItemCount(28793) > 20 then
			player:removeItem(28793, 20)
			player:addOutfit(1069, 2)
			player:addOutfit(1070, 2)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_12")
			startMission(player:getId(), Storage.Quest.U11_80.BattleMageOutfits.Addon2, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_13")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dedoras.say_14")
			npcHandler:setTopic(playerId, 3)
		end
	end

	return true
end

keywordHandler:addKeyword({ "looking" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dedoras.stdmod_1" })
keywordHandler:addKeyword({ "value" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dedoras.stdmod_2" })
keywordHandler:addKeyword({ "threat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dedoras.stdmod_3" })
keywordHandler:addKeyword({ "disassembled" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dedoras.stdmod_4" })
keywordHandler:addKeyword({ "obscure" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dedoras.stdmod_5" })
keywordHandler:addKeyword({ "hands" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dedoras.stdmod_6" })
keywordHandler:addKeyword(
	{ "adventurer" },
	StdModule.say,
	{ npcHandler = npcHandler, i18nKey = "npc.dedoras.stdmod_11" }
)
keywordHandler:addKeyword({ "background" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dedoras.stdmod_7",
})
keywordHandler:addKeyword(
	{ "parts" },
	StdModule.say,
	{ npcHandler = npcHandler, i18nKey = "npc.dedoras.stdmod_12" }
)
keywordHandler:addKeyword({ "godbreaker" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dedoras.stdmod_8",
})
keywordHandler:addKeyword({ "knowledge" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dedoras.stdmod_13" })
keywordHandler:addKeyword({ "myths" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dedoras.stdmod_9",
})
keywordHandler:addKeyword({ "peril" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dedoras.stdmod_14" })
keywordHandler:addKeyword(
	{ "find" },
	StdModule.say,
	{ npcHandler = npcHandler, i18nKey = "npc.dedoras.stdmod_15" }
)
keywordHandler:addKeyword({ "reach" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dedoras.stdmod_16" })
keywordHandler:addKeyword({ "rumors" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dedoras.stdmod_10",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.dedoras.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.dedoras.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)