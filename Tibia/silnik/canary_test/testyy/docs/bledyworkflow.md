  [6/33] Building CXX object src/CMakeFiles/canary_lib.dir/Unity/unity_22_cxx.cxx.o
  FAILED: [code=1] src/CMakeFiles/canary_lib.dir/Unity/unity_22_cxx.cxx.o 
  /usr/bin/c++ -DCURL_STATICLIB -DNDEBUG -DSPDLOG_COMPILED_LIB -DSPDLOG_FMT_EXTERNAL -DUSE_PRECOMPILED_HEADERS -I/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src -I/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/luajit-2.1 -I/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/src/protobuf -isystem /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/mysql -isystem /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include -march=x86-64 -mtune=generic -mno-avx -mno-sse4 -O2 -g -DNDEBUG -std=gnu++23 -flto=auto -fno-fat-lto-objects -fPIC -Wno-unused-parameter -Wno-sign-compare -Wno-switch -Wno-implicit-fallthrough -Wno-extra -Wno-deprecated-declarations -flto=auto -O3 -march=native -fopenmp -Winvalid-pch -include /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/src/CMakeFiles/canary_lib.dir/cmake_pch.hxx -MD -MT src/CMakeFiles/canary_lib.dir/Unity/unity_22_cxx.cxx.o -MF src/CMakeFiles/canary_lib.dir/Unity/unity_22_cxx.cxx.o.d -o src/CMakeFiles/canary_lib.dir/Unity/unity_22_cxx.cxx.o -c /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/src/CMakeFiles/canary_lib.dir/Unity/unity_22_cxx.cxx
  In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.cpp:10,
                   from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/src/CMakeFiles/canary_lib.dir/Unity/unity_22_cxx.cxx:10:
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/json.hpp:5216:12: error: reference to ‘json’ is ambiguous
   5216 |     inline nlohmann::json operator ""_json(const char* s, std::size_t n)
        |            ^~~~~~~~
  In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/detail/meta/type_traits.hpp:23,
                   from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/detail/exceptions.hpp:25,
                   from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/detail/conversions/from_json.hpp:23,
                   from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/adl_serializer.hpp:14,
                   from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/json.hpp:34:
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/json_fwd.hpp:62:7: note: candidates are: ‘using nlohmann::json_abi_v3_12_0::json = class nlohmann::json_abi_v3_12_0::basic_json<>’
     62 | using json = basic_json<>;
        |       ^~~~
  In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.cpp:1:
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.hpp:12:15: note:                 ‘class nlohmann::json’
     12 |         class json;
        |               ^~~~
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/json.hpp:5228:12: error: reference to ‘json’ is ambiguous
   5228 |     inline nlohmann::json::json_pointer operator ""_json_pointer(const char* s, std::size_t n)
        |            ^~~~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/json_fwd.hpp:62:7: note: candidates are: ‘using nlohmann::json_abi_v3_12_0::json = class nlohmann::json_abi_v3_12_0::basic_json<>’
     62 | using json = basic_json<>;
        |       ^~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.hpp:12:15: note:                 ‘class nlohmann::json’
     12 |         class json;
        |               ^~~~
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/json.hpp:5296:59: error: ‘operator""_json’ has not been declared in ‘nlohmann::json_abi_v3_12_0::literals::json_literals’
   5296 |         using nlohmann::literals::json_literals::operator ""_json; // NOLINT(misc-unused-using-decls,google-global-names-in-headers)
        |                                                           ^~~~~~~
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/json.hpp:5297:59: error: ‘operator""_json_pointer’ has not been declared in ‘nlohmann::json_abi_v3_12_0::literals::json_literals’
   5297 |         using nlohmann::literals::json_literals::operator ""_json_pointer; //NOLINT(misc-unused-using-decls,google-global-names-in-headers)
        |                                                           ^~~~~~~~~~~~~~~
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.cpp:15:22: error: the type ‘const std::array<std::filesystem::__cxx11::path, 3>’ of ‘constexpr’ variable ‘{anonymous}::DEFAULT_SEARCH_PATHS’ is not literal
     15 | constexpr std::array DEFAULT_SEARCH_PATHS = {
        |                      ^~~~~~~~~~~~~~~~~~~~
  In file included from /usr/include/c++/14/format:43,
                   from /usr/include/c++/14/ostream:43,
                   from /usr/include/c++/14/istream:41,
                   from /usr/include/c++/14/sstream:40,
                   from /usr/include/c++/14/chrono:45,
                   from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/benchmark.hpp:13,
                   from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/pch.hpp:17,
                   from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/src/CMakeFiles/canary_lib.dir/cmake_pch.hxx:5,
                   from <command-line>:
  /usr/include/c++/14/array:100:12: note: ‘std::array<std::filesystem::__cxx11::path, 3>’ is not literal because:
    100 |     struct array
        |            ^~~~~
  /usr/include/c++/14/array:115:55: note:   non-static data member ‘std::array<std::filesystem::__cxx11::path, 3>::_M_elems’ has non-literal type
    115 |       typename __array_traits<_Tp, _Nm>::_Type        _M_elems;
        |                                                       ^~~~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.cpp: In member function ‘void i18n::Translator::loadLocale(const std::string&) const’:
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.cpp:103:27: error: passing ‘const i18n::Translator’ as ‘this’ argument discards qualifiers [-fpermissive]
    103 |         loadLocaleUnlocked(locale);
        |         ~~~~~~~~~~~~~~~~~~^~~~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.hpp:37:14: note:   in call to ‘void i18n::Translator::loadLocaleUnlocked(const std::string&)’
     37 |         void loadLocaleUnlocked(const std::string &locale);
        |              ^~~~~~~~~~~~~~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.cpp: In member function ‘void i18n::Translator::ensureLocaleLoaded(const std::string&) const’:
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.cpp:173:27: error: passing ‘const i18n::Translator’ as ‘this’ argument discards qualifiers [-fpermissive]
    173 |         loadLocaleUnlocked(locale);
        |         ~~~~~~~~~~~~~~~~~~^~~~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.hpp:37:14: note:   in call to ‘void i18n::Translator::loadLocaleUnlocked(const std::string&)’
     37 |         void loadLocaleUnlocked(const std::string &locale);
        |              ^~~~~~~~~~~~~~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.cpp: In member function ‘void i18n::Translator::loadLocaleUnlocked(const std::string&)’:
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.cpp:207:61: error: reference to ‘json’ is ambiguous
    207 |                                 const auto json = nlohmann::json::parse(stream, nullptr, true, true);
        |                                                             ^~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/json_fwd.hpp:62:7: note: candidates are: ‘using nlohmann::json_abi_v3_12_0::json = class nlohmann::json_abi_v3_12_0::basic_json<>’
     62 | using json = basic_json<>;
        |       ^~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.hpp:12:15: note:                 ‘class nlohmann::json’
     12 |         class json;
        |               ^~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.cpp: At global scope:
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.cpp:252:36: error: reference to ‘json’ is ambiguous
    252 | void Translator::flattenJson(const nlohmann::json &node, const std::string &prefix, std::unordered_map<std::string, std::string> &output) {
        |                                    ^~~~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/vcpkg_installed/x64-linux/include/nlohmann/json_fwd.hpp:62:7: note: candidates are: ‘using nlohmann::json_abi_v3_12_0::json = class nlohmann::json_abi_v3_12_0::basic_json<>’
     62 | using json = basic_json<>;
        |       ^~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.hpp:12:15: note:                 ‘class nlohmann::json’
     12 |         class json;
        |               ^~~~
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.cpp:252:6: error: no declaration matches ‘void i18n::Translator::flattenJson(const int&, const std::string&, std::unordered_map<std::__cxx11::basic_string<char>, std::__cxx11::basic_string<char> >&)’
    252 | void Translator::flattenJson(const nlohmann::json &node, const std::string &prefix, std::unordered_map<std::string, std::string> &output) {
        |      ^~~~~~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.hpp:40:21: note: candidate is: ‘static void i18n::Translator::flattenJson(const nlohmann::json&, const std::string&, std::unordered_map<std::__cxx11::basic_string<char>, std::__cxx11::basic_string<char> >&)’
     40 |         static void flattenJson(const nlohmann::json &node, const std::string &prefix, std::unordered_map<std::string, std::string> &output);
        |                     ^~~~~~~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/i18n/translator.hpp:17:7: note: ‘class i18n::Translator’ defined here
     17 | class Translator {
        |       ^~~~~~~~~~
  In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/build/linux-release/src/CMakeFiles/canary_lib.dir/Unity/unity_22_cxx.cxx:16:
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/tools.cpp: In function ‘void toLowerCaseString(std::string&)’:
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/tools.cpp:280:34: error: cannot bind non-const lvalue reference of type ‘unsigned char&’ to a value of type ‘char’
    280 |         for (unsigned char &ch : source) {
        |                                  ^~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/tools.cpp: In function ‘std::string formatDate(time_t)’:
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/tools.cpp:455:65: error: ‘localtime’ is not a member of ‘fmt’
    455 |                 return fmt::format("{:%d/%m/%Y %H:%M:%S}", fmt::localtime(time));
        |                                                                 ^~~~~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/tools.cpp:455:65: note: suggested alternatives:
  In file included from /usr/include/c++/14/ctime:42,
                   from /usr/include/c++/14/bits/chrono.h:40,
                   from /usr/include/c++/14/chrono:41:
  /usr/include/time.h:137:19: note:   ‘localtime’
    137 | extern struct tm *localtime (const time_t *__timer) __THROW;
        |                   ^~~~~~~~~
  /usr/include/time.h:137:19: note:   ‘localtime’
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/tools.cpp: In function ‘std::string formatDateShort(time_t)’:
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/tools.cpp:464:59: error: ‘localtime’ is not a member of ‘fmt’
    464 |                 return fmt::format("{:%Y-%m-%d %X}", fmt::localtime(time));
        |                                                           ^~~~~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/tools.cpp:464:59: note: suggested alternatives:
  /usr/include/time.h:137:19: note:   ‘localtime’
    137 | extern struct tm *localtime (const time_t *__timer) __THROW;
        |                   ^~~~~~~~~
  /usr/include/time.h:137:19: note:   ‘localtime’
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/tools.cpp: In function ‘std::string formatTime(time_t)’:
  Error: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/tools.cpp:473:56: error: ‘localtime’ is not a member of ‘fmt’
    473 |                 return fmt::format("{:%H:%M:%S}", fmt::localtime(time));
        |                                                        ^~~~~~~~~
  /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/src/utils/tools.cpp:473:56: note: suggested alternatives:
  /usr/include/time.h:137:19: note:   ‘localtime’
    137 | extern struct tm *localtime (const time_t *__timer) __THROW;
        |                   ^~~~~~~~~
  /usr/include/time.h:137:19: note:   ‘localtime’
  [7/33] Building CXX object src/CMakeFiles/canary.dir/cmake_pch.hxx.gch
  ninja: build stopped: subcommand failed.
⏱ elapsed: 18.323 seconds
Error: "'/home/runner/work/_temp/1928717701/cmake-4.2.1-linux-x86_64/bin/cmake' failed with error code: '1'.
    at CMakeRunner.<anonymous> (/home/runner/work/_actions/lukka/run-cmake/main/dist/index.js:6910:23)
    at Generator.next (<anonymous>)
    at fulfilled (/home/runner/work/_actions/lukka/run-cmake/main/dist/index.js:6725:58)
Error: run-cmake action execution failed: 'Error: "'/home/runner/work/_temp/1928717701/cmake-4.2.1-linux-x86_64/bin/cmake' failed with error code: '1'.'