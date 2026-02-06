local questArea = {
	Position(32706, 32345, 7),
	Position(32725, 32357, 7),
}

local sounds = {
	"scripts.demon_oak.voice_1",
	"scripts.demon_oak.voice_2",
	"scripts.demon_oak.voice_3",
	"scripts.demon_oak.voice_4",
	"scripts.demon_oak.voice_5",
	"scripts.demon_oak.voice_6",
	"scripts.demon_oak.voice_7",
}

local demonOakVoices = GlobalEvent("demon oak voices")
function demonOakVoices.onThink(interval, lastExecution)
	local spectators, spectator = Game.getSpectators(DEMON_OAK_POSITION, false, true, 0, 15, 0, 15)
	local soundKey = sounds[math.random(#sounds)]
	for i = 1, #spectators do
		spectator = spectators[i]
		if spectator:getPosition():isInRange(questArea[1], questArea[2]) then
			return true
		end
		spectator:sayLocalized(soundKey, TALKTYPE_MONSTER_YELL, false, 0, DEMON_OAK_POSITION)
	end
	return true
end

demonOakVoices:interval(15000)
demonOakVoices:register()
