# Installation rules for nucleo-hal package

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Install qpc and nucleo-h753 static libraries
install(
    TARGETS qpc nucleo-h753
    EXPORT nucleoTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    COMPONENT library
)

# Install board-specific headers (Core/Inc)
install(
    DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Core/Inc/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/nucleo
    COMPONENT library
    FILES_MATCHING PATTERN "*.h"
)

# Install generated GPIO struct header
install(
    FILES ${GPIO_STRUCT_GENERATED_HEADER}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/nucleo
    COMPONENT library
)

# Install STM32CubeH7 HAL/LL headers
file(GLOB HALAndLLHeaders ${st_HAL_DRV_INCLUDE_DIR}/*.h)
list(FILTER HALAndLLHeaders EXCLUDE REGEX "template")
install(
    FILES ${HALAndLLHeaders}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/stm32cubeh7/Drivers/STM32H7xx_HAL_Driver/Inc
    COMPONENT library
)

# Install HAL Legacy headers
file(GLOB STLegacyHeaders ${st_HAL_DRV_INCLUDE_LEGACY_DIR}/*.h)
list(FILTER STLegacyHeaders EXCLUDE REGEX "template")
install(
    FILES ${STLegacyHeaders}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/stm32cubeh7/Drivers/STM32H7xx_HAL_Driver/Inc/Legacy
    COMPONENT library
)

# Install CMSIS headers
file(GLOB cmsis_CORE_HEADERS ${st_cmsis_PATH}/Core/Include/*.h)
file(GLOB cmsis_INCLUDE_HEADERS ${st_cmsis_PATH}/Include/*.h)
file(GLOB cmsis_DEVICE_HEADERS ${st_cmsis_PATH}/Device/ST/STM32${UPPERCASE_STM32_TYPE}xx/Include/*.h)

list(FILTER cmsis_CORE_HEADERS EXCLUDE REGEX "template")
list(FILTER cmsis_INCLUDE_HEADERS EXCLUDE REGEX "template")
list(FILTER cmsis_DEVICE_HEADERS EXCLUDE REGEX "template")

install(
    FILES ${cmsis_CORE_HEADERS}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/stm32cubeh7/Drivers/CMSIS/Core/Include
    COMPONENT library
)

install(
    FILES ${cmsis_INCLUDE_HEADERS}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/stm32cubeh7/Drivers/CMSIS/Include
    COMPONENT library
)

install(
    FILES ${cmsis_DEVICE_HEADERS}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/stm32cubeh7/Drivers/CMSIS/Device/ST/STM32${UPPERCASE_STM32_TYPE}xx/Include
    COMPONENT library
)

# Install QP/C headers
install(
    DIRECTORY ${qpc_SOURCE_DIR}/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/qpc/include
    COMPONENT library
    FILES_MATCHING PATTERN "*.h"
)

install(
    DIRECTORY ${QPC_PORT_DIR}/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/qpc/port
    COMPONENT library
    FILES_MATCHING PATTERN "*.h"
)

# Install QP/C configuration header
install(
    FILES ${qpc_SOURCE_DIR}/ports/arm-cm/config/qp_config.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/qpc/config
    COMPONENT library
)

# Generate and install CMake package config files
configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/nucleoConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/nucleoConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/nucleo
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/nucleoConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

# Install CMake package files
install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/nucleoConfig.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/nucleoConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/nucleo
    COMPONENT library
)

# Install unified targets export file
install(
    EXPORT nucleoTargets
    FILE nucleoTargets.cmake
    NAMESPACE nucleo::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/nucleo
    COMPONENT library
)

# Configure and install root CMakeLists.txt for packaged archive
configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/nucleo-root-CMakeLists.txt.in
    ${CMAKE_CURRENT_BINARY_DIR}/package-CMakeLists.txt
    @ONLY
)

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/package-CMakeLists.txt
    DESTINATION .
    RENAME CMakeLists.txt
    COMPONENT library
)
