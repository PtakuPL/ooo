local imbuement = Action()

function imbuement.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if configManager.getBoolean(configKeys.TOGGLE_IMBUEMENT_SHRINE_STORAGE) and player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Tomes) ~= 1 then
		return player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.imbuement_shrine.msg_1")
	end

	if type(target) ~= "userdata" or not target:isItem() then
		return player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.imbuement_shrine.msg_2")
	end

	player:openImbuementWindow(target)
	return true
end

imbuement:id(25060, 25061, 25174, 25175, 25182, 25183, 24964)
imbuement:register()
