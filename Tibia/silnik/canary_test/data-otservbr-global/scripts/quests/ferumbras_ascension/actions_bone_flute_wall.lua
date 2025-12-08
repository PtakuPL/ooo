local ferumbrasAscendantBoneWall = Action()
function ferumbrasAscendantBoneWall.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.BoneFluteWall) < 1 then
		player:addItem(22254)
		player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.BoneFluteWall, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bone_flute_wall.msg_1")
		toPosition:sendMagicEffect(CONST_ME_THUNDER)
	else
		return false
	end
	return true
end

ferumbrasAscendantBoneWall:aid(54386)
ferumbrasAscendantBoneWall:register()
