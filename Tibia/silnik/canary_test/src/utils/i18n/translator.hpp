#pragma once

#include <chrono>
#include <filesystem>
#include <mutex>
#include <string>
#include <string_view>
#include <unordered_map>
#include <vector>

#include <nlohmann/json_fwd.hpp>

namespace i18n {

class Translator {
public:
	static Translator &getInstance();

	void setSearchPaths(std::vector<std::filesystem::path> paths);
	void setFallbackLocale(std::string locale);
	[[nodiscard]] const std::string &getFallbackLocale() const;

	void loadLocale(const std::string &locale) const;
	[[nodiscard]] bool isLocaleLoaded(const std::string &locale) const;

	[[nodiscard]] std::string get(const std::string &key, const std::string &locale = "en") const;
	[[nodiscard]] std::string format(const std::string &key, const std::string &locale, const std::vector<std::string> &args) const;

	[[nodiscard]] static const std::vector<std::string> &supportedLocales();

private:
	Translator();

	void ensureLocaleLoaded(const std::string &locale) const;
	void loadLocaleUnlocked(const std::string &locale) const;
	[[nodiscard]] std::string lookupUnlocked(const std::string &locale, const std::string &key) const;
	[[nodiscard]] std::filesystem::path resolveLocalePath(const std::string &locale) const;
	static void flattenJson(const nlohmann::json &node, const std::string &prefix, std::unordered_map<std::string, std::string> &output);

	struct LocaleStore {
		bool loaded = false;
		std::unordered_map<std::string, std::string> entries;
		std::chrono::system_clock::time_point loadedAt;
	};

	mutable std::unordered_map<std::string, LocaleStore> locales;
	mutable std::mutex mutex;
	std::vector<std::filesystem::path> searchPaths;
	std::string fallbackLocale = "en";
};

Translator &g_translator();

} // namespace i18n
