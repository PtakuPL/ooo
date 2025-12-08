local adventurersWarriorSkeleton = Action()

function adventurersWarriorSkeleton.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U10_80.TheGreatDragonHunt.WarriorSkeleton) < 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_warrior_skeleton.msg_1")
		player:addItem(5882, 1)

		if player:getStorageValue(Storage.Quest.U9_80.AdventurersGuild.QuestLine) < 1 then
			player:setStorageValue(Storage.Quest.U9_80.AdventurersGuild.QuestLine, 1)
		end

		player:setStorageValue(Storage.Quest.U10_80.TheGreatDragonHunt.WarriorSkeleton, 1)
		player:setStorageValue(Storage.Quest.U10_80.TheGreatDragonHunt.DragonCounter, 0)
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_warrior_skeleton.msg_2")
	end

	return true
end

adventurersWarriorSkeleton:aid(50806)
adventurersWarriorSkeleton:register()
