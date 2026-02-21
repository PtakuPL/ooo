-- Arena PvP Rewards System
-- Handles: Arena Point shop, title awarding, achievement tracking
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

local arenaRewards = TalkAction("!arena-shop", "!arenashop")

local function showShop(player)
local stats = player:arenaGetStats()
local points = stats and stats.arenaPoints or 0

local msg = player:getTranslation("arena.shop.header", {tostring(points)}) .. "\n\n"
msg = msg .. player:getTranslation("arena.shop.columns") .. "\n"
msg = msg .. string.rep("-", 56) .. "\n"

for _, item in ipairs(ArenaConfig.shop) do
ame = item.i18nKey and player:getTranslation(item.i18nKey) or item.name
g.format("%-4d %-30s %-10d %-10s\n",
ame, item.cost, item.category)
end
msg = msg .. "\n" .. player:getTranslation("arena.shop.buy_hint")

player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

local function buyItem(player, itemIndex)
local shopItem = nil
for _, item in ipairs(ArenaConfig.shop) do
dex then
d
end

if not shopItem then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.shop.invalid_id")

end

local stats = player:arenaGetStats()
local points = stats and stats.arenaPoints or 0

if points < shopItem.cost then
dLocalizedTextMessage(MESSAGE_FAILURE,
a.shop.not_enough", {tostring(shopItem.cost), tostring(points)})

end

-- Deduct points via DB
local query = string.format(
a_players` SET `arena_points` = `arena_points` - %d WHERE `player_id` = %d AND `arena_points` >= %d",
ot db.query(query) then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.shop.failed")

end

-- Give item
local addedItem = player:addItem(shopItem.itemId, 1)
if addedItem then
ame = shopItem.i18nKey and player:getTranslation(shopItem.i18nKey) or shopItem.name
dLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
a.shop.success", {itemName, tostring(shopItem.cost)})
else
d if inventory full
g.format(
a_players` SET `arena_points` = `arena_points` + %d WHERE `player_id` = %d",
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.shop.inventory_full")
end
end

function arenaRewards.onSay(player, words, param)
if not player then
 false
end

local args = param:lower():split(" ")
local action = args[1] or "list"

if action == "buy" then
umber(args[2])
ot itemId then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.shop.buy_usage")
 true
d
d

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
 false
end

local stats = player:arenaGetStats()
if not stats then
dLocalizedTextMessage(MESSAGE_FAILURE, "arena.title.no_profile")
 true
end

local currentTitleName = ArenaConfig.getTitleForMMR(stats.mmr)
local currentTitleKey = ArenaConfig.getTitleI18nKey(currentTitleName)
local currentTitle = player:getTranslation(currentTitleKey)
local nextTitle = nil

for i, t in ipairs(ArenaConfig.titles) do
MMR then
extTitle = t
d
end

local msg = player:getTranslation("arena.title.header") .. "\n"
msg = msg .. player:getTranslation("arena.title.current", {currentTitle}) .. "\n"
msg = msg .. "MMR: " .. stats.mmr .. "\n"

if nextTitle then
eeded = nextTitle.minMMR - stats.mmr
extTitleKey = ArenaConfig.getTitleI18nKey(nextTitle.name)
extTitleName = player:getTranslation(nextTitleKey)
slation("arena.title.next", {nextTitleName, tostring(needed)}) .. "\n"
else
slation("arena.title.highest") .. "\n"
end

msg = msg .. "\n" .. player:getTranslation("arena.title.all_titles") .. "\n"
for _, t in ipairs(ArenaConfig.titles) do
aConfig.getTitleI18nKey(t.name)
ame = player:getTranslation(titleKey)
MMR) and "✓" or " "
g.format("  [%s] %-12s (MMR %d+)\n", marker, titleName, t.minMMR)
end

player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
return true
end

arenaTitle:groupType("normal")
arenaTitle:register()
