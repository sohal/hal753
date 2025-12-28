cmake_minimum_required(VERSION 3.25)

# =====================================================================
# BSP Library (lan8742 Ethernet PHY driver)
# =====================================================================
add_library(bsp STATIC)
add_library(bsp::bsp ALIAS bsp)

target_sources(bsp
    PRIVATE
        ${st_BSP_lan8742_DIR}/lan8742.c
)

target_include_directories(bsp
    PUBLIC
        ${st_BSP_lan8742_DIR}
        ${st_HAL_DRV_INCLUDE_DIR}
        ${st_HAL_DRV_INCLUDE_LEGACY_DIR}
        ${st_cmsis_PATH}/Include
        ${st_cmsis_PATH}/Core/Include
        ${st_cmsis_PATH}/Device/ST/STM32${UPPERCASE_STM32_TYPE}xx/Include
)

# =====================================================================
# LwIP Library (LwIP middleware sources)
# =====================================================================
add_library(lwip STATIC)
add_library(lwip::lwip ALIAS lwip)

# LwIP core sources
file(GLOB_RECURSE LWIP_CORE_SOURCES
    ${stm32cubeh7_SOURCE_DIR}/Middlewares/Third_Party/LwIP/src/core/*.c
)

# LwIP API sources
file(GLOB_RECURSE LWIP_API_SOURCES
    ${stm32cubeh7_SOURCE_DIR}/Middlewares/Third_Party/LwIP/src/api/*.c
)

# LwIP netif sources
file(GLOB_RECURSE LWIP_NETIF_SOURCES
    ${stm32cubeh7_SOURCE_DIR}/Middlewares/Third_Party/LwIP/src/netif/*.c
)

# LwIP system/OS sources (arch.c, sys_arch.c)
file(GLOB LWIP_SYSTEM_SOURCES
    ${stm32cubeh7_SOURCE_DIR}/Middlewares/Third_Party/LwIP/system/OS/*.c
)

target_sources(lwip
    PRIVATE
        ${LWIP_CORE_SOURCES}
        ${LWIP_API_SOURCES}
        ${LWIP_NETIF_SOURCES}
        ${LWIP_SYSTEM_SOURCES}
)

target_include_directories(lwip
    PUBLIC
        ${stm32cubeh7_SOURCE_DIR}/Middlewares/Third_Party/LwIP/src/include
        ${stm32cubeh7_SOURCE_DIR}/Middlewares/Third_Party/LwIP/system
        ${st_HAL_DRV_INCLUDE_DIR}
        ${st_HAL_DRV_INCLUDE_LEGACY_DIR}
        ${st_cmsis_PATH}/Include
        ${st_cmsis_PATH}/Core/Include
        ${st_cmsis_PATH}/Device/ST/STM32${UPPERCASE_STM32_TYPE}xx/Include
)

# =====================================================================
# Nucleo H753 Main Library (HAL + Application)
# =====================================================================
add_library(nucleo-h753 STATIC)
add_library(nucleo::h753 ALIAS nucleo-h753)

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
        Core/Src/stm32h7xx_it.c
        Core/Src/stm32h7xx_hal_msp.c
        Core/Src/system_stm32h7xx.c
        Core/Src/syscalls.c
        Core/Src/sysmem.c
)

# LWIP application sources
target_sources(nucleo-h753
    PRIVATE
        LWIP/App/lwip.c
        LWIP/Target/ethernetif.c
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
        Core/Inc
        LWIP/App
        LWIP/Target
        ${CMAKE_CURRENT_BINARY_DIR}  # For generated GPIO struct header
        ${st_HAL_DRV_INCLUDE_DIR}
        ${st_HAL_DRV_INCLUDE_LEGACY_DIR}
        ${st_cmsis_PATH}/Include
        ${st_cmsis_PATH}/Core/Include
        ${st_cmsis_PATH}/Device/ST/STM32${UPPERCASE_STM32_TYPE}xx/Include
        ${stm32cubeh7_SOURCE_DIR}/Middlewares/Third_Party/LwIP/src/include
        ${stm32cubeh7_SOURCE_DIR}/Middlewares/Third_Party/LwIP/system
)

# Link with bsp and lwip libraries
target_link_libraries(nucleo-h753
    PUBLIC
        bsp::bsp
        lwip::lwip
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
