/*
 * Copyright (c) 2010-2025 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include <algorithm>
#include <ranges>
#include <vector>
#include <charconv>

#include "exception.h"
#include "types.h"
#include <framework/text/Utf8.h>

// Windows headers must be included OUTSIDE namespace stdext, otherwise
// clang-cl places _GUID, IID, etc. inside stdext:: and COM template
// methods in the SDK fail to compile.
#ifdef WIN32
#include <winsock2.h>
#include <windows.h>
#endif

#ifdef _MSC_VER
#pragma warning(disable:4267) // '?' : conversion from 'A' to 'B', possible loss of data
#endif

namespace stdext
{
    [[nodiscard]] std::string resolve_path(std::string_view filePath, std::string_view sourcePath) {
        if (filePath.starts_with("/"))
            return std::string(filePath);

        auto slashPos = sourcePath.find_last_of('/');
        if (slashPos == std::string::npos)
            throw std::runtime_error("Invalid source path '" + std::string(sourcePath) + "' for file '" + std::string(filePath) + "'");

        return std::string(sourcePath.substr(0, slashPos + 1)) + std::string(filePath);
    }

    [[nodiscard]] std::string date_time_string(const char* format) {
        std::time_t tnow = std::time(nullptr);
        std::tm ts{};

        // Platform-specific time handling
#ifdef _WIN32
        localtime_s(&ts, &tnow);
#else
        localtime_r(&tnow, &ts);
#endif

        char date[20];  // Reduce buffer size based on expected format
        if (std::strftime(date, sizeof(date), format, &ts) == 0)
            throw std::runtime_error("Failed to format date-time string");

        return std::string(date);
    }

    [[nodiscard]] std::string dec_to_hex(uint64_t num) {
        char buffer[17]; // 16 characters for a uint64_t in hex + null terminator
        auto [ptr, ec] = std::to_chars(buffer, buffer + sizeof(buffer) - 1, num, 16);
        *ptr = '\0'; // Null-terminate the string
        return std::string(buffer);
    }

    [[nodiscard]] uint64_t hex_to_dec(std::string_view str) {
        uint64_t num = 0;
        auto [ptr, ec] = std::from_chars(str.data(), str.data() + str.size(), num, 16);
        if (ec != std::errc())
            throw std::runtime_error("Invalid hexadecimal input");
        return num;
    }

    [[nodiscard]] bool is_valid_utf8(std::string_view src) {
        for (size_t i = 0; i < src.size();) {
            unsigned char c = src[i];
            size_t bytes = (c < 0x80) ? 1 : (c < 0xE0) ? 2 : (c < 0xF0) ? 3 : (c < 0xF5) ? 4 : 0;
            if (!bytes || i + bytes > src.size() || (bytes > 1 && (src[i + 1] & 0xC0) != 0x80))
                return false;
            i += bytes;
        }
        return true;
    }

    [[nodiscard]] std::string utf8_to_latin1(std::string_view src) {
        std::string out;
        out.reserve(src.size()); // Reserve memory to avoid multiple allocations
        for (size_t i = 0; i < src.size(); ++i) {
            uint8_t c = static_cast<uint8_t>(src[i]);
            if ((c >= 32 && c < 128) || c == 0x0d || c == 0x0a || c == 0x09) {
                out += c;
            } else if (c == 0xc2 || c == 0xc3) {
                if (i + 1 < src.size()) {
                    uint8_t c2 = static_cast<uint8_t>(src[++i]);
                    out += (c == 0xc2) ? c2 : (c2 + 64);
                }
            } else {
                // Skip multi-byte characters
                while (i + 1 < src.size() && (src[i + 1] & 0xC0) == 0x80) {
                    ++i;
                }
            }
        }
        return out;
    }

    [[nodiscard]] std::string latin1_to_utf8(std::string_view src) {
        std::string out;
        out.reserve(src.size() * 2); // Reserve space to reduce allocations
        for (uint8_t c : src) {
            if ((c >= 32 && c < 128) || c == 0x0d || c == 0x0a || c == 0x09) {
                out += c; // Directly append ASCII characters
            } else {
                out.push_back(0xc2 + (c > 0xbf));
                out.push_back(0x80 + (c & 0x3f));
            }
        }
        return out;
    }

#ifdef WIN32
    std::wstring utf8_to_utf16(const std::string_view src)
    {
        constexpr size_t BUFFER_SIZE = 65536;

        std::wstring res;
        wchar_t out[BUFFER_SIZE];
        if (MultiByteToWideChar(CP_UTF8, 0, src.data(), -1, out, BUFFER_SIZE))
            res = out;
        return res;
    }

    std::string utf16_to_utf8(const std::wstring_view src)
    {
        constexpr size_t BUFFER_SIZE = 65536;

        std::string res;
        char out[BUFFER_SIZE];
        if (WideCharToMultiByte(CP_UTF8, 0, src.data(), -1, out, BUFFER_SIZE, nullptr, nullptr))
            res = out;
        return res;
    }

    std::wstring latin1_to_utf16(const std::string_view src) { return utf8_to_utf16(latin1_to_utf8(src)); }

    std::string utf16_to_latin1(const std::wstring_view src) { return utf8_to_latin1(utf16_to_utf8(src)); }
#endif

    // Unicode case conversion helper for Polish and common European characters
    namespace {
        char32_t unicodeToLower(char32_t cp) {
            // Polish uppercase to lowercase
            switch (cp) {
                case U'Ą': return U'ą';
                case U'Ć': return U'ć';
                case U'Ę': return U'ę';
                case U'Ł': return U'ł';
                case U'Ń': return U'ń';
                case U'Ó': return U'ó';
                case U'Ś': return U'ś';
                case U'Ź': return U'ź';
                case U'Ż': return U'ż';
                // German
                case U'Ä': return U'ä';
                case U'Ö': return U'ö';
                case U'Ü': return U'ü';
                // Czech/Slovak
                case U'Č': return U'č';
                case U'Ď': return U'ď';
                case U'Ě': return U'ě';
                case U'Ň': return U'ň';
                case U'Ř': return U'ř';
                case U'Š': return U'š';
                case U'Ť': return U'ť';
                case U'Ů': return U'ů';
                case U'Ý': return U'ý';
                case U'Ž': return U'ž';
                default:
                    if (cp < 128) return static_cast<char32_t>(std::tolower(static_cast<int>(cp)));
                    return cp;
            }
        }

        char32_t unicodeToUpper(char32_t cp) {
            // Polish lowercase to uppercase
            switch (cp) {
                case U'ą': return U'Ą';
                case U'ć': return U'Ć';
                case U'ę': return U'Ę';
                case U'ł': return U'Ł';
                case U'ń': return U'Ń';
                case U'ó': return U'Ó';
                case U'ś': return U'Ś';
                case U'ź': return U'Ź';
                case U'ż': return U'Ż';
                // German
                case U'ä': return U'Ä';
                case U'ö': return U'Ö';
                case U'ü': return U'Ü';
                case U'ß': return U'ẞ';  // German sharp s (or could stay ß)
                // Czech/Slovak
                case U'č': return U'Č';
                case U'ď': return U'Ď';
                case U'ě': return U'Ě';
                case U'ň': return U'Ň';
                case U'ř': return U'Ř';
                case U'š': return U'Š';
                case U'ť': return U'Ť';
                case U'ů': return U'Ů';
                case U'ý': return U'Ý';
                case U'ž': return U'Ž';
                default:
                    if (cp < 128) return static_cast<char32_t>(std::toupper(static_cast<int>(cp)));
                    return cp;
            }
        }

        bool unicodeIsSpace(char32_t cp) {
            return cp == U' ' || cp == U'\t' || cp == U'\n' || cp == U'\r' || cp == U'\v' || cp == U'\f';
        }
    }

    void tolower(std::string& str) { 
        auto text32 = otc::text::utf8ToU32(str);
        for (char32_t& cp : text32) {
            cp = unicodeToLower(cp);
        }
        str = otc::text::u32ToUtf8(text32);
    }

    void toupper(std::string& str) { 
        auto text32 = otc::text::utf8ToU32(str);
        for (char32_t& cp : text32) {
            cp = unicodeToUpper(cp);
        }
        str = otc::text::u32ToUtf8(text32);
    }

    void ltrim(std::string& s) { s.erase(s.begin(), std::ranges::find_if(s, [](unsigned char ch) { return !std::isspace(ch); })); }

    void rtrim(std::string& s) { s.erase(std::ranges::find_if(s | std::views::reverse, [](unsigned char ch) { return !std::isspace(ch); }).base(), s.end()); }

    void trim(std::string& s) { ltrim(s);       rtrim(s); }

    void ucwords(std::string& str) {
        auto text32 = otc::text::utf8ToU32(str);
        bool capitalize = true;
        for (char32_t& cp : text32) {
            if (unicodeIsSpace(cp)) {
                capitalize = true;
            } else if (capitalize) {
                cp = unicodeToUpper(cp);
                capitalize = false;
            }
        }
        str = otc::text::u32ToUtf8(text32);
    }

    void replace_all(std::string& str, std::string_view search, std::string_view replacement) {
        size_t pos = 0;
        while ((pos = str.find(search, pos)) != std::string::npos) {
            str.replace(pos, search.length(), replacement);
            pos += replacement.length();
        }
    }

    void eraseWhiteSpace(std::string& str) { std::erase_if(str, isspace); }

    [[nodiscard]] std::vector<std::string> split(std::string_view str, std::string_view separators) {
        std::vector<std::string> result;

        const char* begin = str.data();
        const char* end = begin + str.size();
        const char* p = begin;

        while (p < end) {
            const char* token_start = p;
            while (p < end && separators.find(*p) == std::string_view::npos)
                ++p;

            if (p > token_start)
                result.emplace_back(token_start, p - token_start);

            while (p < end && separators.find(*p) != std::string_view::npos)
                ++p;
        }

        return result;
    }
}