cmake_minimum_required (VERSION 2.8)

macro(tycho_subdirlist result curdir)
  file(GLOB children RELATIVE ${curdir} "${curdir}/*")
  set(dirlist "")
  foreach(child ${children})
    if(IS_DIRECTORY ${curdir}/${child})
        set(dirlist ${dirlist} ${child})
    endif()
  endforeach()
  set(${result} ${dirlist})
endmacro()

function(tycho_makesrcfolders curdir name ignore testing)
	#message(STATUS "  Making source folders for ${name}")
	
	# get subdirectories in this folder
	tycho_subdirlist(SUBDIRS ${curdir})

	# check if this directory is platform directory that
	# should not be compiled on the current platform
	set(dir_ignored 0)
	if(NOT ${ignore} AND NOT "${name}" STREQUAL "")
		tycho_dir_ignored(${name})
	endif()
	
	set(dir_hide 0)
	if(NOT ${testing} AND "${name}" STREQUAL "tests")
		set(dir_hide 1)
	endif()
	
	#message(STATUS "CurDir : ${curdir} : ${dir_ignored}")
	#message(STATUS "Name   : " ${name})

	if(NOT ${dir_hide})
		# get all files in this directory
		file(GLOB dir_files "${curdir}/*.*")
		list_filter(dir_files file_types OUTPUT_VARIABLE all_files2)

		# add files to correct source group so they show in correct 
		# folders in visual studio
		if(NOT "${name}" STREQUAL "")
			string(REGEX REPLACE "/" "\\\\" group ${name})
			#message(STATUS "Group : " ${group})
			source_group("${group}" FILES ${all_files2})
		else()
			#message(STATUS "Group : \\\\" )
			source_group("\\\\" FILES ${all_files2})	
		endif()
		
		# if this directory should be excluded from the build
		# then set all files not to compile
		if(${dir_ignored})
			set_source_files_properties(${all_files2} PROPERTIES HEADER_FILE_ONLY TRUE)
		else()
			# exclude files from build that only included so they show in the solution
			set(files "")
			set(solution_files "")
			list_filter(all_files2 solution_file_types OUTPUT_VARIABLE solution_files)
			set_source_files_properties(${solution_files} PROPERTIES HEADER_FILE_ONLY TRUE)
		endif()
	
		# recurse into folders and add source folder
		foreach(subdir ${SUBDIRS})
			set(nextdir ${curdir}/${subdir})
			if("${name}" STREQUAL "")
				set(nextname ${subdir})
			else()
				set(nextname ${name}/${subdir})
			endif()
			tycho_makesrcfolders(${nextdir} ${nextname} dir_ignored ${testing})
		endforeach()
	endif() # dir_hide
endfunction()
