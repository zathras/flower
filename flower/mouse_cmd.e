
deferred class MOUSE_CMD inherit
	-- Parent of mouse commands.

	TCL_COMMAND
		redefine
			evaluate
		end;

	EXCEPTIONS



feature	{ BUTTON_CMD }	-- Subclass implementation

	do_command(c : CONTROLLER; x : INTEGER; y : INTEGER) is
		deferred
		end;

	app : FLOWER_MAIN is
		deferred
		end;

feature { TCL_INTERPRETER }		-- Command invocation

	evaluate (args : ARRAY[STRING]) : STRING is
		local
			id : INTEGER;
			x : INTEGER;
			y : INTEGER;
			diagram : DIAGRAM;
		do
			if args.lower+2/= args.upper 
				or else (not (args @ 0).is_integer)
				or else (not (args @ 1).is_double)
				or else (not (args @ 2).is_double)
			then
				raise("Error in arguments");
			end
			id := (args @ 0).to_integer;
			diagram := app.find_diagram(id);
			if (diagram = Void) then
				raise("Internal error:  Diagram not found");
			end;
			x := ((args @ 1).to_double + 0.5).floor;
			y := ((args @ 2).to_double + 0.5).floor;
			do_command(diagram.controller, x, y);
			Result := "";
		end;




end -- class BUTTON_1_DOWN_CMD
