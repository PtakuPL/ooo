#pragma once

#include <string>
#include <string_view>
#include <cstdint>

namespace otc::text {

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

} // namespace otc::text
