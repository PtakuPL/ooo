local addCharm = TalkAction("/addcharms")

function addCharm.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local usage = "/addcharms PLAYER NAME,AMOUNT"
	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_usage", {usage})
		return true
	end
	local split = param:split(",")
	if not split[2] then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_insufficient_usage", {usage})
		return true
	end
	local target = Player(split[1])
	if not target then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_name_not_online")
		return true
	end

	split[2] = split[2]:trimSpace()

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_added_points", {split[2], target:getName()})
	target:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_received_points", {split[2]})
	target:addCharmPoints(tonumber(split[2]))
	target:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
end

addCharm:separator(" ")
addCharm:groupType("god")
addCharm:register()

---------------- // ----------------

local addMinorCharm = TalkAction("/addminorcharms")

function addMinorCharm.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local usage = "/addminorcharms PLAYER NAME,AMOUNT"
	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_usage", {usage})
		return true
	end
	local split = param:split(",")
	if not split[2] then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_insufficient_usage", {usage})
		return true
	end
	local target = Player(split[1])
	if not target then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_name_not_online")
		return true
	end

	split[2] = split[2]:trimSpace()

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_added_minor", {split[2], target:getName()})
	target:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_received_minor", {split[2]})
	target:addMinorCharmEchoes(tonumber(split[2]))
	target:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
end

addMinorCharm:separator(" ")
addMinorCharm:groupType("god")
addMinorCharm:register()

---------------- // ----------------

local resetCharm = TalkAction("/resetcharms")

function resetCharm.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		param = player:getName()
	end
	local target = Player(param)
	if not target then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_name_not_online")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_reset_other", {target:getName()})
	target:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_reset_self")
	target:resetCharmsBestiary()
	target:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
end

resetCharm:separator(" ")
resetCharm:groupType("god")
resetCharm:register()

---------------- // ----------------
local charmExpansion = TalkAction("/charmexpansion")

function charmExpansion.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		param = player:getName()
	end
	local target = Player(param)
	if not target then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_name_not_online")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_expansion_other", {target:getName()})
	target:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_expansion_self")
	target:charmExpansion(true)
	target:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
end

charmExpansion:separator(" ")
charmExpansion:groupType("god")
charmExpansion:register()

---------------- // ----------------
local charmRune = TalkAction("/charmrunes")

function charmRune.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		param = player:getName()
	end
	local target = Player(param)
	if not target then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_name_not_online")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_runes_other", {target:getName()})
	target:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_runes_self")
	target:unlockAllCharmRunes()
	target:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
end

charmRune:separator(" ")
charmRune:groupType("god")
charmRune:register()

---------------- // ----------------
local setBestiary = TalkAction("/setbestiary")

function setBestiary.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local usage = "/setbestiary PLAYER NAME,MONSTER NAME/ALL,AMOUNT"
	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_usage", {usage})
		return true
	end
	local split = param:split(",")
	if not split[3] then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_insufficient_usage", {usage})
		return true
	end
	local target = Player(split[1])
	if not target then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_name_not_online")
		return true
	end

	split[2] = split[2]:trimSpace()
	split[3] = split[3]:trimSpace()

	local amount = tonumber(split[3])
	if not amount then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_wrong_kill")
		return true
	end

	local monsterName = split[2]
	-- If "all" is specified, iterate through all monsters
	if monsterName:lower() == "all" then
		local monsterList = Game.getMonsterTypes() -- Retrieves all available monsters
		for _, mType in pairs(monsterList) do
			if mType:raceId() > 0 then -- Ensure the monster has a bestiary entry
				target:addBestiaryKill(mType:name(), amount)
			end
		end
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_set_all_other", {amount, target:getName()})
		target:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_set_all_self")
	else
		local mType = MonsterType(monsterName)
		if not mType or (mType and mType:raceId() == 0) then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_no_bestiary")
			return true
		end

		target:addBestiaryKill(monsterName, amount)
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_set_single_other", {monsterName, target:getName(), amount})
		target:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.charms.msg_set_single_self", {monsterName})
	end

	target:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
end

setBestiary:separator(" ")
setBestiary:groupType("god")
setBestiary:register()
