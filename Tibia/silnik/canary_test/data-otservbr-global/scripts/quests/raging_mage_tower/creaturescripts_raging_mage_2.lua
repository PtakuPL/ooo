local ragingMage2 = CreatureEvent("RagingMage2")
function ragingMage2.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	Game.broadcastLocalizedMessage("quests.creaturescripts_raging_mage_2.broadcast_2", MESSAGE_EVENT_ADVANCE)
	creature:sayLocalized("scripts.creaturescripts_raging_mage_2.say_1", TALKTYPE_MONSTER_SAY, 0, 0, Position(33142, 31529, 2))
	addEvent(function()
		local tilePos = Tile(Position(33143, 31527, 2)):getItemById(10840)
		if not tilePos then
			return true
		end
		tilePos:remove()
		Game.broadcastLocalizedMessage("quests.creaturescripts_raging_mage_2.broadcast_1", MESSAGE_EVENT_ADVANCE)
	end, 5 * 60 * 1000)
	mostDamageKiller:setStorageValue(673004, 0)
	Game.setStorageValue(775559, 0)
	return true
end

ragingMage2:register()
