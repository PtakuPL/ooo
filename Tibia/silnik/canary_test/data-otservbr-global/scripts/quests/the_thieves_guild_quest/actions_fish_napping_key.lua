-- Theodore Loveless' key

local theThievesKey = Action()
function theThievesKey.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission06) == 2 then
		if target.actionid == 51394 and item.itemid == 7934 then
			player:removeItem(7934, 1)
			player:sayLocalized("scripts.actions_fish_napping_key.say_1", TALKTYPE_MONSTER_SAY)
			player:teleportTo(Position(32359, 32788, 6))
			return true
		end
	end
	return false
end

theThievesKey:id(7934)
theThievesKey:register()
