#!/bin/bash

# Test script for CPack-generated packages
# Usage: ./test-cpack.sh <package.tar.gz>

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <package.tar.gz>"
    exit 1
fi

PACKAGE="$1"
if [ ! -f "$PACKAGE" ]; then
    echo "Error: Package file not found: $PACKAGE"
    exit 1
fi

echo "========================================="
echo "Testing CPack package: $(basename $PACKAGE)"
echo "========================================="

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Extract package
echo ""
echo "[1/5] Extracting package..."
tar -xzf "$PACKAGE" -C "$TEMP_DIR"

# Find the extracted directory
EXTRACT_DIR=$(find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d)
if [ -z "$EXTRACT_DIR" ]; then
    echo "Error: Could not find extracted directory"
    exit 1
fi

echo "Extracted to: $EXTRACT_DIR"

# Verify directory structure
echo ""
echo "[2/5] Verifying directory structure..."

EXPECTED_DIRS=(
    "lib"
    "lib/cmake/nucleo"
    "include/nucleo"
    "include/qpc"
    "include/stm32cubeh7"
)

for dir in "${EXPECTED_DIRS[@]}"; do
    if [ ! -d "$EXTRACT_DIR/$dir" ]; then
        echo "Error: Missing directory: $dir"
        exit 1
    fi
    echo "  ✓ $dir"
done

# Verify library files
echo ""
echo "[3/5] Verifying library files..."

EXPECTED_LIBS=(
    "lib/libqpc.a"
    "lib/libnucleo-h753.a"
)

for lib in "${EXPECTED_LIBS[@]}"; do
    if [ ! -f "$EXTRACT_DIR/$lib" ]; then
        echo "Error: Missing library: $lib"
        exit 1
    fi
    SIZE=$(stat -c%s "$EXTRACT_DIR/$lib")
    echo "  ✓ $lib ($SIZE bytes)"
done

# Verify CMake files
echo ""
echo "[4/5] Verifying CMake configuration..."

CMAKE_FILES=(
    "CMakeLists.txt"
    "lib/cmake/nucleo/nucleoConfig.cmake"
    "lib/cmake/nucleo/nucleoConfigVersion.cmake"
    "lib/cmake/nucleo/nucleoTargets.cmake"
)

for cmake_file in "${CMAKE_FILES[@]}"; do
    if [ ! -f "$EXTRACT_DIR/$cmake_file" ]; then
        echo "Error: Missing CMake file: $cmake_file"
        exit 1
    fi
    echo "  ✓ $cmake_file"
done

# Verify header files
echo ""
echo "[5/5] Verifying header files..."

EXPECTED_HEADERS=(
    "include/nucleo/main.h"
    "include/nucleo/stm32h7xx_hal_conf.h"
    "include/nucleo/stm32h7xx_it.h"
    "include/qpc/include/qp.h"
    "include/qpc/port/qp_port.h"
)

for header in "${EXPECTED_HEADERS[@]}"; do
    if [ ! -f "$EXTRACT_DIR/$header" ]; then
        echo "Error: Missing header: $header"
        exit 1
    fi
    echo "  ✓ $header"
done

# Check STM32Cube headers exist (at least some)
STM32_HEADERS=$(find "$EXTRACT_DIR/include/stm32cubeh7" -name "*.h" | wc -l)
if [ "$STM32_HEADERS" -lt 10 ]; then
    echo "Error: Too few STM32Cube headers found ($STM32_HEADERS)"
    exit 1
fi
echo "  ✓ Found $STM32_HEADERS STM32Cube header files"

# Test CMake integration (if cmake is available)
if command -v cmake &> /dev/null; then
    echo ""
    echo "[Bonus] Testing CMake integration..."

    TEST_PROJECT="$TEMP_DIR/test_project"
    mkdir -p "$TEST_PROJECT"

    cat > "$TEST_PROJECT/CMakeLists.txt" << EOF
cmake_minimum_required(VERSION 3.25)
project(test_integration)

list(APPEND CMAKE_PREFIX_PATH "$EXTRACT_DIR")
find_package(nucleo REQUIRED)

message(STATUS "Nucleo version: \${NUCLEO_VERSION}")
message(STATUS "Nucleo found: \${NUCLEO_FOUND}")

add_executable(dummy dummy.c)
target_link_libraries(dummy PRIVATE nucleo::h753)
EOF

    cat > "$TEST_PROJECT/dummy.c" << EOF
#include <stdint.h>
int main(void) { return 0; }
EOF

    cd "$TEST_PROJECT"
    if cmake . -G "Unix Makefiles" > /dev/null 2>&1; then
        echo "  ✓ CMake integration successful"
    else
        echo "  ✗ CMake integration failed (non-critical)"
    fi
fi

echo ""
echo "========================================="
echo "✓ All tests passed!"
echo "========================================="
echo ""
echo "Package summary:"
echo "  Libraries: ${#EXPECTED_LIBS[@]}"
echo "  Headers: $STM32_HEADERS+"
echo "  Size: $(du -h "$PACKAGE" | cut -f1)"
echo ""
