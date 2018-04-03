cmake_minimum_required (VERSION 2.8)

include("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt")

# add each library search directory to the preprocessor includes
#TODO: this could be a little more fine grained and each libary
#      add only ones that it needs
foreach(search_dir ${TYCHO_CMAKE_SEARCH_DIRS})
    include_directories("${search_dir}")
endforeach()

#TODO: build dir needs to be set based on the location of this file
#TODO: test/ is over agressive, need to limit to test folders under a folder that
#      already contains a cmake file
set(exclude_search_dirs
    tycho/lib/build
    tests/
)
find_cmake_files("${TYCHO_CMAKE_SEARCH_DIRS}" "${exclude_search_dirs}" all_cmake_files)

message(STATUS ${all_cmake_files})

foreach(cmake_file ${all_cmake_files})
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" cmake_file "${cmake_file}")
    string(REPLACE "CMakeLists.txt" "" cmake_file "${cmake_file}")
    message(STATUS ${cmake_file})
    add_subdirectory(${cmake_file})
endforeach()

