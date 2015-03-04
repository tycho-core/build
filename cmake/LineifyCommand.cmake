cmake_minimum_required (VERSION 2.8)

macro(tycho_lineify_command input_file output_file)
	add_custom_command (
		OUTPUT ${output_file}
		DEPENDS lineify
		MAIN_DEPENDENCY ${input_file}
		COMMAND lineify ${input_file} ${output_file}
		COMMENT "Generating lineified file for ${input_file}"
	)
endmacro()
