#include "utils/i18n/keymap.hpp"

#include <fstream>

#include <nlohmann/json.hpp>

#include "lib/logging/log_with_spd_log.hpp"

namespace i18n {

Keymap &Keymap::getInstance() {
	static Keymap instance;
	return instance;
}

Keymap &g_keymap() {
	return Keymap::getInstance();
}

void Keymap::configure(bool enable, std::filesystem::path keymapPath) {
	std::error_code ec;
	const auto normalized = keymapPath.empty() ? path : std::filesystem::weakly_canonical(keymapPath, ec);
	const auto finalPath = keymapPath.empty() ? path : (ec ? keymapPath : normalized);

	std::scoped_lock lock(mutex);
	if (enabled == enable && finalPath == path) {
		return;
	}

	enabled = enable;
	if (finalPath != path) {
		path = finalPath;
		loaded = false;
		semanticToCompact.clear();
	}
}

bool Keymap::isEnabled() const {
	std::scoped_lock lock(mutex);
	return enabled;
}

bool Keymap::isLoaded() const {
	std::scoped_lock lock(mutex);
	return loaded;
}

std::string Keymap::toCompactOrSelf(std::string_view key) const {
	if (key.empty()) {
		return {};
	}

	std::scoped_lock lock(mutex);
	if (!enabled) {
		return std::string(key);
	}

	ensureLoadedUnlocked();
	const auto it = semanticToCompact.find(std::string(key));
	if (it == semanticToCompact.end()) {
		return std::string(key);
	}
	return it->second;
}

void Keymap::ensureLoadedUnlocked() const {
	if (loaded) {
		return;
	}

	loaded = true;
	semanticToCompact.clear();

	std::ifstream stream(path);
	if (!stream.is_open()) {
		g_logger().warn("[i18n::Keymap] Cannot open keymap file: {}", path.string());
		return;
	}

	try {
		const auto json = nlohmann::json::parse(stream, nullptr, true, true);
		if (!json.is_object()) {
			g_logger().warn("[i18n::Keymap] keymap.json is not an object: {}", path.string());
			return;
		}

		semanticToCompact.reserve(json.size());
		for (const auto &[semanticKey, compactValue] : json.items()) {
			if (!compactValue.is_string()) {
				continue;
			}
			semanticToCompact.emplace(semanticKey, compactValue.get<std::string>());
		}

		g_logger().info("[i18n::Keymap] Loaded {} mappings from {}", semanticToCompact.size(), path.string());
	} catch (const std::exception &e) {
		g_logger().warn("[i18n::Keymap] Failed to parse {}: {}", path.string(), e.what());
	}
}

} // namespace i18n
