local setting = {
	[50510] = { position = Position(33459, 31715, 9), message = "scripts.oramond_teleport.say_1", premium = false }, --entrance
	[50511] = { position = Position(33668, 31887, 5), message = "scripts.oramond_teleport.say_2", premium = false }, --exit

	[50512] = { position = Position(31254, 32604, 9), message = "scripts.oramond_teleport.say_3", premium = false }, --minos entrance
	[50513] = { position = Position(31061, 32605, 9), message = "scripts.oramond_teleport.say_4", premium = false }, --golens entrance

	[50514] = { position = Position(33668, 31887, 5), message = "scripts.oramond_teleport.say_5", premium = false }, --minos exit
	[50515] = { position = Position(33668, 31887, 5), message = "scripts.oramond_teleport.say_6", premium = false }, --golens exit

	[50624] = { position = Position(33668, 31887, 5), message = "scripts.oramond_teleport.say_7", premium = false }, --minos exit
	[50625] = { position = Position(33668, 31887, 5), message = "scripts.oramond_teleport.say_8", premium = false }, --golens exit
}

local oramondTeleports = MoveEvent()

function oramondTeleports.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local teleport = setting[item.uid]
	if teleport then
		if not player:isPremium() and teleport.premium then
			player:teleportTo(fromPosition)
			player:sendLocalizedCancelMessage("quests.movements.you_need_a_premium_account_to")
			fromPosition:sendMagicEffect(CONST_ME_POFF)
			return true
		end

		player:teleportTo(teleport.position)
		item:getPosition():sendMagicEffect(CONST_ME_GREEN_RINGS)
		player:sayLocalized(teleport.message, TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end
	return true
end

oramondTeleports:type("stepin")

for index, value in pairs(setting) do
	oramondTeleports:uid(index)
end

oramondTeleports:register()
