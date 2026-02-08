local worldBoard = Action()

local communicates = {
	[1] = {
		storageValue = GlobalStorage.FuryGates,
		communicate = "quests.world_board.fury_gate",
	},

	[2] = {
		storageValue = GlobalStorage.Yasir,
		communicate = "quests.world_board.oriental_ships",
	},

	[3] = {
		storageValue = GlobalStorage.WorldBoard.NightmareIsle.AnkrahmunNorth,
		communicate = "quests.world_board.sandstorm_tar",
	},

	[4] = {
		storageValue = GlobalStorage.WorldBoard.NightmareIsle.DarashiaNorth,
		communicate = "quests.world_board.sandstorm_coast",
	},

	[5] = {
		storageValue = GlobalStorage.WorldBoard.NightmareIsle.DarashiaWest,
		communicate = "quests.world_board.sandstorm_drefia",
	},
}

function worldBoard.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	for index, value in pairs(communicates) do
		if Game.getStorageValue(value.storageValue) > 0 then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, value.communicate)
		end
	end
	return true
end

worldBoard:id(19236)
worldBoard:register()
