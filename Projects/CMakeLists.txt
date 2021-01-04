cmake_minimum_required(VERSION 3.12.0 FATAL_ERROR)
CMAKE_POLICY(SET CMP0077 NEW)

#######################################
#         PROJECT INFORMATION         #
#######################################

# Project name
project("ExternalMedia")

# Project version
set(VERSION_MAJOR 3)
set(VERSION_MINOR 2)
set(VERSION_PATCH 3)
set(APP_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")
message(STATUS "ExternalMedia library version: ${APP_VERSION}")
set(LIBRARY_NAME "ExternalMediaLib")
set(LIBRARY_HEADER "externalmedialib.h")


#######################################
#       PROJECT-WIDE OPTIONS          #
#######################################
option(ENABLE_DYMOLA "Build a library that is compatible with the Dymola software" ON)
option(ENABLE_OPEN_MODELICA "Build a library that is compatible with the Open Modelica environment" ON)

# Use the Modelica Standard Library headers
if(ENABLE_DYMOLA OR ENABLE_OPEN_MODELICA)
  set(ENABLE_MSL_HEADERS ON)
else()
  set(ENABLE_MSL_HEADERS OFF)
endif()

option(ADD_FLUIDPROP_SHARED "Link the shared FluidProp library to ExternalMedia, requires FluidProp to be available in the system PATH" OFF)
option(ADD_COOLPROP_OBJECT "Link the CoolProp object files to ExternalMedia" ON)
option(ADD_COOLPROP_SHARED "NOT SUPPORTED: Link the shared CoolProp library to ExternalMedia, requires CoolProp to be available in the system PATH" OFF)

# "Build a library that uses the FluidProp solver"
if(ADD_FLUIDPROP_STATIC OR ADD_FLUIDPROP_SHARED)
  set(ENABLE_FLUIDPROP ON)
else()
  set(ENABLE_FLUIDPROP OFF)
endif()

# "Build a library that uses the CoolProp solver"
if(ADD_COOLPROP_OBJECT OR ADD_COOLPROP_STATIC OR ADD_COOLPROP_SHARED)
  set(ENABLE_COOLPROP ON)
else()
  set(ENABLE_COOLPROP OFF)
endif()

macro(set_define BASE_VAR)
  if(${BASE_VAR})
    set(${BASE_VAR}_DEFINE 1)
  else()
    set(${BASE_VAR}_DEFINE 0)
  endif()
endmacro()

# Use the current options to create the include definitions
set_define(ENABLE_DYMOLA)
set_define(ENABLE_OPEN_MODELICA)
set_define(ENABLE_FLUIDPROP)
set_define(ENABLE_COOLPROP)
set_define(BUILD_SHARED_LIBS)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Sources/include.h.in ${CMAKE_CURRENT_SOURCE_DIR}/Sources/include.h @ONLY)


#######################################
#       PROJECT-WIDE SETTINGS         #
#######################################

# if (MSVC)
# #    # Force visual studio to statically link the c runtime to avoid dependency on MSVCRXXX.dll
# #    set (CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
# #    set (CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
# #    set (CMAKE_C_FLAGS_RELEASE   "${CMAKE_C_FLAGS_RELEASE} /MT")
# #    set (CMAKE_C_FLAGS_DEBUG     "${CMAKE_C_FLAGS_DEBUG} /MTd")
    # ADD_DEFINITIONS (-D_CRT_SECURE_NO_WARNINGS)
# endif()
# ADD_DEFINITIONS (-DMODELICA_ERRORS=0 -DNOMINMAX)
# # Workaround for missing ModelicaMessage and ModelicaError objects
# set  (INCLUDE_DIRS "")


#######################################
#         TARGET DEFINITIONS          #
#######################################
file (GLOB_RECURSE LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/Sources/*.cpp")

if(NOT ENABLE_FLUIDPROP)
  list(REMOVE_ITEM LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/Sources/FluidProp_IF.cpp")
  list(REMOVE_ITEM LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/Sources/FluidProp_COM.cpp")
  list(REMOVE_ITEM LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/Sources/fluidpropsolver.cpp")
endif()

if(NOT ENABLE_COOLPROP)
  list(REMOVE_ITEM LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/Sources/coolpropsolver.cpp")
endif()

add_library(${LIBRARY_NAME} ${LIB_SOURCES})
set_property(TARGET ${LIBRARY_NAME} PROPERTY VERSION ${APP_VERSION})
set_property(TARGET ${LIBRARY_NAME} PROPERTY CXX_STANDARD 11)
target_include_directories(${LIBRARY_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/Sources")
if(ENABLE_MSL_HEADERS)
  target_include_directories(${LIBRARY_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/ModelicaStandardLibrary")
  target_compile_definitions(${LIBRARY_NAME} PRIVATE -DMODELICA_ERRORS=1)
else()
  target_compile_definitions(${LIBRARY_NAME} PRIVATE -DMODELICA_ERRORS=0)
endif()

#if(MSVC)
# Add postfix for debugging, this breaks the Modelica code, use it carefully
set_property(TARGET ${LIBRARY_NAME} PROPERTY DEBUG_POSTFIX d)
set_property(TARGET ${LIBRARY_NAME} PROPERTY RELEASE_POSTFIX )
#endif()

if(NOT DEFINED MODELICA_PLATFORM)
  if(WIN32)
    if(CMAKE_SIZEOF_VOID_P MATCHES "8")
      set(MODELICA_PLATFORM "win64")
    else()
      set(MODELICA_PLATFORM "win32")
    endif()
  elseif(APPLE)
    if(CMAKE_SIZEOF_VOID_P MATCHES "8")
      set(MODELICA_PLATFORM "linux64")
    else()
      set(MODELICA_PLATFORM "linux32")
    endif()
  elseif(UNIX)
    if(CMAKE_SIZEOF_VOID_P MATCHES "8")
      set(MODELICA_PLATFORM "linux64")
    else()
      set(MODELICA_PLATFORM "linux32")
    endif()
  else()
    message(FATAL_ERROR "Could not determine the MODELICA_PLATFORM, aborting.")
  endif()
endif()

if(NOT DEFINED MODELICA_COMPILER)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    if    (MSVC_TOOLSET_VERSION EQUAL 80 )
      set(MODELICA_COMPILER vs2005)
    elseif(MSVC_TOOLSET_VERSION EQUAL 90 )
      set(MODELICA_COMPILER vs2008)
    elseif(MSVC_TOOLSET_VERSION EQUAL 100)
      set(MODELICA_COMPILER vs2010)
    elseif(MSVC_TOOLSET_VERSION EQUAL 110)
      set(MODELICA_COMPILER vs2012)
    elseif(MSVC_TOOLSET_VERSION EQUAL 120)
      set(MODELICA_COMPILER vs2013)
    elseif(MSVC_TOOLSET_VERSION EQUAL 140)
      set(MODELICA_COMPILER vs2015)
    elseif(MSVC_TOOLSET_VERSION EQUAL 141)
      set(MODELICA_COMPILER vs2017)
    elseif(MSVC_TOOLSET_VERSION EQUAL 142)
      set(MODELICA_COMPILER vs2019)
    else()
      message(WARNING "${MSVC_TOOLSET_VERSION} Is not explicitly supported. Please check you build carefully.")
    endif()
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    string(REPLACE "." ";" _VERSION_LIST ${CMAKE_CXX_COMPILER_VERSION})
    list(GET _VERSION_LIST 0 _VERSION_MAJOR)
    list(GET _VERSION_LIST 1 _VERSION_MINOR)
    set(MODELICA_COMPILER gcc${_VERSION_MAJOR}${_VERSION_MINOR})
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    string(REPLACE "." ";" _VERSION_LIST ${CMAKE_CXX_COMPILER_VERSION})
    list(GET _VERSION_LIST 0 _VERSION_MAJOR)
    list(GET _VERSION_LIST 1 _VERSION_MINOR)
    set(MODELICA_COMPILER clang${_VERSION_MAJOR}${_VERSION_MINOR})
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    string(REPLACE "." ";" _VERSION_LIST ${CMAKE_CXX_COMPILER_VERSION})
    list(GET _VERSION_LIST 0 _VERSION_MAJOR)
    list(GET _VERSION_LIST 1 _VERSION_MINOR)
    set(MODELICA_COMPILER appleclang${_VERSION_MAJOR}${_VERSION_MINOR})
  else()
    message(WARNING "${CMAKE_CXX_COMPILER_ID} Is not explicitly supported. Please check you build carefully.")
  endif()
endif()

if(MINGW)
  if(CMAKE_SIZEOF_VOID_P MATCHES "8")
    set(MODELICA_PLATFORM "mingw64")
  else()
    set(MODELICA_PLATFORM "mingw32")
  endif()
  set(MODELICA_COMPILER "")
  message(WARNING "Discarded compiler information since OpenModelica expect the mingw32/64 platform.")
endif()

set(MODELICA_INSTALL_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../Modelica/ExternalMedia ${APP_VERSION}/Resources")

INSTALL(TARGETS "${LIBRARY_NAME}"                                     DESTINATION "${MODELICA_INSTALL_PATH}/Library/${MODELICA_PLATFORM}/${MODELICA_COMPILER}")
INSTALL(FILES "${CMAKE_CURRENT_SOURCE_DIR}/Sources/${LIBRARY_HEADER}" DESTINATION "${MODELICA_INSTALL_PATH}/Include")

if(MODELICA_COMPILER)
  add_custom_target(install-as-default
      COMMAND ${CMAKE_COMMAND} -E echo "Copying \"Library/${MODELICA_PLATFORM}/${MODELICA_COMPILER}/\" to \"Library/${MODELICA_PLATFORM}/\""
      COMMAND ${CMAKE_COMMAND} -E copy_directory "Library/${MODELICA_PLATFORM}/${MODELICA_COMPILER}/" "Library/${MODELICA_PLATFORM}/"
      DEPENDS install
      WORKING_DIRECTORY "${MODELICA_INSTALL_PATH}"
      COMMENT "Install the current build as default library."
  )
else()
  add_custom_target(install-as-default
      COMMAND ${CMAKE_COMMAND} -E echo "Not copying \"Library/${MODELICA_PLATFORM}/${MODELICA_COMPILER}/\" to \"Library/${MODELICA_PLATFORM}/\""
      COMMENT "Install the current build as default library, not needed."
  )
endif()


#######################################
#     INCLUDE COOLPROP LIBRARY        #
#######################################

# This is really a mess, but we cannot do it differently since 
# Coolprop does not follow CMake standards and handles installation
# directories in a rather exotic way.

if(ENABLE_COOLPROP)
  include(cmake/fetch_coolprop.cmake)
  # Add CoolProp to ExternalMedia
  if(COOLPROP_LINKER_INPUT)
    target_sources(${LIBRARY_NAME} PUBLIC ${COOLPROP_LINKER_INPUT})
    target_link_libraries(${LIBRARY_NAME} PUBLIC ${CMAKE_DL_LIBS})
    target_include_directories(${LIBRARY_NAME} PUBLIC ${COOLPROP_INCLUDES})
  elseif(COOLPROP_LIBRARY_NAME)
    target_link_libraries(${LIBRARY_NAME} PUBLIC ${COOLPROP_LIBRARY_NAME} ${CMAKE_DL_LIBS})
    target_include_directories(${LIBRARY_NAME} PUBLIC ${COOLPROP_INCLUDES})
  endif()
  
  # This links the final ExternalMedia sources, avoids conflicts with the MSL headers
  add_executable (coolprop_comparisons ${CMAKE_CURRENT_SOURCE_DIR}/Tests/coolprop_comparisons.cpp ${LIB_SOURCES})
  target_compile_definitions(coolprop_comparisons PRIVATE -DMODELICA_ERRORS=0)
  target_include_directories(coolprop_comparisons PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Sources)
  if(COOLPROP_LINKER_INPUT)
    target_sources(coolprop_comparisons PUBLIC ${COOLPROP_LINKER_INPUT})
    target_link_libraries(coolprop_comparisons PUBLIC ${CMAKE_DL_LIBS})
    target_include_directories(coolprop_comparisons PUBLIC ${COOLPROP_INCLUDES})
  elseif(COOLPROP_LIBRARY_NAME)
    target_link_libraries(coolprop_comparisons PUBLIC ${COOLPROP_LIBRARY_NAME} ${CMAKE_DL_LIBS})
    target_include_directories(coolprop_comparisons PUBLIC ${COOLPROP_INCLUDES})
  endif()
endif()
