local monsters = { "unbound blightwalker", "unbound demon", "unbound demon outcast", "unbound defiler" }
local possessedTree = CreatureEvent("PossessedTree")
function possessedTree.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	local targetMonster = creature:getMonster()
	if not targetMonster then
		return true
	end
	targetMonster:getPosition():sendMagicEffect(CONST_ME_SMALLPLANTS)
	local monster = Game.createMonster(monsters[math.random(#monsters)], targetMonster:getPosition(), true, true)
	if monster then
		monster:sayLocalized("quests.forgotten_knowledge.tree_destruction", TALKTYPE_MONSTER_SAY, false, nil, nil, {monster:getName():lower()})
	end
	addEvent(Game.createMonster, 60 * 1000, "possessed tree", targetMonster:getPosition(), true, true)
	return true
end

possessedTree:register()
