local soulPrism = Action()

local function getNextDifficultyLevel(currentLevel)
	for level, value in pairs(SoulPit.SoulCoresConfiguration.monstersDifficulties) do
		if value == currentLevel + 1 then
			return level
		end
	end
	return nil
end

local function getPreviousDifficultyLevel(currentLevel)
	for level, value in pairs(SoulPit.SoulCoresConfiguration.monstersDifficulties) do
		if value == currentLevel - 1 then
			return level
		end
	end
	return nil
end

local function getSoulCoreItemForMonster(monsterName)
	local lowerMonsterName = monsterName:lower()
	local soulCoreName = SoulPit.SoulCoresConfiguration.monsterVariationsSoulCore[monsterName]

	if soulCoreName then
		local newSoulCoreId = getItemIdByName(soulCoreName)
		if newSoulCoreId then
			return newSoulCoreId
		end
	else
		local newMonsterSoulCore = string.format("%s soul core", monsterName)
		local newSoulCoreId = getItemIdByName(newMonsterSoulCore)
		if newSoulCoreId then
			return newSoulCoreId
		end
	end

	return false
end

function soulPrism.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local itemName = target:getName()
	local monsterName = SoulPit.getSoulCoreMonster(itemName)

	if not monsterName then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.soul_prism.msg_1")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local monsterType = MonsterType(monsterName)
	if not monsterType then
		player:sendLocalizedMessage(MESSAGE_GAME_HIGHLIGHT, "scripts.soul_prism.msg_2")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local currentDifficulty = monsterType:BestiaryStars()
	local nextDifficultyLevel = getNextDifficultyLevel(currentDifficulty)
	local nextDifficultyMonsters = nil

	if nextDifficultyLevel then
		nextDifficultyMonsters = Game.getMonstersByBestiaryStars(SoulPit.SoulCoresConfiguration.monstersDifficulties[nextDifficultyLevel])
	else
		nextDifficultyLevel = currentDifficulty
		nextDifficultyMonsters = Game.getMonstersByBestiaryStars(SoulPit.SoulCoresConfiguration.monstersDifficulties[currentDifficulty])
	end

	if #nextDifficultyMonsters == 0 then
		player:sendLocalizedMessage(MESSAGE_GAME_HIGHLIGHT, "scripts.soul_prism.msg_3")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local newMonsterType = nextDifficultyMonsters[math.random(#nextDifficultyMonsters)]
	local newSoulCoreItem = getSoulCoreItemForMonster(newMonsterType:getName())
	if not newSoulCoreItem then -- Retry a second time.
		newSoulCoreItem = getSoulCoreItemForMonster(newMonsterType:getName())
		if not newSoulCoreItem then
			player:sendLocalizedMessage(MESSAGE_GAME_HIGHLIGHT, "scripts.soul_prism.msg_4")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end

	if player:getFreeCapacity() < ItemType(newSoulCoreItem):getWeight() then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.soul_prism.msg_5")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if math.random(100) <= SoulPit.SoulCoresConfiguration.chanceToGetOminousSoulCore then
		player:addItem(49163, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.soul_prism.msg_6")
	else
		player:addItem(newSoulCoreItem, 1)
		target:remove(1)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.soul_prism.msg_1", {newMonsterType:getName()})
	end
	item:remove(1)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end

soulPrism:id(49164)
soulPrism:register()
