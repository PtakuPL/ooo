local internalNpcName = "Maeryn"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 683,
	lookHead = 94,
	lookBody = 101,
	lookLegs = 97,
	lookFeet = 116,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.maeryn.voice_1" },
	{ i18nKey = "npc.maeryn.voice_2" },
	{ i18nKey = "npc.maeryn.voice_3" },
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

local vocations = {
	["sorcerer"] = 0,
	["druid"] = 1,
	["paladin"] = 2,
	["knight"] = {
		["club"] = 3,
		["axe"] = 4,
		["sword"] = 5,
	},
}

local knightChoice = {}

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	knightChoice[playerId] = nil
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if MsgContains(message, "tokens") then
	elseif table.contains({ "dangerous", "beasts" }, message:lower()) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_23")
	elseif MsgContains(message, "pitiful") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_24")
	elseif MsgContains(message, "changed") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_25")
	elseif MsgContains(message, "hope") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_26")
	elseif table.contains({ "were-sickness", "curse" }, message:lower()) then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.maeryn.say_27", "npc.maeryn.say_28", "npc.maeryn.say_29", "npc.maeryn.say_30" })
	elseif MsgContains(message, "tunnels") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.maeryn.say_31", "npc.maeryn.say_32" })
	elseif MsgContains(message, "hunch") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.maeryn.say_33", "npc.maeryn.say_34" })
	elseif MsgContains(message, "artefacts") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_35")
	elseif MsgContains(message, "moon") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.maeryn.say_36", "npc.maeryn.say_37", "npc.maeryn.say_38", "npc.maeryn.say_39", "npc.maeryn.say_40" })
	elseif MsgContains(message, "nightshade") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_41")
	elseif MsgContains(message, "name") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_42")
	elseif MsgContains(message, "maeryn") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_43")
	elseif MsgContains(message, "time") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_44", { getFormattedWorldTime() })
	elseif MsgContains(message, "job") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_45")
	elseif MsgContains(message, "grimvale") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_46")
	elseif MsgContains(message, "owin") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_47")
	elseif MsgContains(message, "werewolves") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_48")
	elseif MsgContains(message, "gladys") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_49")
	elseif MsgContains(message, "cornell") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_50")
	elseif MsgContains(message, "werewolf helmet") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_51")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_52")
			npcHandler:setTopic(playerId, 2)
		end
	elseif table.contains({ "knight", "sorcerer", "druid", "paladin" }, message:lower()) and npcHandler:getTopic(playerId) == 2 then
		local helmet = message:lower()
		if not vocations[helmet] then
			return false
		end
		if message:lower() == "knight" then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_53")
			knightChoice[playerId] = helmet
			npcHandler:setTopic(playerId, 3)
		end
		if npcHandler:getTopic(playerId) == 2 then
			--if (Set storage if player can enchant helmet(need Grim Vale quest)) then
			player:setStorageValue(Storage.Quest.U10_80.GrimvaleQuest.WereHelmetEnchant, vocations[helmet])
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_54")
			--else
			--npcHandler:say("Message when player do not have quest.", npc, creature)
			--end
			npcHandler:setTopic(playerId, 0)
		end
	elseif table.contains({ "axe", "club", "sword" }, message:lower()) and npcHandler:getTopic(playerId) == 3 then
		local weapontype = message:lower()
		if not vocations[knightChoice[playerId]][weapontype] then
			return false
		else
			--if (Set storage if player can enchant helmet(need Grim Vale quest)) then
			player:setStorageValue(Storage.Quest.U10_80.GrimvaleQuest.WereHelmetEnchant, vocations[knightChoice[playerId]][weapontype])
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_55")
			--else
			--npcHandler:say("Message when player do not have quest.", npc, creature)
			--end
			knightChoice[playerId] = nil
			npcHandler:setTopic(playerId, 0)
		end
	end
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings, visitor. I wonder what may lead you to this {dangerous} place.")
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
