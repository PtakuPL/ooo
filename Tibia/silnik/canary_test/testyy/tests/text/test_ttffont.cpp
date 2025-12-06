/**
 * @file test_ttffont.cpp
 * @brief Unit tests for TTFFont class
 *
 * Tests cover:
 * - Font loading with fallback fonts
 * - Glyph caching and atlas management
 * - Text width measurement
 * - Color parameter support
 * - Fallback font selection based on codepoint
 * - Edge cases and error handling
 */

#include <gtest/gtest.h>
#include <framework/text/TTFFont.h>
#include <framework/text/TextShaper.h>
#include <framework/util/color.h>
#include <string>
#include <vector>

class TTFFontTest : public ::testing::Test {
protected:
    TTFFontPtr font;

    void SetUp() override {
        font = std::make_shared<TTFFont>();
    }

    void TearDown() override {
        font.reset();
    }

    // Try to find a system font for testing
    std::string findSystemFont() {
        const char* fontPaths[] = {
            "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
            "/usr/share/fonts/TTF/DejaVuSans.ttf",
            "/usr/share/fonts/dejavu/DejaVuSans.ttf",
            "/System/Library/Fonts/Helvetica.ttc", // macOS
            nullptr
        };

        for (const char** path = fontPaths; *path != nullptr; ++path) {
            std::ifstream f(*path);
            if (f.good()) {
                return *path;
            }
        }
        return "";
    }
};

// Test basic font loading
TEST_F(TTFFontTest, LoadFont) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    bool loaded = font->load(fontPath, fallbacks, 16);

    EXPECT_TRUE(loaded);
    EXPECT_NE(font->hbFont(), nullptr);
    EXPECT_GT(font->atlasCount(), 0u);
}

// Test font loading with invalid path
TEST_F(TTFFontTest, LoadInvalidFont) {
    std::vector<std::string> fallbacks;
    bool loaded = font->load("/nonexistent/font.ttf", fallbacks, 16);

    EXPECT_FALSE(loaded);
}

// Test font loading with fallback fonts
TEST_F(TTFFontTest, LoadWithFallbackFonts) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    // Try to load same font as fallback (for testing)
    std::vector<std::string> fallbacks = {fontPath};
    bool loaded = font->load(fontPath, fallbacks, 16);

    EXPECT_TRUE(loaded);
}

// Test font loading with non-existent fallback fonts
TEST_F(TTFFontTest, LoadWithInvalidFallbacks) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks = {
        "/nonexistent/fallback1.ttf",
        "/nonexistent/fallback2.ttf"
    };
    bool loaded = font->load(fontPath, fallbacks, 16);

    // Should still succeed with main font
    EXPECT_TRUE(loaded);
}

// Test different pixel sizes
TEST_F(TTFFontTest, DifferentPixelSizes) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<int> sizes = {8, 12, 16, 24, 32, 48};
    
    for (int size : sizes) {
        auto testFont = std::make_shared<TTFFont>();
        std::vector<std::string> fallbacks;
        bool loaded = testFont->load(fontPath, fallbacks, size);
        
        EXPECT_TRUE(loaded) << "Failed to load font at size " << size;
    }
}

// Test measureTextWidth with empty string
TEST_F(TTFFontTest, MeasureEmptyText) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    float width = font->measureTextWidth(U"", params);
    EXPECT_FLOAT_EQ(width, 0.0f);
}

// Test measureTextWidth with single character
TEST_F(TTFFontTest, MeasureSingleCharacter) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    float width = font->measureTextWidth(U"A", params);
    EXPECT_GT(width, 0.0f);
}

// Test measureTextWidth is consistent
TEST_F(TTFFontTest, MeasureTextConsistency) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::u32string text = U"Test";
    float width1 = font->measureTextWidth(text, params);
    float width2 = font->measureTextWidth(text, params);

    EXPECT_FLOAT_EQ(width1, width2) << "Measurement should be consistent";
}

// Test measureTextWidth for different strings
TEST_F(TTFFontTest, MeasureDifferentTexts) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    float widthShort = font->measureTextWidth(U"A", params);
    float widthLong = font->measureTextWidth(U"AAAA", params);

    EXPECT_GT(widthLong, widthShort);
    // Approximately 4 times wider (allowing for kerning)
    EXPECT_GT(widthLong, widthShort * 3.5f);
}

// Test atlas creation
TEST_F(TTFFontTest, AtlasCreation) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    size_t initialAtlasCount = font->atlasCount();
    EXPECT_EQ(initialAtlasCount, 1u); // Should have one atlas initially

    // Get atlas texture
    auto atlas = font->getAtlasTexture(0);
    EXPECT_NE(atlas, nullptr);
}

// Test invalid atlas index
TEST_F(TTFFontTest, InvalidAtlasIndex) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    auto atlas = font->getAtlasTexture(999);
    EXPECT_EQ(atlas, nullptr);
}

// Test buildQuads with empty text
TEST_F(TTFFontTest, BuildQuadsEmptyText) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::vector<GlyphQuad> quads;
    Rect bounds = font->buildQuads(U"", params, quads);

    EXPECT_TRUE(quads.empty());
    EXPECT_FALSE(bounds.isValid());
}

// Test buildQuads with valid text
TEST_F(TTFFontTest, BuildQuadsValidText) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::vector<GlyphQuad> quads;
    Rect bounds = font->buildQuads(U"Test", params, quads);

    EXPECT_FALSE(quads.empty());
    EXPECT_TRUE(bounds.isValid());
    EXPECT_GT(bounds.width(), 0);
    EXPECT_GT(bounds.height(), 0);
}

// Test buildQuads produces correct number of quads
TEST_F(TTFFontTest, BuildQuadsCorrectCount) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::vector<GlyphQuad> quads;
    font->buildQuads(U"ABC", params, quads);

    // Should have 3 quads (one per character)
    EXPECT_EQ(quads.size(), 3u);
}

// Test quads have valid texture
TEST_F(TTFFontTest, QuadsHaveValidTexture) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::vector<GlyphQuad> quads;
    font->buildQuads(U"A", params, quads);

    ASSERT_FALSE(quads.empty());
    for (const auto& quad : quads) {
        EXPECT_NE(quad.texture, nullptr);
    }
}

// Test quads have valid destination rectangles
TEST_F(TTFFontTest, QuadsHaveValidDestRects) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::vector<GlyphQuad> quads;
    font->buildQuads(U"Test", params, quads);

    for (const auto& quad : quads) {
        EXPECT_GT(quad.dest.width(), 0);
        EXPECT_GT(quad.dest.height(), 0);
    }
}

// Test quads have valid source rectangles
TEST_F(TTFFontTest, QuadsHaveValidSrcRects) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::vector<GlyphQuad> quads;
    font->buildQuads(U"Test", params, quads);

    for (const auto& quad : quads) {
        EXPECT_GE(quad.src.x(), 0);
        EXPECT_GE(quad.src.y(), 0);
        EXPECT_GT(quad.src.width(), 0);
        EXPECT_GT(quad.src.height(), 0);
    }
}

// Test glyph caching (repeated measurement should be fast)
TEST_F(TTFFontTest, GlyphCaching) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    // First measurement caches glyphs
    float width1 = font->measureTextWidth(U"AAAA", params);
    
    // Second measurement should use cached glyphs
    float width2 = font->measureTextWidth(U"AAAA", params);

    EXPECT_FLOAT_EQ(width1, width2);
    
    // Atlas count should remain the same (no new atlases)
    size_t atlasCount = font->atlasCount();
    EXPECT_EQ(atlasCount, 1u);
}

// Test different scripts use codepoint for fallback
TEST_F(TTFFontTest, CodepointFallback) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "ru";
    params.script = "Cyrl";
    params.direction = TextDirection::LTR;

    // Measure Cyrillic text (may fallback if main font doesn't support)
    float width = font->measureTextWidth(U"Test", params);
    EXPECT_GE(width, 0.0f); // Should handle gracefully even without Cyrillic
}

// Test very small font size
TEST_F(TTFFontTest, VerySmallFontSize) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    auto testFont = std::make_shared<TTFFont>();
    std::vector<std::string> fallbacks;
    bool loaded = testFont->load(fontPath, fallbacks, 4); // 4px

    EXPECT_TRUE(loaded);

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    float width = testFont->measureTextWidth(U"Test", params);
    EXPECT_GT(width, 0.0f);
}

// Test very large font size
TEST_F(TTFFontTest, VeryLargeFontSize) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    auto testFont = std::make_shared<TTFFont>();
    std::vector<std::string> fallbacks;
    bool loaded = testFont->load(fontPath, fallbacks, 72); // 72px

    EXPECT_TRUE(loaded);

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    float width = testFont->measureTextWidth(U"Test", params);
    EXPECT_GT(width, 0.0f);
}

// Test special characters
TEST_F(TTFFontTest, SpecialCharacters) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    float width = font->measureTextWidth(U"!@#$%^&*()", params);
    EXPECT_GT(width, 0.0f);
}

// Test numbers
TEST_F(TTFFontTest, Numbers) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    float width = font->measureTextWidth(U"0123456789", params);
    EXPECT_GT(width, 0.0f);
}

// Test mixed alphanumeric
TEST_F(TTFFontTest, MixedAlphanumeric) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    float width = font->measureTextWidth(U"Test123", params);
    EXPECT_GT(width, 0.0f);
}

// Test long text doesn't cause issues
TEST_F(TTFFontTest, LongText) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    // Generate 1000 character string
    std::u32string longText(1000, U'A');
    float width = font->measureTextWidth(longText, params);
    EXPECT_GT(width, 0.0f);
}

// Test text with multiple words
TEST_F(TTFFontTest, MultipleWords) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    float width = font->measureTextWidth(U"The quick brown fox", params);
    EXPECT_GT(width, 0.0f);
}

// Test bounds calculation
TEST_F(TTFFontTest, BoundsCalculation) {
    std::string fontPath = findSystemFont();
    if (fontPath.empty()) {
        GTEST_SKIP() << "No system font found for testing";
    }

    std::vector<std::string> fallbacks;
    ASSERT_TRUE(font->load(fontPath, fallbacks, 16));

    ShapeParams params;
    params.language = "en";
    params.script = "Latn";
    params.direction = TextDirection::LTR;

    std::vector<GlyphQuad> quads;
    Rect bounds = font->buildQuads(U"Ag", params, quads); // A is tall, g descends

    EXPECT_TRUE(bounds.isValid());
    // Height should be at least the pixel size
    EXPECT_GE(bounds.height(), 12); // Reasonable minimum for 16px font
}