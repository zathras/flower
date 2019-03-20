class EDIT_RELATIONSHIP_DIALOG
	-- This singleton class oversees the edit_associatino Tk dialog.  
	-- This dialog is used to modify LM_RELATIONSHIPs (either
	-- LM_ASSOCIATIONs or LM_AGGRETATIONs).

inherit

	OBSERVER		-- We Observe the association we're editing
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

	launch (a_relationship : LM_CLASS_RELATIONSHIP) is
				-- @@ Oops!  This should be an EDIT_CLASS_RELATIONSHIP_DIALOG
		local
			command : TCL_COMMAND_STRING;
		do
			if edited_relationship /= Void then		-- If we're already open
				close
			end -- if
			edited_relationship := a_relationship;
			!!command.make("edit_relationship");
			command.string_arg(a_relationship.source_class.name);
			command.boolean_arg(a_relationship.has_source_attributes);
			command.string_arg(a_relationship.destination_class.name);
			command.boolean_arg(a_relationship.has_destination_attributes);
			dialog_name := tk_app.eval(command);
				-- it should always give the same name
			notify_change;		-- To set the multiplicity widgets
			edited_relationship.add_observer(Current);
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

feature { EDIT_RELATIONSHIP_DIALOG_CMD } -- Command callbacks


	apply is		-- When the apply button is pressed
		local
			res : STRING;
			src_m, dest_m : MULTIPLICITY;
			src_attr, dest_attr : LM_RELATIONSHIP_END_ATTRIBUTES;
		do
			src_attr := edited_relationship.source_attributes;
			if src_attr /= Void then
				res := tk_app.get_global_array(dialog_name, 
											   "source_multiplicity");
				src_m := edited_relationship.mult_from_string(res);
			end

			dest_attr := edited_relationship.destination_attributes;
			if dest_attr /= Void then
				res := tk_app.get_global_array(dialog_name, 
											   "dest_multiplicity");
				dest_m := edited_relationship.mult_from_string(res);
			end

				-- It's important to do the changing last, because
				-- the observer mechanism changes the radiobutton
				-- area out from under us!
			if src_attr /= Void and then src_attr.multiplicity /= src_m then
				edited_relationship.set_source_multiplicity(src_m);
			end -- if

			if dest_attr /= Void and then dest_attr.multiplicity /= dest_m then
				edited_relationship.set_destination_multiplicity(dest_m);
			end -- if
		end;

	close is
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make("wm withdraw .");
			command.append(dialog_name);
			res := tk_app.eval(command);
			edited_relationship.remove_observer(Current);
			edited_relationship := Void;
		end;

feature	{ OBSERVER, OBSERVABLE }	-- Notification

	notify_change is
		local
			str : STRING;
			attr : LM_RELATIONSHIP_END_ATTRIBUTES;
		do
			attr := edited_relationship.source_attributes;
			if attr /= Void then
				str := edited_relationship.mult_to_string(attr.multiplicity);
				tk_app.set_global_array(dialog_name, 
									    "source_multiplicity", str);
			end -- if

			attr := edited_relationship.destination_attributes;
			if attr /= Void then
				str := edited_relationship.mult_to_string(attr.multiplicity);
				tk_app.set_global_array(dialog_name, 
									    "dest_multiplicity", str);
			end -- if
		end;

	notify_release is
			-- Called just before class is deleted.  This shouldn't ever
			-- happen in the single-user verion.
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			close;
			tk_app.show_message("The relationship you were editing has just been deleted.");
		end;

feature { EDIT_CLASS_DIALOG }		-- Implementation

	edited_relationship : LM_RELATIONSHIP;	  -- The relationship being edited


	set_created is
		do
			created_ref.set_item(True);
		end;

	created_ref : BOOLEAN_REF is
		once
			!!Result;
			Result.set_item(False);
		end;


feature { NONE }		-- Tcl Commands

	bind_commands is
				-- Create the commands that the dialog uses to call us
		local
			cmd : EDIT_RELATIONSHIP_DIALOG_CMD;
		do
			!ERELAT_D_APPLY_CMD!cmd.make(Current);
			tk_app.add_command(cmd);
			!ERELAT_D_CLOSE_CMD!cmd.make(Current);
			tk_app.add_command(cmd);
		end;


end -- class EDIT_RELATIONSHIP_DIALOG
