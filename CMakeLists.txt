cmake_minimum_required(VERSION 3.25)

# Extract version from git tags
find_package(Git QUIET)
if(GIT_FOUND)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --abbrev=0
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_TAG
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    if(GIT_TAG MATCHES "^v([0-9]+)\\.([0-9]+)\\.([0-9]+)")
        set(VERSION_MAJOR ${CMAKE_MATCH_1})
        set(VERSION_MINOR ${CMAKE_MATCH_2})
        set(VERSION_PATCH ${CMAKE_MATCH_3})
    else()
        set(VERSION_MAJOR 0)
        set(VERSION_MINOR 0)
        set(VERSION_PATCH 1)
    endif()
else()
    set(VERSION_MAJOR 0)
    set(VERSION_MINOR 0)
    set(VERSION_PATCH 1)
endif()

project(nucleo-hal
    VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
    LANGUAGES C ASM
)

# Download CPM.cmake
file(
    DOWNLOAD
    https://github.com/cpm-cmake/CPM.cmake/releases/download/${GITHUB_BRANCH_cpm}/CPM.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/cmake/CPM.cmake
    EXPECTED_HASH SHA256=${EXPECTED_HASH_cpm}
)
include(${CMAKE_CURRENT_BINARY_DIR}/cmake/CPM.cmake)

# Include dependency files
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/deps.toolchain.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/deps.stm32cubeh7.cmake)

# Extract STM32CubeH7 version from preset variable
string(REGEX REPLACE "^v" "" stm32cubeh7_VERSION "${GITHUB_BRANCH_stm32cubeh7}")

# Add board subdirectory based on BOARD_TYPE cache variable
if(BOARD_TYPE STREQUAL "nucleo-h753")
    add_subdirectory(nucleo-h753)
else()
    message(STATUS "No board selected. Set BOARD_TYPE to 'nucleo-h753' to build.")
endif()

# Include CPack configuration
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/cpack.cmake)
