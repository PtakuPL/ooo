local actions_asura_bonefiddle = Action()

function actions_asura_bonefiddle.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Asuras.Questline) < 2 then
		if item.itemid == 28491 then
			if target.itemid == 28489 then
				item:remove(1)
				target:remove(1)
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_bonefiddle.msg_5")
				player:addItem(28492)
			end
		elseif item.itemid == 28492 then
			if target.itemid == 28490 then
				item:remove(1)
				target:remove(1)
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_bonefiddle.msg_4")
				player:addItem(28493)
				player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Asuras.Questline, 2)
			end
		end
	end
	if item.itemid == 28493 then
		if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Asuras.Questline) == 2 then
			if player:getPosition():isInRange(Position(32807, 32762, 10), Position(32809, 32768, 10)) then
				player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Asuras.Questline, 3)
			end
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_bonefiddle.msg_3")
			player:getPosition():sendMagicEffect(CONST_ME_SOUND_PURPLE)
		elseif player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Asuras.Questline) == 4 then
			if player:getPosition():isInRange(Position(32807, 32762, 10), Position(32809, 32768, 10)) then
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_bonefiddle.msg_2")
				player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Asuras.Questline, 5)
				player:getPosition():sendMagicEffect(CONST_ME_SOUND_WHITE)
				return true
			end
		elseif player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.Asuras.Questline) >= 5 then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_bonefiddle.msg_1")
			player:getPosition():sendMagicEffect(CONST_ME_SOUND_WHITE)
		end
	end

	return true
end

actions_asura_bonefiddle:id(28491, 28492, 28493)
actions_asura_bonefiddle:register()
