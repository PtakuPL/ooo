local stringOfMending = Action()

function stringOfMending.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or target.itemid ~= 12737 then
		return false
	end

	local random = math.random(100)
	if random <= 50 then
		target:transform(20182) -- ring of ending
		target:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		item:remove(1)
		return true
	end

	target:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
	item:remove(1)
	target:remove()
	player:sayLocalized("scripts.string_of_mending.say_1", TALKTYPE_MONSTER_SAY)
	return true
end

stringOfMending:id(20208)
stringOfMending:register()
