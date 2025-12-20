local config = {
	[897] = 9598, -- TBI
	[898] = 9596, -- CGB
	[899] = 9594, -- AVIN
}

local secretServiceTools = Action()
function secretServiceTools.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local useItem = config[item.itemid]
	if not useItem then
		return true
	end

	player:addItem(useItem)
	player:sayLocalized("scripts.actions_tools.say_1", TALKTYPE_MONSTER_SAY)

	item:remove()
	return true
end

for itemId, info in pairs(config) do
	secretServiceTools:id(itemId)
end

secretServiceTools:register()
