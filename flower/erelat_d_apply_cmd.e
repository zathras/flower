class ERELAT_D_APPLY_CMD
	-- Called when an apply is requested from the edit relationship dialog

inherit

	EDIT_RELATIONSHIP_DIALOG_CMD
		redefine
			evaluate, name
		end;
	EXCEPTIONS

creation

	make

feature { TCL_INTERPRETER }		-- Command invocation

	evaluate (args : ARRAY[STRING]) : STRING is
		local
			diagram_name : STRING;
			res : STRING;
		do
			if args.lower /= args.upper then
				raise("Error in arguments:  Shoule be %'eiffel eassoc_d_apply <dialog name>%'");
			end;
			diagram_name := args @ 0;
			check right_diagram: diagram_name.is_equal(dialog.dialog_name) end;
			dialog.apply;
			Result := "";
		end;

feature		-- Attributes

	name : STRING is "erelat_d_apply";


end -- class ERELAT_D_APPLY_CMD
