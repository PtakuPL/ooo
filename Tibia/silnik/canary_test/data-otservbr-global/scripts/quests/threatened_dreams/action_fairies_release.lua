local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams
local config = {
	[40016] = {
		pos = Position(33576, 32185, 8),
		storage = ThreatenedDreams.Mission02.Fairy01,
		message = "quests.threatened_dreams.fairy_free",
	},
	[40017] = {
		pos = Position(33621, 32214, 8),
		storage = ThreatenedDreams.Mission02.Fairy02,
		message = "quests.threatened_dreams.fairy_free",
	},
	[40018] = {
		pos = Position(33559, 32203, 9),
		storage = ThreatenedDreams.Mission02.Fairy03,
		message = "quests.threatened_dreams.fairy_free",
	},
	[40019] = {
		pos = Position(33505, 32286, 8),
		storage = ThreatenedDreams.Mission02.Fairy04,
		message = "quests.threatened_dreams.fairy_free",
	},
	[40020] = {
		pos = Position(33440, 32217, 8),
		storage = ThreatenedDreams.Mission02.Fairy05,
		message = "quests.threatened_dreams.fairy_free",
	},
}

local function revertFairy(toPosition, item)
	local fairy = Tile(toPosition):getItemById(item)
	if fairy then
		fairy:transform(25796)
	end
end

local fairiesRelease = Action()
function fairiesRelease.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local fairy = config[item.actionid]
	if not fairy then
		return
	end

	local fairiesCounter = player:getStorageValue(ThreatenedDreams.Mission02.FairiesCounter)
	if player:getStorageValue(ThreatenedDreams.Mission02[1]) == 3 and fairiesCounter < 5 then
		if player:getStorageValue(fairy.storage) < 1 then
			item:transform(25797)
			addEvent(revertFairy, 30 * 1000, toPosition, 25797)
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, fairy.message)
			toPosition:sendMagicEffect(CONST_ME_PURPLESMOKE)
			toPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
			player:setStorageValue(fairy.storage, 1)
			if fairiesCounter == -1 then
				player:setStorageValue(ThreatenedDreams.Mission02.FairiesCounter, 1)
			else
				player:setStorageValue(ThreatenedDreams.Mission02.FairiesCounter, fairiesCounter + 1)
			end
			return true
		else
			toPosition:sendMagicEffect(CONST_ME_PURPLESMOKE)
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, fairy.message)
		end
	else
		return false
	end
end

fairiesRelease:aid(40016, 40017, 40018, 40019, 40020)
fairiesRelease:register()
