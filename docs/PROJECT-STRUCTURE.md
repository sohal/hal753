# hal753 Project Structure

This document provides an overview of the hal753 repository structure and architecture.

## Repository Structure

```
hal753/
├── .github/
│   └── workflows/
│       └── cmake.yml              # CI/CD workflow for multi-toolchain builds
│
├── cmake/                          # CMake configuration files
│   ├── cpack.cmake                # CPack packaging configuration
│   ├── deps.stm32cubeh7.cmake     # STM32CubeH7 dependency via CPM
│   ├── deps.toolchain.cmake       # cmake_scripts toolchain dependency
│   ├── nucleo-install.cmake       # Installation rules for all libraries
│   ├── nucleoConfig.cmake.in      # CMake package config template
│   └── nucleo-root-CMakeLists.txt.in  # Package root CMakeLists template
│
├── CMakePresets/                   # Modular preset files
│   ├── HiddenPresets.json         # MCU, toolchain, build type presets
│   ├── NucleoStaticLibPreset.json # Board-specific configure/build/package presets
│   └── VersionPresets.json        # Dependency version specifications
│
├── docs/                           # Documentation
│   ├── CPack-Guide.md             # Package creation and distribution guide
│   └── USAGE.md                   # Integration guide for users
│
├── nucleo-h753/                    # Board-specific sources and CMake
│   ├── CMakeLists.txt             # Three library targets (bsp, lwip, nucleo-h753)
│   ├── Core/
│   │   ├── Inc/                   # Board headers (main.h, hal_conf.h, it.h)
│   │   └── Src/                   # Board sources (main.c, hal_msp.c, syscalls, etc.)
│   ├── LWIP/
│   │   ├── App/                   # LwIP application layer (lwip.c/h)
│   │   └── Target/                # LwIP target layer (ethernetif.c/h, lwipopts.h)
│   ├── Makefile                   # Legacy Makefile (reference)
│   ├── nucleo-h753.ioc            # STM32CubeMX project file
│   ├── startup_stm32h753xx.s      # Startup assembly
│   └── STM32H753XX_FLASH.ld       # Linker script
│
├── scripts/
│   └── test-cpack.sh              # Package validation script
│
├── .gitignore                      # Git ignore patterns
├── CMakeLists.txt                  # Root CMake project file
├── CMakePresets.json               # Root presets (includes modular files)
├── CMakeUserPresetsTemplate.json   # Template for local toolchain paths
├── LICENSE                         # BSD 3-Clause license
└── README.md                       # Project overview and quick start
```

## Library Architecture

The project generates three separate static libraries:

### 1. **bsp** (`libbsp.a`)
- **Purpose**: Board Support Package for Ethernet PHY
- **Sources**: `lan8742.c` from STM32CubeH7 BSP components
- **Exports**: `bsp::bsp` CMake target
- **Dependencies**: None (standalone)

### 2. **lwip** (`liblwip.a`)
- **Purpose**: LwIP TCP/IP stack middleware
- **Sources**: All LwIP core, API, netif, and system sources from STM32CubeH7
- **Exports**: `lwip::lwip` CMake target
- **Dependencies**: None (standalone)

### 3. **nucleo-h753** (`libnucleo-h753.a`)
- **Purpose**: Main HAL library with application code
- **Sources**:
  - STM32H7xx HAL drivers (eth, rcc, flash, gpio, dma, pwr, tim, i2c, etc.)
  - Core application (main.c, stm32h7xx_it.c, hal_msp.c, syscalls, etc.)
  - LWIP application layer (lwip.c, ethernetif.c)
  - Generated GPIO structures from CubeMX
- **Exports**: `nucleo::h753` CMake target
- **Dependencies**: Links `bsp::bsp` and `lwip::lwip` **publicly**
- **Compile Definitions**: `USE_HAL_DRIVER`, `STM32H753xx`, `USE_PWR_LDO_SUPPLY`

### Unified Target

Users typically link with `nucleo::h753` which transitively provides:
- All three libraries
- All compile definitions
- All include paths (board headers + STM32Cube hierarchy)

## Build System Features

### Version Management
- Versions extracted from git tags (`v<major>.<minor>.<patch>`)
- Follows STM32CubeH7 release versions

### Dependency Management
- **CPM.cmake**: Downloads cmake_scripts and STM32CubeH7
- **cmake_scripts v1.0.7.4**: Provides toolchain files and GPIO struct generation
- **STM32CubeH7 v1.12.1**: HAL/LL drivers, CMSIS, BSP, LwIP middleware

### Toolchain Support
- **ARM GCC 14.3**: Primary toolchain
- **ARM Compiler for Embedded 21.1**: Secondary toolchain
- Preset-based configuration for easy switching

### GPIO Structure Generation
- Uses `gpioStructs.cmake` from cmake_scripts
- Generates type-safe GPIO structs from CubeMX `main.h`
- Automatic integration with nucleo-h753 library

### Package Generation
- Board-agnostic naming: `nucleo-hal-<version>-<toolchain>.tar.gz`
- Preserves STM32Cube include hierarchy
- Installs all three libraries with unified CMake export
- Self-contained packages with CMake config files

## Preset System

### Configure Presets
- `hal-gnuarm14.3`: ARM GCC 14.3 Debug
- `hal-gnuarm14.3-release`: ARM GCC 14.3 Release
- `hal-armclang21.1`: ARM Clang 21.1 Debug
- `hal-armclang21.1-release`: ARM Clang 21.1 Release

### Build Presets
- Match configure presets
- Build all three libraries

### Package Presets
- Create TGZ archives via CPack
- Match configure presets

## CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/cmake.yml`):

1. **Trigger**: Push to main/develop, PRs, tags, manual dispatch
2. **Matrix Build**:
   - Toolchains: gnuarm14.3, armclang21.1
   - Build types: Debug, Release
3. **Container**: `ghcr.io/kodezine/kdocker:latest`
4. **Steps**: Configure → Build → Package → Upload artifacts
5. **Release**: Automatic GitHub Release creation on `v*` tags

## Key Design Decisions

### Separate Libraries
- **Rationale**: Modular design, users can selectively link if needed
- **Implementation**: Three distinct static libraries, all installed

### Unified Target
- **Rationale**: Convenience for typical use cases
- **Implementation**: `nucleo::h753` links both `bsp::bsp` and `lwip::lwip` publicly

### Board-Agnostic Packaging
- **Rationale**: HAL is independent of specific board variant
- **Implementation**: Package name uses "nucleo-hal", not board-specific name

### STM32Cube Hierarchy Preservation
- **Rationale**: Maintains familiarity for STM32 developers
- **Implementation**: Install rules preserve full directory structure

### Compile Definitions on Unified Target Only
- **Rationale**: HAL-specific defines not needed for bsp/lwip standalone use
- **Implementation**: `target_compile_definitions()` only on `nucleo-h753`

## Usage Patterns

### Minimal Integration
```cmake
find_package(nucleo REQUIRED)
target_link_libraries(my_firmware PRIVATE nucleo::h753)
```

### Selective Linking
```cmake
target_link_libraries(my_app PRIVATE nucleo::lwip nucleo::bsp)
```

### Custom Definitions
```cmake
target_link_libraries(my_firmware PRIVATE nucleo::h753)
target_compile_definitions(my_firmware PRIVATE CUSTOM_DEFINE=1)
```

## Development Workflow

1. **Clone** repository
2. **Copy** `CMakeUserPresetsTemplate.json` → `CMakeUserPresets.json`
3. **Edit** preset to set `COMPILER_ROOT_PATH`
4. **Configure**: `cmake --preset hal-gnuarm14.3`
5. **Build**: `cmake --build --preset hal-gnuarm14.3`
6. **Package**: `cpack --preset hal-gnuarm14.3-release`
7. **Test**: `./scripts/test-cpack.sh <package>.tar.gz`

## License

- **CMake Configuration**: BSD 3-Clause (see LICENSE)
- **STM32CubeH7 Components**: ST proprietary licenses (retained in packages)
- **LwIP**: BSD license (from STM32CubeH7)

## References

- STM32CubeH7: https://github.com/STMicroelectronics/STM32CubeH7
- cmake_scripts: https://github.com/kodezine/cmake_scripts
- CPM.cmake: https://github.com/cpm-cmake/CPM.cmake
