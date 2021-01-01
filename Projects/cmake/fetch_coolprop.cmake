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

# FetchContent_GetProperties(coolprop)
# if(NOT coolprop_POPULATED)
  # FetchContent_Populate(coolprop)
  # add_subdirectory(${coolprop_SOURCE_DIR} ${coolprop_BINARY_DIR})
# endif()

# FetchContent_GetProperties(coolprop)
if(NOT coolprop_POPULATED)
  FetchContent_Populate(coolprop)
  if(ADD_COOLPROP_OBJECT)
    message(STATUS "Preparing CoolProp object files in \"${coolprop_BINARY_DIR}\"")
    execute_process(
      COMMAND ${CMAKE_COMMAND} --build ${coolprop_BINARY_DIR} --target CoolProp --config Release
      RESULT_VARIABLE rv
    )
    message("rv='${rv}'")
    execute_process(
      COMMAND ${CMAKE_COMMAND} --build ${coolprop_BINARY_DIR} --target CoolProp --config Debug
      RESULT_VARIABLE rv
    )
    message("rv='${rv}'")
  endif()
  add_subdirectory(${coolprop_SOURCE_DIR} ${coolprop_BINARY_DIR})
endif()

if(ADD_COOLPROP_OBJECT)  
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



