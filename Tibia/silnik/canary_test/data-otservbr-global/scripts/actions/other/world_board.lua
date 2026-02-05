local worldBoard = Action()

local communicates = {
	[1] = {
		storageValue = GlobalStorage.FuryGates,
		communicateKey = "actions.world_board.fury_gates",
	},

	[2] = {
		storageValue = GlobalStorage.Yasir,
		communicateKey = "actions.world_board.yasir_trader",
	},

	[3] = {
		storageValue = GlobalStorage.WorldBoard.NightmareIsle.AnkrahmunNorth,
		communicateKey = "actions.world_board.nightmare_ankrahmun",
	},

	[4] = {
		storageValue = GlobalStorage.WorldBoard.NightmareIsle.DarashiaNorth,
		communicateKey = "actions.world_board.nightmare_darashia_north",
	},

	[5] = {
		storageValue = GlobalStorage.WorldBoard.NightmareIsle.DarashiaWest,
		communicateKey = "actions.world_board.nightmare_darashia_west",
	},
}

function worldBoard.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	for index, value in pairs(communicates) do
		if Game.getStorageValue(value.storageValue) > 0 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, value.communicateKey)
		end
	end
	return true
end

worldBoard:id(19236)
worldBoard:register()
