#include <functional>
target_sources(${PROJECT_NAME}_lib PRIVATE
    combat/combat_functions.cpp
    combat/condition_functions.cpp
    combat/spell_functions.cpp
    combat/variant_functions.cpp
    creature_functions.cpp
    monster/charm_functions.cpp
    monster/loot_functions.cpp
    monster/monster_functions.cpp
    monster/monster_spell_functions.cpp
    monster/monster_type_functions.cpp
    npc/npc_functions.cpp
    npc/npc_type_functions.cpp
    npc/shop_functions.cpp
    player/group_functions.cpp
    player/guild_functions.cpp
    player/mount_functions.cpp
    player/party_functions.cpp
    player/player_functions.cpp
    player/vocation_functions.cpp
)
