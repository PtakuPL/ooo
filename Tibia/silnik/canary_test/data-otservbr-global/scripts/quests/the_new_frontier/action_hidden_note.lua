local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier

local hiddenNote = Action()

function hiddenNote.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(TheNewFrontier.Mission07.HiddenNote) < 1 then
		local note = player:addItem(8747, 1)
		note:setAttribute(ITEM_ATTRIBUTE_TEXT, "#i18n:book.new_frontier.hidden_note")
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.action_hidden_note.msg_1")
		player:setStorageValue(TheNewFrontier.Mission07.HiddenNote, 1)
		return true
	end
end

hiddenNote:position(Position(33165, 31249, 11))
hiddenNote:register()
