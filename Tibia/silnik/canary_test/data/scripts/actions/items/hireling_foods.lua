local hasteCondition = Condition(CONDITION_HASTE)
hasteCondition:setParameter(CONDITION_PARAM_TICKS, 60 * 60 * 1000)
hasteCondition:setParameter(CONDITION_PARAM_SPEED, 80)

local fishingCondition = Condition(CONDITION_ATTRIBUTES)
fishingCondition:setParameter(CONDITION_PARAM_TICKS, 60 * 60 * 1000)
fishingCondition:setParameter(CONDITION_PARAM_SKILL_FISHING, 30)

local magicPointsCondition = Condition(CONDITION_ATTRIBUTES)
magicPointsCondition:setParameter(CONDITION_PARAM_TICKS, 60 * 60 * 1000)
magicPointsCondition:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, 3)

local meleeCondition = Condition(CONDITION_ATTRIBUTES)
meleeCondition:setParameter(CONDITION_PARAM_TICKS, 60 * 60 * 1000)
meleeCondition:setParameter(CONDITION_PARAM_SKILL_MELEE, 3)

local shieldCondition = Condition(CONDITION_ATTRIBUTES)
shieldCondition:setParameter(CONDITION_PARAM_TICKS, 60 * 60 * 1000)
shieldCondition:setParameter(CONDITION_PARAM_SKILL_SHIELD, 7)

local distanceCondition = Condition(CONDITION_ATTRIBUTES)
distanceCondition:setParameter(CONDITION_PARAM_TICKS, 60 * 60 * 1000)
distanceCondition:setParameter(CONDITION_PARAM_SKILL_DISTANCE, 7)

local gourmetDishes = {
	[29408] = { condition = shieldCondition, message = "scripts.hireling_foods.sound_chomp" },
	[29409] = { condition = distanceCondition, message = "scripts.hireling_foods.sound_yummm" },
	[29410] = { condition = magicPointsCondition, message = "scripts.hireling_foods.sound_munch" },
	[29411] = { condition = meleeCondition, message = "scripts.hireling_foods.sound_munch" },
	[29412] = { condition = hasteCondition, message = "scripts.hireling_foods.sound_yummm" },
	[29413] = { condition = fishingCondition, message = "scripts.hireling_foods.sound_mmmmm" },
	[29414] = { healing = true, message = "scripts.hireling_foods.sound_munch" },
	[29415] = { manaRestore = true, message = "scripts.hireling_foods.sound_chomp" },
	[29416] = { message = "scripts.hireling_foods.sound_blurg" },
}

local hirelingFoods = Action()

function hirelingFoods.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local dish = gourmetDishes[item.itemid]
	if not dish then
		return true
	end

	if player:hasExhaustion("special-foods-cooldown") then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "actions.hireling_foods.msg_too_full")
		return true
	end

	if dish.condition then
		player:addCondition(dish.condition)
	elseif dish.healing then
		player:addHealth(player:getMaxHealth() * 0.3)
	elseif dish.manaRestore then
		player:addMana(player:getMaxMana() * 0.3)
	end

	player:sayLocalized(dish.message, TALKTYPE_MONSTER_SAY)
	player:setExhaustion("special-foods-cooldown", 10 * 60)

	item:remove(1)
	return true
end

for index, value in pairs(gourmetDishes) do
	hirelingFoods:id(index)
end

hirelingFoods:register()
