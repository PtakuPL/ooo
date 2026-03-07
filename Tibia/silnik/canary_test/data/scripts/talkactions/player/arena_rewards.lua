-- Arena PvP - Reward Shop & Title Commands
-- Commands: !arena-shop [buy <id>] | !arena-title
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

local arenaShop = TalkAction("!arena-shop")

function arenaShop.onSay(player, words, param)
	if not player then
		return false
	end

	local args = param:lower():split(" ")
	local action = args[1] or "list"

	if action == "list" or action == "" then
		local stats = player:arenaGetStats()
		local points = stats and stats.arenaPoints or 0
		local msg = player:getTranslation("arena.shop.header", {tostring(points)}) .. "\n"

		for i, item in ipairs(ArenaConfig.shop) do
			local itemName = player:getTranslation(item.i18nKey)
			msg = msg .. player:getTranslation("arena.shop.entry",
				{tostring(i), itemName, tostring(item.cost), item.category}) .. "\n"
		end

		msg = msg .. player:getTranslation("arena.shop.buy_hint")
		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)

	elseif action == "buy" then
		local itemIndex = tonumber(args[2])
		if not itemIndex or itemIndex < 1 or itemIndex > #ArenaConfig.shop then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.shop.invalid_id")
			return true
		end

		local item = ArenaConfig.shop[itemIndex]
		local stats = player:arenaGetStats()
		local points = stats and stats.arenaPoints or 0

		if points < item.cost then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE,
				"arena.shop.not_enough_points", {tostring(item.cost), tostring(points)})
			return true
		end

		-- Deduct points
		db.query(string.format(
			"UPDATE `arena_players` SET `arena_points` = `arena_points` - %d WHERE `player_id` = %d",
			item.cost, player:getGuid()
		))

		-- Give item
		player:addItem(item.itemId, 1)
		local itemName = player:getTranslation(item.i18nKey)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
			"arena.shop.buy_success", {itemName, tostring(item.cost)})

		ArenaLog.logAdminAction(player, "shop_buy", player:getName(),
			"Bought " .. item.name .. " for " .. item.cost .. " pts")
	else
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.shop.usage")
	end

	return true
end

arenaShop:separator(" ")
arenaShop:groupType("normal")
arenaShop:register()

-- ============================================
-- Title display command
-- ============================================

local arenaTitle = TalkAction("!arena-title")

function arenaTitle.onSay(player, words, param)
	if not player then
		return false
	end

	local stats = player:arenaGetStats()
	if not stats then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.title.no_stats")
		return true
	end

	local currentTitle = ArenaConfig.getTranslatedTitle(player, stats.mmr)
	local msg = player:getTranslation("arena.title.current", {currentTitle, tostring(stats.mmr)}) .. "\n"
	msg = msg .. player:getTranslation("arena.title.progression") .. "\n"

	for _, t in ipairs(ArenaConfig.titles) do
		local titleName = player:getTranslation(t.i18nKey)
		local marker = stats.mmr >= t.minMMR and ">>>" or "   "
		msg = msg .. string.format("%s %s (MMR %d+)\n", marker, titleName, t.minMMR)
	end

	player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
	return true
end

arenaTitle:groupType("normal")
arenaTitle:register()
