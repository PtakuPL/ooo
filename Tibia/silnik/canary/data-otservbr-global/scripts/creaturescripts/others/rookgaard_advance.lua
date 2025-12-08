local rookgaardAdvance = CreatureEvent("RookgaardAdvance")
function rookgaardAdvance.onAdvance(player, skill, oldLevel, newLevel)
	if skill ~= SKILL_LEVEL or newLevel ~= 8 or player:getVocation():getId() ~= 0 then
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "player.rookgaard.ready")
	return true
end

rookgaardAdvance:register()
