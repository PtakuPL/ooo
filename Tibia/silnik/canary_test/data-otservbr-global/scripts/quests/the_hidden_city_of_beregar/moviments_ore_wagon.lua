local oreWagon = MoveEvent()

function oreWagon.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.OreWagon) ~= 1 then
		player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.OreWagon, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.moviments_ore_wagon.msg_1")
	end
	return true
end

oreWagon:type("stepin")
oreWagon:aid(50091)
oreWagon:register()
