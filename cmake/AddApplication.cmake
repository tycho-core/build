cmake_minimum_required (VERSION 2.8)

function(tycho_add_application_aux name link_libs folder win32)
	message(STATUS "Adding application : ${name}")

	tycho_makesrcfolders(${CMAKE_CURRENT_SOURCE_DIR} "" 0 0)

	# get all files in this directory
	file(GLOB_RECURSE dir_files "*.*")
		
	# filter out all files we will include in project
	list_filter(dir_files file_types OUTPUT_VARIABLE all_files)
		
	add_executable(${name} ${win32} ${all_files})
	
	target_link_libraries(${name} ${link_libs})

	# add to solution folder
	set_target_properties(${name} PROPERTIES FOLDER "${folder}")
endfunction()

function(tycho_add_application name link_libs)
	tycho_add_application_aux(${name} "${link_libs}" "applications" "WIN32")
endfunction()

function(tycho_add_tool name link_libs)
	tycho_add_application_aux(${name} "${link_libs}" "tools" "")
endfunction()

