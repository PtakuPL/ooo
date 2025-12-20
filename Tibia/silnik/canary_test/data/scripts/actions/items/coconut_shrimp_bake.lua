local coconutShrimpBake = Action()

function coconutShrimpBake.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:hasExhaustion("special-foods-cooldown") then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.coconut_shrimp_bake.msg_1")
		return true
	end

	local headItem = player:getSlotItem(CONST_SLOT_HEAD)
	if not headItem then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.coconut_shrimp_bake.msg_2")
		return true
	end

	local acceptableHelmets = { 5460, 11585, 13995 }
	if not table.contains(acceptableHelmets, headItem:getId()) then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.coconut_shrimp_bake.msg_3")
		return true
	end

	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.coconut_shrimp_bake.msg_4" .. headItem:getName() .. " has increased for twenty-four hours.")
	player:sayLocalized("scripts.coconut_shrimp_bake.say_1", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	player:setExhaustion("special-foods-cooldown", 10 * 60)
	player:setExhaustion("coconut-shrimp-bake", 24 * 60 * 60)
	item:remove(1)
	return true
end

coconutShrimpBake:id(11584)
coconutShrimpBake:register()
