local internalNpcName = "Jack Springer"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 289,
	lookHead = 114,
	lookBody = 114,
	lookLegs = 114,
	lookFeet = 113,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.jack_springer.voice_1" },
	{ i18nKey = "npc.jack_springer.voice_2" },
}

npcConfig.shop = {
	{ itemName = "vial of potent holy water", clientId = 31612, buy = 100 },
}

-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end

-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})
end

-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

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

local function greetCallback(npc, creature)
	local player = Player(creature)

	if player then
		if player:getLevel() >= 250 then
			if player:getStorageValue(Storage.Quest.U12_20.GraveDanger.Questline) < 1 then
				NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.jack_springer.greet_msg_1")
			elseif player:getStorageValue(Storage.Quest.U12_20.GraveDanger.Questline) >= 3 then
				NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.jack_springer.greet_msg_2")
			else
				NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.jack_springer.greet_msg_3")
			end
		else
			NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.jack_springer.greet_msg_4")
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

	local storages = {
		Storage.Quest.U12_20.GraveDanger.ScarlettKilled,
		Storage.Quest.U12_20.GraveDanger.Graves.Progress,
		Storage.Quest.U12_20.GraveDanger.Graves.Edron,
		Storage.Quest.U12_20.GraveDanger.Graves.DarkCathedral,
		Storage.Quest.U12_20.GraveDanger.Graves.Ghostlands,
		Storage.Quest.U12_20.GraveDanger.Graves.Cormaya,
		Storage.Quest.U12_20.GraveDanger.Graves.FemorHills,
		Storage.Quest.U12_20.GraveDanger.Graves.Ankrahmun,
		Storage.Quest.U12_20.GraveDanger.Graves.Kilmaresh,
		Storage.Quest.U12_20.GraveDanger.Graves.Vengoth,
		Storage.Quest.U12_20.GraveDanger.Graves.Darashia,
		Storage.Quest.U12_20.GraveDanger.Graves.Thais,
		Storage.Quest.U12_20.GraveDanger.Graves.Orclands,
		Storage.Quest.U12_20.GraveDanger.Graves.IceIslands,
	}

	if MsgContains(message, "late") then
		if player:getStorageValue(Storage.Quest.U12_20.GraveDanger.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.multi_12")
			for _, stor in pairs(storages) do
				player:setStorageValue(stor, 0)
			end
			player:setStorageValue(Storage.Quest.U12_20.GraveDanger.Stage, 0)
			player:setStorageValue(Storage.Quest.U12_20.GraveDanger.Questline, 1)
			npcHandler:setTopic(playerId, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.multi_10")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "report") and npcHandler:getTopic(playerId) == 2 then
		if player:getStorageValue(Storage.Quest.U12_20.GraveDanger.Stage) < 1 then
			if player:getStorageValue(Storage.Quest.U12_20.GraveDanger.Graves.Progress) >= 12 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.say_1")
				npcHandler:setTopic(playerId, 3)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.say_2")
			end
		else
			if player:getStorageValue(Storage.Quest.U12_20.GraveDanger.Bosses.KingZelos.Killed) >= 1 then
				if player:getStorageValue(Storage.Quest.U12_20.GraveDanger.Questline) >= 3 and player:getStorageValue(Storage.Quest.U12_20.HandOfTheInquisitionOutfits.Addon2) < 1 and player:removeItem(31737, 1) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.say_3")
					player:addOutfit(1243, 2)
					player:addOutfit(1244, 2)
					player:setStorageValue(Storage.Quest.U12_20.GraveDanger.Stage, 2)
					player:setStorageValue(Storage.Quest.U12_20.GraveDanger.Questline, 3)
					player:setStorageValue(Storage.Quest.U12_20.HandOfTheInquisitionOutfits.Addon2, 1)
				elseif player:getStorageValue(Storage.Quest.U12_20.GraveDanger.Questline) >= 3 and player:getStorageValue(Storage.Quest.U12_20.HandOfTheInquisitionOutfits.Addon1) < 1 and player:removeItem(31738, 1) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.say_4")
					player:addOutfit(1243, 1)
					player:addOutfit(1244, 1)
					player:setStorageValue(Storage.Quest.U12_20.GraveDanger.Stage, 2)
					player:setStorageValue(Storage.Quest.U12_20.GraveDanger.Questline, 3)
					player:setStorageValue(Storage.Quest.U12_20.HandOfTheInquisitionOutfits.Addon1, 1)
				elseif player:getStorageValue(Storage.Quest.U12_20.GraveDanger.Questline) < 3 and player:getStorageValue(Storage.Quest.U12_20.HandOfTheInquisitionOutfits.Outfits) < 1 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.say_5")
					player:addOutfit(1243, 0)
					player:addOutfit(1244, 0)
					player:addAchievement("Inquisition's Hand")
					player:setStorageValue(Storage.Quest.U12_20.GraveDanger.Stage, 2)
					player:setStorageValue(Storage.Quest.U12_20.GraveDanger.Questline, 3)
					player:setStorageValue(Storage.Quest.U12_20.HandOfTheInquisitionOutfits.Outfits, 1)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.say_6")
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.say_7")
			end
		end
	elseif MsgContains(message, "ultimate") and npcHandler:getTopic(playerId) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.multi_8")
		npcHandler:setTopic(playerId, 4)
	elseif MsgContains(message, "threat") and npcHandler:getTopic(playerId) == 4 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_springer.multi_6")
		player:setStorageValue(Storage.Quest.U12_20.GraveDanger.Stage, 1)
		player:setStorageValue(Storage.Quest.U12_20.GraveDanger.Questline, 2)
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.jack_springer.sendtrade_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

keywordHandler:addKeyword({ "discuss" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_1" })
keywordHandler:addKeyword({ "urgency" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_2" })
keywordHandler:addKeyword({ "start" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_3" })
keywordHandler:addKeyword({ "source" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_4" })
keywordHandler:addKeyword({ "events" }, StdModule.say, { npcHandler = npcHandler, text = {
	"Well, in Rathleton there was an individual at work, looking for some ancient artefact of power. ...",
	"To cover its escape the creature left another creature, known as the ravager to cover his tracks. But there is {more}.",
} })
keywordHandler:addKeyword({ "more" }, StdModule.say, { npcHandler = npcHandler, text = {
	"Only recently someone was trying to manipulate the elven dream courts into releasing a monstrosity of nightmares, probably planning to control or recruit this creature. ....",
	"But those incidents were just some of {many}.",
} })
keywordHandler:addKeyword({ "many" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_5" })
keywordHandler:addKeyword(
	{ "iceberg" },
	StdModule.say,
	{ npcHandler = npcHandler, text = {
		"There is a scheming going on behind the scenes. Powerful good people were corrupted. Evil-doers got backup and resources from a hidden ally. ...",
		"Powerful malignant creatures, gathering their kind under their banner and so much more. These things are not happening by chance. There is a pattern, a guiding {hand}.",
	} }
)
keywordHandler:addKeyword({ "hand" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_6" })
keywordHandler:addKeyword({ "predates" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_7" })
keywordHandler:addKeyword(
	{ "language" },
	StdModule.say,
	{ npcHandler = npcHandler, text = {
		"It has a rather complex meaning and as far as we can tell it translates to 'army of those who are many, dedicated to the ultimate time of mayhem and despair'. ...",
		"Other, more handy names are army of the last battlefield, army of the last days, legion of mayhem, dread legion or simply the {legion}.",
	} }
)
keywordHandler:addKeyword(
	{ "legion" },
	StdModule.say,
	{ npcHandler = npcHandler, text = {
		"We know little for sure. You can look into our books to see some of our sources. But most are vague and some even contradictory. ...",
		"To summarise what we know, let me tell you this: The Shiron'Fal is an extremely old organisation. It seeks to accumulate power for some unknown but certainly sinister {goal}.",
	} }
)
keywordHandler:addKeyword({ "goal" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"For this purpose, the members gather knowledge, artefacts and powerful individuals. The members are formidable at certain fields of expertise. They are cunning and powerful and act with no regard for others, with no remorse or mercy. ...",
		"As they are doing this since ages, they must have acquired tremendous powers and knowledge. Their members often operate alone but are usually well funded with the necessary resources. ...",
		"Whatever their endgame might be, each of their operations pose a grave danger to the whole world and have to be {stopped}.",
	},
})
keywordHandler:addKeyword({ "stopped" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_8" })
keywordHandler:addKeyword({ "clashes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_9" })
keywordHandler:addKeyword({ "hurry" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_10" })
keywordHandler:addKeyword({ "problem" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_11" })
keywordHandler:addKeyword({ "knights" }, StdModule.say, { npcHandler = npcHandler, text = {
	"The knights they aim at were tainted in life by their actions or happenstance. ...",
	"This leaves their bodies vulnerable to their special breed of necromancy that would raise them as powerful {lich}-knights.",
} })
keywordHandler:addKeyword({ "lich" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_12" })
keywordHandler:addKeyword({ "scheme" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_13" })
keywordHandler:addKeyword({ "threats" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_14" })
keywordHandler:addKeyword({ "rituals" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_springer.stdmod_15" })
keywordHandler:addKeyword({ "purge" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Reaching the graves will not be without danger and if you encounter the death cultists you will have to fight them. Even worse, they might have even succeeded in some cases. ...",
		"As a newly risen lich-knight is not able to leave the site of its resurrection for some time, you might have to fight some of them. ...",
		"Let us pray that you never come too {late} or else some of the fiends might be able to leave their crypts.",
	},
})
keywordHandler:addKeyword({ "locations" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"We have located twelve graves that have to be secured: In the old northern Edron graveyard, in the dark cathedral of the plains of havoc, in the ghostlands, on Cormaya, Somewhere in the Femor Hills, on Vengoth, ...",
		"in the graveyard of Darashia, in the old temple north of Thais, at the entrance to the orcland, one is on the southern ice islands, in a mountain on Kilmaresh, one on an island north-east of Ankrahmun.",
	},
})

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
