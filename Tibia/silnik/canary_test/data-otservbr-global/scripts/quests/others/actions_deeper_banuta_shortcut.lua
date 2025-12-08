local othersDeeper = Action()
function othersDeeper.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target.actionid ~= 62378 then
		return false
	end

	if player:getStorageValue(Storage.BanutaSecretTunnel.DeeperBanutaShortcut) ~= 1 then
		player:removeItem(9606, 1)
		player:setStorageValue(Storage.BanutaSecretTunnel.DeeperBanutaShortcut, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_deeper_banuta_shortcut.msg_1")
		Position(32887, 32633, 11):sendMagicEffect(CONST_ME_WATERSPLASH)
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_deeper_banuta_shortcut.msg_2")
	end
	return true
end

othersDeeper:id(9606)
othersDeeper:register()
