local messages = {
	{ "quests.bigfoot_burden.gnomedix_msg1", CONST_ME_LOSEENERGY },
	{ "quests.bigfoot_burden.gnomedix_msg2" },
	{ "quests.bigfoot_burden.gnomedix_msg3", CONST_ME_POFF },
	{ "quests.bigfoot_burden.gnomedix_msg4" },
	{ "quests.bigfoot_burden.gnomedix_msg5" },
	{ "quests.bigfoot_burden.gnomedix_msg6", CONST_ME_STUN },
	{ "quests.bigfoot_burden.gnomedix_msg7" },
	{ "quests.bigfoot_burden.gnomedix_msg8", CONST_ME_BLOCKHIT },
}

local function sendTextMessages(cid, index)
	local player = Player(cid)
	if not player then
		return true
	end

	if index ~= player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.GnomedixMsg) then
		return false
	end

	if player:getPosition() ~= Position({ x = 32767, y = 31771, z = 10 }) then
		return false
	end

	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, messages[index][1])
	if messages[index][2] then
		player:getPosition():sendMagicEffect(messages[index][2])
	end
	player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.GnomedixMsg, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.GnomedixMsg) + 1)
	if index == 8 then
		Game.createMonster("Strange Slime", Position(32767, 31772, 10))
		player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 11)
	end
end

local taskEar = MoveEvent()
function taskEar.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) ~= 10 then
		return true
	end
	player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.GnomedixMsg, 1)
	position:sendMagicEffect(CONST_ME_LOSEENERGY)

	for i = player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.GnomedixMsg), #messages do
		addEvent(sendTextMessages, (i - 1) * 4000, player.uid, i)
	end
	return true
end

taskEar:position({ x = 32767, y = 31771, z = 10 })
taskEar:register()
