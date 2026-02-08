-- The Rookie Guard Quest - Mission 02: Defence!

local CATAPULT_ID = {
	BAR = 1,
	ACADEMY_1 = 2,
	ACADEMY_2 = 4,
	SHOP = 8,
}

local missionTiles = {
	[50313] = {
		states = { 1 },
		message = "quests.rookie_guard.m02.house_vascalir",
		arrowPosition = { x = 32082, y = 32189, z = 7 },
	},
	[50314] = {
		states = { 2, 3 },
		message = "quests.rookie_guard.m02.norma_bar",
		arrowPosition = { x = 32097, y = 32184, z = 7 },
		catapults = { CATAPULT_ID.BAR },
	},
	[50315] = {
		states = { 2, 3 },
		message = "quests.rookie_guard.m02.academy_roof",
		arrowPosition = { x = 32098, y = 32190, z = 7 },
		catapults = { CATAPULT_ID.ACADEMY_1, CATAPULT_ID.ACADEMY_2 },
	},
	[50316] = {
		states = { 2, 3 },
		message = "quests.rookie_guard.m02.obi_shop",
		arrowPosition = { x = 32104, y = 32205, z = 7 },
		catapults = { CATAPULT_ID.SHOP },
	},
}

-- Mission tutorial tiles

local missionGuide = MoveEvent()

function missionGuide.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02)
	-- Skip if not was started or finished
	if missionState == -1 or missionState >= 4 then
		return true
	end
	local missionTile = missionTiles[item.actionid]
	-- Check if the tile has bound a catapult(s)
	local hasUsedCatapult = missionTile.catapults ~= nil or false
	if hasUsedCatapult then
		local catapultsState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Catapults)
		for i = 1, #missionTile.catapults do
			-- Check if the catapult was used
			hasUsedCatapult = testFlag(catapultsState, missionTile.catapults[i])
			if hasUsedCatapult then
				break
			end
		end
	end
	-- Check if the tile is active
	if table.find(missionTile.states, missionState) and not hasUsedCatapult then
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

-- Stone pile (gather heavy stone)

local stonePile = Action()

function stonePile.onUse(player, item, frompos, item2, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02)
	-- Skip if not was started
	if missionState == -1 then
		return true
	end
	if missionState <= 3 then
		if missionState == 1 then
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02, 2)
		end
		-- Gather delay
		if player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.StonePileTimer) - os.time() <= 0 then
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.StonePileTimer, os.time() + 2 * 60)
			player:addItemEx(Game.createItem(12724, 1), true, CONST_SLOT_WHEREEVER)
		else
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission02_defence.msg_1")
		end
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission02_defence.msg_2")
	end
	return true
end

stonePile:aid(40005)
stonePile:register()

local catapults = {
	[40006] = CATAPULT_ID.BAR,
	[40007] = CATAPULT_ID.ACADEMY_1,
	[40008] = CATAPULT_ID.ACADEMY_2,
	[40009] = CATAPULT_ID.SHOP,
}

-- Heavy stone (load stone on catapult)

local heavyStone = Action()

function heavyStone.onUse(player, item, frompos, item2, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02)
	if missionState >= 2 and missionState <= 3 and catapults[item2.actionid] then
		local catapultsState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Catapults)
		local hasUsedCatapult = testFlag(catapultsState, catapults[item2.actionid])
		if not hasUsedCatapult then
			if missionState == 2 then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission02_defence.msg_3")
			elseif missionState == 3 then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission02_defence.msg_4")
			end
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02, missionState + 1)
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Catapults, catapultsState + catapults[item2.actionid])
			player:addExperience(5, true)
			player:removeItem(12724, 1)
		else
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission02_defence.msg_5")
		end
	end
	return true
end

heavyStone:id(12724)
heavyStone:register()
