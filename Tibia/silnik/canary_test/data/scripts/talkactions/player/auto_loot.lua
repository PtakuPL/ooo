local feature = TalkAction("!autoloot")

local validValues = {
	-- "all",
	"on",
	"off",
}

function feature.onSay(player, words, param)
	if not configManager.getBoolean(configKeys.AUTOLOOT) then
		return true
	end
	if configManager.getBoolean(configKeys.VIP_SYSTEM_ENABLED) and configManager.getBoolean(configKeys.VIP_AUTOLOOT_VIP_ONLY) and not player:isVip() then
		player:sendLocalizedMessage("talkactions.player.auto_loot.vip_required")
		return true
	end
	if not table.contains(validValues, param) then
		local validValuesStr = table.concat(validValues, "/")
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.auto_loot.msg_1" .. validValuesStr .. "]")
		return true
	end

	if param == "all" then
		player:setFeature(Features.AutoLoot, 2)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.auto_loot.msg_2")
	elseif param == "on" then
		player:setFeature(Features.AutoLoot, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.auto_loot.msg_3")
	elseif param == "off" then
		player:setFeature(Features.AutoLoot, 0)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.auto_loot.msg_4")
	end
	return true
end

feature:separator(" ")
feature:groupType("normal")
feature:register()
