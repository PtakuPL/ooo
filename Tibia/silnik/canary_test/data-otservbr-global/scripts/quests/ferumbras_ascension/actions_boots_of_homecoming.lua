local ferumbrasAscendantHomeComing = Action()
function ferumbrasAscendantHomeComing.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local boots = player:getSlotItem(CONST_SLOT_FEET)
	if boots ~= item or boots ~= item then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_boots_of_homecoming.msg_1")
		return true
	end
	if item.itemid == 22773 then
		if Tile(player:getPosition()):hasFlag(TILESTATE_PROTECTIONZONE) then
			item:transform(22774)
			item:decay()
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			player:teleportTo(Position(32121, 32708, 7))
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_boots_of_homecoming.msg_2")
		else
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_boots_of_homecoming.msg_3")
			return true
		end
	elseif item.itemid == 22774 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_boots_of_homecoming.msg_4")
	end
	return true
end

ferumbrasAscendantHomeComing:id(22773, 22774)
ferumbrasAscendantHomeComing:register()
