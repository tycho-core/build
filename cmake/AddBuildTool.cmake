cmake_minimum_required (VERSION 3.1)

function(tycho_add_build_tool name link_libs)
	message(STATUS "Adding build tool : ${name}")

	tycho_makesrcfolders(${CMAKE_CURRENT_SOURCE_DIR} "" 0 0)

	# get all files in this directory
	file(GLOB_RECURSE dir_files "*.*")
		
	# filter out all files we will include in project
	list_filter(dir_files file_types OUTPUT_VARIABLE all_files)
	
	add_executable(${name} ${all_files})

	# setup library dependencies
	foreach(lib ${link_libs})
		#message(STATUS "Linking : ${lib}")
		target_link_libraries(${name} ${lib})
	endforeach()
	
	# add to solution folder
	set_target_properties(${name} PROPERTIES FOLDER "build_tools")
endfunction()
