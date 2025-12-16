local function revertMachine(position, itemId, transformId)
	local item = Tile(position):getItemById(itemId)
	if item then
		item:transform(transformId)
	end
	Game.setStorageValue(GlobalStorage.HeroRathleton.SecondMachines, Game.getStorageValue(GlobalStorage.HeroRathleton.SecondMachines) - 1)
end

local heroRathletonGlooth = Action()
function heroRathletonGlooth.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.itemid ~= 21743 then
		return false
	end

	if Game.getStorageValue(GlobalStorage.HeroRathleton.DeepTerrorRunning) >= 1 then
		player:sayLocalized("scripts.actions_machines_glooth_horror.say_3", TALKTYPE_MONSTER_SAY, false, nil, toPosition)
		return true
	end

	if Game.getStorageValue(GlobalStorage.HeroRathleton.SecondMachines) == 7 then
		player:sayLocalized("scripts.actions_machines_glooth_horror.say_2", TALKTYPE_MONSTER_SAY)
	end

	item:transform(21744)
	addEvent(revertMachine, 10 * 60 * 1000, toPosition, 21744, 21743)
	Game.setStorageValue(GlobalStorage.HeroRathleton.SecondMachines, Game.getStorageValue(GlobalStorage.HeroRathleton.SecondMachines) + 1)
	player:sayLocalized("scripts.actions_machines_glooth_horror.say_1", TALKTYPE_MONSTER_SAY, false, nil, toPosition)
	return true
end

heroRathletonGlooth:aid(24863)
heroRathletonGlooth:register()
