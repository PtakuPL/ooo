local callback = EventCallback("PlayerOnLookInTradeBaseEvent")

function callback.playerOnLookInTrade(player, partner, item, distance)
	player:sendLocalizedTextMessage(MESSAGE_LOOK, "eventcallbacks.trade_look", {item:getDescription(distance)})
end

callback:register()
