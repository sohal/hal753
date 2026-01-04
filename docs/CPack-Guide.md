# CPack Packaging Guide

This guide explains how to create distribution packages for the hal753 Nucleo HAL library.

## Overview

The hal753 project uses CPack to generate platform-independent binary packages containing:
- Pre-compiled static libraries (`.a` files)
- Header files preserving STM32Cube directory structure
- CMake configuration files for easy integration
- Documentation

## Package Naming Convention

Packages follow this naming pattern:

```
nucleo-hal-<version>-<toolchain>.tar.gz
```

Where:
- `<version>`: STM32CubeH7 version (e.g., 1.12.1)
- `<toolchain>`: Compiler identifier (gnuarm14.3, armclang21.1, etc.)

Examples:
- `nucleo-hal-1.12.1-gnuarm14.3.tar.gz`
- `nucleo-hal-1.12.1-armclang21.1.tar.gz`

## Creating Packages

### Prerequisites

1. Build the project first:
   ```bash
   cmake --preset hal-gnuarm14.3-release
   cmake --build --preset hal-gnuarm14.3-release
   ```

2. Ensure the build completed successfully

### Using CPack Presets

The easiest way to create a package:

```bash
# For ARM GCC Debug
cpack --preset hal-gnuarm14.3

# For ARM GCC Release (recommended for distribution)
cpack --preset hal-gnuarm14.3-release

# For ARM Clang Release
cpack --preset hal-armclang21.1-release
```

### Manual CPack Invocation

If you need more control:

```bash
cd build/hal-gnuarm14.3-release
cpack -G TGZ
```

## Package Contents

After extraction, the package contains:

```
nucleo-hal-<version>-<toolchain>/
│
├── CMakeLists.txt                    # Root CMake for package users
│
├── lib/                              # Static libraries
│   ├── libqpc.a                      # QP/C framework library
│   ├── libnucleo-h753.a              # Main HAL library
│   └── cmake/nucleo/                 # CMake package files
│       ├── nucleoConfig.cmake
│       ├── nucleoConfigVersion.cmake
│       └── nucleoTargets.cmake
│
└── include/                          # Header files
    ├── nucleo/                       # Board-specific
    │   ├── main.h
    │   ├── stm32h7xx_hal_conf.h
    │   └── stm32h7xx_it.h
    │
    ├── qpc/                          # QP/C framework
    │   ├── include/                  # QP/C core headers
    │   └── port/                     # ARM Cortex-M port headers
    │
    └── stm32cubeh7/                  # STM32Cube hierarchy
        ├── Drivers/
        │   ├── STM32H7xx_HAL_Driver/
        │   │   └── Inc/
        │   │       ├── *.h
        │   │       └── Legacy/*.h
        │   └── CMSIS/
        │       ├── Core/Include/*.h
        │       ├── Include/*.h
        │       └── Device/ST/STM32H7xx/Include/*.h
```

## Testing Packages

Use the provided test script:

```bash
./scripts/test-cpack.sh build/hal-gnuarm14.3-release/nucleo-hal-1.12.1-gnuarm14.3.tar.gz
```

This script:
1. Extracts the package to a temporary directory
2. Verifies all expected files exist
3. Checks library symbols
4. Validates CMake integration
5. Cleans up

## Distributing Packages

### GitHub Releases

Packages are automatically created and uploaded to GitHub Releases when you tag a version:

```bash
git tag -a v1.12.1 -m "Release v1.12.1"
git push origin v1.12.1
```

The CI/CD workflow builds packages for all supported toolchains and uploads them.

### Manual Distribution

After creating a package:

1. Test it thoroughly using the test script
2. Calculate checksums:
   ```bash
   sha256sum nucleo-hal-*.tar.gz > checksums.txt
   ```
3. Distribute via your preferred method (GitHub Releases, internal server, etc.)

## Version Management

Package versions are automatically extracted from git tags:

- Tag format: `v<major>.<minor>.<patch>`
- Example: `v1.12.1` → version 1.12.1

The version in the package name matches the STM32CubeH7 version being used.

## CPack Configuration

The packaging behavior is configured in [`cmake/cpack.cmake`](../cmake/cpack.cmake):

- **Generator**: TGZ (compressed tar archive)
- **Component**: `library` (only libraries and headers, no sources)
- **Metadata**: Package name, vendor, description
- **Filename**: Automatically includes version and toolchain

## Customization

### Adding Extra Files

Edit [`cmake/nucleo-install.cmake`](../cmake/nucleo-install.cmake):

```cmake
install(
    FILES ${CMAKE_SOURCE_DIR}/extra_doc.md
    DESTINATION docs/
    COMPONENT library
)
```

### Changing Package Format

Edit [`cmake/cpack.cmake`](../cmake/cpack.cmake):

```cmake
set(CPACK_GENERATOR "TGZ;ZIP")  # Add ZIP format
```

### Multi-Component Packages

Currently, only the `library` component is packaged. To add development files:

```cmake
set(CPACK_COMPONENTS_ALL library development)
install(FILES ... COMPONENT development)
```

## Troubleshooting

### Package is too large

Check if debug symbols are included:

```bash
# Build in Release mode
cmake --preset hal-gnuarm14.3-release
```

### Missing files in package

Verify installation rules in `nucleo-install.cmake`. Check CPack output:

```bash
cpack --preset hal-gnuarm14.3 --verbose
```

### CMake can't find the package

Ensure users set `CMAKE_PREFIX_PATH` correctly:

```cmake
list(APPEND CMAKE_PREFIX_PATH "/path/to/extracted/package")
find_package(nucleo REQUIRED)
```

## Best Practices

1. **Always use Release builds** for distribution packages
2. **Test packages** before distributing
3. **Provide checksums** for verification
4. **Document toolchain requirements** in release notes
5. **Version packages consistently** with STM32CubeH7
6. **Keep package size minimal** (no unnecessary files)

## CI/CD Integration

The GitHub Actions workflow automatically:

1. Builds for multiple toolchains
2. Creates packages for each
3. Uploads to GitHub Releases on version tags
4. Provides downloadable artifacts for all builds

See [`.github/workflows/cmake.yml`](../.github/workflows/cmake.yml) for details.
