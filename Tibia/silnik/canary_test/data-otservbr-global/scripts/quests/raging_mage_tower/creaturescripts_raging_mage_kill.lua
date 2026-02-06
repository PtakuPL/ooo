local deathEvent = CreatureEvent("RagingMageDeath")

function deathEvent.onDeath(creature)
	Game.broadcastLocalizedMessage("quests.creaturescripts_raging_mage_kill.broadcast_2", MESSAGE_EVENT_ADVANCE)
	creature:sayLocalized("scripts.raging_mage.death_say", TALKTYPE_MONSTER_SAY)

	addEvent(function()
		Game.broadcastLocalizedMessage("quests.creaturescripts_raging_mage_kill.broadcast_1", MESSAGE_EVENT_ADVANCE)
		local tile = Tile(Position({ x = 33143, y = 31527, z = 2 }))
		if tile then
			local item = tile:getItemById(11796)
			if item then
				item:remove(1)
			end
		end
	end, 5 * 60 * 1000)
	return true
end

deathEvent:register()
