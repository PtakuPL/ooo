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
	local messageKey = "quests.threatened_dreams.found_herb"
	local messageArgs = { getItemName(config.herbId) }
	local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)

	if not backpack or backpack:getEmptySlots(true) < 1 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.threatened_dreams.herb_no_room", { getItemName(config.herbId) })
		return true
	end

	if (player:getFreeCapacity() / 100) < config.herbWeight then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.threatened_dreams.herb_too_heavy", { getItemName(config.herbId), config.herbWeight })
		return true
	end

	if player:getStorageValue(config.storage) > os.time() then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.event_raven_herb_bush.msg_1")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, messageKey, messageArgs)
	player:setStorageValue(config.storage, os.time() + 60 * 30 * 1000)
	player:addItem(config.herbId, 1)
	return true
end

ravenHerb:id(25783)
ravenHerb:register()
