local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams

local foundPoacherBody = MoveEvent()
function foundPoacherBody.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return false
	end
	if player:getStorageValue(ThreatenedDreams.Mission01[1]) == 6 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movement_poacher_notes.msg_1")
		player:setStorageValue(ThreatenedDreams.Mission01[1], 7)
	end
	return true
end

foundPoacherBody:position({ x = 32949, y = 31811, z = 7 })
foundPoacherBody:position({ x = 32950, y = 31811, z = 7 })
foundPoacherBody:position({ x = 32951, y = 31811, z = 7 })
foundPoacherBody:register()
