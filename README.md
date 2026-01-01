# hal753

CMake-based build system for STM32H7 Nucleo boards with integrated HAL, BSP, and LwIP middleware libraries.

## Features

- **Modular Library Architecture**: Separate static libraries for BSP (`libbsp.a`), LwIP (`liblwip.a`), and board HAL (`libnucleo-h753.a`)
- **CMake Presets**: Pre-configured build presets for multiple toolchains (ARM GCC 14.3, ARM Compiler for Embedded 21.1)
- **Auto-Generated GPIO Structures**: Type-safe GPIO access via cmake_scripts
- **CPM Package Manager**: Automated dependency fetching for STM32CubeH7 and toolchain files
- **Relocatable Packages**: CPack-generated redistributable library packages
- **CI/CD**: GitHub Actions workflow for automated builds and releases

## Supported Boards

- **nucleo-h753**: STM32H753ZI (Cortex-M7F) with Ethernet (LAN8742) and LwIP stack

## Quick Start

### Prerequisites

- CMake 3.25 or higher
- ARM GCC toolchain 14.3 or ARM Compiler for Embedded 21.1
- Git

### Building Locally

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd hal753
   ```

2. **Configure local toolchain** (optional):
   ```bash
   cp CMakeUserPresetsTemplate.json CMakeUserPresets.json
   # Edit CMakeUserPresets.json to set your toolchain path
   ```

3. **Configure and build**:
   ```bash
   cmake --preset nucleo-h753-hal-gnuarm14.3
   cmake --build --preset nucleo-h753-hal-gnuarm14.3
   ```

4. **Create package**:
   ```bash
   cd build/nucleo-h753-hal-gnuarm14.3
   cpack -G TGZ -C Debug
   ```

### Using in Your Project

See [docs/USAGE.md](docs/USAGE.md) for detailed integration examples.

## Project Structure

```
hal753/
├── nucleo-h753/          # Board-specific code and configuration
│   ├── Core/             # Application code (main.c, interrupts, MSP)
│   └── LWIP/             # LwIP application and target files
├── cmake/                # CMake modules and package configuration
├── CMakePresets/         # Modular CMake preset files
├── docs/                 # Documentation
└── scripts/              # Build and packaging scripts
```

## Library Targets

When the package is installed, three CMake targets are available:

- `bsp::bsp` - BSP drivers (LAN8742 Ethernet PHY)
- `lwip::lwip` - LwIP TCP/IP stack
- `nucleo::h753` - Board HAL library (publicly links bsp and lwip)

## Documentation

- [USAGE.md](docs/USAGE.md) - CMake integration and API usage
- [CPack-Guide.md](docs/CPack-Guide.md) - Package creation and distribution

## License

This project's CMake configuration is licensed under the BSD 3-Clause License. See [LICENSE](LICENSE) for details.

STM32CubeH7 HAL/LL drivers and LwIP middleware retain their original licenses from STMicroelectronics.

## Contributing

Contributions are welcome! Please ensure CMake presets build successfully before submitting pull requests.
