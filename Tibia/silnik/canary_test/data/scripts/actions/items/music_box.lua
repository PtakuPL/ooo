local config = {
	["dragonling"] = { mountId = 31, achievement = "Dragon Mimicry", tameMessage = "scripts.music_box.tame_dragonling", sound = "scripts.music_box.sound_dragonling" },
	["draptor"] = { mountId = 6, achievement = "Scales and Tail", tameMessage = "scripts.music_box.tame_draptor", sound = "scripts.music_box.sound_draptor" },
	["enraged white deer"] = { mountId = 18, achievement = "Friend of Elves", tameMessage = "scripts.music_box.tame_enraged_white_deer", sound = "scripts.music_box.sound_enraged_white_deer" },
	["ironblight"] = { mountId = 29, achievement = "Magnetised", tameMessage = "scripts.music_box.tame_ironblight", sound = "scripts.music_box.sound_ironblight" },
	["magma crawler"] = { mountId = 30, achievement = "Way to Hell", tameMessage = "scripts.music_box.tame_magma_crawler", sound = "scripts.music_box.sound_magma_crawler" },
	["midnight panther"] = { mountId = 5, achievement = "Starless Night", tameMessage = "scripts.music_box.tame_midnight_panther", sound = "scripts.music_box.sound_midnight_panther" },
	["wailing widow"] = { mountId = 1, achievement = "Spin-Off", tameMessage = "scripts.music_box.tame_wailing_widow", sound = "scripts.music_box.sound_wailing_widow" },
	["wild horse"] = { mountId = 17, achievement = "Lucky Horseshoe", tameMessage = "scripts.music_box.tame_wild_horse", sound = "scripts.music_box.sound_wild_horse" },
	["panda"] = { mountId = 19, achievement = "Chequered Teddy", tameMessage = "scripts.music_box.tame_panda", sound = "scripts.music_box.sound_panda" },
}

local musicBox = Action()

function musicBox.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target:isCreature() or not target:isMonster() or target:getMaster() then
		return false
	end

	local monsterConfig = config[target:getName():lower()]
	if not monsterConfig then
		return false
	end

	if player:hasMount(monsterConfig.mountId) then
		return false
	end

	player:addMount(monsterConfig.mountId)
	player:addAchievement("Natural Born Cowboy")
	player:addAchievement(monsterConfig.achievement)
	player:sayLocalized(monsterConfig.tameMessage, TALKTYPE_MONSTER_SAY)
	toPosition:sendMagicEffect(CONST_ME_SOUND_RED)

	target:sayLocalized(monsterConfig.sound, TALKTYPE_MONSTER_SAY)
	target:remove()

	item:remove(1)
	return true
end

musicBox:id(16244)
musicBox:register()
