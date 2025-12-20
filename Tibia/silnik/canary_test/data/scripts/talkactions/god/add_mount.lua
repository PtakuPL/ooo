local addmount = TalkAction("/addmount")

function addmount.onSay(player, words, param)
	-- Create log
	logCommand(player, words, param)

	if param == "" then
		player:sendCancelMessage("Command param required.")
		return true
	end

	local split = param:split(",")
	if #split < 2 then
		player:sendCancelMessage("Usage: /addmount <playername>, <mount id or 'all'>")
		return true
	end

	local playerName = split[1]
	local target = Player(playerName)

	if not target then
		player:sendCancelMessage("Player not found.")
		return true
	end

	local mountParam = string.trim(split[2])
	if mountParam == "all" then
		for mountId = 1, 231 do
			target:addMount(mountId)
		end

		target:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.add_mount.msg_4", {player:getName()})
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.add_mount.msg_3", {target:getName()})
	else
		local mountId = tonumber(mountParam)
		if not mountId then
			player:sendCancelMessage("Invalid mount ID.")
			return true
		end

		target:addMount(mountId)
		target:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.add_mount.msg_2", {player:getName()})
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.add_mount.msg_1", {mountId, target:getName()})
	end
	return true
end

addmount:separator(" ")
addmount:groupType("god")
addmount:register()
