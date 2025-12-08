local config = {
	[1] = Position(32731, 31531, 9),
	[2] = Position(32739, 31489, 9),
	[3] = Position(32739, 31507, 9),
	[4] = Position(32761, 31518, 9),
	[5] = Position(32720, 31545, 8),
	[6] = Position(32745, 31423, 8),
	[7] = Position(32742, 31410, 8),
	[8] = Position(32685, 31430, 8),
	[9] = Position(32746, 31462, 8),
	[10] = Position(32683, 31537, 9),
	[11] = Position(32740, 31494, 9), -- Bancada Cult Object
	[12] = Position(32741, 31494, 9), -- Bancada Cult Object
}

local cultsOfTibiaLastObject = Action()

function cultsOfTibiaLastObject.onUse(player, item)
	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Barkless.Mission) == 4 then
		for i, position in pairs(config) do
			position:sendMagicEffect(CONST_ME_YELLOWENERGY)
		end
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_last_object.msg_1")
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_last_object.msg_2")
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_last_object.msg_3")
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Barkless.Mission, 5)
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Barkless.BossAccessDoor, 1)
	end
	return true
end

cultsOfTibiaLastObject:aid(5536)
cultsOfTibiaLastObject:register()
