# @file
# @brief Platform detection routines here
#
#
# $Id: $

macro(updatePlatform PLATFORM_STRING)
    set(PLATFORM ${PLATFORM_STRING})

    string(TOUPPER ${PLATFORM} PLATFORM_UPPERCASE)
    set(PLATFORM_${PLATFORM_UPPERCASE} ON)
endmacro()

macro(queryLsbRelease)
    execute_process(COMMAND lsb_release -si
                    RESULT_VARIABLE LSB_RESULT
                    OUTPUT_VARIABLE LSB_OUTPUT)
    if (${LSB_RESULT} EQUAL 0)
        if (LSB_OUTPUT MATCHES ".*Debian.*")
            updatePlatform("Debian")
        elseif (LSB_OUTPUT MATCHES ".*Astra.*")
            updatePlatform("Astra")
        elseif (LSB_OUTPUT MATCHES ".*Gentoo.*")
            updatePlatform("Gentoo")
        endif()
    endif()
endmacro()

macro(queryReleaseFile)
    if(EXISTS "/etc/debian_version")
        updatePlatform("Debian")
    elseif(EXISTS "/etc/redhat-release")
        updatePlatform("Redhat")
    elseif(EXISTS "/etc/MCBC-release")
        updatePlatform("MSVS")
    endif()
endmacro()

macro(queryLinux)
    queryLsbRelease()
    if (PLATFORM MATCHES "Unix")
        queryReleaseFile()
    endif()
endmacro()

if (NOT PLATFORM)
    if(UNIX)
        updatePlatform("Unix")
        queryLinux()
    elseif(WIN32)
        updatePlatform("Windows")
    else()
        message(WARNING "Can not detect platform type,
                         issues with compiling and packaging possible")
    endif()
else()
    updatePlatform(${PLATFORM})
endif()

configure_file(${CMAKE_SCRIPTS_PATH}/templates/platform.h.in
    ${GLOBAL_GENERATED_INCLUDES}/Platform.h @ONLY)
