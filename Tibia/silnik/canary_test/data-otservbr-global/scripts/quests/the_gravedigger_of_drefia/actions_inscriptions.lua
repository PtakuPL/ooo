local gravediggerInscriptions = Action()
function gravediggerInscriptions.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission45) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission46) < 1 then
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission46, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_inscriptions.msg_1")
		player:getPosition():sendMagicEffect(CONST_ME_ENERGYHIT)
	elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission46) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission47) < 1 then
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission47, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_inscriptions.msg_2")
		player:getPosition():sendMagicEffect(CONST_ME_ENERGYHIT)
	elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission47) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission48) < 1 then
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission48, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_inscriptions.msg_3")
		player:getPosition():sendMagicEffect(CONST_ME_ENERGYHIT)
	end
	return true
end

gravediggerInscriptions:aid(4651, 4652, 4653)
gravediggerInscriptions:register()
