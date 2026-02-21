#include <functional>
target_sources(${PROJECT_NAME}_lib PRIVATE
    functions/game_reload.cpp
    game.cpp
    bank/bank.cpp
    movement/position.cpp
    movement/teleport.cpp
    scheduling/events_scheduler.cpp
    scheduling/dispatcher.cpp
    scheduling/task.cpp
    scheduling/save_manager.cpp
    zones/zone.cpp
    arena/arena_system.cpp
    arena/arena_match.cpp
    arena/arena_matchmaking.cpp
)
