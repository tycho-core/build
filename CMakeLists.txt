cmake_minimum_required (VERSION 3.1)

# check we are building out of tree in the build directory
message(STATUS "Binary directory is ${CMAKE_BINARY_DIR}")
if(NOT ${CMAKE_BINARY_DIR} MATCHES ".+/build(/.*)?$")
	message(FATAL_ERROR "cmake must be run from build directory not from ${CMAKE_BINARY_DIR}")
endif()

# initial setup for unit testing
enable_testing()

# enable solution folders, must come before project definition
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
project (tycho)

# set build related variables
set(ty_build_dx9 0)  # default dx9 to off
set(ty_compiler_clang 0)
set(ty_compiler_msvc  0)
set(ty_compiler_intel 0)
set(ty_buildenv_qt 0)
set(ty_platform_osx 0)
set(ty_platform_windows 0)

if(NOT ty_use_boost)
	set(ty_use_boost 0)
endif()
set(ty_platform_linux 0)
set(ty_platform_ignore_dirs)

# setup global defines
add_definitions(-DTYCHO)
add_definitions(-DTYCHO_ASSERT_ENABLED=1)

#------------------------------------------------------------------------------
# setup platform defines
#------------------------------------------------------------------------------
message(STATUS "System is ${CMAKE_SYSTEM_NAME}")
message(STATUS "Compiler is ${CMAKE_CXX_COMPILER_ID}")

# Linux
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set(ty_platform_linux 1)
	set(ty_platform "linux")
	set(ty_platform_dir "linux")
	set(ty_platform_ignore_dirs "pc" "gc" "osx")
    set(ty_compiler_clang 0)
	add_definitions(-DTYCHO_LINUX=1)
endif()

# Windows
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    # build dx9 graphics driver
    set(ty_build_dx9 1)
    set(ty_platform_windows 1)

    # Visual Studio
    if(MSVC)
        set(ty_compiler_msvc 1)
		set(ty_platform "pc")
		set(ty_platform_dir "win32")
		set(ty_platform_ignore_dirs "osx" "linux" "gc")
		add_definitions(-DTYCHO_PC=1)
		add_definitions(-D_CRT_SECURE_NO_WARNINGS)
		add_definitions(-D_VARIADIC_MAX=10)
		add_definitions(-DBOOST_CONFIG_SUPPRESS_OUTDATED_MESSAGE)
	
		if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
			# Clang 3.5.0 does not support windows exceptions
			add_definitions(-D_HAS_EXCEPTIONS=0)	 # disable standard library exceptions
			add_definitions(-DTYCHO_NO_EXCEPTIONS=1) # disable our exceptions
			add_definitions(-DBOOST_NO_EXCEPTIONS)    # boost exceptions
			set(ty_compiler_clang 1)
		elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
			set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Qstd=c++11")	
			set(ty_compiler_intel 1)
		else()
			set(ty_compiler_msvc 1)
		endif()	
    endif()
endif()

# OS X
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(ty_platform_osx 1)
	set(ty_platform "osx")
	set(ty_platform_dir "linux")
	set(ty_platform_ignore_dirs "pc" "gc")
    set(ty_compiler_clang 1)
	add_definitions(-DTYCHO_LINUX=1 -DTYCHO_OSX=1)

	# QT / Command line
        set(ty_buildenv_qt 1)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --std=c++11") 

	# Xcode
	set(CMAKE_XCODE_ATTRIBUTE_GCC_VERSION "com.apple.compilers.llvm.clang.1_0")
	set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++0x")
	set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall")
endif()

# check to see if the passed directory should be included in the
# current build
function(tycho_dir_ignored dir)
	set(dir_ignored 0 PARENT_SCOPE)
	foreach(d ${ty_platform_ignore_dirs})
		if(${dir} MATCHES "${d}")
			set(dir_ignored 1 PARENT_SCOPE)
		endif()
	endforeach()
endfunction()

# some libraries use python scripts for code generation
find_package(PythonInterp REQUIRED)
if(NOT PYTHONINTERP_FOUND OR NOT EXISTS "${PYTHON_EXECUTABLE}")
	message(FATAL_ERROR "Python is required to build tycho")
endif()

# configure boost
message(STATUS "UseBoost=${ty_use_boost}")
if(ty_use_boost)
	set(USE_BOOST_CACHE 1)
	set(TargetArchitecture "x86_64")
	include("${CMAKE_CURRENT_LIST_DIR}/cmake/AddBoost.cmake")
	include_directories("${BoostSourceDir}")
	link_directories("${BoostSourceDir}/stage/lib/")
endif()

# add tycho lib directory for all projects
message(STATUS "Current source dir = ${CMAKE_CURRENT_SOURCE_DIR}")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/lib")

# add top level directory for all projects
include_directories("${CMAKE_CURRENT_SOURCE_DIR}")

# QT doesn't seem to use the output directories correctly.
# force to build debug for now.
# TODO: figure out where QT sets build type
if(ty_buildenv_qt)
    message(STATUS "CMAKE_BUILD_TYPE : ${CMAKE_BUILD_TYPE}")

    if("${CMAKE_BUILD_TYPE}" MATCHES "")
        message(STATUS "CMAKE_BUILD_TYPE : Defaulting to Debug")
        set(CMAKE_BUILD_TYPE "Debug")
    endif()
endif()

# override where libraries, dll's and executable get built to
set(CMAKE_BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/bin)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${ty_platform_dir}/archive/release)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/${ty_platform_dir}/archive/release)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/${ty_platform_dir}/archive/debug)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${ty_platform_dir})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/${ty_platform_dir}/lib/release)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/${ty_platform_dir}/lib/debug)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${ty_platform_dir})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/${ty_platform_dir})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/${ty_platform_dir}/debug)


# Output shared libraries to binary directory when using QT
# TODO: may need this for other osx / linux buildenv's.
if(ty_buildenv_qt)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/${ty_platform_dir})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/${ty_platform_dir}/debug)
endif()


# file types used by the build system
set(lemon_file_types ".+\\.y$")
set(flex_file_types ".+\\.l$")
set(shader_file_types ".+\\.hlsl$")
set(compile_file_types ".+\\.c$" ".+\\.cpp$" ".+\\.cc$" ${lemon_file_types} ${flex_file_types} ${shader_file_types})
set(solution_src_files ".+\\.h$" ".+\\.l$" ".+\\.inl$" ".+\\.m$" ".+\\.defs$" ".+\\.types$" ".+\\.py$" ".+\\.ssXML$")
set(solution_asset_files ".+\\.png$" ".+\\.ttf$" ".+\\.ui$")
set(solution_file_types ${solution_src_files} ${solution_asset_files})
set(file_types ${compile_file_types} ${solution_file_types})

# custom commmands
message(STATUS "Build system root : ${CMAKE_CURRENT_LIST_DIR}")

include("${CMAKE_CURRENT_LIST_DIR}/cmake/LemonCommand.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/FlexCommand.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/Bin2HeaderCommand.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/StringifyCommand.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/LineifyCommand.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/ListFilter.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/AddLibrary.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/AddApplication.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/AddBuildTool.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/AddTest.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/MakeSrcFolders.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/CompilerHelpers.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/cmake/FindCMakeFiles.cmake")
