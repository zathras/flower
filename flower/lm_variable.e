class LM_VARIABLE
	-- Represents a variable (in an LM_CLASS)

inherit

	LM_CLASS_MEMBER
		redefine
			write_for_writer
		end;

creation

	make,
	make_for_reader



feature { LM_CLASS }		-- Streaming Support

	write_for_writer (writer : PROJECT_WRITER) is
		do
			writer.left_paren;
			writer.write_token("lm-variable");
			writer.write_string(name);
			writer.write_string(type);
			writer.right_paren;
			writer.new_line;
		end;

end -- class LM_VARIABLE
