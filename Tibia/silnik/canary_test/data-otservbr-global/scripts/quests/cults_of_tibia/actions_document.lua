local cultsOfTibiaDocument = Action()

function cultsOfTibiaDocument.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local posDocument = Position(33279, 32169, 8)
	if item:getPosition() == posDocument then
		if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 2 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_document.msg_1")
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_document.msg_2")
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_document.msg_3")
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_document.msg_4")
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_document.msg_5")
			player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission, 3)
		end
	end

	return true
end

cultsOfTibiaDocument:aid(5522)
cultsOfTibiaDocument:register()
