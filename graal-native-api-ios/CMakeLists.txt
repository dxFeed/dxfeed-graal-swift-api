# SPDX-License-Identifier: MPL-2.0

cmake_minimum_required(VERSION 3.10)

# Target
set(target DxFeedGraalNativeApi)

# Set project
project(${target})

# Print status
message(STATUS "Imported lib ${target}")

set(src_location ${CMAKE_CURRENT_SOURCE_DIR})
set(bin_location ${CMAKE_CURRENT_SOURCE_DIR})

if (DEFINED GRAAL_CUSTOM_SRC_LOCATION)
    set(src_location ${GRAAL_CUSTOM_SRC_LOCATION})
endif ()

if (DEFINED GRAAL_CUSTOM_BIN_LOCATION)
    set(bin_location ${GRAAL_CUSTOM_BIN_LOCATION})
endif ()


#
# Create target
#

# Add imported library
add_library(${target} SHARED IMPORTED GLOBAL)

# Set empty library prefix
set(lib_prefix "")
# Set empty library extension
set(lib_extension "")

# Add platform specific variable
if (WIN32)
    set(lib_prefix "")
    set(lib_extension "dll")
elseif (APPLE)
    set(lib_prefix "lib")
    set(lib_extension "dylib")
elseif (UNIX)
    set(lib_prefix "lib")
    set(lib_extension "so")
else ()
    message(ERROR "Unknown platform!")
endif ()


#
# Project options
#

# Target properties
set_target_properties(${target}
        PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${src_location}"
        # Path to dynamic library
        IMPORTED_LOCATION "${bin_location}/${lib_prefix}${target}.${lib_extension}"
        # For Windows
        IMPORTED_IMPLIB "${bin_location}/${lib_prefix}${target}.lib"
        # For Linux and macOS
        IMPORTED_NO_SONAME "TRUE"
        )

# Deployment
install(IMPORTED_RUNTIME_ARTIFACTS ${target}
        RUNTIME DESTINATION ${INSTALL_BIN} COMPONENT runtime
        LIBRARY DESTINATION ${INSTALL_SHARED} COMPONENT runtime
        )
