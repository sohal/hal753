# Usage Guide

This document describes how to use the hal753 Nucleo HAL package in your CMake projects.

## Prerequisites

- CMake 3.25 or later
- ARM GCC toolchain (14.3 or later) or ARM Compiler for Embedded (21.1 or later)
- Ninja build system

## Building from Source

### Clone the repository

```bash
git clone https://github.com/kodezine/hal753.git
cd hal753
```

### Configure and build

Using a preset for ARM GCC:

```bash
# Copy user preset template
cp CMakeUserPresetsTemplate.json CMakeUserPresets.json

# Edit CMakeUserPresets.json to set your toolchain path
# Update COMPILER_ROOT_PATH to point to your ARM GCC installation

# Configure (Debug)
cmake --preset hal-gnuarm14.3

# Build
cmake --build --preset hal-gnuarm14.3

# Configure and build (Release)
cmake --preset hal-gnuarm14.3-release
cmake --build --preset hal-gnuarm14.3-release
```

### Create distribution package

```bash
# After building, create a package
cpack --preset hal-gnuarm14.3-release
```

This generates `nucleo-hal-<version>-gnuarm14.3.tar.gz` in the build directory.

## Using the Prebuilt Package

### Extract the package

```bash
tar -xzf nucleo-hal-1.12.1-gnuarm14.3.tar.gz
cd nucleo-hal-1.12.1-gnuarm14.3
```

### Integrate with your CMake project

Add the package directory to your `CMAKE_PREFIX_PATH`:

```cmake
cmake_minimum_required(VERSION 3.25)
project(my_project)

# Point CMake to the extracted package
list(APPEND CMAKE_PREFIX_PATH "/path/to/nucleo-hal-1.12.1-gnuarm14.3")

# Find the nucleo package
find_package(nucleo 1.12.1 REQUIRED)

# Create your executable
add_executable(my_firmware
    src/main.c
    src/app.c
)

# Link with the unified nucleo target
target_link_libraries(my_firmware
    PRIVATE
        nucleo::h753
)

# Optional: Link only specific libraries
# target_link_libraries(my_firmware PRIVATE nucleo::bsp nucleo::lwip)
```

### Using individual libraries

The package provides three library targets:

- `nucleo::bsp` - BSP library (lan8742 Ethernet PHY driver)
- `nucleo::lwip` - LwIP middleware library
- `nucleo::h753` - Main HAL library (links bsp and lwip publicly)

For most use cases, link with `nucleo::h753` which includes everything:

```cmake
target_link_libraries(my_firmware PRIVATE nucleo::h753)
```

This automatically provides:
- All HAL drivers
- BSP components
- LwIP middleware
- Compile definitions (`USE_HAL_DRIVER`, `STM32H753xx`, `USE_PWR_LDO_SUPPLY`)
- Include paths

### Manual include paths (if needed)

The package automatically sets include directories, but you can access them:

```cmake
message(STATUS "Nucleo includes: ${NUCLEO_INCLUDE_DIRS}")
```

## Directory Structure in Package

```
nucleo-hal-<version>-<toolchain>/
├── CMakeLists.txt              # Root CMake file for package
├── lib/
│   ├── libbsp.a               # BSP static library
│   ├── liblwip.a              # LwIP static library
│   ├── libnucleo-h753.a       # Main HAL static library
│   └── cmake/
│       └── nucleo/
│           ├── nucleoConfig.cmake
│           ├── nucleoConfigVersion.cmake
│           └── nucleoTargets.cmake
└── include/
    ├── nucleo/                # Board-specific headers
    │   ├── main.h
    │   ├── stm32h7xx_hal_conf.h
    │   ├── stm32h7xx_it.h
    │   ├── gpio_struct.h      # Generated GPIO structures
    │   └── lwip/              # LWIP App and Target headers
    └── stm32cubeh7/           # STM32Cube headers
        ├── Drivers/
        │   ├── STM32H7xx_HAL_Driver/
        │   ├── CMSIS/
        │   └── BSP/
        └── Middlewares/
            └── Third_Party/LwIP/
```

## Example Projects

### Minimal blinky with Ethernet

```cmake
cmake_minimum_required(VERSION 3.25)
project(ethernet_blinky C ASM)

# Set toolchain before project()
set(CMAKE_TOOLCHAIN_FILE "/path/to/toolchain.cmake")

# Find nucleo package
list(APPEND CMAKE_PREFIX_PATH "/path/to/nucleo-hal-1.12.1-gnuarm14.3")
find_package(nucleo REQUIRED)

# Create firmware
add_executable(firmware
    src/main.c
    src/ethernet_init.c
)

target_link_libraries(firmware
    PRIVATE
        nucleo::h753
)

# Linker script
target_link_options(firmware
    PRIVATE
        -T${CMAKE_CURRENT_SOURCE_DIR}/STM32H753XX_FLASH.ld
)

# Generate hex and bin
add_custom_command(TARGET firmware POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:firmware> firmware.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:firmware> firmware.bin
)
```

## Troubleshooting

### Package not found

Ensure `CMAKE_PREFIX_PATH` points to the extracted package directory:

```bash
cmake -DCMAKE_PREFIX_PATH=/path/to/nucleo-hal-1.12.1-gnuarm14.3 ..
```

### Wrong toolchain

The package is toolchain-specific. Use the package built with your target toolchain (gnuarm14.3, armclang21.1, etc.).

### Missing symbols

If you encounter undefined references, ensure you're linking with `nucleo::h753` which includes all dependencies.

## Support

For issues and questions:
- GitHub Issues: https://github.com/kodezine/hal753/issues
- Documentation: See docs/ directory in the repository
