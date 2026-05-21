cmake_minimum_required(VERSION 3.10.2)
cmake_policy(SET CMP0048 NEW)

project(URBANoptCLI VERSION 1.2.0)


# Get the system arch. 
if(UNIX)
  # Allow overriding from the command line with -DARCH=...
  if(NOT DEFINED ARCH OR "${ARCH}" STREQUAL "")
    # OS_RELEASE is the result of `uname -r` which is unhelpful (eg '5.4.0-42-generic')
    find_program(LSB_RELEASE lsb_release)
    # -rs outputs only version, e.g. 20.04
    execute_process(COMMAND ${LSB_RELEASE} -rs OUTPUT_VARIABLE LSB_RELEASE_VERSION_SHORT OUTPUT_STRIP_TRAILING_WHITESPACE)

    # -is outputs "Ubuntu" or "Fedora"
    execute_process(COMMAND ${LSB_RELEASE} -is OUTPUT_VARIABLE LSB_RELEASE_ID_SHORT OUTPUT_STRIP_TRAILING_WHITESPACE)

    find_program(UNAME uname)
    execute_process(COMMAND ${UNAME} -m
      OUTPUT_VARIABLE ARCH
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  endif()

  if (ARCH STREQUAL "aarch64")
    set(ARCH "arm64")
  endif()

endif()


include(FindOpenStudioSDK.cmake)

get_target_property(os_cli_location openstudio::openstudio LOCATION)
set(os_cli_install_name "openstudio${CMAKE_EXECUTABLE_SUFFIX}")

# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
    "MinSizeRel" "RelWithDebInfo")
endif()

if ( APPLE )
  find_library(SECURITY_FRAMEWORK Security)
endif()

include(ExternalProject)
include(CPackComponent)



###############################################################################
#                       P R O J E C T    V E R S I O N                        #
###############################################################################
# Project version information

set(PROJECT_VERSION_BUILD "Unknown" CACHE STRING "Build number") # git sha
find_package(Git)

if(NOT GIT_FOUND)
  find_program(GIT_EXECUTABLE git HINTS "$ENV{LOCALAPPDATA}/Programs/git/bin" "C:/Program Files/Git/bin")
  if(NOT GIT_EXECUTABLE_NOTFOUND)
    set(GIT_FOUND TRUE)
  endif()
endif()

if(GIT_FOUND)
  execute_process(COMMAND "${GIT_EXECUTABLE}" "rev-parse" "--short=10" "HEAD"
                  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
                  TIMEOUT 10
                  RESULT_VARIABLE RESULT
                  OUTPUT_VARIABLE GIT_VERSION
                  ERROR_QUIET
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(${RESULT} EQUAL 0 AND NOT "${GIT_VERSION}" EQUAL "${PROJECT_VERSION_BUILD}")
    set(PROJECT_VERSION_BUILD ${GIT_VERSION} CACHE STRING "Build number" FORCE) # git sha
  endif()

  get_filename_component(GIT_DIR "${GIT_EXECUTABLE}" DIRECTORY)
else()
  set(GIT_DIR "")
endif()

# URBANopt version: Allows to add a pre1 tag as needed.
set(URBANOPT_CLI_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
# TODO JM 2019-07-12: Comment out (or delete) if prerelease tag not needed
set(URBANOPT_CLI_PRERELEASE_TAG "")
if (NOT "${URBANOPT_CLI_PRERELEASE_TAG}" STREQUAL "")
  message(STATUS "We have a prerelease tag set to '${URBANOPT_CLI_PRERELEASE_TAG}'")
  set(URBANOPT_CLI_VERSION "${URBANOPT_CLI_VERSION}-${URBANOPT_CLI_PRERELEASE_TAG}")
else()
  message(STATUS "We do not have a prerelease tag")
endif()
set(URBANOPT_CLI_LONG_VERSION "${URBANOPT_CLI_VERSION}.${PROJECT_VERSION_BUILD}")
message(STATUS "URBANOPT_CLI_VERSION=${URBANOPT_CLI_VERSION}")
message(STATUS "URBANOPT_CLI_LONG_VERSION=${URBANOPT_CLI_LONG_VERSION}")


###############################################################################
#                         B U I L D    O P T I O N S                          #
###############################################################################

option(BUILD_PACKAGE "Build package" OFF)



###############################################################################
#                           D E P E N D E N C I E S                           #
###############################################################################

# Required dependencies

# CI will build and upload urbanopt-cli-gems to s3 at (TBD)
# need to  update the MD5sum for each platform and url below
if(UNIX)
  if(APPLE)
    if (ARCH MATCHES "arm64")
      set(URBANOPT_CLI_GEMS_ZIP_FILENAME "urbanopt-cli-gems-20260518-darwin_arm64.tar.gz")
      set(URBANOPT_CLI_GEMS_ZIP_EXPECTED_MD5 "65431ad99ba876d0e1897ae3d332af11")
    else()
      set(URBANOPT_CLI_GEMS_ZIP_FILENAME "urbanopt-cli-gems-20251014-darwin_x86_64.tar.gz")
      set(URBANOPT_CLI_GEMS_ZIP_EXPECTED_MD5 "a4355702143c741a8d3972af225e867a")
    endif()	
  else()
    if (ARCH MATCHES "arm64")
      set(URBANOPT_CLI_GEMS_ZIP_FILENAME "urbanopt-cli-gems-20260519-linux_arm64.tar.gz")
      set(URBANOPT_CLI_GEMS_ZIP_EXPECTED_MD5 "b5e69d884ae679bbd18a4ebc2ce93967")
    else() 
      set(URBANOPT_CLI_GEMS_ZIP_FILENAME "urbanopt-cli-gems-20260518-linux_x86_64.tar.gz")
      set(URBANOPT_CLI_GEMS_ZIP_EXPECTED_MD5 "1e9e73f84d7bc2339bd31459e19d74a1")
    endif()	
  endif()
elseif(WIN32)
  if(CMAKE_CL_64)
    set(URBANOPT_CLI_GEMS_ZIP_FILENAME "urbanopt-cli-gems-20260520-windows.tar.gz")
    set(URBANOPT_CLI_GEMS_ZIP_EXPECTED_MD5 "22e9d2f076aeb87e4959218db81b6996")
  endif()
endif()

set(URBANOPT_CLI_GEMS_ZIP_LOCAL_PATH "${PROJECT_BINARY_DIR}/${URBANOPT_CLI_GEMS_ZIP_FILENAME}")
set(URBANOPT_CLI_GEMS_DIR "${PROJECT_BINARY_DIR}/urbanopt-cli-gems")
if(EXISTS "${URBANOPT_CLI_GEMS_ZIP_LOCAL_PATH}")
  file(MD5 "${URBANOPT_CLI_GEMS_ZIP_LOCAL_PATH}" URBANOPT_CLI_GEMS_ZIP_MD5)
endif()

if(NOT URBANOPT_CLI_GEMS_ZIP_MD5 STREQUAL URBANOPT_CLI_GEMS_ZIP_EXPECTED_MD5)
  message(STATUS "Downloading URBANopt-CLI Gems: ${URBANOPT_CLI_GEMS_ZIP_FILENAME}")
  file(DOWNLOAD "https://urbanopt-cli-resources.s3-us-west-2.amazonaws.com/gems/${URBANOPT_CLI_GEMS_ZIP_FILENAME}"
    ${URBANOPT_CLI_GEMS_ZIP_LOCAL_PATH}
    INACTIVITY_TIMEOUT 300 # 5 minute timeout
    SHOW_PROGRESS
    EXPECTED_MD5 ${URBANOPT_CLI_GEMS_ZIP_EXPECTED_MD5})
#  file(REMOVE_RECURSE "${URBANOPT_CLI_GEMS_DIR}")
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xfz ${URBANOPT_CLI_GEMS_ZIP_LOCAL_PATH} WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")

endif()



# Windows build needs a seperate gem package for running openstudio workflows due to 
# not being able to use any native compiled gem on windows platform (sqlite being the issue)
if(WIN32)
  if(CMAKE_CL_64)
    set(OPENSTUDIO_RUNTIME_GEMS_ZIP_FILENAME "openstudio-runtime-gems-20260519-windows.tar.gz")
    set(OPENSTUDIO_RUNTIME_GEMS_ZIP_EXPECTED_MD5 "027bbc398e192914dfc09c467e7c79f6")
  endif()

  set(OPENSTUDIO_RUNTIME_GEMS_ZIP_LOCAL_PATH "${PROJECT_BINARY_DIR}/${OPENSTUDIO_RUNTIME_GEMS_ZIP_FILENAME}")
  set(OPENSTUDIO_RUNTIME_GEMS_DIR "${PROJECT_BINARY_DIR}/openstudio-runtime-gems")
  if(EXISTS "${OPENSTUDIO_RUNTIME_GEMS_ZIP_LOCAL_PATH}")
    file(MD5 "${OPENSTUDIO_RUNTIME_GEMS_ZIP_LOCAL_PATH}" OPENSTUDIO_RUNTIME_GEMS_ZIP_MD5)
  endif()

  if(NOT OPENSTUDIO_RUNTIME_GEMS_ZIP_MD5 STREQUAL OPENSTUDIO_RUNTIME_GEMS_ZIP_EXPECTED_MD5)
    message(STATUS "Downloading Openstudio Runtime Gems: ${OPENSTUDIO_RUNTIME_GEMS_ZIP_FILENAME}")
    file(DOWNLOAD "https://urbanopt-cli-resources.s3-us-west-2.amazonaws.com/gems/${OPENSTUDIO_RUNTIME_GEMS_ZIP_FILENAME}"
      ${OPENSTUDIO_RUNTIME_GEMS_ZIP_LOCAL_PATH}
      INACTIVITY_TIMEOUT 300 # 5 minute timeout
      SHOW_PROGRESS
      EXPECTED_MD5 ${OPENSTUDIO_RUNTIME_GEMS_ZIP_EXPECTED_MD5})
  #  file(REMOVE_RECURSE "${OPENSTUDIO_RUNTIME_GEMS_DIR}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xfz ${OPENSTUDIO_RUNTIME_GEMS_ZIP_LOCAL_PATH} WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")
  endif()
endif()


set(RUBY_DIR "${PROJECT_BINARY_DIR}/ruby")

if(UNIX)
  if(APPLE)
    if(ARCH MATCHES "arm64")
      set(RUBY_ZIP_FILENAME "ruby-3.2.2-darwin_arm64.tar.gz")
      set(RUBY_ZIP_EXPECTED_MD5 "01ccfb8acbf67b3e172795301767dde3")
    else() 
      set(RUBY_ZIP_FILENAME "ruby-3.2.2-darwin_x86_64.tar.gz")
      set(RUBY_ZIP_EXPECTED_MD5 "e431eb4e78391d29d7ed0c138f59125c")
    endif()
  else() # Linux
    if (ARCH MATCHES "arm64")
      set(RUBY_ZIP_FILENAME "ruby-3.2.2-linux_arm64.tar.gz")
      set(RUBY_ZIP_EXPECTED_MD5 "7a777f6a4fdbf7b8d561156a94e677b8")
    else() 
      set(RUBY_ZIP_EXPECTED_MD5 "74c9f8f4c693df02a361730dcf780a99")
      set(RUBY_ZIP_FILENAME "ruby-3.2.2-linux_x86_64.tar.gz")
    endif()
  endif()
elseif(WIN32)
  set(RUBY_ZIP_FILENAME "ruby-3.2.2_win32.tar.gz")
  set(RUBY_ZIP_EXPECTED_MD5 "c67bda97ad696d66561c3f39387fd5d1")
endif()

set(RUBY_ZIP_LOCAL_PATH "${PROJECT_BINARY_DIR}/${RUBY_ZIP_FILENAME}")
set(RUBY_DIR "${PROJECT_BINARY_DIR}/ruby")

if(EXISTS "${RUBY_ZIP_LOCAL_PATH}")
  file(MD5 "${RUBY_ZIP_LOCAL_PATH}" RUBY_ZIP_MD5)
endif()

if(NOT RUBY_ZIP_MD5 STREQUAL RUBY_ZIP_EXPECTED_MD5)
  message(STATUS "Downloading Ruby: ${RUBY_ZIP_FILENAME}")
  file(DOWNLOAD "https://urbanopt-cli-resources.s3-us-west-2.amazonaws.com/ruby/${RUBY_ZIP_FILENAME}"
    ${RUBY_ZIP_LOCAL_PATH}
    INACTIVITY_TIMEOUT 300 # 5 minute timeout
    SHOW_PROGRESS
    EXPECTED_MD5 ${RUBY_ZIP_EXPECTED_MD5})

  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xfz ${RUBY_ZIP_LOCAL_PATH} WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")
endif()


# Download uv package manager from GitHub releases
set(UV_VERSION "0.11.15")

if(UNIX)
  if(APPLE)
    if(ARCH MATCHES "arm64")
      set(UV_ARCHIVE_FILENAME "uv-aarch64-apple-darwin.tar.gz")
      set(UV_ARCHIVE_ROOT "uv-aarch64-apple-darwin")
    else()
      set(UV_ARCHIVE_FILENAME "uv-x86_64-apple-darwin.tar.gz")
      set(UV_ARCHIVE_ROOT "uv-x86_64-apple-darwin")
    endif()
  else() # Linux
    if(ARCH MATCHES "arm64")
      set(UV_ARCHIVE_FILENAME "uv-aarch64-unknown-linux-gnu.tar.gz")
      set(UV_ARCHIVE_ROOT "uv-aarch64-unknown-linux-gnu")
    else()
      set(UV_ARCHIVE_FILENAME "uv-x86_64-unknown-linux-gnu.tar.gz")
      set(UV_ARCHIVE_ROOT "uv-x86_64-unknown-linux-gnu")
    endif()
  endif()
  set(UV_BINARY_NAME "uv")
elseif(WIN32)
  set(UV_ARCHIVE_FILENAME "uv-x86_64-pc-windows-msvc.zip")
  set(UV_ARCHIVE_ROOT "uv-x86_64-pc-windows-msvc")
  set(UV_BINARY_NAME "uv.exe")
endif()

set(UV_ARCHIVE_LOCAL_PATH "${PROJECT_BINARY_DIR}/${UV_ARCHIVE_FILENAME}")
set(UV_EXTRACTED_DIR "${PROJECT_BINARY_DIR}/${UV_ARCHIVE_ROOT}")
set(UV_STAGED_BINARY_PATH "${PROJECT_BINARY_DIR}/${UV_BINARY_NAME}")

if(NOT EXISTS "${UV_ARCHIVE_LOCAL_PATH}")
  message(STATUS "Downloading uv: ${UV_ARCHIVE_FILENAME}")
  file(DOWNLOAD "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/${UV_ARCHIVE_FILENAME}"
    ${UV_ARCHIVE_LOCAL_PATH}
    INACTIVITY_TIMEOUT 300 # 5 minute timeout
    SHOW_PROGRESS)
endif()

if(NOT EXISTS "${UV_STAGED_BINARY_PATH}" AND
   NOT EXISTS "${UV_EXTRACTED_DIR}/${UV_BINARY_NAME}" AND
   NOT EXISTS "${PROJECT_BINARY_DIR}/${UV_ARCHIVE_FILENAME}/${UV_BINARY_NAME}")
  message(STATUS "Extracting uv: ${UV_ARCHIVE_FILENAME}")
  if(WIN32)
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xvf ${UV_ARCHIVE_LOCAL_PATH} WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")
  else()
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xfz ${UV_ARCHIVE_LOCAL_PATH} WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")
  endif()
endif()

if(NOT EXISTS "${UV_STAGED_BINARY_PATH}")
  if(EXISTS "${UV_EXTRACTED_DIR}/${UV_BINARY_NAME}")
    message(STATUS "Staging uv binary to project binary directory")
    file(COPY "${UV_EXTRACTED_DIR}/${UV_BINARY_NAME}" DESTINATION "${PROJECT_BINARY_DIR}")
  elseif(EXISTS "${PROJECT_BINARY_DIR}/${UV_ARCHIVE_FILENAME}/${UV_BINARY_NAME}")
    message(STATUS "Staging uv binary from extracted archive-named directory")
    file(COPY "${PROJECT_BINARY_DIR}/${UV_ARCHIVE_FILENAME}/${UV_BINARY_NAME}" DESTINATION "${PROJECT_BINARY_DIR}")
  else()
    message(FATAL_ERROR "Unable to locate extracted uv binary '${UV_BINARY_NAME}'")
  endif()
endif()




###############################################################################
#                              I N S T A L L E R                              #
###############################################################################

######### Install SDK dependencies here ################

install(DIRECTORY "${OPENSTUDIO_SDK_PATH}/" DESTINATION "OpenStudio" COMPONENT "OpenStudio" USE_SOURCE_PERMISSIONS)
#install(DIRECTORY "${URBANOPT_CLI_GEMS_DIR}/" DESTINATION ".gems" COMPONENT "URBANopt" USE_SOURCE_PERMISSIONS)


if(UNIX)
  install(PROGRAMS ${PROJECT_SOURCE_DIR}/scripts/setup-env-unix.sh DESTINATION "." COMPONENT "URBANopt" RENAME "setup-env.sh")
elseif(WIN32)
  install(PROGRAMS ${PROJECT_SOURCE_DIR}/scripts/setup-env-gitbash.sh DESTINATION "." COMPONENT "URBANopt" RENAME "setup-env.sh")
  install(PROGRAMS ${PROJECT_SOURCE_DIR}/scripts/setup-env.ps1 DESTINATION "." COMPONENT "URBANopt")
  install(PROGRAMS ${PROJECT_SOURCE_DIR}/scripts/setup-env.bat DESTINATION "." COMPONENT "URBANopt")
endif()

install(DIRECTORY "${PROJECT_BINARY_DIR}/ruby" DESTINATION "." COMPONENT "Ruby" USE_SOURCE_PERMISSIONS)
install(DIRECTORY "${PROJECT_BINARY_DIR}/urbanopt-cli-gems/" DESTINATION "gems" COMPONENT "URBANopt" USE_SOURCE_PERMISSIONS)
install(PROGRAMS "${UV_STAGED_BINARY_PATH}" DESTINATION "." COMPONENT "URBANopt")

if(WIN32)
  install(DIRECTORY "${PROJECT_BINARY_DIR}/openstudio-runtime-gems/" DESTINATION "openstudio-runtime-gems" COMPONENT "URBANopt" USE_SOURCE_PERMISSIONS)
endif()


set(CPACK_PACKAGE_VENDOR "National Renewable Energy Laboratory")
# These are ok, even if we have a prerelease tag
set(CPACK_PACKAGE_VERSION_MAJOR ${URBANOPT_CLI_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${URBANOPT_CLI_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${URBANOPT_CLI_VERSION_PATCH})

# TODO:/URBANOPT_CLI_VERSION
# CPACK_DEBIAN_PACKAGE_DESCRIPTION defaults to this one too. dpkg-deb -I xxx.deb will show this description
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "URBANoptCLI ${URBANOPT_CLI_VERSION} is a CLI software tool to support whole building energy modeling using EnergyPlus and advanced daylight analysis using Radiance")

# The actual package file name on disk
set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${URBANOPT_CLI_LONG_VERSION}-${CMAKE_SYSTEM_NAME}")
set(CPACK_PACKAGE_CONTACT "openstudio@nlr.gov")

# Install additional Documents, such as release notes
#install(FILES "${PROJECT_SOURCE_DIR}/LICENSE.md" DESTINATION .)

if (APPLE)
  set(CPACK_IFW_TARGET_DIRECTORY "/Applications/URBANoptCLI_${URBANOPT_CLI_VERSION}/")
elseif(UNIX)

  # For debug
  # set(CPACK_DEBIAN_PACKAGE_DEBUG ON)

  # These two will set the .deb install path correctly
  set(CPACK_DEBIAN_PACKAGE_DEPENDS "libqdbm14,sqlite3,libgomp1,libncurses5")
  set(CPACK_SET_DESTDIR ON)
  set(CPACK_INSTALL_PREFIX /usr/local/urbanopt-cli-${URBANOPT_CLI_VERSION})

  set(CPACK_DEBIAN_PACKAGE_MAINTAINER "openstudio@nlr.gov")
  # Default the debian package name to include version to allow several versions to be installed concurrently instead of overwriting any existing one
  set(CPACK_DEBIAN_PACKAGE_NAME "urbanopt-cli-${URBANOPT_CLI_VERSION}")
  set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://www.openstudio.net")

  set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CPACK_DEBIAN_BIN_PACKAGE_CONTROL_EXTRA};${POSTINST_FILE};${POSTRM_FILE}")

elseif(WIN32)
  set(CPACK_PACKAGE_INSTALL_DIRECTORY "URBANopt-cli-${URBANOPT_CLI_VERSION}")
  set(CPACK_IFW_TARGET_DIRECTORY "C:/${CPACK_PACKAGE_INSTALL_DIRECTORY}")
  set(CPACK_BINARY_IFW ON CACHE BOOL "Enable to build IFW packages")
  set(CPACK_BINARY_NSIS OFF CACHE BOOL "Enable to build NSIS packages")
endif()

include(CPackIFW)

cpack_add_component(URBANopt
  DISPLAY_NAME "URBANopt CLI"
  DESCRIPTION "URBANopt CLI software tool"
)

cpack_add_component(OpenStudio
  DISPLAY_NAME "OpenStudio SDK"
  DESCRIPTION "OpenStudio SDK"
)

cpack_ifw_configure_component(URBANopt
  REQUIRES_ADMIN_RIGHTS
)

cpack_ifw_configure_component(OpenStudio
  REQUIRES_ADMIN_RIGHTS
)

include(CPack)

