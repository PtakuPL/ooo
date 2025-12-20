local whiteDeerScoutsDeath = CreatureEvent("WhiteDeerScoutsDeath")

function whiteDeerScoutsDeath.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	local targetMonster = creature:getMonster()
	if not targetMonster or targetMonster:getMaster() then
		return true
	end

	local chance = math.random(100)
	if chance <= 10 then
		for i = 1, 2 do
			local spawnMonster = Game.createMonster("Elf Scout", targetMonster:getPosition(), true, true)
			if spawnMonster then
				spawnMonster:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			end
		end

		targetMonster:sayLocalized("scripts.white_deer_scouts.say_1", TALKTYPE_MONSTER_SAY)
	end
	return true
end

whiteDeerScoutsDeath:register()
