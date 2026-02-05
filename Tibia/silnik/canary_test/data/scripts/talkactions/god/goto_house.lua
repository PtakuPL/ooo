local sellHouse = TalkAction("/gotohouse")

function sellHouse.onSay(player, words, param)
	local targetPlayer = Player(param)
	if targetPlayer then
		local targetHouse = targetPlayer:getHouse()
		if not targetHouse then
			targetPlayer:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.goto_house.msg_target_no_house", {player:getName()})
			return
		end

		targetPlayer:teleportTo(targetHouse:getExitPosition())
	else
		local house = player:getHouse()
		if not house then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.goto_house.msg_self_no_house")
			return
		end

		player:teleportTo(house:getExitPosition())
	end

	return true
end

sellHouse:separator(" ")
sellHouse:groupType("god")
sellHouse:register()
