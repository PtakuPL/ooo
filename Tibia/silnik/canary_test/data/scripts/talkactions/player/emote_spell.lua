-- Usage talkaction: "!emote on" or "!emote off"
local emoteSpell = TalkAction("!emote")

function emoteSpell.onSay(player, words, param)
	if configManager.getBoolean(configKeys.EMOTE_SPELLS) == false then
		player:sendLocalizedMessage(MESSAGE_LOOK, "scripts.emote_spell.msg_1")
		return true
	end

	if param == "" then
		player:sendLocalizedMessage("talkactions.player.emote_spell.specify_parameter")
		return true
	end

	if param == "on" then
		player:setStorageValue(STORAGEVALUE_EMOTE, 1)
		player:sendLocalizedMessage(MESSAGE_LOOK, "scripts.emote_spell.msg_2")
	elseif param == "off" then
		player:setStorageValue(STORAGEVALUE_EMOTE, 0)
		player:sendLocalizedMessage(MESSAGE_LOOK, "scripts.emote_spell.msg_3")
	end
	return true
end

emoteSpell:separator(" ")
emoteSpell:groupType("normal")
emoteSpell:register()
