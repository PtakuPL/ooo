local drunk = Condition(CONDITION_DRUNK)
drunk:setParameter(CONDITION_PARAM_TICKS, 60000)

local poison = Condition(CONDITION_POISON)
poison:setParameter(CONDITION_PARAM_DELAYED, true)
poison:setParameter(CONDITION_PARAM_MINVALUE, -50)
poison:setParameter(CONDITION_PARAM_MAXVALUE, -120)
poison:setParameter(CONDITION_PARAM_STARTVALUE, -5)
poison:setParameter(CONDITION_PARAM_TICKINTERVAL, 4000)
poison:setParameter(CONDITION_PARAM_FORCEUPDATE, true)

local fluidMessage = {
	[1] = "scripts.fluids.msg_1", -- water
	[2] = "scripts.fluids.msg_2", -- wine
	[3] = "scripts.fluids.msg_2", -- beer
	[4] = "scripts.fluids.msg_1", -- mud
	[5] = "scripts.fluids.msg_1", -- blood
	[6] = "scripts.fluids.msg_3", -- slime
	[7] = "scripts.fluids.msg_1", -- oil
	[8] = "scripts.fluids.msg_3", -- urine
	[9] = "scripts.fluids.msg_1", -- milk
	[10] = "scripts.fluids.msg_4", -- manafluid
	[11] = "scripts.fluids.msg_4", -- lifefluid
	[12] = "scripts.fluids.msg_5", -- lemonade
	[13] = "scripts.fluids.msg_2", -- rum
	[14] = "scripts.fluids.msg_5", -- fruit juice
	[15] = "scripts.fluids.msg_5", -- coconut milk
	[16] = "scripts.fluids.msg_2", -- mead
	[17] = "scripts.fluids.msg_1", -- tea
	[18] = "scripts.fluids.msg_3", -- ink
}

local fluid = Action()

function fluid.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local targetItemType = ItemType(target.itemid)
	if targetItemType and targetItemType:isFluidContainer() then
		if target.type == 0 and item.type ~= 0 then
			target:transform(target:getId(), item.type)
			item:transform(item:getId(), 0)
			return true
		elseif target.type ~= 0 and item.type == 0 then
			target:transform(target:getId(), 0)
			item:transform(item:getId(), target.type)
			return true
		end
	end

	if target.itemid == 1 then
		if item.type == 0 then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "actions.fluids.msg_2")
		elseif target.uid == player.uid then
			if table.contains({ 3, 15, 43 }, item.type) then
				player:addCondition(drunk)
			elseif item.type == 4 then
				player:addCondition(poison)
			elseif item.type == 7 then
				player:addMana(math.random(50, 150))
				fromPosition:sendMagicEffect(CONST_ME_MAGIC_BLUE)
			elseif item.type == 10 then
				player:addHealth(60)
				fromPosition:sendMagicEffect(CONST_ME_MAGIC_BLUE)
			end
			player:sayLocalized(fluidMessage[item.type] or "scripts.fluids.gulp", TALKTYPE_MONSTER_SAY)
			item:transform(item:getId(), 0)
		else
			Game.createItem(2886, item.type, toPosition):decay()
			item:transform(item:getId(), 0)
		end
	else
		local fluidSource = targetItemType and targetItemType:getFluidSource() or 0
		if fluidSource ~= 0 then
			item:transform(item:getId(), fluidSource)
		elseif item.type == 0 then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "actions.fluids.msg_1")
		else
			if toPosition.x == CONTAINER_POSITION then
				toPosition = player:getPosition()
			end
			Game.createItem(2886, item.type, toPosition):decay()
			item:transform(item:getId(), 0)
		end
	end

	return true
end

fluid:id(2524, 2873, 2874, 2875, 2876, 2877, 2879, 2880, 2881, 2882, 2883, 2884, 2885, 2893, 2901, 2902, 2903, 2904, 3477, 3478, 3479, 3480)
fluid:register()
