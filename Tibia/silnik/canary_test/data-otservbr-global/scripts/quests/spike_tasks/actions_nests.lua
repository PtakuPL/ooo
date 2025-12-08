local summon = { "Spider", "Larva", "Scarab", "Tarantula" }

local spikeTasksNests = Action()
function spikeTasksNests.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if table.contains({ -1, 5 }, player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main)) then
		return false
	end

	if player:getOutfit().lookType ~= 307 then
		return false
	end

	local sum = player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main) + 1
	player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main, sum)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_nests.msg_1")

	if sum == 5 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_nests.msg_2")
	end

	if math.random(100) > 60 then
		Game.createMonster(summon[math.random(#summon)], player:getPosition())
	end

	item:transform(19210)
	item:decay()
	toPosition:sendMagicEffect(17)
	return true
end

spikeTasksNests:id(19209)
spikeTasksNests:register()
