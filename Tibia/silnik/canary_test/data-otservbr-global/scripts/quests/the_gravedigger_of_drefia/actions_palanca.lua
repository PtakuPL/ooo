local gravediggerPalanca = Action()

function gravediggerPalanca.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission39) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission40) < 1 then
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission40, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_palanca.msg_1")
		player:getPosition():sendMagicEffect(CONST_ME_ENERGYHIT)
	end

	return true
end

gravediggerPalanca:aid(4650)
gravediggerPalanca:register()
