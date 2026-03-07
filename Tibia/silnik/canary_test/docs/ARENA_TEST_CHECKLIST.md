# Arena PvP — Manual Test Checklist (Pre-Alpha)

> **Target:** Internal testing before alpha release  
> **Requires:** 2+ game clients, GM account, compiled server with arena C++ code

---

## Prerequisites

- [ ] Server starts without errors (`arenaSystemEnabled = true` in config.lua)
- [ ] Arena module loads in log: `[Arena] System initialized`
- [ ] Database tables exist: `arena_players`, `arena_matches`, `arena_match_players`, `arena_queue`, `arena_seasons`
- [ ] Arena NPC "Arena Master" spawned on map
- [ ] At least 2 test characters at level 50+

---

## 1. Basic Queue Tests

### 1.1 Join / Leave Queue
- [ ] `!arena join 1v1` — Player joins 1v1 queue, gets confirmation message
- [ ] `!arena status` — Shows "In queue for: 1v1 Duel"
- [ ] `!arena leave` — Player leaves queue, gets confirmation
- [ ] `!arena join 2v2` — Works for 2v2 mode
- [ ] `!arena join` — Shows help/mode list (no mode specified)

### 1.2 Edge Cases
- [ ] Player below level 50 tries `!arena join 1v1` — Blocked with message
- [ ] Player already in queue tries `!arena join 1v1` again — Error message
- [ ] Player not in queue tries `!arena leave` — Error message
- [ ] Player types invalid mode `!arena join xyz` — Error with valid modes list

---

## 2. Matchmaking Tests (1v1)

### 2.1 Basic Match
- [ ] Player A: `!arena join 1v1` (MMR ~1000)
- [ ] Player B: `!arena join 1v1` (MMR ~1000)
- [ ] Within 5 seconds: Both get "Match found!" message
- [ ] Both teleported to arena area
- [ ] Countdown message appears (3, 2, 1, FIGHT!)
- [ ] Players can attack each other

### 2.2 Match Result
- [ ] Player A kills Player B
- [ ] Winner gets "Victory!" message with MMR change
- [ ] Loser gets "Defeat!" message with MMR change
- [ ] Both teleported back to their original positions
- [ ] Winner's stats updated: `!arena stats` shows +1 win, MMR increased
- [ ] Loser's stats updated: `!arena stats` shows +1 loss, MMR decreased

### 2.3 Match Timeout
- [ ] Both players join match but nobody dies
- [ ] After 5 minutes: Match ends as draw
- [ ] Both teleported back

---

## 3. Statistics Tests

### 3.1 Player Stats
- [ ] `!arena stats` — Shows own W/L/D, MMR, win rate, KDR
- [ ] `!arena stats PlayerName` — Shows another player's stats

### 3.2 Ranking
- [ ] `!arena ranking` — Shows top players by MMR
- [ ] After a few matches, rankings reflect actual results

### 3.3 History
- [ ] `!arena history` — Shows recent match history with results

---

## 4. NPC Arena Master Tests

- [ ] Talk to Arena Master NPC
- [ ] Say "arena" → NPC responds with arena info (in player's language)
- [ ] Say "join" → NPC explains how to join
- [ ] Say "stats" → NPC shows player stats
- [ ] Say "ranking" → NPC shows ranking
- [ ] Say "modes" → NPC lists available modes

---

## 5. Security Tests (Phase 8)

### 5.1 Teleport Blocking
- [ ] During match: Cast Levitate — blocked with message
- [ ] During match: Use Magic Rope — blocked with message
- [ ] During match: Use teleport scroll — blocked with message

### 5.2 Item Restrictions
- [ ] During match: Try to use exercise weapon — blocked
- [ ] Items outside arena inventory restrictions work as expected

### 5.3 Party Blocking
- [ ] During match: Try to invite someone to party — blocked

### 5.4 AFK Detection
- [ ] During match: Stand still for 30s — Warning message appears
- [ ] Continue standing still for 60s total — Force-lose, teleported out

### 5.5 Logout
- [ ] During match: Try to logout — Warning about loss
- [ ] Actually disconnect — Match registers as loss for disconnected player

### 5.6 Death Prevention
- [ ] Dying in arena does NOT lose exp
- [ ] Dying in arena does NOT lose items
- [ ] No skull applied during arena match

---

## 6. Anti-Cheat Tests (Phase 8)

### 6.1 Repeat Opponent Detection
- [ ] Play 3 matches with same opponent pair → All count
- [ ] Play 4th match with same opponent → MMR gain should be 0 or restricted

### 6.2 Match Duration Validation
- [ ] Match that ends in <30 seconds → Should not count for MMR (flagged)

### 6.3 Daily MMR Cap
- [ ] Play many matches and gain 200+ MMR in one day → Further gains capped

---

## 7. Admin Tests

### 7.1 GM Commands
- [ ] `!arena-admin info PlayerName` — Shows player's arena info
- [ ] `!arena-admin stats` — Shows system stats (active matches, queue sizes)
- [ ] `!arena-admin setmmr PlayerName 1500` — Sets player's MMR
- [ ] `!arena-admin addpoints PlayerName 100` — Adds arena points
- [ ] `!arena-admin reset PlayerName` — Resets player's arena stats
- [ ] `!arena-admin broadcast Message` — Broadcasts to all arena players

### 7.2 Logging
- [ ] `logs/arena.log` file exists and has entries after matches
- [ ] Log entries include: match create, match result, queue join/leave
- [ ] Suspicious actions logged with SECURITY level

---

## 8. Shop Tests

### 8.1 Arena Shop
- [ ] `!arena-shop` — Shows available items and prices
- [ ] `!arena-shop buy 1` — Buys item if enough arena points
- [ ] `!arena-shop buy 1` — Fails if not enough points, shows error

### 8.2 Title
- [ ] `!arena-title` — Shows current title based on MMR
- [ ] After reaching MMR threshold, title changes automatically

---

## 9. i18n Tests

- [ ] Player with `en` locale sees English messages
- [ ] Player with `pl` locale sees Polish messages
- [ ] NPC dialogs respect player locale
- [ ] All arena messages use localized strings (no hardcoded English)

---

## 10. Stress / Edge Cases

- [ ] Server restart while player is in queue → Player state cleaned up
- [ ] Server restart while match is in progress → Match handled gracefully
- [ ] 2 players join queue, one disconnects before match starts → Queue cleaned
- [ ] Multiple 1v1 matches running simultaneously
- [ ] Player tries `!arena join 1v1` while already in a match → Blocked

---

## Results Template

| Test Section | Pass | Fail | Notes |
|---|---|---|---|
| 1. Queue | /5 | /5 | |
| 2. Matchmaking | /8 | /8 | |
| 3. Statistics | /4 | /4 | |
| 4. NPC | /6 | /6 | |
| 5. Security | /9 | /9 | |
| 6. Anti-Cheat | /3 | /3 | |
| 7. Admin | /8 | /8 | |
| 8. Shop | /3 | /3 | |
| 9. i18n | /4 | /4 | |
| 10. Edge Cases | /5 | /5 | |
| **TOTAL** | **/55** | **/55** | |

---

*Generated: 2026-02-21*
