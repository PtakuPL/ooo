local internalNpcName = "Frosty"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 1159,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
local talkState = {}
local rtnt = {}

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

local sleightInfo = {
	["bright percht sleigh"] = { cost = 0, items = { { 30192, 1 } }, mount = 133, storageID = Storage.Percht1 },
	["cold percht sleigh"] = { cost = 0, items = { { 30192, 1 } }, mount = 132, storageID = Storage.Percht2 },
	["dark percht sleigh"] = { cost = 0, items = { { 30192, 1 } }, mount = 134, storageID = Storage.Percht3 },
}

local monsterName = { "bright percht sleigh", "cold percht sleigh", "dark percht sleigh" }

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if sleightInfo[message] ~= nil then
		if getPlayerStorageValue(creature, sleightInfo[message].storageID) ~= -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frosty.say_1")
			npcHandler:resetNpc(player)
		else
			local itemsTable = sleightInfo[message].items
			local items_list = ""
			if table.maxn(itemsTable) > 0 then
				for i = 1, table.maxn(itemsTable) do
					local item = itemsTable[i]
					items_list = items_list .. item[2] .. " " .. ItemType(item[1]):getName()
					if i ~= table.maxn(itemsTable) then
						items_list = items_list .. ", "
					end
				end
			end
			local text = ""
			if sleightInfo[message].cost > 0 then
				text = sleightInfo[message].cost .. " gp"
			elseif table.maxn(sleightInfo[message].items) then
				text = items_list
			elseif (sleightInfo[message].cost > 0) and table.maxn(sleightInfo[message].items) then
				text = items_list .. " and " .. sleightInfo[message].cost .. " gp"
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frosty.say_1", { message, text })
			rtnt[playerId] = message
			talkState[playerId] = sleightInfo[message].storageID
			return true
		end
	elseif message:lower() == "percht" then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frosty.say_3")
	elseif MsgContains(message, "yes") then
		if talkState[playerId] >= Storage.Percht1 and talkState[playerId] <= Storage.Percht3 then
			local items_number = 0
			if table.maxn(sleightInfo[rtnt[playerId]].items) > 0 then
				for i = 1, table.maxn(sleightInfo[rtnt[playerId]].items) do
					local item = sleightInfo[rtnt[playerId]].items[i]
					if getPlayerItemCount(creature, item[1]) >= item[2] then
						items_number = items_number + 1
					end
				end
			end
			if player:removeMoneyBank(sleightInfo[rtnt[playerId]].cost) and (items_number == table.maxn(sleightInfo[rtnt[playerId]].items)) then
				if table.maxn(sleightInfo[rtnt[playerId]].items) > 0 then
					for i = 1, table.maxn(sleightInfo[rtnt[playerId]].items) do
						local item = sleightInfo[rtnt[playerId]].items[i]
						doPlayerRemoveItem(creature, item[1], item[2])
					end
				end
				doPlayerAddMount(creature, sleightInfo[rtnt[playerId]].mount)
				setPlayerStorageValue(creature, sleightInfo[rtnt[playerId]].storageID, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frosty.say_4")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frosty.say_5")
			end
			rtnt[playerId] = nil
			talkState[playerId] = 0
			npcHandler:resetNpc(player)
			return true
		end
	elseif MsgContains(message, "mount") or MsgContains(message, "mounts") or MsgContains(message, "sleigh") or MsgContains(message, "sleighs") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frosty.say_2", { table.concat(monsterName, "}, {") })
		rtnt[playerId] = nil
		talkState[playerId] = 0
		npcHandler:resetNpc(player)
		return true
	elseif MsgContains(message, "help") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frosty.say_6")
		rtnt[playerId] = nil
		talkState[playerId] = 0
		npcHandler:resetNpc(player)
		return true
	else
		if talkState[playerId] ~= nil then
			if talkState[playerId] > 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frosty.say_7")
				rtnt[playerId] = nil
				talkState[playerId] = 0
				npcHandler:resetNpc(player)
				return true
			end
		end
	end
	return true
end

keywordHandler:addKeyword({ "carrot" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frosty.stdmod_1" })
keywordHandler:addKeyword({ "percht skull" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frosty.stdmod_2" })
keywordHandler:addKeyword({ "bunnies" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frosty.stdmod_3" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.frosty.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
