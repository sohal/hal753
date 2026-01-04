cmake_minimum_required(VERSION 3.25)

# Include QP/C framework dependency
include(${PROJECT_SOURCE_DIR}/cmake/deps.qpc.cmake)

# Define paths for STM32CubeH7 components (since we're not building the library)
set(st_cmsis_PATH ${stm32cubeh7_SOURCE_DIR}/Drivers/CMSIS CACHE PATH "Path to STM32CubeH7 CMSIS folder" FORCE)
set(st_HAL_Driver_DIR ${stm32cubeh7_SOURCE_DIR}/Drivers/STM32${UPPERCASE_STM32_TYPE}xx_HAL_Driver CACHE PATH "Path to STM32CubeH7 HAL Driver folder" FORCE)
set(st_HAL_DRV_INCLUDE_DIR "${st_HAL_Driver_DIR}/Inc" CACHE PATH "Path to STM32CubeH7 HAL Driver Include folder" FORCE)
set(st_HAL_DRV_INCLUDE_LEGACY_DIR "${st_HAL_DRV_INCLUDE_DIR}/Legacy" CACHE PATH "Path to STM32CubeH7 HAL Driver Legacy Include folder" FORCE)
set(st_HAL_DRV_SRC_DIR "${st_HAL_Driver_DIR}/Src" CACHE PATH "Path to STM32CubeH7 HAL Driver Source folder" FORCE)

# =====================================================================
# Nucleo H753 Main Library (HAL + Application)
# QP/C framework is built as separate library (qpc_lib)
# =====================================================================
add_library(nucleo-h753 STATIC)
add_library(nucleo::nucleo-h753 ALIAS nucleo-h753)

# HAL driver sources (from Makefile C_SOURCES)
target_sources(nucleo-h753
    PRIVATE
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_eth.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_rcc.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_rcc_ex.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_flash.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_flash_ex.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_gpio.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_hsem.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_dma.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_dma_ex.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_mdma.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_pwr.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_pwr_ex.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_cortex.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_i2c.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_i2c_ex.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_exti.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_tim.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_tim_ex.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_cryp.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_cryp_ex.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_hash.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_hash_ex.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_rng.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_rng_ex.c
)

# Core application sources
target_sources(nucleo-h753
    PRIVATE
        Core/Src/main.c
        Core/Src/gpio.c
        Core/Src/eth.c
        Core/Src/usart.c
        Core/Src/rng.c
        Core/Src/hash.c
        Core/Src/cryp.c
        Core/Src/stm32h7xx_it.c
        Core/Src/stm32h7xx_hal_msp.c
        Core/Src/stm32h7xx_hal_timebase_tim.c
        Core/Src/system_stm32h7xx.c
        Core/Src/syscalls.c
        Core/Src/sysmem.c
)

# QP/C adapter from frameworks/qpc
target_sources(nucleo-h753
    PRIVATE
        ${CMAKE_SOURCE_DIR}/frameworks/qpc/qpc-adapter.c
)

# Generate GPIO structures from CubeMX main.h
# NOTE: This utility is not available in cmake_scripts v1.0.7.4
# include(${cmake_scripts_SOURCE_DIR}/utilities/gpioStructs.cmake)
# generateGpioStructsFromCubeMx(
#     VENDOR st
#     MCU_FAMILY STM32${UPPERCASE_STM32_TYPE}
#     MAIN_H_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Core/Inc/main.h
#     GENERATED_FILE GPIO_STRUCT_GENERATED_HEADER
# )

target_sources(nucleo-h753
    PRIVATE
        ${GPIO_STRUCT_GENERATED_HEADER}
)

# Include directories
target_include_directories(nucleo-h753
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Core/Inc>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>                  # For generated GPIO struct header
        $<BUILD_INTERFACE:${st_HAL_DRV_INCLUDE_DIR}>
        $<BUILD_INTERFACE:${st_HAL_DRV_INCLUDE_LEGACY_DIR}>
        $<BUILD_INTERFACE:${st_cmsis_PATH}/Include>
        $<BUILD_INTERFACE:${st_cmsis_PATH}/Core/Include>
        $<BUILD_INTERFACE:${st_cmsis_PATH}/Device/ST/STM32${UPPERCASE_STM32_TYPE}xx/Include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/nucleo>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/stm32cubeh7/Drivers/STM32H7xx_HAL_Driver/Inc>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/stm32cubeh7/Drivers/STM32H7xx_HAL_Driver/Inc/Legacy>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/stm32cubeh7/Drivers/CMSIS/Include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/stm32cubeh7/Drivers/CMSIS/Device/ST/STM32${UPPERCASE_STM32_TYPE}xx/Include>
    PRIVATE
        ${CMAKE_SOURCE_DIR}/frameworks/qpc           # QP/C adapter
        ${CMAKE_SOURCE_DIR}/ao/common                # AO headers (for build only, not installed)
        ${CMAKE_SOURCE_DIR}/ao/stack_monitor
        ${CMAKE_SOURCE_DIR}/ao/blinky
)

# Link with qpc library publicly (downstream projects get qpc automatically)
target_link_libraries(nucleo-h753
    PUBLIC
        qpc::qpc
)

# Set compile definitions on unified target only
target_compile_definitions(nucleo-h753
    PUBLIC
        USE_HAL_DRIVER
        STM32H753xx
        USE_PWR_LDO_SUPPLY
)

# =====================================================================
# Installation
# =====================================================================
include(${CMAKE_SOURCE_DIR}/cmake/nucleo-install.cmake)
