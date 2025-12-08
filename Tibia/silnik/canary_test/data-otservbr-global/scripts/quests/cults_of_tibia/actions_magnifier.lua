local cultsOfTibiaMagnifier = Action()
function cultsOfTibiaMagnifier.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local sqm = Position(33296, 32140, 8)
	local tile = Tile(Position(target:getPosition()))

	if not player then
		return true
	end

	if not target or type(target) ~= "userdata" or not target:isItem() then
		return false
	end

	if target:isCreature() then
		return false
	end

	if table.contains({ 2622, 2601, 2596, 2612, 2618 }, target:getId()) then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_magnifier.msg_1")
		target:getPosition():sendMagicEffect(CONST_ME_POFF)
	elseif target:getPosition() == sqm and target:getId() == 2613 and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 8 then
		target:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission, 9)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_magnifier.msg_2")
	end

	return true
end

cultsOfTibiaMagnifier:id(25306)
cultsOfTibiaMagnifier:register()
