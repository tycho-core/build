cmake_minimum_required (VERSION 2.8)

# Clang : disble the passed list of warnings in the CXX and C flags.
macro(ty_clang_warning_disable warnings)
    if(ty_compiler_clang)
        set(flags "")
        foreach(warning ${warnings})
            set(flags "-Wno-${warning} ${flags}")
        endforeach()

        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${flags}")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${flags}")
    endif()
endmacro()

# Clang : replace if present -Wall from the CXX and C flags.
macro(ty_clang_no_wall)
    if(ty_compiler_clang)
        string(REPLACE "-Wall" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
        string(REPLACE "-Wall" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
    endif()
endmacro()

# Clang : disable the passed list of warnings for a specifc file.
macro(ty_clang_file_disable_warnings file warnings)
    if(ty_compiler_clang)
        set(flags "")
        foreach(warning ${warnings})
            set(flags "-Wno-${warning} ${flags}")
        endforeach()

        set_source_files_properties(${file} PROPERTIES COMPILE_FLAGS "${flags}")
    endif()
endmacro()

# MSVC : disble the passed list of warnings in the CXX and C flags.
macro(ty_msvc_warning_disable warnings)
    if(ty_compiler_msvc)
        set(flags "")
        foreach(warning ${warnings})
            set(flags "/wd${warning} ${flags}")
        endforeach()

        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${flags}")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${flags}")
    endif()
endmacro()

# MSVC : disable the passed list of warnings for a specifc file.
macro(ty_msvc_file_disable_warnings file warnings)
    if(ty_compiler_msvc)
        set(flags "")
        foreach(warning ${warnings})
            set(flags "/wd${warning} ${flags}")
        endforeach()

        set_source_files_properties(${file} PROPERTIES COMPILE_FLAGS "${flags}")
    endif()
endmacro()