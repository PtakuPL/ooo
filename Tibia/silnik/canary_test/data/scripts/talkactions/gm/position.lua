local position = TalkAction("/pos", "!pos")

function position.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		local pos = player:getPosition()
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.position.msg_1" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ".")
		return
	end

	local teleportPosition = param:toPosition()
	if not teleportPosition then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.position.msg_2")
		return
	end

	local tile = Tile(teleportPosition)
	if not tile then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.position.msg_3")
		return
	end

	player:teleportTo(teleportPosition)
	if not player:isInGhostMode() then
		teleportPosition:sendMagicEffect(CONST_ME_TELEPORT)
	end
end

position:separator(" ")
position:groupType("gamemaster")
position:register()
