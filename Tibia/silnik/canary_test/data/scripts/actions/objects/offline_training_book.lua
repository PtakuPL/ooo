local offlineTrainingBook = Action()

function offlineTrainingBook.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local text = Translator.getTranslation(player, "scripts.offline_training_book.info")
	player:showTextDialog(item.itemid, text)
	return true
end

offlineTrainingBook:id(11441)
offlineTrainingBook:register()
