local config = {
	[8009] = {
		storage = Storage.Quest.U8_54.ChildrenOfTheRevolution.SpyBuilding01,
		text = "quests.children_revolution.spy_say_1",
	},
	[8010] = {
		storage = Storage.Quest.U8_54.ChildrenOfTheRevolution.SpyBuilding02,
		text = "quests.children_revolution.spy_say_2",
	},
	[8011] = {
		storage = Storage.Quest.U8_54.ChildrenOfTheRevolution.SpyBuilding03,
		text = "quests.children_revolution.spy_say_3",
	},
}

local spy = MoveEvent()

function spy.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local targetTile = config[item.actionid]
	if not targetTile then
		return true
	end

	if player:getStorageValue(targetTile.storage) < 1 then
		--Questlog, Children of the Revolution "Mission 2: Imperial Zzecret Weaponzz"
		player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission02, player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission02) + 1)
		player:setStorageValue(targetTile.storage, 1)
		player:sayLocalized(targetTile.text, TALKTYPE_MONSTER_SAY)
	end
	return true
end

spy:type("stepin")

for index, value in pairs(config) do
	spy:aid(index)
end

spy:register()
