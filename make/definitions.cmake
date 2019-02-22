#Common c++ build flags
macro(setupCompiler)
    # gcc 6+ use c++11 by default
    # warnings about auto_ptr in boost 1.55
    set(WARNING_FLAGS "-Wall -Wextra -Werror -Woverloaded-virtual -Winit-self -Wno-unused-parameter -Wno-deprecated-declarations")
    set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} ${WARNING_FLAGS}")
    
    if (NOT CMAKE_CXX_STANDARD)
        set (CMAKE_CXX_STANDARD 14)
    endif()
    
    message ("Compile flags: ${CMAKE_CXX_FLAGS}")

    option(SANITIZE "Turn on address sanitizer" OFF)
    option(COVERAGE "Turn on gcov" OFF)

    # Sometimes CMAKE_BUILD_TYPE is not set if we don't pass -DCMAKE_BUILD_TYPE
    # and the following expression breaks the compilation.
    if (NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE "Release")
    endif (NOT CMAKE_BUILD_TYPE)

    if(CMAKE_BUILD_TYPE MATCHES "Debug")
        # Install submodules along with project binaries
        set(INSTALL_SUBMODULE true)
        set(DEBUG_FLAGS "-O0 -g")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${DEBUG_FLAGS}")
        set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

        # Turn on coverage build
        if(COVERAGE)
            set(COVERAGE_FLAGS "-pg --coverage")
            message("------------------COVERAGE IS ON------------------")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COVERAGE_FLAGS}")
            set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${COVERAGE_FLAGS}")
            set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${COVERAGE_FLAGS}")
            set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} ${COVERAGE_FLAGS}")
            set(GCOV ON)
        endif(COVERAGE)
    else()
        set(RELEASE_FLAGS "-O3")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${RELEASE_FLAGS}")
    endif(CMAKE_BUILD_TYPE MATCHES "Debug")

    #Remove some warning depending of compiler
    # CMAKE_CXX_COMPILER_ID is one of Clang, GNU, Intel or MSVC
    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        SET(USE_CLANG ON)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-const-variable")
        if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 3.6)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-local-typedefs")
        endif()

        #Turn on address sanitizer
        if(SANITIZE)
            message("------------------SANITIZER IS ON------------------")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address -fno-omit-frame-pointer")
            set(CMAKE_SHARED_LINKER_FLAGS "-fsanitize=address")
            set(CMAKE_EXE_LINKER_FLAGS "-fsanitize=address")
        endif()

        message("--------------CLANG--------------- Version: " ${CMAKE_CXX_COMPILER_VERSION})
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        add_definitions(-Wno-unused-local-typedefs)

        if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 7.0)     # Old gcc
            message(FATAL_ERROR "Unsupported compiler, please, upgrade to newer version!")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-placement-new")
        endif()

        message("--------------GCC--------------- Version: " ${CMAKE_CXX_COMPILER_VERSION})
    else()
        message(FATAL_ERROR "Unsupported compiler")
    endif()

    if (UNIX)
        add_definitions(-DOS_UNIX)
    elseif(WIN32)
        add_definitions(-DOS_WIN32)
    else()
        message(FATAL_ERROR "Usupported OS" )
    endif(UNIX)
endmacro()
