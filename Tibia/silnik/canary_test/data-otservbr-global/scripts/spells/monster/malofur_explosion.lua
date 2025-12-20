local BOOOM = Combat()
BOOOM:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
BOOOM:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_GROUNDSHAKER)
BOOOM:setFormula(COMBAT_FORMULA_DAMAGE, -200, -600, -10000, -20000)
BOOOM:setArea(createCombatArea({
	{ 0, 1, 1, 1, 0 },
	{ 0, 1, 3, 1, 0 },
	{ 0, 1, 1, 1, 0 },
}))

local BOOOOM = Combat()
BOOOOM:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
BOOOOM:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_GROUNDSHAKER)
BOOOOM:setFormula(COMBAT_FORMULA_DAMAGE, -200, -600, -10000, -20000)
BOOOOM:setArea(createCombatArea({
	{ 0, 0, 0, 0, 0, 0, 0 },
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 0, 1, 1, 3, 1, 1, 0 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 0, 0, 0, 0, 0, 0 },
}))

local BOOOOOM = Combat()
BOOOOOM:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
BOOOOOM:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_GROUNDSHAKER)
BOOOOOM:setFormula(COMBAT_FORMULA_DAMAGE, -200, -600, -10000, -20000)
BOOOOOM:setArea(createCombatArea({
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 3, 1, 1, 1 },
	{ 1, 1, 1, 1, 1, 1, 1 },
	{ 0, 1, 1, 1, 1, 1, 0 },
	{ 0, 0, 1, 1, 1, 0, 0 },
}))

local BOOOOOOM = Combat()
BOOOOOOM:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
BOOOOOOM:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_GROUNDSHAKER)
BOOOOOOM:setFormula(COMBAT_FORMULA_DAMAGE, -200, -600, -10000, -20000)
BOOOOOOM:setArea(createCombatArea({
	{ 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0 },
	{ 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0 },
	{ 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1 },
	{ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
	{ 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
	{ 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0 },
	{ 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 },
}))

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	if not creature:isMonster() then
		return false
	end

	local exaust = math.random(11, 41)

	if creature:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.Malofur) ~= 1 then
		creature:sayLocalized("scripts.malofur_explosion.say_6", TALKTYPE_MONSTER_SAY)
		creature:sayLocalized("scripts.malofur_explosion.say_5", TALKTYPE_MONSTER_SAY)
		creature:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.Malofur, 1)

		addEvent(function(cid)
			local c = Creature(cid)
			if c then
				local var = Variant(c:getPosition())
				BOOOM:execute(c, var)
				c:sayLocalized("scripts.malofur_explosion.say_4", TALKTYPE_MONSTER_SAY)
			end
		end, 3 * 1000, creature:getId())

		addEvent(function(cid)
			local c = Creature(cid)
			if c then
				local var = Variant(c:getPosition())
				BOOOOM:execute(c, var)
				c:sayLocalized("scripts.malofur_explosion.say_3", TALKTYPE_MONSTER_SAY)
			end
		end, 5 * 1000, creature:getId())

		addEvent(function(cid)
			local c = Creature(cid)
			if c then
				local var = Variant(c:getPosition())
				BOOOOOM:execute(c, var)
				c:sayLocalized("scripts.malofur_explosion.say_2", TALKTYPE_MONSTER_SAY)
			end
		end, 7 * 1000, creature:getId())

		addEvent(function(cid)
			local c = Creature(cid)
			if c then
				local var = Variant(c:getPosition())
				BOOOOOOM:execute(c, var)
				c:sayLocalized("scripts.malofur_explosion.say_1", TALKTYPE_MONSTER_SAY)
			end
		end, 9 * 1000, creature:getId())

		addEvent(function(cid)
			local c = Creature(cid)
			if c then
				c:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.Malofur, 0)
			end
		end, exaust * 1000, creature:getId())
	end

	return true
end

spell:name("malofur explosion")
spell:words("###559")
spell:isAggressive(false)
spell:blockWalls(true)
spell:needTarget(false)
spell:needLearn(true)
spell:register()
