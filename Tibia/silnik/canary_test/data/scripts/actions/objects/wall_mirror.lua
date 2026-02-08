local setting = {
	"scripts.wall_mirror.msg_1",
	"scripts.wall_mirror.msg_2",
	"scripts.wall_mirror.msg_3",
	"scripts.wall_mirror.msg_4",
	"scripts.wall_mirror.msg_5",
	"scripts.wall_mirror.msg_6",
	"scripts.wall_mirror.msg_7",
	"scripts.wall_mirror.msg_8",
	"scripts.wall_mirror.msg_9",
	"scripts.wall_mirror.msg_10",
	"scripts.wall_mirror.msg_11",
}

local wallMirror = Action()

function wallMirror.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:hasExhaustion("delay-wall-mirror") then
		player:sayLocalized("scripts.wall_mirror.say_1", TALKTYPE_MONSTER_SAY)
		return true
	end

	player:sayLocalized(setting[math.random(1, #setting)], TALKTYPE_MONSTER_SAY)
	player:setExhaustion("delay-wall-mirror", 20 * 60 * 60)
	return true
end

wallMirror:id(2603, 2604, 2630, 2631, 2633, 2634, 2636, 2637)
wallMirror:register()
