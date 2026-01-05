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
# QP/C framework is built as separate library (qpc)
# =====================================================================
set (libName nucleo-h753)
add_library(${libName} STATIC)
add_library(nucleo::${libName} ALIAS ${libName})

# HAL driver sources (from Makefile C_SOURCES)
target_sources(${libName}
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
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_uart.c
        ${st_HAL_DRV_SRC_DIR}/stm32${LOWERCASE_STM32_TYPE}xx_hal_uart_ex.c
)

# Core application sources
target_sources(${libName}  
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
        # syscalls.c and sysmem.c intentionally excluded - applications must provide their own
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

target_sources(${libName}
    PRIVATE
        ${GPIO_STRUCT_GENERATED_HEADER}
)

# Include directories
target_include_directories(${libName}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Core/Inc>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>                  # For generated GPIO struct header
        $<BUILD_INTERFACE:${st_HAL_DRV_INCLUDE_DIR}>
        $<BUILD_INTERFACE:${st_HAL_DRV_INCLUDE_LEGACY_DIR}>
        $<BUILD_INTERFACE:${st_cmsis_PATH}/Include>
        $<BUILD_INTERFACE:${st_cmsis_PATH}/Core/Include>
        $<BUILD_INTERFACE:${st_cmsis_PATH}/Device/ST/STM32${UPPERCASE_STM32_TYPE}xx/Include>
        $<INSTALL_INTERFACE:include/nucleo>
        $<INSTALL_INTERFACE:include/stm32cubeh7/Drivers/STM32H7xx_HAL_Driver/Inc>
        $<INSTALL_INTERFACE:include/stm32cubeh7/Drivers/STM32H7xx_HAL_Driver/Inc/Legacy>
        $<INSTALL_INTERFACE:include/stm32cubeh7/Drivers/CMSIS/Include>
        $<INSTALL_INTERFACE:include/stm32cubeh7/Drivers/CMSIS/Device/ST/STM32${UPPERCASE_STM32_TYPE}xx/Include>
)

# Set compile definitions on unified target only
target_compile_definitions(${libName}
    PUBLIC
        USE_HAL_DRIVER
        STM32H753xx
        USE_PWR_LDO_SUPPLY
)
target_compile_options(${libName}
    PRIVATE
        -mcpu=cortex-m7
        -mthumb
        -mfpu=fpv5-d16
        -mfloat-abi=hard
        -Os
        -g3
        -Wall
        -Wextra
        -Wpedantic
        -Werror
)
unset (libName)
# =====================================================================
# Installation
# =====================================================================
include(${CMAKE_SOURCE_DIR}/cmake/nucleo-install.cmake)
