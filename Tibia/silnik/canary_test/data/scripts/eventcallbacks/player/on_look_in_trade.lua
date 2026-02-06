local callback = EventCallback("PlayerOnLookInTradeBaseEvent")

function callback.playerOnLookInTrade(player, partner, item, distance)
	local prefix = Translator.getTranslation(player, "scripts.on_look_in_trade.you_see")
	player:sendTextMessage(MESSAGE_LOOK, string.format(prefix, item:getDescription(distance)))
end

callback:register()
