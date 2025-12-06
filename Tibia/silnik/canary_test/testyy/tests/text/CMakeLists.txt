cmake_minimum_required(VERSION 3.16)

# Find GTest
find_package(GTest CONFIG REQUIRED)

# Find required libraries for text tests
find_package(Freetype CONFIG QUIET)
if(NOT TARGET Freetype::Freetype)
    find_package(Freetype REQUIRED)
endif()

find_package(harfbuzz CONFIG QUIET)
if(NOT TARGET harfbuzz::harfbuzz AND NOT TARGET harfbuzz)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(HARFBUZZ REQUIRED harfbuzz)
endif()

find_package(fribidi CONFIG QUIET)
if(NOT TARGET fribidi::fribidi AND NOT TARGET fribidi)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(FRIBIDI REQUIRED fribidi)
endif()

# Create test executable for text module
add_executable(text_tests
    test_textshaper.cpp
)

# Include paths for framework headers
target_include_directories(text_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/src
)

# Link libraries
target_link_libraries(text_tests PRIVATE
    GTest::gtest
    GTest::gtest_main
    Freetype::Freetype
)

# Link HarfBuzz
if(TARGET harfbuzz::harfbuzz)
    target_link_libraries(text_tests PRIVATE harfbuzz::harfbuzz)
elseif(TARGET harfbuzz)
    target_link_libraries(text_tests PRIVATE harfbuzz)
else()
    target_include_directories(text_tests PRIVATE ${HARFBUZZ_INCLUDE_DIRS})
    target_link_libraries(text_tests PRIVATE ${HARFBUZZ_LINK_LIBRARIES})
endif()

# Link FriBidi
if(TARGET fribidi::fribidi)
    target_link_libraries(text_tests PRIVATE fribidi::fribidi)
elseif(TARGET fribidi)
    target_link_libraries(text_tests PRIVATE fribidi)
else()
    target_include_directories(text_tests PRIVATE ${FRIBIDI_INCLUDE_DIRS})
    target_link_libraries(text_tests PRIVATE ${FRIBIDI_LINK_LIBRARIES})
endif()

# Add source files from framework/text that we're testing
target_sources(text_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/src/framework/text/TextShaper.cpp
)

# Enable testing
include(GoogleTest)
gtest_discover_tests(text_tests)
