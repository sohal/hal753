# QP/C Framework Dependency
# Quantum Leaps QP/C real-time embedded framework

CPMAddPackage(
    NAME qpc
    VERSION 8.1.1
    GITHUB_REPOSITORY QuantumLeaps/qpc
    GIT_TAG v8.1.1
    OPTIONS
        "QPCPP OFF"
        "QPC_CFG_KERNEL qk"
        "QPC_CFG_PORT arm-cm"
        DOWNLOAD_ONLY TRUE
)

if(qpc_ADDED)
    message(STATUS "QP/C added at: ${qpc_SOURCE_DIR}")
    
    # Define the QP/C port for ARM Cortex-M7 with QK kernel
    set(QPC_PORT_DIR "${qpc_SOURCE_DIR}/ports/arm-cm/qk/gnu" CACHE PATH "QP/C Port Directory")
    
    # reconfigure the qp_config.h
    # Generate from template
    configure_file(
        ${CMAKE_CURRENT_LIST_DIR}/qpcfg.cmake.in
        ${qpc_SOURCE_DIR}/ports/arm-cm/config/qp_config.h
        @ONLY
    )

    set (libName qpc)
    # Create qpc library target
    add_library(${libName} STATIC)
    
    # Add QP/C sources
    file(GLOB QPC_CORE_SOURCES 
        "${qpc_SOURCE_DIR}/src/qf/*.c"
        "${qpc_SOURCE_DIR}/src/qk/*.c"
    )
    
    # Add port-specific sources
    file(GLOB QPC_PORT_SOURCES
        "${QPC_PORT_DIR}/*.c"
    )
    
    target_sources(${libName}
        PRIVATE
            ${QPC_CORE_SOURCES}
            ${QPC_PORT_SOURCES}
    )
    
    target_include_directories(${libName}
        PUBLIC
            "$<BUILD_INTERFACE:${qpc_SOURCE_DIR}/include>"
            "$<BUILD_INTERFACE:${qpc_SOURCE_DIR}/ports/arm-cm/config>"
            "$<BUILD_INTERFACE:${QPC_PORT_DIR}>"
            "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/qpc/include>"
            "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/qpc/config>"
            "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/qpc/port>"
    )
    
    target_compile_definitions(${libName}
        PUBLIC
            QP_API_VERSION=0
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
    
    # Create alias for easier linking
    add_library(qpc::qpc ALIAS ${libName})
    
    message(STATUS "QP/C library configured for ARM Cortex-M7 QK kernel")
    unset (libName)
endif()
