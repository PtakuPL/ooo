local dollsTable = {
	[5080] = { "scripts.dolls.5080_1" },
	[5668] = {
		"scripts.dolls.5668_1",
		"scripts.dolls.5668_2",
		"scripts.dolls.5668_3",
		"scripts.dolls.5668_4",
		"scripts.dolls.5668_5",
		"scripts.dolls.5668_6",
		"scripts.dolls.5668_7",
		"scripts.dolls.5668_8",
		"scripts.dolls.5668_9",
		"scripts.dolls.5668_10",
	},
	[6566] = {
		"scripts.dolls.6566_1",
		"scripts.dolls.6566_2",
		"scripts.dolls.6566_3",
		"scripts.dolls.6566_4",
		"scripts.dolls.6566_5",
	},
	[6387] = { "scripts.dolls.6387_1" },
	[6511] = {
		"scripts.dolls.6511_1",
		"scripts.dolls.6511_2",
		"scripts.dolls.6511_3",
		"scripts.dolls.6511_4",
		"scripts.dolls.6511_5",
		"scripts.dolls.6511_6",
	},
	[8146] = { "scripts.dolls.8146_1" },
	[8149] = {
		"scripts.dolls.8149_1",
		"scripts.dolls.8149_2",
		"scripts.dolls.8149_3",
		"scripts.dolls.8149_4",
		"scripts.dolls.8149_5",
	},
	[8153] = {
		"scripts.dolls.8153_1",
		"scripts.dolls.8153_2",
		"scripts.dolls.8153_3",
		"scripts.dolls.8153_4",
	},
	[8154] = {
		"scripts.dolls.8154_1",
		"scripts.dolls.8154_2",
		"scripts.dolls.8154_3",
	},
	[9144] = {
		"scripts.dolls.9144_1",
		"scripts.dolls.9144_2",
		"scripts.dolls.9144_3",
		"scripts.dolls.9144_4",
	},
	[12043] = {
		"scripts.dolls.12043_1",
		"scripts.dolls.12043_2",
		"scripts.dolls.12043_3",
	},
	[12904] = {
		"scripts.dolls.12904_1",
		"scripts.dolls.12904_2",
		"scripts.dolls.12904_3",
		"scripts.dolls.12904_4",
	},
	[14764] = {
		"scripts.dolls.14764_1",
		"scripts.dolls.14764_2",
	},
	[18343] = {
		"scripts.dolls.18343_1",
		"scripts.dolls.18343_2",
		"scripts.dolls.18343_3",
	},
	[21435] = {
		"scripts.dolls.21435_1",
		"scripts.dolls.21435_2",
		"scripts.dolls.21435_3",
		"scripts.dolls.21435_4",
		"scripts.dolls.21435_5",
		"scripts.dolls.21435_6",
	},
	[21947] = {
		"scripts.dolls.21947_1",
		"scripts.dolls.21947_2",
		"scripts.dolls.21947_3",
		"scripts.dolls.21947_4",
	},
	[21962] = {
		"scripts.dolls.21962_1",
		"scripts.dolls.21962_2",
		"scripts.dolls.21962_3",
		"scripts.dolls.21962_4",
		"scripts.dolls.21962_5",
	},
	[22120] = {
		"scripts.dolls.22120_1",
		"scripts.dolls.22120_2",
		"scripts.dolls.22120_3",
		"scripts.dolls.22120_4",
	},
}

-- Keys that use %s for player name substitution
local dollsWithPlayerName = {
	["scripts.dolls.6387_1"] = true,
	["scripts.dolls.9144_1"] = true,
	["scripts.dolls.12043_3"] = true,
	["scripts.dolls.12904_2"] = true,
	["scripts.dolls.21435_2"] = true,
	["scripts.dolls.21947_3"] = true,
	["scripts.dolls.21962_2"] = true,
	["scripts.dolls.22120_2"] = true,
}

local dolls = Action()

function dolls.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local sounds = dollsTable[item.itemid]
	if not sounds then
		return false
	end

	if fromPosition.x == CONTAINER_POSITION then
		fromPosition = player:getPosition()
	end

	local chance = math.random(#sounds)
	local soundKey = sounds[chance]
	if item.itemid == 5668 then
		fromPosition:sendMagicEffect(CONST_ME_MAGIC_RED)
		item:transform(item.itemid + 1)
		item:decay()
	elseif item.itemid == 6387 then
		fromPosition:sendMagicEffect(CONST_ME_SOUND_YELLOW)
	elseif item.itemid == 6566 then
		if chance == 3 then
			fromPosition:sendMagicEffect(CONST_ME_POFF)
		elseif chance == 4 then
			fromPosition:sendMagicEffect(CONST_ME_FIREAREA)
		elseif chance == 5 then
			player:sendMagicEffect(CONST_ME_EXPLOSIONHIT)
			player:addHealth(-1)
		end
	elseif item.itemid == 9144 then
		item:transform(item.itemid + 1)
		item:decay()
	elseif item.itemid == 12904 then
		item:transform(12905)
		item:decay()
	elseif item.itemid == 14764 then
		item:transform(item.itemid + 1)
		item:decay()
	elseif item.itemid == 21435 then
		item:transform(item.itemid + 1)
		item:decay()
	elseif item.itemid == 22120 then
		item:transform(item.itemid + 1)
		item:decay()
	end

	-- Resolve the localized text, substituting player name if needed
	local args = {}
	if dollsWithPlayerName[soundKey] then
		args = { player:getName() }
	end
	-- sayLocalized(key, type, ghost, target, position, args)
	player:sayLocalized(soundKey, TALKTYPE_MONSTER_SAY, false, nil, fromPosition, args)
	return true
end

for index, value in pairs(dollsTable) do
	dolls:id(index)
end

dolls:register()
