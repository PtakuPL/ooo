local createMonster = TalkAction("/spawn")

function createMonster.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.common.param_required")
		return true
	end

	local spawn = Spawn()
	local parameter = param:split(",")
	local config = {
		{
			spawntime = tonumber(parameter[2]) or 60,
			monster = parameter[1],
			pos = player:getPosition(),
			status = true,
		},
	}
	spawn:setPositions(config)
	spawn:executeSpawn()
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.create_spawn.msg_1" .. parameter[1] .. ".")
	return true
end

createMonster:separator(" ")
createMonster:groupType("god")
createMonster:register()
