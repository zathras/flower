class SAVE_PROJECT_CMD 
	-- Command to save a project


inherit
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

	name : STRING is "save_project";


feature { TCL_INTERPRETER }		-- Command invocation

	evaluate (args : ARRAY[STRING]) : STRING is
		local
			writer : PROJECT_WRITER;
		do
			if args.lower /= args.upper then
				raise("wrong # of arguments:  should be 'eiffel save_project <name>'");
			end

			!!writer.make(args @ args.lower);
			if not writer.is_open then
				raise("Unable to open file");
			end
			writer.write(app.project);
			writer.release;
			Result := "";
		end;


feature { NONE } 	-- private

	app : FLOWER_MAIN;



end -- class SAVE_PROJECT_CMD

