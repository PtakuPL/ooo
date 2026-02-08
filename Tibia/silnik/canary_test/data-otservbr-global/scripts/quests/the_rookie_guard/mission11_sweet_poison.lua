-- The Rookie Guard Quest - Mission 11: Sweet Poison

local missionTiles = {
	[50350] = {
		state = 1,
		message = "quests.rookie_guard.m11.wasps_nest",
		arrowPosition = { x = 32090, y = 32147, z = 7 },
	},
	[50353] = {
		state = 1,
		newState = 2,
		message = "quests.rookie_guard.m11.wasp_tower",
	},
}

-- Mission tutorial tiles

local missionGuide = MoveEvent()

function missionGuide.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11)
	-- Skip if not was started or finished
	if missionState == -1 or missionState > 1 then
		return true
	end
	local missionTile = missionTiles[item.actionid]
	-- Check if the tile is active
	if missionState == missionTile.state then
		-- Check delayed notifications (message/arrow)
		if not isTutorialNotificationDelayed(player) then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, missionTile.message)
			if missionTile.arrowPosition then
				Position(missionTile.arrowPosition):sendMagicEffect(CONST_ME_TUTORIALARROW)
			end
		end
		if missionTile.newState then
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11, missionTile.newState)
		end
	end
	return true
end

for index, value in pairs(missionTiles) do
	missionGuide:aid(index)
end
missionGuide:register()

-- Special flask (gather poison on wasp corpse)

local specialFlask = Action()

function specialFlask.onUse(player, item, frompos, item2, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11)
	if missionState == 2 and item2.itemid == 5989 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission11_sweet_poison.msg_1")
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11, 3)
		player:removeItem(12785, 1)
		player:addItemEx(Game.createItem(12784, 1), true, CONST_SLOT_WHEREEVER)
	end
	return true
end

specialFlask:id(12785)
specialFlask:register()
