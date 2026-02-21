-- Arena PvP - Mode: Capture The Flag (CTF)
-- Two teams fight to capture the enemy flag and return it to their base.
-- First team to 3 captures wins, or most captures when time expires.

ArenaModes = ArenaModes or {}

ArenaModes.CTF = {
	mode = Arena.MODE_CTF,
	name = "Capture The Flag",
	playersRequired = 6,  -- 3v3
	teams = 2,
	playersPerTeam = 3,
	duration = 10 * 60,  -- 10 minutes
	respawn = true,
	respawnDelay = 10,
	capturesToWin = 3,

	-- Flag positions (relative to arena center)
	flagPositions = {
		[1] = { x = -8, y = 0 },  -- Team 1 flag
		[2] = { x = 8,  y = 0 },  -- Team 2 flag
	},

	--- Check win condition: first to 3 captures
	---@param matchData table (needs captures field per team)
	---@return number? winnerTeam
	checkWin = function(matchData)
		if not matchData.teamScores then
			return nil
		end

		if (matchData.teamScores[1] or 0) >= 3 then return 1 end
		if (matchData.teamScores[2] or 0) >= 3 then return 2 end
		return nil
	end,

	--- Determine winner at time expiry
	---@param matchData table
	---@return number winnerTeam
	determineWinner = function(matchData)
		local score1 = (matchData.teamScores and matchData.teamScores[1]) or 0
		local score2 = (matchData.teamScores and matchData.teamScores[2]) or 0

		if score1 > score2 then return 1, "Captures: " .. score1 .. "-" .. score2 end
		if score2 > score1 then return 2, "Captures: " .. score2 .. "-" .. score1 end
		return 0, "Draw: " .. score1 .. "-" .. score2  -- tie
	end,
}
