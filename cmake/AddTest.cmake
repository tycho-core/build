cmake_minimum_required (VERSION 2.8)

function(tycho_add_test name link_libs folder)
	set(test_dir "${CMAKE_CURRENT_SOURCE_DIR}")
	set(test_name "${name}_tests")
	
	if(EXISTS "${test_dir}" AND IS_DIRECTORY "${test_dir}")
		message(STATUS "Adding tests : ${name}")

		tycho_makesrcfolders(${test_dir} "" 0 1)

		# get all files in this directory
		file(GLOB_RECURSE dir_files "*.*")
			
		# filter out all files we will include in project
		list_filter(dir_files file_types OUTPUT_VARIABLE all_files)
			
		# remove the export definition in MSCV for the parent library as 
		# cmake inherits preprocessor definitions from the parent directory scope
		if(MSVC)
			string(TOUPPER TYCHO_${name}_EXPORTS dll_export)
			remove_definitions("-D${dll_export}")
		endif()

                add_executable(${test_name} ${all_files})
		add_test(NAME ${test_name} COMMAND $<TARGET_FILE:${test_name}> WORKING_DIRECTORY "${test_dir}")
                add_dependencies(${test_name} boost_test)

		# setup library dependencies
		if(ty_platform_windows)
			set(boost_test   "libboost_unit_test_framework-vc110-mt-1_55")
			set(boost_test_d "libboost_unit_test_framework-vc110-mt-gd-1_55")

                        target_link_libraries(${test_name} ${link_libs} "tytest" debug ${boost_test_d} optimized ${boost_test})
                else()
                        target_link_libraries(${test_name} ${link_libs} "tytest" "boost_unit_test_framework-mt")
		endif()
		
		
		# add to solution folder
		set_target_properties(${test_name} PROPERTIES FOLDER "tests") 
	endif()
endfunction()
