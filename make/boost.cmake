# @file
# @brief This file adds Boost components functions
#

if (_useBoost)
    return()
endif()

set(_useBoost true)

include(CMakeParseArguments)

#If you want to redefine Boost paths use the following hints
# BOOST_ROOT             - Preferred installation prefix
# BOOST_INCLUDEDIR       - Preferred include directory e.g. <prefix>/include
# BOOST_LIBRARYDIR       - Preferred library directory e.g. <prefix>/lib
# Boost_NO_SYSTEM_PATHS  - Set to ON to disable searching in locations not
#                          specified by these hint variables. Default is OFF.
function(useBoost)
    cmake_parse_arguments(USEBOOST "" "TARGET" "" ${ARGN})

    if("${USEBOOST_TARGET}" STREQUAL "")
        set(USEBOOST_TARGET ${PROJECT_NAME})
    endif()

    find_package(Boost REQUIRED COMPONENTS  ${USEBOOST_UNPARSED_ARGUMENTS})
    target_include_directories(${USEBOOST_TARGET} ${Boost_INCLUDE_DIRS})
    target_link_libraries(${USEBOOST_TARGET} ${Boost_LIBRARIES})
endfunction(useBoost)
