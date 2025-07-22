#include "pch.hpp"
/**
 * Canary - A free and open-source MMORPG server emulator
 * Copyright (©) 2019-2024 OpenTibiaBR <opentibiabr@outlook.com>
 * Repository: https://github.com/opentibiabr/canary
 * License: https://github.com/opentibiabr/canary/blob/main/LICENSE
 * Contributors: https://github.com/opentibiabr/canary/graphs/contributors
 * Website: https://docs.opentibiabr.com/
 */



#include <cstdint>             // dodaj to, jeśli jeszcze nie ma
#include <memory>              // dodaj to, jeśli jeszcze nie ma
#include <string> 

#include "account/account_repository.hpp"
#include "lib/di/container.hpp"
#include "enums/account_coins.hpp" // ← tutaj dodaj ten include

AccountRepository &AccountRepository::getInstance() {
	return inject<AccountRepository>();
}
