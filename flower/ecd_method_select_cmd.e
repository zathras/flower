class ECD_METHOD_SELECT_CMD 
	-- Called when a method is selected on the listbox
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
			num : INTEGER;
			diagram_name : STRING
		do
			if args.lower+1 /= args.upper
				or else (not (args @ 1).is_integer)
			then
				raise("Error in arguments:  Should be %'eiffel ecd_method_select <diagram> <item #>%'");
			end
			diagram_name := args @ 0;
			num := (args @ 1).to_integer;
			check right_diagram: diagram_name.is_equal(dialog.dialog_name) end;
			dialog.select_method(num);
			result := "";
		end;

feature		-- Attributes

	name : STRING is "ecd_method_select";

end -- class ECD_METHOD_SELECT_CMD
