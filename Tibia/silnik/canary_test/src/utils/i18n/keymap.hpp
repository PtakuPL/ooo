#pragma once

#include <filesystem>
#include <mutex>
#include <string>
#include <string_view>
#include <unordered_map>

namespace i18n {

class Keymap {
public:
	static Keymap &getInstance();

	// Thread-safe, cheap if values unchanged. If path changes, mapping cache is cleared.
	void configure(bool enabled, std::filesystem::path keymapPath);

	// Returns compact id if mapping exists and enabled; otherwise returns input key.
	[[nodiscard]] std::string toCompactOrSelf(std::string_view key) const;

	[[nodiscard]] bool isEnabled() const;
	[[nodiscard]] bool isLoaded() const;

private:
	Keymap() = default;

	void ensureLoadedUnlocked() const;

	mutable std::mutex mutex;
	mutable bool enabled = false;
	mutable bool loaded = false;
	mutable std::filesystem::path path = std::filesystem::path("i18n") / "keymap.json";
	mutable std::unordered_map<std::string, std::string> semanticToCompact;
};

Keymap &g_keymap();

} // namespace i18n
