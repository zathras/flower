deferred class TCL_COMMAND 

	-- A TCL_COMMAND is a command, implemented in Eiffel, that has been
	-- bound into a TCL_INTERPRETER.  For a command named <name>, a Tcl
	-- script invokes the command with "eiffel <name> <args>".



feature		-- Attributes

	name : STRING is		-- The name of the command
		deferred
		ensure
			starts_with_letter: (Result @ 1).is_alpha;
		end;


feature { TCL_INTERPRETER }		-- Command invocation

	evaluate (args : ARRAY[STRING]) : STRING is
		deferred
	ensure
		result_not_void: Result /= Void
	end;
		-- evaluate may throw a developer exception if
		-- something goes wrong...  This will be translated
		-- into a Tcl error.

end -- class TCL_COMMAND
