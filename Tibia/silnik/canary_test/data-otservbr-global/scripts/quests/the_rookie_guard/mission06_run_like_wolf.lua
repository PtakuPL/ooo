-- The Rookie Guard Quest - Mission 06: Run Like a Wolf

local missionTiles = {
	[50329] = {
		state = 2,
		messageKey = "scripts.mission06_run_like_wolf.tile_1",
		arrowPosition = { x = 32109, y = 32166, z = 7 },
	},
	[50330] = {
		state = 2,
		messageKey = "scripts.mission06_run_like_wolf.tile_2",
	},
	[50331] = {
		state = 2,
		messageKey = "scripts.mission06_run_like_wolf.tile_3",
	},
	[50332] = {
		state = 2,
		messageKey = "scripts.mission06_run_like_wolf.tile_4",
		arrowPosition = { x = 32138, y = 32132, z = 7 },
	},
	[50333] = {
		state = 3,
		messageKey = "scripts.mission06_run_like_wolf.tile_5",
	},
}

-- Mission tutorial tiles

local missionGuide = MoveEvent()

function missionGuide.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06)
	-- Skip if not was started or finished
	if missionState == -1 or missionState >= 4 then
		return true
	end
	local tile = missionTiles[item.actionid]
	-- Check if the tile is active
	if missionState == tile.state then
		-- Check delayed notifications (message/arrow)
		if not isTutorialNotificationDelayed(player) then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, tile.messageKey)
			if tile.arrowPosition then
				Position(tile.arrowPosition):sendMagicEffect(CONST_ME_TUTORIALARROW)
			end
		end
	end
	return true
end

for index, value in pairs(missionTiles) do
	missionGuide:aid(index)
end
missionGuide:register()

-- War wolf den hole

local warWolfDenHole = MoveEvent()

function warWolfDenHole.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06)
	if missionState == -1 or missionState >= 4 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission06_run_like_wolf.msg_1")
		player:teleportTo(fromPosition, true)
	end
	return true
end

warWolfDenHole:uid(25024)
warWolfDenHole:register()

local specialMissionTiles = {
	[25025] = {
		state = 2,
		messageKey = "scripts.mission06_run_like_wolf.special_1",
		arrowPosition = { x = 32135, y = 32133, z = 8 },
		newState = 3,
	},
	[25026] = {
		state = 3,
		messageKey = "scripts.mission06_run_like_wolf.special_2",
		arrowPosition = { x = 32108, y = 32132, z = 11 },
	},
	[25027] = {
		state = 5,
		messageKey = "scripts.mission06_run_like_wolf.special_3",
		newState = 6,
	},
}

-- War wolf den special tiles

local warWolfDenTiles = MoveEvent()

function warWolfDenTiles.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06)
	if missionState == -1 then
		return true
	end
	local missionTile = specialMissionTiles[item.uid]
	-- Check if the tile is active
	if missionState == missionTile.state then
		-- Check delayed notifications (message/arrow)
		if not isTutorialNotificationDelayed(player) then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, missionTile.messageKey)
			if missionTile.arrowPosition then
				Position(missionTile.arrowPosition):sendMagicEffect(CONST_ME_TUTORIALARROW)
			end
		end
		if missionTile.newState then
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06, missionTile.newState)
		end
	end
	return true
end

for index, value in pairs(specialMissionTiles) do
	warWolfDenTiles:uid(index)
end
warWolfDenTiles:register()

-- War wolf den boost tiles

local function teleportBack(uid)
	local player = Player(uid)
	if player and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06) == 5 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission06_run_like_wolf.msg_2")
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06, 4)
		player:teleportTo({ x = 32109, y = 32131, z = 11 })
	end
end

local warWolfDenBoostTiles = MoveEvent()

function warWolfDenBoostTiles.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06)
	if missionState == 4 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission06_run_like_wolf.msg_3")
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06, 5)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		local conditionHaste = Condition(CONDITION_HASTE)
		conditionHaste:setParameter(CONDITION_PARAM_TICKS, 25000)
		conditionHaste:setFormula(0.3, -24, 0.3, -24)
		player:addCondition(conditionHaste)
		addEvent(teleportBack, 25000, player:getId())
	end
	return true
end

warWolfDenBoostTiles:aid(50334)
warWolfDenBoostTiles:register()

-- Poacher corpse (gather skinning knife)

local poacherCorpse = Action()

function poacherCorpse.onUse(player, item, frompos, itemEx, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06)
	-- Skip if not was started
	if missionState == -1 then
		return true
	end
	if missionState == 2 then
		local corpseState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.PoacherCorpse)
		if corpseState == -1 then
			local reward = Game.createItem(12672, 1)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission06_run_like_wolf.msg_4" .. reward:getArticle() .. " " .. reward:getName() .. ".")
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.PoacherCorpse, 1)
			player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06, 3)
			player:addItemEx(reward, true, CONST_SLOT_WHEREEVER)
		else
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.quest_common.chest_empty", item:getName())
		end
	end
	return true
end

poacherCorpse:uid(40044)
poacherCorpse:register()

-- Skinning knife (skinning dead war wolf)

local skinningKnife = Action()

function skinningKnife.onUse(player, item, frompos, itemEx, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06)
	if missionState == 3 and itemEx.uid == 40045 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission06_run_like_wolf.msg_5")
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06, 4)
		player:addExperience(50, true)
		player:removeItem(12672, 1)
		player:addItemEx(Game.createItem(12740, 1), true, CONST_SLOT_WHEREEVER)
	end
	return true
end

skinningKnife:id(12672)
skinningKnife:register()

-- War wolf den chest (Small health potion)

local warWolfDenChest = Action()

function warWolfDenChest.onUse(player, item, frompos, itemEx, topos)
	local missionState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06)
	-- Skip if not was started
	if missionState == -1 then
		return true
	end
	local chestState = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.WarWolfDenChest)
	if chestState == -1 then
		local reward = Game.createItem(7876, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.mission06_run_like_wolf.msg_6" .. reward:getArticle() .. " " .. reward:getName() .. ".")
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.WarWolfDenChest, 1)
		player:addItemEx(reward, true, CONST_SLOT_WHEREEVER)
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.quest_common.chest_empty", item:getName())
	end
	return true
end

warWolfDenChest:uid(40076)
warWolfDenChest:register()
