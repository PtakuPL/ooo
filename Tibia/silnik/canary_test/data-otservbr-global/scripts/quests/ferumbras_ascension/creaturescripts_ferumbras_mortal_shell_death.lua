local ferumbrasMortalShell = CreatureEvent("FerumbrasMortalShell")

local config = AscendingFerumbrasConfig

function ferumbrasMortalShell.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if creature:getName():lower() ~= "destabilized ferumbras" then
		return true
	end

	local monster = Game.createMonster("Ferumbras Mortal Shell", config.bossPos, true, true)
	if not monster then
		return true
	end
	monster:sayLocalized("scripts.creaturescripts_ferumbras_mortal_shell_death.say_2", TALKTYPE_MONSTER_SAY)
	lasthitkiller:sayLocalized("scripts.creaturescripts_ferumbras_mortal_shell_death.say_1", TALKTYPE_MONSTER_SAY, nil, nil, config.bossPos)
	return true
end

ferumbrasMortalShell:register()
