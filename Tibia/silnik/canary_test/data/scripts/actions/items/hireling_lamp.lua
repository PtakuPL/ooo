local hirelingLamp = Action()

function hirelingLamp.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local spawnPosition = player:getPosition()
	local hirelingId = item:getCustomAttribute("Hireling")
	local house = spawnPosition and spawnPosition:getTile() and spawnPosition:getTile():getHouse() or nil

	if not house then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "scripts.hireling_lamp.msg_1")
		return false
	elseif house:getDoorIdByPosition(spawnPosition) then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "scripts.hireling_lamp.msg_2")
		return false
	elseif getHirelingByPosition(spawnPosition) then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "scripts.hireling_lamp.msg_3")
		return false
	elseif house:getOwnerGuid() ~= player:getGuid() then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "scripts.hireling_lamp.msg_4")
		return false
	end

	local hireling = getHirelingById(hirelingId)
	if not hireling then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.hireling_lamp.msg_5")
		logger.warn("[hirelingLamp.onUse] Player {} is using hireling with id {} not exist in the database", player:getName(), hirelingId)
		logger.error("Deleted the lamp")
		item:remove(1)
		return true
	end

	hireling:setPosition(spawnPosition)
	item:remove(1)
	hireling:spawn()
	spawnPosition:sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

hirelingLamp:id(HIRELING_LAMP)
hirelingLamp:register()
