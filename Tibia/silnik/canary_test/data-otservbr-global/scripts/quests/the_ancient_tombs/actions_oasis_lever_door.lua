local doorPosition = Position(33122, 32765, 14)

local function revertCarrotAndLever(position, carrotPosition)
	local leverItem = Tile(position):getItemById(2773)
	if leverItem then
		leverItem:transform(2772)
	end

	local carrotItem = Tile(carrotPosition):getItemById(3595)
	if carrotItem then
		carrotItem:remove()
	end
end

local theAncientOasisLever = Action()
function theAncientOasisLever.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.itemid == 1662 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_oasis_lever_door.msg_1")
		return true
	end

	if item.itemid ~= 2772 then
		return true
	end

	if math.random(3) == 1 then
		local hatPosition = Position(toPosition.x - 1, toPosition.y, toPosition.z)
		hatPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
		doorPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
		Game.createItem(3595, 1, hatPosition)

		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_oasis_lever_door.msg_2")
		item:transform(2773)
		addEvent(revertCarrotAndLever, 4 * 1000, toPosition, hatPosition)

		local doorItem = Tile(doorPosition):getItemById(1662)
		if doorItem then
			doorItem:transform(1663)
		end
		return true
	end

	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_oasis_lever_door.msg_3")
	doAreaCombatHealth(player, COMBAT_PHYSICALDAMAGE, player:getPosition(), 0, -200, -200, CONST_ME_POFF)
	return true
end

theAncientOasisLever:aid(12107)
theAncientOasisLever:register()
