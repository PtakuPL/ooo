local gravediggerAmforas = Action()
function gravediggerAmforas.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission05) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission06) ~= 1 then
		local chances = math.random(30)
		if chances == 13 then
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission06, 1)
			player:sayLocalized("scripts.actions_amforas.say_3", TALKTYPE_MONSTER_SAY)
			player:getPosition():sendMagicEffect(CONST_ME_HEARTS)
			player:addItem(19077, 1)
		else
			player:sayLocalized("scripts.actions_amforas.say_2", TALKTYPE_MONSTER_SAY)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	else
		player:sayLocalized("scripts.actions_amforas.say_1", TALKTYPE_MONSTER_SAY)
	end
	return true
end

gravediggerAmforas:aid(4630)
gravediggerAmforas:register()
