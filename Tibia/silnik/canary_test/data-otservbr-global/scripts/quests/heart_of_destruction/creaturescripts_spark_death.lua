local function setStorage()
	local upConer = { x = 32126, y = 31296, z = 14 } -- upLeftCorner
	local downConer = { x = 32162, y = 31322, z = 14 } -- downRightCorner
	for i = upConer.x, downConer.x do
		for j = upConer.y, downConer.y do
			for k = upConer.z, downConer.z do
				local room = { x = i, y = j, z = k }
				local tile = Tile(room)
				if tile then
					local creatures = tile:getCreatures()
					if creatures and #creatures > 0 then
						for _, creature in pairs(creatures) do
							if creature:isPlayer() and creature:getStorageValue(14324) < 1 then -- hardcoded storges
								creature:setStorageValue(14324, 1) -- Access to boss realityquake
							end
						end
					end
				end
			end
		end
	end
end

local sparkDeath = CreatureEvent("SparkDeath")
function sparkDeath.onDeath(creature)
	if unstableSparksCount < 10 then
		unstableSparksCount = unstableSparksCount + 1
		creature:sayLocalized("scripts.creaturescripts_spark_death.say_2", TALKTYPE_MONSTER_YELL, isInGhostMode, pid, { x = 32143, y = 31308, z = 14 })
	elseif unstableSparksCount == 10 then
		setStorage()
		creature:sayLocalized("scripts.creaturescripts_spark_death.say_1", TALKTYPE_MONSTER_YELL, isInGhostMode, pid, { x = 32143, y = 31308, z = 14 })
		unstableSparksCount = 11
	end
	return true
end

sparkDeath:register()
