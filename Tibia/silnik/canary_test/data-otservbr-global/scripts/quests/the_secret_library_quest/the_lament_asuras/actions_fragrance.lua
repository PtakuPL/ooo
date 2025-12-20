local actions_asura_fragrance = Action()

function actions_asura_fragrance.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_fragrance.msg_1")
	player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Asuras.Fragrance, os.time() + 10 * 60)
	item:remove(1)

	return true
end

actions_asura_fragrance:id(28495)
actions_asura_fragrance:register()
