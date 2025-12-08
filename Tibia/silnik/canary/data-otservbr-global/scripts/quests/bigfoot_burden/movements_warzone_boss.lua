local function filter(list, f, i)
	if i < #list then
		if f(list[i]) then
			return list[i], filter(list, f, i + 1)
		else
			return filter(list, f, i + 1)
		end
	elseif list[i] and f(list[i]) then
		return list[i]
	end
end

local function spawnBoss(inf)
	local boss = Game.createMonster(inf.boss, inf.bossResp)
	boss:registerEvent("BossWarzoneDeath")
end

local warzoneBoss = MoveEvent()

function warzoneBoss.onStepIn(creature, item, pos, fromPosition)
	if not creature:isPlayer() then
		creature:teleportTo(fromPosition)
		return false
	end

	local warzone = warzoneConfig[item:getActionId()]
	if not warzone then
		return false
	end

	if not creature:canFightBoss(warzone.boss) then
		local hoursLeft = math.ceil(creature:getBossCooldown(warzone.boss) / 3600)
		creature:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.warzone_cleared", hoursLeft)
		creature:teleportTo(fromPosition)
		return false
	end

	if warzone.locked then
		creature:sendLocalizedTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"quests.bigfoot_burden.room_wait"
		)
		creature:teleportTo(fromPosition)
		return true
	end

	creature:teleportTo(warzone.teleportTo)
	creature:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.boss_challenge", warzone.boss)
	return true
end

warzoneBoss:type("stepin")
warzoneBoss:aid(45700, 45701, 45702)
warzoneBoss:register()
