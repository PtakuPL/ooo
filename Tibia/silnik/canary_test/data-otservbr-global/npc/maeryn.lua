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
	{ text = "Not enough purple nightshade ... not enough liquid silver. *sigh*" },
	{ text = "You think the full moon is a romantic affair? Think again!" },
	{ text = "This place isn't safe. You should leave this island." },
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
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_1")
	elseif MsgContains(message, "pitiful") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_2")
	elseif MsgContains(message, "changed") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_3")
	elseif MsgContains(message, "hope") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_4")
	elseif table.contains({ "were-sickness", "curse" }, message:lower()) then
		npcHandler:say({
			"It transforms peaceful villagers into savage beasts. We're not sure how this curse found the way into our small village. But one day it began. At first it befell just a few people. ...",
			"In a full moon night they changed into bears and wolves, and tore apart their unsuspecting relatives while they were asleep. ...",
			"Those merely wounded, first thought they were lucky. But then we realised they were changing, too. Later, others assumed the forms of badgers and boars also. ...",
			"But that does not mean they were any less wild or dangerous than the others.",
		}, npc, creature)
	elseif MsgContains(message, "tunnels") then
		npcHandler:say({ "We are not sure what they are doing down there. We're glad if they stay in the caverns and leave us alone. Only at full moon do they come up and threaten the island's surface and village. ...", "I, however, have a {hunch} as to why they dwell so deep under the earth." }, npc, creature)
	elseif MsgContains(message, "hunch") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_5")
	elseif MsgContains(message, "artefacts") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_6")
	elseif MsgContains(message, "moon") then
		npcHandler:say({
			"Every month around the 13th, the single Tibian moon will by fully visible to us. That's when the curse hits us hardest. ...",
			"The two days around the 13th, the 12th and the 14th, are considered 'Harvest Moon', those are the best to gather {nightshade}. However, only after it has reached its apex on the 13th, the curse strengthens. ...",
			"We do not know what happens down there in those tunnels around that time but there is a presence there, we all feel - yet cannot quite fathom. ...",
			"At full moon, humans transform into wild beasts: wolves, boars, bears and others. Some call it the {curse} of the Full Moon, others think it is a kind of sickness. .",
			"During this time, we try to not leave the house, we shut the windows and hope it will pass. The curse will weaken a bit after that but it returns. Every month.",
		}, npc, creature)
	elseif MsgContains(message, "nightshade") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_7")
	elseif MsgContains(message, "name") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_8")
	elseif MsgContains(message, "maeryn") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_9")
	elseif MsgContains(message, "time") then
		npcHandler:say("It's exactly " .. getFormattedWorldTime() .. ".", npc, creature)
	elseif MsgContains(message, "job") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_10")
	elseif MsgContains(message, "grimvale") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_11")
	elseif MsgContains(message, "owin") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_12")
	elseif MsgContains(message, "werewolves") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_13")
	elseif MsgContains(message, "gladys") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_14")
	elseif MsgContains(message, "cornell") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_15")
	elseif MsgContains(message, "werewolf helmet") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_16")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_17")
			npcHandler:setTopic(playerId, 2)
		end
	elseif table.contains({ "knight", "sorcerer", "druid", "paladin" }, message:lower()) and npcHandler:getTopic(playerId) == 2 then
		local helmet = message:lower()
		if not vocations[helmet] then
			return false
		end
		if message:lower() == "knight" then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_18")
			knightChoice[playerId] = helmet
			npcHandler:setTopic(playerId, 3)
		end
		if npcHandler:getTopic(playerId) == 2 then
			--if (Set storage if player can enchant helmet(need Grim Vale quest)) then
			player:setStorageValue(Storage.Quest.U10_80.GrimvaleQuest.WereHelmetEnchant, vocations[helmet])
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_19")
			--else
			--NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_20")
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
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_21")
			--else
			--NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maeryn.say_22")
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
