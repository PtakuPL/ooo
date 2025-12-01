function init()
    connect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })
    if g_game.isOnline() then
        online()
    end
end

function terminate()
    disconnect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })
    offline()
end

function online()
    if g_game.getFeature(GamePlayerMounts) then
        Keybind.new(tr("Movement"), tr("Mount/dismount"), "Ctrl+R", "")
        Keybind.bind(tr("Movement"), tr("Mount/dismount"), {
            {
              type = KEY_DOWN,
              callback = toggleMount,
            }
          })
    end
end

function offline()
    if g_game.getFeature(GamePlayerMounts) then
        Keybind.delete(tr("Movement"), tr("Mount/dismount"))
    end
end

function toggleMount()
    local player = g_game.getLocalPlayer()
    if player then
        player:toggleMount()
    end
end

function mount()
    local player = g_game.getLocalPlayer()
    if player then
        player:mount()
    end
end

function dismount()
    local player = g_game.getLocalPlayer()
    if player then
        player:dismount()
    end
end
