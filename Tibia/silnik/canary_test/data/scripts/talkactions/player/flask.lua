local flask = TalkAction("!flask")

function flask.onSay(player, words, param)
	if param == "" then
		player:sendCancelMessage("You need to specify on/off param.")
		return true
	end
	if param == "on" then
		player:kv():set("talkaction.potions.flask", true)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.flask.msg_1")
		player:getPosition():sendMagicEffect(CONST_ME_REDSMOKE)
	elseif param == "off" then
		player:kv():remove("talkaction.potions.flask")
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.flask.msg_2")
		player:getPosition():sendMagicEffect(CONST_ME_REDSMOKE)
	end
	return true
end

flask:separator(" ")
flask:groupType("normal")
flask:register()
