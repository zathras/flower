class ECD_MEMBER_DELETE_CMD 
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
			command : TCL_COMMAND_STRING;
		do
			if args.lower /= args.upper then
				raise("Error in arguments:  Should be %'eiffel ecd_member_delete <diagram>%'");
			end
			diagram_name := args @ 0;
			check right_diagram: diagram_name.is_equal(dialog.dialog_name) end;

			dialog.delete_current_member;
			Result := "";
		end;

feature		-- Attributes

	name : STRING is "ecd_member_delete";

end -- class ECD_MEMBER_DELETE_CMD
