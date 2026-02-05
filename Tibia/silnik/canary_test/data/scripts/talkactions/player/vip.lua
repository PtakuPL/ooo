local vip = TalkAction("!checkvip", "!vip")

function vip.onSay(player, words, param)
	if player:isVip() then
		player:sendVipStatus()
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.vip.msg_1")
	end
	return true
end

vip:groupType("normal")
vip:register()
