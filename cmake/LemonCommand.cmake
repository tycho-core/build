cmake_minimum_required (VERSION 3.1)

macro(tycho_lemon_command lemon_file)
	set(lemon_output_header)
	set(lemon_output_inline)
	string(REGEX REPLACE "[.]y" ".h" lemon_output_header ${lemon_file})
	string(REGEX REPLACE "[.]y" ".inl" lemon_output_inline ${lemon_file})		
	add_custom_command (
		OUTPUT ${lemon_output_header} ${lemon_output_inline}
		DEPENDS lemon
		MAIN_DEPENDENCY ${lemon_file}
		COMMAND lemon -q ${lemon_file} 
						 ${lemon_output_header}
						 ${CMAKE_SOURCE_DIR}/tools/bin/lempar.c
		COMMENT "Generating parser for ${lemon_file}"
	)
endmacro()