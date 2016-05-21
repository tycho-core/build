cmake_minimum_required (VERSION 3.1)

macro(tycho_stringify_command input_file output_file)
	add_custom_command (
		OUTPUT ${output_file}
		DEPENDS stringify
		MAIN_DEPENDENCY ${input_file}
		COMMAND stringify ${input_file} ${output_file}
		COMMENT "Generating stringified file for ${input_file}"
	)
endmacro()
