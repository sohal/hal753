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

# Link with the nucleo target
target_link_libraries(my_firmware
    PRIVATE
        nucleo::h753
)
```

### Using the library

The package provides two independent library targets:

- `nucleo::nucleo-h753` - STM32H753 HAL library (bare-metal ready)
- `nucleo::qpc` - QP/C framework (optional, for RTOS applications)

#### Modern CMake (Recommended)

Link with the targets you need:

```cmake
# Bare-metal application (no RTOS)
target_link_libraries(my_firmware PRIVATE nucleo::nucleo-h753)

# QP/C application
target_link_libraries(my_firmware 
    PRIVATE 
        nucleo::nucleo-h753
        nucleo::qpc
)
```

This automatically provides:
- Include directories
- Compile definitions (`USE_HAL_DRIVER`, `STM32H753xx`, `USE_PWR_LDO_SUPPLY`)
- Library dependencies

#### Traditional Variables (for legacy projects)

The package exports cache variables for non-CMake or legacy build systems:

**Include Directories:**
```cmake
# All include directories (HAL + QPC)
${NUCLEO_INCLUDE_DIRS}

# STM32H753 HAL includes only
${NUCLEO_HAL_INCLUDE_DIRS}

# QP/C framework includes only
${NUCLEO_QPC_INCLUDE_DIRS}
```

**Library Files:**
```cmake
# All libraries (combined)
${NUCLEO_LIBRARIES}

# STM32H753 HAL library (.a file path)
${NUCLEO_HAL_LIBRARY}

# QP/C framework library (.a file path)
${NUCLEO_QPC_LIBRARY}
```

**Example using variables:**
```cmake
find_package(nucleo REQUIRED)

add_executable(my_firmware src/main.c)

# Manual include paths
target_include_directories(my_firmware PRIVATE ${NUCLEO_INCLUDE_DIRS})

# Manual library linking
target_link_libraries(my_firmware PRIVATE ${NUCLEO_LIBRARIES})
```

**Package Information:**
```cmake
${NUCLEO_FOUND}    # TRUE if package found
${NUCLEO_VERSION}  # Package version (e.g., "1.12.1")
```

## Directory Structure in Package

```
nucleo-hal-<version>-<toolchain>/
├── CMakeLists.txt              # Root CMake file for package
├── lib/
│   ├── libqpc.a               # QP/C framework static library
│   ├── libnucleo-h753.a       # STM32H753 HAL static library
│   └── cmake/
│       └── nucleo/
│           ├── nucleoConfig.cmake          # Package configuration
│           ├── nucleoConfigVersion.cmake   # Version checking
│           └── nucleoTargets.cmake         # Exported targets
└── include/
    ├── nucleo/                # Board-specific headers
    │   ├── main.h
    │   ├── stm32h7xx_hal_conf.h
    │   └── stm32h7xx_it.h
    ├── qpc/                   # QP/C framework headers
    │   ├── include/           # QP/C core headers (qf.h, qk.h, etc.)
    │   ├── config/            # QP/C configuration (qp_config.h)
    │   └── port/              # ARM Cortex-M port headers (qp_port.h)
    └── stm32cubeh7/           # STM32Cube headers
        └── Drivers/
            ├── STM32H7xx_HAL_Driver/   # HAL drivers
            └── CMSIS/                  # CMSIS headers
```

## Example Projects

### Minimal bare-metal blinky

```cmake
cmake_minimum_required(VERSION 3.25)
project(bare_metal_blinky C ASM)

# Set toolchain before project()
set(CMAKE_TOOLCHAIN_FILE "/path/to/toolchain.cmake")

# Find nucleo package
list(APPEND CMAKE_PREFIX_PATH "/path/to/nucleo-hal-1.12.1-gnuarm14.3")
find_package(nucleo REQUIRED)

# Create firmware
add_executable(firmware
    src/main.c
    src/blinky.c
)

# Link HAL only (no RTOS)
target_link_libraries(firmware
    PRIVATE
        nucleo::nucleo-h753
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

### QP/C RTOS application

```cmake
cmake_minimum_required(VERSION 3.25)
project(qpc_app C ASM)

set(CMAKE_TOOLCHAIN_FILE "/path/to/toolchain.cmake")

list(APPEND CMAKE_PREFIX_PATH "/path/to/nucleo-hal-1.12.1-gnuarm14.3")
find_package(nucleo REQUIRED)

add_executable(firmware
    src/main.c
    src/blinky_ao.c
    src/app_init.c
)

# Link both HAL and QP/C framework
target_link_libraries(firmware
    PRIVATE
        nucleo::nucleo-h753  # Hardware abstraction
        nucleo::qpc          # QP/C framework
)

target_link_options(firmware
    PRIVATE
        -T${CMAKE_CURRENT_SOURCE_DIR}/STM32H753XX_FLASH.ld
)
```

### Using traditional variables (Makefile-based projects)

```cmake
cmake_minimum_required(VERSION 3.25)
project(legacy_project C ASM)

find_package(nucleo REQUIRED)

# Get library paths and includes as variables
message(STATUS "HAL Library: ${NUCLEO_HAL_LIBRARY}")
message(STATUS "QPC Library: ${NUCLEO_QPC_LIBRARY}")
message(STATUS "Includes: ${NUCLEO_INCLUDE_DIRS}")

add_executable(firmware src/main.c)

# Manual configuration
target_include_directories(firmware PRIVATE ${NUCLEO_HAL_INCLUDE_DIRS})
target_link_libraries(firmware PRIVATE ${NUCLEO_HAL_LIBRARY})
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

If you encounter undefined references:
- Ensure you're linking with `nucleo::nucleo-h753` for HAL functionality
- Add `nucleo::qpc` if using QP/C Active Objects
- Check that both library targets are linked in the correct order

## Support

For issues and questions:
- GitHub Issues: https://github.com/kodezine/hal753/issues
- Documentation: See docs/ directory in the repository
