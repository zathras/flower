class CREATE_SPECIALIZATION_CMD inherit
    -- Add a specialization (subclassing) relationship  to the diagram 
    -- identified by the id (passed in as an argument)


	TCL_COMMAND
		redefine
			evaluate, name
		end;

	EXCEPTIONS

creation

	make

feature		-- Initialilze/Release

	make (application : FLOWER_MAIN) is
		do
			app := application;
		end;


feature		-- Attributes

	name : STRING is "create_specialization";


feature { TCL_INTERPRETER }		-- Command invocation

	evaluate (args : ARRAY[STRING]) : STRING is
		local
			id : INTEGER;
			diagram : DIAGRAM;
			command : DRAW_SPECIALIZATION_CMD;
		do
			if args.lower /= args.upper 
				or else (not (args @ 0).is_integer)
			then
				raise("Error in arguments:  should be 'eiffel create_specialization <id>'");
			end
			id := (args @ 0).to_integer;
			diagram := app.find_diagram(id);
			if (diagram = Void) then
				raise("Internal error:  Diagram not found");
			end;
			!!command.make(diagram.controller);
			diagram.controller.set_button_down_cmd(command);
			Result := "";
		end;


feature { NONE } 	-- private

	app : FLOWER_MAIN;


end -- class CREATE_SPECIALIZATION_CMD
