local ferumbrasAscendantAmulet = Action()

function ferumbrasAscendantAmulet.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local amulet = player:getSlotItem(CONST_SLOT_NECKLACE)
	if amulet ~= item then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.ferumbras_amulet.msg_1")
		return true
	end

	if item.itemid == 22767 then
		if math.random(2) == 1 then
			player:addHealth(1000, true, true)
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.ferumbras_amulet.msg_2")
		else
			player:addMana(1000, true, true)
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.ferumbras_amulet.msg_3")
		end

		item:transform(22768)
		item:decay()
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	elseif item.itemid == 22768 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.ferumbras_amulet.msg_4")
	end
	return true
end

ferumbrasAscendantAmulet:id(22767, 22768)
ferumbrasAscendantAmulet:register()
