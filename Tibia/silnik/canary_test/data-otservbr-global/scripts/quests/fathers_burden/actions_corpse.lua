local config = {
	[11589] = { itemId = 11550, storage = Storage.Quest.U8_6.AFathersBurden.Corpse.Scale, text = "quests.fathers_burden.corpse_say_1" },
	[11590] = { itemId = 11548, storage = Storage.Quest.U8_6.AFathersBurden.Corpse.Sinew, text = "quests.fathers_burden.corpse_say_2" },
}

local fatherCorpse = Action()
function fatherCorpse.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local corpse = config[item.itemid]
	if not corpse then
		return true
	end

	if player:getStorageValue(corpse.storage) == 1 then
		return false
	end

	player:addItem(corpse.itemId, 1)
	player:setStorageValue(corpse.storage, 1)
	player:sayLocalized("quests.fathers_burden.acquired", TALKTYPE_MONSTER_SAY, false, nil, nil, { corpse.text })
	return true
end

for itemId, itemInfo in pairs(config) do
	fatherCorpse:id(itemId)
end

fatherCorpse:register()
