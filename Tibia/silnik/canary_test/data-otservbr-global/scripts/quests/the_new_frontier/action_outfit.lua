local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier

local theNewFrontierOutfit = Action()

function theNewFrontierOutfit.onUse(player, item)
	if player:getStorageValue(TheNewFrontier.Questline) == 26 then
		player:addOutfit(335, 0)
		player:addOutfit(336, 0)
		player:setStorageValue(TheNewFrontier.Mission09.RewardDoor, 1)
		player:setStorageValue(TheNewFrontier.Questline, 27)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.action_outfit.msg_1")
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.action_outfit.msg_2")
	end
	return true
end

theNewFrontierOutfit:position({ x = 33053, y = 31020, z = 7 })
theNewFrontierOutfit:register()
