local buyHouse = TalkAction("!buyhouse")

function buyHouse.onSay(player, words, param)
	local housePrice = configManager.getNumber(configKeys.HOUSE_PRICE_PER_SQM)
	if housePrice == -1 then
		return true
	end

	if not player:isPremium() then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.player.buy_house.msg_need_premium")
		return true
	end

	local houseBuyLevel = configManager.getNumber(configKeys.HOUSE_BUY_LEVEL)
	if player:getLevel() < houseBuyLevel then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.player.buy_house.msg_need_level", {houseBuyLevel})
		return true
	end

	local position = player:getPosition()
	position:getNextPosition(player:getDirection())

	local tile = Tile(position)
	local house = tile and tile:getHouse()
	local playerPos = player:getPosition()
	local houseEntry = house and house:getExitPosition()

	if not house or playerPos ~= houseEntry then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.player.buy_house.msg_look_at_door")
		return true
	end

	if house:getOwnerGuid() > 0 then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.player.buy_house.msg_has_owner")
		return true
	end

	if player:getHouse() then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.player.buy_house.msg_already_owner")
		return true
	end

	if house:hasItemOnTile() then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.buy_house.msg_1")
		return true
	end

	local price = house:getPrice()
	if not player:removeMoneyBank(price) then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.player.buy_house.msg_not_enough_money")
		return true
	end
	metrics.addCounter("balance_decrease", remainsPrice, {
		player = player:getName(),
		context = "house_purchase",
	})

	house:setHouseOwner(player:getGuid())
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.buy_house.msg_2")
	return true
end

if not configManager.getBoolean(configKeys.CYCLOPEDIA_HOUSE_AUCTION) then
	buyHouse:separator(" ")
	buyHouse:groupType("normal")
	buyHouse:register()
end
