# QP/C Framework Dependency
# Quantum Leaps QP/C real-time embedded framework

CPMAddPackage(
    NAME qpc
    VERSION 8.1.1
    GITHUB_REPOSITORY QuantumLeaps/qpc
    GIT_TAG v8.1.1
    OPTIONS
        "QPCPP OFF"
)

if(qpc_ADDED)
    message(STATUS "QP/C added at: ${qpc_SOURCE_DIR}")
    
    # Define the QP/C port for ARM Cortex-M7 with QK kernel
    set(QPC_PORT_DIR "${qpc_SOURCE_DIR}/ports/arm-cm/qk/gnu" CACHE PATH "QP/C Port Directory")
    
    # Create qpc library target
    add_library(qpc_lib STATIC)
    
    # Add QP/C sources
    file(GLOB QPC_CORE_SOURCES 
        "${qpc_SOURCE_DIR}/src/qf/*.c"
        "${qpc_SOURCE_DIR}/src/qk/*.c"
    )
    
    # Add port-specific sources
    file(GLOB QPC_PORT_SOURCES
        "${QPC_PORT_DIR}/*.c"
    )
    
    target_sources(qpc_lib
        PRIVATE
            ${QPC_CORE_SOURCES}
            ${QPC_PORT_SOURCES}
    )
    
    target_include_directories(qpc_lib
        PUBLIC
            "${qpc_SOURCE_DIR}/include"
            "${QPC_PORT_DIR}"
    )
    
    target_compile_definitions(qpc_lib
        PUBLIC
            Q_SPY=0
            QP_API_VERSION=0
    )
    
    # Create alias for easier linking
    add_library(qpc::qpc ALIAS qpc_lib)
    
    message(STATUS "QP/C library configured for ARM Cortex-M7 QK kernel")
endif()
