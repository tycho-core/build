cmake_minimum_required (VERSION 2.8)

macro(tycho_flex_command flex_file)
	set(flex_output_inline)
	string(REGEX REPLACE "[.]l" ".inl" flex_output_inline ${flex_file})		
	add_custom_command (
		OUTPUT ${flex_output_inline}
		DEPENDS flex
		MAIN_DEPENDENCY ${flex_file}
		COMMAND flex --nounistd -o ${flex_output_inline} ${flex_file}
		COMMENT "Generating lexer for ${flex_file}"
	)
endmacro()