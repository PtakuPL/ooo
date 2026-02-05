local clean = TalkAction("/clean")

function clean.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local itemCount = cleanMap()
	if itemCount ~= 0 then
		player:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "talkactions.gm.clean.cleaned_items", {tostring(itemCount), itemCount > 1 and "s" or ""})
	end
	return true
end

clean:separator(" ")
clean:groupType("gamemaster")
clean:register()
