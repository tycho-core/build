cmake_minimum_required (VERSION 2.8)

macro(tycho_bin2header_command input_file output_file)
	add_custom_command (
		OUTPUT ${output_file}
		DEPENDS bin2header
		MAIN_DEPENDENCY ${input_file}
		COMMAND bin2header ${input_file} ${output_file}
		COMMENT "Generating header from binary file for ${input_file}"
	)
endmacro()
