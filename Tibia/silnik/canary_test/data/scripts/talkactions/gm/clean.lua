local clean = TalkAction("/clean")

function clean.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local itemCount = cleanMap()
	if itemCount ~= 0 then
		player:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "talkaction.gm.clean.msg_cleaned", {itemCount})
	end
	return true
end

clean:separator(" ")
clean:groupType("gamemaster")
clean:register()
