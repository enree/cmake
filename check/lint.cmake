set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(CMakeParseArguments)

option(LINT "Enable linters" ON)

find_program(CLANG_TIDY clang-tidy)
find_program(CLAZY clazy-standalone)

macro(enableClangTidy TARGET)
    if (NOT LINT)
        message(STATUS "Clang-tidy is disabled")
    else()
        if(NOT CLANG_TIDY OR NOT USE_CLANG)
            message(STATUS "Either clang-tidy is not found or clang is not being used, clang-tidy is disabled.")
        else()
            message(STATUS "Found clang-tidy ${CLANG_TIDY}")

            set(oneValueArgs CHECKS)

            cmake_parse_arguments(OPTIONS "" "${oneValueArgs}" "" ${ARGN})
            if (NOT OPTIONS_CHECKS)
                set(OPTIONS_CHECKS "clang-diagnostic-*,clang-analyzer-*,bugpone-*,\
                    cppcoreguidelines-*,-cppcoreguidelines-pro-bounds-array-to-pointer-decay,\
                    -cppcoreguidelines-pro-bounds-pointer-arithmetic,\
                    -cppcoreguidelines-pro-bounds-constant-array-index,\
                    -cppcoreguidelines-owning-memory,\
                    -cppcoreguidelines-pro-type-reinterpret-cast,\
                    -cppcoreguidelines-special-member-functions,\
                    hicpp-*,-hicpp-no-array-decay,-hicpp-special-member-functions,\
                    llvm-*,-llvm-namespace-comment,\
                    modernize-*,-modernize-concat-nested-namespaces,\
                    performance-*,readability-*")
            endif()

            set_target_properties(${TARGET}
                PROPERTIES CXX_CLANG_TIDY
                "${CLANG_TIDY};-checks=${OPTIONS_CHECKS};-warnings-as-errors=*;-p=${CMAKE_BINARY_DIR};-header-filter='${CMAKE_CURRENT_SOURCE_DIR}/*'")
        endif()
    endif()

endmacro()

macro(enableClazy TARGET)
    if (NOT LINT)
        message(STATUS "Clazy is disabled")
    else()
        if(NOT CLAZY OR NOT USE_CLANG)
            message(STATUS "Either clazy is not found or clang is not being used, clazy is disabled.")
        else()
            message(STATUS "Found clazy ${CLAZY}")

            set(oneValueArgs CHECKS)

            cmake_parse_arguments(OPTIONS "" "${oneValueArgs}" "" ${ARGN})
            if (NOT OPTIONS_CHECKS)
                #Checks from manual level
                set(CHECKS "inefficient-qlist-soft,isempty-vs-count,qhash-with-char-pointer-key,tr-non-literal")
                #Checks from level 3
                set(CHECKS "assert-with-side-effects,unneeded-cast,${CHECKS}")
                #Checks from level 2
                set(CHECKS "base-class-event,function-args-by-ref,global-const-char-pointer,implicit-casts,${CHECKS}")

                set(CHECKS "-checks=${CHECKS},level1")
            else()
                set(CHECKS "-checks=${OPTIONS_CHECKS}")
            endif()


            set_target_properties(${TARGET}
                PROPERTIES CXX_CPPLINT
                "${CLAZY};${CHECKS};-p=${CMAKE_BINARY_DIR};-header-filter='${CMAKE_CURRENT_SOURCE_DIR}/*")
        endif()
    endif()

endmacro()

macro(enableCppcheck TARGET)
    if (NOT LINT)
        message(STATUS "Cppcheck is disabled")
    else()
        find_program(CPPCHECK NAMES cppcheck)
        if(NOT CPPCHECK)
            message(STATUS "Cppcheck is not found and check is disabled.")
        else()
            message(STATUS "Found cppcheck ${CPPCHECK}")

            set(oneValueArgs CHECKS SUPPRESSIONS)
            set(multiValueArgs EXCLUDES)

            cmake_parse_arguments(OPTIONS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

            list(
                APPEND CPPCHECK
                    "--enable=all"
                    "--inconclusive"
                    "--force"
                    "--inline-suppr"
                    "--std=c++11"
                    "--library=qt"
                    "--verbose"
                    "--template='[{severity}][{id}] {message} {callstack} (On {file}:{line})'"

            )

            if (OPTIONS_SUPPRESSIONS)
                list(APPEND CPPCHECK "--suppressions-list=${OPTIONS_SUPPRESSIONS}")
            endif()
            foreach(_exclude ${OPTIONS_EXCLUDES})
                list(APPEND CPPCHECK "-i${_exclude}")
            endforeach()

            set_target_properties(${TARGET}
                PROPERTIES CXX_CPPCHECK
                "${CPPCHECK}")
        endif()
    endif()

endmacro()

macro(lint TARGET)
    enableClangTidy(${TARGET})
    enableClazy(${TARGET})
#    enableCppcheck(${TARGET})
endmacro()
