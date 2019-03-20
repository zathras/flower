class flower_main

creation

	make

feature	-- Creation

	make is
		local
			res : STRING;
		do
			!!project.make(Current);
			!!tk_app.make;
			bind_commands;
			res := tk_app.eval_file("flower.tcl");
			tk_app.run;
			tk_app.release;
		end;
	


feature 		-- Modification

	add_diagram(a_diagram : DIAGRAM) is
		do
			project.add_diagram(a_diagram)
		end;

	set_project (p : PROJECT) is
		do
			if project /= Void then
				project.release;
			end
			project := p;
		end;

feature			-- Attributes

	tk_app : TK_APPLICATION;

	project : PROJECT;

feature			-- Query

	logical_model : LOGICAL_MODEL is
		do
			Result := project.logical_model
		end;

	find_diagram(an_id : INTEGER) : DIAGRAM is		
			-- Find a diagram by id, Void if not found.
		do
			Result := project.find_diagram(an_id);
		end;

	next_diagram_id : INTEGER is	-- Generate a unique id for a diagram
		do
			Result := project.next_diagram_id;
		end;



feature { NONE }	-- Private

	bind_commands is
			-- Bind all of our commands into the application prior to launching
		local
			command : TCL_COMMAND;
		do
			!OPEN_PROJECT_CMD!command.make(Current);
			tk_app.add_command(command);
			!SAVE_PROJECT_CMD!command.make(Current);
			tk_app.add_command(command);
			!OPEN_RUMBAUGH_CLASS_CMD!command.make(Current);
			tk_app.add_command(command);
			!CREATE_CLASS_CMD!command.make(Current);
			tk_app.add_command(command);
			!CREATE_ASSOCIATION_CMD!command.make(Current);
			tk_app.add_command(command);
			!CREATE_AGGREGATION_CMD!command.make(Current);
			tk_app.add_command(command);
			!CREATE_SPECIALIZATION_CMD!command.make(Current);
			tk_app.add_command(command);
			!BUTTON_1_DOWN_CMD!command.make(Current);
			tk_app.add_command(command);
			!BUTTON_1_DOUBLE_CMD!command.make(Current);
			tk_app.add_command(command);
            !BUTTON_3_DOWN_CMD!command.make(Current);
            tk_app.add_command(command);
			!BUTTON_1_UP_CMD!command.make(Current);
			tk_app.add_command(command);
			!MOUSE_MOVE_CMD!command.make(Current);
			tk_app.add_command(command);
		end;

end -- class FLOWER_MAIN
