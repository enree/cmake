# Functions for copy configs

function(installConfig TARGET DESTINATION COMPONENT)
    file(GLOB _files ${ARGN})

    convertRelativePath(${DESTINATION} INSTALL_CONFIG_PATH)
    install(FILES ${_files}
            DESTINATION ${INSTALL_CONFIG_PATH}
            COMPONENT "${COMPONENT}")

    add_custom_target(${TARGET}_config SOURCES ${_files})
endfunction(installConfig)

# Install project configuration
macro(installProjectConfiguration TARGET DESTINATION COMPONENT)
    # This should be done before installing generated files
    # If we have METAPACKAGE_STATIC_CONFIG_PATH defined we are to check config files for TARGET
    # Use default path if no files exist
    if (METAPACKAGE_STATIC_CONFIG_PATH)
        set (TARGET_CONFIG_PATH "${METAPACKAGE_STATIC_CONFIG_PATH}/${TARGET}")
        if(EXISTS "${TARGET_CONFIG_PATH}")
            installConfig(${TARGET}_staticConfig ${DESTINATION} ${COMPONENT} "${TARGET_CONFIG_PATH}/*")
            set(${TARGET}ConfigsOverridden TRUE)
        endif()
    endif()

    if (NOT ${TARGET}ConfigsOverridden)
        installConfig(${TARGET}_staticConfig ${DESTINATION} ${COMPONENT} "${CMAKE_CURRENT_SOURCE_DIR}/config/*")
    endif()

    installConfig(${TARGET}_generatedConfig ${DESTINATION} ${COMPONENT} "${GENERATED_CONFIG}/${TARGET}/*")

    if(IS_ROOT)
        installConfig(${TARGET}_nativeConfig ${DESTINATION} ${COMPONENT} "${CMAKE_CURRENT_SOURCE_DIR}/nativeconfig/*")
    endif()

endmacro()

macro(installSounds TARGET COMPONENT)
    installConfig(${TARGET}_sounds  ${SOUND_PATH} ${COMPONENT} "${CMAKE_CURRENT_SOURCE_DIR}/sounds/*")
endmacro()
