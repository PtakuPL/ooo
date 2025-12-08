local forgottenKnowledgeOldDesk = Action()
function forgottenKnowledgeOldDesk.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.SilverKey) >= 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_old_desk.msg_1")
		return true
	end
	if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.GirlPicture) >= 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_old_desk.msg_2")
		player:addItem(23733, true, true)
		player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.SilverKey, 1)
		return true
	end
	if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.OldDesk) >= 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_old_desk.msg_3")
		return true
	end
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_old_desk.msg_4")
	player:addItem(23731, true, true)
	player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.OldDesk, 1)
	return true
end

forgottenKnowledgeOldDesk:aid(24875)
forgottenKnowledgeOldDesk:register()
