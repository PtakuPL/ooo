local getlook = TalkAction("/getlook")

function getlook.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.common.param_required")
		return true
	end

	local creature = Creature(param)
	if not creature then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.creature.not_found")
		return true
	end

	local lookt = creature:getOutfit()
	player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, '<look type="' .. lookt.lookType .. '" head="' .. lookt.lookHead .. '" body="' .. lookt.lookBody .. '" legs="' .. lookt.lookLegs .. '" feet="' .. lookt.lookFeet .. '" addons="' .. lookt.lookAddons .. '" mount="' .. lookt.lookMount .. '" />')
	return true
end

getlook:separator(" ")
getlook:groupType("gamemaster")
getlook:register()
