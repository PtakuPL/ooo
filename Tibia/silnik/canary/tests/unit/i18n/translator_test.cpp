#include "pch.hpp"

#include <boost/ut.hpp>

#include <chrono>
#include <filesystem>
#include <fstream>

#include <fmt/format.h>

#include "utils/i18n/translator.hpp"

using namespace boost::ut;

namespace {
std::filesystem::path makeTempRoot() {
    const auto suffix = std::chrono::steady_clock::now().time_since_epoch().count();
    return std::filesystem::temp_directory_path() / fmt::format("canary_i18n_test_{}", suffix);
}

void writeJson(const std::filesystem::path &root, const std::string &locale, std::string_view json) {
    const auto dir = root / locale;
    std::filesystem::create_directories(dir);
    std::ofstream out(dir / "system.json");
    out << json;
}
}

suite<"i18n.translator"> translator_suite = [] {
    test("fallback to en and formatting") = [] {
        const auto root = makeTempRoot();
        const std::string enJson = R"({
            "system": {
                "welcome": "Hello {0}",
                "only_en": "Base EN"
            }
        })";
        const std::string plJson = R"({
            "system": {
                "welcome": "Witaj {0}"
            }
        })";

        writeJson(root, "en", enJson);
        writeJson(root, "pl", plJson);

        auto &tr = i18n::g_translator();
        tr.setSearchPaths({root});
        tr.setFallbackLocale("en");

        // Ładowanie pl/ fallback en
        expect(tr.format("system.welcome", "pl", {"Tester"}) == "Witaj Tester");
        expect(tr.get("system.only_en", "pl") == "Base EN");

        std::filesystem::remove_all(root);
    };

    test("missing locale returns key") = [] {
        const auto root = makeTempRoot();
        std::filesystem::create_directories(root);

        auto &tr = i18n::g_translator();
        tr.setSearchPaths({root});
        tr.setFallbackLocale("en");

        expect(tr.get("unknown.key", "xx") == "unknown.key");

        std::filesystem::remove_all(root);
    };

    test("arrays flatten and formatting errors fall back to raw string") = [] {
        const auto root = makeTempRoot();
        const std::string enJson = R"({
            "ui": {
                "dialog": [
                    "First line",
                    "Second line"
                ],
                "notice": {
                    "rich": "Value {0} {1}"
                }
            }
        })";

        writeJson(root, "en", enJson);

        auto &tr = i18n::g_translator();
        tr.setSearchPaths({root});
        tr.setFallbackLocale("en");

        expect(tr.get("ui.dialog[1]", "en") == "Second line");

        // Missing format argument should return the unformatted string.
        expect(tr.format("ui.notice.rich", "en", {"only-one"}) == "Value {0} {1}");

        std::filesystem::remove_all(root);
    };

    test("supported locales list contains client set") = [] {
        const auto &locales = i18n::Translator::supportedLocales();
        expect(std::find(locales.begin(), locales.end(), "pl") != locales.end());
        expect(std::find(locales.begin(), locales.end(), "zh") != locales.end());
        expect(std::find(locales.begin(), locales.end(), "ar") != locales.end());
        expect(std::find(locales.begin(), locales.end(), "ca") != locales.end());
    };
};
