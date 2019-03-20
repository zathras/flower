class ECD_MEMBER_APPLY_CMD 
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
			member_name : STRING;
			member_type : STRING;
		do
			if args.lower /= args.upper then
				raise("Error in arguments:  Should be %'eiffel ecd_member_apply <diagram>%'");
			end
			diagram_name := args @ 0;
			check right_diagram: diagram_name.is_equal(dialog.dialog_name) end;

			member_name := dialog.tk_app.get_global_array(dialog.dialog_name, 
														  "member_name");
			member_type := dialog.tk_app.get_global_array(dialog.dialog_name, 
														  "member_type");

			dialog.apply_member_attributes(member_name, member_type);
			Result := "";
		end;

feature		-- Attributes

	name : STRING is "ecd_member_apply";

end -- class ECD_MEMBER_APPLY_CMD
