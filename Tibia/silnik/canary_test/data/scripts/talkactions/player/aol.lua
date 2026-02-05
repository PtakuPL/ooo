local aol = TalkAction("!aol")

function aol.onSay(player, words, param)
	local totalCost = 50000 + (configManager.getNumber(configKeys.BUY_AOL_COMMAND_FEE) or 0)
	if player:removeMoneyBank(totalCost) then
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		player:addItem(3057, 1)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.aol.msg_1", {totalCost})
	else
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.player.aol.msg_not_enough_money", {totalCost})
	end
	return true
end

aol:groupType("normal")
aol:register()
