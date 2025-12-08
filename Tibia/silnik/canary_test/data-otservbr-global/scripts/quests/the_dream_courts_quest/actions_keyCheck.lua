local storage = Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Questline
local pillar = { Position(33069, 32317, 8), Position(33070, 32317, 8), Position(33068, 32308, 8) }

local actions_keyCheck = Action()

function actions_keyCheck.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not player then
		return true
	end

	local iPos = item:getPosition()
	local isInQuest = player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Tomb)

	if player:getStorageValue(storage) == 1 and isInQuest < 1 then
		if iPos == pillar[1] or iPos == pillar[2] then
			if player:getItemCount(29351) >= 2 then
				player:removeItem(29351, 2)
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_keyCheck.msg_1")
				player:teleportTo(Position(33069, 32310, 8))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			else
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_keyCheck.msg_2")
				return true
			end
		elseif iPos == pillar[3] then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_keyCheck.msg_3")
			player:teleportTo(Position(33068, 32320, 8))
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Tomb, 1)
			if player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Tomb) == 1 and player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Cellar) == 1 and player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Temple) == 1 then
				player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Questline, 2)
			end
		end
	end

	return true
end

actions_keyCheck:aid(23105)
actions_keyCheck:register()
