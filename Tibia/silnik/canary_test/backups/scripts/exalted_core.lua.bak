local exaltedCore = Action()

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

function exaltedCore.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local itemName = target:getName()
	local monsterName = SoulPit.getSoulCoreMonster(itemName)

	if not monsterName then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.exalted_core.msg_1")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local monsterType = MonsterType(monsterName)
	if not monsterType then
		player:sendLocalizedMessage(MESSAGE_GAME_HIGHLIGHT, "scripts.exalted_core.msg_2")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local currentDifficulty = monsterType:BestiaryStars()
	local previousDifficultyLevel = getPreviousDifficultyLevel(currentDifficulty)
	local previousDifficultyMonsters = nil

	if previousDifficultyLevel then
		previousDifficultyMonsters = Game.getMonstersByBestiaryStars(SoulPit.SoulCoresConfiguration.monstersDifficulties[previousDifficultyLevel])
	else
		previousDifficultyLevel = currentDifficulty
		previousDifficultyMonsters = Game.getMonstersByBestiaryStars(SoulPit.SoulCoresConfiguration.monstersDifficulties[currentDifficulty])
	end

	if #previousDifficultyMonsters == 0 then
		player:sendLocalizedMessage(MESSAGE_GAME_HIGHLIGHT, "scripts.exalted_core.msg_3")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local newMonsterType = previousDifficultyMonsters[math.random(#previousDifficultyMonsters)]
	local newSoulCoreItem = getSoulCoreItemForMonster(newMonsterType:getName())
	if not newSoulCoreItem then -- Retry a second time.
		newSoulCoreItem = getSoulCoreItemForMonster(newMonsterType:getName())
		if not newSoulCoreItem then
			player:sendLocalizedMessage(MESSAGE_GAME_HIGHLIGHT, "scripts.exalted_core.msg_4")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end

	if player:getFreeCapacity() < ItemType(newSoulCoreItem):getWeight() then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.exalted_core.msg_5")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	player:addItem(newSoulCoreItem, 1)
	target:remove(1)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You have received a %s soul core.", newMonsterType:getName()))
	item:remove(1)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end

exaltedCore:id(37110)
exaltedCore:register()
