local function sendConditionCults(playerId, info, fromPos, toPos, fromPos2, toPos2, time)
	local player = Player(playerId)
	if not player then
		return false
	end

	if not player:getPosition():isInRange(fromPos2, toPos2) then
		if not player:getPosition():isInRange(fromPos, toPos) then
			return true
		end
	end

	time = time + 2
	if time == 30 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, info.msgs[2])
	elseif time == 60 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, info.msgs[2])
	elseif time == 90 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, info.msgs[2])
	elseif time >= 120 then
		local storage = player:getStorageValue(info.storageBarkless) < 0 and 0 or player:getStorageValue(info.storageBarkless)
		if storage < 3 and storage ~= 1 and storage ~= 2 then
			if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Barkless.Sulphur) == 3 and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Barkless.Tar) == 3 then
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, info.msgs[3])
				player:setStorageValue(info.storageBarkless, 1)
			else
				return true
			end
		end
	end
	player:getPosition():sendMagicEffect(info.effect)
	addEvent(sendConditionCults, 2000, playerId, info, fromPos, toPos, fromPos2, toPos2, time)
end

local function floorPassage(playerId, info, time)
	local player = Player(playerId)
	if not player then
		return true
	end
	local storage = player:getStorageValue(info.storageBarkless) < 0 and 0 or player:getStorageValue(info.storageBarkless)
	if time == 0 and storage < 3 then
		player:setStorageValue(info.storageBarkless, 0)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, info.msgs[6])
		return true
	end
	if storage == 3 then
		return true
	end
	addEvent(floorPassage, 1000, playerId, info, time - 1)
end

local ice = MoveEvent()

function ice.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local setting = {
		fromPos = Position(32677, 31393, 8),
		toPos = Position(32722, 31440, 8),
		fromPos2 = Position(32696, 31429, 8),
		toPos2 = Position(32728, 31435, 8),
		effect = CONST_ME_GIANTICE,
		firstTile = Position(32698, 31405, 8),
		storageBarkless = Storage.Quest.U11_40.CultsOfTibia.Barkless.Ice,
		msgs = {
			"quests.cults_of_tibia.ice.msg_1", -- on enter
			"quests.cults_of_tibia.ice.msg_2", -- 30/60/90 seconds
			"quests.cults_of_tibia.ice.msg_3", -- 120 seconds
			"quests.cults_of_tibia.ice.msg_4", -- step on the first tile
			"quests.cults_of_tibia.ice.msg_5", -- step on the second tile
			"quests.cults_of_tibia.ice.msg_6", -- didn't step in time
		},
	}
	if fromPosition.y == 31441 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, setting.msgs[1])
		sendConditionCults(player:getId(), setting, setting.fromPos, setting.toPos, setting.fromPos2, setting.toPos2, 0)
		return true
	end

	if item:getPosition():compare(setting.firstTile) then
		if player:getStorageValue(setting.storageBarkless) ~= 1 then
			return true
		end
		player:setStorageValue(setting.storageBarkless, 2)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, setting.msgs[4])
		floorPassage(player:getId(), setting, 60)
		return true
	end

	if fromPosition.y == 31439 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_ice.msg_1")
		return true
	end
	return true
end

ice:type("stepin")
ice:aid(5532)
ice:register()
