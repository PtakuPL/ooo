local internalNpcName = "Charles"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 134,
	lookHead = 57,
	lookBody = 67,
	lookLegs = 95,
	lookFeet = 60,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.charles.voice_1" },
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

local shortcuts = {
	["thais"] = { price = 100, position = Position(32310, 32210, 6) },
	["edron"] = { price = 90, position = Position(33173, 31764, 6) },
	["liberty bay"] = { price = 20, position = Position(32285, 32891, 6) },
	["yalahar"] = { price = 200, position = Position(32816, 31272, 6) },
}

local isles = {
	[1] = { isMission = true, position = Position(32031, 32463, 7) },
	[2] = { isMission = false, position = Position(33454, 32160, 7) },
	[3] = { isMission = false, position = Position(32112, 31745, 7) },
	[4] = { isMission = false, position = Position(32457, 32937, 7) },
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "shortcut") and player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.Questline) >= 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.charles.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.charles.multi_2")
		npcHandler:setTopic(playerId, 5)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.charles.say_1")
		npcHandler:setTopic(playerId, 6)
	elseif npcHandler:getTopic(playerId) == 6 then
		local travelTo = shortcuts[message:lower()]
		if travelTo then
			if player:removeMoney(travelTo.price) then
				local r = math.random(1, #isles)
				local chance = math.random(1, 10)
				if chance <= 3 then
					player:teleportTo(travelTo.position)
				else
					player:teleportTo(isles[r].position)
					if isles[r].isMission and player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.Questline) < 2 then
						player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.Questline, 2)
					end
				end
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.charles.say_2")
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				return true
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.charles.say_3")
			end
		end
	else
		local function addTravelKeyword(keyword, cost, destination, condition)
			if condition then
				keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.charles.stdmod_1" }, condition)
			end
			local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.charles.stdmod_2" .. keyword:titleCase() .. " for |TRAVELCOST|?", cost = cost, discount = "postman" })
			travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, discount = "postman", destination = destination })
			travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.charles.stdmod_3", reset = true })
		end
		addTravelKeyword("edron", 150, Position(33173, 31764, 6))
		addTravelKeyword("venore", 160, Position(32954, 32022, 6))
		addTravelKeyword("yalahar", 260, Position(32816, 31272, 6), function(player)
			return player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.PortHope) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5
		end)
		addTravelKeyword("ankrahmun", 110, Position(33092, 32883, 6))
		addTravelKeyword("darashia", 180, Position(33289, 32480, 6))
		addTravelKeyword("thais", 160, Position(32310, 32210, 6))
		addTravelKeyword("liberty bay", 50, Position(32285, 32892, 6))
		addTravelKeyword("carlin", 120, Position(32387, 31820, 6))
	end
end

keywordHandler:addKeyword({ "kick" }, StdModule.kick, { npcHandler = npcHandler, destination = { Position(32535, 32792, 6), Position(32536, 32778, 6) } })
keywordHandler:addKeyword({ "sail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.charles.stdmod_4" })
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.charles.stdmod_5" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.charles.stdmod_6" })
keywordHandler:addKeyword({ "captain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.charles.stdmod_7" })
keywordHandler:addKeyword({ "port hope" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.charles.stdmod_8" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.charles.stdmod_9" })
keywordHandler:addKeyword({ "svargrond" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.charles.stdmod_10" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.charles.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.charles.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.charles.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
