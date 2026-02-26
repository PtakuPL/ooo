local function testSay(player, creature, npcHandler, npc)
  creature:sayLocalized("scripts.say_concat_fixture.say_3", TALKTYPE_SAY, {player:getName()})
  creature:sayLocalized("scripts.say_concat_fixture.say_2", TALKTYPE_MONSTER_SAY, {55})
  npcHandler:sayLocalized("scripts.say_concat_fixture.say_1", npc, player, {player:getLevel()})
  npcHandler:say(dynamicMessage, npc, player)
end
