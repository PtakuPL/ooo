local leaveHouse = TalkAction("!leavehouse")

function leaveHouse.onSay(player, words, param)
	local playerPosition = player:getPosition()
	local playerTile = Tile(playerPosition)
	local house = playerTile and playerTile:getHouse()
	if not house then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_not_inside_house")
		playerPosition:sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if house:getOwnerGuid() ~= player:getGuid() then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.player.leave_house.msg_not_owner")
		playerPosition:sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if house:hasNewOwnership() then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.leave_house.msg_1")
		playerPosition:sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Move hireling back to lamp
	local tiles = house:getTiles()
	if tiles then
		for i, tile in pairs(tiles) do
			if tile then
				local position = Position(tile:getPosition())
				local hireling = getHirelingByPosition(position)
				if hireling then
					hireling:returnToLamp(player:getGuid())
				end
			end
		end
	end

	house:setNewOwnerGuid(0)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.leave_house.msg_2")
	playerPosition:sendMagicEffect(CONST_ME_POFF)
	return true
end

if not configManager.getBoolean(configKeys.CYCLOPEDIA_HOUSE_AUCTION) then
	leaveHouse:separator(" ")
	leaveHouse:groupType("normal")
	leaveHouse:register()
end
