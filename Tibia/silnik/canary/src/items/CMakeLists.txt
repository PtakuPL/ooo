#include <functional>
target_sources(${PROJECT_NAME}_lib PRIVATE
    bed.cpp
    containers/container.cpp
    containers/depot/depotchest.cpp
    containers/depot/depotlocker.cpp
    containers/inbox/inbox.cpp
    containers/mailbox/mailbox.cpp
    containers/rewards/reward.cpp
    containers/rewards/rewardchest.cpp
    cylinder.cpp
    decay/decay.cpp
    item.cpp
    items.cpp
    functions/item/attribute.cpp
    functions/item/custom_attribute.cpp
    functions/item/item_parse.cpp
    thing.cpp
    tile.cpp
    trashholder.cpp
    weapons/weapons.cpp
)
