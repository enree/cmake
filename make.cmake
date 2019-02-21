# @file
# @brief Combine several .cmake files
# Define if this project is root one

# Read predefined configs for build from file
if (DEFINED PREDEFINED_CONFIGS)
    set(CONFIGS_FILE ${CMAKE_SOURCE_DIR}/${PREDEFINED_CONFIGS})

    if(EXISTS "${CONFIGS_FILE}")
        file(STRINGS "${CONFIGS_FILE}" ConfigContents)
        foreach(NameAndValue ${ConfigContents})
          # Strip leading spaces
          string(REGEX REPLACE "^[ ]+" "" NameAndValue ${NameAndValue})
          # Find variable name
          string(REGEX MATCH "^[^=]+" Name ${NameAndValue})
          # Find the value
          string(REPLACE "${Name}=" "" Value ${NameAndValue})
          # Set the variable
          set(${Name} "${Value}")
          message("Set property from ${PREDEFINED_CONFIGS}: ${Name}=${Value}")
        endforeach()
    else()
        message(FATAL_ERROR "${CONFIGS_FILE} not found")
    endif()
endif()

set(TESTS_PATH ${CMAKE_CURRENT_SOURCE_DIR}/tests)

# All latter definitions should be called only once in root module
if(__add_cmake_definitions)
    return()
endif()
set(__add_cmake_definitions YES)

# Templates
set(TEMPLATES_PATH ${BUILD_SCRIPTS_PATH}/templates)

set(BUILD_SCRIPTS_PATH ${CMAKE_CURRENT_LIST_DIR})

# Cmake utils
include(${BUILD_SCRIPTS_PATH}/make/utils.cmake)

# Project definitions
if (NOT MODULES)
    set (MODULES ${CMAKE_SOURCE_DIR}/modules)
endif()

include (${BUILD_SCRIPTS_PATH}/make/definitions.cmake)
setCompilerOptions()

# Version
include (${BUILD_SCRIPTS_PATH}/make/version.cmake)
defineVersion()

# Install and config paths
include (${BUILD_SCRIPTS_PATH}/make/paths.cmake)

# Cmake build functions and macros
include (${BUILD_SCRIPTS_PATH}/make/boost.cmake)

# Define path for global generated includes and generate defs file
set(GLOBAL_GENERATED_INCLUDES ${CMAKE_BINARY_DIR}/include)
include_directories(${GLOBAL_GENERATED_INCLUDES})

configure_file(${TEMPLATES_PATH}/defs.h.in ${GLOBAL_GENERATED_INCLUDES}/Defs.h @ONLY)

# Define path for generated configs
set(GENERATED_CONFIG ${CMAKE_BINARY_DIR}/config)