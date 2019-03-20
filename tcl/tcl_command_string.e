
class TCL_COMMAND_STRING
	-- Is used to build up a command string to send to a TCL_INTERPRETER.
    -- This adds to STRING some methods that are generally useful for
    -- Tcl commands.

inherit

	STRING
		rename
			make as string_make
		end;

creation

	make

feature	-- Initialize / Release

	make (initial : STRING) is
		do
			string_make(initial.count);
			append(initial);
		end;

feature -- Element Change

	int_arg (arg : INTEGER) is	-- Append an integer argument to the string
		do
			append(" ");
			append_integer(arg);
		end;

	string_arg (arg : STRING) is	-- Append a string argument to the string
		do
			append(" {");
			append(arg);
			append("}");
		end;

	boolean_arg (arg : BOOLEAN) is	-- Append a boolean argument to the string
		do
			if arg then
				append(" 1 ");
			else
				append(" 0 ");
			end
		end;

	start_array is		-- Start an array argument
		-- Use:  start_array; string_arg("xx"); string_arg("yy"); finish_array
		do
			append(" {"); 
		end;

	finish_array is		-- Start an array argument
		-- Use:  start_array; string_arg("xx"); string_arg("yy"); finish_array
		do
			append("}"); 
		end;

end 	-- TCL_COMMAND_STRING
