local config = {
	[1] = {
		text = "quests.unnatural_selection.mission2_say_1",
		position = { Position(33263, 31834, 1) },
	},
	[2] = {
		text = "quests.unnatural_selection.mission2_say_2",
		position = { Position(32711, 31668, 1) },
	},
	[3] = {
		text = "quests.unnatural_selection.mission2_say_3",
		position = { Position(32537, 31772, 1) },
	},
	[4] = {
		text = "quests.unnatural_selection.mission2_say_4",
		position = { Position(33216, 32450, 1) },
	},
	[5] = {
		text = "quests.unnatural_selection.mission2_say_5",
		position = {
			Position(33149, 32841, 2),
			Position(33149, 32842, 2),
			Position(33149, 32843, 2),
			Position(33149, 32844, 2),
			Position(33149, 32845, 2),
			Position(33150, 32841, 2),
			Position(33151, 32841, 2),
			Position(33152, 32841, 2),
			Position(33153, 32841, 2),
			Position(33153, 32842, 2),
			Position(33153, 32843, 2),
			Position(33153, 32844, 2),
			Position(33153, 32845, 2),
			Position(33150, 32845, 2),
			Position(33151, 32845, 2),
			Position(33152, 32845, 2),
		},
	},
	[6] = {
		text = "quests.unnatural_selection.mission2_say_6",
		position = {
			Position(32588, 32801, 4),
			Position(32580, 32743, 4),
			Position(32628, 32745, 4),
			Position(32629, 32745, 4),
			Position(32689, 32742, 4),
		},
	},
	[7] = {
		text = "quests.unnatural_selection.mission2_say_7",
		position = { Position(32346, 32808, 2) },
	},
	[8] = {
		text = "quests.unnatural_selection.mission2_say_8",
		position = { Position(32789, 31238, 3) },
	},
	[9] = {
		text = "quests.unnatural_selection.mission2_say_9",
		position = { Position(32236, 31096, 2) },
	},
	[10] = {
		text = "quests.unnatural_selection.mission2_say_10",
		position = { Position(32344, 32265, 0) },
	},
	[11] = {
		text = "quests.unnatural_selection.mission2_say_11",
		position = { Position(32316, 31752, 0) },
	},
}

local mission2AllAroundTheWorld = MoveEvent()

function mission2AllAroundTheWorld.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local targetValue = config[player:getStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Mission02)]
	if not targetValue then
		return true
	end
	if table.contains(targetValue.position, player:getPosition()) and player:getItemCount(10159) >= 1 then
		--Questlog, Unnatural Selection Quest "Mission 2: All Around the World"
		player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Mission02, player:getStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Mission02) + 1)
		player:sayLocalized(targetValue.text, TALKTYPE_MONSTER_SAY)
	end
	return true
end

for a = 1, #config do
	for b = 1, #config[a].position do
		mission2AllAroundTheWorld:position({ x = config[a].position[b].x, y = config[a].position[b].y, z = config[a].position[b].z })
	end
end
mission2AllAroundTheWorld:register()
