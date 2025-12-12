#include "utils/i18n/translator.hpp"

#include <array>
#include <fstream>
#include <system_error>

#include <fmt/format.h>
#include <fmt/ranges.h>
#include <fmt/std.h>
#include <nlohmann/json.hpp>

#include "lib/logging/log_with_spd_log.hpp"

namespace {
constexpr std::array DEFAULT_SEARCH_PATHS = {
	std::filesystem::path("data-otservbr-global/i18n"),
	std::filesystem::path("data/i18n"),
	std::filesystem::path("i18n")
};

const std::vector<std::string> &supportedLocaleList() {
	// Ujednolicona lista 53+ języków zgodna z klientem (I18N) – rozszerzona, aby serwer obsługiwał te same locale.
	static const std::vector<std::string> locales = {
		// Western European
		"en", "de", "es", "fr", "it", "pt", "nl", "sv", "da", "no", "fi", "is",
		// Eastern European / Slavic
		"pl", "cs", "hu", "ro", "bg", "sk", "hr", "sr", "sl", "sq", "mk", "ru", "uk",
		// Baltic
		"lt", "lv", "et",
		// Asian
		"zh", "ja", "ko", "vi", "th", "hi", "id", "ms", "fil", "bn",
		// Middle Eastern (RTL)
		"ar", "he", "fa", "tr",
		// Caucasus
		"ka", "hy", "az",
		// Central Asian
		"kk", "uz",
		// African
		"af", "sw",
		// Other
		"eu", "ca", "gl", "el"
	};
	return locales;
}
} // namespace

namespace i18n {

Translator::Translator() :
	searchPaths(DEFAULT_SEARCH_PATHS.begin(), DEFAULT_SEARCH_PATHS.end()) { }

Translator &Translator::getInstance() {
	static Translator instance;
	return instance;
}

Translator &g_translator() {
	return Translator::getInstance();
}

void Translator::setSearchPaths(std::vector<std::filesystem::path> paths) {
	std::vector<std::filesystem::path> normalized;
	normalized.reserve(paths.size());

	for (auto &path : paths) {
		if (path.empty()) {
			continue;
		}

		std::error_code ec;
		const auto canonical = std::filesystem::weakly_canonical(path, ec);
		normalized.emplace_back(ec ? path : canonical);
	}

	if (normalized.empty()) {
		normalized.assign(DEFAULT_SEARCH_PATHS.begin(), DEFAULT_SEARCH_PATHS.end());
	}

	std::scoped_lock lock(mutex);
	searchPaths = std::move(normalized);
	locales.clear();
}

void Translator::setFallbackLocale(std::string locale) {
	if (locale.empty()) {
		return;
	}

	std::scoped_lock lock(mutex);
	fallbackLocale = std::move(locale);
}

const std::string &Translator::getFallbackLocale() const {
	return fallbackLocale;
}

void Translator::loadLocale(const std::string &locale) const {
	if (locale.empty()) {
		return;
	}

	std::scoped_lock lock(mutex);
	loadLocaleUnlocked(locale);
}

bool Translator::isLocaleLoaded(const std::string &locale) const {
	std::scoped_lock lock(mutex);
	const auto it = locales.find(locale);
	return it != locales.end() && it->second.loaded;
}

std::string Translator::get(const std::string &key, const std::string &locale) const {
	return format(key, locale, {});
}

std::string Translator::format(const std::string &key, const std::string &locale, const std::vector<std::string> &args) const {
	if (key.empty()) {
		return {};
	}

	const auto resolvedLocale = locale.empty() ? fallbackLocale : locale;
	ensureLocaleLoaded(resolvedLocale);
	if (resolvedLocale != fallbackLocale) {
		ensureLocaleLoaded(fallbackLocale);
	}

	std::string translation;
	{
		std::scoped_lock lock(mutex);
		translation = lookupUnlocked(resolvedLocale, key);
		if (translation.empty() && resolvedLocale != fallbackLocale) {
			translation = lookupUnlocked(fallbackLocale, key);
		}
	}

	if (translation.empty()) {
		g_logger().warn("Missing translation for key '{}' (locale '{}')", key, resolvedLocale);
		return key;
	}

	if (args.empty()) {
		return translation;
	}

	fmt::dynamic_format_arg_store<fmt::format_context> store;
	for (const auto &arg : args) {
		store.push_back(arg);
	}

	try {
		return fmt::vformat(translation, store);
	} catch (const fmt::format_error &err) {
		g_logger().warn("Failed to format translation '{}' (locale '{}'): {}", key, resolvedLocale, err.what());
		return translation;
	}
}

const std::vector<std::string> &Translator::supportedLocales() {
	return supportedLocaleList();
}

void Translator::ensureLocaleLoaded(const std::string &locale) const {
	if (locale.empty()) {
		return;
	}

	std::scoped_lock lock(mutex);
	const auto it = locales.find(locale);
	if (it != locales.end() && it->second.loaded) {
		return;
	}

	loadLocaleUnlocked(locale);
}

void Translator::loadLocaleUnlocked(const std::string &locale) {
	if (locale.empty()) {
		return;
	}

	auto &store = locales[locale];
	if (store.loaded) {
		return;
	}

	store.entries.clear();
	const auto localePath = resolveLocalePath(locale);
	if (localePath.empty() || !std::filesystem::exists(localePath)) {
		g_logger().warn("Locale '{}' path not found (looked in {}).", locale, fmt::join(searchPaths, ", "));
		store.loaded = true;
		return;
	}

	try {
		for (const auto &entry : std::filesystem::recursive_directory_iterator(localePath)) {
			if (!entry.is_regular_file() || entry.path().extension() != ".json") {
				continue;
			}

			std::ifstream stream(entry.path());
			if (!stream.is_open()) {
				g_logger().warn("Failed to open translation file: {}", entry.path().string());
				continue;
			}

			try {
				const auto json = nlohmann::json::parse(stream, nullptr, true, true);
				flattenJson(json, "", store.entries);
			} catch (const std::exception &err) {
				g_logger().warn("Failed to parse translation file {}: {}", entry.path().string(), err.what());
			}
		}
	} catch (const std::exception &err) {
		g_logger().warn("Failed to iterate locale directory {}: {}", localePath.string(), err.what());
	}

	store.loaded = true;
	store.loadedAt = std::chrono::system_clock::now();
	g_logger().debug("Loaded locale '{}' with {} entries.", locale, store.entries.size());
}

std::string Translator::lookupUnlocked(const std::string &locale, const std::string &key) const {
	const auto it = locales.find(locale);
	if (it == locales.end()) {
		return {};
	}

	const auto entryIt = it->second.entries.find(key);
	if (entryIt == it->second.entries.end()) {
		return {};
	}

	return entryIt->second;
}

std::filesystem::path Translator::resolveLocalePath(const std::string &locale) const {
	for (const auto &basePath : searchPaths) {
		if (basePath.empty()) {
			continue;
		}

		const std::filesystem::path candidate = basePath / locale;
		std::error_code ec;
		if (std::filesystem::exists(candidate, ec) && !ec) {
			return candidate;
		}
	}

	return {};
}

void Translator::flattenJson(const nlohmann::json &node, const std::string &prefix, std::unordered_map<std::string, std::string> &output) {
	if (node.is_string()) {
		output[prefix] = node.get<std::string>();
		return;
	}

	if (node.is_primitive()) {
		output[prefix] = node.dump();
		return;
	}

	if (node.is_array()) {
		for (std::size_t idx = 0; idx < node.size(); ++idx) {
			const auto childKey = prefix.empty() ? std::to_string(idx) : fmt::format("{}.{}", prefix, idx);
			flattenJson(node[idx], childKey, output);
		}
		return;
	}

	for (auto it = node.begin(); it != node.end(); ++it) {
		const auto childKey = prefix.empty() ? it.key() : fmt::format("{}.{}", prefix, it.key());
		flattenJson(it.value(), childKey, output);
	}
}

} // namespace i18n
