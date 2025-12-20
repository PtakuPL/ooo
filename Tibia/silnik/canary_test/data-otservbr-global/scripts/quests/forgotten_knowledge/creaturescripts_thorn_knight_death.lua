local function checkBlood(position)
	local tile = Tile(position)
	local items = tile:getItems()
	for i = 1, #items do
		local item = items[i]
		if not ItemType(item):isMovable() then
			item:remove()
		end
	end
end
local thornKnightDeath = CreatureEvent("ThornKnightDeath")
function thornKnightDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if creature:getName():lower() == "mounted thorn knight" then
		creature:sayLocalized("scripts.creaturescripts_thorn_knight_death.say_1", TALKTYPE_MONSTER_SAY)
		Game.createMonster("the shielded thorn knight", creature:getPosition(), true, true)
		Game.createMonster("thorn steed", creature:getPosition(), false, true)
		addEvent(checkBlood, 1, creature:getPosition())
		return true
	elseif creature:getName():lower() == "the shielded thorn knight" then
		Game.createMonster("the enraged thorn knight", creature:getPosition(), true, true)
		addEvent(checkBlood, 1, creature:getPosition())
		return true
	end
	return true
end

thornKnightDeath:register()
