-- The Rookie Guard Quest - Mission 04: Home-Brewed

local missionTiles = {
	[50317] = {
		states = 1,
		message = "quests.rookie_guard.m04.not_lily",
		arrowPosition = { x = 32090, y = 32201, z = 7 },
	},
	[50318] = {
		states = 2,
		message = "quests.rookie_guard.m04.not_hyacinth_north",
		arrowPosition = { x = 32090, y = 32190, z = 7 },
	},
	[50320] = {
		states = 2,
		message = "quests.rookie_guard.m04.not_hyacinth_east",
		arrowPosition = { x = 32092, y = 32164, z = 7 },
	},
	[50322] = {
		states = 2,
		message = "quests.rookie_guard.m04.not_hyacinth_stay",
	},
}

-- Mission tutorial tiles

local missionGuide = MoveEvent()

function missionGuide.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04)
	-- Skip if not was started or finished
	if missionState == -1 or missionState > 2 then
		return true
	end
	local missionTile = missionTiles[item.actionid]
	-- Check if the tile is active
	if missionTile.states == missionState then
		-- Check delayed notifications (message/arrow)
		if not isTutorialNotificationDelayed(player) then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, missionTile.message)
			if missionTile.arrowPosition then
				Position(missionTile.arrowPosition):sendMagicEffect(CONST_ME_TUTORIALARROW)
			end
		end
	end
	return true
end

for index, value in pairs(missionTiles) do
	missionGuide:aid(index)
end
missionGuide:register()
