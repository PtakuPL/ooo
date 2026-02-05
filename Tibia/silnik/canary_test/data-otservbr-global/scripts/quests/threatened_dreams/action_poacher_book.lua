local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams

local poacherBook = Action()
function poacherBook.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(ThreatenedDreams.Mission01[1]) == 2 then
		if target.itemid == 12648 or target.itemid == 12649 then
			target:decay()
			item:remove(1)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.action_poacher_book.msg_1")
			toPosition:sendMagicEffect(CONST_ME_BLOCKHIT)
			player:setStorageValue(ThreatenedDreams.Mission01[1], 3)
			return true
		end
	else
		player:sendLocalizedCancelMessage("quests.common.not_on_mission")
	end
end

poacherBook:id(25235)
poacherBook:register()
