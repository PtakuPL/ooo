local setting = {
	[32415] = {
		storage = Storage.Quest.U11_40.CultsOfTibia.Humans.Decaying,
		max = 10,
		text = "quests.cults_of_tibia.task_teleport_say_1",
		effect = CONST_ME_GREEN_ENERGY_SPARK,
	},
	[32414] = {
		storage = Storage.Quest.U11_40.CultsOfTibia.Humans.Vaporized,
		max = 10,
		text = "quests.cults_of_tibia.task_teleport_say_2",
		effect = CONST_ME_BLUE_ENERGY_SPARK,
	},
}

local taskTeleport = MoveEvent()

function taskTeleport.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Questline) < 1 then
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Questline, 1)
	end
	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Humans.Mission) < 1 then
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Humans.Mission, 1)
	end

	for index, value in pairs(setting) do
		local teleport = Tile(position):getItemById(index)
		if teleport then
			local storage = (player:getStorageValue(value.storage) < 0 and 0 or player:getStorageValue(value.storage))
			local attribute = teleport:getCustomAttribute("task") or ""
			if attribute:find(player:getName()) or storage >= value.max then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_task_teleport.msg_1")
				return false
			end
			attribute = string.format("%s, %s", attribute, player:getName())
			teleport:setCustomAttribute("task", attribute)
			player:setStorageValue(value.storage, storage + 1)
			player:getPosition():sendMagicEffect(value.effect)
			teleport:remove()
			player:sayLocalized(value.text, TALKTYPE_MONSTER_SAY)
		end
	end
	return true
end

taskTeleport:type("stepin")
taskTeleport:aid(5580)
taskTeleport:register()
