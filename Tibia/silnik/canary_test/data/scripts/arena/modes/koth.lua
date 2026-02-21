-- Arena PvP - Mode: King of the Hill (KotH)
-- Teams contest a central control point. Holding it accumulates score.
-- First team to reach target score wins.

ArenaModes = ArenaModes or {}

ArenaModes.KotH = {
	mode = Arena.MODE_KOTH,
	name = "King of the Hill",
	playersRequired = 4,  -- 2v2 minimum
	maxPlayers = 6,
	teams = 2,
	duration = 8 * 60,  -- 8 minutes
	respawn = true,
	respawnDelay = 8,
	scoreToWin = 100,
	scorePerTick = 1,  -- points per 2-second tick while controlling hill

	-- Hill center (relative to arena center)
	hillOffset = { x = 0, y = 0 },
	hillRadius = 3,

	--- Check win condition: first to target score
	---@param matchData table
	---@return number? winnerTeam
	checkWin = function(matchData)
		if not matchData.teamScores then
			return nil
		end

		if (matchData.teamScores[1] or 0) >= 100 then return 1 end
		if (matchData.teamScores[2] or 0) >= 100 then return 2 end
		return nil
	end,

	--- Determine winner at time expiry
	---@param matchData table
	---@return number winnerTeam
	determineWinner = function(matchData)
		local score1 = (matchData.teamScores and matchData.teamScores[1]) or 0
		local score2 = (matchData.teamScores and matchData.teamScores[2]) or 0

		if score1 > score2 then return 1, "Score: " .. score1 .. "-" .. score2 end
		if score2 > score1 then return 2, "Score: " .. score2 .. "-" .. score1 end
		return 0, "Draw: " .. score1 .. "-" .. score2
	end,
}
