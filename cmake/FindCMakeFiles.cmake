# Function that finds all CMake files under the given directories
# that do not contain text from exclude_search_dirs
function(find_cmake_files search_dirs exclude_search_dirs output)
    set(all_cmake_files)
    foreach(dir ${search_dirs})
        set(search_dir "${CMAKE_CURRENT_SOURCE_DIR}/${dir}")
        message(STATUS "Searching ${search_dir}")
        file(GLOB_RECURSE cmake_files "${search_dir}/CMakeLists.txt")
        foreach(cmake_file ${cmake_files})
            set(exclude_dir_check 0)
            foreach(exclude_dir ${exclude_search_dirs})
                if(${cmake_file} MATCHES "${exclude_dir}")
                    set(exclude_dir_check 1)
                endif()
            endforeach()
            if(${exclude_dir_check} EQUAL 0)
                list(APPEND all_cmake_files ${cmake_file})
            endif()
        endforeach()
    endforeach()
    set(${output} "${all_cmake_files}" PARENT_SCOPE)
endfunction()