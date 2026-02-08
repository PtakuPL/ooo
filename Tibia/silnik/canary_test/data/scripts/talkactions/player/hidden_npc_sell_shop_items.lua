local talkaction = TalkAction("!hiddenshop")

function talkaction.onSay(player, words, param)
	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_on_off_required")
		return true
	end
	if param == "on" then
		player:kv():set("npc-shop-hidden-sell-item", true)
		player:sendLocalizedTextMessage(MESSAGE_LOOK, "scripts.hidden_npc_sell_shop_items.msg_1")
	elseif param == "off" then
		player:kv():set("npc-shop-hidden-sell-item", false)
		player:sendLocalizedTextMessage(MESSAGE_LOOK, "scripts.hidden_npc_sell_shop_items.msg_2")
	end
	return true
end

talkaction:separator(" ")
talkaction:groupType("normal")
talkaction:register()
