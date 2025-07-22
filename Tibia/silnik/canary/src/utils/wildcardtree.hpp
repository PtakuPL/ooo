#include "pch.hpp"
#include "lua/global/shared_object.hpp"
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

#include "declarations.hpp"
#include <string>
#include <vector>
#include <map>
#include <cstdint>

class WildcardTreeNode final : public SharedObject {
public:
	explicit WildcardTreeNode(bool initBreakpoint) :
		breakpoint(initBreakpoint) { }
	WildcardTreeNode(WildcardTreeNode &&other) noexcept = default;

	// non-copyable
	WildcardTreeNode(const WildcardTreeNode &) = delete;
	WildcardTreeNode &operator=(const WildcardTreeNode &) = delete;

	std::shared_ptr<WildcardTreeNode> getChild(char ch);
	std::shared_ptr<WildcardTreeNode> getChild(char ch) const;
	std::shared_ptr<WildcardTreeNode> addChild(char ch, bool breakpoint);

	void insert(const std::string &str);
	void remove(const std::string &str);

	ReturnValue findOne(const std::string &query, std::string &result) const;

private:
	std::map<char, std::shared_ptr<WildcardTreeNode>> children;
	bool breakpoint;
};
