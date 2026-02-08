local internalNpcName = "Grizzly Adams"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 144,
	lookHead = 116,
	lookBody = 78,
	lookLegs = 94,
	lookFeet = 78,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.shop = {
	-- HuntsMan rank
	-- Sell offers
	{ clientId = 10297, sell = 50, itemName = "antlers", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 9633, sell = 100, itemName = "bloody pincers", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 10272, sell = 35, itemName = "crab pincers", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 9657, sell = 55, itemName = "cyclops toe", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 12316, sell = 550, itemName = "cavebear skull", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 17818, sell = 150, itemName = "cheesy figurine", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 11514, sell = 110, itemName = "colourful feather", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 7398, sell = 500, itemName = "cyclops trophy", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 10398, sell = 15000, itemName = "draken trophy", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 12309, sell = 800, itemName = "draptor scales", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 18994, sell = 115, itemName = "elven hoof", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 9648, sell = 30, itemName = "frosty ear of a troll", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 12317, sell = 950, itemName = "giant crab pincer", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 11539, sell = 20, itemName = "goblin ear", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 12314, sell = 400, itemName = "hollow stampor hoof", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 10282, sell = 600, itemName = "hydra head", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 10455, sell = 80, itemName = "lancer beetle shell", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 10419, sell = 8000, itemName = "lizard trophy", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 11489, sell = 280, itemName = "mantassin tail", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 17461, sell = 65, itemName = "marsh stalker beak", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 17462, sell = 50, itemName = "marsh stalker feather", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 12315, sell = 250, itemName = "maxilla", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 7401, sell = 500, itemName = "minotaur trophy", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 9662, sell = 420, itemName = "mutated bat ear", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 12039, sell = 750, itemName = "panther head", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 12040, sell = 300, itemName = "panther paw", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 11491, sell = 500, itemName = "quara bone", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 11491, sell = 350, itemName = "quara eye", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 11490, sell = 410, itemName = "quara pincers", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 11487, sell = 140, itemName = "quara tentacle", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 12172, sell = 50, itemName = "rabbit's foot", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 18993, sell = 70, itemName = "rorc feather", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 10311, sell = 400, itemName = "sabretooth", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 10456, sell = 20, itemName = "sandcrawler shell", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 9631, sell = 280, itemName = "scarab pincers", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 12312, sell = 280, itemName = "stampor horn", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 12313, sell = 150, itemName = "stampor talons", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 10454, sell = 60, itemName = "terramite legs", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 10452, sell = 170, itemName = "terramite shell", storageKey = POINTSSTORAGE, storageValue = 10 },
	{ clientId = 10273, sell = 95, itemName = "terrorbird beak", storageKey = POINTSSTORAGE, storageValue = 10 },
	-- Buy offers
	{ clientId = 5907, buy = 35000, itemName = "slingshot", storageKey = POINTSSTORAGE, storageValue = 20 },

	-- BigGameHunter rank
	{ clientId = 10244, sell = 6000, itemName = "bonebeast trophy", storageKey = POINTSSTORAGE, storageValue = 40 },
	{ clientId = 7397, sell = 3000, itemName = "deer trophy", storageKey = POINTSSTORAGE, storageValue = 40 },
	{ clientId = 7400, sell = 3000, itemName = "lion trophy", storageKey = POINTSSTORAGE, storageValue = 40 },
	{ clientId = 7395, sell = 1000, itemName = "orc trophy", storageKey = POINTSSTORAGE, storageValue = 40 },
	{ clientId = 7394, sell = 3000, itemName = "wolf trophy", storageKey = POINTSSTORAGE, storageValue = 40 },

	-- TrophyHunter rank
	-- Sell offers
	{ clientId = 7396, sell = 20000, itemName = "behemoth trophy", storageKey = POINTSSTORAGE, storageValue = 70 },
	{ clientId = 7393, sell = 40000, itemName = "demon trophy", storageKey = POINTSSTORAGE, storageValue = 70 },
	{ clientId = 7399, sell = 10000, itemName = "dragon lord trophy", storageKey = POINTSSTORAGE, storageValue = 70 },
	{ clientId = 10421, sell = 3000, itemName = "disgusting trophy", storageKey = POINTSSTORAGE, storageValue = 70 },
	{ clientId = 22101, sell = 9000, itemName = "werebadger trophy", storageKey = POINTSSTORAGE, storageValue = 70 },
	{ clientId = 22102, sell = 10000, itemName = "wereboar trophy", storageKey = POINTSSTORAGE, storageValue = 70 },
	{ clientId = 22103, sell = 11000, itemName = "werebear trophy", storageKey = POINTSSTORAGE, storageValue = 70 },
	{ clientId = 27706, sell = 9000, itemName = "werefox trophy", storageKey = POINTSSTORAGE, storageValue = 70 },
	{ clientId = 34219, sell = 12000, itemName = "werehyaena trophy", storageKey = POINTSSTORAGE, storageValue = 70 },
	-- Buy offers
	{ clientId = 9601, buy = 1000, itemName = "demon backpack", storageKey = POINTSSTORAGE, storageValue = 70 },
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
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry) ~= 0 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.grizzly_adams.greet_msg_1")
	elseif
		player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) < 0 and player:getStorageValue(POINTSSTORAGE) >= 10 and player:getLevel() >= 6 -- to Huntsman Rank
		or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 0 and player:getStorageValue(POINTSSTORAGE) >= 20 and player:getLevel() >= 6 -- to Ranger Rank
		or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 2 and player:getStorageValue(POINTSSTORAGE) >= 40 and player:getLevel() >= 50 -- to Big Game Hunter Rank
		or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 4 and player:getStorageValue(POINTSSTORAGE) >= 70 and player:getLevel() >= 80 -- to Trophy Hunter Rank
		or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 6 and player:getStorageValue(POINTSSTORAGE) >= 100 and player:getLevel() >= 130
	then -- to Elite Hunter Rank
		npcHandler:setLocalizedMessage(MESSAGE_GREET, "npc.grizzly_adams.greet_msg_3", {
			args = function(targetPlayer)
				return { targetPlayer:getName(), targetPlayer:getStorageValue(POINTSSTORAGE) }
			end,
		})
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.grizzly_adams.greet_msg_2")
	end
	return true
end
local choose = {}
local cancel = {}
local KillCounter = Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.KillCount

-- Helper: say an i18n message that can be a single key (string) or multi-part (table of keys)
local function sayI18nMsg(npcH, npc, creature, msg)
	if type(msg) == "table" then
		NPC_LIB.i18n.npcSayMultiple(npcH, npc, creature, msg)
	else
		NPC_LIB.i18n.npcSay(npcH, npc, creature, msg)
	end
end

local messageYes = {
	[1] = "npc.grizzly_adams.yes_1",
	[2] = "npc.grizzly_adams.yes_2",
	[3] = "npc.grizzly_adams.yes_3",
	[4] = "npc.grizzly_adams.yes_4",
	[5] = "npc.grizzly_adams.yes_5",
	[6] = "npc.grizzly_adams.yes_6",
	[7] = "npc.grizzly_adams.yes_7",
	[8] = "npc.grizzly_adams.yes_8",
	[9] = "npc.grizzly_adams.yes_9",
	[10] = "npc.grizzly_adams.yes_10",
}
local messageTask = {
	[1] = "npc.grizzly_adams.task_complete_1",
	[2] = "npc.grizzly_adams.task_complete_2",
	[3] = "npc.grizzly_adams.task_complete_3",
	[4] = "npc.grizzly_adams.task_complete_4",
}
local messageBoss = {
	{ "npc.grizzly_adams.boss_intro_1a", "npc.grizzly_adams.boss_intro_1b" }, -- Snapper
	"npc.grizzly_adams.boss_intro_2", -- Hide
	{ "npc.grizzly_adams.boss_intro_3a", "npc.grizzly_adams.boss_intro_3b" }, -- Deathbine
	"npc.grizzly_adams.boss_intro_4", -- Blood Tusk
	{ "npc.grizzly_adams.boss_intro_5a", "npc.grizzly_adams.boss_intro_5b" }, -- Shardhead
	{ "npc.grizzly_adams.boss_intro_6a", "npc.grizzly_adams.boss_intro_6b" }, -- Esmeralda
	{ "npc.grizzly_adams.boss_intro_7a", "npc.grizzly_adams.boss_intro_7b", "npc.grizzly_adams.boss_intro_7c" }, -- Fleshcrawler
	{ "npc.grizzly_adams.boss_intro_8a", "npc.grizzly_adams.boss_intro_8b" }, -- Ribstride
	{ "npc.grizzly_adams.boss_intro_9a", "npc.grizzly_adams.boss_intro_9b" }, -- Bloodweb
	{ "npc.grizzly_adams.boss_intro_10a", "npc.grizzly_adams.boss_intro_10b" }, -- Thul
	"npc.grizzly_adams.boss_intro_11", -- Old Widow
	{ "npc.grizzly_adams.boss_intro_12a", "npc.grizzly_adams.boss_intro_12b" }, -- Hemming
	{ "npc.grizzly_adams.boss_intro_13a", "npc.grizzly_adams.boss_intro_13b" }, -- Tormentor
	"npc.grizzly_adams.boss_intro_14", -- Flameborn
	{ "npc.grizzly_adams.boss_intro_15a", "npc.grizzly_adams.boss_intro_15b" }, -- Fazzrah
	{ "npc.grizzly_adams.boss_intro_16a", "npc.grizzly_adams.boss_intro_16b", "npc.grizzly_adams.boss_intro_16c" }, -- Tromphonyte
	"npc.grizzly_adams.boss_intro_17", -- Sulphur Scuttler
	"npc.grizzly_adams.boss_intro_18", -- Bruise Payne
	"npc.grizzly_adams.boss_intro_19", -- Many
	{ "npc.grizzly_adams.boss_intro_20a", "npc.grizzly_adams.boss_intro_20b" }, -- Noxious Spawn
	"npc.grizzly_adams.boss_intro_21", -- Gorgo
	{ "npc.grizzly_adams.boss_intro_22a", "npc.grizzly_adams.boss_intro_22b" }, -- Stonecracker
	{ "npc.grizzly_adams.boss_intro_23a", "npc.grizzly_adams.boss_intro_23b", "npc.grizzly_adams.boss_intro_23c" }, -- Leviathan
	{ "npc.grizzly_adams.boss_intro_24a", "npc.grizzly_adams.boss_intro_24b" }, -- Kerberos
	"npc.grizzly_adams.boss_intro_25", -- Ethershreck
	"npc.grizzly_adams.boss_intro_26", -- Paiz
	"npc.grizzly_adams.boss_intro_27", -- Bretzecutioner
	"npc.grizzly_adams.boss_intro_28", -- Zanakeph
}
local messageBossStart = {
	"npc.grizzly_adams.boss_start_default", -- Snapper
	"npc.grizzly_adams.boss_start_default", -- Hide
	"npc.grizzly_adams.boss_start_deathbine", -- Deathbine
	"npc.grizzly_adams.boss_start_default", -- Blood Tusk
	"npc.grizzly_adams.boss_start_default", -- Shardhead
	"npc.grizzly_adams.boss_start_default", -- Esmeralda
	"npc.grizzly_adams.boss_start_default", -- Fleshcrawler
	"npc.grizzly_adams.boss_start_default", -- Ribstride
	"npc.grizzly_adams.boss_start_default", -- Bloodweb
	"npc.grizzly_adams.boss_start_default", -- Thul
	"npc.grizzly_adams.boss_start_default", -- Old Widow
	"npc.grizzly_adams.boss_start_default", -- Hemming
	"npc.grizzly_adams.boss_start_default", -- Tormentor
	"npc.grizzly_adams.boss_start_default", -- Flameborn
	"npc.grizzly_adams.boss_start_default", -- Fazzrah
	"npc.grizzly_adams.boss_start_default", -- Tromphonyte
	"npc.grizzly_adams.boss_start_default", -- Sulphur Scuttler
	"npc.grizzly_adams.boss_start_default", -- Bruise Payne
	"npc.grizzly_adams.boss_start_many", -- Many
	"npc.grizzly_adams.boss_start_default", -- Noxious Spawn
	"npc.grizzly_adams.boss_start_gorgo", -- Gorgo
	"npc.grizzly_adams.boss_start_stonecracker", -- Stonecracker
	"npc.grizzly_adams.boss_start_default", -- Leviathan
	"npc.grizzly_adams.boss_start_default", -- Kerberos
	"npc.grizzly_adams.boss_start_default", -- Ethershreck
	"npc.grizzly_adams.boss_start_default", -- Paiz
	"npc.grizzly_adams.boss_start_default", -- Bretzecutioner
	"npc.grizzly_adams.boss_start_default", -- Zanakeph
}
local tier = {
	{
		allName = { "crocodiles", "badgers", "tarantulas", "carniphilas", "stone golems", "mammoths", "gnarlhounds", "terramites", "apes", "thornback tortoises", "gargoyles", "crocodile", "badger", "tarantula", "carniphila", "stone golem", "mammoth", "gnarlhound", "terramite", "ape", "thornback tortoise", "gargoyle" },
		withsName = { "crocodiles", "badgers", "tarantulas", "carniphilas", "stone golems", "mammoths", "gnarlhounds", "terramites", "apes", "thornback tortoises", "gargoyles" },
	},
	{
		allName = { "ice golems", "quara scouts", "mutated rats", "ancient scarabs", "wyverns", "lancer beetles", "wailing widows", "killer caimans", "bonebeasts", "crystal spiders", "mutated tigers", "ice golem", "quara scout", "mutated rat", "ancient scarab", "wyvern", "lancer beetle", "wailing widow", "killer caiman", "bonebeast", "crystal spider", "mutated tiger" },
		withsName = { "ice golems", "quara scouts", "mutated rats", "ancient scarabs", "wyverns", "lancer beetles", "wailing widows", "killer caimans", "bonebeasts", "crystal spiders", "mutated tigers" },
	},
	{
		allName = { "underwater quara", "giant spiders", "werewolves", "nightmares", "hellspawns", "high class lizards", "stampors", "brimstone bugs", "mutated bats", "giant spider", "werewolve", "nightmare", "hellspawn", "high class lizard", "stampor", "brimstone bug", "mutated bat" },
		withsName = { "underwater quara", "giant spiders", "werewolves", "nightmares", "hellspawns", "high class lizards", "stampors", "brimstone bugs", "mutated bats" },
	},
	{
		allName = { "hydras", "serpent spawns", "medusae", "behemoths", "sea serpents", "hellhounds", "ghastly dragons", "undead dragons", "drakens", "destroyers", "hydra", "serpent spawn", "medusa", "behemoth", "sea serpent", "hellhound", "ghastly dragon", "undead dragon", "draken", "destroyer" },
		withsName = { "hydras", "serpent spawns", "medusae", "behemoths", "sea serpents", "hellhounds", "ghastly dragons", "undead dragons", "drakens", "destroyers" },
	},
}
local messageStartTask = {
	["crocodiles"] = "npc.grizzly_adams.start_task_crocodiles",
	["badgers"] = "npc.grizzly_adams.start_task_badgers",
	["tarantulas"] = "npc.grizzly_adams.start_task_tarantulas",
	["stone golems"] = "npc.grizzly_adams.start_task_stone_golems",
	["mammoths"] = "npc.grizzly_adams.start_task_mammoths",
	["gnarlhounds"] = "npc.grizzly_adams.start_task_gnarlhounds",
	["terramites"] = "npc.grizzly_adams.start_task_terramites",
	["apes"] = "npc.grizzly_adams.start_task_apes",
	["thornback tortoises"] = "npc.grizzly_adams.start_task_thornback_tortoises",
	["gargoyles"] = "npc.grizzly_adams.start_task_gargoyles",
	["ice golems"] = "npc.grizzly_adams.start_task_ice_golems",
	["quara scouts"] = "npc.grizzly_adams.start_task_quara_scouts",
	["mutated rats"] = "npc.grizzly_adams.start_task_mutated_rats",
	["ancient scarabs"] = "npc.grizzly_adams.start_task_ancient_scarabs",
	["wyverns"] = "npc.grizzly_adams.start_task_wyverns",
	["lancer beetles"] = "npc.grizzly_adams.start_task_lancer_beetles",
	["wailing widows"] = "npc.grizzly_adams.start_task_wailing_widows",
	["killer caimans"] = "npc.grizzly_adams.start_task_killer_caimans",
	["bonebeasts"] = "npc.grizzly_adams.start_task_bonebeasts",
	["crystal spiders"] = "npc.grizzly_adams.start_task_crystal_spiders",
	["mutated tigers"] = "npc.grizzly_adams.start_task_mutated_tigers",
	["underwater quara"] = "npc.grizzly_adams.start_task_underwater_quara",
	["giant spiders"] = "npc.grizzly_adams.start_task_giant_spiders",
	["werewolves"] = "npc.grizzly_adams.start_task_werewolves",
	["nightmares"] = "npc.grizzly_adams.start_task_nightmares",
	["hellspawns"] = "npc.grizzly_adams.start_task_hellspawns",
	["high class lizards"] = "npc.grizzly_adams.start_task_high_class_lizards",
	["stampors"] = "npc.grizzly_adams.start_task_stampors",
	["brimstone bugs"] = "npc.grizzly_adams.start_task_brimstone_bugs",
	["mutated bats"] = "npc.grizzly_adams.start_task_mutated_bats",
	["hydras"] = "npc.grizzly_adams.start_task_hydras",
	["serpent spawns"] = "npc.grizzly_adams.start_task_serpent_spawns",
	["medusae"] = "npc.grizzly_adams.start_task_medusae",
	["behemoths"] = "npc.grizzly_adams.start_task_behemoths",
	["sea serpents"] = { "npc.grizzly_adams.start_task_sea_serpents_1", "npc.grizzly_adams.start_task_sea_serpents_2" },
	["hellhounds"] = "npc.grizzly_adams.start_task_hellhounds",
	["ghastly dragons"] = "npc.grizzly_adams.start_task_ghastly_dragons",
	["undead dragons"] = "npc.grizzly_adams.start_task_undead_dragons",
	["drakens"] = "npc.grizzly_adams.start_task_drakens",
	["destroyers"] = "npc.grizzly_adams.start_task_destroyers",
}
local messageStartTaskAlt = {
	["crocodile"] = messageStartTask["crocodiles"],
	["badger"] = messageStartTask["badgers"],
	["tarantula"] = messageStartTask["tarantulas"],
	["stone golem"] = messageStartTask["stone golems"],
	["mammoth"] = messageStartTask["mammoths"],
	["gnarlhound"] = messageStartTask["gnarlhounds"],
	["terramite"] = messageStartTask["terramites"],
	["ape"] = messageStartTask["apes"],
	["thornback tortoise"] = messageStartTask["thornback tortoises"],
	["gargoyle"] = messageStartTask["gargoyles"],
	["ice golem"] = messageStartTask["ice golems"],
	["quara scout"] = messageStartTask["quara scouts"],
	["mutated rat"] = messageStartTask["mutated rats"],
	["ancient scarab"] = messageStartTask["ancient scarabs"],
	["wyvern"] = messageStartTask["wyverns"],
	["lancer beetle"] = messageStartTask["lancer beetles"],
	["wailing widow"] = messageStartTask["wailing widows"],
	["killer caiman"] = messageStartTask["killer caimans"],
	["bonebeast"] = messageStartTask["bonebeasts"],
	["crystal spider"] = messageStartTask["crystal spiders"],
	["mutated tiger"] = messageStartTask["mutated tigers"],
	["giant spider"] = messageStartTask["giant spiders"],
	["werewolve"] = messageStartTask["werewolves"],
	["nightmare"] = messageStartTask["nightmares"],
	["hellspawn"] = messageStartTask["hellspawns"],
	["high class lizard"] = messageStartTask["high class lizards"],
	["stampor"] = messageStartTask["stampors"],
	["brimstone bug"] = messageStartTask["brimstone bugs"],
	["mutated bat"] = messageStartTask["mutated bats"],
	["hydra"] = messageStartTask["hydras"],
	["serpent spawn"] = messageStartTask["serpent spawns"],
	["medusa"] = messageStartTask["medusae"],
	["behemoth"] = messageStartTask["behemoths"],
	["sea serpent"] = messageStartTask["sea serpents"],
	["hellhound"] = messageStartTask["hellhounds"],
	["ghastly dragon"] = messageStartTask["ghastly dragons"],
	["undead dragon"] = messageStartTask["undead dragons"],
	["draken"] = messageStartTask["drakens"],
	["destroyer"] = messageStartTask["destroyers"],
}
local function checkX(npc, player, d, message)
	for m = 1, #tasks.GrizzlyAdams do
		if tasks.GrizzlyAdams[m].bossName then
			if tasks.GrizzlyAdams[m].bossName:lower() == message:lower() then
				for n = 1, #tasks.GrizzlyAdams[m].rewards do
					if table.contains({ REWARD_STORAGE, "storage", "stor" }, tasks.GrizzlyAdams[m].rewards[n].type:lower()) then
						if player:getStorageValue(tasks.GrizzlyAdams[m].rewards[n].value[1]) < 0 and player:getLevel() >= d then
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_1")
							player:setStorageValue(tasks.GrizzlyAdams[m].rewards[n].value[1], 1)
							player:setStorageValue(tasks.GrizzlyAdams[m].rewards[n].value[2], 0)
						elseif player:getStorageValue(tasks.GrizzlyAdams[m].rewards[n].value[1]) == 3 or player:getStorageValue(tasks.GrizzlyAdams[m].rewards[n].value[1]) < 0 then
							NPC_LIB.i18n.npcSay(npcHandler, npc, player, messageBossStart[tasks.GrizzlyAdams[m].bossId])
							player:setStorageValue(tasks.GrizzlyAdams[m].rewards[n].value[1], 1)
							player:setStorageValue(tasks.GrizzlyAdams[m].rewards[n].value[2], 0)
							player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossPoints, player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossPoints) - 1)
							player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry, player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry)) -- fake update
							return true
						else
							NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.grizzly_adams.say_1", { tasks.GrizzlyAdams[m].bossName })
						end
					end
				end
			end
		end
	end
end
local function checkY(npc, player, message)
	for a = 1, #tasks.GrizzlyAdams do
		if message:lower() == tasks.GrizzlyAdams[a].raceName:lower() then
			if player:getStorageValue(REPEATSTORAGE_BASE + a) == 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.grizzly_adams.say_2", { player:getStorageValue(REPEATSTORAGE_BASE + a) })
				return true
			end
		end
	end
end
local function checkZ(npc, player, message)
	for k = 1, #tasks.GrizzlyAdams do
		for o = 1, #tasks.GrizzlyAdams[k].rewards do
			if table.contains({ REWARD_ACHIEVEMENT, "achievement", "ach" }, tasks.GrizzlyAdams[k].rewards[o].type:lower()) then
				if player:getStorageValue(tasks.GrizzlyAdams[k].rewards[o + 1].value[1]) == 2 and player:getStorageValue(tasks.GrizzlyAdams[k].rewards[o + 1].value[2]) == 0 then
					player:setStorageValue(tasks.GrizzlyAdams[k].rewards[o + 1].value[1], 1)
				end
				if player:getStorageValue(tasks.GrizzlyAdams[k].rewards[o + 1].value[1]) == 2 and player:getStorageValue(tasks.GrizzlyAdams[k].rewards[o + 1].value[2]) == 1 then
					player:setStorageValue(tasks.GrizzlyAdams[k].rewards[o + 1].value[1], 3)
					player:setStorageValue(tasks.GrizzlyAdams[k].rewards[o + 1].value[2], 0)
					player:addAchievement(tasks.GrizzlyAdams[k].rewards[o].value[1])
					NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.grizzly_adams.say_3", { tasks.GrizzlyAdams[k].bossName })
					return true
				end
			end
		end
	end
end
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	message = message:gsub("(%l)(%w*)", function(a, b)
		return string.upper(a) .. b
	end)

	if (MsgContains("join", message) or MsgContains("yes", message)) and npcHandler:getTopic(playerId) == 0 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry) ~= 0 then
		player:setStorageValue(JOIN_STOR, 1)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossPoints, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry, 0)
		player:setStorageValue(POINTSSTORAGE, 0)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_1")
	elseif table.contains({ "report", "reports" }, message:lower()) then
		if checkZ(npc, player, message) == true then
			return true
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_2")
		end
	elseif table.contains({ "tasks", "task", "mission" }, message:lower()) then
		if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry) ~= 0 then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_3")
		end
		if checkZ(npc, player, message) == true then
			return true
		end
		if
			player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) < 0 and player:getStorageValue(POINTSSTORAGE) >= 10 and player:getLevel() >= 6 -- to Huntsman Rank
			or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 0 and player:getStorageValue(POINTSSTORAGE) >= 20 and player:getLevel() >= 6 -- to Ranger Rank
			or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 2 and player:getStorageValue(POINTSSTORAGE) >= 40 and player:getLevel() >= 50 -- to Big Game Hunter Rank
			or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 4 and player:getStorageValue(POINTSSTORAGE) >= 70 and player:getLevel() >= 80 -- to Trophy Hunter Rank
			or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 6 and player:getStorageValue(POINTSSTORAGE) >= 100 and player:getLevel() >= 130
		then -- to Elite Hunter Rank
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_4")
			return true
		end
		local messageAlt, messageAltPoints, messageAltExtra, messageAltExtraPoints = false, false, false, false
		local extraValue = 0
		local messageAltId = 1
		local started = player:getStartedTasks()
		local finished = 0
		if started and #started > 0 then
			local id, reward
			for i = 1, #started do
				id = started[i]
				if player:getStorageValue(KillCounter + id) >= tasks.GrizzlyAdams[id].killsRequired then
					finished = finished + 1
					for j = 1, #tasks.GrizzlyAdams[id].rewards do
						reward = tasks.GrizzlyAdams[id].rewards[j]
						local deny = false
						if reward.storage then
							if player:getStorageValue(reward.storage[1]) >= reward.storage[2] then
								deny = true
							end
						end
						if table.contains({ REWARD_MONEY, "money" }, reward.type:lower()) and not deny then
							player:addMoney(reward.value[1])
						elseif table.contains({ REWARD_EXP, "exp", "experience" }, reward.type:lower()) and not deny then
							player:addExperience(reward.value[1], true)
						elseif table.contains({ REWARD_STORAGE, "storage", "stor" }, reward.type:lower()) and not deny then
							if #reward.value == 2 then
								player:setStorageValue(reward.value[1], reward.value[2])
								if tasks.GrizzlyAdams[id].raceName:lower() == "demons" then
									messageAltExtra = true
								end
							elseif table.contains({ 1, 2 }, player:getStorageValue(reward.value[1])) then
								player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossPoints, player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossPoints) + 1)
							else
								player:setStorageValue(reward.value[1], reward.value[3])
								player:setStorageValue(reward.value[2], reward.value[4])
								messageAlt = true
								messageAltId = tasks.GrizzlyAdams[id].bossId
							end
						elseif table.contains({ REWARD_POINT, "points", "point" }, reward.type:lower()) and not deny then
							local ratePoints = 1
							if configKeys.RATE_KILLING_IN_THE_NAME_OF_POINTS then
								ratePoints = configManager.getNumber(configKeys.RATE_KILLING_IN_THE_NAME_OF_POINTS)
							end

							local pointsToReceive = reward.value[1] * ratePoints
							if player:getStorageValue(POINTSSTORAGE) >= 40 and player:getLevel() < 50 or player:getStorageValue(POINTSSTORAGE) >= 70 and player:getLevel() < 80 or player:getStorageValue(POINTSSTORAGE) >= 100 and player:getLevel() < 130 then
								messageAltPoints = true
							elseif player:getLevel() >= 130 and player:getStorageValue(POINTSSTORAGE) <= 20 then
								player:setStorageValue(POINTSSTORAGE, getPlayerTasksPoints(creature) + pointsToReceive + 3)
								messageAltExtraPoints = true
								extraValue = 3
								player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry, player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry)) -- fake update
							elseif player:getLevel() >= 130 and player:getStorageValue(POINTSSTORAGE) <= 40 then
								player:setStorageValue(POINTSSTORAGE, getPlayerTasksPoints(creature) + pointsToReceive + 2)
								messageAltExtraPoints = true
								extraValue = 2
								player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry, player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry)) -- fake update
							elseif player:getLevel() >= 130 and player:getStorageValue(POINTSSTORAGE) <= 70 then
								player:setStorageValue(POINTSSTORAGE, getPlayerTasksPoints(creature) + pointsToReceive + 1)
								messageAltExtraPoints = true
								extraValue = 1
								player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry, player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry)) -- fake update
							else
								player:setStorageValue(POINTSSTORAGE, getPlayerTasksPoints(creature) + pointsToReceive)
								player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry, player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.QuestLogEntry)) -- fake update
							end
						elseif table.contains({ REWARD_ITEM, "item", "items", "object" }, reward.type:lower()) and not deny then
							player:addItem(reward.value[1], reward.value[2])
						end

						if reward.storage then
							player:setStorageValue(reward.storage[1], reward.storage[2])
						end
					end

					player:setStorageValue(QUESTSTORAGE_BASE + id, (tasks.GrizzlyAdams[id].norepeatable and 2 or 0))
					if tasks.GrizzlyAdams[id].repeatable then
						player:setStorageValue(REPEATSTORAGE_BASE + id, math.max(player:getStorageValue(REPEATSTORAGE_BASE + id), 0))
					else
						player:setStorageValue(REPEATSTORAGE_BASE + id, math.max(player:getStorageValue(REPEATSTORAGE_BASE + id), 0))
						player:setStorageValue(REPEATSTORAGE_BASE + id, player:getStorageValue(REPEATSTORAGE_BASE + id) + 1)
					end
					if player:getStorageValue(REPEATSTORAGE_BASE + id) == 3 then
						player:setStorageValue(KILLSSTORAGE_BASE + id, 2)
					else
						player:setStorageValue(KILLSSTORAGE_BASE + id, player:getStorageValue(KILLSSTORAGE_BASE + id) + 1)
					end
					player:setStorageValue(KillCounter, 0)
				end
			end
		end
		if messageAltExtra == true then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_37")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_38")
			return true
		end
		if finished > 0 then
			local chanceY = math.random(4)
			if finished == 1 then
				if messageAlt == false then
					if messageAltPoints == true then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_35")
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_36")
					elseif messageAltExtraPoints == true then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_4", { extraValue })
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, messageTask[chanceY])
					end
				else
					sayI18nMsg(npcHandler, npc, creature, messageBoss[messageAltId])
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, messageTask[chanceY])
			end
			return true
		end
		if #player:getStartedTasks() >= tasksByPlayer then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_6")
			npcHandler:setTopic(playerId, 10)
			return true
		end
		if player:getLevel() < 50 then
			if player:getStorageValue(POINTSSTORAGE) >= 40 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_32")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_33")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_34")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_7")
			end
		elseif player:getLevel() >= 50 and player:getLevel() < 80 then
			if player:getStorageValue(POINTSSTORAGE) >= 70 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_29")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_30")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_31")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_27")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_28")
			end
		elseif player:getLevel() >= 80 and player:getLevel() < 130 then
			if player:getStorageValue(POINTSSTORAGE) >= 100 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_24")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_25")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_26")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_22")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_23")
			end
		elseif player:getLevel() >= 130 and player:getStorageValue(POINTSSTORAGE) < 100 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_21")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_19")
		end
		npcHandler:setTopic(playerId, 0)
	elseif message ~= "" and player:canStartTask(message) then
		if #player:getStartedTasks() >= tasksByPlayer then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_8")
			npcHandler:setTopic(playerId, 10)
			return true
		end
		local task = getTaskByName(message)
		if task and player:getStorageValue(QUESTSTORAGE_BASE + task) > 0 then
			return false
		end
		local messageElseKey = "npc.grizzly_adams.else_max_rank"
		if table.contains(tier[1].allName, message:lower()) then
			if player:getStorageValue(POINTSSTORAGE) >= 40 and player:getLevel() < 50 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, messageElseKey, { tasks.GrizzlyAdams[task].killsRequired, tasks.GrizzlyAdams[task].raceName })
			elseif table.contains({ "carniphilas", "carniphila" }, message:lower()) then
				local chanceX = math.random(2)
				local messageCarniphilas = {
					[1] = "npc.grizzly_adams.carniphilas_1",
					[2] = "npc.grizzly_adams.carniphilas_2",
				}
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, messageCarniphilas[chanceX])
			elseif table.contains(tier[1].withsName, message:lower()) then
				sayI18nMsg(npcHandler, npc, creature, messageStartTask[message:lower()])
			else
				sayI18nMsg(npcHandler, npc, creature, messageStartTaskAlt[message:lower()])
			end
		elseif table.contains(tier[2].allName, message:lower()) then
			if player:getStorageValue(POINTSSTORAGE) >= 70 and player:getLevel() < 80 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, messageElseKey, { tasks.GrizzlyAdams[task].killsRequired, tasks.GrizzlyAdams[task].raceName })
			elseif table.contains(tier[2].withsName, message:lower()) then
				sayI18nMsg(npcHandler, npc, creature, messageStartTask[message:lower()])
			else
				sayI18nMsg(npcHandler, npc, creature, messageStartTaskAlt[message:lower()])
			end
		elseif table.contains(tier[3].allName, message:lower()) then
			if player:getStorageValue(POINTSSTORAGE) >= 100 and player:getLevel() < 130 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, messageElseKey, { tasks.GrizzlyAdams[task].killsRequired, tasks.GrizzlyAdams[task].raceName })
			elseif table.contains(tier[3].withsName, message:lower()) then
				sayI18nMsg(npcHandler, npc, creature, messageStartTask[message:lower()])
			else
				sayI18nMsg(npcHandler, npc, creature, messageStartTaskAlt[message:lower()])
			end
		elseif table.contains(tier[4].allName, message:lower()) then
			if table.contains(tier[4].withsName, message:lower()) then
				sayI18nMsg(npcHandler, npc, creature, messageStartTask[message:lower()])
			else
				sayI18nMsg(npcHandler, npc, creature, messageStartTaskAlt[message:lower()])
			end
		elseif table.contains({ "demons", "demon" }, message:lower()) and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_9")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_5", { tasks.GrizzlyAdams[task].killsRequired, tasks.GrizzlyAdams[task].raceName })
		end
		choose[playerId] = task
		npcHandler:setTopic(playerId, 1)
	elseif table.contains(tier[1].allName, message:lower()) and player:getLevel() < 50 and npcHandler:getTopic(playerId) < 2 then
		checkY(npc, player, message)
	elseif table.contains(tier[2].allName, message:lower()) and player:getLevel() < 80 and npcHandler:getTopic(playerId) < 2 then
		checkY(npc, player, message)
	elseif table.contains(tier[3].allName, message:lower()) and player:getLevel() < 130 and npcHandler:getTopic(playerId) < 2 then
		checkY(npc, player, message)
	elseif message:lower() == "yes" and npcHandler:getTopic(playerId) == 1 then
		player:setStorageValue(QUESTSTORAGE_BASE + choose[playerId], 1)
		player:setStorageValue(KillCounter + choose[playerId], 0)
		if #tasks.GrizzlyAdams[choose[playerId]].creatures > 1 then
			if tasks.GrizzlyAdams[choose[playerId]].raceName == "Apes" then
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.KongraCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.MerlkinCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.SibangCount, 0)
			elseif tasks.GrizzlyAdams[choose[playerId]].raceName == "Quara Scouts" then
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.QuaraConstrictorScoutCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.QuaraHydromancerScoutCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.QuaramMntassinScoutCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.QuaraPincherScoutCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.QuaraPredatorScoutCount, 0)
			elseif tasks.GrizzlyAdams[choose[playerId]].raceName == "Underwater Quara" then
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.QuaraConstrictorCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.QuaraHydromancerCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.QuaraMantassinCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.QuaraPincherCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.QuaraPredatorCount, 0)
			elseif tasks.GrizzlyAdams[choose[playerId]].raceName == "Nightmares" then
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.NightmareCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.NightmareScionCount, 0)
			elseif tasks.GrizzlyAdams[choose[playerId]].raceName == "High Class Lizards" then
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.LizardChosenCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.LizardDragonPriestCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.LizardHighGuardCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.LizardLegionnaireCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.LizardZaogunCount, 0)
			elseif tasks.GrizzlyAdams[choose[playerId]].raceName == "Sea Serpents" then
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.SeaSerpentCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.YoungSeaSerpentCount, 0)
			elseif tasks.GrizzlyAdams[choose[playerId]].raceName == "Drakens" then
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.DrakenAbominationCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.DrakenEliteCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.DrakenSpellweaverCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.DrakenWarmasterCount, 0)
			end
		end
		if player:getStorageValue(KILLSSTORAGE_BASE + choose[playerId]) == 1 then
			player:setStorageValue(KILLSSTORAGE_BASE + choose[playerId], player:getStorageValue(KILLSSTORAGE_BASE + choose[playerId]) - 1)
		else
			player:setStorageValue(KILLSSTORAGE_BASE + choose[playerId], player:getStorageValue(KILLSSTORAGE_BASE + choose[playerId]) + 1)
		end
		local chance = math.random(10)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, messageYes[chance])
		choose[playerId] = nil
		npcHandler:setTopic(playerId, 0)
		elseif MsgContains("status", message) then
			local started = player:getStartedTasks()
			if started and #started > 0 then
				local statusText = ""
				table.sort(started, function(a, b)
					return (a < b)
				end)
				local t = 0
				local id
				for i = 1, #started do
					id = started[i]
					t = t + 1
					statusText = statusText .. "Task name: " .. tasks.GrizzlyAdams[id].raceName .. ". " .. "Current kills: " .. player:getStorageValue(KillCounter + id) .. ".\n"
				end
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_11")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_12")
		end
	elseif table.contains({ "promotion", "promotions" }, message:lower()) then
		if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) < 0 and player:getStorageValue(POINTSSTORAGE) >= 10 and player:getLevel() >= 6 then -- to Huntsman Rank
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_16")
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank, 0)
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 0 and player:getStorageValue(POINTSSTORAGE) >= 20 and player:getLevel() >= 6 then -- to Ranger Rank
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_14")
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank, 2)
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 2 and player:getStorageValue(POINTSSTORAGE) >= 40 and player:getLevel() >= 50 then -- to Big Game Hunter Rank
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_12")
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank, 4)
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 4 and player:getStorageValue(POINTSSTORAGE) >= 70 and player:getLevel() >= 80 then -- to Trophy Hunter Rank
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_10")
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank, 6)
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank) == 6 and player:getStorageValue(POINTSSTORAGE) >= 100 and player:getLevel() >= 130 then -- to Elite Hunter Rank
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_13")
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PawAndFurRank, 7)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_14")
		end
	elseif table.contains({ "boss", "bosses" }, message:lower()) then
		if checkZ(npc, player, message) == true then
			return true
		end
		if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossPoints) > 0 then
			if player:getLevel() < 50 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_15")
				npcHandler:setTopic(playerId, 4)
			elseif player:getLevel() >= 50 and player:getLevel() < 80 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_8")
				npcHandler:setTopic(playerId, 5)
			elseif player:getLevel() >= 80 and player:getLevel() < 130 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_6")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_7")
				npcHandler:setTopic(playerId, 6)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_5")
				npcHandler:setTopic(playerId, 7)
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_6", { player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossPoints) })
		end
	elseif table.contains({ "snapper", "hide", "deathbine", "bloodtusk" }, message:lower()) and npcHandler:getTopic(playerId) >= 4 and npcHandler:getTopic(playerId) <= 7 then
		checkX(npc, player, 50, message)
	elseif table.contains({ "shardhead", "fleshcrawler", "ribstride", "bloodweb", "esmeralda" }, message:lower()) and npcHandler:getTopic(playerId) >= 5 and npcHandler:getTopic(playerId) <= 7 then
		checkX(npc, player, 80, message)
	elseif table.contains({ "thul", "flameborn", "sulphur scuttler", "old widow", "hemming", "tormentor", "fazzrah", "tromphonyte", "bruise payne" }, message:lower()) and npcHandler:getTopic(playerId) >= 6 and npcHandler:getTopic(playerId) <= 7 then
		checkX(npc, player, 130, message)
	elseif table.contains({ "many", "noxious spawn", "stonecracker", "gorgo", "kerberos", "ethershreck", "zanakeph", "paiz the pauperizer", "bretzecutioner", "leviathan" }, message:lower()) and npcHandler:getTopic(playerId) == 7 then
		for w = 1, #tasks.GrizzlyAdams do
			if tasks.GrizzlyAdams[w].bossName then
				if tasks.GrizzlyAdams[w].bossName:lower() == message:lower() then
					for y = 1, #tasks.GrizzlyAdams[w].rewards do
						if table.contains({ REWARD_STORAGE, "storage", "stor" }, tasks.GrizzlyAdams[w].rewards[y].type:lower()) then
							if player:getStorageValue(tasks.GrizzlyAdams[w].rewards[y].value[1]) == 3 or player:getStorageValue(tasks.GrizzlyAdams[w].rewards[y].value[1]) < 0 then
								NPC_LIB.i18n.npcSay(npcHandler, npc, creature, messageBossStart[tasks.GrizzlyAdams[w].bossId])
								player:setStorageValue(tasks.GrizzlyAdams[w].rewards[y].value[1], 1)
								player:setStorageValue(tasks.GrizzlyAdams[w].rewards[y].value[2], 0)
								player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossPoints, player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossPoints) - 1)
								return true
							else
								NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_7", { tasks.GrizzlyAdams[w].bossName })
							end
						end
					end
				end
			end
		end
		elseif message:lower() == "started" then
			local started = player:getStartedTasks()
			if started and #started > 0 then
				local startedText = ""
				local sep = ", "
			table.sort(started, function(a, b)
				return (a < b)
			end)
			local t = 0
			local id
			for i = 1, #started do
				id = started[i]
				t = t + 1
				if t == #started - 1 then
					sep = " and "
				elseif t == #started then
					sep = "."
				end
					startedText = startedText .. "{" .. (tasks.GrizzlyAdams[id].name or tasks.GrizzlyAdams[id].raceName) .. "}" .. sep
				end

				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_8", { (#started > 1 and "s" or ""), (#started > 1 and "are" or "is"), startedText })
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_17")
		end
		elseif message:lower() == "cancel" or message:lower() == "yes" and npcHandler:getTopic(playerId) == 10 then
			local started = player:getStartedTasks()
			local cancelText = ""
			local sep = ", "
		table.sort(started, function(a, b)
			return (a < b)
		end)
		local t = 0
		local id
		for i = 1, #started do
			id = started[i]
			t = t + 1
			if t == #started - 1 then
				sep = " or "
			elseif t == #started then
				sep = "?"
			end
				cancelText = cancelText .. "{" .. (tasks.GrizzlyAdams[id].name or tasks.GrizzlyAdams[id].raceName) .. "}" .. sep
			end
			if started and #started > 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_9", { (#started > 1 and "" or ""), cancelText })
			npcHandler:setTopic(playerId, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_18")
		end
	elseif (getTaskByName(message)) and (npcHandler:getTopic(playerId) == 2) and (table.contains(getPlayerStartedTasks(creature), getTaskByName(message))) then
		local task = getTaskByName(message)
		if player:getStorageValue(KillCounter + task) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_10", { player:getStorageValue(KillCounter + task), tasks.GrizzlyAdams[task].killsRequired, tasks.GrizzlyAdams[task].raceName })
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_19")
		end
		npcHandler:setTopic(playerId, 3)
		cancel[playerId] = task
	elseif (getTaskByName(message)) and (npcHandler:getTopic(playerId) == 1) and (table.contains(getPlayerStartedTasks(creature), getTaskByName(message))) then
		local task = getTaskByName(message)
		if player:getStorageValue(KillCounter + task) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_11", { player:getStorageValue(KillCounter + task), tasks.GrizzlyAdams[task].killsRequired, tasks.GrizzlyAdams[task].raceName })
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_12", { tasks.GrizzlyAdams[task].killsRequired, tasks.GrizzlyAdams[task].raceName })
		end
		npcHandler:setTopic(playerId, 0)
	elseif message:lower() == "yes" and npcHandler:getTopic(playerId) == 3 then
		player:setStorageValue(QUESTSTORAGE_BASE + cancel[playerId], -1)
		player:setStorageValue(KILLSSTORAGE_BASE + cancel[playerId], player:getStorageValue(KILLSSTORAGE_BASE + cancel[playerId]) - 1)
		player:setStorageValue(KillCounter + cancel[playerId], 0)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_13", { (tasks.GrizzlyAdams[cancel[playerId]].name or tasks.GrizzlyAdams[cancel[playerId]].raceName) })
		npcHandler:setTopic(playerId, 0)
	elseif table.contains({ "points", "rank" }, message:lower()) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_14", { player:getPawAndFurPoints(), (player:getPawAndFurRank() == 6 and "are an Elite Hunter" or player:getPawAndFurRank() == 5 and "are a Trophy Hunter" or player:getPawAndFurRank() == 4 and "are a Big Game Hunter" or player:getPawAndFurRank() == 3 and "are a Ranger" or player:getPawAndFurRank() == 2 and "are a Huntsman" or player:getPawAndFurRank() == 1 and "are a Member" or "haven't been ranked yet") })
		npcHandler:setTopic(playerId, 0)
	elseif message:lower() == "no" and npcHandler:getTopic(playerId) == 10 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_21")
		npcHandler:setTopic(playerId, 0)
	elseif table.contains({ "special", "special task" }, message:lower()) then
		if player:getPawAndFurPoints() >= 70 and player:getLevel() >= 80 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionTiquandasRevenge) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.multi_2")
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.TiquandasCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionTiquandasRevenge, 1)
			elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionTiquandasRevenge) <= 2 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.TiquandasCount) == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_22")
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionTiquandasRevenge, 1) -- for death scenario
			elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionTiquandasRevenge) == 2 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.TiquandasCount) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_23")
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionTiquandasRevenge, 3)
			elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionDemodras) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_24")
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.DemodrasCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionDemodras, 1)
			elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionDemodras) <= 2 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.DemodrasCount) == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_25")
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionDemodras, 1) -- for death scenario
			elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionDemodras) == 2 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.DemodrasCount) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_26")
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionDemodras, 3)
			elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionDemodras) == 3 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MissionTiquandasRevenge) == 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.grizzly_adams.say_27")
			end
			npcHandler:setTopic(playerId, 0)
		end
	end
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.grizzly_adams.farewell_msg_1")
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
