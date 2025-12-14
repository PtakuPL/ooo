#pragma once

#include <string>
#include <string_view>
#include <cstdint>

namespace otc::text {

/**
 * @brief Convert UTF-8 string to UTF-32 (codepoints)
 * @param utf8 Input UTF-8 string view
 * @return UTF-32 string with one char32_t per codepoint
 */
inline std::u32string utf8ToU32(std::string_view utf8)
{
    std::u32string out;
    out.reserve(utf8.size());

    size_t i = 0;
    const size_t n = utf8.size();
    while (i < n) {
        const auto c = static_cast<unsigned char>(utf8[i]);
        uint32_t cp = 0;
        size_t extra = 0;

        if (c < 0x80) {
            cp = c;
        } else if ((c >> 5) == 0x6) {
            cp = c & 0x1F;
            extra = 1;
        } else if ((c >> 4) == 0xE) {
            cp = c & 0x0F;
            extra = 2;
        } else if ((c >> 3) == 0x1E) {
            cp = c & 0x07;
            extra = 3;
        } else {
            ++i;
            continue;
        }

        if (i + extra >= n)
            break;

        bool malformed = false;
        for (size_t k = 0; k < extra; ++k) {
            const auto cc = static_cast<unsigned char>(utf8[i + 1 + k]);
            if ((cc >> 6) != 0x2) {
                malformed = true;
                break;
            }
            cp = (cp << 6) | (cc & 0x3F);
        }

        i += 1 + extra;
        if (!malformed)
            out.push_back(static_cast<char32_t>(cp));
    }

    return out;
}

/**
 * @brief Convert UTF-32 (codepoints) string to UTF-8
 * @param u32 Input UTF-32 string with codepoints
 * @return UTF-8 encoded string
 */
inline std::string u32ToUtf8(const std::u32string& u32)
{
    std::string out;
    out.reserve(u32.size() * 4); // worst case: 4 bytes per codepoint

    for (const char32_t cp : u32) {
        if (cp < 0x80) {
            // 1-byte (ASCII)
            out.push_back(static_cast<char>(cp));
        } else if (cp < 0x800) {
            // 2-byte
            out.push_back(static_cast<char>(0xC0 | (cp >> 6)));
            out.push_back(static_cast<char>(0x80 | (cp & 0x3F)));
        } else if (cp < 0x10000) {
            // 3-byte
            out.push_back(static_cast<char>(0xE0 | (cp >> 12)));
            out.push_back(static_cast<char>(0x80 | ((cp >> 6) & 0x3F)));
            out.push_back(static_cast<char>(0x80 | (cp & 0x3F)));
        } else if (cp < 0x110000) {
            // 4-byte
            out.push_back(static_cast<char>(0xF0 | (cp >> 18)));
            out.push_back(static_cast<char>(0x80 | ((cp >> 12) & 0x3F)));
            out.push_back(static_cast<char>(0x80 | ((cp >> 6) & 0x3F)));
            out.push_back(static_cast<char>(0x80 | (cp & 0x3F)));
        }
        // Invalid codepoints (>= 0x110000) are silently skipped
    }

    return out;
}

/**
 * @brief Count the number of UTF-8 codepoints in a string
 * @param utf8 Input UTF-8 string view
 * @return Number of codepoints (not bytes!)
 */
inline size_t utf8Length(std::string_view utf8)
{
    size_t count = 0;
    for (size_t i = 0; i < utf8.size(); ) {
        const auto c = static_cast<unsigned char>(utf8[i]);
        if (c < 0x80) {
            i += 1;
        } else if ((c >> 5) == 0x6) {
            i += 2;
        } else if ((c >> 4) == 0xE) {
            i += 3;
        } else if ((c >> 3) == 0x1E) {
            i += 4;
        } else {
            i += 1; // skip invalid byte
        }
        ++count;
    }
    return count;
}

/**
 * @brief Get byte offset for a codepoint index in UTF-8 string
 * @param utf8 Input UTF-8 string view
 * @param codepointIndex Index of codepoint (0-based)
 * @return Byte offset in the string, or string length if index is out of range
 */
inline size_t utf8ByteOffset(std::string_view utf8, size_t codepointIndex)
{
    size_t byteOffset = 0;
    size_t cpIndex = 0;
    
    while (byteOffset < utf8.size() && cpIndex < codepointIndex) {
        const auto c = static_cast<unsigned char>(utf8[byteOffset]);
        if (c < 0x80) {
            byteOffset += 1;
        } else if ((c >> 5) == 0x6) {
            byteOffset += 2;
        } else if ((c >> 4) == 0xE) {
            byteOffset += 3;
        } else if ((c >> 3) == 0x1E) {
            byteOffset += 4;
        } else {
            byteOffset += 1; // skip invalid byte
        }
        ++cpIndex;
    }
    return byteOffset;
}

/**
 * @brief Get codepoint index for a byte offset in UTF-8 string
 * @param utf8 Input UTF-8 string view
 * @param byteOffset Byte offset in the string
 * @return Codepoint index (0-based)
 */
inline size_t utf8CodepointIndex(std::string_view utf8, size_t byteOffset)
{
    size_t cpIndex = 0;
    size_t pos = 0;
    
    while (pos < utf8.size() && pos < byteOffset) {
        const auto c = static_cast<unsigned char>(utf8[pos]);
        if (c < 0x80) {
            pos += 1;
        } else if ((c >> 5) == 0x6) {
            pos += 2;
        } else if ((c >> 4) == 0xE) {
            pos += 3;
        } else if ((c >> 3) == 0x1E) {
            pos += 4;
        } else {
            pos += 1; // skip invalid byte
        }
        ++cpIndex;
    }
    return cpIndex;
}

} // namespace otc::text
