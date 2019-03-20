class PROJECT_READER
	-- Knows how to read a file containing objects.  Objects are
	-- specified in a lisp-like syntax, with the symbol after a leading (
	-- representing the class of the object being read.  (There is one
	-- exception to this:  PROJECT is called "flower-project", because that
	-- makes for a file that a human can recognize as belonging to flower).
	--
	-- This doesn't really try to be a generic "anything" reader -- a fair
	-- amount of understanding about PROJECT is hard-coded into this class.
	-- I'll factor out the generic stuff if and when there's a need!

inherit

	EXCEPTIONS

creation

	make

feature		-- Initialize/Release


	make (file_name : STRING; a_project : PROJECT) is
		do
			project := a_project;
			!!ascii;
			!!file.make_open_read(file_name);
			!!span_endpoints.make(0);
			!!some_spans.make(0);
			!!diagram_drawables.make(0);
			paren_level := 0;
			curr_line := 1;
			curr_character := 0;
			read_character;
		end;


	release is
		do
			file.close
		end;

feature		-- Access 

	is_open : BOOLEAN is
		do
			Result := not file.is_closed
		end;

	read : ANY is
		-- Read the next object in the file.  Return Void if there is
		-- nothing more to be read (at the current paren_level).
		do
			skip_whitespace;
			if last_character = '(' then
				paren_level := paren_level + 1;
				Result := read_object;
			elseif last_character = ')' then
				read_character;
				paren_level := paren_level - 1;
				Result := Void;
			elseif last_character.code = ascii.Singlequote then
				Result := read_string;
			else 
				Result := read_token;
			end;
		end;

	init_project (an_app : FLOWER_MAIN) is
		local
			i : INTEGER;
			diagrams : ARRAYED_LIST [ DIAGRAM ];
			diagram : DIAGRAM;
			dialog_name : STRING;
			command : TCL_COMMAND_STRING;
			long_title : STRING;
		do
			diagrams := project.diagrams_as_arrayed_list;
				-- Yes, I *could* iterate directly through the hash
				-- table, but I hate the idea of making stateful changes
				-- to a collection just to iterate through it.
			from i := 1 until i > diagrams.count loop
					-- @@ This is a bit of a kludge.  Eventually, I will
					-- @@ defer initializing a diagram until it's asked
					-- @@ for, and provide a way of closing diagrams.
				diagram := diagrams @ i;
				!!command.make("make_class_diagram rumbaugh ");
				command.int_arg(diagram.id);
				long_title := clone(diagram.title);
				long_title.append(" (Rumbaugh Class Diagram)");
				command.string_arg(long_title);
				dialog_name := an_app.tk_app.eval(command);
				diagram.init_from_reader(an_app, dialog_name);
				i := i + 1;
			end -- loop
		end;

feature	{ PROJECT_STREAMABLE }	-- Services

	error (msg : STRING) is
		do
			msg.append(", file ");
			msg.append(file.name);
			msg.append(", line ");
			msg.append(curr_line.out);
			msg.append(", character ");
			msg.append(curr_character.out);
			raise(msg);
		end;

	get_lm_item (id_str : STRING) : LOGICAL_MODEL_ITEM is
		-- Get the item identified by id_str
		local
			i : INTEGER;
			message : STRING;
		do
			i := -1;
			if id_str /= Void and then id_str.is_integer then
				i := id_str.to_integer;
			end
			if i < 1 or else i > project.logical_model.items.count then
				!!message.make(50);
				message.append("Meta-model id number ");
				if id_str = Void then
					message.append("<void>")
				else
					message.append(id_str)
				end
				message.append(" not found");
				error(message);
			end
			Result := project.logical_model.items @ i;
		end;

	get_diagram_drawable (id_str : STRING) : DRAWABLE is
		-- Get the diagram_drawable identified by id_str
		local
			i : INTEGER;
			message : STRING;
		do
			i := -1;
			if id_str /= Void and then id_str.is_integer then
				i := id_str.to_integer;
			end
			if i < 1 or else i > diagram_drawables.count then
				!!message.make(50);
				message.append("Diagram drawable id number ");
				if id_str = Void then
					message.append("<void>")
				else
					message.append(id_str)
				end
				message.append(" not found");
				error(message);
			end
			Result := diagram_drawables @ i;
		end;


	get_solid (id_str : STRING) : SOLID is
		do
			Result ?= get_diagram_drawable(id_str);
			if Result = Void then
				error("Expected solid")
			end
		end;

	get_inheritance_triangle (id_str : STRING) : INHERITANCE_TRIANGLE is
		do
			Result ?= get_diagram_drawable(id_str);
			if Result = Void then
				error("Expected inheritance triangle")
			end
		end;

	get_span_endpoint (id_str : STRING) : SPAN_ENDPOINT is
		-- Get the SPAN_ENDPOINT identified by id_str
		local
			i : INTEGER;
			message : STRING;
		do
			i := -1;
			if id_str /= Void and then id_str.is_integer then
				i := id_str.to_integer;
			end
			if i < 1 or else i > diagram_drawables.count then
				!!message.make(50);
				message.append("Span endpoint id number ");
				if id_str = Void then
					message.append("<void>")
				else
					message.append(id_str)
				end
				message.append(" not found");
				error(message);
			end
			Result := span_endpoints @ i;
		end;

	check_id_str (id_str : STRING) is
		-- Check that the id in id_str is consistent with the item
		-- number wanted.
		do
			if id_str = Void or else (not id_str.is_integer)
			   or else id_str.to_integer < 1
			then
				error("Invalid id");
					-- For now, id's are limited to being sequential id's.
					-- In the future (especially if/when a client/server
					-- version is made), id's will be more meaningful -- for
					-- now, they're more of a placeholder.
			end;
		end;

	add_diagram (id_str : STRING; d : DIAGRAM) is
		do
			check_id_str(id_str);
			project.add_diagram(d);
			diagram_drawables.wipe_out;
		end;

	add_diagram_drawable (id_str : STRING; d : DRAWABLE) is
		do
			check_id_str(id_str);
			from until diagram_drawables.count >= id_str.to_integer loop
				diagram_drawables.extend(Void);
			end
			diagram_drawables.put_i_th(d, id_str.to_integer);
		end;

	add_span (s : SPAN) is
			-- Add a span to some_spans for later consumption by a CONNECTION
		do
			some_spans.extend(s);
		end;

	add_span_endpoint (id_str : STRING; ep : SPAN_ENDPOINT) is
		do
			check_id_str(id_str);
			from until span_endpoints.count >= id_str.to_integer loop
				span_endpoints.extend(Void);
			end
			span_endpoints.put_i_th(ep, id_str.to_integer);
		end;

	take_some_spans : ARRAYED_LIST [ SPAN ] is
			-- Give ownership of some_spans to the caller, and create a
			-- new one
		do
			Result := some_spans;
			!!some_spans.make(0);
			!!span_endpoints.make(0);	
				-- The endpoints are owned by the spans.
		ensure
			result_not_void: Result /= Void;
		end;


	make_endpoint_constraint (type, solid_str : STRING; x, y : INTEGER) 
							 : ENDPOINT_CONSTRAINT is
		do
			if type = Void then
				error("error in span endpoint constraint");
			end
			if type.is_equal("nil") then
				Result := Void
			elseif type.is_equal("fixed") then
				!ENDPOINT_FIXED_CONSTRAINT!Result.make(x, y);
			elseif type.is_equal("solid-top") then
				!ENDPOINT_SOLID_TOP_CONSTRAINT!
					Result.make(get_solid(solid_str));
			elseif type.is_equal("solid-bottom") then
				!ENDPOINT_SOLID_BOTTOM_CONSTRAINT!
					Result.make(get_solid(solid_str));
			elseif type.is_equal("solid-left") then
				!ENDPOINT_SOLID_LEFT_CONSTRAINT!
					Result.make(get_solid(solid_str));
			elseif type.is_equal("solid-right") then
				!ENDPOINT_SOLID_RIGHT_CONSTRAINT!
					Result.make(get_solid(solid_str));
			elseif type.is_equal("triangle-top") then
				!ENDPOINT_TRIANGLE_TOP_CONSTRAINT!
					Result.make(get_inheritance_triangle(solid_str));
			elseif type.is_equal("triangle-bottom") then
				!ENDPOINT_TRIANGLE_BOTTOM_CONSTRAINT!
					Result.make(get_inheritance_triangle(solid_str));
			else
				error("Unrecognized endpoint constraint type");
			end
		end;


feature -- Attributes

	project : PROJECT;		-- The project being read.  Items being read need
							-- this so they can insert themselves;

		
		-- The following attributes give a building area for items that
		-- need it:


	diagram_drawables : ARRAYED_LIST [ DRAWABLE ];
											-- for DRAWABLE
	span_endpoints : ARRAYED_LIST [ SPAN_ENDPOINT ];	
											-- For MANHATTAN_CONNECTION
	some_spans : ARRAYED_LIST [ SPAN ];
											-- For MANHATTAN_CONNECTION


feature { PROJECT_READER }	-- Implementation

	file : PLAIN_TEXT_FILE;

	paren_level : INTEGER;	-- How many left-parens deep we currently are

	ascii : ASCII;		-- The ASCII character set.  I just can't bear
						-- to inherit this!

	curr_line,
	curr_character : INTEGER		-- Our position (for error messages)

	read_character is
			-- Advance to next character, keeping curr_character and curr_line
			-- up to date.  Raise an exception on EOF.
		do
			if file.end_of_file then
				error("End of file unexpected");
					-- End of file is *never* expected, because we don't read
					-- past the last matching right-parenthesis
			end
			file.read_character;
			if file.last_character.code = ascii.Nl then
				curr_line := curr_line + 1;
				curr_character := 0;
			else
				curr_character := curr_character + 1;
			end
		end;

	last_character : CHARACTER is
		do
			Result := file.last_character
		end;

	is_whitespace (c : CHARACTER) : BOOLEAN is
		-- Something is whitespace if it isn't '(', ')', '''', '-', a letter
		-- or a digit.  This is rather severe, but then, our 
		-- grammar is very simple.
		do
			Result := c /= '(' 
					  and then c /= ')'
				      and then c.code /= ascii.Singlequote 
				      and then (not is_token_char(c));
		end;

	skip_whitespace is
		do
			from until not is_whitespace(last_character) loop
				read_character
			end;
		end;

	is_token_char (c : CHARACTER) : BOOLEAN is
		-- Is c a character that can be part of a token?  Tokens *may* start
		-- with digits, and contain dashes and/or underscores.
		do
			Result := c.is_alpha
					  or else c.is_digit
					  or else c = '-'
					  or else c = '_';
		end;

	read_object : ANY is
			-- Read the next object, leaving last_character set past the
			-- ending ')'
		require
			starts_with_paren : last_character = '('
		local
			arg : ANY;
			args : ARRAYED_LIST [ ANY ];
			type_name : STRING;
		do
			read_character;		-- skip the '('
			skip_whitespace;
			type_name := read_token;
			from
				!!args.make(0);
				arg := read;
			until
				arg = Void
			loop
				args.extend(arg);
				arg := read;
			end -- loop

			Result := create_object(type_name, args);
		end;

	create_object(type_name : STRING; args : ARRAYED_LIST [ ANY ]) : ANY is
		-- Create the object described by type_name and args
		local
			msg : STRING;
		do
			if type_name.is_equal("flower-project") then
				check_flower_project_version(args);
					-- The rest of the arguments would have added themselves
					-- to the project.
				Result := project;
			elseif type_name.is_equal("logical-model") then
				-- Do nothing...  The arguments added themselves
				Result := project.logical_model
			elseif type_name.is_equal("lm-class") then
				!LM_CLASS!Result.make_for_reader(Current, args);
			elseif type_name.is_equal("lm-variable") then
				!LM_VARIABLE!Result.make_for_reader(Current, args);
			elseif type_name.is_equal("lm-method") then
				!LM_METHOD!Result.make_for_reader(Current, args);
			elseif type_name.is_equal("lm-generalization") then
				!LM_GENERALIZATION!Result.make_for_reader(Current, args);
			elseif type_name.is_equal("lm-association") then
				!LM_ASSOCIATION!Result.make_for_reader(Current, args);
			elseif type_name.is_equal("lm-aggregation") then
				!LM_AGGREGATION!Result.make_for_reader(Current, args);
			elseif type_name.is_equal("rumbaugh-diagram") then
				!RUMBAUGH_DIAGRAM!Result.make_for_reader(Current, args);
			elseif type_name.is_equal("class-box") then
				!CLASS_BOX!Result.make_for_reader(Current, args);
			elseif type_name.is_equal("inheritance-triangle") then
				!INHERITANCE_TRIANGLE!Result.make_for_reader(Current, args);
			elseif type_name.is_equal("manhattan-connection") then
				!MANHATTAN_CONNECTION!Result.make_for_reader(Current, args);
			elseif type_name.is_equal("manhattan-span") then
				!MANHATTAN_SPAN!Result.make_for_reader(Current, args);
			elseif type_name.is_equal("span-endpoint") then
				!SPAN_ENDPOINT!Result.make_for_reader(Current, args);
			else
				!!msg.make(50);
				msg.append("Unrecognized object type '");
				msg.append(type_name);
				msg.append("'");
				error(msg);
			end -- if
		end;

	read_string : STRING is
			-- Read the next string, leaving last_character set past
			-- the ending quote.  Backslash will escape anything
			-- (notably "'").
		require
			starts_with_quote : last_character.code = Ascii.Singlequote;
		do
			!!Result.make(10);
			from
				read_character
			until
				last_character.code = Ascii.Singlequote
			loop
				if last_character.code = Ascii.Backslash then
					read_character;		-- Allows ' to be escaped
				end
				Result.extend(last_character);
				read_character;
			end
			read_character;		-- Pass the trailing '
		end;

	check_flower_project_version (args : ARRAYED_LIST [ ANY ]) is
			-- Check that the version number (in args @ 1) is OK
		local
			s : STRING;
		do
			if args.count >= 1 then
				s ?= args @ 1;
			end -- if
			if s = Void or else not s.is_integer
				   or else s.to_integer /= 1
			then
				raise("File version number of 1 expected");
			end
		end;

	read_token : STRING is
			-- Read a token, leaving last_character set past the
			-- last character.  Tokens consist of letters, numbers, and
			-- dashes.
		local
			message : STRING;
		do
			if not is_token_char(last_character) then
				!!message.make(50);
				message.append("'");
				message.extend(last_character);
				message.append("' unexpected");
				error(message);
			end
			!!Result.make(10);
			from until not is_token_char(last_character) loop
				result.extend(last_character);
				read_character;
			end;
		end;

end -- class PROJECT_READER
