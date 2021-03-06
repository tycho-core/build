cmake_minimum_required (VERSION 3.1)

function(tycho_add_library name link_libs solution_folder)
	message(STATUS "Adding library : ${name}  [${CMAKE_CURRENT_SOURCE_DIR}]")
	set(lib_name ty${name})

	# get all files in this directory
	file(GLOB_RECURSE dir_files "*.*")

	# filter out files not for this platform	
	set(filtered_files)
	message(STATUS "filtering '${ty_platform_ignore_dirs}'")
	foreach(d ${ty_platform_ignore_dirs})
		foreach(dir_file ${dir_files})
			if(NOT ${dir_file} MATCHES "${CMAKE_CURRENT_SOURCE_DIR}/${d}/.*")
				LIST(APPEND filtered_files ${dir_file})
				message(STATUS "Including: ${dir_file}")
			else()
				message(STATUS "Excluding: ${dir_file} in ${CMAKE_CURRENT_SOURCE_DIR}/${d}")
			endif()
		endforeach()
	endforeach()

	# filter out all files we will include in project
	list_filter(filtered_files file_types OUTPUT_VARIABLE tmp_files)
	
	# filter out all test files	
	set(all_files)
	foreach(tmp ${tmp_files})
		if(NOT tmp MATCHES ".*/tests/.*")
			list(APPEND all_files ${tmp})
		endif()
	endforeach()
	
	# add custom build rules for lemon grammar files
	list_filter(all_files lemon_file_types OUTPUT_VARIABLE lemon_filenames)
	foreach(lemon_file ${lemon_filenames})
		tycho_lemon_command(${lemon_file})
	endforeach()
	
	# add custom build rules for flex grammar files
	list_filter(all_files flex_file_types OUTPUT_VARIABLE flex_filenames)
	foreach(flex_file ${flex_filenames})
		tycho_flex_command(${flex_file})
	endforeach()
	
	# setup dll export when building the library
	if(ty_static_lib)
		string(TOUPPER TYCHO_${name}_STATIC_LIB static_lib)
		add_definitions("-D${static_lib}")
		add_library(${lib_name} ${all_files})
	else()
		if(MSVC)
			string(TOUPPER TYCHO_${name}_EXPORTS dll_export)
			add_definitions("-D${dll_export}")
		endif()
		add_library(${lib_name} SHARED ${all_files})
	endif()
	
	# setup library dependencies
	foreach(lib ${link_libs})
		#message(STATUS "Linking : ${lib}")
		target_link_libraries(${lib_name} ${lib})
	endforeach()

	# make solution source folders
	tycho_makesrcfolders(${CMAKE_CURRENT_SOURCE_DIR} "" 0 0)

	# add to solution folder
	set_target_properties(${lib_name} PROPERTIES FOLDER ${solution_folder})
	
	# add tests
	if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tests/CMakeLists.txt")
		add_subdirectory(tests)
	endif()
endfunction()
