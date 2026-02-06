local templeScroll = Action()

function templeScroll.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local inPz = player:getTile():hasFlag(TILESTATE_PROTECTIONZONE)
	local inFight = player:isPzLocked() or player:getCondition(CONDITION_INFIGHT, CONDITIONID_DEFAULT)
	if inPz or not inFight then
		fromPosition:sendMagicEffect(CONST_ME_TELEPORT)
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		item:remove()
	else
		player:sendLocalizedCancelMessage("quests.actions.you_cant_use_this_when_youre")
		fromPosition:sendMagicEffect(CONST_ME_POFF)
	end
	return true
end

templeScroll:id(25718)
templeScroll:register()
