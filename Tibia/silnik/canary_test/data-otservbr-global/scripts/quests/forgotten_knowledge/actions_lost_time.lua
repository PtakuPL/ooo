local forgottenKnowledgeLostTime = Action()
function forgottenKnowledgeLostTime.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target:getName():lower() ~= "time waster" then
		return false
	end
	target:getPosition():sendMagicEffect(CONST_ME_POFF)
	target:remove()
	item:remove()
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_lost_time.msg_1")
	return true
end

forgottenKnowledgeLostTime:id(23729)
forgottenKnowledgeLostTime:register()
