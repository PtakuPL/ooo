local forgottenKnowledgeGirl = Action()
function forgottenKnowledgeGirl.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.GirlPicture) >= 1 then
		return false
	end
	player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.GirlPicture, 1)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_girl_picture.msg_1")
	item:remove()
	return true
end

forgottenKnowledgeGirl:id(23732)
forgottenKnowledgeGirl:register()
