local spySlotTranslationKeys = {
	"talkaction.gm.spy.slot_helmet",
	"talkaction.gm.spy.slot_amulet",
	"talkaction.gm.spy.slot_backpack",
	"talkaction.gm.spy.slot_armor",
	"talkaction.gm.spy.slot_right_hand",
	"talkaction.gm.spy.slot_left_hand",
	"talkaction.gm.spy.slot_legs",
	"talkaction.gm.spy.slot_boots",
	"talkaction.gm.spy.slot_ring",
	"talkaction.gm.spy.slot_arrow",
}

local function getStackCount(player, item)
	if item.type > 0 then
		return " " .. player:getTranslation("talkaction.gm.spy.msg_stack_count", { tostring(item.type) })
	end
	return ""
end

local function getItemsInContainer(player, container, sep)
	local text = ""
	local tsep = ""
	for i = 1, sep do
		tsep = tsep .. "-"
	end
	tsep = tsep .. ">"
	for slot = 0, container:getSize() - 1 do
		local item = container:getItem(slot)
		if not item:isContainer() then
			text = text .. "\n" .. tsep .. ItemType(item.itemid):getName() .. getStackCount(player, item)
		else
			if item:getSize() > 0 then
				text = text .. "\n" .. tsep .. ItemType(item.itemid):getName()
				text = text .. getItemsInContainer(player, item, sep + 2)
			else
				text = text .. "\n" .. tsep .. ItemType(item.itemid):getName()
			end
		end
	end
	return text
end

local spy = TalkAction("/spy")

function spy.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.gm.spy.msg_specify_name")
		return true
	end

	local target = Player(param)

	if target and target:isPlayer() then
		local text = player:getTranslation("talkaction.gm.spy.msg_equipment_of", { target:getName() })
		for i = 1, 10 do
			text = text .. "\n\n"
			local item = target:getSlotItem(i)
			local slotLabel = player:getTranslation(spySlotTranslationKeys[i])
			if item and item.itemid > 0 then
				if item:isContainer() then
					text = text .. slotLabel .. ": " .. ItemType(item.itemid):getName() .. getItemsInContainer(player, item, 1)
				else
					text = text .. slotLabel .. ": " .. ItemType(item.itemid):getName() .. getStackCount(player, item)
				end
			else
				text = text .. slotLabel .. ": " .. player:getTranslation("talkaction.gm.spy.msg_empty")
			end
		end
		player:showTextDialog(6528, text)
	else
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.gm.spy.msg_offline")
	end
	return true
end

spy:separator(" ")
spy:groupType("gamemaster")
spy:register()
