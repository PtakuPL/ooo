local config = {
	{ chance = 30, monster = "Enraged White Deer", i18nKey = "scripts.white_deer_death.say_1" },
	{ chance = 100, monster = "Desperate White Deer", i18nKey = "scripts.white_deer_death.say_2" },
}

local whiteDeerDeath = CreatureEvent("WhiteDeerDeath")

function whiteDeerDeath.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	local targetMonster = creature:getMonster()
	if not targetMonster or targetMonster:getMaster() then
		return true
	end

	local chance = math.random(100)
	for i = 1, #config do
		if chance <= config[i].chance then
			local spawnMonster = Game.createMonster(config[i].monster, targetMonster:getPosition(), true, true)
			if spawnMonster then
				spawnMonster:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				targetMonster:sayLocalized(config[i].i18nKey, TALKTYPE_MONSTER_SAY)
			end
			break
		end
	end
	return true
end

whiteDeerDeath:register()
