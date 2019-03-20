class TCL_INTERPRETER 

inherit
	MEMORY		-- So we can execute a cleanup procedure
		redefine
			dispose
		end;

	EXCEPTIONS


creation

	make

feature			-- Initialize/Release

	make is
		require
			not_done_yet: not initialized
		do
			!!commands.make(10);
			handle := c_tcl_createinterp;
			c_create_eiffel_command(Current, handle);
				-- We create the single command "eiffel", which will result
				-- in our "command_callback" feature being executed.
		ensure
			successful: initialized
		end;


	release is		-- This *must* be called by the client when done.
					-- It does internal cleanup.
		require
			initialized: initialized
		do
			c_release_eiffel_interpreter(Current);
			c_tcl_deleteinterp(handle);
			handle := c_null_pointer;
		ensure
			successful: not initialized
		end;

feature			-- Status report

	initialized : BOOLEAN is		
			-- Has this intepreter been successfully initialized?
		do
			Result := handle /= c_null_pointer;

		end;

	has_command_named (name : STRING) : BOOLEAN is
			-- Has this interpreter a command named name?
		do
			Result := commands.has(name);
		end;

feature			-- Command Evaluation


	eval (command : STRING) : STRING is
			-- If command is unsuccessful, raises a developer exception.
		local
			external_command: ANY;
		do
			external_command := command.to_c;
			!!Result.make(30);
			if c_eval(handle, $external_command, Result) /= c_null_pointer then
				Result.prepend_string("tcl error:  ");
				raise(Result);
			end;
		end;

	eval_file (file_name : STRING) : STRING is
			-- If command is unsuccessful, raises a developer exception.
		local
			external_file_name : ANY;
		do
			external_file_name := file_name.to_c;
			!!Result.make(30);
			if c_evalfile(handle, $external_file_name, Result) /= c_null_pointer 
			then
				Result.prepend_string("tcl error:  ");
				raise(Result);
			end;
		end;

feature			-- Command binding

	add_command (command : TCL_COMMAND) is
		require
			is_unique: not has_command_named (command.name);
			starts_with_letter: (command.name @ 1).is_alpha;
		do
			commands.put(command, command.name);
		ensure
			was_inserted: has_command_named (command.name);
		end;


feature		-- Convenience functions

	set_global_array(arr, member, value : STRING) is
			-- Set the global Tcl value $arr($member) to value
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make("set_global_array");
			command.string_arg(arr);
			command.string_arg(member);
			command.string_arg(value);
			res := eval(command);
		end;

	get_global_array(arr, member : STRING) : STRING is
			-- Get the global Tcl value $arr($member)
		local
			command : TCL_COMMAND_STRING;
		do
			!!command.make("get_global_array");
			command.string_arg(arr);
			command.string_arg(member);
			Result := eval(command);
		end;

	-- Some of these depend on functions defined in utilities.tcl.
feature { TK_APPLICATION }	-- Exports that TK_APPLICATION needs


	handle : POINTER;	-- Tcl_Interp* from C


feature {NONE} 	--	Private


	commands : HASH_TABLE [ TCL_COMMAND, STRING ];

	dispose is			-- Invoked at GC time
		do
			check
				handle = Void;		-- Client must release interpreter.
			end;
		end;

	command_callback (interp : POINTER;
					  argc : INTEGER; argv : POINTER) : BOOLEAN is
			-- Sets cmd_result.  Returns True if OK, False otherwise.
		local
			i : integer;
			child_args : ARRAY[STRING];
			command : TCL_COMMAND;
			command_failed : BOOLEAN;
			a_string : STRING;
			cmd_result : STRING;
			external_cmd_result : ANY;
		do
			if command_failed then
				Result := False;
			else
				if argc <= 0 then
					Result := False;
					cmd_result := "wrong # args:  should be 'eiffel command [args]'.";
				else
					!!a_string.make(0);
					a_string.from_c(c_access_string_array(argv, 0));
					command := commands.item(a_string);
					if command = Void then
						!!cmd_result.make(0);
						cmd_result.copy("invalid eiffel command '");
						cmd_result.append(a_string);
						cmd_result.append("'");
						Result := False;
					else
						!!child_args.make(0, argc - 2);
						from
							i := 1
						until
							i >= argc
						loop
							!!a_string.make(0);
							a_string.from_c(c_access_string_array(argv, i));
							child_args.enter(a_string, i-1);
							i := i + 1;
						end
						!!cmd_result.make(0);
						cmd_result.copy(command.evaluate(child_args));
						Result := True;
					end;
				end;
				external_cmd_result := cmd_result.to_c;
				c_tcl_set_result(interp, $external_cmd_result);
			end;
		rescue
			if not command_failed and is_developer_exception then
				command_failed := True;
				cmd_result := clone(developer_exception_name);
				retry
			end
		end;


feature {NONE} 	--	C implementation

	c_tcl_createinterp : POINTER is
		external
			"C"
		end;

	c_tcl_deleteinterp(interp : POINTER) is
		external
			"C"
		end;

	c_create_eiffel_command(myself : TCL_INTERPRETER; interp : POINTER) is
		external
			"C"
		end;

	c_release_eiffel_interpreter(myself : TCL_INTERPRETER) is
		external
			"C"
		end;

	c_eval (interp : POINTER; command : POINTER; res : STRING) : POINTER is
			-- Returns NULL if no error, pointer to the string "error" if 
			-- there is (because Eiffel has a bug if we try to return 
			-- BOOLEAN)
		external
			"C"
		end;

	c_evalfile(interp : POINTER; file_name : POINTER; res : STRING) : POINTER is
			-- Like c_eval
		external
			"C"
		end;


	c_access_string_array(argv : POINTER; i : INTEGER) : POINTER is
		external
			"C"
		end;

	c_tcl_set_result(interp : POINTER; res : POINTER) is
		external
			"C"
		end;

	c_null_pointer : POINTER is
		external
			"C"
		end;



end -- class TCL_INTERPRETER
