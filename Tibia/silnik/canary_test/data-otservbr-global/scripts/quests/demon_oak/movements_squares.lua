local voices = {
	"quests.demon_oak.voice_1",
	"quests.demon_oak.voice_2",
	"quests.demon_oak.voice_3",
	"quests.demon_oak.voice_4",
	"quests.demon_oak.voice_5",
	"quests.demon_oak.voice_6",
	"quests.demon_oak.voice_7",
}

local squares = MoveEvent()

function squares.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local status = math.max(player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Squares), 0)
	local startUid = 9000
	if item.uid - startUid == status + 1 then
		player:setStorageValue(Storage.Quest.U8_2.TheDemonOak.Squares, status + 1)
		player:sayLocalized(voices[math.random(#voices)], TALKTYPE_MONSTER_YELL, false, player, DEMON_OAK_POSITION)
	end
	return true
end

squares:type("stepin")
squares:uid(9001, 9002, 9003, 9004, 9005)
squares:register()
