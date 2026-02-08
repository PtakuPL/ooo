#include "pch.hpp"

#include <boost/ut.hpp>

#include "utils/i18n/translator.hpp"

using namespace boost::ut;

suite<"utils"> localeNormalizationTest = [] {
	struct LocaleNormalizationCase {
		std::string input;
		std::string expected;
	};

	const std::vector cases {
		LocaleNormalizationCase { "en", "en" },
		LocaleNormalizationCase { "EN", "en" },
		LocaleNormalizationCase { "pt_BR", "pt" },
		LocaleNormalizationCase { "pt-BR", "pt" },
		LocaleNormalizationCase { "fil", "tl" },
		LocaleNormalizationCase { "tl", "tl" },
		LocaleNormalizationCase { "zh_tw", "zh_TW" },
		LocaleNormalizationCase { "zh-TW", "zh_TW" },
		LocaleNormalizationCase { "zh_hant", "zh_TW" },
		LocaleNormalizationCase { "zh_cn", "zh" },
		LocaleNormalizationCase { "xx", "" },
	};

	for (const auto &testCase : cases) {
		test(fmt::format("normalize locale '{}'", testCase.input)) = [&testCase] {
			expect(eq(testCase.expected, i18n::Translator::normalizeLocale(testCase.input)));
		};
	}
};
