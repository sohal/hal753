# Fetch STM32CubeH7 via CPM
set(BUILD_stm32cubeh7_LIBRARY FALSE CACHE BOOL "Build STM32CubeH7 library" FORCE)

# Include generic STM32Cube silicon support from cmake_scripts
include(${cmake_scripts_SOURCE_DIR}/silicon/stm32cubexx.cmake)
