local premiumScroll = Action()

function premiumScroll.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local maxDays = 365
	if player:getPremiumDays() <= maxDays then
		item:remove(1)
		player:addPremiumDays(30)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.premium_scroll.msg_1")
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "actions.premium_scroll.max_days_reached", {maxDays})
	end
	return true
end

premiumScroll:id(14758)
premiumScroll:register()
