local promotionScrolls = {
	[43946] = { name = "abridged", points = 3, itemName = "abridged promotion scroll" },
	[43947] = { name = "basic", points = 5, itemName = "basic promotion scroll" },
	[43948] = { name = "revised", points = 9, itemName = "revised promotion scroll" },
	[43949] = { name = "extended", points = 13, itemName = "extended promotion scroll" },
	[43950] = { name = "advanced", points = 20, itemName = "advanced promotion scroll" },
}

local scroll = Action()

function scroll.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getLevel() < 51 then
		player:sendLocalizedTextMessage(MESSAGE_LOOK, "scripts.wheel_scrolls.msg_1")
		return true
	end

	local scrollData = promotionScrolls[item:getId()]
	if not player:wheelUnlockScroll(scrollData.name) then
		player:sendLocalizedTextMessage(MESSAGE_LOOK, "scripts.wheel_scrolls.msg_2")
		return true
	end

player:sendLocalizedTextMessage(MESSAGE_LOOK, "scripts.wheel_scrolls.msg_3", { scrollData.points, scrollData.itemName })
	item:remove(1)
	return true
end

for id in pairs(promotionScrolls) do
	scroll:id(id)
end

scroll:register()
