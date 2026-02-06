local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams

local config = {
	[25024] = {
		message = "quests.threatened_dreams.feathers_1", -- Edron
		storage = ThreatenedDreams.Mission01.Feathers1,
	},
	[25025] = {
		message = "quests.threatened_dreams.feathers_2", -- Darasha in City
		storage = ThreatenedDreams.Mission01.Feathers2,
	},
	[25026] = {
		message = "quests.threatened_dreams.feathers_3", -- Darashia Nort of City
		storage = ThreatenedDreams.Mission01.Feathers3,
	},
	[25027] = {
		message = "quests.threatened_dreams.feathers_4", -- Darashia Nort + Far of City
		storage = ThreatenedDreams.Mission01.Feathers4,
	},
	[25028] = {
		message = "quests.threatened_dreams.feathers_5", -- Darashia Nort + Far of City
		storage = ThreatenedDreams.Mission01.Feathers5,
	},
}

local swanFeathers = MoveEvent()
function swanFeathers.onStepIn(creature, item, position, fromPosition)
	local feathersFound = config[item.actionid]
	local player = creature:getPlayer()
	if not player then
		return false
	end
	if player:getStorageValue(ThreatenedDreams.Mission01[1]) ~= 13 then
		return true
	end
	if player:getStorageValue(feathersFound.storage) == 1 then
		return true
	end

	if player:getStorageValue(ThreatenedDreams.Mission01.FeathersCount) < 5 then
		player:setStorageValue(ThreatenedDreams.Mission01.FeathersCount, player:getStorageValue(ThreatenedDreams.Mission01.FeathersCount) + 1)
		player:addItem(25244, 1)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, feathersFound.message)
		player:setStorageValue(feathersFound.storage, 1)
		if player:getStorageValue(ThreatenedDreams.Mission01.FeathersCount) == 5 then
			player:setStorageValue(ThreatenedDreams.Mission01[1], 14) -- Finish the mission
		end
		return true
	end
end

swanFeathers:aid(25024, 25025, 25026, 25027, 25028)
swanFeathers:register()
