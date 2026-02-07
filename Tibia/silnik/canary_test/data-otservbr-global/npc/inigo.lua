local internalNpcName = "Inigo"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 472,
	lookHead = 59,
	lookBody = 114,
	lookLegs = 0,
	lookFeet = 94,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

local hintKeys = {
	[1] = "npc.inigo.hint_1",
	[2] = "npc.inigo.hint_2",
	[3] = "npc.inigo.hint_3",
	[4] = "npc.inigo.hint_4",
	[5] = "npc.inigo.hint_5",
	[6] = "npc.inigo.hint_6",
	[7] = "npc.inigo.hint_7",
	[8] = "npc.inigo.hint_8",
	[9] = "npc.inigo.hint_9",
	[10] = "npc.inigo.hint_10",
	[11] = "npc.inigo.hint_11",
	[12] = "npc.inigo.hint_12",
	[13] = "npc.inigo.hint_13",
	[14] = "npc.inigo.hint_14",
	[15] = "npc.inigo.hint_15",
	[16] = "npc.inigo.hint_16",
	[17] = "npc.inigo.hint_17",
	[18] = "npc.inigo.hint_18",
	[19] = "npc.inigo.hint_19",
	[20] = "npc.inigo.hint_20",
	[21] = "npc.inigo.hint_21",
	[22] = "npc.inigo.hint_22",
	[23] = "npc.inigo.hint_23",
	[24] = "npc.inigo.hint_24",
	[25] = "npc.inigo.hint_25",
	[26] = "npc.inigo.hint_26",
	[27] = "npc.inigo.hint_27",
	[28] = "npc.inigo.hint_28",
	[29] = "npc.inigo.hint_29",
	[30] = "npc.inigo.hint_30",
	[31] = "npc.inigo.hint_31",
	[32] = "npc.inigo.hint_32",
	[33] = "npc.inigo.hint_33",
	[34] = "npc.inigo.hint_34",
	[35] = "npc.inigo.hint_35",
}
npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.inigo.voice_1" },
	{ i18nKey = "npc.inigo.voice_2" },
	{ i18nKey = "npc.inigo.voice_3" },
	{ i18nKey = "npc.inigo.voice_4" },
	{ i18nKey = "npc.inigo.voice_5" },
	{ i18nKey = "npc.inigo.voice_6" },
	{ i18nKey = "npc.inigo.voice_7" },
	{ i18nKey = "npc.inigo.voice_8" },
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
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.inigo.greet_msg_1")

keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_1",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_2",
})
keywordHandler:addKeyword({ "tibia" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_3",
})
keywordHandler:addKeyword({ "questing" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_4",
})
keywordHandler:addKeyword({ "people" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_5",
})
keywordHandler:addKeyword({ "monsters" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_6",
})
keywordHandler:addKeyword({ "garamond" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_7",
})
keywordHandler:addKeyword({ "tybald" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_8",
})
keywordHandler:addKeyword({ "richard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_9",
})
keywordHandler:addKeyword({ "knight" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_10",
})
keywordHandler:addKeyword({ "druid" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_11",
})
keywordHandler:addKeyword({ "paladin" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_12",
})
keywordHandler:addKeyword({ "sorcerer" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_13",
})
keywordHandler:addKeyword({ "tools" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_14",
})
keywordHandler:addKeyword({ "food" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_15",
})
keywordHandler:addKeyword({ "fishing rod" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.inigo.stdmod_16",
})

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "portal") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_1", "npc.inigo.say_2", "npc.inigo.say_3"}, 10)
	elseif MsgContains(message, "menesto") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_4", "npc.inigo.say_5", "npc.inigo.say_6"}, 10)
	elseif MsgContains(message, "play") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_7", "npc.inigo.say_8", "npc.inigo.say_9", "npc.inigo.say_10", "npc.inigo.say_11"}, 10)
	elseif MsgContains(message, "combat") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_12", "npc.inigo.say_13", "npc.inigo.say_14", "npc.inigo.say_15"}, 10)
	elseif MsgContains(message, "pvp") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_16", "npc.inigo.say_17", "npc.inigo.say_18", "npc.inigo.say_19"}, 10)
	elseif MsgContains(message, "players") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_20", "npc.inigo.say_21"}, 10)
	elseif MsgContains(message, "npc") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_22", "npc.inigo.say_23", "npc.inigo.say_24", "npc.inigo.say_25", "npc.inigo.say_26"}, 10)
	elseif MsgContains(message, "spells") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_27", "npc.inigo.say_28", "npc.inigo.say_29"}, 10)
	elseif MsgContains(message, "shovel") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_30", "npc.inigo.say_31"}, 10)
	elseif MsgContains(message, "dawnport") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_32", "npc.inigo.say_33", "npc.inigo.say_34", "npc.inigo.say_35", "npc.inigo.say_36"}, 10)
	elseif MsgContains(message, "mainland") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_37", "npc.inigo.say_38", "npc.inigo.say_39"}, 10)
	elseif MsgContains(message, "figthing") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_40", "npc.inigo.say_41", "npc.inigo.say_42", "npc.inigo.say_43", "npc.inigo.say_44", "npc.inigo.say_45"}, 10)
	elseif MsgContains(message, "vocations") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_46", "npc.inigo.say_47", "npc.inigo.say_48", "npc.inigo.say_49"}, 10)
	elseif MsgContains(message, "help") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_50", "npc.inigo.say_51", "npc.inigo.say_52", "npc.inigo.say_53"}, 10)
	elseif MsgContains(message, "offensive") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_54", "npc.inigo.say_55"}, 10)
	elseif MsgContains(message, "balanced") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_56", "npc.inigo.say_57"}, 10)
	elseif MsgContains(message, "defensive") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_58", "npc.inigo.say_59"}, 10)
	elseif MsgContains(message, "skull") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_60", "npc.inigo.say_61"}, 10)
	elseif MsgContains(message, "hamish") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_62", "npc.inigo.say_63"}, 10)
	elseif MsgContains(message, "coltrayne") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_64", "npc.inigo.say_65"}, 10)
	elseif MsgContains(message, "morris") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_66", "npc.inigo.say_67", "npc.inigo.say_68"}, 10)
	elseif MsgContains(message, "skills") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_69", "npc.inigo.say_70"}, 10)
	elseif MsgContains(message, "rope") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_71", "npc.inigo.say_72"}, 10)
	elseif MsgContains(message, "oressa") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_73", "npc.inigo.say_74"}, 10)
	elseif MsgContains(message, "temple") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_75", "npc.inigo.say_76"}, 10)
	elseif MsgContains(message, "dying") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_77", "npc.inigo.say_78", "npc.inigo.say_79"}, 10)
	elseif MsgContains(message, "druid spells") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_80", "npc.inigo.say_81", "npc.inigo.say_82"}, 10)
	elseif MsgContains(message, "train") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_83", "npc.inigo.say_84", "npc.inigo.say_85", "npc.inigo.say_86", "npc.inigo.say_87", "npc.inigo.say_88"}, 10)
	elseif MsgContains(message, "bless") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_89", "npc.inigo.say_90", "npc.inigo.say_91", "npc.inigo.say_92"}, 10)
	elseif MsgContains(message, "hints") then
		for i = 1, #hintKeys do
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, hintKeys[i])
		end
	elseif MsgContains(message, "rookgaard") and player:getLevel() <= 9 then
		if Player.getAccountStorage(player, Storage.Dawnport.Mainland, true) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.inigo.say_95")
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.inigo.say_1")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.inigo.say_93", "npc.inigo.say_94"}, 10)
		npcHandler:setTopic(playerId, 2)
	elseif npcHandler:getTopic(playerId) == 2 and MsgContains(message, "yes") or MsgContains(message, "sure") or MsgContains(message, "leave") then
		local town = Town(TOWNS_LIST.ROOKGAARD)
		player:setTown(town)
		-- Change to none vocation, convert magic level and skills and set proper stats
		player:changeVocation(VOCATION.ID.NONE)
		player:teleportTo(town:getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

		local slots = {
			1,
			2,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
		}
		-- Cycle through the slots table and store the slot id in slot
		for index, value in pairs(slots) do
			-- Get the player's slot item and store it in item
			local item = player:getSlotItem(value)
			-- If the item exists meaning its not nil then continue
			if item and not table.contains({ 2853, 2854, 2920, 3355, 3562, 3559 }, item:getId()) then
				item:remove()
			end
		end
		local container = player:getSlotItem(CONST_SLOT_BACKPACK)
		local toBeDeleted = {}
		local allowedIds = {
			2853,
			2920,
			3003,
			3031,
		}
		if container and container:getSize() > 0 then
			for i = 0, container:getSize() do
				if player:getMoney() > 21465 then
					player:removeMoney(math.abs(21465 - player:getMoney()))
				end
				local item = container:getItem(i)
				if item then
					---@diagnostic disable-next-line: undefined-field
					if not table.contains(allowedIds, item:getId()) then
						toBeDeleted[#toBeDeleted + 1] = item.uid
					end
				end
			end
			if #toBeDeleted > 0 then
				for i, v in pairs(toBeDeleted) do
					local item = Item(v)
					if item then
						item:remove()
					end
				end
			end
		end
		player:addItem(3270, 1)
		player:addItem(2853, 1)
		player:addItem(2920, 1)
		player:addItem(3585, 1)
		player:addItem(3561, 1)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.inigo.say_96")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
