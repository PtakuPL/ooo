#include "utils/i18n/translator.hpp"

#include <algorithm>
#include <array>
#include <cctype>
#include <fstream>
#include <system_error>

#include <fmt/format.h>
#include <fmt/ranges.h>
#include <fmt/std.h>
#include <nlohmann/json.hpp>

#include "lib/logging/log_with_spd_log.hpp"

namespace {
const std::array DEFAULT_SEARCH_PATHS = {
	std::filesystem::path("data-otservbr-global/i18n"),
	std::filesystem::path("data/i18n"),
	std::filesystem::path("i18n")
};

std::string normalizeLocaleForCompare(const std::string &input) {
	std::string normalized;
	normalized.reserve(input.size());

	for (unsigned char ch : input) {
		if (std::isalnum(ch) || ch == '_' || ch == '-') {
			normalized += static_cast<char>(std::tolower(ch));
		}
	}

	std::replace(normalized.begin(), normalized.end(), '-', '_');
	return normalized;
}

std::string canonicalizeLocaleTag(const std::string &input) {
	const auto normalized = normalizeLocaleForCompare(input);
	if (normalized.empty()) {
		return {};
	}

	const auto separator = normalized.find('_');
	std::string language = separator == std::string::npos ? normalized : normalized.substr(0, separator);
	std::string region = separator == std::string::npos ? "" : normalized.substr(separator + 1);
	if (language.empty()) {
		return {};
	}

	// Common legacy aliases.
	if (language == "fil") {
		language = "tl";
	} else if (language == "iw") {
		language = "he";
	} else if (language == "in") {
		language = "id";
	}

	// Canonical Chinese mapping used in datapack directories.
	if (language == "zh") {
		if (region == "tw" || region == "hk" || region == "mo" || region == "hant") {
			return "zh_TW";
		}
		return "zh";
	}

	// We keep only generic Portuguese locale in the server dictionaries.
	if (language == "pt" && !region.empty()) {
		return "pt";
	}

	// We keep only generic English locale in the server dictionaries.
	if (language == "en" && !region.empty()) {
		return "en";
	}

	if (!region.empty() && region.size() == 2 && std::isalpha(static_cast<unsigned char>(region[0])) && std::isalpha(static_cast<unsigned char>(region[1]))) {
		region[0] = static_cast<char>(std::toupper(static_cast<unsigned char>(region[0])));
		region[1] = static_cast<char>(std::toupper(static_cast<unsigned char>(region[1])));
		return language + "_" + region;
	}

	return language;
}

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
		"zh", "zh_TW", "ja", "ko", "vi", "th", "hi", "id", "ms", "tl", "bn",
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

std::string findSupportedLocale(const std::string &localeTag) {
	const auto normalizedTag = normalizeLocaleForCompare(localeTag);
	if (normalizedTag.empty()) {
		return {};
	}

	for (const auto &supported : supportedLocaleList()) {
		if (normalizeLocaleForCompare(supported) == normalizedTag) {
			return supported;
		}
	}

	const auto separator = normalizedTag.find('_');
	if (separator == std::string::npos) {
		return {};
	}

	const auto base = normalizedTag.substr(0, separator);
	for (const auto &supported : supportedLocaleList()) {
		if (normalizeLocaleForCompare(supported) == base) {
			return supported;
		}
	}

	return {};
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
	auto normalized = normalizeLocale(std::move(locale));
	if (normalized.empty()) {
		return;
	}

	std::scoped_lock lock(mutex);
	fallbackLocale = std::move(normalized);
}

const std::string &Translator::getFallbackLocale() const {
	return fallbackLocale;
}

void Translator::loadLocale(const std::string &locale) const {
	const auto normalized = normalizeLocale(locale);
	if (normalized.empty()) {
		return;
	}

	std::scoped_lock lock(mutex);
	loadLocaleUnlocked(normalized);
}

bool Translator::isLocaleLoaded(const std::string &locale) const {
	const auto normalized = normalizeLocale(locale);
	if (normalized.empty()) {
		return false;
	}

	std::scoped_lock lock(mutex);
	const auto it = locales.find(normalized);
	return it != locales.end() && it->second.loaded;
}

std::string Translator::get(const std::string &key, const std::string &locale) const {
	return format(key, locale, {});
}

std::string Translator::format(const std::string &key, const std::string &locale, const std::vector<std::string> &args) const {
	if (key.empty()) {
		return {};
	}

	const auto normalizedLocale = normalizeLocale(locale);
	const auto resolvedLocale = normalizedLocale.empty() ? fallbackLocale : normalizedLocale;
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

std::string Translator::normalizeLocale(std::string locale) {
	const auto canonical = canonicalizeLocaleTag(locale);
	if (canonical.empty()) {
		return {};
	}

	if (const auto supported = findSupportedLocale(canonical); !supported.empty()) {
		return supported;
	}

	return {};
}

const std::vector<std::string> &Translator::supportedLocales() {
	return supportedLocaleList();
}

// ---- CLDR-based plural rules ------------------------------------------------

PluralCategory Translator::getPluralCategory(const std::string &locale, int64_t n) {
	const auto absN = std::abs(n);
	const auto mod10 = absN % 10;
	const auto mod100 = absN % 100;

	// Extract 2-letter base language from locale (e.g. "pt_BR" → "pt")
	const std::string lang = locale.substr(0, 2);

	// East Slavic: ru, uk, be — one / few / many
	if (lang == "ru" || lang == "uk") {
		if (mod10 == 1 && mod100 != 11) {
			return PluralCategory::One;
		}
		if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
			return PluralCategory::Few;
		}
		return PluralCategory::Many;
	}

	// Polish: one (n=1), few (n%10 in 2-4 && n%100 not in 12-14), many (rest)
	if (lang == "pl") {
		if (absN == 1) {
			return PluralCategory::One;
		}
		if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
			return PluralCategory::Few;
		}
		return PluralCategory::Many;
	}

	// Czech, Slovak: one (n=1), few (n in 2-4), other
	if (lang == "cs" || lang == "sk") {
		if (absN == 1) {
			return PluralCategory::One;
		}
		if (absN >= 2 && absN <= 4) {
			return PluralCategory::Few;
		}
		return PluralCategory::Other;
	}

	// Croatian, Serbian, Bosnian: same pattern as East Slavic
	if (lang == "hr" || lang == "sr" || lang == "bs") {
		if (mod10 == 1 && mod100 != 11) {
			return PluralCategory::One;
		}
		if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
			return PluralCategory::Few;
		}
		return PluralCategory::Many;
	}

	// Slovenian: one (n%100=1), few (n%100 in 2-4), other
	if (lang == "sl") {
		if (mod100 == 1) {
			return PluralCategory::One;
		}
		if (mod100 >= 2 && mod100 <= 4) {
			return PluralCategory::Few;
		}
		return PluralCategory::Other;
	}

	// Romanian: one (n=1), few (n=0 || n%100 in 2-19), other
	if (lang == "ro") {
		if (absN == 1) {
			return PluralCategory::One;
		}
		if (absN == 0 || (mod100 >= 2 && mod100 <= 19)) {
			return PluralCategory::Few;
		}
		return PluralCategory::Other;
	}

	// Lithuanian: one (n%10=1 && n%100 not in 11-19), few (n%10 in 2-9 && n%100 not in 11-19), many
	if (lang == "lt") {
		if (mod10 == 1 && (mod100 < 11 || mod100 > 19)) {
			return PluralCategory::One;
		}
		if (mod10 >= 2 && mod10 <= 9 && (mod100 < 11 || mod100 > 19)) {
			return PluralCategory::Few;
		}
		return PluralCategory::Many;
	}

	// Latvian: one (n%10=1 && n%100≠11, or n=0 in CLDR), other
	if (lang == "lv") {
		if (mod10 == 1 && mod100 != 11) {
			return PluralCategory::One;
		}
		return PluralCategory::Other;
	}

	// Arabic: one (n=1), few (n%100 in 3-10), many (n%100 in 11-99), other
	if (lang == "ar") {
		if (absN == 1) {
			return PluralCategory::One;
		}
		if (mod100 >= 3 && mod100 <= 10) {
			return PluralCategory::Few;
		}
		if (mod100 >= 11 && mod100 <= 99) {
			return PluralCategory::Many;
		}
		return PluralCategory::Other;
	}

	// Default: one / other  (en, de, es, fr, it, pt, nl, sv, da, no, fi, etc.)
	if (absN == 1) {
		return PluralCategory::One;
	}
	return PluralCategory::Other;
}

std::string Translator::plural(const std::string &key, const std::string &locale, int64_t count, const std::vector<std::string> &args) const {
	if (key.empty()) {
		return {};
	}

	const auto normalizedLocale = normalizeLocale(locale);
	const auto resolvedLocale = normalizedLocale.empty() ? fallbackLocale : normalizedLocale;
	ensureLocaleLoaded(resolvedLocale);
	if (resolvedLocale != fallbackLocale) {
		ensureLocaleLoaded(fallbackLocale);
	}

	const auto cat = getPluralCategory(resolvedLocale, count);
	static const std::string suffixes[] = { "_one", "_few", "_many", "_other" };
	const auto &suffix = suffixes[static_cast<int>(cat)];

	std::string translation;
	{
		std::scoped_lock lock(mutex);

		// 1. Try key + category suffix in requested locale
		translation = lookupUnlocked(resolvedLocale, key + suffix);

		// 2. Fallback to key_other in requested locale
		if (translation.empty() && suffix != "_other") {
			translation = lookupUnlocked(resolvedLocale, key + "_other");
		}

		// 3. Fallback to bare key in requested locale
		if (translation.empty()) {
			translation = lookupUnlocked(resolvedLocale, key);
		}

		// 4. Same chain in fallback locale
		if (translation.empty() && resolvedLocale != fallbackLocale) {
			translation = lookupUnlocked(fallbackLocale, key + suffix);
			if (translation.empty() && suffix != "_other") {
				translation = lookupUnlocked(fallbackLocale, key + "_other");
			}
			if (translation.empty()) {
				translation = lookupUnlocked(fallbackLocale, key);
			}
		}
	}

	if (translation.empty()) {
		g_logger().warn("Missing plural translation for key '{}' (locale '{}', count {})", key, resolvedLocale, count);
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
		g_logger().warn("Failed to format plural translation '{}' (locale '{}'): {}", key, resolvedLocale, err.what());
		return translation;
	}
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

void Translator::loadLocaleUnlocked(const std::string &locale) const {
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

void Translator::buildReverseTextMap(const std::string &keyPrefix) const {
	ensureLocaleLoaded(fallbackLocale);

	std::scoped_lock lock(mutex);
	if (reverseMapBuilt_) {
		return;
	}

	const auto it = locales.find(fallbackLocale);
	if (it == locales.end()) {
		reverseMapBuilt_ = true;
		return;
	}

	for (const auto &[key, value] : it->second.entries) {
		if (key.starts_with(keyPrefix) && value.size() >= 20) {
			reverseTextMap_[value] = key;
		}
	}

	reverseMapBuilt_ = true;
	g_logger().info("Built reverse text map with {} entries for prefix '{}'.", reverseTextMap_.size(), keyPrefix);
}

std::string Translator::getKeyForText(const std::string &text) const {
	std::scoped_lock lock(mutex);
	if (!reverseMapBuilt_) {
		return {};
	}

	const auto it = reverseTextMap_.find(text);
	if (it != reverseTextMap_.end()) {
		return it->second;
	}
	return {};
}

} // namespace i18n
