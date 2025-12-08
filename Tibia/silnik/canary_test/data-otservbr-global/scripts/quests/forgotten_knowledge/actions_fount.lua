local forgottenKnowledgeFount = Action()
function forgottenKnowledgeFount.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Phial) >= 1 then
		return false
	end
	player:addItem(23810)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_fount.msg_1")
	player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Phial, 1)
	return true
end

forgottenKnowledgeFount:id(25135, 25136, 25137, 25138)
forgottenKnowledgeFount:register()
