local function placeFruits(position, fruit, nofruit)
	local item = Tile(position):getItemById(nofruit)

	if item then
		item:transform(fruit)
	end
end

local fruitId = 29995

local actions_sunFruit = Action()

function actions_sunFruit.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not player then
		return true
	end

	local r = math.random(2, 4)

	player:addItem(fruitId, r)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_sunFruit.msg_1", { ItemType(fruitId):getName() })
	item:transform(29970)
	item:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	addEvent(placeFruits, 1 * 60 * 60 * 1000, item:getPosition(), 29969, 29970)

	return true
end

actions_sunFruit:id(29969)
actions_sunFruit:register()
