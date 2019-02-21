#Get version and revision from git, set it to apropriate variables

macro(defineVersion)
    if(NOT DEFINED VERSION)
        execute_process(COMMAND git describe --abbrev=0 WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE VERSION RESULT_VARIABLE GIT_VERSION_PROCESS_RESULT)

        set(DEFAULT_VERSION "0.0.0")
        if (NOT ${GIT_VERSION_PROCESS_RESULT} EQUAL "0")
            message("Warning: can't determine version, set it to defaut (${DEFAULT_VERSION}).")

            set(VERSION ${DEFAULT_VERSION})
        endif(NOT ${GIT_VERSION_PROCESS_RESULT} EQUAL "0")

        string(REPLACE "." ";" VERSION_LIST ${VERSION})
        list(LENGTH VERSION_LIST VERSION_LENGTH)
        if (NOT VERSION_LENGTH EQUAL 3)
            message("Warning: version format is not correct (${VERSION}) set to default (${DEFAULT_VERSION}).")

            set(VERSION ${DEFAULT_VERSION})
        endif(NOT VERSION_LENGTH EQUAL 3)

        string (REPLACE "\n" "" VERSION "${VERSION}")
    endif()

    if(NOT DEFINED REVISION)
        execute_process(COMMAND git rev-parse --verify --short HEAD WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE REVISION)
        string (REPLACE "\n" "" REVISION "${REVISION}")
    endif()

    if(NOT DEFINED BUILD_NUMBER)
        set(BUILD_NUMBER 0)
    endif()

    if(DEFINED VERSION)
        string(REPLACE "." ";" VERSION_LIST ${VERSION})

        list(GET VERSION_LIST 0 VERSION_MAJOR)
        list(GET VERSION_LIST 1 VERSION_MINOR)
        list(GET VERSION_LIST 2 VERSION_NUMBER)

        set (VERSION_MAJOR ${VERSION_MAJOR} CACHE STRING "Version major" FORCE)
        set (VERSION_MINOR ${VERSION_MINOR} CACHE STRING "Version minor" FORCE)
        set (VERSION_NUMBER ${VERSION_NUMBER} CACHE STRING "Version number" FORCE)

        if(WIN32)
            set(libversion ${VERSION_MAJOR} CACHE STRING "Lib version" FORCE)
        endif()
    endif()

    string(TIMESTAMP BUILD_DATE "%Y-%m-%d")
    string(TIMESTAMP BUILD_YEAR "%Y")
endmacro()
