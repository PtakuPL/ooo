local function revertMachine(position, itemId, transformId)
	local item = Tile(position):getItemById(itemId)
	if item then
		item:transform(transformId)
	end
	Game.setStorageValue(GlobalStorage.HeroRathleton.FourthMachines, Game.getStorageValue(GlobalStorage.HeroRathleton.FourthMachines) - 1)
end

local heroRathletonLava = Action()
function heroRathletonLava.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.itemid ~= 21743 then
		return false
	end

	if Game.getStorageValue(GlobalStorage.HeroRathleton.LavaRunning) >= 1 then
		player:sayLocalized("scripts.actions_machines_lava.say_3", TALKTYPE_MONSTER_SAY, false, nil, toPosition)
		return true
	end

	if Game.getStorageValue(GlobalStorage.HeroRathleton.FourthMachines) == 7 then
		player:sayLocalized("scripts.actions_machines_lava.say_2", TALKTYPE_MONSTER_SAY)
	end

	item:transform(21744)
	addEvent(revertMachine, 10 * 60 * 1000, toPosition, 21744, 21743)
	Game.setStorageValue(GlobalStorage.HeroRathleton.FourthMachines, Game.getStorageValue(GlobalStorage.HeroRathleton.FourthMachines) + 1)
	player:sayLocalized("scripts.actions_machines_lava.say_1", TALKTYPE_MONSTER_SAY, false, nil, toPosition)
	return true
end

heroRathletonLava:aid(24865)
heroRathletonLava:register()
