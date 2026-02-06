local info = TalkAction("/info")

local function tr(player, key)
	return i18nTranslate(key, player:getLocale())
end

function info.onSay(player, words, param)
	local target = Player(param)
	if not target then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_not_found")
		return true
	end

	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
		return true
	end

	local targetIp = target:getIp()

	local text = tr(player, "scripts.info.header") .. "\n\n"
	text = text .. tr(player, "scripts.info.name") .. target:getName() .. "\n"
	text = text .. tr(player, "scripts.info.access") .. (target:getGroup():getAccess() and "1" or "0") .. "\n"
	text = text .. tr(player, "scripts.info.speed") .. target:getSpeed() .. "\n"
	text = text .. tr(player, "scripts.info.position") .. string.format("(%0.5d / %0.5d / %0.3d)", target:getPosition().x, target:getPosition().y, target:getPosition().z) .. "\n"
	text = text .. tr(player, "scripts.info.ip") .. Game.convertIpToString(targetIp) .. "\n\n"

	text = text .. tr(player, "scripts.info.skills_header") .. "\n\n"
	text = text .. tr(player, "scripts.info.skill_level") .. target:getLevel() .. "\n"
	text = text .. tr(player, "scripts.info.skill_axe") .. target:getSkillLevel(SKILL_AXE) .. "\n"
	text = text .. tr(player, "scripts.info.skill_club") .. target:getSkillLevel(SKILL_CLUB) .. "\n"
	text = text .. tr(player, "scripts.info.skill_distance") .. target:getSkillLevel(SKILL_DISTANCE) .. "\n"
	text = text .. tr(player, "scripts.info.skill_fist") .. target:getSkillLevel(SKILL_FIST) .. "\n"
	text = text .. tr(player, "scripts.info.skill_magic") .. target:getMagicLevel() .. "\n"
	text = text .. tr(player, "scripts.info.skill_shield") .. target:getSkillLevel(SKILL_SHIELD) .. "\n"
	text = text .. tr(player, "scripts.info.skill_sword") .. target:getSkillLevel(SKILL_SWORD) .. "\n"

	player:popupFYI(text)

	local players = {}
	for _, targetPlayer in ipairs(Game.getPlayers()) do
		if targetPlayer:getIp() == targetIp and targetPlayer ~= target then
			players[#players + 1] = targetPlayer:getName() .. " [" .. targetPlayer:getLevel() .. "]"
		end
	end

	if #players > 0 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.info.msg_1", { table.concat(players, ", ") })
	end
	return true
end

info:separator(" ")
info:groupType("gamemaster")
info:register()
