local monster = {
	["burning gladiator"] = Storage.Quest.U12_20.KilmareshQuest.Thirteen.Fafnar,
	["priestess of the wild sun"] = Storage.Quest.U12_20.KilmareshQuest.Thirteen.Fafnar,
}

local fafnar = CreatureEvent("FafnarMissionsDeath")

function fafnar.onDeath(creature, _corpse, _lastHitKiller, mostDamageKiller)
	local storage = monster[creature:getName():lower()]
	if not storage then
		return false
	end

	onDeathForParty(creature, mostDamageKiller, function(creature, player)
		local kills = player:getStorageValue(storage)
		if kills == 300 and player:getStorageValue(storage) == 1 then
			player:sayLocalized("scripts.creaturescripts_fafnar.say_1", TALKTYPE_MONSTER_SAY, { creature = creature:getName() })
		else
			kills = kills + 1
			player:sayLocalized("scripts.creaturescripts_fafnar.say_2", TALKTYPE_MONSTER_SAY, { creature = creature:getName(), kills = kills })
			player:setStorageValue(storage, kills)
		end
	end)

	return true
end

fafnar:register()
