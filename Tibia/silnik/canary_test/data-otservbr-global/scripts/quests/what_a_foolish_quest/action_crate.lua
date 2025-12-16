local whatFoolishCrate = Action()
function whatFoolishCrate.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target.itemid ~= 116 then
		return false
	end

	if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) ~= 8 then
		return false
	end

	player:getPosition():sendMagicEffect(CONST_ME_SOUND_GREEN)
	player:sayLocalized("scripts.action_crate.say_1", TALKTYPE_MONSTER_SAY)
	toPosition:sendMagicEffect(CONST_ME_BLOCKHIT)
	item:transform(item.itemid + 1)
	return true
end

whatFoolishCrate:id(117)
whatFoolishCrate:register()
