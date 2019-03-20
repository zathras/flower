
    -- This command will add a class to the diagram identified by the
    -- id (passed in as an argument)

class CREATE_CLASS_CMD inherit

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

	name : STRING is "create_class";


feature { TCL_INTERPRETER }		-- Command invocation

	evaluate (args : ARRAY[STRING]) : STRING is
		local
			id : INTEGER;
			diagram : DIAGRAM;
			a_class_name : STRING;
			a_class : LM_CLASS;
			class_box : CLASS_BOX;
		do
			if args.lower+1 /= args.upper 
				or else (not (args @ 0).is_integer)
			then
				raise("Error in arguments:  should be 'eiffel create_class <id> <name>'");
			end
			id := (args @ 0).to_integer;
			a_class_name := args @ 1;
			a_class := app.logical_model.class_named(a_class_name);
			diagram := app.find_diagram(id);
			if (diagram = Void) then
				raise("Internal error:  Diagram not found");
			end;
			!!class_box.make(10, 10, a_class, diagram);
			Result := "";
		end;


feature { NONE } 	-- private

	app : FLOWER_MAIN;




end -- class CREATE_CLASS_CMD
