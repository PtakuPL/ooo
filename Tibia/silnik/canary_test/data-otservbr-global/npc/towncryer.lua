local internalNpcName = "Towncryer"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 131,
	lookHead = 95,
	lookBody = 86,
	lookLegs = 10,
	lookFeet = 114,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.towncryer.voice_1" },
	{ i18nKey = "npc.towncryer.voice_2" },
	{ i18nKey = "npc.towncryer.voice_3" },
}

local worldChanges = {
	{ i18nKey = "npc.towncryer.voice_4", storage = GlobalStorage.WorldBoard.NightmareIsle.AnkrahmunNorth },
	{ i18nKey = "npc.towncryer.voice_5", storage = GlobalStorage.WorldBoard.NightmareIsle.DarashiaNorth },
	{ i18nKey = "npc.towncryer.voice_6", storage = GlobalStorage.WorldBoard.NightmareIsle.DarashiaWest },
	{ i18nKey = "npc.towncryer.voice_7", storage = GlobalStorage.Yasir },
	{ i18nKey = "npc.towncryer.voice_8", storage = GlobalStorage.FuryGates },
}

for i = 1, #worldChanges do
	if Game.getStorageValue(worldChanges[i].storage) > 0 then
		table.insert(npcConfig.voices, { i18nKey = worldChanges[i].i18nKey })
	end
end

npcType:register(npcConfig)
