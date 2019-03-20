

    -- This command will open a new Rumbaugh class diagram (or, if
    -- the given diagram is already open, it will bring it to the
    -- top.

class OPEN_RUMBAUGH_CLASS_CMD inherit

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

	name : STRING is "open_rumbaugh_class";


feature { TCL_INTERPRETER }		-- Command invocation

	evaluate (args : ARRAY[STRING]) : STRING is
		local
			command : STRING;
			dialog_name : STRING;
			diagram : DIAGRAM;
			title : STRING;
			id : INTEGER;
		do
			if args.lower /= args.upper then
				raise("wrong # of arguments:  should be 'eiffel open_rumbaugh_class <name>'");
			end
			title := args @ 0;
			-- @@ check if already exists.  If so, don't create it, but
			--    do bring it to the front.

			id := app.next_diagram_id;
			!!command.make(40);
			command.append("make_class_diagram rumbaugh ");
			command.append_integer(id);
			command.append(" {");
			command.append(title);
			command.append(" (Rumbaugh Class Diagram)}");
			dialog_name := app.tk_app.eval(command);
				-- @@ ^^ This logic should be put in RUMBAUGH_DIAGRAM.
				-- @@    Doing this would mean it wouldn't have to be
				-- @@    duplicated in PROJECT_READER.

			!RUMBAUGH_DIAGRAM!diagram.make(id, dialog_name, title, app);
			app.add_diagram(diagram);
			Result := "";
		end;


feature { NONE } 	-- private

	app : FLOWER_MAIN;



end -- class OPEN_RUMBAUGH_CLASS_CMD

