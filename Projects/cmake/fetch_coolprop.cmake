include(FetchContent)



# Define the configuration variables
if(CMAKE_SIZEOF_VOID_P MATCHES "8")
  set(COOLPROP_BITNESS "64")
else()
  set(COOLPROP_BITNESS "32")
endif()

if(NOT MSVC)
  set(COOLPROP_FORCE_BITNESS "-DFORCE_BITNESS_${COOLPROP_BITNESS}=ON")
else()
  set(COOLPROP_FORCE_BITNESS "-DFORCE_BITNESS_${COOLPROP_BITNESS}=OFF")
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
  execute_process(
    COMMAND "\"${CMAKE_COMMAND}\" echo \"Building Coolprop\""
    COMMAND "\"${CMAKE_COMMAND}\" --build \"${coolprop_BINARY_DIR}\" --target CoolProp"
  )
  #COMMAND <cmd1> [<arguments>]
  #             [COMMAND <cmd2> [<arguments>]]...
  #             [WORKING_DIRECTORY <directory>]
  #             [TIMEOUT <seconds>]
  #             [RESULT_VARIABLE <variable>]
  #             [RESULTS_VARIABLE <variable>]
  #             [OUTPUT_VARIABLE <variable>]
  #             [ERROR_VARIABLE <variable>]
  #             [INPUT_FILE <file>]
  #             [OUTPUT_FILE <file>]
  #             [ERROR_FILE <file>]
  #             [OUTPUT_QUIET]
  #             [ERROR_QUIET]
  #             [COMMAND_ECHO <where>]
  #             [OUTPUT_STRIP_TRAILING_WHITESPACE]
  #             [ERROR_STRIP_TRAILING_WHITESPACE]
  #             [ENCODING <name>]
  #             [ECHO_OUTPUT_VARIABLE]
  #             [ECHO_ERROR_VARIABLE]
  #             [COMMAND_ERROR_IS_FATAL <ANY|LAST>])
  add_subdirectory(${coolprop_SOURCE_DIR} ${coolprop_BINARY_DIR})
endif()

if(ADD_COOLPROP_OBJECT)
  add_library(CoolPropLib OBJECT IMPORTED GLOBAL)
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}")
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}/include")
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}/externals/msgpack-c/include")
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}/externals/fmtlib")
  set(COOLPROP_LINKER_INPUT $<TARGET_OBJECTS:CoolProp>)
  set(COOLPROP_LIBRARY_FILE "")
elseif(ADD_COOLPROP_STATIC)
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}")
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}/include")
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}/externals/msgpack-c/include")
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}/externals/fmtlib")
  set(COOLPROP_LINKER_INPUT "")
  set(COOLPROP_LIBRARY_FILE "CoolProp")
elseif(ADD_COOLPROP_SHARED)
  list(APPEND COOLPROP_INCLUDES "${coolprop_SOURCE_DIR}/include")
  set(COOLPROP_LINKER_INPUT "")
  set(COOLPROP_LIBRARY_FILE "CoolProp")
endif()



