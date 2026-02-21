-- Arena PvP Rewards System
-- Handles: Arena Point shop, title awarding, achievement tracking

local arenaRewards = TalkAction("!arena-shop", "!arenashop")

local function showShop(player)
	local stats = player:arenaGetStats()
	local points = stats and stats.arenaPoints or 0

	local msg = "[Arena Shop] Your Arena Points: " .. points .. "\n\n"
	msg = msg .. string.format("%-4s %-30s %-10s %-10s\n", "#", "Item", "Cost", "Category")
	msg = msg .. string.rep("-", 56) .. "\n"

	for _, item in ipairs(ArenaConfig.shop) do
		msg = msg .. string.format("%-4d %-30s %-10d %-10s\n",
			item.id, item.name, item.cost, item.category)
	end
	msg = msg .. "\nUse '!arena-shop buy <id>' to purchase."

	player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

local function buyItem(player, itemIndex)
	local shopItem = nil
	for _, item in ipairs(ArenaConfig.shop) do
		if item.id == itemIndex then
			shopItem = item
			break
		end
	end

	if not shopItem then
		player:sendTextMessage(MESSAGE_FAILURE, "[Arena Shop] Invalid item ID.")
		return
	end

	local stats = player:arenaGetStats()
	local points = stats and stats.arenaPoints or 0

	if points < shopItem.cost then
		player:sendTextMessage(MESSAGE_FAILURE,
			string.format("[Arena Shop] Not enough points. Need %d, have %d.", shopItem.cost, points))
		return
	end

	-- Deduct points via DB
	local query = string.format(
		"UPDATE `arena_players` SET `arena_points` = `arena_points` - %d WHERE `player_id` = %d AND `arena_points` >= %d",
		shopItem.cost, player:getGuid(), shopItem.cost
	)

	if not db.query(query) then
		player:sendTextMessage(MESSAGE_FAILURE, "[Arena Shop] Purchase failed. Try again.")
		return
	end

	-- Give item
	local addedItem = player:addItem(shopItem.itemId, 1)
	if addedItem then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
			string.format("[Arena Shop] You purchased %s for %d Arena Points!", shopItem.name, shopItem.cost))
	else
		-- Refund if inventory full
		db.query(string.format(
			"UPDATE `arena_players` SET `arena_points` = `arena_points` + %d WHERE `player_id` = %d",
			shopItem.cost, player:getGuid()
		))
		player:sendTextMessage(MESSAGE_FAILURE, "[Arena Shop] Your inventory is full!")
	end
end

function arenaRewards.onSay(player, words, param)
	if not player then
		return false
	end

	local args = param:lower():split(" ")
	local action = args[1] or "list"

	if action == "buy" then
		local itemId = tonumber(args[2])
		if not itemId then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena Shop] Usage: !arena-shop buy <id>")
			return true
		end
		buyItem(player, itemId)
	else
		showShop(player)
	end

	return true
end

arenaRewards:groupType("normal")
arenaRewards:register()

-- ============================================
-- Arena Title TalkAction (!arena-title)
-- ============================================

local arenaTitle = TalkAction("!arena-title")

function arenaTitle.onSay(player, words, param)
	if not player then
		return false
	end

	local stats = player:arenaGetStats()
	if not stats then
		player:sendTextMessage(MESSAGE_FAILURE, "[Arena] No arena profile yet. Play a match first!")
		return true
	end

	local currentTitle = ArenaConfig.getTitleForMMR(stats.mmr)
	local nextTitle = nil

	for i, t in ipairs(ArenaConfig.titles) do
		if stats.mmr < t.minMMR then
			nextTitle = t
			break
		end
	end

	local msg = "[Arena Title]\n"
	msg = msg .. "Current Title: " .. currentTitle .. "\n"
	msg = msg .. "MMR: " .. stats.mmr .. "\n"

	if nextTitle then
		local needed = nextTitle.minMMR - stats.mmr
		msg = msg .. "Next Title: " .. nextTitle.name .. " (need " .. needed .. " more MMR)\n"
	else
		msg = msg .. "You have reached the highest title!\n"
	end

	msg = msg .. "\nAll Titles:\n"
	for _, t in ipairs(ArenaConfig.titles) do
		local marker = (stats.mmr >= t.minMMR) and "✓" or " "
		msg = msg .. string.format("  [%s] %-12s (MMR %d+)\n", marker, t.name, t.minMMR)
	end

	player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
	return true
end

arenaTitle:groupType("normal")
arenaTitle:register()
