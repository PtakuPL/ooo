local forgottenKnowledgeSecret = Action()
function forgottenKnowledgeSecret.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.actionid == 24877 then
		player:teleportTo(Position(32891, 31620, 10))
		return true
	end
	if not player:getItemById(23738, true) then
		return false
	end
	if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.SilverKey) < 1 or not player:getItemById(23733, true) then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_secret_wall.msg_1")
		return true
	end
	player:teleportTo(Position(32924, 31637, 14))
	return true
end

forgottenKnowledgeSecret:aid(24876, 24877)
forgottenKnowledgeSecret:register()
