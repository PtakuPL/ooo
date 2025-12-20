local internalNpcName = "Walter Jaeger"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 957,
	lookHead = 78,
	lookBody = 5,
	lookLegs = 5,
	lookFeet = 115,
	lookAddons = 0,
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

--
--	To-Do: Task hunting points history
--
local config = {
	enable = true,
	topics = {
		outfit = 1000,
		mount = 2000,
		trophy = 3000,
		furniture = 4000,
	},
	outifts = {
		[1] = {
			name = "Falconer",
			looktype = {
				male = 1282,
				female = 1283,
			},
			points = {
				base = 100000,
				addons = {
					first = 35000,
					second = 35000,
				},
			},
		},
	},
	mounts = {
		[1] = {
			name = "Antelope",
			id = 163,
			points = 145000,
		},
	},
	trophies = {
		[1] = {
			name = "gozzler trophy",
			id = 32751,
			points = 3000,
		},
		[2] = {
			name = "bronze hunter trophy",
			id = 32754,
			points = 3000,
		},
		[3] = {
			name = "sea serpent trophy",
			id = 32752,
			points = 15000,
		},
		[4] = {
			name = "silver hunter trophy",
			id = 32755,
			points = 15000,
		},
		[5] = {
			name = "many faces trophy",
			id = 36749,
			points = 50000,
		},
		[6] = {
			name = "hellflayer trophy",
			id = 32753,
			points = 80000,
		},
		[7] = {
			name = "gold hunter trophy",
			id = 32756,
			points = 80000,
		},
		[8] = {
			name = "brachiodemon trophy",
			id = 36748,
			points = 80000,
		},
	},
	furniture = {
		--[1] = {
		--	name = "bone bed",
		--	id = 32799,
		--	points = 35000
		--},
		[1] = {
			name = "falcon pet",
			id = 36750,
			points = 135000,
		},
	},
}

local function getOfferIndex(name, offer, topic)
	for index, offerTable in ipairs(offer) do
		if name:lower() == (offerTable.name):lower() then
			return index + topic
		end
	end

	return 0
end

local function getOffersString(offer, showPrice)
	local string = ""

	if #offer == 0 then
		return string
	end

	for index, offerTable in ipairs(offer) do
		string = string .. "{" .. offerTable.name .. "}"

		if showPrice and type(offerTable.points) == "number" then
			string = string .. " (" .. tostring(offerTable.points) .. " HTP)"
		end

		if index ~= #offer then
			string = string .. ", "
		elseif index == (#offer - 1) then
			string = string .. " and "
		end
	end

	return string
end

local function getOfferByName(name, offer, topic)
	if offer == nil or #offer == 0 then
		return nil
	end

	for index, offerTable in ipairs(offer) do
		if name:lower() == (offerTable.name):lower() then
			if topic == config.topics.outfit then
				return {
					offerId = index,
					name = offerTable.name,
					offerTopic = topic,
					base = offerTable.points.base,
					firstAddon = offerTable.points.addons.first,
					secondAddon = offerTable.points.addons.second,
					male = offerTable.looktype.male,
					female = offerTable.looktype.female,
				}
			elseif topic == config.topics.mount then
				return {
					offerId = index,
					name = offerTable.name,
					offerTopic = topic,
					value = offerTable.points,
					mountId = offerTable.id,
				}
			elseif topic == config.topics.trophy or topic == config.topics.furniture then
				return {
					offerId = index,
					name = offerTable.name,
					offerTopic = topic,
					value = offerTable.points,
					itemId = offerTable.id,
				}
			end
		end
	end

	return nil
end

local function getOfferByIndex(offerIndex, offer, topic)
	if offer == nil or #offer == 0 then
		return nil
	end

	for index, offerTable in ipairs(offer) do
		if index == offerIndex then
			if topic == config.topics.outfit then
				return {
					offerId = index,
					name = offerTable.name,
					offerTopic = topic,
					base = offerTable.points.base,
					firstAddon = offerTable.points.addons.first,
					secondAddon = offerTable.points.addons.second,
					male = offerTable.looktype.male,
					female = offerTable.looktype.female,
				}
			elseif topic == config.topics.mount then
				return {
					offerId = index,
					name = offerTable.name,
					offerTopic = topic,
					value = offerTable.points,
					mountId = offerTable.id,
				}
			elseif topic == config.topics.trophy or topic == config.topics.furniture then
				return {
					offerId = index,
					name = offerTable.name,
					offerTopic = topic,
					value = offerTable.points,
					itemId = offerTable.id,
				}
			end
		end
	end

	return nil
end

local function getOfferString(name, offer, topic)
	local string = ""
	if offer == nil or #offer == 0 then
		return string
	end

	local offerTable = getOfferByName(name, offer, topic)
	if offerTable == nil then
		return string
	end

	if topic == config.topics.outfit then
		string = "The {base} " .. offerTable.name .. " outfit costs " .. tostring(offerTable.base) .. " HTP, the {first} addon " .. tostring(offerTable.firstAddon) .. " HTP and the {second} addon " .. tostring(offerTable.secondAddon) .. " HTP."
	elseif topic == config.topics.mount then
		string = "The {" .. offerTable.name .. "} mount costs " .. tostring(offerTable.value) .. " HTP."
	end

	return string
end

local function processItemInboxPurchase(player, name, id)
	if not player then
		return false
	end

	local inbox = player:getStoreInbox()
	local inboxItems = inbox:getItems()
	if inbox and #inboxItems < inbox:getMaxCapacity() then
		local decoKit = inbox:addItem(ITEM_DECORATION_KIT, 1)
		if decoKit then
			decoKit:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "You bought this item with the Walter Jaeger.\nUnwrap it in your own house to create a <" .. name .. ">.")
			decoKit:setCustomAttribute("unWrapId", id)
			return true
		end
	else
		player:sendTextMessage(MESSAGE_LOOK, "Please make sure you have free slots in your store inbox.")
	end

	return false
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end
	if MsgContains(message, "rewards") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.walter_jaeger.say_1", "npc.walter_jaeger.say_2"}, 100)
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "tasks") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_1")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "have") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_1", { player:getTaskHuntingPoints() })
		npcHandler:setTopic(playerId, 0)

		-- Add task hunting points history here.
		--elseif MsgContains(message, "spent") then
		--	npcHandler:say("You have already spent " .. nil .. " HTP.", npc, creature)
		--	npcHandler:setTopic(playerId, 0)

		-- Rewards topic
	elseif npcHandler:getTopic(playerId) == 1 then
		if not config.enable then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_3")
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "outfit") then
			if config == nil or config.outifts == nil or #config.outifts == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_4")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_2", { getOffersString(config.outifts, false), (#config.outifts >= 1 and "s." or ".") })
				npcHandler:setTopic(playerId, config.topics.outfit)
			end
		elseif MsgContains(message, "mount") then
			if config == nil or config.mounts == nil or #config.mounts == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_5")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_3", { getOffersString(config.mounts, false), (#config.mounts >= 1 and "s." or ".") })
				npcHandler:setTopic(playerId, config.topics.mount)
			end
		elseif MsgContains(message, "trophies") then
			if config == nil or config.trophies == nil or #config.trophies == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_6")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_4", { getOffersString(config.trophies, true) })
				npcHandler:setTopic(playerId, config.topics.trophy)
			end
		elseif MsgContains(message, "furniture") then
			if config == nil or config.furniture == nil or #config.furniture == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_7")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_5", { getOffersString(config.furniture, true) })
				npcHandler:setTopic(playerId, config.topics.furniture)
			end
		end

		-- Offer topics
	elseif npcHandler:getTopic(playerId) > 1 then
		if npcHandler:getTopic(playerId) == config.topics.outfit then
			if config ~= nil and config.outifts ~= nil and #config.outifts > 0 then
				npcHandler:say(getOfferString(message, config.outifts, npcHandler:getTopic(playerId)), npc, creature)
				npcHandler:setTopic(playerId, getOfferIndex(message, config.outifts, npcHandler:getTopic(playerId)))
			end
		elseif npcHandler:getTopic(playerId) == config.topics.mount then
			if config ~= nil and config.mounts ~= nil and #config.mounts > 0 then
				npcHandler:say(getOfferString(message, config.mounts, npcHandler:getTopic(playerId)), npc, creature)
				npcHandler:setTopic(playerId, getOfferIndex(message, config.mounts, npcHandler:getTopic(playerId)))
			end
		elseif npcHandler:getTopic(playerId) == config.topics.trophy then
			if config ~= nil and config.trophies ~= nil and #config.trophies > 0 then
				local offerTable = getOfferByName(message, config.trophies, npcHandler:getTopic(playerId))
				if offerTable ~= nil then
					if player:getTaskHuntingPoints() >= offerTable.value then
						if processItemInboxPurchase(player, offerTable.name, offerTable.itemId) and player:removeTaskHuntingPoints(offerTable.value) then
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_8")
						else
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_9")
						end
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_10")
					end
				else
					return true
				end
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == config.topics.furniture then
			if config ~= nil and config.furniture ~= nil and #config.furniture > 0 then
				local offerTable = getOfferByName(message, config.furniture, npcHandler:getTopic(playerId))
				if offerTable ~= nil then
					if player:getTaskHuntingPoints() >= offerTable.value then
						if processItemInboxPurchase(player, offerTable.name, offerTable.itemId) and player:removeTaskHuntingPoints(offerTable.value) then
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_11")
						else
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_12")
						end
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_13")
					end
				else
					return true
				end
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) > config.topics.outfit and npcHandler:getTopic(playerId) < config.topics.mount then
			if config ~= nil and config.outifts ~= nil and #config.outifts > 0 then
				local offerTable = getOfferByIndex(npcHandler:getTopic(playerId) - config.topics.outfit, config.outifts, config.topics.outfit)
				if offerTable ~= nil then
					if MsgContains(message, "base") then
						local points = offerTable.base
						if player:hasOutfit(offerTable.male) or player:hasOutfit(offerTable.female) then
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_14")
						elseif player:removeTaskHuntingPoints(points) then
							-- Add task hunting points history here.
							player:addOutfit(offerTable.male)
							player:addOutfit(offerTable.female)
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_15")
						end
					elseif MsgContains(message, "first") then
						local points = offerTable.firstAddon
						if not (player:hasOutfit(offerTable.male)) or not (player:hasOutfit(offerTable.female)) then
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_16")
						elseif player:hasOutfit(offerTable.male, 1) or player:hasOutfit(offerTable.female, 1) then
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_17")
						elseif player:removeTaskHuntingPoints(points) then
							-- Add task hunting points history here.
							player:addOutfitAddon(offerTable.male, 1)
							player:addOutfitAddon(offerTable.female, 1)
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_18")
						else
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_19")
						end
					elseif MsgContains(message, "second") then
						local points = offerTable.secondAddon
						if not (player:hasOutfit(offerTable.male)) or not (player:hasOutfit(offerTable.female)) then
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_20")
						elseif player:hasOutfit(offerTable.male, 2) or player:hasOutfit(offerTable.female, 2) then
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_21")
						elseif player:removeTaskHuntingPoints(points) then
							-- Add task hunting points history here.
							player:addOutfitAddon(offerTable.male, 2)
							player:addOutfitAddon(offerTable.female, 2)
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_22")
						else
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_23")
						end
					else
						return true
					end
				else
					return true
				end
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) > config.topics.mount and npcHandler:getTopic(playerId) < config.topics.trophy then
			if config ~= nil and config.mounts ~= nil and #config.mounts > 0 then
				local offerTable = getOfferByIndex(npcHandler:getTopic(playerId) - config.topics.mount, config.mounts, config.topics.mount)
				if offerTable ~= nil then
					local points = offerTable.value
					if player:hasMount(offerTable.mountId) then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_24")
					elseif player:removeTaskHuntingPoints(points) then
						-- Add task hunting points history here.
						player:addMount(offerTable.mountId)
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.walter_jaeger.say_25")
					end
				else
					return true
				end
			end
			npcHandler:setTopic(playerId, 0)
		end
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.walter_jaeger.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.walter_jaeger.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.walter_jaeger.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
