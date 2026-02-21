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

#ifndef FRAMEWORK_PCH_H
#define FRAMEWORK_PCH_H

#pragma once

 // common C headers
#include <cassert>
#include <cmath>
#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <cstring>

// common STL headers
#include <algorithm>
#include <array>
#include <deque>
#include <functional>
#include <iomanip>
#include <iostream>
#include <list>
#include <map>
#include <memory>
#include <numeric>
#include <sstream>
#include <string>
#include <string_view>
#include <tuple>
#include <typeinfo>
#include <unordered_map>
#include <vector>

#include <parallel_hashmap/btree.h>
#include <parallel_hashmap/phmap.h>
#include <pugixml.hpp>

// FMT
// OTML_NO_FMT: MSVC ICE C1001 workaround — fmt template processing in
// otmlnode.cpp / otmlparser.cpp crashes P2 codegen even with /Od.
// These two TUs are compiled with -DOTML_NO_FMT to exclude fmt entirely.
#ifndef OTML_NO_FMT
#include <fmt/chrono.h>
#include <fmt/core.h>
#include <fmt/format.h>
#include <fmt/args.h>
#include <fmt/ranges.h>

// FMT Custom Formatter for Enums
// fmt >= 10.0.0 (FMT_VERSION >= 100000) has built-in format_as for enums.
// Only define this fallback for older fmt versions.
#if FMT_VERSION < 100000
template <typename E>
std::enable_if_t<std::is_enum_v<E>, std::underlying_type_t<E>>
format_as(E e) {
    return static_cast<std::underlying_type_t<E>>(e);
}
#endif
#endif // OTML_NO_FMT

using namespace std::literals;

#endif // FRAMEWORK_PCH_H