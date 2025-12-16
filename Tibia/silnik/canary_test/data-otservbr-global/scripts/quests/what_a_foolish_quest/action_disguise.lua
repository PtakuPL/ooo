local condition = Condition(CONDITION_OUTFIT)
condition:setTicks(10000)
condition:setOutfit({ lookType = 65 })

local whatFoolishDisguise = Action()
function whatFoolishDisguise.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	player:addCondition(condition)
	player:sayLocalized("scripts.action_disguise.say_1", TALKTYPE_MONSTER_SAY)
	return true
end

whatFoolishDisguise:id(144)
whatFoolishDisguise:register()
