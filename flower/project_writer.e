class PROJECT_WRITER
	-- Knows how to write a file containing objects.  See PROJECT_READER.

inherit

	EXCEPTIONS

creation

	make

feature		-- Initialize/Release


	make (file_name : STRING) is
		do
			!!ascii;
			!!file.make_open_write(file_name);
			!!span_endpoints.make(0);
			paren_level := 0;
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

	write (a_project : PROJECT) is
		-- Write the project PROJECT to the file.
		local
			i : INTEGER;
			diagrams : ARRAYED_LIST [ DIAGRAM ];
		do
			project := a_project;
			left_paren;
			write_token("flower-project ");
			write_token(file_version.out);
			new_line;
			write_logical_model(project.logical_model);
			diagrams := project.diagrams_as_arrayed_list;
			from i := 1 until i > diagrams.count loop
				set_current_diagram(diagrams @ i, i);
				current_diagram.write_for_writer(Current);
				i := i + 1;
			end -- loop
			file.new_line;
			right_paren;
			file.new_line;
			project := Void;
		end;

feature		-- Services


	left_paren is
		do
			file.put_character('(');
			paren_level := paren_level + 1;
		end;

	right_paren is
		do
			file.put_character(')');
			paren_level := paren_level - 1;
		end;

	new_line is
		local
			i : INTEGER;
		do
			file.new_line;
			from i := 0 until i > paren_level loop
				file.put_character(' ');
				i := i + 1;
			end
		end;

	write_string (s : STRING) is
			-- Write the string s.
			-- Backslash will preceed ' and \.
		local
			i : INTEGER;
			c : CHARACTER;
		do
			file.put_character(''');
			from i := 1 until i > s.count loop
				c := s @ i;
				if c.code = ascii.Backslash or else c.code = Ascii.singlequote
				then
					file.put_character('\');
				end
				file.put_character(c);
				i := i + 1;
			end -- loop
			file.put_character(''');
			file.put_character(' ');
		end;

	write_token (s : STRING) is
			-- Write the token s.  Tokens are assumed to have a limited
			-- character set (cf. STREAM_READER)
		do
			file.put_string(s);
			file.put_character(' ');
		end;

	write_integer (i : INTEGER) is
		do
			file.put_integer(i);
			file.put_character(' ');
		end;

	has_span_endpoint (ep : SPAN_ENDPOINT) : BOOLEAN is
		do
			Result := span_endpoints.has(ep);
		end;

	set_span_endpoint_id (ep : SPAN_ENDPOINT) : INTEGER is
		require
			not_there: not has_span_endpoint(ep);
		do
			span_endpoints.extend(ep);
			Result := span_endpoints.count;
		end;

	get_span_endpoint_id (ep : SPAN_ENDPOINT) : INTEGER is
		do
			Result := span_endpoints.index_of(ep, 1);
			check found: Result > 0 end;
		end;

	reset_span_endpoints is
			-- *must* be called from CONNECTION
		do
			span_endpoints.wipe_out;
		end;

	get_lm_id (item : LOGICAL_MODEL_ITEM) : INTEGER is
		do
			Result := project.logical_model.items.index_of(item, 1);
				-- @@ Obviously, I should use a hash table here for speed.
			check found: Result > 0 end;
		end;

	get_current_diagram_id : INTEGER is
		do
			Result := current_diagram_id;
		end;

	get_connection_id (c : CONNECTION) : INTEGER is
		do
			Result := get_drawable_id(c);
		end;

	get_drawable_id (d : DRAWABLE) : INTEGER is
		do
			Result := current_diagram.drawables.index_of(d, 1);
			check found: Result > 0 end;
		end;

	get_solid_id_from_bounding_box (bb : BOUNDING_BOX) : INTEGER is
		local
			i : INTEGER;
			s : SOLID
		do
			Result := 0
			from i := 1 
			until Result /= 0 or else i > current_diagram.drawables.count 
			loop
				s ?= current_diagram.drawables @ i;
				if s /= Void and then s.bounding_box = bb then
					Result := i;
				end
				i := i + 1;
			end -- loop
			check found: Result > 0 end;
		end;



feature { PROJECT_WRITER }	-- Implementation

	project : PROJECT;		-- The project being written

	file : PLAIN_TEXT_FILE;

	paren_level : INTEGER;

	span_endpoints : ARRAYED_LIST [ SPAN_ENDPOINT ];

	current_diagram    : DIAGRAM;	-- The diagram currently being output
	current_diagram_id : INTEGER;


	ascii : ASCII;		-- The ASCII character set.  I just can't bear
						-- to inherit this!

	file_version : INTEGER is 1;
		-- This should be kept in sync with FILE_READER
		-- @@ Put it in a common base class

	write_logical_model (mm : LOGICAL_MODEL) is
		local
			i : INTEGER;
		do
			left_paren;
			write_token("logical-model");
			new_line;
			from i := 1 until i > mm.items.count loop
				(mm.items @ i).write_for_writer(Current);
				i := i + 1;
			end -- loop
			right_paren;
			new_line;
		end;

	set_current_diagram (d : DIAGRAM; id : INTEGER) is
		do
			current_diagram_id := id;
			current_diagram := d;
		end;

end -- class PROJECT_WRITER
