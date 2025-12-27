# CPack configuration for nucleo-hal package

# Determine toolchain identifier
if(CMAKE_C_COMPILER_ID MATCHES "GNU")
    if(CMAKE_C_COMPILER_VERSION)
        string(REGEX MATCH "^([0-9]+)\\.([0-9]+)" COMPILER_VER ${CMAKE_C_COMPILER_VERSION})
        set(TOOLCHAIN_ID "gnuarm${CMAKE_MATCH_1}.${CMAKE_MATCH_2}")
    else()
        set(TOOLCHAIN_ID "gnuarm")
    endif()
elseif(CMAKE_C_COMPILER_ID MATCHES "ARMClang")
    if(CMAKE_C_COMPILER_VERSION)
        string(REGEX MATCH "^([0-9]+)\\.([0-9]+)" COMPILER_VER ${CMAKE_C_COMPILER_VERSION})
        set(TOOLCHAIN_ID "armclang${CMAKE_MATCH_1}.${CMAKE_MATCH_2}")
    else()
        set(TOOLCHAIN_ID "armclang")
    endif()
elseif(CMAKE_C_COMPILER_ID MATCHES "Clang")
    if(CMAKE_C_COMPILER_VERSION)
        string(REGEX MATCH "^([0-9]+)\\.([0-9]+)" COMPILER_VER ${CMAKE_C_COMPILER_VERSION})
        set(TOOLCHAIN_ID "llvm${CMAKE_MATCH_1}.${CMAKE_MATCH_2}")
    else()
        set(TOOLCHAIN_ID "llvm")
    endif()
else()
    set(TOOLCHAIN_ID "unknown")
endif()

# Package metadata
set(CPACK_PACKAGE_NAME "nucleo-hal")
set(CPACK_PACKAGE_VENDOR "kodezine")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "STM32H7 Nucleo HAL library with BSP and LwIP")
set(CPACK_PACKAGE_VERSION_MAJOR ${VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${VERSION_PATCH})
set(CPACK_PACKAGE_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

# Package filename pattern: nucleo-hal-<version>-<toolchain>.tar.gz
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${stm32cubeh7_VERSION}-${TOOLCHAIN_ID}")

# Generator settings
set(CPACK_GENERATOR "TGZ")
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)

# Component configuration
set(CPACK_COMPONENTS_ALL library)
set(CPACK_COMPONENT_LIBRARY_DISPLAY_NAME "Nucleo HAL Library")
set(CPACK_COMPONENT_LIBRARY_DESCRIPTION "STM32H7 HAL, BSP, and LwIP static libraries")

# Include CPack
include(CPack)
