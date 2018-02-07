cmake_minimum_required (VERSION 2.8)

include("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt")

#TODO: These need to be set per workspace based on the configured
#      directory mappings
set(search_dirs
    tycho/lib
    tycho/third_party
)

#TODO: build dir needs to be set based on the location of this file
#TODO: test/ is over agressive, need to limit to test folders under a folder that
#      already contains a cmake file
set(exclude_search_dirs
    tycho/lib/build
    test/
)
find_cmake_files("${search_dirs}" "${exclude_search_dirs}" all_cmake_files)
foreach(cmake_file ${all_cmake_files})
    message(STATUS ${cmake_file})
    include(${cmake_file})
endforeach()

