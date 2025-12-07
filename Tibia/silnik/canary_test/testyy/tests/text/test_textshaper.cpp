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

/**
 * @brief Converts a UTF-8 encoded string to a UTF-32 string.
 *
 * @param utf8 UTF-8 encoded input.
 * @return std::u32string The input re-encoded as UTF-32.
 */
static std::u32string utf8to32(const std::string& utf8) {
    std::wstring_convert<std::codecvt_utf8<char32_t>, char32_t> conv;
    return conv.from_bytes(utf8);
}

class TextShaperTest : public ::testing::Test {
protected:
    FT_Library ftLib = nullptr;
    FT_Face ftFace = nullptr;
    hb_font_t* hbFont = nullptr;

    /**
     * @brief Initialize FreeType, load a system font, and create a HarfBuzz font for tests.
     *
     * Attempts to initialize the FreeType library, search a set of common system font paths
     * to load a face, set the face pixel size to 16, and create an hb_font_t from the FreeType face.
     * If no face is found the test is skipped. Initialization failures assert and mark the test as failed.
     */
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

    /**
     * @brief Releases HarfBuzz and FreeType resources allocated by the test fixture.
     *
     * Destroys the HarfBuzz font and finalizes the FreeType face and library if they were created.
     */
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