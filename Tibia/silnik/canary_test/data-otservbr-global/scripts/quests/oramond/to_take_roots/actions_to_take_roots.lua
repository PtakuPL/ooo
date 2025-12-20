local function revertRoot(position, itemId, transformId)
	local item = Tile(position):getItemById(itemId)
	if item then
		item:transform(transformId)
	end
end

local toTakeRoots = Action()
function toTakeRoots.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local rand = math.random(1, 100)
	if item.itemid == 21104 then
		if rand <= 50 then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_to_take_roots.msg_5")
			player:addItem(21291, 1)
			item:transform(item.itemid + 2)
			addEvent(revertRoot, 120000, toPosition, 21106, 21104)
			toPosition:sendMagicEffect(CONST_ME_GREEN_RINGS)
			if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.QuestLine) <= 0 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.QuestLine, 1)
			end
			if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Mission) <= 0 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Mission, 1)
			end
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Count, player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Count) > 0 and player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Count) + 1 or 1)
		else
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_to_take_roots.msg_4")
			item:transform(item.itemid + 2)
			addEvent(revertRoot, 120000, toPosition, 21106, 21104)
			toPosition:sendMagicEffect(CONST_ME_GREEN_RINGS)
		end
	elseif item.itemid == 21105 then
		if rand <= 50 then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_to_take_roots.msg_3")
			player:addItem(21291, 1)
			item:transform(item.itemid + 2)
			addEvent(revertRoot, 120000, toPosition, 21107, 21105)
			toPosition:sendMagicEffect(CONST_ME_GREEN_RINGS)
			if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.QuestLine) <= 0 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.QuestLine, 1)
			end
			if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Mission) <= 0 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Mission, 1)
			end
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Count, player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Count) > 0 and player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Count) + 1 or 1)
		else
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_to_take_roots.msg_2")
			item:transform(item.itemid + 2)
			addEvent(revertRoot, 120000, toPosition, 21107, 21105)
			toPosition:sendMagicEffect(CONST_ME_GREEN_RINGS)
		end
	elseif item.itemid == 21106 or item.itemid == 21107 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_to_take_roots.msg_1")
	end
	return true
end

toTakeRoots:id(21104, 21105, 21106, 21107)
toTakeRoots:register()
