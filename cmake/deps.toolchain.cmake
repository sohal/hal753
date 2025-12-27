# Fetch cmake_scripts (toolchain and silicon support) via CPM
CPMAddPackage(
    NAME cmake_scripts
    GITHUB_REPOSITORY kodezine/cmake_scripts
    GIT_TAG ${GITHUB_BRANCH_toolchain}
    DOWNLOAD_ONLY TRUE
    GIT_SHALLOW TRUE
)

if(cmake_scripts_ADDED)
    message(STATUS "cmake_scripts fetched to: ${cmake_scripts_SOURCE_DIR}")
endif()
