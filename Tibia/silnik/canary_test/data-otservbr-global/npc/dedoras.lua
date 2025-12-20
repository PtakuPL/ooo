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
	{ npcHandler = npcHandler, text = {
		"Of course the first to ask would be the famous Avar Tar, but I heard he's already on a quest of his own and ...",
		"Well, let's say our last collaboration did not end too well. In fact, I'd be not even surprised if he pretended to not even know me. ...",
		"So I have to look elsewhere to handle this new {threat}.",
	} }
)
keywordHandler:addKeyword({ "background" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The goodbreaker was created in ancient times, when the war between the gods and their minions was on its height. Its creation took aeons and incredible sacrifices. ...",
		"Each part had to be crafted perfectly, to emulate the gods, so it would share 'the same place' with them. ...",
		"Mere mortals can not even perceive it in his whole but only recognize the part of it that is the physical representation in our world. ...",
		"If it was meant to be used as an actual weapon, as the ultimate threat, or if Zathroth was just tempted to use his knowledge in the ultimate way - to create something that could undo himself - we don't know. ...",
		"However in the end even Zathroth deemed it too much of a threat but instead of destroying the contraption once and for all, it was {disassembled} and hidden away.",
	},
})
keywordHandler:addKeyword(
	{ "parts" },
	StdModule.say,
	{ npcHandler = npcHandler, text = {
		"The parts alone do them no good. To assemble the parts, great skill, immense power and forbidden knowledge are necessary. ...",
		"The skill will be supplied by the fallen Yalahari and the power by Variphor itself. ...",
		"The only thing they are still lacking is the knowledge to assemble and operate the {godbreaker}.",
	} }
)
keywordHandler:addKeyword({ "godbreaker" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The godbreaker is a complex artifact. Incantation woven into incantation. The powers bound into it are so immense that the slightest mishandling could prove disastrous. ...",
		"o figure out how it works, let alone how it can be operated safely, could require several centuries of tireless study. And even then this information would be only partial. ...",
		"Yet the creation and operation of the godbreaker is just the kind of forbidden {knowledge} Zathroth values most, so it was compiled and stored.",
	},
})
keywordHandler:addKeyword({ "knowledge" }, StdModule.say, { npcHandler = npcHandler, text = {
	"Of course the dangers of such knowledge were obvious. It was hidden in a sacred place devoted to Zathroth and dangerous knowledge. ...",
	"The hidden library, the forbidden hoard, the shrouded trove of knowledge or the veiled hoard of forbidden knowledge, the place has many names in many {myths}.",
} })
keywordHandler:addKeyword({ "myths" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The myths agree that the place is well hidden, extremely guarded and contains some of the most powerful pieces of knowledge in this world and probably beyond. ...",
		"However the knowledge about the godbreaker now poses a threat to all existence. In the hands of Variphor it can cause disaster in previously unknown ways. The gods themselves are in {peril}.",
	},
})
keywordHandler:addKeyword({ "peril" }, StdModule.say, { npcHandler = npcHandler, text = {
	"Regardless of the dangers, the cult of Zathroth refused to destroy the knowledge of the godbreaker for good. ...",
	"They {value} dangerous knowledge that much, that they are unable to part from it, even when faced with the utter destruction of creation.",
} })
keywordHandler:addKeyword(
	{ "find" },
	StdModule.say,
	{ npcHandler = npcHandler, text = {
		"I know it's asked much but it's no longer a matter of choice. ...",
		"The enemy is moving and I have reports that suggest the minions of Variphor are actively searching for Zathroth's library. They must not be allowed to succeed. ...",
		"We must be the first to {reach} the hoard and make sure the enemy doesn't get the information he needs.",
	} }
)
keywordHandler:addKeyword({ "reach" }, StdModule.say, { npcHandler = npcHandler, text = {
	"I'd recommend to follow the few leads me and my associates could gather so far. ...",
	"Old myths, some {rumors} about old texts and other pieces of knowledge that I could use to figure out where to locate the hidden library and how to enter it.",
} })
keywordHandler:addKeyword({ "rumors" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Hints about the shrouded hoard are numerous, though most are general mentions in texts that deal with Zathroth. But there are other sources. ...",
		"Like texts about ancient liturgies of Zathroth and historical documents that might give us clues. I already compiled everything of value from the sources that were openly available. ...",
		"To gather the more {obscure} parts of knowledge, however, I'll need your help.",
	},
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.dedoras.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.dedoras.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
