local function testBroadcast(player)
  Game.broadcastLocalizedMessage("scripts.broadcast_concat_fixture.broadcast_2", MESSAGE_EVENT_ADVANCE, {10})
  Game.broadcastLocalizedMessage("scripts.broadcast_concat_fixture.broadcast_1", MESSAGE_EVENT_ADVANCE, {player:getName()})
  Game.broadcastMessage(dynamicMessage, MESSAGE_EVENT_ADVANCE)
end
