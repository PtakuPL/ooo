local ferumbrasAscendantManaKeg = Action()

function ferumbrasAscendantManaKeg.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.itemid == 22769 then
		player:addItem("ultimate mana potion", 10)
		item:transform(22770)
		item:decay()
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.ferumbras_mana_keg.msg_1")
		return true
	elseif item.itemid == 22770 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.ferumbras_mana_keg.msg_2")
	end
	return true
end

ferumbrasAscendantManaKeg:id(22769, 22770)
ferumbrasAscendantManaKeg:register()
