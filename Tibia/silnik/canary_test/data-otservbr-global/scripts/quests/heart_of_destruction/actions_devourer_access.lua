local heartDestructionDevourer = Action()
function heartDestructionDevourer.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not player:canFightBoss("World Devourer") then
		player:setBossCooldown("World Devourer", 0)
		player:sendLocalizedMessage(19, "scripts.actions_devourer_access.msg_1")
		item:transform(23687)
	else
		player:sendLocalizedMessage(19, "scripts.actions_devourer_access.msg_2")
	end

	return true
end

heartDestructionDevourer:id(23686)
heartDestructionDevourer:register()
