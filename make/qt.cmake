# @file
# @brief This file plugs in Qt modules
#

if (_useQt)
    return()
endif()

set(_useQt true)

# The darkest and the blackest magic
# If someone mixes together the following headers in the following order:
# boost/foreach_fwd->qtglobal->boost/foreach he will fall to the deep hole of undefined symbols.
# We can't control this order so we use this little workaround to fix it.
# Now boost has Q_FOREACH inside and everybody happy.
add_definitions(-Dforeach=Q_FOREACH)

if (NOT DEFINED QT_QMAKE_EXECUTABLE)
    set(QT_QMAKE_EXECUTABLE qmake)
endif()

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

#For autogenerated files (moc, ui)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
find_package(Qt5 COMPONENTS Core REQUIRED)

function(useQtModule target module)
    find_package(Qt5 COMPONENTS ${module} REQUIRED)
    target_link_libraries(${target} Qt5::${module})
endfunction(useQtModule)

# on old OS (like astra) doesn't sets some variales for qt5 executables
# but qt4 variables can be used
macro(setupQtLocationVariable TARGET VARIABLE DEFAULT_VALUE HELP_STRING)
    set(EXECUTABLE ${DEFAULT_VALUE})

    if (TARGET ${TARGET})
        get_target_property(TARGET_EXECUTABLE ${TARGET} IMPORTED_LOCATION)

        if (TARGET_EXECUTABLE)
            set(EXECUTABLE ${TARGET_EXECUTABLE})
        endif()
    endif()

    set(${VARIABLE} "${EXECUTABLE}" CACHE STRING ${HELP_STRING} FORCE)
endmacro()

function(setQtBinaryVar VARIABLE PROGRAM PATH HELP_STRING)
    find_program(${VARIABLE} ${PROGRAM} PATHS ${PATH})
    message("${HELP_STRING} is ${${VARIABLE}}")
endfunction()

macro(setupQtVariables)
    message(STATUS "-------------------------------------Qt------------------------------")
    execute_process(COMMAND ${QT_QMAKE_EXECUTABLE} -query QT_VERSION OUTPUT_VARIABLE QT_VERSION)
    message("Installed Qt version: ${QT_VERSION}")

    execute_process(COMMAND ${QT_QMAKE_EXECUTABLE} -query QT_INSTALL_BINS OUTPUT_VARIABLE QT_BINARIES_PATH)
    setQtBinaryVar(MOC_EXECUTABLE "moc" "${QT_BINARIES_PATH}" "Meta Object compiler")
    setQtBinaryVar(UIC_EXECUTABLE "uic" "${QT_BINARIES_PATH}" "UI compiler")
    setQtBinaryVar(RCC_EXECUTABLE "rcc" "${QT_BINARIES_PATH}" "Resource compiler")
    setQtBinaryVar(DBUSCPP2XML_EXECUTABLE "qdbuscpp2xml" "${QT_BINARIES_PATH}" "DBUS cpp to xml converter")
    setQtBinaryVar(DBUSXML2CPP_EXECUTABLE "qdbusxml2cpp" "${QT_BINARIES_PATH}" "DBUS xml to cpp converter")
    setQtBinaryVar(QCOLLECTIONGENERATOR_EXECUTABLE "qcollectiongenerator" "${QT_BINARIES_PATH}" "Help collection generator")
    setQtBinaryVar(QHELPGENERATOR_EXECUTABLE "qhelpgenerator" "${QT_BINARIES_PATH}" "Help generator")
    setQtBinaryVar(LUPDATE_EXECUTABLE "lupdate" "${QT_BINARIES_PATH}" "lupdate")
    setQtBinaryVar(LRELEASE_EXECUTABLE "lrelease" "${QT_BINARIES_PATH}" "lrelease")
    setQtBinaryVar(DESIGNER_EXECUTABLE "designer" "${QT_BINARIES_PATH}" "UI designer")
    setQtBinaryVar(LINGUIST_EXECUTABLE "linguist" "${QT_BINARIES_PATH}" "Linguist")
    message(STATUS "========================================================================")
endmacro()

function(useQtModules)
    cmake_parse_arguments(USEQT "" "TARGET" "" ${ARGN})

    if("${USEQT_TARGET}" STREQUAL "")
        set(USEQT_TARGET ${PROJECT_NAME})
    endif()

    foreach(module ${USEQT_UNPARSED_ARGUMENTS})
        useQtModule(${USEQT_TARGET} ${module})
    endforeach(module)
endfunction(useQtModules)

setupQtVariables()

