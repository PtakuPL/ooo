local teleportToCreature = TalkAction("/goto")

function teleportToCreature.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.common.param_required")
		return true
	end

	local target = Creature(param)
	if target then
		player:teleportTo(target:getPosition())
	else
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.common.creature_not_found")
	end
	return true
end

teleportToCreature:separator(" ")
teleportToCreature:groupType("gamemaster")
teleportToCreature:register()
