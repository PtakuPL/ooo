local forgottenKnowledgeBird = Action()
function forgottenKnowledgeBird.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.itemid == 23812 then
		if target:getName():lower() ~= "cave parrot" then
			return false
		end
		target:getPosition():sendMagicEffect(CONST_ME_POFF)
		target:remove()
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bird_cage.msg_1")
		item:transform(23813)
		return true
	elseif item.itemid == 23813 then
		if player:getPosition() ~= Position(32737, 32117, 10) then
			return false
		end
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bird_cage.msg_2")
		item:transform(23812)
		if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.BirdCounter) < 0 then
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.BirdCounter, 0)
		end
		player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.BirdCounter, player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.BirdCounter) + 1)
	end
	player:getPosition():sendMagicEffect(CONST_ME_HEARTS)
	return true
end

forgottenKnowledgeBird:id(23812, 23813)
forgottenKnowledgeBird:register()
