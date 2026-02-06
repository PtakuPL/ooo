if not FERTILIZED_MUSHROOMS then
	FERTILIZED_MUSHROOMS = {}
end

local spikeTasksFertilizer = Action()
function spikeTasksFertilizer.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if table.contains({ -1, 4 }, player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main)) then
		return false
	end

	if not target or type(target) ~= "userdata" or not target:isItem() or (target:getId() ~= 19215) then
		return false
	end

	if not FERTILIZED_MUSHROOMS[player:getGuid()] then
		FERTILIZED_MUSHROOMS[player:getGuid()] = {}
	end

	local mushPos = Position(toPosition.x, toPosition.y, toPosition.z)
	if table.contains(FERTILIZED_MUSHROOMS[player:getGuid()], mushPos) then
		return player:sendLocalizedCancelMessage("quests.spike_tasks.you_have_already_fertilised_this_mushroom")
	end

	table.insert(FERTILIZED_MUSHROOMS[player:getGuid()], mushPos)
	local sum = player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main) + 1
	player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main, sum)

	if sum == 4 then
		item:remove()
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_fertilizer.msg_1")
	end
	return toPosition:sendMagicEffect(46)
end

spikeTasksFertilizer:id(19214)
spikeTasksFertilizer:register()
