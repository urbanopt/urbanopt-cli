set(OPENSTUDIO_VERSION_MAJOR 3)
set(OPENSTUDIO_VERSION_MINOR 7)
set(OPENSTUDIO_VERSION_PATCH 0)
set(OPENSTUDIO_VERSION "${OPENSTUDIO_VERSION_MAJOR}.${OPENSTUDIO_VERSION_MINOR}.${OPENSTUDIO_VERSION_PATCH}")

find_package(openstudio "${OPENSTUDIO_VERSION}" CONFIG)
if(openstudio_FOUND)
  message("Found specified openstudio at ${openstudio_DIR}")
else()

  # TODO: currently unsupported, we do not host zip/tar.gz anywhere
  # This will make it throw, which an informative message
#  find_package(openstudio "${OPENSTUDIO_VERSION}" CONFIG REQUIRED)


  set(OPENSTUDIO_BASELINK "https://github.com/NREL/OpenStudio/releases/download/v${OPENSTUDIO_VERSION}"
    CACHE STRING "Base link to where the openstudio archives are hosted" FORCE)

  set(OPENSTUDIO_VERSION_SHA "+d5269793f1")

  if(APPLE)
    set(OPENSTUDIO_EXPECTED_HASH a4585ef0a3523168f8975ecd1cff1d12)
    set(OPENSTUDIO_PLATFORM "Darwin-x86_64")
    set(OPENSTUDIO_EXT "tar.gz")
  elseif(UNIX)
    if(LSB_RELEASE_VERSION_SHORT MATCHES "22.04")
      if (ARCH MATCHES "arm64")
        set(OPENSTUDIO_EXPECTED_HASH d98b3d3d133a7c5bc1b9581553d23811)
        set(OPENSTUDIO_PLATFORM "Ubuntu-22.04-arm64")
      else()
        set(OPENSTUDIO_EXPECTED_HASH 1e48f36417d3d118d6a10f1a7d61f46e)
      endif()
      set(OPENSTUDIO_EXPECTED_HASH 5c006e5e66e5e859206a63626ea2966f)
      set(OPENSTUDIO_PLATFORM "Ubuntu-22.04-x86_64")
    else() # Assumes 20.04
      set(OPENSTUDIO_EXPECTED_HASH 5c006e5e66e5e859206a63626ea2966f)
      set(OPENSTUDIO_PLATFORM "Ubuntu-20.04-x86_64")
    endif()
    if(LSB_RELEASE_VERSION_SHORT MATCHES "20.04")
      if (ARCH MATCHES "arm64")
        set(OPENSTUDIO_EXPECTED_HASH d98b3d3d133a7c5bc1b9581553d23811)
      else()
        set(OPENSTUDIO_EXPECTED_HASH 1e48f36417d3d118d6a10f1a7d61f46e)
      endif()
      set(OPENSTUDIO_EXPECTED_HASH 5c006e5e66e5e859206a63626ea2966f)
      set(OPENSTUDIO_PLATFORM "Ubuntu-20.04-x86_64")
    else() # Assumes 20.04
      set(OPENSTUDIO_EXPECTED_HASH 5c006e5e66e5e859206a63626ea2966f)
      set(OPENSTUDIO_PLATFORM "Ubuntu-20.04-x86_64")
    endif()
    set(OPENSTUDIO_EXT "tar.gz")
  elseif(WIN32)
    set(OPENSTUDIO_EXPECTED_HASH f192860357fdbffb5705942a991b072b)
    set(OPENSTUDIO_PLATFORM "Windows")
    set(OPENSTUDIO_EXT "tar.gz")
  endif()

  set(OPENSTUDIO_ARCHIVE_BASENAME "OpenStudio-${OPENSTUDIO_VERSION}${OPENSTUDIO_VERSION_SHA}-${OPENSTUDIO_PLATFORM}")
  set(OPENSTUDIO_ARCHIVE_NAME "${OPENSTUDIO_ARCHIVE_BASENAME}.${OPENSTUDIO_EXT}"
      CACHE STRING "Archive Name, with extension" FORCE)

  if(EXISTS "${PROJECT_BINARY_DIR}/${OPENSTUDIO_ARCHIVE_NAME}")
    file(MD5 "${PROJECT_BINARY_DIR}/${OPENSTUDIO_ARCHIVE_NAME}" OPENSTUDIO_HASH)
  endif()
  if(NOT EXISTS "${PROJECT_BINARY_DIR}/${OPENSTUDIO_ARCHIVE_NAME}" OR NOT "${OPENSTUDIO_HASH}" MATCHES "${OPENSTUDIO_EXPECTED_HASH}")
    set(OPENSTUDIO_URL "${OPENSTUDIO_BASELINK}/${OPENSTUDIO_ARCHIVE_NAME}")
    string(REPLACE "+" "%2B" OPENSTUDIO_URL ${OPENSTUDIO_URL})
    message(STATUS "Downloading OpenStudio SDK: ${OPENSTUDIO_URL}")

    file(DOWNLOAD "${OPENSTUDIO_URL}" "${PROJECT_BINARY_DIR}/${OPENSTUDIO_ARCHIVE_NAME}"
       INACTIVITY_TIMEOUT 300 # 5-min timeout
       SHOW_PROGRESS
       EXPECTED_MD5 ${OPENSTUDIO_EXPECTED_HASH})

    # Remove the old extracted dir if exists
    execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory "${PROJECT_BINARY_DIR}/${OPENSTUDIO_ARCHIVE_BASENAME}")

  endif()

  # Allows placing the archive manually in the build dir too
  if (NOT EXISTS "${OPENSTUDIO_ARCHIVE_BASENAME}")
    unset(OPENSTUDIO_FOUND CACHE)
    unset(OPENSTUDIO_WEATHER_DIR CACHE)
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xfz "${PROJECT_BINARY_DIR}/${OPENSTUDIO_ARCHIVE_NAME}" WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")
  endif()

  if(UNIX AND NOT APPLE)
    find_package(openstudio "${OPENSTUDIO_VERSION}" CONFIG REQUIRED
      PATHS "${PROJECT_BINARY_DIR}/${OPENSTUDIO_ARCHIVE_BASENAME}/usr/local/"
      NO_CMAKE_PATH
      NO_CMAKE_ENVIRONMENT_PATH
      NO_SYSTEM_ENVIRONMENT_PATH
      NO_CMAKE_SYSTEM_PATH
    )
  else()   
    find_package(openstudio "${OPENSTUDIO_VERSION}" CONFIG REQUIRED
      PATHS "${PROJECT_BINARY_DIR}/${OPENSTUDIO_ARCHIVE_BASENAME}"
      NO_CMAKE_PATH
      NO_CMAKE_ENVIRONMENT_PATH
      NO_SYSTEM_ENVIRONMENT_PATH
      NO_CMAKE_SYSTEM_PATH
    )
  endif()

endif()

get_filename_component(OPENSTUDIO_SDK_PATH "${openstudio_DIR}/../../../" ABSOLUTE)
set(OPENSTUDIO_SDK_PATH "${OPENSTUDIO_SDK_PATH}" CACHE STRING "This is the path to the root of SDK, under which you'll find bin/, lib/, etc" FORCE)
