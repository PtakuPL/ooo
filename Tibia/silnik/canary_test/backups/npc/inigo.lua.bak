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

local hints = {
	[1] = "If you don't know the meaning of an icon on the minimap, move the mouse cursor on it and wait a moment.",
	[2] = "If you seek more information, look at or click on objects near you, like wall signs, \z
		blackboards or books in book cases - many of them have useful information on {Tibia} or maybe \z
		even a quest you are doing. By the way, to receive more of my hints, just say {hints} again.",
	[3] = "If you want to attack a monster, simply click on it in your battle list. \z
		A red frame around a monster shows you are attacking it.",
	[4] = "If you already know where you want to go, click on the automap and your character \z
		will walk there automatically if the location is reachable and not too far away.",
	[5] = "Always have a {rope} with you! If you fall into a hole and are surrounded by {monsters}, \z
		quickly use the rope with the ropespot to get back up and out.",
	[6] = "'Capacity' restricts the amount of things you can carry with you. It raises with each level.",
	[7] = "Always have a look on your health bar. \z
		If you see that you do not regenerate health points anymore, eat something. ",
	[8] = "Always eat as much {food} as possible. \z
		This way, you'll regenerate health points for a longer period of time.",
	[9] = "After you have killed a monster, you have 10 seconds in which the corpse \z
		is not movable and no one else but you can loot it.",
	[10] = "Be careful when you approach three or more {monsters} because you only can block the attacks of two! \z
		In such a situation, even a few salamanders can do severe damage or even kill you.",
	[11] = "There are many ways to gather {food}. Many creatures drop food but you can also pick blueberries or \z
		bake your own bread. If you have a {fishing rod} and worms in your inventory, you can also try to catch a fish.",
	[12] = "Baking bread is rather complex. First of all you need a scythe to harvest wheat. \z
		Then you use the wheat with a millstone to get flour. This can be be used on water to get dough, \z
		which can be used on an oven to bake bread. Use milk instead of water to get cake dough.",
	[13] = "{Dying} hurts! Better run away than risk your life. \z
		You are going to lose experience and skill points when you die. \z
		And anyone can loot your corpse if you are not blessed.",
	[14] = "When you switch to '{Offensive} {Fighting}', you deal out more damage but you also get hurt more easily.",
	[15] = "When you are on low health and need to run away from a monster, \z
		switch to '{Defensive} {Fighting}' and the monster will hit you less severely.",
	[16] = "Many creatures try to run away from you. Select 'Chase Opponent' to follow them.",
	[17] = "The deeper you enter a dungeon, the more dangerous it will be. \z
		Approach every dungeon with utmost care or an unexpected creature might kill you. \z
		This will result in losing experience and skill points.",
	[18] = "Due to the perspective, some objects in {Tibia} are not located at the spot they seem to appear \z
		(ladders, windows, lamps). Try clicking on the floor tile the object would lie on.",
	[19] = "Almost as important as a {rope} is a {shovel}. Many things can be dug out of the sand, and a pile \z
		of loose stones might hide a secret entrance. But if you go down an unknown hole, make sure you have a \z
		rope with you to get you out quickly if necessary!",
	[20] = "Stairs, ladders and dungeon entrances are marked as yellow dots on the automap.",
	[21] = "You can get {food} by killing animals or {monsters}. You can also pick blueberries or bake your own bread. \z
		If you are too lazy or own too much money, you can also buy food.",
	[22] = "Quest containers can be recognised easily. They don't open up regularly but display a message \z
		'You have found ....'. They can only be opened once.",
	[23] = "Better run away than risk to die. You'll lose experience and skill points each time you die.",
	[24] = "You can form a party by right-clicking on a player and selecting 'Invite to Party'. \z
		The party leader can also enable 'Shared Experience' by right-clicking on him- or herself.",
	[25] = "You can assign {spells}, the use of items, or random text to 'hotkeys'. You find them under 'Options'.",
	[26] = "You can also follow other {players}. Just right-click on the player and select 'Follow'.",
	[27] = "You can found a party with your friends by right-clicking on a player and selecting 'Invite to Party'. \z
		If you are invited to a party, right-click on yourself and select 'Join Party'.",
	[28] = "Only found parties with people you trust! You can attack people in your party without getting a {skull}. \z
		This is helpful for training your {skills}, \z
		but can be abused to kill people without having to fear negative consequences.",
	[29] = "The leader of a party has the option to distribute gathered experience among all {players} in the party. \z
		If you are the leader, right-click on yourself and select 'Enable Shared Experience'.",
	[30] = "If you see someone with a {skull} symbol next to their name, it means he or she has attacked \z
		or even killed another player. Be careful around such people, as their next target might be you.",
	[31] = "A brown frame around a player means he or she is in a {PvP} situation.",
	[32] = "To open or close {skills}, battle or VIP list, click on the corresponding button. \z
		The buttons are displayed to the left or right of your game window.",
	[33] = "If you want to trade an item with another player, right-click on the item and select \z
		'Trade with ...', then click on the player with whom you want to trade.",
	[34] = "Send private messages to other {players} by right-clicking on the player or the player's name and select \z
		'Message to ....'. You can also open a 'private message channel' and type in the name of the player.",
	[35] = "There is nothing more I can tell you. If you are still in need of some {hints}, I can repeat them for you.",
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
		for i = 0, 35, 1 do
			if i <= 35 then
				npcHandler:say({ hints[i] })
			elseif i == 35 then
				i = 0
			end
		end
	elseif MsgContains(message, "rookgaard") and player:getLevel() <= 9 then
		if Player.getAccountStorage(player, Storage.Dawnport.Mainland, true) == 1 then
			npcHandler:say(
				"Hmmm. Long time I visited that isle. Not very exciting place. \z
			Why do you ask? Do you wish to go there?",
				npc,
				creature
			)
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
		npcHandler:say(
			"Then so be it. I'm sorry to see you go, but if this is what you want, step this way... right. \z
		Now, cover your eyes... GO!",
			npc,
			creature
		)
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
