local range = {
	-- Only the Drillworms killed on this area count
	from = Position(32120, 32470, 13),
	to = Position(32345, 32710, 15),
}

local lowerSpikeKill = CreatureEvent("LowerSpikeDeath")
function lowerSpikeKill.onDeath(creature, _corpse, _lastHitKiller, mostDamageKiller)
	if not creature:getPosition():isInRange(range.from, range.to) then
		return true
	end

	onDeathForParty(creature, mostDamageKiller, function(creature, player)
		if not table.contains({ -1, 7 }, player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main)) then
			local sum = player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main) + 1
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main, sum)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.creaturescripts_lower_spike_kill.msg_1", { sum })
			if sum == 7 then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.creaturescripts_lower_spike_kill.msg_2")
			end
		end
	end)
	return true
end

lowerSpikeKill:register()
