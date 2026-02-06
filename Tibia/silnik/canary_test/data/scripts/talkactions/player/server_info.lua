local serverInfo = TalkAction("!serverinfo")

local function tr(player, key)
	return i18nTranslate(key, player:getLocale())
end

function serverInfo.onSay(player, words, param)
	local text
	local useStages = configManager.getBoolean(configKeys.RATE_USE_STAGES)
	if not useStages then
		text = tr(player, "scripts.server_info.rates_header")
			.. "\n\n"
			.. tr(player, "scripts.server_info.exp_rate")
			.. configManager.getNumber(configKeys.RATE_EXPERIENCE)
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.skill_rate")
			.. configManager.getNumber(configKeys.RATE_SKILL)
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.magic_rate")
			.. configManager.getNumber(configKeys.RATE_MAGIC)
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.loot_rate")
			.. configManager.getNumber(configKeys.RATE_LOOT)
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.spawn_rate")
			.. configManager.getNumber(configKeys.RATE_SPAWN)
			.. "x"
	else
		local configRateSkill = configManager.getNumber(configKeys.RATE_SKILL)
		text = tr(player, "scripts.server_info.stages_header")
			.. "\n\n"
			.. tr(player, "scripts.server_info.exp_rate_stages")
			.. getRateFromTable(experienceStages, player:getLevel(), expstagesrate)
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.sword_rate_stages")
			.. getRateFromTable(skillsStages, player:getSkillLevel(SKILL_SWORD), configRateSkill)
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.club_rate_stages")
			.. getRateFromTable(skillsStages, player:getSkillLevel(SKILL_CLUB), configRateSkill)
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.axe_rate_stages")
			.. getRateFromTable(skillsStages, player:getSkillLevel(SKILL_AXE), configRateSkill)
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.distance_rate_stages")
			.. getRateFromTable(skillsStages, player:getSkillLevel(SKILL_DISTANCE), configRateSkill)
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.shield_rate_stages")
			.. getRateFromTable(skillsStages, player:getSkillLevel(SKILL_SHIELD), configRateSkill)
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.fist_rate_stages")
			.. getRateFromTable(skillsStages, player:getSkillLevel(SKILL_FIST), configRateSkill)
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.magic_rate")
			.. getRateFromTable(magicLevelStages, player:getBaseMagicLevel(), configManager.getNumber(configKeys.RATE_MAGIC))
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.loot_rate")
			.. configManager.getNumber(configKeys.RATE_LOOT)
			.. "x"
			.. "\n"
			.. tr(player, "scripts.server_info.spawn_rate")
			.. configManager.getNumber(configKeys.RATE_SPAWN)
			.. "x"
	end
	local loseHouseText = configManager.getNumber(configKeys.HOUSE_LOSE_AFTER_INACTIVITY) > 0
			and configManager.getNumber(configKeys.HOUSE_LOSE_AFTER_INACTIVITY) .. " " .. tr(player, "scripts.server_info.days")
		or tr(player, "scripts.server_info.never")
	text = text
		.. "\n\n"
		.. tr(player, "scripts.server_info.more_header")
		.. "\n\n"
		.. tr(player, "scripts.server_info.level_buy_house")
		.. configManager.getNumber(configKeys.HOUSE_BUY_LEVEL)
		.. "\n"
		.. tr(player, "scripts.server_info.lose_house_after_inactivity")
		.. loseHouseText
		.. "\n"
		.. tr(player, "scripts.server_info.protection_level")
		.. configManager.getNumber(configKeys.PROTECTION_LEVEL)
		.. "\n"
		.. tr(player, "scripts.server_info.world_type")
		.. configManager.getString(configKeys.WORLD_TYPE)
		.. "\n"
		.. tr(player, "scripts.server_info.kills_day_red")
		.. configManager.getNumber(configKeys.DAY_KILLS_TO_RED)
		.. "\n"
		.. tr(player, "scripts.server_info.kills_week_red")
		.. configManager.getNumber(configKeys.WEEK_KILLS_TO_RED)
		.. "\n"
		.. tr(player, "scripts.server_info.kills_month_red")
		.. configManager.getNumber(configKeys.MONTH_KILLS_TO_RED)
		.. "\n"
		.. tr(player, "scripts.server_info.server_save")
		.. configManager.getString(configKeys.GLOBAL_SERVER_SAVE_TIME)
	player:showTextDialog(34266, text)
	return true
end

serverInfo:separator(" ")
serverInfo:groupType("normal")
serverInfo:register()
