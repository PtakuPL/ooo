local UniqueTable = {
	[25002] = {
		storage = Storage.Quest.U11_02.TheFirstDragon.DesertTile,
		msg = "quests.first_dragon.oasis",
	},
	[25003] = {
		storage = Storage.Quest.U11_02.TheFirstDragon.StoneSculptureTile,
		msg = "quests.first_dragon.circle_trees",
	},
	[25004] = {
		storage = Storage.Quest.U11_02.TheFirstDragon.SuntowerTile,
		msg = "quests.first_dragon.suntower",
	},
}

local zorvoraxSecrets = MoveEvent()

function zorvoraxSecrets.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local setting = UniqueTable[item.actionid]
	if not setting then
		return true
	end

	if player:getStorageValue(setting.storage) < 1 then
		player:setStorageValue(setting.storage, 1)
		player:setStorageValue(Storage.Quest.U11_02.TheFirstDragon.SecretsCounter, player:getStorageValue(Storage.Quest.U11_02.TheFirstDragon.SecretsCounter) + 1)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, setting.msg)
		return true
	end
	return true
end

for index, value in pairs(UniqueTable) do
	zorvoraxSecrets:aid(index)
end

zorvoraxSecrets:register()
