local theThievesDoor = Action()
function theThievesDoor.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission06) == 3 then
		player:sayLocalized("scripts.actions_fish_napping_door.say_1", TALKTYPE_MONSTER_SAY)
		player:teleportTo(Position(32359, 32786, 6))
	end
	return true
end

theThievesDoor:aid(51394)
theThievesDoor:register()
