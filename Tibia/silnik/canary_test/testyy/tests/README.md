# OTClient Unit Tests

This directory contains unit tests for the OTClient project.

## Structure

```
tests/
├── CMakeLists.txt       # Main test configuration
├── text/                # Text rendering tests
│   ├── CMakeLists.txt
│   └── test_textshaper.cpp
└── README.md
```

## Building Tests

To build the tests, configure CMake with the `BUILD_TESTING` option:

```bash
mkdir build && cd build
cmake -DBUILD_TESTING=ON ..
cmake --build .
```

## Running Tests

After building, you can run all tests with:

```bash
ctest --output-on-failure
```

Or run specific test executables:

```bash
./text_tests
```

## Test Coverage

### Text Module (`tests/text/`)

Tests for the text rendering stack:

- **TextShaper Tests** (`test_textshaper.cpp`)
  - Basic Latin text shaping
  - Polish text with diacritics (ą, ę, ż, etc.)
  - Cyrillic text (Russian)
  - Greek text
  - Empty text handling
  - Null font handling
  - LTR/RTL direction handling
  - Number and punctuation handling
  - Codepoint preservation for fallback fonts

## Dependencies

Tests require:
- Google Test (gtest) - added via vcpkg
- FreeType
- HarfBuzz
- FriBidi
- A system font (e.g., DejaVuSans.ttf)

## Adding New Tests

1. Create a new test file in the appropriate subdirectory
2. Add the file to the corresponding `CMakeLists.txt`
3. Use Google Test macros (`TEST`, `TEST_F`, etc.)
4. Run `ctest` to verify

## Continuous Integration

Tests are automatically run in CI when `BUILD_TESTING=ON` is set.
