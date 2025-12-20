local partyTrumpet = Action()

function partyTrumpet.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	player:sayLocalized("scripts.party_trumpet.say_1", TALKTYPE_MONSTER_SAY)
	fromPosition:sendMagicEffect(CONST_ME_SOUND_BLUE)
	item:transform(6573)
	item:decay()
	return true
end

partyTrumpet:id(6572)
partyTrumpet:register()
