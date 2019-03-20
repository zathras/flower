class OPEN_PROJECT_CMD 
	-- Command to open a project


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

	name : STRING is "open_project";


feature { TCL_INTERPRETER }		-- Command invocation

	evaluate (args : ARRAY[STRING]) : STRING is
		local
			reader : PROJECT_READER;
			project : PROJECT;
		do
			if args.lower /= args.upper then
				raise("wrong # of arguments:  should be 'eiffel open_project <name>'");
			end

			!!project.make(app);
			!!reader.make(args @ args.lower, project);
			if not reader.is_open then
				raise("Unable to open file");
			end
			project ?= reader.read;
			check project_made: project /= Void end;
				-- If there was a problem, reader should have thrown 
				-- an exception
				-- @@ We should catch this, and at least release the reader
			app.set_project(project);
			reader.init_project(app);
			reader.release;
			Result := "";
		end;


feature { NONE } 	-- private

	app : FLOWER_MAIN;



end -- class OPEN_PROJECT_CMD

