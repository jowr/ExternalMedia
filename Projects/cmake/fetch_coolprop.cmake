include(FetchContent)

# Define the configuration variables
if(NOT MSVC)
 if(CMAKE_SIZEOF_VOID_P MATCHES "8")
   set(FORCE_BITNESS_64 ON)
 else()
   set(FORCE_BITNESS_32 ON)
 endif()
endif()

set(COOLPROP_OBJECT_LIBRARY ${ADD_COOLPROP_OBJECT})
set(COOLPROP_STATIC_LIBRARY ${ADD_COOLPROP_STATIC})
set(COOLPROP_SHARED_LIBRARY ${ADD_COOLPROP_SHARED})

# Define the source for the CoolProp files
FetchContent_Declare(
  coolprop
  GIT_REPOSITORY https://github.com/coolprop/coolprop.git
  GIT_TAG        v6.4.1
)

# After the following call, the CMake targets defined by CoolProp
# will be defined and available to the rest of the build
#FetchContent_MakeAvailable(coolprop)

FetchContent_GetProperties(coolprop)
if(NOT coolprop_POPULATED)
  FetchContent_Populate(coolprop)
  #if(ADD_COOLPROP_OBJECT)
  #  message(STATUS "Preparing CoolProp object files in \"${coolprop_BINARY_DIR}\"")
  #  execute_process(
  #    COMMAND ${CMAKE_COMMAND} -B ${coolprop_BINARY_DIR} -S ${coolprop_SOURCE_DIR}
  #    RESULT_VARIABLE rv
  #  )
  #  message("rv='${rv}'")
  #endif()
  add_subdirectory(${coolprop_SOURCE_DIR} ${coolprop_BINARY_DIR})
  #message(STATUS WARNING FATAL_ERROR "")
endif()

if(NOT DEFINED CACHE{CMAKE_RUN_SWITCH})
  message(STATUS "This seems to be the first time you run CMake to access \"${coolprop_BINARY_DIR}\"")
  message(STATUS "-----> Please rerun CMake manually <-----")
  set(CMAKE_RUN_SWITCH ON CACHE BOOL "Did CMake run earlier?")
endif()

if(ADD_COOLPROP_OBJECT)
  get_target_property(COOLPROP_INCLUDES CoolProp INCLUDE_DIRECTORIES)
  #get_target_property(COOLPROP_LINKER_INPUT CoolProp SOURCES)
  set(COOLPROP_LINKER_INPUT $<TARGET_OBJECTS:CoolProp>)
  set(COOLPROP_LIBRARY_NAME "CoolProp")
elseif(ADD_COOLPROP_STATIC)
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}")
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}/include")
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}/externals/msgpack-c/include")
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}/externals/fmtlib")
  set(COOLPROP_LINKER_INPUT "")
  set(COOLPROP_LIBRARY_NAME "CoolProp")
elseif(ADD_COOLPROP_SHARED)
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}/include")
  set(COOLPROP_LINKER_INPUT "")
  set(COOLPROP_LIBRARY_NAME "CoolProp")
endif()

message(STATUS "COOLPROP_LINKER_INPUT: \"${COOLPROP_LINKER_INPUT}\"")
message(STATUS "COOLPROP_LIBRARY_NAME: \"${COOLPROP_LIBRARY_NAME}\"")
