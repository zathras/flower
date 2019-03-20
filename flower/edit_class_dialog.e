class EDIT_CLASS_DIALOG 
	-- This singleton class oversees the edit_class Tk dialog.  This dialog
	-- is used to modify an LM_CLASS.

inherit

	OBSERVER		-- We Observe the class we're editing
		redefine
			notify_change,
			notify_release
		end;

creation

	make

feature		-- Initialize/Release

	make (a_tk_app : TK_APPLICATION) is
		require
			app_given : a_tk_app /= Void;
			not_created_before : not created;	-- It is a singleton.
		do
			tk_app := a_tk_app;
			bind_commands;
			set_created;
		ensure
			created_flag_set : created;
		end;

feature		-- Editing

	launch (a_class : LM_CLASS) is
		local
			command : TCL_COMMAND_STRING;
		do
			if edited_class /= Void then		-- If we're already open
				close
			end -- if
			edited_class := a_class;
			selected_method := -1;
			selected_variable := -1;
			!!command.make("edit_class ");
			command.string_arg(a_class.name);
			command.append(tcl_method_names_list);
			command.append(tcl_variable_names_list);
			dialog_name := tk_app.eval(command);
				-- it should always give the same name
			edited_class.add_observer(Current);
		end;


feature		-- Querying


	created : BOOLEAN is
			-- Has an instance of this class been created?  (This is useful
			-- for ensuring that this is a singleton)
		do
			Result := created_ref.item
		end;

	dialog_name : STRING;		-- The name of the dialog that is 
								-- created for us.

feature		-- Attributes

	tk_app : TK_APPLICATION;

feature { EDIT_CLASS_DIALOG_CMD } -- Command callbacks

	select_variable (num : INTEGER) is
		do
			selected_method := -1;
			selected_variable := num;
			update_member_area;
		end;

	select_method (num : INTEGER) is
		do
			selected_method := num;
			selected_variable := -1;
			update_member_area;
		end;

	set_class_name (a_name : STRING) is
		do
			if not a_name.is_equal(edited_class.name) then
				edited_class.set_name(a_name)
			end;
		end;

	apply_member_attributes (member_name, member_type : STRING) is
		local
			method : LM_METHOD;
			variable : LM_VARIABLE;
		do
			if selected_variable = 0 then
				!!variable.make(member_name, member_type);
				selected_variable := edited_class.variables.count + 1;
				edited_class.append_variable(variable);
			elseif selected_method = 0 then
				!!method.make(member_name, member_type);
				selected_method := edited_class.methods.count + 1;
				edited_class.append_method(method);
			elseif selected_variable > 0 then
				!!variable.make(member_name, member_type);
				edited_class.replace_variable(variable, selected_variable);
			elseif selected_method > 0 then
				!!method.make(member_name, member_type);
				edited_class.replace_method(method, selected_method);
			else
				tk_app.show_message("No variable or method selected!");
			end
			-- The change notification mechanism takes care of the
			-- screen update for us.
		end;

	delete_current_member is
		local
			i : INTEGER;
		do
			if selected_variable > 0 then
				i := selected_variable;
				selected_variable := -1;
				edited_class.remove_variable(i);
			elseif selected_method > 0 then
				i := selected_method;
				selected_method := -1;
				edited_class.remove_method(i);
			else
				tk_app.show_message("No variable or method selected!");
			end
			-- The change notification mechanism takes care of the
			-- screen update for us.
		end;

	close is
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make("wm withdraw .");
			command.append(dialog_name);
			res := tk_app.eval(command);
			edited_class.remove_observer(Current);
			edited_class := Void;
		end;

feature	{ OBSERVER, OBSERVABLE }	-- Notification

	notify_change is
		do
			if selected_variable > edited_class.variables.count then
				selected_variable := -1
			end;
			if selected_method > edited_class.methods.count then
				selected_method := -1
			end;
			update_class_name;
			populate_listbox("methods.list", tcl_method_names_list, 
						     selected_method);
			populate_listbox("variables.list", tcl_variable_names_list, 
						     selected_variable);
			update_member_area;
		end;

	notify_release is
			-- Called just before class is deleted.  This shouldn't ever
			-- happen in the single-user verion.
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			close;
			tk_app.show_message("The class you were editing has just been deleted.");
		end;

feature { EDIT_CLASS_DIALOG }		-- Implementation

	edited_class : LM_CLASS;		-- The class being edited

	selected_method : INTEGER;
	selected_variable : INTEGER;
		-- The number of the method or variable currently selected.  -1
		-- means not selected, 0 is the special value "<New>", and anything
		-- else is an index into the list.  A variable and a method may not
		-- be selected at the same time.


	set_created is
		do
			created_ref.set_item(True);
		end;

	created_ref : BOOLEAN_REF is
		once
			!!Result;
			Result.set_item(False);
		end;

	update_class_name is
		-- Update the class name in the dialog
		do
			tk_app.set_global_array(dialog_name, "class_name",
								    edited_class.name);
		end;

	populate_listbox(name, methods_list : STRING; selected_no : INTEGER) is
		-- Populate the named listbox with the methods in method_list (a
		-- Tcl-format list).  See to it that selected_no is selected.
		local
			listbox_name : STRING;
		do
			!!listbox_name.make(30);
			listbox_name.append(".");
			listbox_name.append(dialog_name);
			listbox_name.append(".l.");
			listbox_name.append(name);

			tk_app.populate_listbox(listbox_name, methods_list, selected_no);
		end;

	update_member_area is
		-- Update the name and type entry boxes in the dialog's member area
		local
			name, type : STRING;
		do
			if selected_method > 0 then
				name := (edited_class.methods @ selected_method).name;
				type := (edited_class.methods @ selected_method).type;
			elseif selected_variable > 0 then
				name := (edited_class.variables @ selected_variable).name;
				type := (edited_class.variables @ selected_variable).type;
			else
				name := "";
				type := "";
			end
			tk_app.set_global_array(dialog_name, "member_name", name);
			tk_app.set_global_array(dialog_name, "member_type", type);
		end;

	tcl_method_names_list : TCL_COMMAND_STRING is
		-- A tcl-style list of the method names
		local
			i : INTEGER;
		do
			!!Result.make("");
			Result.start_array;
			Result.string_arg("<New>");
			from i := 1 until i > edited_class.methods.count loop
				Result.string_arg((edited_class.methods @ i).name);
				i := i + 1;
			end
			Result.finish_array;
		end;

	tcl_variable_names_list : TCL_COMMAND_STRING is
		-- A tcl-style list of the variable names
		local
			i : INTEGER;
		do
			!!Result.make("");
			Result.start_array;
			Result.string_arg("<New>");
			from i := 1 until i > edited_class.variables.count loop
				Result.string_arg((edited_class.variables @ i).name);
				i := i + 1;
			end
			Result.finish_array;
		end;

feature { NONE }		-- Tcl Commands

	bind_commands is
				-- Create the commands that the dialog uses to call us
		local
			cmd : EDIT_CLASS_DIALOG_CMD;
		do
			!ECD_METHOD_SELECT_CMD!cmd.make(Current);
			tk_app.add_command(cmd);
			!ECD_VARIABLE_SELECT_CMD!cmd.make(Current);
			tk_app.add_command(cmd);
			!ECD_APPLY_CMD!cmd.make(Current);
			tk_app.add_command(cmd);
			!ECD_CLOSE_CMD!cmd.make(Current);
			tk_app.add_command(cmd);
			!ECD_MEMBER_APPLY_CMD!cmd.make(Current);
			tk_app.add_command(cmd);
			!ECD_MEMBER_DELETE_CMD!cmd.make(Current);
			tk_app.add_command(cmd);
		end;


end -- class EDIT_CLASS_DIALOG
