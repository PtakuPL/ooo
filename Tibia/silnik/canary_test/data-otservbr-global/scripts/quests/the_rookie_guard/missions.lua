-- The Rookie Guard Quest

-- Handle avoid spam (message and arrow) in mission tiles
function isTutorialNotificationDelayed(player)
	-- Check delay
	if player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.TutorialDelay) - os.time() <= 0 then
		-- Reset delay
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.TutorialDelay, os.time() + 4)
		return false
	end
	return true
end

-- Missions shared tiles (Handled together due not possible more than one MoveEvent per action id)

local missionTiles = {
	-- North exit
	[50312] = {
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission02,
			states = { 1, 2, 3, 4 },
			message = "quests.rookie_guard.missions.road_main",
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission03,
			states = { 1 },
			message = "quests.rookie_guard.missions.road_main",
		},
	},
	-- North bridge exit
	[50319] = {
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission04,
			states = { 2 },
			message = "quests.rookie_guard.missions.hyacinth_east",
			arrowPosition = { x = 32096, y = 32169, z = 7 },
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission06,
			states = { 2 },
			message = "quests.rookie_guard.missions.wolf_forest",
			arrowPosition = { x = 32094, y = 32169, z = 7 },
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission09,
			states = { 1 },
			message = "quests.rookie_guard.missions.troll_caves",
			arrowPosition = { x = 32091, y = 32166, z = 7 },
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission10,
			states = { 1 },
			extra = {
				storage = Storage.Quest.U9_1.TheRookieGuard.Sarcophagus,
				state = -1,
			},
			message = "quests.rookie_guard.missions.graveyard_east",
			arrowPosition = { x = 32095, y = 32169, z = 7 },
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission11,
			states = { 1 },
			message = "quests.rookie_guard.missions.wasps_bridge",
			arrowPosition = { x = 32090, y = 32165, z = 7 },
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission12,
			states = { 2 },
			extra = {
				storage = Storage.Quest.U9_1.TheRookieGuard.AcademyChest,
				state = 1,
			},
			message = "quests.rookie_guard.missions.orc_fortress_path",
			arrowPosition = { x = 32091, y = 32166, z = 7 },
		},
	},
	[50321] = {
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission04,
			states = { 2 },
			message = "quests.rookie_guard.missions.not_hyacinth_south",
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission10,
			states = { 1 },
			extra = {
				storage = Storage.Quest.U9_1.TheRookieGuard.Sarcophagus,
				state = -1,
			},
			message = "quests.rookie_guard.missions.not_crypt_south",
		},
	},
	-- Outer east
	[50323] = {
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission05,
			states = { 1 },
			message = "quests.rookie_guard.missions.not_tarantula_nw",
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission09,
			states = { 1 },
			message = "quests.rookie_guard.missions.not_troll_north",
			arrowPosition = { x = 32091, y = 32166, z = 7 },
		},
	},
	-- North-west drawbridge
	[50325] = {
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission05,
			states = { 1 },
			message = "quests.rookie_guard.missions.tarantula_stairs",
			arrowPosition = { x = 32069, y = 32145, z = 6 },
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission11,
			states = { 1 },
			message = "quests.rookie_guard.missions.wasps_bridge_south",
			arrowPosition = { x = 32068, y = 32149, z = 6 },
		},
	},
	-- Academy entrance
	[50335] = {
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission07,
			states = { 1 },
			extra = {
				storage = Storage.Quest.U9_1.TheRookieGuard.LibraryChest,
				state = -1,
			},
			message = "quests.rookie_guard.missions.library_vault",
			arrowPosition = { x = 32097, y = 32197, z = 7 },
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission08,
			states = { 1 },
			message = "quests.rookie_guard.missions.bank_academy",
			arrowPosition = { x = 32097, y = 32197, z = 7 },
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission12,
			states = { 1 },
			extra = {
				storage = Storage.Quest.U9_1.TheRookieGuard.AcademyChest,
				state = -1,
			},
			message = "quests.rookie_guard.missions.no_bag_yet",
			arrowPosition = { x = 32097, y = 32197, z = 7 },
		},
	},
	-- Academy downstairs
	[50336] = {
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission07,
			states = { 1 },
			extra = {
				storage = Storage.Quest.U9_1.TheRookieGuard.LibraryChest,
				state = -1,
			},
			message = "quests.rookie_guard.missions.hallway_library",
			arrowPosition = { x = 32095, y = 32188, z = 8 },
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission08,
			states = { 1 },
			message = "quests.rookie_guard.missions.bank_paulie",
			arrowPosition = { x = 32100, y = 32191, z = 8 },
		},
	},
	-- North-west drawbridge south downstairs
	[50351] = {
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission11,
			states = { 1 },
			message = "quests.rookie_guard.missions.wasps_west",
			arrowPosition = { x = 32063, y = 32159, z = 7 },
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission12,
			states = { 2 },
			extra = {
				storage = Storage.Quest.U9_1.TheRookieGuard.AcademyChest,
				state = 1,
			},
			message = "quests.rookie_guard.missions.orc_west",
			arrowPosition = { x = 32063, y = 32159, z = 7 },
		},
	},
	-- Orc land entrance
	[50352] = {
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission11,
			states = { 1 },
			message = "quests.rookie_guard.missions.not_wasps_north",
			arrowPosition = { x = 32003, y = 32148, z = 7 },
		},
		{
			mission = Storage.Quest.U9_1.TheRookieGuard.Mission12,
			states = { 2 },
			extra = {
				storage = Storage.Quest.U9_1.TheRookieGuard.AcademyChest,
				state = 1,
			},
			message = "quests.rookie_guard.missions.entering_orcland",
		},
	},
}

-- Missions tutorial tiles

local missionGuide = MoveEvent()

function missionGuide.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	local tile = missionTiles[item.actionid]
	-- Check mission cases for the tile
	for i = 1, #tile do
		local missionState = player:getStorageValue(tile[i].mission)
		local extraState = tile[i].extra == nil or player:getStorageValue(tile[i].extra.storage) == tile[i].extra.state
		-- Check if the tile is active
		if missionState ~= -1 and table.find(tile[i].states, missionState) and extraState then
			-- Check delayed notifications (message/arrow)
			if not isTutorialNotificationDelayed(player) then
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, tile[i].message)
				if tile[i].arrowPosition then
					Position(tile[i].arrowPosition):sendMagicEffect(CONST_ME_TUTORIALARROW)
				end
			end
			break
		end
	end
	return true
end

for index, value in pairs(missionTiles) do
	missionGuide:aid(index)
end
missionGuide:register()
