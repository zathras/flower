class ECD_CLOSE_CMD
	-- Called when the close button is pressed in the class edit dialog

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
		do
			if args.lower /= args.upper then
				raise("Error in arguments:  Should be %'eiffel ecd_close <diagram>%'");
			end
			diagram_name := args @ 0;
			check right_diagram: diagram_name.is_equal(dialog.dialog_name) end;
			dialog.close;
			Result := "";
		end;

feature		-- Attributes

	name : STRING is "ecd_close";

end -- class ECD_CLOSE_CMD
