local vipGod = TalkAction("/vip")

local config = {
	minDays = 1, -- minimum number of days that can be added
	maxDays = 90, -- maximum days that can be added
}

function vipGod.onSay(player, words, param)
	if not configManager.getBoolean(configKeys.VIP_SYSTEM_ENABLED) then
		player:sendCancelMessage("Vip System are not enabled!")
		return true
	end

	-- create log
	logCommand(player, words, param)

	local params = param:split(",")
	local action = params[1]:trim():lower()

	local targetName = params[2]:trim()
	if not action or not targetName then
		player:sendLocalizedTextMessage(MESSAGE_LOOK, "scripts.manage_vip.msg_1")
		return true
	end

	local target = Player(targetName)
	if not target then
		player:sendLocalizedTextMessage(MESSAGE_LOOK, "scripts.manage_vip.msg_7", {targetName})
		return true
	end

	local targetVipDays = target:getVipDays()
	targetName = target:getName()

	if action == "check" then
		player:sendLocalizedTextMessage(MESSAGE_STATUS, "scripts.manage_vip.msg_6", {targetName, (targetVipDays == 0xFFFF and "infinite" or targetVipDays)})
	elseif action == "adddays" then
		local amount = tonumber(params[3])
		if not amount or amount <= 0 then
			player:sendCancelMessage("<value> has to be a numeric value.")
			return true
		end

		if amount < config.minDays or amount > config.maxDays then
			player:sendLocalizedTextMessage(MESSAGE_LOOK, "scripts.manage_vip.msg_5", {config.minDays, config.maxDays})
			return true
		end

		target:addPremiumDays(amount)
		target:onAddVip(amount)
		target:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
		player:sendLocalizedTextMessage(MESSAGE_STATUS, "scripts.manage_vip.msg_4", {targetName, amount, target:getVipDays()})
	elseif action == "removedays" then
		local amount = tonumber(params[3])
		if not amount then
			player:sendLocalizedTextMessage(MESSAGE_LOOK, "scripts.manage_vip.msg_2")
			return true
		end
		if amount > targetVipDays then
			target:removePremiumDays(targetVipDays)
			target:onRemoveVip()
			target:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			player:sendLocalizedTextMessage(MESSAGE_STATUS, "scripts.manage_vip.msg_3", {targetName})
		else
			target:removePremiumDays(amount)
			player:sendLocalizedTextMessage(MESSAGE_STATUS, "scripts.manage_vip.msg_2", {targetName, amount, target:getVipDays()})
		end
	elseif action == "remove" then
		target:removePremiumDays(targetVipDays)
		target:onRemoveVip()
		target:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		player:sendLocalizedTextMessage(MESSAGE_STATUS, "scripts.manage_vip.msg_1", {targetName})
	else
		player:sendLocalizedTextMessage(MESSAGE_LOOK, "scripts.manage_vip.msg_3")
		return true
	end
	return true
end

vipGod:separator(" ")
vipGod:groupType("god")
vipGod:register()
