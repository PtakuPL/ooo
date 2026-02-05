local buyHouse = TalkAction("!buyhouse")

function buyHouse.onSay(player, words, param)
	local housePrice = configManager.getNumber(configKeys.HOUSE_PRICE_PER_SQM)
	if housePrice == -1 then
		return true
	end

	if not player:isPremium() then
		player:sendLocalizedMessage("talkactions.player.buy_house.premium_required")
		return true
	end

	local houseBuyLevel = configManager.getNumber(configKeys.HOUSE_BUY_LEVEL)
	if player:getLevel() < houseBuyLevel then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkactions.player.buy_house.level_required", {houseBuyLevel})
		return true
	end

	local position = player:getPosition()
	position:getNextPosition(player:getDirection())

	local tile = Tile(position)
	local house = tile and tile:getHouse()
	local playerPos = player:getPosition()
	local houseEntry = house and house:getExitPosition()

	if not house or playerPos ~= houseEntry then
		player:sendLocalizedMessage("talkactions.player.buy_house.must_look_at_door")
		return true
	end

	if house:getOwnerGuid() > 0 then
		player:sendLocalizedMessage("talkactions.player.buy_house.already_has_owner")
		return true
	end

	if player:getHouse() then
		player:sendLocalizedMessage("talkactions.player.buy_house.already_own_house")
		return true
	end

	if house:hasItemOnTile() then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.buy_house.msg_1")
		return true
	end

	local price = house:getPrice()
	if not player:removeMoneyBank(price) then
		player:sendLocalizedMessage("talkactions.player.buy_house.insufficient_money")
		return true
	end
	metrics.addCounter("balance_decrease", remainsPrice, {
		player = player:getName(),
		context = "house_purchase",
	})

	house:setHouseOwner(player:getGuid())
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.buy_house.msg_2")
	return true
end

if not configManager.getBoolean(configKeys.CYCLOPEDIA_HOUSE_AUCTION) then
	buyHouse:separator(" ")
	buyHouse:groupType("normal")
	buyHouse:register()
end
