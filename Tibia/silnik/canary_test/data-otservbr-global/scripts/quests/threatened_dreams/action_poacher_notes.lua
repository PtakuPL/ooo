local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams

local poacherNotes = Action()
function poacherNotes.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(ThreatenedDreams.Mission01[1]) == 7 and player:getStorageValue(ThreatenedDreams.Mission01.PoacherNotes) < 1 then
		player:addItem(25242, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.action_poacher_notes.msg_1")
		player:setStorageValue(ThreatenedDreams.Mission01.PoacherNotes, 1)
	else
		player:sendLocalizedCancelMessage("scripts.common.empty")
	end

	return true
end

poacherNotes:aid(20002)
poacherNotes:register()
