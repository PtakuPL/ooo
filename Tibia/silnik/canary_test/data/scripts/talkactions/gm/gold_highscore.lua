local goldRank = TalkAction("/goldrank")

function goldRank.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local highscoreQuery = db.storeQuery("SELECT `balance`, `name` FROM `players` WHERE group_id < 3 ORDER BY balance DESC LIMIT 10")
	if not highscoreQuery then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.gm.gold_highscore.msg_no_highscore")
		return true
	end

	local highscoreList = ""
	local rank = 0
	repeat
		rank = rank + 1
		local playerName = Result.getString(highscoreQuery, "name")
		local playerBalance = FormatNumber(Result.getNumber(highscoreQuery, "balance"))
		highscoreList = highscoreList .. "\n" .. rank .. "- " .. playerName .. " (" .. playerBalance .. ")."
	until not Result.next(highscoreQuery)

	Result.free(highscoreQuery)
	if highscoreList == "" then
		highscoreList = player:getTranslation("talkaction.gm.gold_highscore.msg_no_highscore")
	end

	player:popupFYI(player:getTranslation("talkaction.gm.gold_highscore.msg_header") .. "\n" .. highscoreList)
	return true
end

goldRank:separator(" ")
goldRank:groupType("gamemaster")
goldRank:register()
