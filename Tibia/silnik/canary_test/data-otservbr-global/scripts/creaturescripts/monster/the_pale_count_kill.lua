local thePaleCountKill = CreatureEvent("ThePaleCountKill")
function thePaleCountKill.onThink(creature)
	local hp = (creature:getHealth() / creature:getMaxHealth()) * 100
	if hp < 75 then
		creature:sayLocalized("scripts.the_pale_count_kill.say_1", TALKTYPE_MONSTER_SAY)
		creature:remove()
		Game.createMonster("the pale count2", { x = 32972, y = 32419, z = 15 })
	end
	return true
end

thePaleCountKill:register()
