local config = {
	bushId = 25783,
	createItem = LIGHT_STATE_NIGHT,
	removeItem = LIGHT_STATE_SUNRISE,
	pos = Position(33497, 32196, 7),
	herbId = 5953,
	herbWeight = 1,
	storage = Storage.Quest.U11_40.ThreatenedDreams.Mission03.RavenHerbTimer,
}

local createRavenHerb = GlobalEvent("createRavenHerb")

function createRavenHerb.onPeriodChange(period, light)
	local pos = config.pos
	if config.createItem == period then
		local createItem = Game.createItem(config.bushId, 1, pos)
		if createItem then
			pos:sendMagicEffect(CONST_ME_BIGPLANTS)
		end
	elseif config.removeItem == period then
		local target = Tile(pos):getItemById(config.bushId)
		if target then
			pos:removeItem(config.bushId, CONST_ME_BIGPLANTS)
		end
	end
	return true
end

createRavenHerb:register()

local ravenHerb = Action()

function ravenHerb.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local herbName = getItemName(config.herbId)
	local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)

	if not backpack or backpack:getEmptySlots(true) < 1 then
		local foundMessage = "You have found a " .. herbName .. "."
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.quest_reward_common.no_room", foundMessage)
		return true
	end

	if (player:getFreeCapacity() / 100) < config.herbWeight then
		local foundMessage = "You have found a " .. herbName .. "."
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.quest_reward_common.too_heavy", foundMessage, config.herbWeight)
		return true
	end

	if player:getStorageValue(config.storage) > os.time() then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.event_raven_herb_bush.msg_1")
		return true
	end

	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.common.found_item_a", herbName)
	player:setStorageValue(config.storage, os.time() + 60 * 30 * 1000)
	player:addItem(config.herbId, 1)
	return true
end

ravenHerb:id(25783)
ravenHerb:register()
