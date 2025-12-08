local questline = Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Questline
local wordsCount = Storage.Quest.U12_00.TheDreamCourts.BurriedCatedral.WordCount
local facelessTime = Storage.Quest.U12_00.TheDreamCourts.BurriedCatedral.FacelessTime

local actions_bookOnTable = Action()

function actions_bookOnTable.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not player then
		return true
	end

	if player:getStorageValue(questline) == 2 and player:getStorageValue(wordsCount) >= 4 then
		player:setStorageValue(questline, 3)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bookOnTable.msg_1")
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bookOnTable.msg_2")
	elseif player:getStorageValue(questline) >= 4 then
		if player:getStorageValue(facelessTime) > os.time() then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bookOnTable.msg_3")
			return true
		else
			player:teleportTo(Position(33640, 32561, 13))
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bookOnTable.msg_4")
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		end
	end

	return true
end

actions_bookOnTable:id(29954)
actions_bookOnTable:register()
