local chance = {
	{ 90, "quests.spike_tasks.spirit_anger", "Enraged Soul" },
	{ 80, "quests.spike_tasks.ancient_ghost", "Ghost" },
	{ 70, "quests.spike_tasks.undead_creature", "Demon Skeleton" },
	{ 50, "quests.spike_tasks.undead_creature", "Zombie" },
	{ 1, "quests.spike_tasks.nothing_special" },
}

local spikeTasksShovel = Action()
function spikeTasksShovel.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if table.contains({ -1, 1 }, player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main)) then
		return player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	end

	if not target or type(target) ~= "userdata" or not target:isItem() or (target:getId() ~= 19211) then
		return player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	end

	target:transform(19212)
	target:decay()
	local luck = math.random(100)
	for i, result in ipairs(chance) do
		if luck >= result[1] then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, result[2])
			if result[3] then
				Game.createMonster(result[3], toPosition)
			end
			if i == 1 then
				local sum = player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main) + 1
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main, sum)
				if sum == 1 then
					item:remove()
					player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_spirit_shovel.msg_1")
				end
			end
			break
		end
	end
	return toPosition:sendMagicEffect(35)
end

spikeTasksShovel:id(19203)
spikeTasksShovel:register()
