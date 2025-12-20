--

local paper = Action()

function paper.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Second.Investigating) == 2 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.2_ambassadors_treason.msg_7")
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Second.Investigating, 3)
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.2_ambassadors_treason.msg_6")
	end
	return true
end

paper:uid(40030)
paper:register()

--

local paperScraps = Action()

function paperScraps.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Second.Investigating) == 3 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.2_ambassadors_treason.msg_5")
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Second.Investigating, 4)
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.2_ambassadors_treason.msg_4")
	end
	return true
end

paperScraps:uid(40031)
paperScraps:register()

--

local scrolls = Action()

function scrolls.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Second.Investigating) == 1 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.2_ambassadors_treason.msg_3")
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Second.Investigating, 2)
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.2_ambassadors_treason.msg_2")
	end
	return true
end

scrolls:uid(40029)
scrolls:register()

--

local roofTop = MoveEvent()

function roofTop.onStepIn(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Second.Investigating) == 4 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.2_ambassadors_treason.msg_1")
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Second.Investigating, 5)
	end
	return true
end

roofTop:aid(50307)
roofTop:register()
