class TK_APPLICATION 

	-- A TK_APPLICATION consists of a TCL_INTERPRETER that has been
	-- initialized with the Tk toolkit.  One command is automatically
	-- bound into the interpreter:  "eiffel exit" will cause the even
	-- loop to return.


creation

	make

feature		-- Initialize/Release

	make is
		local
			exit_command : TK_EXIT_COMMAND;
		do
			!!tcl.make;
			!!exit_command.make(Current);
			main_window := c_tk_init(tcl.handle);
			tcl.add_command(exit_command);
			running := True;
		end;

	release is		-- cf. TCL_INTERPRETER.release
		require
			not_running : not running
		local
			res : STRING;
		do
			res := tcl.eval("exit");
			-- I think that I should do a "tcl.release" instead of
			-- having tcl exit, but in Welch's book ("Practical Programming
			-- in Tcl and Tk, page 357) he recommends this.  This *does*
			-- mean that Eiffel won't do its cleanup, which is a shame.
			-- If I do call "tcl.release" here, I get a seg fault in the
			-- tcl library, so I guess this is a loose end of theirs.
			--
			-- This gives me a choice between two evils:
			-- tcl.eval("exit"), and have Eiffel not clean up, or I can
			-- not do anything, and have Tk not clean up.  Either way,
			-- a Windows client loses.  Under Unix it ought to be OK,
			-- though.
			tcl := Void;
		end;



feature		-- Command Evaluation

	eval (command : STRING) : STRING is
		require
			running : running
		do
			Result := tcl.eval(command);
		end;

	eval_file (file_name : STRING) : STRING is
		require
			running : running
		do
			Result := tcl.eval_file(file_name);
		end;

	bell is
		local
			res : STRING;
		do
				-- This is a Tk command, *not* a Tcl command.
			res := eval("bell");
			check result_ok : res.is_equal(""); end;
		end;


feature		-- Commmand binding

	add_command (command : TCL_COMMAND) is
		do
			tcl.add_command(command);
		end;


feature		-- Application Execution

	run is
		do
			from
			until
				not running
			loop
				c_do_one_tk_event;
			end
		end;


feature		-- Convenience functions
	-- Some of these depend on functions defined in utilities.tcl.

	width_of(s : STRING) : INTEGER is		
				-- Reports the width of s with the default font
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make("");
			if not width_of_called then
				width_of_called := true;
				command.append("label .dummy_for_width_of -borderwidth 0");
				res := eval(command);
				check
					result_ok : res.is_equal(".dummy_for_width_of");
				end;
			end;
			command.wipe_out;
			command.append(".dummy_for_width_of configure -text {");
			command.append(s);
			command.append("}");
			res := eval(command);
			check
				result_ok : res.is_equal("");
			end;
			command.wipe_out;
			command.append("winfo reqwidth .dummy_for_width_of");
			Result := eval(command).to_integer;
		end;


	character_height : INTEGER is		
				-- Reports the height of a character in the default font
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		once
			!!command.make("");
			command.append("label .dummy_for_character_height -borderwidth 0");
			res := eval(command);
			check
				result_ok : res.is_equal(".dummy_for_character_height");
			end;
			command.wipe_out;
			command.append(".dummy_for_width_of configure -text {jWMXgyO}");
			res := eval(command);
			check
				result_ok : res.is_equal("");
			end;
			command.wipe_out;
			command.append("winfo reqheight .dummy_for_width_of");
			Result := eval(command).to_integer - 2;
				-- Tk adds padding...  I wish I knew a better way to get
				-- font metrics out of Tk :-(
		end;

	show_message (msg : STRING) is
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make("ShowMessage");
			command.string_arg(msg);
			res := eval(command);
		end;

	get_value (prompt : STRING) : STRING is
		local
			command : TCL_COMMAND_STRING;
		do
			!!command.make("GetValue");
			command.string_arg(prompt);
			Result := eval(command);
		end;

	set_global_array(arr, member, value : STRING) is
			-- Set the global Tcl value $arr($member) to value
		do
			tcl.set_global_array(arr, member, value);
		end;

	get_global_array(arr, member : STRING) : STRING is
			-- Get the global Tcl value $arr($member)
		do
			Result := tcl.get_global_array(arr, member);
		end;

	populate_listbox(listbox_name, list : STRING; selected_no : INTEGER) is
		-- Populate the named listbox with the strings in list (a
		-- Tcl-format list).  See to it that selected_no is selected (if
		-- it's >= 0)
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make(listbox_name);
			command.append(" delete 0 [");
			command.append(listbox_name);
			command.append(" size]");
			res := eval(command);

			!!command.make("eval {");
			command.append(listbox_name);
			command.append(" insert end} ");
			command.append(list);
			res := eval(command);

			if selected_no > 0 then
				!!command.make(listbox_name);
				command.append(" selection set ");
				command.append(selected_no.out);
				res := eval(command);
			end -- if
		end;


feature		-- Status report

	running : BOOLEAN;


feature { TK_EXIT_COMMAND }

	exit is
		require
			running : running
		do
			running := False;
		end;

feature { NONE }		-- Private

	tcl : TCL_INTERPRETER;
	main_window : POINTER;

	width_of_called : BOOLEAN;		-- Used only in width_of


feature { NONE } 		-- C implementation

	c_tk_init (handle : POINTER) : POINTER is
		external
			"C"
		end;

	c_do_one_tk_event is
		external
			"C"
		end;


end -- class TK_APPLICATION
