local documentContent = "#i18n:book.koshei.famous_inhabitants_page_2"

local kosheiBag = Action()
function kosheiBag.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(483293) == -1 then
		local bag = player:addItem(2853, 1)
		if bag then
			local document = bag:addItem(2834, 1)
			if document then
				document:setAttribute(ITEM_ATTRIBUTE_NAME, "Famous Inhabitants of Darashia, Page 2")
				document:setAttribute(ITEM_ATTRIBUTE_TEXT, documentContent)
			end
		end
		player:setStorageValue(483293)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.action_bag.msg_1")
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.action_bag.msg_2")
	end
	return true
end

kosheiBag:aid(40532)
kosheiBag:register()
