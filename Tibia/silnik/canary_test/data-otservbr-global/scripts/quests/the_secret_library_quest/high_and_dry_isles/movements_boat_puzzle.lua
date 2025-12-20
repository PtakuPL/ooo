local movements_isle_color_puzzle = MoveEvent()

function movements_isle_color_puzzle.onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	local player = Player(creature:getId())
	local boatStage = player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.BoatStages)

	if item.actionid == 4936 then
		if boatStage < 1 then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.movements_boat_puzzle.msg_5")
			player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.BoatStages, 1)
		elseif boatStage >= 1 and boatStage < 2 then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.movements_boat_puzzle.msg_4")
		end
	elseif item.actionid == 4937 then
		if boatStage <= 1 then
			if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.Hawser) == 1 then
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.movements_boat_puzzle.msg_3")
				if player:getItemCount(28707) >= 1 then
					player:removeItem(28707, 1)
				end
				player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.BoatStages, 2)
			else
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.movements_boat_puzzle.msg_2")
			end
		elseif boatStage == 2 then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.movements_boat_puzzle.msg_1")
		elseif boatStage == 3 then
			player:teleportTo(Position(32187, 32473, 7))
			if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.Questline) < 3 then
				player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.SmallIslands.Questline, 3)
			end
		end
	end

	return true
end

movements_isle_color_puzzle:aid(4936, 4937)
movements_isle_color_puzzle:register()
