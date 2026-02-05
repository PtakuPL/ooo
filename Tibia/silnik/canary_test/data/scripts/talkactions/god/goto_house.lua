local sellHouse = TalkAction("/gotohouse")

function sellHouse.onSay(player, words, param)
	local targetPlayer = Player(param)
	if targetPlayer then
		local targetHouse = targetPlayer:getHouse()
		if not targetHouse then
			targetPlayer:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkactions.god.goto_house.player_no_house", {player:getName()})
			return
		end

		targetPlayer:teleportTo(targetHouse:getExitPosition())
	else
		local house = player:getHouse()
		if not house then
			player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.god.goto_house.no_house_usage")
			return
		end

		player:teleportTo(house:getExitPosition())
	end

	return true
end

sellHouse:separator(" ")
sellHouse:groupType("god")
sellHouse:register()
