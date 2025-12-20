local creatureevent = CreatureEvent("GiantSpiderWyda")

function creatureevent.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	creature:sayLocalized("scripts.giant_spider_wyda_death.say_1", TALKTYPE_MONSTER_SAY)

	if mostDamageKiller:isPlayer() then
		mostDamageKiller:addAchievement("Someone's Bored")
	end
	return true
end

creatureevent:register()
