local premiumScroll = Action()

function premiumScroll.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local maxDays = 365
	if player:getPremiumDays() <= maxDays then
		item:remove(1)
		player:addPremiumDays(30)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.premium_scroll.msg_1")
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	else
		player:sendCancelMessage("You can not buy more than " .. maxDays .. " days of premium account.")
	end
	return true
end

premiumScroll:id(14758)
premiumScroll:register()
