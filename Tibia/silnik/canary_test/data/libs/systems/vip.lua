local config = {
	outfits = {},
	mounts = {},
}

function Player.onRemoveVip(self)
	self:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "lib.vip.msg_expired")

	for _, outfit in ipairs(config.outfits) do
		self:removeOutfit(outfit)
	end

	for _, mount in ipairs(config.mounts) do
		self:removeMount(mount)
	end

	local playerOutfit = self:getOutfit()
	if table.contains(config.outfits, playerOutfit.lookType) then
		if self:getSex() == PLAYERSEX_FEMALE then
			playerOutfit.lookType = 136
		else
			playerOutfit.lookType = 128
		end
		playerOutfit.lookAddons = 0

		self:setOutfit(playerOutfit)
	end

	self:kv():scoped("account"):remove("vip-system")
end

function Player.onAddVip(self, days, silent)
	if not silent then
		self:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "lib.vip.msg_granted", {tostring(days)})
	end

	for _, outfit in ipairs(config.outfits) do
		self:addOutfitAddon(outfit, 3)
	end

	for _, mount in ipairs(config.mounts) do
		self:addMount(mount)
	end

	self:kv():scoped("account"):set("vip-system", true)
end

function Player.sendVipStatus(self)
	if self:getVipDays() == 0xFFFF then
		self:sendLocalizedTextMessage(MESSAGE_LOGIN, "lib.vip.msg_unlimited")
		return true
	end

	local playerVipTime = self:getVipTime()
	if playerVipTime < os.time() then
		self:sendLocalizedTextMessage(MESSAGE_STATUS, "lib.vip.msg_inactive")
		return true
	end

	self:sendLocalizedTextMessage(MESSAGE_LOGIN, "lib.vip.msg_remaining", {getFormattedTimeRemaining(playerVipTime)})
end
