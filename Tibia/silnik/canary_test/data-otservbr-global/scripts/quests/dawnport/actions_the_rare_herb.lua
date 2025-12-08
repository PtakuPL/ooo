local theRareHerb = Action()

function theRareHerb.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local setting = ItemUnique[item.uid]
	if setting then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheRareHerb) == 1 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_the_rare_herb.msg_1")
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheRareHerb, 2)
		else
			return false
		end
	end
	return true
end

theRareHerb:uid(40027)
theRareHerb:register()
