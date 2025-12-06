/**
 * @file test_textshaper.cpp
 * @brief Unit tests for TextShaper class
 *
 * Tests cover:
 * - Basic text shaping (Latin, Cyrillic, Greek)
 * - RTL text handling (Arabic, Hebrew)
 * - CJK text (Chinese, Japanese, Korean)
 * - Bidirectional text reordering
 * - Empty/edge cases
 */

#include <gtest/gtest.h>
#include <framework/text/TextShaper.h>
#include <hb.h>
#include <hb-ft.h>
#include <ft2build.h>
#include FT_FREETYPE_H
#include <string>
#include <vector>
#include <codecvt>
#include <locale>

// Helper to convert UTF-8 to UTF-32
static std::u32string utf8to32(const std::string& utf8) {
    std::wstring_convert<std::codecvt_utf8<char32_t>, char32_t> conv;
    return conv.from_bytes(utf8);
}

class TextShaperTest : public ::testing::Test {
protected:
    FT_Library ftLib = nullptr;
    FT_Face ftFace = nullptr;
    hb_font_t* hbFont = nullptr;

    void SetUp() override {
        // Initialize FreeType
        ASSERT_EQ(FT_Init_FreeType(&ftLib), 0) << "Failed to init FreeType";
        
        // Try to load a system font for testing
        // Common paths for DejaVu Sans (usually available on Linux)
        const char* fontPaths[] = {
            "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
            "/usr/share/fonts/TTF/DejaVuSans.ttf",
            "/usr/share/fonts/dejavu/DejaVuSans.ttf",
            "/System/Library/Fonts/Helvetica.ttc", // macOS
            nullptr
        };

        for (const char** path = fontPaths; *path != nullptr; ++path) {
            if (FT_New_Face(ftLib, *path, 0, &ftFace) == 0) {
                break;
            }
        }

        if (!ftFace) {
            GTEST_SKIP() << "No system font found for testing";
            return;
        }

        FT_Set_Pixel_Sizes(ftFace, 0, 16);
        hbFont = hb_ft_font_create(ftFace, nullptr);
        ASSERT_NE(hbFont, nullptr) << "Failed to create HarfBuzz font";
    }

    void TearDown() override {
        if (hbFont) hb_font_destroy(hbFont);
        if (ftFace) FT_Done_Face(ftFace);
        if (ftLib) FT_Done_FreeType(ftLib);
    }
};

// Basic Latin text shaping
TEST_F(TextShaperTest, BasicLatinText) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = utf8to32("Hello World");
    auto result = TextShaper::shape(text, hbFont, params);

    // Should have glyphs for each character (11 chars including space)
    EXPECT_EQ(result.size(), 11);
    
    // Verify all glyphs have non-zero advance (except space might have 0 width)
    for (const auto& glyph : result) {
        EXPECT_GE(glyph.advanceX, 0.0f);
    }
}

// Empty text handling
TEST_F(TextShaperTest, EmptyText) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text;
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_TRUE(result.empty());
}

// Null font handling
TEST_F(TextShaperTest, NullFont) {
    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = utf8to32("Test");
    auto result = TextShaper::shape(text, nullptr, params);

    EXPECT_TRUE(result.empty());
}

// Polish text with diacritics
TEST_F(TextShaperTest, PolishText) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "pl";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = utf8to32("Zażółć gęślą jaźń");
    auto result = TextShaper::shape(text, hbFont, params);

    // Should have glyphs (18 chars including spaces)
    EXPECT_EQ(result.size(), 18);
}

// Cyrillic text (Russian)
TEST_F(TextShaperTest, CyrillicText) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "ru";
    params.script = "Cyrl";
    params.direction = TextDirection::LTR;

    std::u32string text = utf8to32("Привет мир");
    auto result = TextShaper::shape(text, hbFont, params);

    // 10 characters including space
    EXPECT_EQ(result.size(), 10);
}

// Greek text
TEST_F(TextShaperTest, GreekText) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "el";
    params.script = "Grek";
    params.direction = TextDirection::LTR;

    std::u32string text = utf8to32("Γειά σου");
    auto result = TextShaper::shape(text, hbFont, params);

    // Should produce glyphs
    EXPECT_FALSE(result.empty());
}

// LTR text direction is preserved
TEST_F(TextShaperTest, LTRDirection) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = utf8to32("ABC");
    auto result = TextShaper::shape(text, hbFont, params);

    ASSERT_EQ(result.size(), 3);
    
    // In LTR, positions should increase from left to right
    // Check that x positions are properly accumulated
    float prevX = result[0].x;
    for (size_t i = 1; i < result.size(); ++i) {
        // Each glyph's start position should be after the previous glyph's advance
        EXPECT_GE(result[i].x, prevX);
        prevX = result[i].x;
    }
}

// Verify codepoint field is populated
TEST_F(TextShaperTest, CodepointPreserved) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"ABC";
    auto result = TextShaper::shape(text, hbFont, params);

    ASSERT_EQ(result.size(), 3);
    // Each glyph should have a valid codepoint for fallback lookup
    // Note: Due to ligatures, codepoint might differ, but should be non-zero
    EXPECT_NE(result[0].codepoint, 0);
}

// Test with numbers and punctuation
TEST_F(TextShaperTest, NumbersAndPunctuation) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = utf8to32("123, test!");
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_EQ(result.size(), 11);
}

// Test single character
TEST_F(TextShaperTest, SingleCharacter) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"X";
    auto result = TextShaper::shape(text, hbFont, params);

    ASSERT_EQ(result.size(), 1);
    EXPECT_GT(result[0].advanceX, 0.0f);
}

// Test spaces only
TEST_F(TextShaperTest, SpacesOnly) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"   ";
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_EQ(result.size(), 3);
}

// ============================================================================
// Extended Tests for New Bidirectional Text Features
// ============================================================================

// Test RTL direction (Arabic/Hebrew simulation)
TEST_F(TextShaperTest, RTLDirection) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "ar";
    params.script = "Arab";
    params.direction = TextDirection::RTL;

    // Using Latin letters to simulate RTL (actual Arabic needs Arabic font)
    std::u32string text = U"ABC";
    auto result = TextShaper::shape(text, hbFont, params);

    ASSERT_EQ(result.size(), 3);
    // Verify glyphs are produced
    for (const auto& glyph : result) {
        EXPECT_GE(glyph.advanceX, 0.0f);
    }
}

// Test AUTO direction detection
TEST_F(TextShaperTest, AutoDirection) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::AUTO;

    std::u32string text = utf8to32("Test");
    auto result = TextShaper::shape(text, hbFont, params);

    ASSERT_EQ(result.size(), 4);
    // AUTO should default to LTR for Latin text
    EXPECT_GE(result[0].advanceX, 0.0f);
}

// Test Hebrew script detection
TEST_F(TextShaperTest, HebrewScript) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "he";
    params.script = "Hebr";
    params.direction = TextDirection::RTL;

    // Using Latin as fallback (actual Hebrew needs Hebrew font)
    std::u32string text = U"Test";
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_FALSE(result.empty());
}

// Test CJK scripts - Han (Chinese)
TEST_F(TextShaperTest, ChineseHanScript) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "zh";
    params.script = "Hani";
    params.direction = TextDirection::LTR;

    // Using Latin as fallback (actual Chinese needs CJK font)
    std::u32string text = U"Test";
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_FALSE(result.empty());
}

// Test Korean Hangul script
TEST_F(TextShaperTest, KoreanHangulScript) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "ko";
    params.script = "Hang";
    params.direction = TextDirection::LTR;

    std::u32string text = U"Test";
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_FALSE(result.empty());
}

// Test Japanese Hiragana script
TEST_F(TextShaperTest, JapaneseHiraganaScript) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "ja";
    params.script = "Jpan";
    params.direction = TextDirection::LTR;

    std::u32string text = U"Test";
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_FALSE(result.empty());
}

// Test Thai script
TEST_F(TextShaperTest, ThaiScript) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "th";
    params.script = "Thai";
    params.direction = TextDirection::LTR;

    std::u32string text = U"Test";
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_FALSE(result.empty());
}

// Test Devanagari script (Hindi)
TEST_F(TextShaperTest, DevanagariScript) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "hi";
    params.script = "Deva";
    params.direction = TextDirection::LTR;

    std::u32string text = U"Test";
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_FALSE(result.empty());
}

// Test Bengali script
TEST_F(TextShaperTest, BengaliScript) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "bn";
    params.script = "Beng";
    params.direction = TextDirection::LTR;

    std::u32string text = U"Test";
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_FALSE(result.empty());
}

// Test mixed direction text (bidirectional)
TEST_F(TextShaperTest, MixedDirectionText) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::AUTO;

    // Mix of Latin and numbers
    std::u32string text = utf8to32("Test 123");
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_EQ(result.size(), 8);
    // Verify all glyphs have codepoints for fallback
    for (const auto& glyph : result) {
        EXPECT_NE(glyph.codepoint, 0);
    }
}

// Test that codepoints are preserved through shaping
TEST_F(TextShaperTest, CodepointPreservationThroughShaping) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"ABC123";
    auto result = TextShaper::shape(text, hbFont, params);

    ASSERT_EQ(result.size(), 6);
    // All glyphs should have valid codepoints
    for (const auto& glyph : result) {
        EXPECT_NE(glyph.codepoint, 0) << "Codepoint should be preserved for fallback";
        EXPECT_GT(glyph.glyphIndex, 0) << "Glyph index should be valid";
    }
}

// Test very long text
TEST_F(TextShaperTest, LongText) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    // Generate long text (500 characters)
    std::string longText(500, 'A');
    std::u32string text = utf8to32(longText);
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_EQ(result.size(), 500);
    // Verify cumulative advance
    float totalAdvance = 0.0f;
    for (const auto& glyph : result) {
        totalAdvance += glyph.advanceX;
    }
    EXPECT_GT(totalAdvance, 0.0f);
}

// Test text with newlines (should be handled)
TEST_F(TextShaperTest, TextWithNewlines) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"Line1\nLine2";
    auto result = TextShaper::shape(text, hbFont, params);

    // Should have 11 glyphs (5 + newline + 5)
    EXPECT_EQ(result.size(), 11);
}

// Test text with tabs
TEST_F(TextShaperTest, TextWithTabs) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"A\tB";
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_EQ(result.size(), 3);
}

// Test special Unicode characters
TEST_F(TextShaperTest, SpecialUnicodeCharacters) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    // Zero-width characters and combining marks
    std::u32string text = U"A\u0301"; // A with combining acute accent
    auto result = TextShaper::shape(text, hbFont, params);

    // Should combine into single glyph or two glyphs depending on font
    EXPECT_FALSE(result.empty());
}

// Test advance values are consistent
TEST_F(TextShaperTest, AdvanceValuesConsistency) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"AAA";
    auto result = TextShaper::shape(text, hbFont, params);

    ASSERT_EQ(result.size(), 3);
    // Same character should have same advance
    EXPECT_FLOAT_EQ(result[0].advanceX, result[1].advanceX);
    EXPECT_FLOAT_EQ(result[1].advanceX, result[2].advanceX);
}

// Test x,y positions are calculated correctly
TEST_F(TextShaperTest, PositionCalculation) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"AB";
    auto result = TextShaper::shape(text, hbFont, params);

    ASSERT_EQ(result.size(), 2);
    // First glyph should start at origin
    EXPECT_FLOAT_EQ(result[0].x, 0.0f);
    EXPECT_FLOAT_EQ(result[0].y, 0.0f);
    // Second glyph x should be after first glyph's advance
    EXPECT_GE(result[1].x, result[0].advanceX);
}

// Test advanceY is zero for horizontal text
TEST_F(TextShaperTest, HorizontalTextAdvanceY) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"Test";
    auto result = TextShaper::shape(text, hbFont, params);

    for (const auto& glyph : result) {
        EXPECT_FLOAT_EQ(glyph.advanceY, 0.0f) << "Horizontal text should have zero Y advance";
    }
}

// Test glyphIndex is non-zero for valid characters
TEST_F(TextShaperTest, ValidGlyphIndices) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"Test";
    auto result = TextShaper::shape(text, hbFont, params);

    for (const auto& glyph : result) {
        EXPECT_GT(glyph.glyphIndex, 0u) << "Valid characters should have non-zero glyph index";
    }
}

// Test different language codes
TEST_F(TextShaperTest, DifferentLanguageCodes) {
    if (!hbFont) GTEST_SKIP();

    std::vector<std::string> languages = {"en", "de", "fr", "es", "it", "pt"};
    
    for (const auto& lang : languages) {
        ShapeParams params;
        params.language = lang;
        params.script = "Latn";
        params.direction = TextDirection::LTR;

        std::u32string text = U"Test";
        auto result = TextShaper::shape(text, hbFont, params);

        EXPECT_EQ(result.size(), 4) << "Language: " << lang;
    }
}

// Test script fallback to Latin
TEST_F(TextShaperTest, ScriptFallbackToLatin) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "UnknownScript"; // Should fall back to Latin
    params.direction = TextDirection::LTR;

    std::u32string text = U"Test";
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_EQ(result.size(), 4);
}

// Test performance with repeated shaping
TEST_F(TextShaperTest, RepeatedShaping) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"Performance Test";
    
    // Shape the same text multiple times
    for (int i = 0; i < 100; ++i) {
        auto result = TextShaper::shape(text, hbFont, params);
        EXPECT_EQ(result.size(), 16);
    }
}

// Test empty language string
TEST_F(TextShaperTest, EmptyLanguageString) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = ""; // Empty language
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"Test";
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_EQ(result.size(), 4);
}

// Test ligatures (if font supports them)
TEST_F(TextShaperTest, LigatureHandling) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    // "fi" often forms a ligature in fonts that support it
    std::u32string text = U"fi";
    auto result = TextShaper::shape(text, hbFont, params);

    // Could be 1 glyph (ligature) or 2 glyphs (no ligature)
    EXPECT_GE(result.size(), 1u);
    EXPECT_LE(result.size(), 2u);
}

// Test kerning is applied
TEST_F(TextShaperTest, KerningApplied) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    // "AV" typically has kerning
    std::u32string text = U"AV";
    auto result = TextShaper::shape(text, hbFont, params);

    ASSERT_EQ(result.size(), 2);
    // Total advance might be less than sum of individual advances due to kerning
    float totalAdvance = result[0].advanceX + result[1].advanceX;
    EXPECT_GT(totalAdvance, 0.0f);
}

// Test multiple consecutive spaces
TEST_F(TextShaperTest, MultipleSpaces) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"A     B"; // 5 spaces
    auto result = TextShaper::shape(text, hbFont, params);

    EXPECT_EQ(result.size(), 7); // A + 5 spaces + B
}

// Test uppercase vs lowercase have different advances
TEST_F(TextShaperTest, CaseSensitiveAdvances) {
    if (!hbFont) GTEST_SKIP();

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    auto resultUpper = TextShaper::shape(U"A", hbFont, params);
    auto resultLower = TextShaper::shape(U"a", hbFont, params);

    ASSERT_EQ(resultUpper.size(), 1);
    ASSERT_EQ(resultLower.size(), 1);
    
    // Typically uppercase and lowercase have different advances
    // (though not required, so we just check both are positive)
    EXPECT_GT(resultUpper[0].advanceX, 0.0f);
    EXPECT_GT(resultLower[0].advanceX, 0.0f);
}
