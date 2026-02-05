local addCharm = TalkAction("/addcharms")

function addCharm.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local usage = "/addcharms PLAYER NAME,AMOUNT"
	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.usage_required", {usage})
		return true
	end
	local split = param:split(",")
	if not split[2] then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.insufficient_params", {usage})
		return true
	end
	local target = Player(split[1])
	if not target then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "gm.common.player_not_found")
		return true
	end

	split[2] = split[2]:trimSpace()

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.added_charm_points_admin", {split[2], target:getName()})
	target:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.added_charm_points_player", {split[2]})
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
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.usage_required", {usage})
		return true
	end
	local split = param:split(",")
	if not split[2] then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.insufficient_params", {usage})
		return true
	end
	local target = Player(split[1])
	if not target then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "gm.common.player_not_found")
		return true
	end

	split[2] = split[2]:trimSpace()

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.added_minor_points_admin", {split[2], target:getName()})
	target:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.added_minor_points_player", {split[2]})
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
		player:sendLocalizedMessage(MESSAGE_FAILURE, "gm.common.player_not_found")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.reseted_admin", {target:getName()})
	target:sendLocalizedMessage(MESSAGE_FAILURE, "god.charms.reseted_player")
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
		player:sendLocalizedMessage(MESSAGE_FAILURE, "gm.common.player_not_found")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.added_expansion_admin", {target:getName()})
	target:sendLocalizedMessage(MESSAGE_FAILURE, "god.charms.added_expansion_player")
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
		player:sendLocalizedMessage(MESSAGE_FAILURE, "gm.common.player_not_found")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.added_all_runes_admin", {target:getName()})
	target:sendLocalizedMessage(MESSAGE_FAILURE, "god.charms.added_all_runes_player")
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
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.usage_required", {usage})
		return true
	end
	local split = param:split(",")
	if not split[3] then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.insufficient_params", {usage})
		return true
	end
	local target = Player(split[1])
	if not target then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "gm.common.player_not_found")
		return true
	end

	split[2] = split[2]:trimSpace()
	split[3] = split[3]:trimSpace()

	local amount = tonumber(split[3])
	if not amount then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.charms.wrong_kill_amount")
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
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.set_all_bestiary_admin", {tostring(amount), target:getName()})
		target:sendLocalizedMessage(MESSAGE_FAILURE, "god.charms.set_all_bestiary_player")
	else
		local mType = MonsterType(monsterName)
		if not mType or (mType and mType:raceId() == 0) then
			player:sendLocalizedMessage(MESSAGE_FAILURE, "god.charms.no_bestiary")
			return true
		end

		target:addBestiaryKill(monsterName, amount)
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.set_bestiary_monster_admin", {monsterName, target:getName(), tostring(amount)})
		target:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.charms.set_bestiary_monster_player", {monsterName})
	end

	target:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
end

setBestiary:separator(" ")
setBestiary:groupType("god")
setBestiary:register()
