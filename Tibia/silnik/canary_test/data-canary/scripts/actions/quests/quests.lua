local quests = Action()

function quests.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.uid <= 1250 or item.uid >= 30000 then
		return false
	end

	local itemType = ItemType(item.uid)
	if itemType:getId() == 0 then
		return false
	end

	local itemWeight = itemType:getWeight()
	local playerCap = player:getFreeCapacity()
	if table.contains({ 1990, 2400, 2431, 2494 }, item.uid) then
		if player:getStorageValue(Storage.Quest.ExampleQuest.Example) == -1 then
			if playerCap >= itemWeight then
				if item.uid == 1990 then
					player:addItem(2856, 1):addItem(3213, 1)
				else
					player:addItem(item.uid, 1)
				end
				player:sendLocalizedMessage(MESSAGE_LOOK, "scripts.canary_quests.found_item", { itemType:getName() })
				player:setStorageValue(Storage.Quest.ExampleQuest.Example, 1)
			else
				player:sendLocalizedMessage(MESSAGE_LOOK, "scripts.canary_quests.found_item_too_heavy", { itemType:getName(), itemWeight })
			end
		else
			player:sendLocalizedTextMessage(MESSAGE_LOOK, "actions.quests.msg_2")
		end
	elseif player:getStorageValue(item.uid) == -1 then
		if playerCap >= itemWeight then
			player:sendLocalizedMessage(MESSAGE_LOOK, "scripts.canary_quests.found_item", { itemType:getName() })
			player:addItem(item.uid, 1)
			player:setStorageValue(item.uid, 1)
		else
			player:sendLocalizedMessage(MESSAGE_LOOK, "scripts.canary_quests.found_item_too_heavy", { itemType:getName(), itemWeight })
		end
	else
		player:sendLocalizedTextMessage(MESSAGE_LOOK, "actions.quests.msg_1")
	end
	return true
end

quests:id(2472, 2480, 2481, 2482)
quests:register()
