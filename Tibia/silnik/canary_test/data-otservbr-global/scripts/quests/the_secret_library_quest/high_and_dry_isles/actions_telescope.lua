local actions_isles_telescope = Action()

function actions_isles_telescope.onUse(player, item, fromPosition, itemEx, toPosition)
	if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.BoatStages) == 2 then
		player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.BoatStages, 3)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_telescope.msg_1")
	end

	return true
end

actions_isles_telescope:aid(4935)
actions_isles_telescope:register()
