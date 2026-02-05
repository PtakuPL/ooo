local config = {
	[23734] = { transformId = 23738 },
	[23738] = { transformId = 23734 },
}

local forgottenKnowledgeLantern = Action()
function forgottenKnowledgeLantern.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local lantern = config[item.itemid]
	if not lantern then
		return true
	end

	if not player:getStorageValue(23734) == 1 then
		return false
	end
	if item:getId() == 23734 then
		player:getPosition():sendMagicEffect(CONST_ME_ENERGYAREA)
		local msgKey = "scripts.lantern.glowing"
		if player:getPosition():getDistance(Position(32891, 31619, 10)) < 2 then
			if not player:getItemById(23733, true) then
				msgKey = "scripts.lantern.invisible_door_no_key"
			else
				msgKey = "scripts.lantern.invisible_door_have_key"
			end
		end
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, msgKey)
	end
	item:transform(lantern.transformId)
	return true
end

for itemId, itemInfo in pairs(config) do
	forgottenKnowledgeLantern:id(itemId)
end

forgottenKnowledgeLantern:register()
