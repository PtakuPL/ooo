local rewardSoulWar = Action()

function rewardSoulWar.onUse(creature, item, fromPosition, target, toPosition, isHotkey)
	local rewardItem = SoulWarQuest.finalRewards[math.random(1, #SoulWarQuest.finalRewards)]
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local soulWarQuest = player:soulWarQuestKV()
	if soulWarQuest:get("final-reward") then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.action-reward_soul_war.msg_1")
		return true
	end

	if not soulWarQuest:get("goshnar's-megalomania-killed") then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.action-reward_soul_war.msg_2")
		return true
	end

	player:addItem(rewardItem.id, 1)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.action-reward_soul_war.msg_3", { rewardItem.name })
	soulWarQuest:set("final-reward", true)
	return true
end

rewardSoulWar:position({ x = 33620, y = 31400, z = 10 })
rewardSoulWar:register()
