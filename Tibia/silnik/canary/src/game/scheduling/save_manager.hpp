#ifndef __SRC_GAME_SCHEDULING_SAVE_MANAGER_HPP_
#define __SRC_GAME_SCHEDULING_SAVE_MANAGER_HPP_

#include "pch.hpp"
#include <parallel_hashmap/phmap.h>
#include <atomic>
#include <thread>
#include <chrono>
#include <cstdint>
#include <string>
#include <memory>

#include <cstdint>
#include <string>
#include <memory>

/**
 * Canary - A free and open-source MMORPG server emulator
 * Copyright (©) 2019-2024 OpenTibiaBR <opentibiabr@outlook.com>
 * Repository: https://github.com/opentibiabr/canary
 * License: https://github.com/opentibiabr/canary/blob/main/LICENSE
 * Contributors: https://github.com/opentibiabr/canary/graphs/contributors
 * Website: https://docs.opentibiabr.com/
 */

#pragma once

#include "lib/thread/thread_pool.hpp"
#include <string>
#include <vector>
#include <map>
#include <cstdint>

class KVStore;
class Logger;
class Game;
class Player;
class Guild;

class SaveManager {
public:
	explicit SaveManager(ThreadPool &threadPool, KVStore &kvStore, Logger &logger, Game &game);

	SaveManager(const SaveManager &) = delete;
	void operator=(const SaveManager &) = delete;

	static SaveManager &getInstance();

	void saveAll();
	void scheduleAll();

	bool savePlayer(std::shared_ptr<Player> player);
	void saveGuild(std::shared_ptr<Guild> guild);

private:
	void saveMap();
	void saveKV();

	void schedulePlayer(std::weak_ptr<Player> player);
	bool doSavePlayer(std::shared_ptr<Player> player);

	std::atomic<std::chrono::steady_clock::time_point> m_scheduledAt;
	phmap::parallel_flat_hash_map<uint32_t, std::chrono::steady_clock::time_point> m_playerMap;

	ThreadPool &threadPool;
	KVStore &kv;
	Logger &logger;
	Game &game;
};

constexpr auto g_saveManager = SaveManager::getInstance;

#endif // __SRC_GAME_SCHEDULING_SAVE_MANAGER_HPP_
