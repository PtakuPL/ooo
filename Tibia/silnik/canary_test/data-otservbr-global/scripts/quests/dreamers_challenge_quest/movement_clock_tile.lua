local words = {
	"quests.dreamers_challenge.clock_word_1",
	"quests.dreamers_challenge.clock_word_2",
	"quests.dreamers_challenge.clock_word_3",
	"quests.dreamers_challenge.clock_word_4",
	"quests.dreamers_challenge.clock_word_5",
}

local clockTile = MoveEvent()

function clockTile.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	position.x = position.x + math.random(-3, 3)
	position.y = position.y + math.random(-3, 3)
	player:sayLocalized(words[math.random(#words)], TALKTYPE_MONSTER_SAY, false, 0, position)
	return true
end

clockTile:type("stepin")
clockTile:aid(9049)
clockTile:register()
