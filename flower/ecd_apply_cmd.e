class ECD_APPLY_CMD 
	-- Called when a variable is selected on the listbox
	-- in the edit class dialog

inherit

	EDIT_CLASS_DIALOG_CMD
		redefine
			evaluate, name
		end;
	EXCEPTIONS

creation

	make


feature	{ TCL_INTERPRETER }		-- Command invocation

	evaluate (args : ARRAY[STRING]) : STRING is
		local
			diagram_name : STRING
			new_class_name : STRING;
		do
			if args.lower /= args.upper then
				raise("Error in arguments:  Should be %'eiffel ecd_apply <diagram>%'");
			end
			diagram_name := args @ 0;
			check right_diagram: diagram_name.is_equal(dialog.dialog_name) end;
			-- Fetch the new name from the $name(class_name) variable
			new_class_name 
				:= dialog.tk_app
					.get_global_array(dialog.dialog_name, "class_name");
			dialog.set_class_name(new_class_name);
			Result := "";
		end;

feature		-- Attributes

	name : STRING is "ecd_apply";

end -- class ECD_APPLY_CMD
