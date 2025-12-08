-- This will kick the players in 1 min after the boss is dead AND add the 20 hours delay to go in again
local bossWarzoneDeath = CreatureEvent("BossWarzoneDeath")
function bossWarzoneDeath.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	local info = warzoneConfig.findByName(creature:getName())
	if not info then
		return true
	end

	local spectators = Game.getSpectators(info.center, false, true, info.minRangeX, info.maxRangeX, info.minRangeY, info.maxRangeY)
	for i = 1, #spectators do
		spectators[i]:setBossCooldown(info.boss, os.time() + info.interval)
		spectators[i]:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.loot_warning")
	end
	addEvent(warzoneConfig.resetRoom, 60 * 1000, info, "quests.bigfoot_burden.teleported_out", false)
	return true
end

bossWarzoneDeath:register()
