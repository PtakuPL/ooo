local setting = {
	[2080] = {
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThroneInfernatil,
		text = "quests.pits_of_inferno.throne_say_1",
		effect = CONST_ME_FIREAREA,
		toPosition = Position(32909, 32211, 15),
	},
	[2081] = {
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThroneTafariel,
		text = "quests.pits_of_inferno.throne_say_2",
		effect = CONST_ME_MORTAREA,
		toPosition = Position(32761, 32243, 15),
	},
	[2082] = {
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThroneVerminor,
		text = "quests.pits_of_inferno.throne_say_3",
		effect = CONST_ME_POISONAREA,
		toPosition = Position(32840, 32327, 15),
	},
	[2083] = {
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThroneApocalypse,
		text = "quests.pits_of_inferno.throne_say_4",
		effect = CONST_ME_EXPLOSIONAREA,
		toPosition = Position(32875, 32267, 15),
	},
	[2084] = {
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThroneBazir,
		text = "quests.pits_of_inferno.throne_say_5",
		effect = CONST_ME_MAGIC_GREEN,
		toPosition = Position(32745, 32385, 15),
	},
	[2085] = {
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThroneAshfalor,
		text = "quests.pits_of_inferno.throne_say_6",
		effect = CONST_ME_FIREAREA,
		toPosition = Position(32839, 32310, 15),
	},
	[2086] = {
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin,
		text = "quests.pits_of_inferno.throne_say_7",
		effect = CONST_ME_MORTAREA,
		toPosition = Position(32785, 32279, 15),
	},
}

local throne = MoveEvent()

function throne.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local throne = setting[item.uid]
	if not throne then
		return true
	end

	-- Check specific condition for UID 2086
	if item.uid == 2086 then
		if player:getStorageValue(throne.storage) == 9 then
			player:setStorageValue(throne.storage, 10)
			player:setStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ShortcutHubDoor, 1)
			player:getPosition():sendMagicEffect(throne.effect)
			player:sayLocalized(throne.text, TALKTYPE_MONSTER_SAY)
		else
			player:teleportTo(throne.toPosition)
			player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
			player:sayLocalized("scripts.movements_throne.say_2", TALKTYPE_MONSTER_SAY)
		end
	else
		-- Default behavior for other UIDs
		if player:getStorageValue(throne.storage) ~= 1 then
			player:setStorageValue(throne.storage, 1)
			player:setStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ShortcutHubDoor, 1)
			player:getPosition():sendMagicEffect(throne.effect)
			player:sayLocalized(throne.text, TALKTYPE_MONSTER_SAY)
		else
			player:teleportTo(throne.toPosition)
			player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
			player:sayLocalized("scripts.movements_throne.say_1", TALKTYPE_MONSTER_SAY)
		end
	end
	return true
end

throne:type("stepin")

for index, value in pairs(setting) do
	throne:uid(index)
end

throne:register()
