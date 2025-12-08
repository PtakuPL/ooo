local config = {
	antlers = 10297,
	antler_talisman = 22008,
}

local starHerb = Action()

function starHerb.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target.itemid == config.antlers then
		target:transform(config.antler_talisman)
		item:remove(1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_star_herb.msg_1")
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end
	return true
end

starHerb:id(3736)
starHerb:register()
