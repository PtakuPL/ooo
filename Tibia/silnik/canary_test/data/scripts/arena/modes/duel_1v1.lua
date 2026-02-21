-- Arena PvP - Mode: 1v1 Duel
-- Specific rules for 1v1 arena duels

ArenaModes = ArenaModes or {}

ArenaModes.Duel1v1 = {
	mode = Arena.MODE_1V1,
	name = "1v1 Duel",
	playersRequired = 2,
	teams = 2,
	playersPerTeam = 1,
	duration = 5 * 60,  -- 5 minutes
	respawn = false,

	-- Spawn positions (relative to arena center)
	-- These will be overridden by map-specific configs
	spawnOffsets = {
		[1] = { x = -5, y = 0 },  -- Team 1
		[2] = { x = 5,  y = 0 },  -- Team 2
	},

	--- Check win condition for 1v1
	---@param matchData table
	---@return number? winnerTeam (nil = not decided yet)
	checkWin = function(matchData)
		-- In 1v1, first death = loss
		for _, pData in ipairs(matchData.players) do
			if pData.deaths > 0 then
				-- The other team wins
				return (pData.team == 1) and 2 or 1
			end
		end
		return nil
	end,

	--- Get result description
	---@param matchData table
	---@return string
	getResultDescription = function(matchData)
		return "1v1 Duel - First death loses"
	end,
}
