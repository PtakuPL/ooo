local TheHuntForTheSeaSerpent = Storage.Quest.U8_2.TheHuntForTheSeaSerpent
local bait = Action()

function bait.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.QuestLine) == 1 then
		if target.itemid == 3496 then -- crane
			if player:getStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Bait) == 1 then
				player:sayLocalized("quests.actions_bait.say_1", TALKTYPE_MONSTER_SAY)
			else
				item:remove(1)
				toPosition:sendMagicEffect(CONST_ME_WATERSPLASH)
				player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Bait, 1)
			end
		end
	end
	return true
end

bait:id(939)
bait:register()

local words = {
	phase = {
		"dot",
		"a dot",
		"a shadow",
		"a huge shadow",
	},
	direction = {
		" straight ahead of you",
		". It is to the starboard side",
		". It is on the larboard side",
	},
}
local telescope = Action()

function telescope.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.QuestLine) == 1 then
		local randBait, randAppear, randPhase, randDirection, phase, direction
		randBait = math.random(2) -- 50% bait loss ratio
		if player:getStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.SuccessSwitch) == 1 then
			randAppear = math.random(10) -- 90%/10% nothing/success ratio
		else
			randAppear = math.random(9) -- always nothing
		end
		if player:getStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Bait) < 1 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bait.msg_1")
		elseif player:getStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction) > 0 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bait.msg_2")
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.SuccessSwitch, 0)
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction, 0)
		elseif randAppear <= 4 then -- 40% nothing
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bait.msg_3")
		else
			if randAppear >= 5 and randAppear <= 8 then -- 40% nothing
				randPhase = math.random(#words.phase)
				randDirection = math.random(#words.direction)
				phase = words.phase[randPhase]
				direction = words.direction[randDirection]
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bait.msg_1", {phase, direction})
				player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction, randDirection)
				if randBait == 2 then
					player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Bait, 0)
				end
			elseif randAppear == 9 then -- 10% nothing
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bait.msg_4")
				player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction, 4)
				if randBait == 2 then
					player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Bait, 0)
				end
			elseif randAppear == 10 then -- 10% success
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_bait.msg_5")
				Position(31933, 31037, 7):sendMagicEffect(CONST_ME_WATERCREATURE)
				player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.QuestLine, 2)
				player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Access, 1)
			end
		end
	end
	return true
end

telescope:id(938)
telescope:register()
