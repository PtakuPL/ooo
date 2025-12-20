local rottinWoodCorpse = Action()

function rottinWoodCorpse.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.itemid == 12189 then
		local storageRottinWoodAndMariedCorpse = player:getStorageValue(Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Corpse)
		if player:getStorageValue(Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03) == 5 and storageRottinWoodAndMariedCorpse < 4 then
			player:sayLocalized("scripts.actions_corpse.say_1", TALKTYPE_MONSTER_SAY)
			player:setStorageValue(Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Corpse, storageRottinWoodAndMariedCorpse + 1)
			item:remove(1)
		end
	end

	return true
end

rottinWoodCorpse:id(12189)
rottinWoodCorpse:register()
